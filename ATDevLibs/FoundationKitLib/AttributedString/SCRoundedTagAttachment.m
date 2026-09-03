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
@property (nonatomic, strong) UIImage *sc_cachedImage;
@end

@implementation SCRoundedTagAttachment

#pragma mark - 属性变更时使缓存失效

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

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    UIFont *font = self.font ?: [UIFont systemFontOfSize:14];
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName: font}];

    CGFloat width  = ceil(textSize.width  + self.insets.left + self.insets.right);
    CGFloat height = ceil(textSize.height + self.insets.top  + self.insets.bottom);
    return CGRectMake(0, -1, width, height);
}

#pragma mark - 渲染
/**
 实测（iOS 26 模拟器，UILabel / UITextView 均验证）：
 现代 TextKit 直接读取 attachment.image 绘制，不再调用自定义 attachment 的
 imageForBounds:... / drawInRect:...。
 因此这里重写 image getter：首次被读取时惰性渲染一张与 bounds 等尺寸的图片并缓存，
 属性变更后缓存失效、下次读取时重新渲染。不预生成、不落地文件。
 */
- (UIImage *)image {
    return [self sc_renderTagImage];
}

- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)charIndex
      effectiveCharacterRange:(NSRangePointer)effectiveCharacterRange {
    // 兼容：个别版本可能走 imageForBounds 路径
    return [self sc_renderTagImage];
}

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
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                        cornerRadius:self.cornerRadius];
        [self.fillColor setFill];
        [path fill];

        // 文字（水平/垂直居中）
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

/// 兼容旧系统：个别版本仍可能走 drawInRect 路径
- (void)drawInRect:(CGRect)rect
   inTextContainer:(NSTextContainer *)textContainer
    characterIndex:(NSUInteger)charIndex {
    if (!self.text.length) return;

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    // 圆角背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                    cornerRadius:self.cornerRadius];
    [self.fillColor setFill];
    [path fill];

    // 文字
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
