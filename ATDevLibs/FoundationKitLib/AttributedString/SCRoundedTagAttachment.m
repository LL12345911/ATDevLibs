//
//  SCRoundedTagAttachment.m
//  EngineeringCool
//
//  Created by Mars on 2026/9/2.
//  Copyright © 2026 Mars. All rights reserved.
//

#import "SCRoundedTagAttachment.h"

@interface SCRoundedTagAttachment ()
/// 惰性渲染缓存的图片（首次绘制时生成，属性变更后失效）
/// 缓存的渲染图片
/// - 首次被 TextKit 读取时生成
/// - 任意显示属性变更后自动失效
@property (nonatomic, strong) UIImage *sc_cachedImage;

@end

@implementation SCRoundedTagAttachment

#pragma mark - 属性变更监听 (属性变更时使缓存失效)

// 所有影响显示效果的属性 setter 中，统一清空缓存，
// 确保下一次 image 被访问时重新渲染。
- (void)setText:(NSString *)text {
    _text = [text copy];
    self.sc_cachedImage = nil;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.sc_cachedImage = nil;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.sc_cachedImage = nil;
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.sc_cachedImage = nil;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.sc_cachedImage = nil;
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    self.sc_cachedImage = nil;
}

#pragma mark - 布局尺寸
/**
 返回 attachment 在文本行中的布局矩形。
 
 TextKit 会根据该方法的返回值决定：
 - attachment 占用的宽度和高度
 - 垂直对齐基线（通过 bounds.origin.y 微调）
 
 这里以文字尺寸 + 内边距作为最终尺寸。
 */
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    UIFont *font = self.font ?: [UIFont systemFontOfSize:14];
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName: font}];

    CGFloat width  = ceil(textSize.width  + self.insets.left + self.insets.right);
    CGFloat height = ceil(textSize.height + self.insets.top  + self.insets.bottom);
    
    // origin.y = -1 用于微调垂直对齐，使标签在文本行中视觉居中
    return CGRectMake(0, -1, width, height);
}

#pragma mark - 渲染
/**
 在 iOS 的现代 TextKit 实现中：
 - TextKit 通常直接访问 attachment.image 进行绘制
 - 不再调用 imageForBounds: / drawInRect:
 
 因此这里采用“惰性渲染 + 缓存”的策略：
 - 首次访问 image 时渲染
 - 属性变化后缓存失效，下次访问重新渲染
 */
- (UIImage *)image {
    return [self sc_renderTagImage];
}

/**
 兼容路径：
 部分系统版本或特殊文本容器仍可能调用 imageForBounds: 获取图片。
 */
- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)charIndex
      effectiveCharacterRange:(NSRangePointer)effectiveCharacterRange {
    // 兼容：个别版本可能走 imageForBounds 路径
    return [self sc_renderTagImage];
}

#pragma mark - 核心渲染逻辑

/**
 将“圆角背景 + 文字”渲染为 UIImage。
 
 设计要点：
 - 使用 UIGraphicsImageRenderer，保证清晰度与线程安全性
 - 显式指定 scale，避免在非主线程或不同屏幕下模糊
 - 渲染结果被缓存，避免重复绘制
 */
- (UIImage *)sc_renderTagImage {
    if (self.sc_cachedImage) {
        return self.sc_cachedImage;
    }

    UIFont *font = self.font ?: [UIFont systemFontOfSize:14];
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName: font}];

    CGFloat width  = ceil(textSize.width  + self.insets.left + self.insets.right);
    CGFloat height = ceil(textSize.height + self.insets.top  + self.insets.bottom);
    width  = MAX(1, width);
    height = MAX(1, height);

    // defaultFormat 不要求主线程（preferredFormat 必须在主线程调用，而 attachment.image
    // 可能在后台线程的文本尺寸计算中被读取），并显式指定屏幕 scale 保证清晰度。
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = [UIScreen mainScreen].scale;
    format.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(width, height)
                                                                              format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGRect rect = CGRectMake(0, 0, width, height);

        // 圆角背景
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
        [self.fillColor setFill];
        [path fill];

        // 绘制文字（水平左对齐，垂直居中）
        NSDictionary *attrs = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor ?: UIColor.blackColor
        };
        CGSize drawSize = [self.text sizeWithAttributes:attrs];
        CGFloat x = self.insets.left;
        CGFloat y = (rect.size.height - drawSize.height) / 2.0;
        [self.text drawAtPoint:CGPointMake(x, y) withAttributes:attrs];
    }];

    self.sc_cachedImage = image;
    return image;
}

#pragma mark - 旧系统兼容

/**
 兼容旧版 TextKit：
 在极少数系统或自定义文本容器中，仍可能直接调用 drawInRect: 进行绘制。
 */
- (void)drawInRect:(CGRect)rect
   inTextContainer:(NSTextContainer *)textContainer
    characterIndex:(NSUInteger)charIndex {
    if (!self.text.length) return;

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    // 圆角背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
    [self.fillColor setFill];
    [path fill];

    // 文字绘制
    NSDictionary *attrs = @{
        NSFontAttributeName: self.font ?: [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName: self.textColor ?: UIColor.blackColor
    };

    CGSize textSize = [self.text sizeWithAttributes:attrs];
    CGFloat x = rect.origin.x + self.insets.left;
    CGFloat y = rect.origin.y + (rect.size.height - textSize.height) / 2.0;
    [self.text drawAtPoint:CGPointMake(x, y) withAttributes:attrs];

    CGContextRestoreGState(ctx);
}

@end
