//
//  UIViewController+Util.m
//  ATC
//
//  Created by Mars on 2018/4/23.
//  Copyright © 2018年 AirCnC车去车来. All rights reserved.
//
//

#import "UIViewController+Util.h"
#import "UIBarButtonItem+SXCreate.h"
#import "UINavigationBar+NavBar.h"

#import <objc/runtime.h>

    //定义常量 必须是C语言字符串
static char *IndicatorBackViewKey = "IndicatorBackViewKey";
static char *LeftBarButtonClickBlockKey = "LeftBarButtonClickBlockKey";
//static char *FullScreenAllowRotationKey = "FullScreenAllowRotationKey";

@implementation UIViewController (Util)

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector){
        // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
        // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
        // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

///**
// 是否允许横屏
//
// @return bool YES 允许 NO 不允许
// */
//- (BOOL)shouldAutorotate1{
//    BOOL flag = objc_getAssociatedObject(self, FullScreenAllowRotationKey);
//    return flag;
//}
//
//
///**
// 屏幕方向
//
// @return 屏幕方向
// */
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations1{
//    //get方法通过key获取对象
//    BOOL flag = objc_getAssociatedObject(self, FullScreenAllowRotationKey);
//    if (flag) {
//        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//    }else{
//        return UIInterfaceOrientationMaskPortrait;
//    }
//}
//
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation1{
//    BOOL flag = objc_getAssociatedObject(self, FullScreenAllowRotationKey);
//    if (flag) {
//        return UIInterfaceOrientationPortraitUpsideDown;
//    }else{
//        return UIInterfaceOrientationPortrait;
//    }
//}

///**
// 强制横屏方法
//
// @param fullscreen 屏幕方向
// */
//- (void)setNewOrientation:(BOOL)fullscreen{
//    AtAppDelegate.allowRotation = fullscreen;
//     objc_setAssociatedObject(self, FullScreenAllowRotationKey,[NSNumber numberWithBool:fullscreen], OBJC_ASSOCIATION_ASSIGN);
//
//    swizzleMethod([self class], @selector(shouldAutorotate), @selector(shouldAutorotate1));
//    swizzleMethod([self class], @selector(supportedInterfaceOrientations), @selector(supportedInterfaceOrientations1));
//    swizzleMethod([self class], @selector(preferredInterfaceOrientationForPresentation), @selector(preferredInterfaceOrientationForPresentation1));
//
//    @autoreleasepool {
//        if (fullscreen) {
//            NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//            [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
//            NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//        }else{
//            NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//            [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
//            NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//        }
//    }
//}

#pragma mark -
#pragma mark - 导航栏 加载动画
/**
 设置 导航栏左侧 按钮的图片
 @param imageName 图片名
 */
- (void)at_leftNavigationBar:(NSString *)imageName{
    @autoreleasepool {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(leftBarButtonItemClick) image:[UIImage imageNamed:imageName.length ==0 ? @"navback" : imageName]];
    }
}

- (void)setLeftBarButtonClickBlock:(LeftBarButtonItemBlock)leftBarButtonClickBlock{
    objc_setAssociatedObject(self, LeftBarButtonClickBlockKey, leftBarButtonClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LeftBarButtonItemBlock)leftBarButtonClickBlock{
    return objc_getAssociatedObject(self, LeftBarButtonClickBlockKey);
}

- (void)leftBarButtonItemClick{
    if (self.leftBarButtonClickBlock) {
        self.leftBarButtonClickBlock();
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)setIndicatorBack:(UIView *)indicatorBack{
    objc_setAssociatedObject(self, IndicatorBackViewKey, indicatorBack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)indicatorBack{
    return objc_getAssociatedObject(self, IndicatorBackViewKey);
}

/// 加载进度
- (void)startIndicatorLoading{
    @autoreleasepool {
        [self startIndicatorLoadingWithAlpha:0.6];
    }
}
/// 加载进度
/// @param alpha 透明度 0-1（值范围）
- (void)startIndicatorLoadingWithAlpha:(CGFloat)alpha{
    @autoreleasepool {
        // UIWindow *window = [UIApplication sharedApplication].keyWindow;
        // UIWindow *window = UIApplication.sharedApplication.delegate.window;
        // window.windowLevel = UIWindowLevelAlert;
        CGFloat height = self.view.frame.size.height;
        CGFloat width = self.view.frame.size.width;
        if (self.indicatorBack) {
            [self.indicatorBack removeFromSuperview];
            self.indicatorBack.frame = CGRectMake(0, height, width, height);
        }
        self.indicatorBack = [[UIView alloc] init];
        self.indicatorBack.frame = CGRectMake(0, 0, width, height);
        self.indicatorBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
        [self.view addSubview:self.indicatorBack];
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //设置显示位置
        indicator.center = CGPointMake(width/2.0, height/2.0);
        indicator.hidesWhenStopped = NO;
        // indicator.color = [UIColor orangeColor];
        //     //    _indicator.color = [UIColor whiteColor];
        [self.indicatorBack addSubview:indicator];
        [indicator startAnimating];
    }
}


/// 全屏加载进度
- (void)startLoadingFullScreen{
    @autoreleasepool {
        [self startLoadingFullScreenWithAlpha:0.6];
    }
}

/// 全屏加载进度
/// @param alpha 透明度 0-1（值范围）
- (void)startLoadingFullScreenWithAlpha:(CGFloat)alpha{
    @autoreleasepool {
        [self.indicatorBack removeFromSuperview];
        
        // UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        //    window.windowLevel = UIWindowLevelAlert;
        CGFloat height = self.view.frame.size.height;
        CGFloat width = self.view.frame.size.width;
        if (self.indicatorBack) {
            [self.indicatorBack removeFromSuperview];
            self.indicatorBack.frame = CGRectMake(0, height, width, height);
        }
        
        self.indicatorBack = [[UIView alloc] init];
        self.indicatorBack.frame = CGRectMake(0, 0, width, height);
        self.indicatorBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
        [window addSubview:self.indicatorBack];
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //设置显示位置
        indicator.center = CGPointMake(width/2.0, height/2.0);
        indicator.hidesWhenStopped = NO;
        // indicator.color = [UIColor orangeColor];
        //     //    _indicator.color = [UIColor whiteColor];
        [self.indicatorBack addSubview:indicator];
        [indicator startAnimating];
    }
}

- (void)stopIndicatorLoading{
    __block typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.indicatorBack removeFromSuperview];
        CGFloat height = self.view.frame.size.height;
        CGFloat width = self.view.frame.size.width;
        weakSelf.indicatorBack.frame = CGRectMake(0, height, width, height);
        //[weakSelf.indicator removeAllSubviews];
        
    });
}

- (void)stopIndicatorLoading:(float)time{
    __block typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.indicatorBack removeFromSuperview];
        
        CGFloat height = self.view.frame.size.height;
        CGFloat width = self.view.frame.size.width;
        weakSelf.indicatorBack.frame = CGRectMake(0, height, width, height);
        //[weakSelf.indicator removeAllSubviews];
        
    });
}



- (void)at_navigationBarBackImage:(NSString *)imageName{
    [self.navigationController.navigationBar at_setBackgroundCustomImage:imageName.length > 0 ? imageName : @"navImage"];
}

- (void)at_navigationBarBackColor:(UIColor *)backColor{
    [self.navigationController.navigationBar at_setBackgroundCustomColor:backColor ? backColor:[UIColor clearColor]];
}

- (void)at_navigationBarClearColor{
    [self.navigationController.navigationBar at_setBackgroundCustomColor:[UIColor clearColor]];
}

- (void)at_navigationBarTitleColor:(UIColor *)titleColor{
    [self.navigationController.navigationBar at_setTitleTextAttribute:titleColor ? titleColor : [UIColor whiteColor]];
}

//
//- (UIWindow *)getKeyWindow{
//    UIWindow* window = nil;
//    if (@available(iOS 13.0, *)){
//        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes){
//            if (windowScene.activationState == UISceneActivationStateForegroundActive){
//                window = windowScene.windows.firstObject;
//                
//                break;
//            }
//        }
//    }else {
//        window = [UIApplication sharedApplication].keyWindow;
//    }
//    return window;
//}


///// 获取当前控制器
//- (UIViewController *)currentController {
//    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
//    while (1) {
//        if ([vc isKindOfClass:[UITabBarController class]]) {
//            vc = ((UITabBarController*)vc).selectedViewController;
//        }
//        if ([vc isKindOfClass:[UINavigationController class]]) {
//            vc = ((UINavigationController*)vc).visibleViewController;
//        }
//        if (vc.presentedViewController) {
//            vc = vc.presentedViewController;
//        }else{
//            break;
//        }
//    }
//    return vc;
//}


@end

