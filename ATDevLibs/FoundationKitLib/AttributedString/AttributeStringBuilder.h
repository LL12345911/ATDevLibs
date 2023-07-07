//
///  AttributeStringBuilder.h
///  SCRAttributedStringBuilderDemo
//
///  Created by Mars on 2023/3/24.
///  Copyright © 2023 Chuanren Shang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 
 @brief  原理说明：
         将方法分为 Content，Range 和 Attribute 三类，其中 Content 用于添加内容，Attribute 用于给内容应用属性，而 Range 用于调整应用范围。
         因此，在 Content 中，无论是 append 还是 insert，会将当前 Range 切换成新加入内容的，属性会应用在此 Range 上。
         由于属性主要用于应用在字符上，因此附件不会切换 Range。另外为了应对 match 到多个的情况，Range 是一个数组。
 
 @discussion NSShadow *shadow = [[NSShadow alloc] init];
 
 @discussion shadow.shadowColor = [UIColor blueColor];
 @discussion shadow.shadowOffset = CGSizeMake(2, 2);
 @discussion NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
 
 @discussion attachment.image = [UIImage imageNamed:@"luffer"];
 @discussion attachment.bounds = CGRectMake(0, 0, 50, 50);
 @discussion NSString *text = @"测试多行文字测试多行文字测试多行文字链接测试多行文字测试多行文字链接测试多行文字测试多行文字测试多行文字链接测试多行文字测试多行文字测试多行文字\n";
 
 @discussion AttributeStringBuilder *build =  AttributeStringBuilder.build(@"颜色字体\n").fontSize(30).color([UIColor purpleColor])
     .range(1, 1).color([UIColor redColor])
     .insert(@"/插入文字/", 2).fontSize(20).color([UIColor blueColor])
     .append(text).firstLineHeadIndent(20).lineHeight(25).paragraphSpacing(20)
     .match(@"链接").hexColor(0xFF4400).backgroundColor([UIColor lightGrayColor])
     .matchFirst(@"链接").underlineStyle(NSUnderlineStyleThick).underlineColor([UIColor greenColor])
     .matchLast(@"链接").strikethroughStyle(NSUnderlineStyleSingle).strikethroughColor([UIColor yellowColor])
     .append(text).alignment(NSTextAlignmentCenter).headIndent(20).tailIndent(-20).lineSpacing(10)
     .append(@"路飞").font([UIFont systemFontOfSize:25]).strokeWidth(2).strokeColor([UIColor darkGrayColor])
     .headInsertImage([UIImage imageNamed:@"luffer"], CGSizeMake(50, 50), [UIFont systemFontOfSize:25])
     .appendSizeImage([UIImage imageNamed:@"luffer"], CGSizeMake(50, 50))
     .appendCustomImage([UIImage imageNamed:@"luffer"], CGSizeMake(50, 50), [UIFont systemFontOfSize:15])
     .append(@"路飞").font([UIFont systemFontOfSize:15])
     .appendSpacing(20)
     .appendAttachment(attachment)
     .insertImage([UIImage imageNamed:@"luffer"], CGSizeMake(50, 50), 0, [UIFont systemFontOfSize:30])
     .append(@"\n阴影").shadow(shadow).append(@"基线偏移\n").baselineOffset(-5)
     .append(@" ").backgroundColor([UIColor redColor]).fontSize(2);
 
 @discussion self.label.attributedText = [build commit];
 */
@interface AttributeStringBuilder : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (NSAttributedString*)commit;

#pragma mark - Content

/// 创建一个 Attributed String
+ (AttributeStringBuilder *(^)(NSString *string))build;

/// 尾部追加一个新的 Attributed String
- (AttributeStringBuilder *(^)(NSString *string))append;

/// 同 append 比，参数是 NSAttributedString
- (AttributeStringBuilder *(^)(NSAttributedString *attributedString))attributedAppend;

/// 插入一个新的 Attributed String
- (AttributeStringBuilder *(^)(NSString *string, NSUInteger index))insert;

/// 增加间隔，spacing 的单位是 point。放到 Content 的原因是，间隔是通过空格+字体模拟的，但不会导致 Range 的切换
- (AttributeStringBuilder *(^)(CGFloat spacing))appendSpacing;

/// 尾部追加一个附件。同插入字符不同，插入附件并不会将当前 Range 切换成附件所在的 Range，下同
- (AttributeStringBuilder *(^)(NSTextAttachment *))appendAttachment;

/// 在尾部追加图片附件，默认使用图片尺寸，图片垂直居中，为了设置处理垂直居中（基于字体的 capHeight），需要在添加图片附件之前设置字体
- (AttributeStringBuilder *(^)(UIImage *image))appendImage;

/// 在尾部追加图片附件，可以自定义尺寸，默认使用图片前一位的字体进行对齐，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *image, CGSize imageSize))appendSizeImage;

/// 在尾部追加图片附件，可以自定义想对齐的字体，图片使用自身尺寸，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *, UIFont *))appendFontImage;

/// 在尾部追加图片附件，可以自定义尺寸和想对齐的字体，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *image, CGSize imageSize, UIFont *font))appendCustomImage;

/// 在 index 位置插入图片附件，由于不确定字体信息，因此需要显式输入字体
- (AttributeStringBuilder *(^)(UIImage *image, CGSize imageSize, NSUInteger index, UIFont *font))insertImage;

/// 同 insertImage 的区别在于，会在当前 Range 的头部插入图片附件，如果没有 Range 则什么也不做
- (AttributeStringBuilder *(^)(UIImage *, CGSize, UIFont *))headInsertImage;

#pragma mark - Range

/// 根据 start 和 length 设置范围
- (AttributeStringBuilder *(^)(NSInteger location, NSInteger length))range;

/// 将范围设置为当前字符串全部
- (AttributeStringBuilder *)all;

/// 匹配所有符合的字符串
- (AttributeStringBuilder *(^)(NSString *string))match;

/// 从头开始匹配第一个符合的字符串
- (AttributeStringBuilder *(^)(NSString *string))matchFirst;

/// 为尾开始匹配第一个符合的字符串
- (AttributeStringBuilder *(^)(NSString *string))matchLast;

/**
 正则表达式
 
 @Discussion regularExpression 正则表达式
 @Discussion all 是否匹配所有
 */
-(AttributeStringBuilder *(^)(NSString *regularExpression, BOOL all))regular;


#pragma mark - Basic

/// 字体
- (AttributeStringBuilder *(^)(UIFont *font))font;

/// 字号，默认字体
- (AttributeStringBuilder *(^)(CGFloat fontSize))fontSize;

/// 字体颜色
- (AttributeStringBuilder *(^)(UIColor *color))color;

/// 字体颜色，16 进制
- (AttributeStringBuilder *(^)(NSInteger hex))hexColor;

/// 背景颜色
- (AttributeStringBuilder *(^)(UIColor *color))backgroundColor;



/**
 背景圆角

 @discussion string  背景文字
 @discussion font  文字字体
 @discussion textColor  文字颜色
 @discussion fillColor  填充背景色
 @discussion radius  圆角
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGFloat offsetY))appendBackgroundColor;

/**
 背景圆角
 
 @discussion string  背景文字
 @discussion font  文字字体
 @discussion textColor  文字颜色
 @discussion fillColor  填充背景色
 @discussion radius  圆角
 @discussion imgSize  固定宽高(size.width=0/size.height=0表示不固定，文本水平/垂直居中)
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGSize imgSize, CGFloat offsetY))appendBackgroundSize;

/**
 背景圆角
 
 @discussion string  背景文字
 @discussion font  文字字体
 @discussion textColor  文字颜色
 @discussion fillColor  填充背景色
 @discussion radius  圆角
 @discussion corners  圆角属性
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGFloat offsetY))appendBackgroundCornerColor;

/**
 背景圆角
 
 @discussion string  背景文字
 @discussion font  文字字体
 @discussion textColor  文字颜色
 @discussion fillColor  填充背景色
 @discussion radius  圆角
 @discussion corners  圆角属性
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, CGFloat offsetY))appendBackgroundCornerSize;

/**
 背景圆角
 
 @discussion text  文本数据
 @discussion font  文字字体
 @discussion textColor  文字颜色
 @discussion fillColor  填充背景色
 @discussion radius  圆角半径
 @discussion corners  圆角属性
 @discussion imgSize  固定宽高(size.width=0/size.height=0表示不固定，文本水平/垂直居中)
 @discussion insets  文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion margins  边框以外的边距
 @discussion strokeColor  边框线颜色
 @discussion lineWidth   宽度
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, UIEdgeInsets insets, UIEdgeInsets margins, UIColor *strokeColor, CGFloat lineWidth, CGFloat offsetY))appendBackgroundRadiusColor;


#pragma mark - Glyph

/**
 删除线风格
 
 @discussion NSUnderlineStyleNone 默认值
 @discussion NSUnderlineStyleNone 不设置删除线
 @discussion NSUnderlineStyleSingle 设置删除线为细单实线
 @discussion NSUnderlineStyleThick 设置删除线为粗单实线
 @discussion NSUnderlineStyleDouble 设置删除线为细双实线
 */
- (AttributeStringBuilder *(^)(NSUnderlineStyle style))strikethroughStyle;

/// 删除线颜色
/// 由于 iOS 的 Bug，删除线在 iOS 10.3 中无法正确显示，需要配合 baseline 使用
/// 具体见：https://stackoverflow.com/questions/43074652/ios-10-3-nsstrikethroughstyleattributename-is-not-rendered-if-applied-to-a-sub
- (AttributeStringBuilder *(^)(UIColor *color))strikethroughColor;

/**
 下划线风格

@discussion NSUnderlineStyleNone 默认值
@discussion NSUnderlineStyleNone 不设置删除线
@discussion NSUnderlineStyleSingle 设置删除线为细单实线
@discussion NSUnderlineStyleThick 设置删除线为粗单实线
@discussion NSUnderlineStyleDouble 设置删除线为细双实线
*/
- (AttributeStringBuilder *(^)(NSUnderlineStyle style))underlineStyle;

/// 下划线颜色
- (AttributeStringBuilder *(^)(UIColor *color))underlineColor;

/// 字形边框颜色
/// @discussion 中空文字的颜色
- (AttributeStringBuilder *(^)(UIColor *color))strokeColor;

/// 字形边框宽度
/// @discussion 中空的线宽度
- (AttributeStringBuilder *(^)(CGFloat width))strokeWidth;

/// 设置文本特殊效果
/// @discussion NSTextEffectLetterpressStyle
- (AttributeStringBuilder *(^)(NSString *effect))textEffect;

/// 阴影
- (AttributeStringBuilder *(^)(NSShadow *shadow))shadow;

/// 链接
- (AttributeStringBuilder *(^)(NSURL *url))link;

#pragma mark - Paragraph

/// 行间距
- (AttributeStringBuilder *(^)(CGFloat spacing))lineSpacing;

/// 段间距
- (AttributeStringBuilder *(^)(CGFloat spacing))paragraphSpacing;

/// 对齐
- (AttributeStringBuilder *(^)(NSTextAlignment alignment))alignment;

/// 换行
- (AttributeStringBuilder *(^)(NSLineBreakMode mode))lineBreakMode;

/// 段第一行头部缩进
- (AttributeStringBuilder *(^)(CGFloat indent))firstLineHeadIndent;

/// 段头部缩进
- (AttributeStringBuilder *(^)(CGFloat indent))headIndent;

/// 段尾部缩进
- (AttributeStringBuilder *(^)(CGFloat indent))tailIndent;

/// 行高，iOS 的行高会在顶部增加空隙，效果一般不符合 UI 的认知，很少使用
/// 这里为了完全匹配 Sketch 的行高效果，会根据当前字体对 baselineOffset 进行修正
/// 具体见: https://joeshang.github.io/2018/03/29/ios-multiline-text-spacing/
- (AttributeStringBuilder *(^)(CGFloat lineHeight))lineHeight;

#pragma mark - Special

/// 基线偏移
- (AttributeStringBuilder *(^)(CGFloat offset))baselineOffset;

/// 连字
- (AttributeStringBuilder *(^)(CGFloat ligature))ligature;

/// 字间距
- (AttributeStringBuilder *(^)(CGFloat kern))kern;

/// 倾斜
- (AttributeStringBuilder *(^)(CGFloat obliqueness))obliqueness;

/// 扩张（压缩文字，正值为伸，负值为缩）
- (AttributeStringBuilder *(^)(CGFloat expansion))expansion;



///// 整体行间距  lineSpacing为零，则为默认行间距
//- (AttributeStringBuilder *(^)(CGFloat lineSpacing))lineSpacing;
//
///// 整体段间距  segmentSpacing为零，则为默认段间距
//- (AttributeStringBuilder *(^)(CGFloat segmentSpacing))segmentSpacing;

@end

NS_ASSUME_NONNULL_END
