//
//  SCDividerLineAttachment.m
//  ATDevLibs
//
//  Created by Mars on 2026/9/8.
//  Copyright © 2026 Mars. All rights reserved.
//

#import "SCDividerLineAttachment.h"
#import <os/lock.h>

@interface SCDividerLineAttachment () {
    /// 最近一次排版得到的分割线宽度（受 sc_lock 保护）
    /// attachmentBounds 在每次排版时都会被反复调用，用它避免渲染宽度的重复计算
    CGFloat sc_cachedWidth;

    /// 已渲染的分割线图片缓存（受 sc_lock 保护）
    /// image 可能在后台线程的文本布局过程中被读取
    UIImage *_Nullable sc_cachedImage;

    /// 保护以上缓存字段。零值即为有效初值，alloc 清零后无需额外初始化
    os_unfair_lock sc_lock;
}

@end

@implementation SCDividerLineAttachment

#pragma mark - 缓存管理

/**
 清空渲染缓存。

 所有影响显示效果的属性 setter 都会调用本方法，
 确保下一次 image / 布局回调被访问时重新计算。
 */
- (void)sc_invalidateCache {
    os_unfair_lock_lock(&sc_lock);
    sc_cachedImage = nil;
    sc_cachedWidth = 0;
    os_unfair_lock_unlock(&sc_lock);
}

#pragma mark - 属性变更监听 (属性变更时使缓存失效)

- (void)setLeftSpacing:(CGFloat)leftSpacing {
    _leftSpacing = leftSpacing;
    [self sc_invalidateCache];
}

- (void)setRightSpacing:(CGFloat)rightSpacing {
    _rightSpacing = rightSpacing;
    [self sc_invalidateCache];
}

- (void)setLineThickness:(CGFloat)lineThickness {
    _lineThickness = lineThickness;
    [self sc_invalidateCache];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self sc_invalidateCache];
}

#pragma mark - 布局

/**
 计算分割线的布局矩形：
 - 占满整个行宽（TextKit 会忽略 bounds.origin.x，水平偏移只能通过渲染内容实现）
 - 高度 = 线粗细
 - origin.y 为负表示相对基线向上偏移，使线条在行内垂直居中

 左右两端间距（leftSpacing / rightSpacing）由渲染阶段实现：
 线条只画在 [leftSpacing, 行宽 - rightSpacing] 区间内，其余区域透明。
 TextKit 会根据该返回值决定分割线占用的宽度和高度。
 */
- (CGRect)sc_dividerBoundsForLineFragment:(CGRect)lineFrag {
    CGFloat lineWidth = CGRectGetWidth(lineFrag);
    lineWidth = MAX(0, lineWidth);

    CGFloat thickness = [self sc_lineThickness];
    CGFloat lineHeight = CGRectGetHeight(lineFrag);

    return CGRectMake(0, -(lineHeight - thickness) / 2.0, lineWidth, thickness);
}

/// 线条在宽度为 width 的行内的可见区间（已做边界收敛，避免负数/越界）
- (CGRect)sc_lineRectForWidth:(CGFloat)width {
    CGFloat x0 = self.leftSpacing;
    CGFloat x1 = width - self.rightSpacing;
    if (x1 <= x0) {
        return CGRectZero;
    }
    return CGRectMake(x0, 0, x1 - x0, [self sc_lineThickness]);
}

/// TextKit 1（NSLayoutManager）布局路径
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    CGRect bounds = [self sc_dividerBoundsForLineFragment:lineFrag];
    [self sc_updateCachedWidth:CGRectGetWidth(bounds)];
    return bounds;
}

/// TextKit 2（NSTextLayoutManager）布局路径
- (CGRect)attachmentBoundsForAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                               location:(id<NSTextLocation>)location
                          textContainer:(NSTextContainer *)textContainer
                   proposedLineFragment:(CGRect)proposedLineFragment
                               position:(CGPoint)position API_AVAILABLE(ios(15.0)) {
    CGRect bounds = [self sc_dividerBoundsForLineFragment:proposedLineFragment];
    [self sc_updateCachedWidth:CGRectGetWidth(bounds)];
    return bounds;
}

#pragma mark - 渲染

- (CGFloat)sc_lineThickness {
    return MAX(0.5, self.lineThickness);
}

- (UIColor *)sc_lineColor {
    return self.lineColor ?: UIColor.lightGrayColor;
}

- (void)sc_updateCachedWidth:(CGFloat)width {
    os_unfair_lock_lock(&sc_lock);
    sc_cachedWidth = width;
    os_unfair_lock_unlock(&sc_lock);
}

/**
 渲染指定宽度的分割线图片（高度 = 线粗细）。

 线条只画在 [leftSpacing, width - rightSpacing] 区间内，
 左右两端为透明，从而在排版时呈现「左右留白」效果。

 设计要点：
 - 使用 UIGraphicsImageRenderer，scale 由 defaultFormat 按当前环境决定，
   不额外访问 [UIScreen mainScreen]，避免在后台线程布局时引入主线程依赖
 - 渲染前对属性做一次快照，避免渲染过程中被其他线程修改导致尺寸与内容不一致
 - 渲染过程不持锁，并发时最坏情况只是重复渲染一次，结果仍然正确
 */
- (nullable UIImage *)sc_renderLineImageWithWidth:(CGFloat)width {
    if (width <= 0) {
        return nil;
    }

    CGFloat renderWidth = ceil(width); // 取整避免边缘发虚
    CGFloat thickness = [self sc_lineThickness];
    UIColor *color = [self sc_lineColor];
    CGRect lineRect = [self sc_lineRectForWidth:renderWidth];

    os_unfair_lock_lock(&sc_lock);
    if (sc_cachedImage && fabs(sc_cachedWidth - renderWidth) < 0.5) {
        UIImage *cached = sc_cachedImage;
        os_unfair_lock_unlock(&sc_lock);
        return cached;
    }
    os_unfair_lock_unlock(&sc_lock);

    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(renderWidth, thickness)
                                                                               format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        if (CGRectGetWidth(lineRect) > 0) {
            [color setFill];
            [rendererContext fillRect:lineRect];
        }
    }];

    os_unfair_lock_lock(&sc_lock);
    sc_cachedImage = image;
    sc_cachedWidth = renderWidth;
    os_unfair_lock_unlock(&sc_lock);

    return image;
}

/// 兜底路径：部分渲染实现会直接读取 attachment.image。
/// 宽度以最近一次排版结果为准；未排版（无宽度）时返回 nil，由 imageForBounds / drawWithFrame 路径兜底。
- (nullable UIImage *)image {
    os_unfair_lock_lock(&sc_lock);
    CGFloat width = sc_cachedWidth;
    os_unfair_lock_unlock(&sc_lock);
    if (width <= 0) {
        return nil;
    }
    return [self sc_renderLineImageWithWidth:width];
}

/// TextKit 1 取图路径
- (nullable UIImage *)imageForBounds:(CGRect)imageBounds
                      textContainer:(NSTextContainer *)textContainer
                     characterIndex:(NSUInteger)charIndex {
    [self sc_updateCachedWidth:CGRectGetWidth(imageBounds)];
    return [self sc_renderLineImageWithWidth:CGRectGetWidth(imageBounds)];
}

/// TextKit 2 取图路径
- (nullable UIImage *)imageForBounds:(CGRect)bounds
                         attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                           location:(id<NSTextLocation>)location
                      textContainer:(NSTextContainer *)textContainer API_AVAILABLE(ios(15.0)) {
    [self sc_updateCachedWidth:CGRectGetWidth(bounds)];
    return [self sc_renderLineImageWithWidth:CGRectGetWidth(bounds)];
}

/// 直接绘制路径（TextKit 1 的 drawWithFrame:）
/// frame 即布局回调返回的 bounds 矩形在视图坐标系中的位置，
/// 线条只画在 [leftSpacing, 宽度 - rightSpacing] 区间内，实现左右留白
- (void)drawWithFrame:(CGRect)frame
               inView:(UIView *)view
        characterIndex:(NSUInteger)charIndex
        layoutManager:(NSLayoutManager *)layoutManager {
    if (CGRectGetWidth(frame) <= 0 || CGRectGetHeight(frame) <= 0) {
        return;
    }
    CGRect lineRect = [self sc_lineRectForWidth:CGRectGetWidth(frame)];
    if (CGRectGetWidth(lineRect) <= 0) {
        return;
    }
    lineRect.origin.x += CGRectGetMinX(frame);
    lineRect.origin.y += CGRectGetMinY(frame);
    [[self sc_lineColor] setFill];
    UIRectFill(lineRect);
}

@end
