//
//  ViewController.m
//  Demo
//
//  Created by Mars on 2024/7/12.
//

#import "ViewController.h"
#import "AttributeStringBuilder.h"
#import "ATPlaceholdTextView.h"


@interface ViewController ()

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 600)];
      label.numberOfLines = 0;
      [self.view addSubview:label];
      
      
    
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
      
      
          //.append(@"背景颜色").font(AutoFont(15)).color([UIColor yellowColor])
          .
      appendBackgroundColor(@"背景颜色", [UIFont systemFontOfSize:34], [UIColor greenColor],[UIColor redColor],3, 0)
          .all.lineSpacing(3).append(@"\n").font([UIFont systemFontOfSize:14]);
    
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
    
    
      
      label.attributedText = [build commit];
      
    
    
    ATPlaceholdTextView *_textView = [[ATPlaceholdTextView alloc] initWithFrame:CGRectMake(10, 600, 300, 200)];
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.placehold = @"描述病害情况...";
    _textView.layer.borderWidth = 1;
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.layer.cornerRadius = 5;
    [self.view addSubview:_textView];


}


@end
