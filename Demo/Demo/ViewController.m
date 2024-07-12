//
//  ViewController.m
//  Demo
//
//  Created by Mars on 2024/7/12.
//

#import "ViewController.h"
#import "AttributeStringBuilder.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 300)];
      label.numberOfLines = 0;
      [self.view addSubview:label];
      
      
      
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
          .all.lineSpacing(3);
      
      label.attributedText = [build commit];
      

}


@end
