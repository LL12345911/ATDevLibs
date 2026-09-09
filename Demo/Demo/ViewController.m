//
//  ViewController.m
//  Demo
//
//  Created by Mars on 2024/7/12.
//

#import "ViewController.h"
#import "AttributeStringBuilder.h"
#import "ATPlaceholdTextView.h"
#import "ATDevLibs.h"
#import "AttributeStringBuilderAllFeaturesDemoViewController.h"


@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;


@end

@implementation ViewController


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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    
    
    
    // 测试1
    [self test1];
    
    
    UIButton *btn2 = [UIButton sf_buttonWithSymbol:@"arrow.right"
                                          forState:UIControlStateNormal
                                         pointSize:90
                                            weight:UIImageSymbolWeightSemibold
                                             scale:UIImageSymbolScaleMedium];
    
    btn2.frame = CGRectMake(100, 400, 100, 100);
    [btn2 addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
}

- (void)click {
    AttributeStringBuilderAllFeaturesDemoViewController *vx = [[AttributeStringBuilderAllFeaturesDemoViewController alloc] init];
    vx.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vx animated:YES completion:^{
        
    } ];
}


- (void)test1 {
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 300, 20)];
    [self.scrollView addSubview:label2];
    
    NSArray *tags2 = @[@"道路破损", @"井盖缺失", @"路灯不亮", @"违规停车", @"垃圾堆积"];
    AttributeStringBuilder *build2 = AttributeStringBuilder.build(@"");
    
    for (NSInteger i = 0; i < tags2.count; i++) {
        build2.appendRoundedTag(tags2[i])
            .tagFont(AutoFont(12))
            .tagTextColor(RGBCOLOR(0x333333))
            .tagBackgroundColor(RGBCOLOR(0xF0F0F0))
            .tagCornerRadius(4)
            .tagInsets(UIEdgeInsetsMake(3, 8, 3, 8));
        
        // 标签之间加间距（不是空格，是固定宽度的 attachment）
        if (i < tags2.count - 1) {
            build2.appendSpacing(6);
        }
    }
    label2.attributedText = [build2 commit];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 700)];
    label.numberOfLines = 0;
    // 必须显式设为 WordWrapping/CharWrapping；默认 TruncatingTail 会导致多标签行被截断而非换行
    //      label.lineBreakMode = NSLineBreakByWordWrapping;
    [self.scrollView addSubview:label];
    
    
    
    CGSize size = [self string:@"病害信息息" sizeWithFont:AutoFont(12) MaxSize:CGSizeMake(10000, 10000)];
    CGFloat padding = size.width;
    
    
    AttributeStringBuilder *build = AttributeStringBuilder.build(@"NSBackgroundColorAttributeName 圆角")
        .append(@"\n").font([UIFont systemFontOfSize:14])
        .append(@"道路路路名名称：").font([UIFont systemFontOfSize:14])
        .append(@"\n").font([UIFont systemFontOfSize:14])
        .append(@"上报人").font([UIFont systemFontOfSize:14]).dynamicKern(@"道路路路名名称", @"上报人", [UIFont systemFontOfSize:14])
        .append(@"\n").font([UIFont systemFontOfSize:14])
        .appendDynamicKern(@"道路路路名名称：", @"上报人：", [UIFont systemFontOfSize:14]).font([UIFont systemFontOfSize:14])
        .append(@"\n").font([UIFont systemFontOfSize:14])
        .appendDynamicFitKern(@"道路路路名名称", @"发报人", [UIFont systemFontOfSize:14], 1).font([UIFont systemFontOfSize:14])
        .append(@"\n").font([UIFont systemFontOfSize:14])
    //.append(@"背景颜色").font(AutoFont(15)).color([UIColor yellowColor])
        .appendBackgroundColor(@"背景颜色", [UIFont systemFontOfSize:34], [UIColor greenColor],[UIColor redColor],3, 0)
        .all.lineSpacing(3).append(@"\n").font([UIFont systemFontOfSize:14])
    
        .append(@"\n")
        .append(@"\n") .append(@"\n")
    
    ;
    
    NSArray *tags = @[@"道路破损", @"井盖缺失", @"路灯不亮", @"违规停车", @"垃圾堆积"];
    
    for (NSInteger i = 0; i < tags.count; i++) {
        build.appendRoundedTag(tags[i])
            .tagFont(AutoFont(12))
            .tagTextColor(RGBCOLOR(0x333333))
            .tagBackgroundColor(RGBCOLOR(0xF0F0F0))
            .tagCornerRadius(4)
            .tagInsets(UIEdgeInsetsMake(13, 8, 13, 8));
        
        // 标签之间加间距（不是空格，是固定宽度的 attachment）
        if (i < tags.count - 1) {
            build.appendSpacing(6);
        }
    }
    
    build.append(@"\n");
    NSString *reasonStr = @"DCloud还提供了使用js编写服务器代码的uniCloud云引擎。所以只需掌握js，你可以开发web、Android、iOS、各家小程序以及服务器等全栈应用。";
    //    build.append(@"\n成因分析：\n").font(AutoBlodFont(15))
    //        .append(reasonStr).color(RGBCOLOR(0x999999)).lineSpacing(Inch(3)).firstLineHeadIndent(Inch(12)*2).font(AutoFont(12)).lineBreakMode(NSLineBreakByCharWrapping)
    //        .append(@"\n\n处置建议：").font(AutoBlodFont(15))
    //    ;
    
    build.append([NSString stringWithFormat:@"位置信息：%@", reasonStr]).font(AutoFont(12)).color([UIColor redColor])
        .headIndent(padding).tailIndent(0).lineBreakMode(NSLineBreakByCharWrapping)
        .append(@"\n\n").font([UIFont systemFontOfSize:2])
        .append([NSString stringWithFormat:@"位置信息：%@", reasonStr]).font(AutoFont(12)).color([UIColor blackColor])
        .headIndentCharacters(5, AutoFont(12)).tailIndent(0).lineBreakMode(NSLineBreakByCharWrapping)
        .append(@"\n\n").font([UIFont systemFontOfSize:2])
    ;
    
    build.appendBackgroundMarginsColor(@"位置信息", AutoFont(12), RGBCOLOR(0xFF5C00), RGBCOLOR(0x000000), 3, UIEdgeInsetsMake(10, 10, 10, 10),UIEdgeInsetsMake(10, 0, 10, 0), 0);
    
    
    label.attributedText = [build commit];
    
    
    
    //    ATPlaceholdTextView *_textView = [[ATPlaceholdTextView alloc] initWithFrame:CGRectMake(10, 600, 300, 200)];
    //    _textView.font = [UIFont systemFontOfSize:14];
    //    _textView.placehold = @"描述病害情况...";
    //    _textView.layer.borderWidth = 1;
    //    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    //    _textView.layer.cornerRadius = 5;
    //    [self.scrollView addSubview:_textView];
    //
    //
    //    UIButton *btn = [UIButton sf_buttonWithSymbol:@"arrow.up.circle.fill"
    //                                                          forState:UIControlStateNormal
    //                                                         tintColor:UIColor.redColor];
    //    btn.frame = CGRectMake(10, 400, 100, 100);
    //    btn.sf_pointSize = Inch(60);
    //    [btn sf_reloadAllSymbols];
    //    [self.scrollView addSubview:btn];
    
    
    //    NSDictionary *symbolMap = @{
    //        @(UIControlStateNormal): @"moon",
    //        @(UIControlStateSelected): @{
    //            SFSymbolConfigKeyName: @"sun.max.fill",
    //            SFSymbolConfigKeyTintColor: UIColor.systemYellowColor,
    //            SFSymbolConfigKeyWeight: @(UIImageSymbolWeightBold),
    //            SFSymbolConfigKeyScale:  @(UIImageSymbolScaleLarge)
    //        }
    //    };
    //    UIButton *btn2 = [UIButton sf_buttonWithSymbols:symbolMap
    //                                         pointSize:80.0
    //                                            weight:UIImageSymbolWeightMedium
    //                                             scale:UIImageSymbolScaleMedium
    //                                  defaultTintColor:UIColor.yellowColor];
    //    btn2.frame = CGRectMake(10, 500, 100, 100);
    //    [self.view addSubview:btn2];
    
    
    //    UIButton *btn2 = [UIButton sf_buttonWithSymbols:@{
    //        @(UIControlStateNormal): @"moon",
    //        @(UIControlStateNormal): @{
    //            SFSymbolConfigKeyName: @"sun.max.fill",
    //            SFSymbolConfigKeyTintColor: UIColor.redColor,
    //            SFSymbolConfigKeyWeight: @(UIImageSymbolWeightBold),
    //            SFSymbolConfigKeyScale:  @(UIImageSymbolScaleLarge)
    //        }
    //    } pointSize:80.0 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
    
    //    UIButton *btn2 = [UIButton sf_buttonWithSymbol:@"trash.fill"
    //                                         forState:UIControlStateNormal
    //                                        pointSize:80
    //                                           weight:UIImageSymbolWeightSemibold
    //                                            scale:UIImageSymbolScaleMedium
    //                                        tintColor:UIColor.yellowColor];
    
    //    UIButton *btn2 = [UIButton sf_buttonWithSymbol:@"arrow.right"
    //                                         forState:UIControlStateNormal
    //                                        pointSize:90
    //                                           weight:UIImageSymbolWeightSemibold
    //                                            scale:UIImageSymbolScaleMedium];
    //
    //    btn2.frame = CGRectMake(100, 400, 100, 100);
    //    [self.scrollView addSubview:btn2];
}

- (void)test3 {
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
    
}

@end
