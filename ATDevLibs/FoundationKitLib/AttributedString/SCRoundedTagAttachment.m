//
//  SCRoundedTagAttachment.m
//  EngineeringCool
//
//  Created by Mars on 2026/9/2.
//  Copyright © 2026 Mars. All rights reserved.
//

#import "SCRoundedTagAttachment.h"
#import <os/lock.h>

@interface SCRoundedTagAttachment () {
    /// 渲染结果缓存，受 sc_cacheLock 保护
    /// （image 可能在后台线程的文本布局过程中被读取）
    UIImage *_Nullable sc_cachedImage;

    /// attachment 尺寸缓存，受 sc_cacheLock 保护
    /// attachmentBounds 在每次排版时都会被反复调用，避免重复做文本测量
    CGSize sc_cachedSize;
    BOOL sc_hasCachedSize;

    /// 保护以上缓存字段。零值即为有效初值，alloc 清零后无需额外初始化
    os_unfair_lock sc_cacheLock;
}

@end

@implementation SCRoundedTagAttachment

#pragma mark - 缓存管理

/**
 清空渲染与尺寸缓存。

 所有影响显示效果的属性 setter 都会调用本方法，
 确保下一次 image / attachmentBounds 被访问时重新计算。
 */
- (void)sc_invalidateCache {
    os_unfair_lock_lock(&sc_cacheLock);
    sc_cachedImage = nil;
    sc_hasCachedSize = NO;
    os_unfair_lock_unlock(&sc_cacheLock);
}

#pragma mark - 属性变更监听 (属性变更时使缓存失效)

- (void)setText:(NSString *)text {
    _text = [text copy];
    [self sc_invalidateCache];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self sc_invalidateCache];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self sc_invalidateCache];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self sc_invalidateCache];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self sc_invalidateCache];
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [self sc_invalidateCache];
}

#pragma mark - 尺寸计算

/**
 计算标签尺寸：文字尺寸 + 内边距，并向上取整。

 结果会被缓存，属性变更后自动失效。
 */
- (CGSize)sc_tagSize {
    os_unfair_lock_lock(&sc_cacheLock);
    if (sc_hasCachedSize) {
        CGSize cached = sc_cachedSize;
        os_unfair_lock_unlock(&sc_cacheLock);
        return cached;
    }
    os_unfair_lock_unlock(&sc_cacheLock);

    UIFont *font = self.font ?: [UIFont systemFontOfSize:14];
    CGSize textSize = [(self.text ?: @"") sizeWithAttributes:@{NSFontAttributeName: font}];

    CGSize size = CGSizeMake(MAX(1, ceil(textSize.width  + self.insets.left + self.insets.right)),
                             MAX(1, ceil(textSize.height + self.insets.top  + self.insets.bottom)));

    os_unfair_lock_lock(&sc_cacheLock);
    sc_cachedSize = size;
    sc_hasCachedSize = YES;
    os_unfair_lock_unlock(&sc_cacheLock);

    return size;
}

/**
 返回 attachment 在文本行中的布局矩形。

 TextKit 会根据该返回值决定：
 - attachment 占用的宽度和高度
 - 垂直对齐基线（通过 bounds.origin.y 微调）

 origin.y = -1 表示相对基线向上偏移 1pt，使标签在文本行中视觉居中。
 */
- (CGRect)sc_attachmentBounds {
    CGSize size = [self sc_tagSize];
    return CGRectMake(0, -1, size.width, size.height);
}

#pragma mark - 布局回调

/// TextKit 1（NSLayoutManager）布局路径
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    return [self sc_attachmentBounds];
}

/// TextKit 2（NSTextLayoutManager）布局路径
- (CGRect)attachmentBoundsForAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                               location:(id<NSTextLocation>)location
                          textContainer:(NSTextContainer *)textContainer
                   proposedLineFragment:(CGRect)proposedLineFragment
                               position:(CGPoint)position API_AVAILABLE(ios(15.0)) {
    return [self sc_attachmentBounds];
}

#pragma mark - 渲染

/**
 在 iOS 的现代 TextKit 实现中：
 - TextKit 通常直接访问 attachment.image 进行绘制
 - 部分路径（NSStringDrawing / UILabel）会走 imageForBounds:

 因此这里采用“惰性渲染 + 缓存”的策略：
 - 首次访问 image 时渲染
 - 属性变化后缓存失效，下次访问重新渲染
 */
- (UIImage *)image {
    return [self sc_renderTagImage];
}

/// TextKit 1 取图路径
- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)charIndex {
    return [self sc_renderTagImage];
}

/// TextKit 2 取图路径
- (UIImage *)imageForBounds:(CGRect)bounds
                 attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                   location:(id<NSTextLocation>)location
              textContainer:(NSTextContainer *)textContainer API_AVAILABLE(ios(15.0)) {
    return [self sc_renderTagImage];
}

#pragma mark - 核心渲染逻辑

/**
 将“圆角背景 + 文字”渲染为 UIImage。

 设计要点：
 - 使用 UIGraphicsImageRenderer，scale 由 defaultFormat 按当前环境决定，
   不需要（也不应该）额外访问 [UIScreen mainScreen]，以免在后台线程布局时引入主线程依赖
 - 渲染前对属性做一次快照，避免渲染过程中被其他线程修改导致尺寸与内容不一致
 - 渲染过程不持锁，并发时最坏情况只是重复渲染一次，结果仍然正确
 */
- (UIImage *)sc_renderTagImage {
    os_unfair_lock_lock(&sc_cacheLock);
    UIImage *cached = sc_cachedImage;
    os_unfair_lock_unlock(&sc_cacheLock);
    if (cached) {
        return cached;
    }

    // 属性快照
    NSString *text = self.text ?: @"";
    UIFont *font = self.font ?: [UIFont systemFontOfSize:14];
    UIColor *textColor = self.textColor ?: UIColor.blackColor;
    UIColor *fillColor = self.fillColor;
    UIEdgeInsets insets = self.insets;

    CGSize size = [self sc_tagSize];
    CGFloat width = size.width;
    CGFloat height = size.height;

    // 圆角半径不能超过短边的一半，否则贝塞尔路径会自交、画出异常形状
    CGFloat cornerRadius = MIN(MAX(self.cornerRadius, 0), MIN(width, height) / 2.0);

    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(width, height)
                                                                               format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGRect rect = CGRectMake(0, 0, width, height);

        // 圆角背景（无填充色时保持透明，不绘制）
        if (fillColor) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
            [fillColor setFill];
            [path fill];
        }

        // 绘制文字（水平按内边距对齐，垂直居中）
        NSDictionary *attrs = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor
        };
        CGSize textSize = [text sizeWithAttributes:attrs];
        CGFloat x = insets.left;
        CGFloat y = (height - textSize.height) / 2.0;
        [text drawAtPoint:CGPointMake(x, y) withAttributes:attrs];
    }];

    os_unfair_lock_lock(&sc_cacheLock);
    sc_cachedImage = image;
    os_unfair_lock_unlock(&sc_cacheLock);

    return image;
}

@end
