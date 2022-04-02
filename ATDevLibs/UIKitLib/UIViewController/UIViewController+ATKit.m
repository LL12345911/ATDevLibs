//
//  UIViewController+ATKit.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIViewController+ATKit.h"

@implementation UIViewController (ATKit)

- (NSString *)emptyStr:(NSString *)str {
    if(([str isKindOfClass:[NSNull class]]) || ([str isEqual:[NSNull null]]) || (str == nil) || (!str)) {
        str = @"";
    }
    return str;
}


- (UIViewController *)findViewController:(NSString *)className {
    if([self emptyStr:className].length <= 0) return nil;
    Class class = NSClassFromString(className);
    if (class == nil) return nil;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if([controller isKindOfClass:class]) {
            return controller;
        }
    }
    return nil;
}

- (void)deleteViewController:(NSString *)className complete:(void (^)(void))complete {
    if([self emptyStr:className].length <= 0) return;
    Class class = NSClassFromString(className);
    if (class == nil) return;
    __kindof NSMutableArray<UIViewController *> *controllers = [self.navigationController.viewControllers mutableCopy];
    for (UIViewController *vc in controllers) {
        if ([vc isKindOfClass:class]) {
            [controllers removeObject:vc];
            self.navigationController.viewControllers = [controllers copy];
            if(complete) {
                complete();
            }
            return;
        }
    }
}

- (void)pushViewClassController:(NSString *)className animated:(BOOL)animated {
    if([self emptyStr:className].length <= 0) return;
    Class class = NSClassFromString(className);
    if (class == nil) return;
    UIViewController *viewController = [[class alloc]init];
    if(viewController == nil) return;
    [self.navigationController pushViewController:viewController animated:animated];
}

/// 跳转到指定的视图控制器 隐藏底部把导航栏
/// @param className 控制器
/// @param animated y动画
- (void)pushViewControllerHideBottom:(NSString *)className animated:(BOOL)animated{
    if([self emptyStr:className].length <= 0) return;
    Class class = NSClassFromString(className);
    if (class == nil) return;
    UIViewController *viewController = [[class alloc]init];
    if(viewController == nil) return;
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:animated];
}



- (void)preventCirculationPushViewController:(NSString *)className animated:(BOOL)animated {
    if([self emptyStr:className].length <= 0) return;
    Class class = NSClassFromString(className);
    if (class == nil) return;
    __weak typeof(self) weakSelf = self;
    [self deleteViewController:className complete:^{
        UIViewController *viewController = [[class alloc]init];
        if(viewController == nil) return;
        [weakSelf.navigationController pushViewController:viewController animated:animated];
    }];
}

- (void)popViewController:(NSString *)className animated:(BOOL)animated {
    if([self emptyStr:className].length <= 0) return;
    Class class = NSClassFromString(className);
    if (class == nil) return;
    __kindof NSArray<UIViewController *> *controllers = self.navigationController.viewControllers;
    for (UIViewController *vc in controllers) {
        if ([vc isKindOfClass:class]) {
            [self.navigationController popToViewController:vc animated:animated];
            return;
        }
    }
}





- (void)pushViewControllerByAnimated:(UIViewController *)view{
    @autoreleasepool {
        CATransition* transition = [CATransition animation];
        transition.duration =0.4f;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:view animated:NO];
    }
}

- (void)pop{
    @autoreleasepool {
        CATransition* transition = [CATransition animation];
        transition.duration =0.4f;
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}


#pragma mark -
#pragma mark -  ATKit

- (void)setKeyBoardDismiss{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)setLargeTitleDisplayModeNever{
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}



- (void)goBackLast {
    [self goBackLast:YES];
}

- (void)goBackLast:(BOOL)animated {
    @try {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:animated];
        }
        else if (self.presentingViewController) {
            [self dismissViewControllerAnimated:animated completion:nil];
            [self.view endEditing:YES];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (void)dismissOrPopToRootControlelr {
    [self dismissOrPopToRootController:YES];
}

- (void)dismissOrPopToRootController:(BOOL)animated {
    @try {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:animated completion:nil];
            [self.view endEditing:YES];
        }
        else if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popToRootViewControllerAnimated:animated];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}


+ (UIViewController *)rootTopPresentedController {
    return [self rootTopPresentedControllerWihtKeys:nil];
}
+ (UIViewController *)rootTopPresentedControllerWihtKeys:(NSArray<NSString *> *)keys {
    return [[[[UIApplication sharedApplication] delegate] window].rootViewController topPresentedControllerWihtKeys:keys];
}


//获取当前控制器
- (UIViewController *)currentController {
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}


- (UIWindow *)getKeyWindow{
    UIWindow* window = nil;
    if (@available(iOS 13.0, *)){
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes){
            if (windowScene.activationState == UISceneActivationStateForegroundActive){
                window = windowScene.windows.firstObject;
                
                break;
            }
        }
    }else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}



- (UIViewController *)topPresentedController {
    return [self topPresentedControllerWihtKeys:nil];
}
- (UIViewController *)topPresentedControllerWihtKeys:(NSArray<NSString *> *)keys {
    keys = keys ?: @[@"centerViewController", @"contentViewController"];
    
    UIViewController *rootVC = self;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)rootVC;
        UIViewController *vc = tab.selectedViewController ?: tab.childViewControllers.firstObject;
        if (vc) {
            return [vc topPresentedControllerWihtKeys:keys];
        }
    }
    
    for (NSString *key in keys) {
        if ([rootVC respondsToSelector:NSSelectorFromString(key)]) {
            UIViewController *vc;
            @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                vc = [rootVC performSelector:NSSelectorFromString(key)];
#pragma clang diagnostic pop
            } @catch (NSException *exception) {
            }
            if ([vc isKindOfClass:[UIViewController class]]) {
                return [vc topPresentedControllerWihtKeys:keys];
            }
        }
    }
    
    while (rootVC.presentedViewController && !rootVC.presentedViewController.isBeingDismissed) {
        rootVC = rootVC.presentedViewController;
    }
    
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = ((UINavigationController *)rootVC).topViewController;
    }
    
    return rootVC;
}

- (NSArray<UIViewController *> *)optimizeVcs:(NSArray<UIViewController *> *)vcs {
    return [self optimizeVcs:vcs maxCount:1];
}
- (NSArray<UIViewController *> *)optimizeVcs:(NSArray<UIViewController *> *)vcs maxCount:(NSUInteger)count {
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:vcs];
    [vcArray addObject:self];
    for (UIViewController *vc in vcArray.reverseObjectEnumerator) {
        if ([vc isKindOfClass:[self class]]) {
            if (count) {
                count--;
            }
            else {
                [vcArray removeObject:vc];
            }
        }
    }
    return vcArray.copy;
}

+ (instancetype)vcFromStoryBoard:(NSString *)sbName theId:(NSString *)theId{
    sbName = sbName ?: [[self class] keyForNib];
    theId = theId ?: [[self class] keyForNib];
    UIStoryboard * story = [UIStoryboard storyboardWithName:sbName bundle:nil];
    UIViewController * viewCtrl = [story instantiateViewControllerWithIdentifier:theId];
    return viewCtrl;
}

+ (NSString *)keyForNib{
    return NSStringFromClass([self class]);
}


@end
