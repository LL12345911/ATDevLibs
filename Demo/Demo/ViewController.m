//
//  ViewController.m
//  Demo
//
//  Created by Mars on 2020/9/23.
//  Copyright © 2020 Mars. All rights reserved.
//

#import "ViewController.h"
#import "ATKitBaseLibs.h"

@interface ViewController ()

@property (nonatomic, strong) NSLock *lock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

//    _lock = [[NSLock alloc] init];
//    ATLockEXE00(_lock, ^{
//
//    });
//
//    ATLockEXE10(_lock, ^ATBlock{
//        return [self infoCallback];
//    });
    
    
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 300)];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    AttributeStringBuilder *build = AttributeStringBuilder.build(@"NSBackgroundColorAttributeName 圆角")
        //.append(@"背景颜色").font(AutoFont(15)).color([UIColor yellowColor])
        .
    appendBackgroundColor(@"背景颜色", [UIFont systemFontOfSize:34], [UIColor greenColor],[UIColor redColor],3, 0)
        .all.lineSpacing(3);
    
    label.attributedText = [build commit];
    
    
//    //判断 App是否开启定位权限
//    [[AuthorizationManager defaultManager] requestAuthorizationWithAuthorizationType:AuthorizationTypeMapWhenInUseOrMapAlways authorizedHandler:^{
//        NSLog(@" =================== ");
//        
//    } unAuthorizedHandler:^{

        //  NSLog(@"Not granted:%@", _authDataArray[indexPath.row]);
//        [NSObject at_showAlertViewWithTitle:@"提示" message:@"此功能,需要App访问你的位置！\n否则无法正常使用此功能！" confirmTitle:@"开启" cancelTitle:@"取消" confirmAction:^{
//            if (@available(iOS 10.0, *)) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
//
//                }];
//            } else {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//#pragma clang diagnostic pop
//            }
//
//        } cancelAction:^{
//        }];
//    }];
}

//- (ATBlock)infoCallback{
//    return ^{
//        [self callback:^{
//            NSLog(@"");
//            NSLog(@"");
//            NSLog(@"");
//            NSLog(@"");
//        }];
//    };
//}

- (void)callback:(void (^)(void))block{
    if (!block) {
        return;
    }
    block();
}


@end
