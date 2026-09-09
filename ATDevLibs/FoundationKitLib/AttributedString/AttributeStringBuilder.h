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
 
 @code
 
 NSShadow *shadow = [[NSShadow alloc] init];
 shadow.shadowColor = [UIColor blueColor];
 shadow.shadowOffset = CGSizeMake(2, 2);
 
 NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
 attachment.image = [UIImage sf_defaultSymbolImageWithName:@"arrow.up.circle.fill" tintColor:themeColor pointSize:36];;
 attachment.bounds = CGRectMake(0, -4, 16, 16);
 
 NSString *reasonStr = @"DCloud还提供了使用js编写服务器代码的uniCloud云引擎。所以只需掌握js，你可以开发web、Android、iOS、各家小程序以及服务器等全栈应用。";
 
 
 AttributeStringBuilder *build =  AttributeStringBuilder.build(@"颜色字体\n").fontSize(30).color([UIColor purpleColor])
     // 匹配（match/matchFirst/matchLast/regular）
     .append(@"链接A 链接B 链接C 数字123 数字456")
     .match(@"链接").hexColor(0xFF4400).underlineStyle(NSUnderlineStyleSingle).underlineColor([UIColor redColor])
     .matchFirst(@"数字").backgroundColor([UIColor yellowColor])
     .matchLast(@"数字").backgroundColor([UIColor cyanColor])
     .regular(@"\\d+", YES).color([UIColor blueColor])
     
     // 图片附件（appendImage/appendSizeImage/appendFontImage/appendCustomImage / insertImage/headInsertImag）
     .appendImage(icon)
     .appendSizeImage(icon, CGSizeMake(28, 28))
     .appendFontImage(smallIcon, [UIFont systemFontOfSize:18])
     .appendCustomImage(icon, CGSizeMake(24, 24), f14)
     .headInsertImage(smallIcon, CGSizeMake(18, 18), f14)
     .insertImage(smallIcon, CGSizeMake(18, 18), 0, f14)
     .append(@" 附件：").font(f14).appendAttachment(attachment)
     
     
     // 圆角文字标签（appendRoundedTag/tagFont/tagTextColor/tagBackgroundColor/tagCornerRadius/tagInsets）
     .appendRoundedTag(@"红色标签")
     .tagFont([UIFont boldSystemFontOfSize:14])
     .tagTextColor([UIColor whiteColor])
     .tagBackgroundColor([UIColor redColor])
     .tagCornerRadius(8)
     .tagInsets(UIEdgeInsetsMake(3, 6, 3, 6))
     
     // 圆角文字标签‑生成图片（appendBackgroundColor 系列，共 7 种变体）
     .appendBackgroundColor(@"基础款", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, 6, 0)
     .appendBackgroundColor(@"上偏移", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, 6, -3)
     .appendBackgroundInsetsColor(@"内边距款", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, 6, UIEdgeInsetsMake(4, 12, 4, 12), 0)
     .appendBackgroundMarginsColor(@"外边距款", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, 6, UIEdgeInsetsMake(2, 6, 2, 6), UIEdgeInsetsMake(2, 4, 2, 4), 0)
     .appendBackgroundSize(@"固定尺寸款", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, 6, CGSizeMake(48, 28), 0)
     .appendBackgroundCornerColor(@"圆角方向 - 左上圆角", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, r,UIRectCornerTopLeft, 0)
     .appendBackgroundCornerColor(@"圆角方向 - 右侧圆角", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, r, UIRectCornerTopRight | UIRectCornerBottomRight, 0)
     .appendBackgroundCornerSize(@"圆角方向+尺寸款", [UIFont systemFontOfSize:13], [UIColor whiteColor], fill, 6, UIRectCornerAllCorners, CGSizeMake(30, 30), 0)
     .appendBackgroundRadiusColor(@"完整参数（描边/线宽/内外边距）", [UIFont systemFontOfSize:13], [UIColor blueColor], [UIColor clearColor], 6,UIRectCornerAllCorners, CGSizeMake(0, 0),UIEdgeInsetsMake(3, 10, 3, 10),UIEdgeInsetsZero,[UIColor blueColor], 1, 0)
     
     // 左侧标题 + 右侧内容（内容多行，自动留出左侧标题空白）
     .append([NSString stringWithFormat:@"位置信息：%@", reasonStr]).font(AutoFont(12)).color([UIColor redColor])
     .headIndent(padding).tailIndent(0).lineBreakMode(NSLineBreakByCharWrapping)
     .append(@"\n\n").font([UIFont systemFontOfSize:2])
     .append([NSString stringWithFormat:@"位置信息：%@", reasonStr]).font(AutoFont(12)).color([UIColor blackColor])
     .headIndentCharacters(5, AutoFont(12)).tailIndent(0).lineBreakMode(NSLineBreakByCharWrapping)
     .append(@"\n\n").font([UIFont systemFontOfSize:2]);
     
     // 分割线
     .appendDividerLine(16, 16)
     .appendDividerLine(0, 0).dividerColor([UIColor lightGrayColor]).dividerThickness(1);
     
     // Glyph 属性（strikethrough/underline/stroke/textEffect/shadow/link/linkUrlStr）
     .append(@"删除线 ").font(f14).strikethroughStyle(NSUnderlineStyleSingle).strikethroughColor([UIColor redColor])
     .append(@"下划线 ").font(f14).underlineStyle(NSUnderlineStyleThick).underlineColor([UIColor greenColor])
     .append(@"中空字").font([UIFont boldSystemFontOfSize:18]).strokeColor([UIColor purpleColor]).strokeWidth(2)
     .append(@"\n浮雕效果").font(f16).textEffect(NSTextEffectLetterpressStyle)
     .append(@" 阴影").font(f16).shadow(shadow)
     .append(@" 链接").font(f16).link([NSURL URLWithString:@"https://www.apple.com"])
     .append(@" 链接字符串").font(f16).linkUrlStr(@"https://www.apple.com")
     
     // appendLeftRightLine（一行两段对齐，自动独占一行）
     .appendLeftRightLine(@"商品名称", @"¥99.00", kDemoWidth, f14)
     .appendLeftRightLine(@"运费", @"包邮", kDemoWidth, f14)
     .appendLeftRightLine(@"实付款", @"¥99.00", kDemoWidth, [UIFont boldSystemFontOfSize:14])
     
     // alignLeftRight（手动 \\t，右段为文本+图片）
     .append(@"金额：").font(f14)
     .append(@"\t")
     .appendSizeImage(smallIcon, CGSizeMake(18, 18)).append(@" ¥99.00").font(f14)
     .alignLeftRight(340) // 演示区域的固定内容宽度（Label使用该宽度）
     
     // headIndent / tailIndent
     .append(@"整体左缩进 + 右缩进。这段文字设置了 headIndent(20) 与 tailIndent(-20)，展示左右缩进后的排版。").font(f14).headIndent(20).tailIndent(-20)
     
     // 特殊属性（baselineOffset/kern/obliqueness/expansion/ligature）
     .append(@"上标").font(f14).baselineOffset(8).fontSize(10)
     .append(@" 下标").font(f14).baselineOffset(-6).fontSize(10)
     .append(@" 字间距").font(f14).kern(4)
     .append(@" 倾斜").font(f14).obliqueness(0.3)
     .append(@" 拉伸").font(f14).expansion(0.5)
     .append(@" 压缩").font(f14).expansion(-0.3)
     .append(@" 连字").font(f14).ligature(1)
     
     //  dynamicKern（对齐已追加的末尾文本宽度）
     .append(@"道路名称：").font(labelFont)
     .append(@"\n").font(labelFont)
     .append(@"上报人").font(labelFont).dynamicKern(@"道路名称", @"上报人", labelFont)
     
     // appendDynamicKern（追加并对齐
     .append(@"道路名称：").font(labelFont)
     .append(@"\n").font(labelFont)
     .appendDynamicKern(@"道路名称：", @"上报人：", labelFont).font(labelFont)
     .append(@"\n").font(labelFont)
     .appendDynamicKern(@"道路名称：", @"审核意见：", labelFont).font(labelFont)
     
     // appendDynamicFitKern（指定后缀长度）
     .append(@"道路名称：").font(labelFont)
     .append(@"\n").font(labelFont)
     .appendDynamicFitKern(@"道路名称：", @"上报人：", labelFont, 2).font(labelFont)
     .append(@"\n").font(labelFont)
     .appendDynamicFitKern(@"道路名称：", @"审核意见：", labelFont, 1).font(labelFont);
 
 _label.attributedText = [build commit];
 @endcode
 */
@interface AttributeStringBuilder : NSObject

/// 计算文本高度
/// - Parameters:
///   - attributedString: 富文本
///   - width: 宽度
+ (CGSize)calculateForAttributedString:(NSAttributedString *)attributedString withWidth:(CGFloat)width;


- (instancetype)init NS_UNAVAILABLE;

- (NSAttributedString*)commit;
/**
 获取当前 NSRange，当append、及获取range时
 */
- (NSRange)currentRange;

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

/// 从结尾倒数location 、 length 设置范围
- (AttributeStringBuilder *(^)(NSInteger location, NSInteger length))lastRange;

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

/// 字号，默认字体
- (AttributeStringBuilder *(^)(CGFloat boldFontSize))boldFontSize;

/// 字体颜色
- (AttributeStringBuilder *(^)(UIColor *color))color;

/// 字体颜色，16 进制
- (AttributeStringBuilder *(^)(NSInteger hex))hexColor;

/// 背景颜色
- (AttributeStringBuilder *(^)(UIColor *color))backgroundColor;

#pragma mark - 圆角文字标签（不生成图片）

/**
 追加一个圆角文字标签（直接绘制，不生成 UIImage）

 @note 连续多个标签需要自动换行时，承载的 UILabel 必须显式设置
       lineBreakMode = NSLineBreakByWordWrapping（或 NSLineBreakByCharWrapping）；
       UILabel 默认 NSLineBreakByTruncatingTail 会对 attachment 密集的行直接截断而非换行。
 */
- (AttributeStringBuilder *(^)(NSString *text))appendRoundedTag;

/// 标签字体
- (AttributeStringBuilder *(^)(UIFont *font))tagFont;

/// 标签文字颜色
- (AttributeStringBuilder *(^)(UIColor *color))tagTextColor;

/// 标签背景色
- (AttributeStringBuilder *(^)(UIColor *color))tagBackgroundColor;

/// 圆角半径
- (AttributeStringBuilder *(^)(CGFloat radius))tagCornerRadius;

/// 标签内边距
- (AttributeStringBuilder *(^)(UIEdgeInsets insets))tagInsets;



#pragma mark - 圆角文字标签（生成图片）

/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *_Nullable textColor, UIColor *_Nullable fillColor, CGFloat radius, CGFloat offsetY))appendBackgroundColor;

/**
 绘制带圆角边框和居中文本的自定义图片 （文本内边距）
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义图片大小
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion insets  文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *_Nullable textColor, UIColor *_Nullable fillColor, CGFloat radius, UIEdgeInsets insets, CGFloat offsetY))appendBackgroundInsetsColor;


/**
 绘制带圆角边框和居中文本的自定义图片 （文本内边距、边框以外的边距）
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义图片大小
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion insets  文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion margins  图片外边框边距（始终生效）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移

 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *_Nullable textColor, UIColor *_Nullable fillColor, CGFloat radius, UIEdgeInsets insets, UIEdgeInsets margins, CGFloat offsetY))appendBackgroundMarginsColor;


/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义图片大小
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion imgSize  图片固定宽高（width/height=0 表示该方向自适应）固定宽高(size.width=0/size.height=0表示不固定，文本水平/垂直居中)
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor * _Nullable textColor, UIColor * _Nullable fillColor, CGFloat radius, CGSize imgSize, CGFloat offsetY))appendBackgroundSize;

/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义圆角方向
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion corners  圆角方向组合（如：UIRectCornerTopLeft | UIRectCornerBottomRight）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor * _Nullable textColor, UIColor * _Nullable fillColor, CGFloat radius, UIRectCorner corners, CGFloat offsetY))appendBackgroundCornerColor;

/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。
 若固定宽高被指定，文本严格居中；否则根据内容自适应宽高，并按边距布局。
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion corners  圆角方向组合（如：UIRectCornerTopLeft | UIRectCornerBottomRight）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor * _Nullable textColor, UIColor * _Nullable fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, CGFloat offsetY))appendBackgroundCornerSize;

/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。
 若固定宽高被指定，文本严格居中；否则根据内容自适应宽高，并按边距布局。
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion corners  圆角方向组合（如：UIRectCornerTopLeft | UIRectCornerBottomRight）
 @discussion imgSize  图片固定宽高（width/height=0 表示该方向自适应）固定宽高(size.width=0/size.height=0表示不固定，文本水平/垂直居中)
 @discussion insets  文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion margins  图片外边框边距（始终生效）
 @discussion strokeColor  边框线颜色（nil 时无边框）
 @discussion lineWidth   边框线宽度（0 时无边框）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor * _Nullable textColor, UIColor * _Nullable fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, UIEdgeInsets insets, UIEdgeInsets margins, UIColor * _Nullable strokeColor, CGFloat lineWidth, CGFloat offsetY))appendBackgroundRadiusColor;


#pragma mark - 分割线

/**
 追加一行分割线（占一行高度，自动独占一行）
 
 @brief 分割线宽度在排版时自动撑满文本行，左右两端分别留出 leftSpacing / rightSpacing 的间距；
        线条粗细与颜色可通过 dividerThickness / dividerColor 配置（作用于最近追加的分割线）。
 
 @discussion leftSpacing   分割线左端距文本区左边界的间距（pt）
 @discussion rightSpacing  分割线右端距文本区右边界的间距（pt）
 
 @code
 AttributeStringBuilder.build(@"")
     .append(@"标题").font([UIFont systemFontOfSize:16])
     .appendDividerLine(16, 16).dividerColor([UIColor lightGrayColor]).dividerThickness(1)
     .append(@"正文").font([UIFont systemFontOfSize:14]);
 @endcode
 */
- (AttributeStringBuilder *(^)(CGFloat leftSpacing, CGFloat rightSpacing))appendDividerLine;

/// 分割线颜色（作用于最近追加的分割线，nil 时恢复默认浅灰）
- (AttributeStringBuilder *(^)(UIColor *color))dividerColor;

/// 分割线粗细，单位 pt（作用于最近追加的分割线）
- (AttributeStringBuilder *(^)(CGFloat thickness))dividerThickness;




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

/// 链接URL对象 NSURL
- (AttributeStringBuilder *(^)(NSURL *url))link;

/// 链接URL 字符串
- (AttributeStringBuilder *(^)(NSString *))linkUrlStr;

#pragma mark - Paragraph

/// 行间距
- (AttributeStringBuilder *(^)(CGFloat spacing))lineSpacing;

/// 段间距
- (AttributeStringBuilder *(^)(CGFloat spacing))paragraphSpacing;

/// 对齐
/// @note 仅作用于当前 Range。若 Range 落在段落中间，对齐可能不生效，
///       这种场景请改用 alignLeft / alignRight / alignCenter / alignJustified
- (AttributeStringBuilder *(^)(NSTextAlignment alignment))alignment;

/// 左对齐（自动扩展到当前 Range 所在的完整段落，段落内的文本与图片附件一起对齐）
- (AttributeStringBuilder *)alignLeft;

/// 右对齐（自动扩展到当前 Range 所在的完整段落，段落内的文本与图片附件一起对齐）
- (AttributeStringBuilder *)alignRight;

/// 居中对齐（自动扩展到当前 Range 所在的完整段落，段落内的文本与图片附件一起对齐）
- (AttributeStringBuilder *)alignCenter;

/// 两端对齐（自动扩展到当前 Range 所在的完整段落）
/// @note 一行文字自动撑满整行、左右两端齐平；不足一行的最后一行仍按左对齐处理
- (AttributeStringBuilder *)alignJustified;

/**
 一行内容两段对齐：同一行内前半段靠左、后半段靠右
 
 @brief 通过在行尾放置一个右对齐制表位实现：`\t` 之前的内容保持靠左，
        之后的内容被推到 lineWidth 处并右对齐。
 
 @discussion lineWidth  行的总宽度，通常为承载控件（UILabel）的内容宽度，
                        即控件宽度减去自身的 contentInset / 边距
 
 @note 左右两段既可以是文本，也可以是图片附件（图片通过 appendImage /
        appendSizeImage / appendCustomImage 等追加），制表位对齐对图片同样生效。
 
 @warning 调用方需要在两段文本之间自行插入 `\t`，例如：
 @code
 AttributeStringBuilder.build(@"")
     .append(@"商品名称").font([UIFont systemFontOfSize:14])
     .append(@"\t")
     .append(@"¥99.00").font([UIFont systemFontOfSize:14])
     .alignLeftRight(375);
 @endcode
 若不想手动拼 `\t`，可直接使用 appendLeftRightLine。
 */
- (AttributeStringBuilder *(^)(CGFloat lineWidth))alignLeftRight;

/**
 追加「左段 + 右段」一行内容，左段靠左、右段靠右（自动独占一行）
 
 @brief appendLeftRightLine 的便捷封装，内部自动拼接 `\t`、末尾换行并应用两段对齐，
        调用方无需关心制表位细节。
 
 @discussion leftText   靠左显示的文本（nil 视为空串）
 @discussion rightText  靠右显示的文本（nil 视为空串）
 @discussion lineWidth  行的总宽度，通常为承载控件的内容宽度
 @discussion font       文本字体（nil 时使用系统 17pt）
 
 @note 若左右段包含图片附件，请改用「手动 `\t` + alignLeftRight」的方式：
       在图片附件与右段内容之间插入 `\t`，最后调用 alignLeftRight(lineWidth)。
 
 @code
 AttributeStringBuilder.build(@"")
     .appendLeftRightLine(@"商品名称", @"¥99.00", 375, [UIFont systemFontOfSize:14])
     .appendLeftRightLine(@"运费", @"包邮", 375, [UIFont systemFontOfSize:14]);
 @endcode
 */
- (AttributeStringBuilder *(^)(NSString *leftText, NSString *rightText, CGFloat lineWidth, UIFont *_Nullable font))appendLeftRightLine;

/// 换行
- (AttributeStringBuilder *(^)(NSLineBreakMode mode))lineBreakMode;

/// 段第一行头部缩进
- (AttributeStringBuilder *(^)(CGFloat indent))firstLineHeadIndent;

/// 段第一行头部缩进字符数
/// @Discussion headIndentCharacters  缩进字符数
/// @Discussion indentFont  缩进字符的字体大小
- (AttributeStringBuilder *(^)(NSInteger headIndentCharacters, UIFont *headIndentFont))firstLineHeadIndentCharacters;


/// 段头部缩进 后续行的左边距
- (AttributeStringBuilder *(^)(CGFloat indent))headIndent;

/// 段头部缩进字符数  后续行的左边距
/// @Discussion headIndentCharacters  缩进字符数
/// @Discussion headIndentFont  缩进字符的字体大小
- (AttributeStringBuilder *(^)(NSInteger headIndentCharacters, UIFont *headIndentFont))headIndentCharacters;


/// 段尾部缩进 后续行相对于左边距的缩进量，负值表示超出左边距 如果setTailIndent:是负值，那么文本将会超出左边距，从而实现左边不超过起始左边点的效果。
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



/// 对已追加的末尾文本动态调整字间距，使其渲染宽度与参考文本对齐
///
/// @discussion 与 appendDynamicFitKern 的区别：
///             - 本方法 **不追加** 新文本，仅修改 builder 当前末尾已存在的文本属性
///             - 适用于先 .append(@"上报人") 再链式调用 .dynamicKern(...) 的场景
///             - 内部固定 suffixLength = 1（排除末尾1个字符），若需其他值请使用 appendDynamicFitKern
///
///             ⚠️ 调用前必须确保 builder 末尾已有文本，否则无效果
///
/// @code
/// AttributeStringBuilder.build(@"")
///     .append(@"道路名称：").font(labelFont)
///     .append(@"\n").font(labelFont)
///     .append(@"上报人").font(labelFont)
///     .dynamicKern(@"道路名称", @"上报人", labelFont);
/// @endcode
///
/// @note 本方法返回一个 Block，该 Block 接受以下三个参数：
///       - referenceText: 参考基准文本，以其渲染宽度作为对齐目标（不含后缀）
///       - fittingText:   用于计算宽度差值的动态文本（应与 builder 末尾文本内容一致）
///       - font:          文本使用的字体（参考文本与动态文本必须使用相同字体）
- (AttributeStringBuilder *(^)(NSString *referenceText, NSString *fittingText, UIFont *font))dynamicKern;



/// 追加动态文本并自动调整字间距，使其渲染宽度与参考文本对齐（固定排除尾部2个字符）
///
/// @discussion 这是 appendDynamicFitKern:suffixLength: 的便捷方法，
///             内部固定 suffixLength = 2，适用于标签后缀为两个字符的场景，如：
///             "道路名称：" ← 参考文本
///             "上报人："   ← 动态文本，末2位"人："不参与间距调整
///
///             ⚠️ 若后缀长度不为2，请使用 appendDynamicFitKern:suffixLength:
///
/// @code
/// AttributeStringBuilder.build(@"")
///     .append(@"道路名称：").font(labelFont)
///     .appendDynamicKern(@"道路名称：", @"上报人：", labelFont)
///     .append(@"\n").font(labelFont);
/// @endcode
///
/// @discussion 本方法返回一个 Block，该 Block 接受以下参数：<br/>
///
/// @discussion  - referenceText: 参考基准文本，以其渲染宽度作为对齐目标（不含后缀）<br/>
/// @discussion  - fittingText:   用于计算宽度差值的动态文本（长度必须 > 2）（应与 builder 末尾文本内容一致）<br/>
/// @discussion  - font:          文本使用的字体（参考文本与动态文本必须使用相同字体）
- (AttributeStringBuilder *(^)(NSString *referenceText, NSString *fittingText, UIFont *font))appendDynamicKern;

/// 追加动态文本并自动调整字间距，使其渲染宽度与参考文本对齐
///
/// @discussion 核心原理：计算「参考文本」与「动态文本」的宽度差值，
///             将差值均摊到动态文本的可调节字符上（排除尾部固定后缀），
///             通过 NSKernAttributeName 实现视觉上的等宽对齐。
///             适用于标签列对齐场景，如：
///             "道路名称：" ← 参考文本（4字中文+冒号）
///             "上报人："   ← 动态文本（3字中文+冒号），自动撑开至与上方等宽
///
/// @code
/// AttributeStringBuilder.build(@"")
///     .append(@"道路名称：").font(labelFont)
///     .appendDynamicFitKern(@"道路名称：", @"上报人：", labelFont, 1)
///     .append(@"\n").font(labelFont)
///     .appendDynamicFitKern(@"道路名称：", @"审核意见：", labelFont, 1);
/// @endcode
///
/// @note 本方法返回一个 Block，该 Block 接受以下参数：
///       - referenceText: 参考基准文本，以其渲染宽度作为对齐目标（不含后缀）
///       - fittingText:    需要调整字间距的动态文本（长度必须 > 2）（应与 builder 末尾文本内容一致）
///       - font:          文本使用的字体（参考文本与动态文本必须使用相同字体）
///       - suffixLength:          动态文本尾部不参与字间距调整的固定字符数
///                       （通常为冒号、空格等后缀，如 @"：" 传 1）
///                       字间距仅作用于前 (fittingText.length - suffixLength) 个字符
- (AttributeStringBuilder *(^)(NSString *referenceText, NSString *fittingText, UIFont *font, NSInteger suffixLength))appendDynamicFitKern;

/// 倾斜
- (AttributeStringBuilder *(^)(CGFloat obliqueness))obliqueness;

/// 扩张（压缩文字，正值为伸，负值为缩）
- (AttributeStringBuilder *(^)(CGFloat expansion))expansion;



///// 整体行间距  lineSpacing为零，则为默认行间距
//- (AttributeStringBuilder *(^)(CGFloat lineSpacing))lineSpacing;
//
///// 整体段间距  segmentSpacing为零，则为默认段间距
//- (AttributeStringBuilder *(^)(CGFloat segmentSpacing))segmentSpacing;



#pragma mark - 点击事件
//
///// 点击标记属性名：作用于被 tapAction 标记的字符，值 = 字符串 ID
//FOUNDATION_EXPORT NSAttributedStringKey const SCRAttributedStringTapIDAttributeName;
//
///// 点击回调注册表属性名：作用于整个字符串，值 = NSDictionary<NSString*, void(^)(void)>
//FOUNDATION_EXPORT NSAttributedStringKey const SCRAttributedStringTapActionsAttributeName;
//
///**
// 给当前 Range 注册点击事件
// 
// @brief 将当前 Range 标记为可点击，点击时回调 action。
// 无需自定义 UILabel 子类：把 commit 出的富文本赋给任意 UILabel，
// 再调用 [AttributeStringBuilder scr_enableTapOnLabel:label] 即可生效。
// 标记的视觉样式（颜色 / 下划线等）需调用方自行设置。
// 图片附件也是一个字符，可通过 .range(idx, 1) 选中后同样注册点击。
// 
// @code
// AttributeStringBuilder.build(@"")
// .append(@"点击我").font([UIFont systemFontOfSize:14])
// .color([UIColor blueColor]).underlineStyle(NSUnderlineStyleSingle)
// .tapAction(^{ NSLog(@"被点击了"); });
// // label.attributedText = [builder commit];
// // [AttributeStringBuilder scr_enableTapOnLabel:label];
// @endcode
// 
// @note 通过 attributedAppend 拼接的富文本若带有点击标记，其回调会自动合并，
// 拼接后点击事件仍然可用。
// */
//- (AttributeStringBuilder *(^)(void (^action)(void)))tapAction;
//
///**
// 让普通 UILabel 支持富文本点击（无需子类化 UILabel）
// 
// @brief 给 label 挂载点击手势并启用交互。手势回调内部用 TextKit 命中测试
// 解析点击坐标 → 找到被 tapAction 标记的字符 → 执行对应回调。
// 幂等：对同一个 label 重复调用不会重复添加手势。
// 
// @code
// UILabel *label = [[UILabel alloc] init];
// label.numberOfLines = 0;
// label.attributedText = [builder commit];
// [AttributeStringBuilder scr_enableTapOnLabel:label];
// @endcode
// 
// @note 1. 需在设置 attributedText 之后调用（回调注册表存储在富文本上）。
// 2. label 的 lineBreakMode 需与展示时一致（如 WordWrapping），命中测试
// 会按 label 当前布局解析。
// */
//+ (void)scr_enableTapOnLabel:(UILabel *)label;
//
///**
// 在指定点触发点击回调（坐标 → 字符 → 回调）
// 
// @brief 与 scr_enableTapOnLabel: 内部手势回调同一实现。
// 需要自定义手势/手动触发时可调用；测试也可直接调用验证。
// 点未命中任何被标记字符时无副作用。
// */
//+ (void)scr_handleTapAtPoint:(CGPoint)point onLabel:(UILabel *)label;

@end

NS_ASSUME_NONNULL_END
