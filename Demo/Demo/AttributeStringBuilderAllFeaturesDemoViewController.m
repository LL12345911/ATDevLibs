//
//  AttributeStringBuilderAllFeaturesDemoViewController.m
//  Demo
//
//  覆盖 AttributeStringBuilder 全部公开功能的示例代码。
//  修改：全部内容合并到**单个UILabel**中展示，不再多个label
//  使用方法：将本文件拖入 Demo 工程（勾选 Target: Demo），
//  然后在 AppDelegate / SceneDelegate 里把根控制器换成：
//      self.window.rootViewController = [[AttributeStringBuilderAllFeaturesDemoViewController alloc] init];
//  即可在模拟器中看到每一组功能的渲染效果。
//
//  分组（与 AttributeStringBuilder.h 的章节一一对应）：
//    1 基础内容与属性     2 插入与 Range     3 图片附件
//    4 圆角文字标签(不生成图片)  5 圆角文字标签(生成图片)
//    6 分割线             7 Glyph 属性       8 段落属性
//    9 特殊属性           10 文本尺寸计算
//

#import "AttributeStringBuilderAllFeaturesDemoViewController.h"

#import <UIKit/UIKit.h>
#import "AttributeStringBuilder.h"
#import "ATDevLibs.h"

@interface AttributeStringBuilderAllFeaturesDemoViewController()
/// 点击事件演示的状态提示行
@property (nonatomic, strong) UILabel *scr_statusLabel;
@end

@implementation AttributeStringBuilderAllFeaturesDemoViewController

/// 演示区域的固定内容宽度（Label使用该宽度）
static const CGFloat kDemoWidth = 340.0;

#pragma mark - 辅助

/// 生成一张纯色占位图，避免 Demo 依赖具体图片资源
- (UIImage *)demoPlaceholderImageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [color setFill];
        [ctx fillRect:CGRectMake(0, 0, size.width, size.height)];
    }];
}

/// 构建完整的合并后的大富文本：所有demo全部拼到一个NSAttributedString
- (NSAttributedString *)buildCombinedFullAttributedText {
    AttributeStringBuilder *mainBuilder = AttributeStringBuilder.build(@"");
    
    // 常用字体/颜色
    UIFont *f14 = [UIFont systemFontOfSize:14];
    UIFont *f16 = [UIFont systemFontOfSize:16];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:19];
    UIColor *themeColor = [UIColor colorWithRed:0.24 green:0.36 blue:0.95 alpha:1.0];
    UIColor *sectionTitleColor = [UIColor blackColor];
    
    // 占位图
    UIImage *icon = [UIImage sf_defaultSymbolImageWithName:@"arrow.up.circle.fill" tintColor:themeColor pointSize:36];
    UIImage *smallIcon = [UIImage sf_defaultSymbolImageWithName:@"arrow.right" tintColor:[UIColor orangeColor] pointSize:18];
    
    // 辅助：追加章节标题
    void(^appendSectionTitle)(NSString *) = ^(NSString *title){
        mainBuilder.append(@"\n\n");
        mainBuilder.append(title).font(titleFont).color(sectionTitleColor);
        mainBuilder.append(@"\n");
    };
    
#pragma mark - 1. 基础内容与属性
    appendSectionTitle(@"1. 基础内容与属性（build/append/attributedAppend/font/fontSize/boldFontSize/color/hexColor/backgroundColor）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"基础文本");
        b.font(f14).color([UIColor darkGrayColor]);
        b.append(@" 蓝色16号").fontSize(16).color([UIColor blueColor]);
        b.append(@" 粗体").boldFontSize(16).color([UIColor purpleColor]);
        b.append(@" 16进制色").hexColor(0xFF4400);
        b.append(@" 高亮背景").font(f14).backgroundColor([UIColor yellowColor]);
        NSAttributedString *sub = AttributeStringBuilder.build(@" [追加的富文本]").font(f14).underlineStyle(NSUnderlineStyleSingle).underlineColor([UIColor greenColor]).commit;
        b.attributedAppend(sub);
        mainBuilder.attributedAppend([b commit]);
    }
    
#pragma mark - 2. 插入与 Range
    appendSectionTitle(@"2. 插入与 Range（insert/range/lastRange/all）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"abcdefghijk");
        b.insert(@"[插]", 2);
        b.range(0, 5).color([UIColor redColor]);
        b.lastRange(3, 2).fontSize(20);
        b.all.backgroundColor([UIColor colorWithWhite:0.95 alpha:1.0]);
        mainBuilder.attributedAppend([b commit]);
    }
    
    appendSectionTitle(@"2b. 匹配（match/matchFirst/matchLast/regular）");
    {
        AttributeStringBuilder *b2 = AttributeStringBuilder.build(@"链接A 链接B 链接C 数字123 数字456");
        b2.match(@"链接").hexColor(0xFF4400).underlineStyle(NSUnderlineStyleSingle).underlineColor([UIColor redColor]);
        b2.matchFirst(@"数字").backgroundColor([UIColor yellowColor]);
        b2.matchLast(@"数字").backgroundColor([UIColor cyanColor]);
        b2.regular(@"\\d+", YES).color([UIColor blueColor]);
        mainBuilder.attributedAppend([b2 commit]);
    }
    
    appendSectionTitle(@"2c. currentRange（当前范围，此处为 build 出的整串）");
    {
        AttributeStringBuilder *b3 = AttributeStringBuilder.build(@"abcdefg");
        NSRange current = [b3 currentRange];
        NSAttributedString *text = AttributeStringBuilder.build([NSString stringWithFormat:@"currentRange = {%lu, %lu}", (unsigned long)current.location, (unsigned long)current.length]).font(f14).commit;
        mainBuilder.attributedAppend(text);
    }
    
#pragma mark - 3. 图片附件
    appendSectionTitle(@"3. 图片附件（appendImage/appendSizeImage/appendFontImage/appendCustomImage）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"图片附件：");
        b.font(f16);
        b.appendImage(icon);
        b.append(@" 指定尺寸").font(f14);
        b.appendSizeImage(icon, CGSizeMake(28, 28));
        b.append(@" 按字体对齐").font(f14);
        b.appendFontImage(smallIcon, [UIFont systemFontOfSize:18]);
        b.append(@" 自定义+字体").font(f14);
        b.appendCustomImage(icon, CGSizeMake(24, 24), f14);
        mainBuilder.attributedAppend([b commit]);
    }
    
    appendSectionTitle(@"3b. 图片附件（insertImage/headInsertImage）");
    {
        AttributeStringBuilder *b2 = AttributeStringBuilder.build(@"行首插图 行尾插图");
        b2.font(f14);
        b2.match(@"行首").headInsertImage(smallIcon, CGSizeMake(18, 18), f14);
        b2.insertImage(smallIcon, CGSizeMake(18, 18), 0, f14);
        mainBuilder.attributedAppend([b2 commit]);
    }
    
    appendSectionTitle(@"3c. 图片附件（appendSpacing/appendAttachment）");
    {
        AttributeStringBuilder *b3 = AttributeStringBuilder.build(@"间隔");
        b3.font(f14);
        b3.appendSpacing(20);
        b3.append(@"后接文字").font(f14);
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = smallIcon;
        attachment.bounds = CGRectMake(0, -4, 16, 16);
        b3.append(@" 附件：").font(f14).appendAttachment(attachment);
        mainBuilder.attributedAppend([b3 commit]);
    }
    
#pragma mark - 4. 圆角文字标签（不生成图片）
    appendSectionTitle(@"4. 圆角文字标签（appendRoundedTag/tagFont/tagTextColor/tagBackgroundColor/tagCornerRadius/tagInsets）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"圆角标签：");
        b.font(f14);
        b.appendRoundedTag(@"默认标签");
        b.append(@" ").font(f14);
        b.appendRoundedTag(@"红色标签")
            .tagFont([UIFont boldSystemFontOfSize:14])
            .tagTextColor([UIColor whiteColor])
            .tagBackgroundColor([UIColor redColor])
            .tagCornerRadius(8)
            .tagInsets(UIEdgeInsetsMake(3, 6, 3, 6));
        b.append(@" ").font(f14);
        b.appendRoundedTag(@"描边标签")
            .tagBackgroundColor([UIColor blackColor])
            .tagTextColor([UIColor whiteColor])
            .tagCornerRadius(12)
            .tagInsets(UIEdgeInsetsMake(2, 10, 2, 10));
        mainBuilder.attributedAppend([b commit]);
    }
    
#pragma mark - 5. 圆角文字标签（生成图片）
    appendSectionTitle(@"5. 圆角文字标签‑生成图片（appendBackgroundColor 系列，共 7 种变体）");
    {
        UIFont *tagFont = [UIFont systemFontOfSize:13];
        UIColor *white = [UIColor whiteColor];
        UIColor *fill = themeColor;
        CGFloat r = 6;
        
        AttributeStringBuilder *b1 = AttributeStringBuilder.build(@"");
        b1.append(@"基础款").font(f14);
        b1.appendBackgroundColor(@"状态A", tagFont, white, fill, r, 0);
        b1.append(@" ").font(f14);
        b1.appendBackgroundColor(@"上偏移", tagFont, white, fill, r, -3);
        mainBuilder.attributedAppend([b1 commit]);
    }
    
    appendSectionTitle(@"5b. insets / margins / 固定尺寸");
    {
        UIFont *tagFont = [UIFont systemFontOfSize:13];
        UIColor *white = [UIColor whiteColor];
        UIColor *fill = themeColor;
        CGFloat r = 6;
        AttributeStringBuilder *b2 = AttributeStringBuilder.build(@"");
        b2.append(@"内边距款").font(f14);
        b2.appendBackgroundInsetsColor(@"内边距款", tagFont, white, fill, r,
                                       UIEdgeInsetsMake(4, 12, 4, 12), 0);
        mainBuilder.attributedAppend([b2 commit]);
    }
    
    appendSectionTitle(@"5c. 外边距");
    {
        UIFont *tagFont = [UIFont systemFontOfSize:13];
        UIColor *white = [UIColor whiteColor];
        UIColor *fill = themeColor;
        CGFloat r = 6;
        AttributeStringBuilder *b3 = AttributeStringBuilder.build(@"");
        b3.append(@"外边距款").font(f14);
        b3.appendBackgroundMarginsColor(@"外边距款", tagFont, white, fill, r,
                                        UIEdgeInsetsMake(2, 6, 2, 6),
                                        UIEdgeInsetsMake(2, 4, 2, 4), 0);
        mainBuilder.attributedAppend([b3 commit]);
    }
    
    appendSectionTitle(@"5d. 固定尺寸");
    {
        UIFont *tagFont = [UIFont systemFontOfSize:13];
        UIColor *white = [UIColor whiteColor];
        UIColor *fill = themeColor;
        CGFloat r = 6;
        AttributeStringBuilder *b4 = AttributeStringBuilder.build(@"");
        b4.append(@"固定尺寸款").font(f14);
        b4.appendBackgroundSize(@"OK", tagFont, white, fill, r,
                                CGSizeMake(48, 28), 0);
        mainBuilder.attributedAppend([b4 commit]);
    }
    
    appendSectionTitle(@"5e. 圆角方向");
    {
        UIFont *tagFont = [UIFont systemFontOfSize:13];
        UIColor *white = [UIColor whiteColor];
        UIColor *fill = themeColor;
        CGFloat r = 6;
        AttributeStringBuilder *b5 = AttributeStringBuilder.build(@"");
        b5.append(@"圆角方向款").font(f14);
        b5.appendBackgroundCornerColor(@"圆角方向 - 左上圆角", tagFont, white, fill, r,
                                       UIRectCornerTopLeft, 0);
        b5.append(@" ").font(f14);
        b5.appendBackgroundCornerColor(@"右侧圆角", tagFont, white, fill, r,
                                       UIRectCornerTopRight | UIRectCornerBottomRight, 0);
        mainBuilder.attributedAppend([b5 commit]);
    }
    
    appendSectionTitle(@"5f. 圆角方向 + 固定尺寸");
    {
        UIFont *tagFont = [UIFont systemFontOfSize:13];
        UIColor *white = [UIColor whiteColor];
        UIColor *fill = themeColor;
        CGFloat r = 6;
        AttributeStringBuilder *b6 = AttributeStringBuilder.build(@"");
        b6.append(@"方向+尺寸款").font(f14);
        b6.appendBackgroundCornerSize(@"6", tagFont, white, fill, r,
                                      UIRectCornerAllCorners, CGSizeMake(30, 30), 0);
        mainBuilder.attributedAppend([b6 commit]);
    }
    
    appendSectionTitle(@"5g. 完整参数（描边/线宽/内外边距）");
    {
        UIFont *tagFont = [UIFont systemFontOfSize:13];
        CGFloat r = 8;
        AttributeStringBuilder *b7 = AttributeStringBuilder.build(@"");
        b7.append(@"描边款").font(f14);
        b7.appendBackgroundRadiusColor(@"完整参数（描边/线宽/内外边距）", tagFont, [UIColor blueColor], [UIColor clearColor], r,
                                       UIRectCornerAllCorners, CGSizeMake(0, 0),
                                       UIEdgeInsetsMake(3, 10, 3, 10),
                                       UIEdgeInsetsZero,
                                       [UIColor blueColor], 1, 0);
        mainBuilder.attributedAppend([b7 commit]);
    }
    
#pragma mark - 6. 分割线
    appendSectionTitle(@"6. 分割线（appendDividerLine/dividerColor/dividerThickness，左右间距可配）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"");
        b.append(@"标题").font(f16);
        b.appendDividerLine(16, 16);
        b.append(@"正文第一行").font(f14);
        b.appendDividerLine(0, 0);
        b.dividerColor([UIColor lightGrayColor]).dividerThickness(1);
        b.append(@"正文第二行").font(f14);
        b.appendDividerLine(20, 60);
        b.dividerColor(themeColor).dividerThickness(2);
        b.append(@"正文第三行").font(f14);
        mainBuilder.attributedAppend([b commit]);
    }
    
#pragma mark - 7. Glyph 属性
    appendSectionTitle(@"7. Glyph 属性（strikethrough/underline/stroke/textEffect/shadow/link/linkUrlStr）");
    {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor grayColor];
        shadow.shadowOffset = CGSizeMake(1, 1);
        
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"删除线 ");
        b.font(f14).strikethroughStyle(NSUnderlineStyleSingle).strikethroughColor([UIColor redColor]);
        b.append(@"下划线 ").font(f14).underlineStyle(NSUnderlineStyleThick).underlineColor([UIColor greenColor]);
        b.append(@"中空字").font([UIFont boldSystemFontOfSize:18]).strokeColor([UIColor purpleColor]).strokeWidth(2);
        b.append(@"\n浮雕效果").font(f16).textEffect(NSTextEffectLetterpressStyle);
        b.append(@" 阴影").font(f16).shadow(shadow);
        b.append(@" 链接").font(f16).link([NSURL URLWithString:@"https://www.apple.com"]);
        b.append(@" 链接字符串").font(f16).linkUrlStr(@"https://www.apple.com");
        mainBuilder.attributedAppend([b commit]);
    }
    
#pragma mark - 8. 段落属性
    appendSectionTitle(@"8. 段落属性（lineSpacing/paragraphSpacing）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"第一行：行间距与段间距演示。\n第二行：这一段设置了 lineSpacing(6) 与 paragraphSpacing(12)。\n第三行：结束。");
        b.font(f14).lineSpacing(6).paragraphSpacing(12);
        mainBuilder.attributedAppend([b commit]);
    }
    
    appendSectionTitle(@"8b. alignCenter（自动扩展到完整段落）");
    {
        AttributeStringBuilder *b2 = AttributeStringBuilder.build(@"这段文字整体居中对齐。");
        b2.font(f14);
        [b2 alignCenter];
        mainBuilder.attributedAppend([b2 commit]);
    }
    
    appendSectionTitle(@"8c. alignRight");
    {
        AttributeStringBuilder *b3 = AttributeStringBuilder.build(@"这段文字整体右对齐。");
        b3.font(f14);
        [b3 alignRight];
        mainBuilder.attributedAppend([b3 commit]);
    }
    
    appendSectionTitle(@"8d. alignJustified（两端对齐）");
    {
        AttributeStringBuilder *b4 = AttributeStringBuilder.build(@"这段文字两端对齐，左右两端齐平。这是一段比较长的内容，用来撑满整行以便观察两端对齐的效果。");
        b4.font(f14);
        [b4 alignJustified];
        mainBuilder.attributedAppend([b4 commit]);
    }
    
    appendSectionTitle(@"8e. appendLeftRightLine（一行两段对齐，自动独占一行）");
    {
        AttributeStringBuilder *b5 = AttributeStringBuilder.build(@"");
        b5.appendLeftRightLine(@"商品名称", @"¥99.00", kDemoWidth, f14);
        b5.appendLeftRightLine(@"运费", @"包邮", kDemoWidth, f14);
        b5.appendLeftRightLine(@"实付款", @"¥99.00", kDemoWidth, [UIFont boldSystemFontOfSize:14]);
        mainBuilder.attributedAppend([b5 commit]);
    }
    
    appendSectionTitle(@"8f. alignLeftRight（手动 \\t，右段为文本+图片）");
    {
        AttributeStringBuilder *b6 = AttributeStringBuilder.build(@"");
        b6.append(@"金额：").font(f14);
        b6.append(@"\t");
        b6.appendSizeImage(smallIcon, CGSizeMake(18, 18)).append(@" ¥99.00").font(f14);
        b6.alignLeftRight(kDemoWidth);
        mainBuilder.attributedAppend([b6 commit]);
    }
    
    appendSectionTitle(@"8g. firstLineHeadIndentCharacters（首行缩进2字符）");
    {
        AttributeStringBuilder *b7 = AttributeStringBuilder.build(@"首行缩进两字符：这是一段设置了 firstLineHeadIndentCharacters 的文本，用来观察首行缩进效果。");
        b7.font(f14).firstLineHeadIndentCharacters(2, f14).lineSpacing(4);
        mainBuilder.attributedAppend([b7 commit]);
    }
    
    appendSectionTitle(@"8h. headIndent / tailIndent");
    {
        AttributeStringBuilder *b8 = AttributeStringBuilder.build(@"整体左缩进 + 右缩进。这段文字设置了 headIndent(20) 与 tailIndent(-20)，展示左右缩进后的排版。");
        b8.font(f14).headIndent(20).tailIndent(-20);
        mainBuilder.attributedAppend([b8 commit]);
    }
    
    appendSectionTitle(@"8i. lineHeight（固定行高）");
    {
        AttributeStringBuilder *b9 = AttributeStringBuilder.build(@"第一行\n第二行\n第三行");
        b9.font(f14).lineHeight(28);
        mainBuilder.attributedAppend([b9 commit]);
    }
    
#pragma mark - 9. 特殊属性
    appendSectionTitle(@"9. 特殊属性（baselineOffset/kern/obliqueness/expansion/ligature）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"上标");
        b.font(f14).baselineOffset(8).fontSize(10);
        b.append(@" 下标").font(f14).baselineOffset(-6).fontSize(10);
        b.append(@" 字间距").font(f14).kern(4);
        b.append(@" 倾斜").font(f14).obliqueness(0.3);
        b.append(@" 拉伸").font(f14).expansion(0.5);
        b.append(@" 压缩").font(f14).expansion(-0.3);
        b.append(@" 连字").font(f14).ligature(1);
        mainBuilder.attributedAppend([b commit]);
    }
    
    appendSectionTitle(@"9b. dynamicKern（对齐已追加的末尾文本宽度）");
    {
        UIFont *labelFont = [UIFont systemFontOfSize:14];
        AttributeStringBuilder *b2 = AttributeStringBuilder.build(@"");
        b2.append(@"道路名称：").font(labelFont);
        b2.append(@"\n").font(labelFont);
        b2.append(@"上报人").font(labelFont);
        b2.dynamicKern(@"道路名称", @"上报人", labelFont);
        mainBuilder.attributedAppend([b2 commit]);
    }
    
    appendSectionTitle(@"9c. appendDynamicKern（追加并对齐）");
    {
        UIFont *labelFont = [UIFont systemFontOfSize:14];
        AttributeStringBuilder *b3 = AttributeStringBuilder.build(@"");
        b3.append(@"道路名称：").font(labelFont);
        b3.append(@"\n").font(labelFont);
        b3.appendDynamicKern(@"道路名称：", @"上报人：", labelFont).font(labelFont);
        b3.append(@"\n").font(labelFont);
        b3.appendDynamicKern(@"道路名称：", @"审核意见：", labelFont).font(labelFont);
        mainBuilder.attributedAppend([b3 commit]);
    }
    
    appendSectionTitle(@"9d. appendDynamicFitKern（指定后缀长度）");
    {
        
        UIFont *labelFont = [UIFont systemFontOfSize:14];
        CGSize size = [self string:@"病害信息息" sizeWithFont:labelFont MaxSize:CGSizeMake(10000, 10000)];
        CGFloat padding = size.width;
        NSString *reasonStr = @"DCloud还提供了使用js编写服务器代码的uniCloud云引擎。所以只需掌握js，你可以开发web、Android、iOS、各家小程序以及服务器等全栈应用。";
        
        AttributeStringBuilder *b4 = AttributeStringBuilder.build(@"");
        b4.append(@"道路名称：").font(labelFont);
        b4.append(@"\n").font(labelFont);
        b4.appendDynamicFitKern(@"道路名称：", @"上报人：", labelFont, 2).font(labelFont);
        b4.append(@"\n").font(labelFont);
        b4.appendDynamicFitKern(@"道路名称：", @"审核意见：", labelFont, 1).font(labelFont);
        
        b4.append(@"\n").font(labelFont)
            .append([NSString stringWithFormat:@"位置信息：%@", reasonStr]).font(labelFont).color([UIColor redColor])
            .headIndent(padding).tailIndent(0).lineBreakMode(NSLineBreakByCharWrapping)
            .append(@"\n\n").font([UIFont systemFontOfSize:2])
            .append([NSString stringWithFormat:@"位置信息：%@", reasonStr]).font(labelFont).color([UIColor blackColor])
            .headIndentCharacters(5, labelFont).tailIndent(0).lineBreakMode(NSLineBreakByCharWrapping)
            .append(@"\n\n").font([UIFont systemFontOfSize:2])
        ;
        mainBuilder.attributedAppend([b4 commit]);
    }
    
#pragma mark - 10. 文本尺寸计算
    appendSectionTitle(@"10. calculateForAttributedString:withWidth:（文本尺寸计算）");
    {
        AttributeStringBuilder *b = AttributeStringBuilder.build(@"这是一段用于计算尺寸的文本，宽度 300pt。\n第二行用于观察换行后的高度变化。");
        b.font(f14).lineSpacing(6);
        NSAttributedString *attr = [b commit];
        CGSize size = [AttributeStringBuilder calculateForAttributedString:attr withWidth:300];
        NSAttributedString *result = AttributeStringBuilder.build([NSString stringWithFormat:@"宽度300pt时的尺寸：{%.0f, %.0f}", size.width, size.height])
            .font(f14).hexColor(0x333333).commit;
        mainBuilder.attributedAppend(result);
    }
    

    return [mainBuilder commit];
}

#pragma mark - 视图搭建

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"AttributeStringBuilder 全功能演示（单Label）";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    
    // 点击状态提示行
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.font = [UIFont boldSystemFontOfSize:13];
    statusLabel.textColor = [UIColor colorWithRed:0.24 green:0.36 blue:0.95 alpha:1.0];
    statusLabel.numberOfLines = 0;
    statusLabel.text = @"👉 点击下方「第11组」中的蓝色/红色文字或图标，观察这里的变化";
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusLabel.userInteractionEnabled = YES;
    [scrollView addSubview:statusLabel];
    self.scr_statusLabel = statusLabel;

    // 普通 UILabel 即可承载富文本点击（builder 一行启用，无需子类）
    UILabel *singleContentLabel = [[UILabel alloc] init];
    singleContentLabel.numberOfLines = 0;
    singleContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    singleContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:singleContentLabel];

    // 生成完整大富文本，全部塞到这一个label
    singleContentLabel.attributedText = [self buildCombinedFullAttributedText];

    // layout：label宽度固定kDemoWidth，上下左右边距，驱动scrollView contentSize
    [NSLayoutConstraint activateConstraints:@[
        [statusLabel.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:16],
        [statusLabel.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:16],
        [statusLabel.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-16],
        [statusLabel.widthAnchor constraintEqualToConstant:kDemoWidth],
        [singleContentLabel.topAnchor constraintEqualToAnchor:statusLabel.bottomAnchor constant:8],
        [singleContentLabel.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:16],
        [singleContentLabel.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-16],
        [singleContentLabel.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-16],
        [singleContentLabel.widthAnchor constraintEqualToConstant:kDemoWidth],
    ]];
}

#pragma mark - get labelSize
- (CGSize)string:(NSString *)str sizeWithFont:(UIFont *)font MaxSize:(CGSize)maxSize
{
    @autoreleasepool {
        CGSize resultSize;
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        CGRect rect = [str boundingRectWithSize:maxSize
                                        options:(NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading)
                                     attributes:attrs
                                        context:nil];
        resultSize = rect.size;
        resultSize = CGSizeMake(ceil(resultSize.width), ceil(resultSize.height));
        
        return resultSize;
    }
}


@end
