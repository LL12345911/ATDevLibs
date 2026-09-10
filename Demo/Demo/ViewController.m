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
    
    ATButton *btn = [[ATButton alloc] init];
    [btn setTitle:@"收藏" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemGreenColor] forState:UIControlStateSelected];
    [btn setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    [btn setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateSelected];
    [btn setBackgroundImage:[UIImage systemImageNamed:@"rectangle.rounded"] forState:UIControlStateNormal];
    
    btn.imagePosition = ATButtonImagePositionTop;
    btn.spacing = 6;
    btn.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.cornerRadius = 10;
    btn.backgroundColor = [UIColor systemGray6Color];
    
    [btn sizeToFit];
    btn.center = CGPointMake(200, 300);
    [btn addTarget:self action:@selector(toggleStar:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    [UIButton buttonWithType:0];
    
    // 配置 A：numberOfLines = 0（多行，不限行数）
    ATButton *btnA = [[ATButton alloc] init];
    btnA.titleLabel.numberOfLines = 0;
    [btnA setTitle:@"第一行\n第二行\n第三行\n第四行" forState:UIControlStateNormal];
    [btnA setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    btnA.imagePosition = ATButtonImagePositionTop;
    btnA.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
    
    CGSize fitA = [btnA sizeThatFits:CGSizeMake(120, CGFLOAT_MAX)];
    // 预期：宽度 = 120（受限），高度 = 4 行完整高度（约 4 × 行高 + 上下内边距），不截断
    btnA.frame = CGRectMake(20, 100, fitA.width, fitA.height);
    [self.view addSubview:btnA];
    
    // 配置 B：numberOfLines = 2（最多两行）
    ATButton *btnB = [[ATButton alloc] init];
    btnB.titleLabel.numberOfLines = 2;
    btnB.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;   // 第二行末尾省略号
    [btnB setTitle:@"第一行\n第二行\n第三行\n第四行" forState:UIControlStateNormal];
    
    CGSize fitB = [btnB sizeThatFits:CGSizeMake(120, CGFLOAT_MAX)];
    // 预期：宽度 = 120，高度 = 2 行高度（第 3、4 行截断，末尾显示"…"）
    btnB.frame = CGRectMake(200, 220, fitB.width, fitB.height);
    [self.view addSubview:btnB];
    
    
    // 对齐：按钮尺寸必须大于内容才有空间
    ATButton *alignBtn = [[ATButton alloc] initWithFrame:CGRectMake(20, 200, 200, 60)];
    [alignBtn setTitle:@"收藏" forState:UIControlStateNormal];
    [alignBtn setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    alignBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    alignBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 20);

    alignBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    alignBtn.contentVerticalAlignment   = UIControlContentVerticalAlignmentTop;

    alignBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:alignBtn];

}

- (void)toggleStar:(ATButton *)sender {
    sender.selected = !sender.selected;
    
    // 读取 API，与 UIButton 完全一致
    NSLog(@"标题: %@", sender.currentTitle);            // "收藏"
    NSLog(@"标题色: %@", sender.currentTitleColor);
    NSLog(@"图片: %@", sender.currentImage);
    NSLog(@"背景图: %@", sender.currentBackgroundImage);
    NSLog(@"富文本: %@", sender.currentAttributedTitle);
    
    // titleLabel / imageView 直接操作，改完自动刷新布局
    sender.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    sender.titleLabel.shadowColor = [UIColor grayColor];
    sender.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
    
    
}

@end
