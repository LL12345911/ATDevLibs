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
#import "WindowsManager.h"
#import <objc/runtime.h>


#pragma mark - 关联对象 Key
    //定义常量 必须是C语言字符串
static char *IndicatorBackViewKey = "IndicatorBackViewKey";
static char *LeftBarButtonClickBlockKey = "LeftBarButtonClickBlockKey";
//static char *FullScreenAllowRotationKey = "FullScreenAllowRotationKey";
static char *ProgressViewKey = "ProgressViewKey";
static char *ProgressLabelKey = "ProgressLabelKey";
static char *LoadingIndicatorKey = "LoadingIndicatorKey";


@implementation UIViewController (Util)

#pragma mark - 方法交换工具
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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleMethod(self, @selector(viewWillLayoutSubviews), @selector(aty_viewWillLayoutSubviews));
    });
}

- (void)aty_viewWillLayoutSubviews {
    [self aty_viewWillLayoutSubviews];
    [self updateLoadingViewFrames];
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


#pragma mark - 私有属性关联
- (void)setIndicatorBack:(UIView *)indicatorBack {
    objc_setAssociatedObject(self, IndicatorBackViewKey, indicatorBack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)indicatorBack {
    return objc_getAssociatedObject(self, IndicatorBackViewKey);
}

- (UIProgressView *)progressView {
    return objc_getAssociatedObject(self, ProgressViewKey);
}

- (void)setProgressView:(UIProgressView *)progressView {
    objc_setAssociatedObject(self, ProgressViewKey, progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)progressLabel {
    return objc_getAssociatedObject(self, ProgressLabelKey);
}

- (void)setProgressLabel:(UILabel *)progressLabel {
    objc_setAssociatedObject(self, ProgressLabelKey, progressLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)loadingIndicator {
    return objc_getAssociatedObject(self, LoadingIndicatorKey);
}

- (void)setLoadingIndicator:(UIActivityIndicatorView *)loadingIndicator {
    objc_setAssociatedObject(self, LoadingIndicatorKey, loadingIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



#pragma mark - 页面布局变化时，自动刷新加载框位置

- (void)updateLoadingViewFrames {
    if (!self.indicatorBack) return;
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    // 背景铺满
    self.indicatorBack.frame = self.view.bounds;
    
    // 菊花居中
    self.loadingIndicator.center = CGPointMake(width * 0.5, height * 0.5 - 30);
    
    // 进度条居中
    self.progressView.frame = CGRectMake(width * 0.5 - 70, height * 0.5 + 10, 140, 3);
    
    // 文本居中
    self.progressLabel.frame = CGRectMake(width * 0.5 - 90, height * 0.5 + 20, 180, 30);
}


#pragma mark - 普通加载（默认只显示菊花）
/// 加载进度
- (void)startIndicatorLoading{
        [self startIndicatorLoadingWithAlpha:0.6];
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
        
        // 移除旧视图
        if (self.indicatorBack) {
            [self.indicatorBack removeFromSuperview];
            self.indicatorBack = nil;
            self.progressView = nil;
            self.progressLabel = nil;
            self.loadingIndicator = nil;
        }
        
        // 背景遮罩
        self.indicatorBack = [[UIView alloc] init];
        self.indicatorBack.frame = self.view.bounds;
        self.indicatorBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
        [self.view addSubview:self.indicatorBack];
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //设置显示位置
        indicator.center = CGPointMake(width/2.0, height/2.0 - 30);
        indicator.hidesWhenStopped = NO;
        // indicator.color = [UIColor orangeColor];
        //     //    _indicator.color = [UIColor whiteColor];
        [self.indicatorBack addSubview:indicator];
        [indicator startAnimating];
        self.loadingIndicator = indicator;
        
        // 进度条（直接添加，默认隐藏）
        UIProgressView *progressView = [[UIProgressView alloc] init];
        progressView.frame = CGRectMake(width * 0.5 - 70, height * 0.5 + 10, 140, 3);
        progressView.tintColor = UIColor.whiteColor;
        progressView.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        progressView.progress = 0;
        progressView.hidden = YES;
        [self.indicatorBack addSubview:progressView];
        self.progressView = progressView;
        
        // 文字（直接添加，默认隐藏）
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width * 0.5 - 90, height * 0.5 + 20, 180, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"加载中... 0%";
        label.hidden = YES;
        [self.indicatorBack addSubview:label];
        self.progressLabel = label;
    }
}


/// 全屏加载进度
- (void)startLoadingFullScreen{
        [self startLoadingFullScreenWithAlpha:0.6];
}

/// 全屏加载进度
/// @param alpha 透明度 0-1（值范围）
- (void)startLoadingFullScreenWithAlpha:(CGFloat)alpha{
    @autoreleasepool {
        [self.indicatorBack removeFromSuperview];
        
        // UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIWindow *window = [WindowsManager keyWindow];
        //    window.windowLevel = UIWindowLevelAlert;
        CGFloat height = self.view.frame.size.height;
        CGFloat width = self.view.frame.size.width;
        if (self.indicatorBack) {
            [self.indicatorBack removeFromSuperview];
            self.indicatorBack = nil;
            self.progressView = nil;
            self.progressLabel = nil;
            self.loadingIndicator = nil;

        }
        
        self.indicatorBack = [[UIView alloc] init];
        self.indicatorBack.frame = self.view.bounds;
        self.indicatorBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
        [window addSubview:self.indicatorBack];
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //设置显示位置
        indicator.center = CGPointMake(width/2.0, height/2.0-30);
        indicator.hidesWhenStopped = NO;
        // indicator.color = [UIColor orangeColor];
        //     //    _indicator.color = [UIColor whiteColor];
        [self.indicatorBack addSubview:indicator];
        [indicator startAnimating];
        self.loadingIndicator = indicator;
        
        // 进度条
        UIProgressView *progressView = [[UIProgressView alloc] init];
        progressView.frame = CGRectMake(width * 0.5 - 70, height * 0.5 + 10, 140, 3);
        progressView.tintColor = UIColor.whiteColor;
        progressView.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        progressView.progress = 0;
        progressView.hidden = YES;
        [self.indicatorBack addSubview:progressView];
        self.progressView = progressView;
        
        // 文本
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width * 0.5 - 90, height * 0.5 + 20, 180, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"加载中... 0%";
        label.hidden = YES;
        [self.indicatorBack addSubview:label];
        self.progressLabel = label;
    }
}

//- (void)stopIndicatorLoading{
//    __block typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weakSelf.indicatorBack removeFromSuperview];
//        CGFloat height = self.view.frame.size.height;
//        CGFloat width = self.view.frame.size.width;
//        weakSelf.indicatorBack.frame = CGRectMake(0, height, width, height);
//        //[weakSelf.indicator removeAllSubviews];
//        
//    });
//}

//- (void)stopIndicatorLoading:(float)time{
//    __block typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weakSelf.indicatorBack removeFromSuperview];
//        
//        CGFloat height = self.view.frame.size.height;
//        CGFloat width = self.view.frame.size.width;
//        weakSelf.indicatorBack.frame = CGRectMake(0, height, width, height);
//        //[weakSelf.indicator removeAllSubviews];
//        
//    });
//}


#pragma mark - 显示进度条 + 文本
- (void)showProgressAndLabel {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = NO;
        self.progressLabel.hidden = NO;
    });
}

#pragma mark - 更新进度
- (void)updateLoadingProgress:(CGFloat)progress {
    if (!self.progressView) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
        int p = (int)(progress * 100);
        self.progressLabel.text = [NSString stringWithFormat:@"加载中... %d%%", p];
    });
}

#pragma mark - 更新文本
- (void)updateLoadingText:(NSString *)text {
    if (!self.progressLabel) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.text = text;
    });
}

#pragma mark - 停止加载
- (void)stopIndicatorLoading {
    [self stopIndicatorLoading:0];
}

- (void)stopIndicatorLoading:(float)time {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.indicatorBack removeFromSuperview];
        weakSelf.indicatorBack = nil;
        weakSelf.progressView = nil;
        weakSelf.progressLabel = nil;
        weakSelf.loadingIndicator = nil;
    });
}

//
//- (void)at_navigationBarBackImage:(NSString *)imageName{
//    [self.navigationController.navigationBar at_setBackgroundCustomImage:imageName.length > 0 ? imageName : @"navImage"];
//}
//
//- (void)at_navigationBarBackColor:(UIColor *)backColor{
//    [self.navigationController.navigationBar at_setBackgroundCustomColor:backColor ? backColor:[UIColor clearColor]];
//}
//
//- (void)at_navigationBarClearColor{
//    [self.navigationController.navigationBar at_setBackgroundCustomColor:[UIColor clearColor]];
//}
//
//- (void)at_navigationBarTitleColor:(UIColor *)titleColor{
//    [self.navigationController.navigationBar at_setTitleTextAttribute:titleColor ? titleColor : [UIColor whiteColor]];
//}

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

