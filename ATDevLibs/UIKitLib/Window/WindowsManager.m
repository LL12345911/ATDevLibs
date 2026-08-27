//
//  WindowsManager.m
//  EngineeringCool
//
//  Created by Mars on 2022/5/9.
//  Copyright © 2022 Mars. All rights reserved.
//

#import "WindowsManager.h"

@implementation WindowsManager

/**
 @brief 获取当前 KeyWindow（兼容 iOS 12 ~ iOS 18+）
 
 @discussion
 查找优先级：
 1. iOS 13+：ForegroundActive scene → keyWindow
 2. iOS 13+ 兜底：ForegroundInactive scene → keyWindow（处理键盘/Alert 等系统 UI 占用场景）
 3. iOS 15+：直接使用 UIWindowScene.keyWindow
 4. iOS 13~14：遍历 scene.windows 查找 isKeyWindow == YES 的窗口
 5. iOS 12 及以下：使用已废弃的 UIApplication.keyWindow
 
 @return 当前 KeyWindow，极端情况下可能返回 nil
 @warning 不应在 App Launch 早期调用，此时 Scene 可能尚未就绪
 
 @code
 // ✅ 安全获取 keyWindow
 UIWindow *window = [UIApplication keyWindow];
 if (window) {
 [window addSubview:myView];
 }
 
 // ✅ 配合 topViewController 使用
 UIViewController *top = [UIViewController topViewController];
 [top presentViewController:vc animated:YES completion:nil];
 @endcode
 */
+ (UIWindow *)keyWindow {
    if (@available(iOS 13.0, *)) {
        // ━━━ 第一轮：从 ForegroundActive scene 中查找 ━━━
        UIWindow *keyWindow = [self _keyWindowFromScenesWithStates:@[
            @(UISceneActivationStateForegroundActive)
        ]];
        
        // ━━━ 第二轮兜底：系统级 UI（键盘、ActionSheet）弹出时
        //     active scene 的 isKeyWindow 可能为 NO ━━━
        if (!keyWindow) {
            keyWindow = [self _keyWindowFromScenesWithStates:@[
                @(UISceneActivationStateForegroundInactive),
                @(UISceneActivationStateForegroundActive)
            ]];
        }
        
        return keyWindow;
        
    } else {
        // ✅ iOS 12 及以下：使用旧 API，显式忽略废弃警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
    }
}

#pragma mark - Private Helper

/**
 @brief 从指定 activationState 的 scenes 中查找 keyWindow
 @param states 允许的 UISceneActivationState 数组（NSNumber 包装）
 @return 找到的 keyWindow，未找到返回 nil
 
 @code
 // 仅从活跃前台 scene 查找
 UIWindow *w = [self _keyWindowFromScenesWithStates:@[
 @(UISceneActivationStateForegroundActive)
 ]];
 @endcode
 */
+ (nullable UIWindow *)_keyWindowFromScenesWithStates:(NSArray<NSNumber *> *)states {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        // ✅ 类型安全校验：connectedScenes 可能包含非 UIWindowScene（如 CarPlay）
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        
        // 检查 activationState 是否在允许列表中
        BOOL stateAllowed = NO;
        for (NSNumber *s in states) {
            if (scene.activationState == (UISceneActivationState)s.integerValue) {
                stateAllowed = YES;
                break;
            }
        }
        if (!stateAllowed) continue;
        
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        
        // ✅ iOS 15+：直接使用 keyWindow 属性
        if (@available(iOS 15.0, *)) {
            if (windowScene.keyWindow) {
                return windowScene.keyWindow;
            }
        } else {
            // ✅ iOS 13~14：遍历查找 isKeyWindow == YES 的窗口
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return nil;
}


/**
 获取当前 keyWindows
 
 @return UIWindow数组
 */
+ (NSArray<UIWindow *> *)keyWindows {
    if (@available(iOS 13, *)) {
        __block UIScene * _Nonnull tmpSc;
        [[[UIApplication sharedApplication] connectedScenes] enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.activationState == UISceneActivationStateForegroundActive) {
                tmpSc = obj;
                *stop = YES;
            }
        }];
        UIWindowScene *curWinSc = (UIWindowScene *)tmpSc;
        if (!curWinSc) {
            return UIApplication.sharedApplication.windows;
        }
        return curWinSc.windows;
        
    } else {
        return [[UIApplication sharedApplication] windows];
    }
}

//
///**
// 获取 rootViewController
// 
// @return rootViewController
// */
//+ (UIViewController *)rootController {
//    if (@available(iOS 13, *)) {
//        __block UIScene * _Nonnull tmpSc;
//        [[[UIApplication sharedApplication] connectedScenes] enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
//            if (obj.activationState == UISceneActivationStateForegroundActive) {
//                tmpSc = obj;
//                *stop = YES;
//            }
//        }];
//        UIWindowScene *curWinSc = (UIWindowScene *)tmpSc;
//        if (!curWinSc) {
//            return UIApplication.sharedApplication.delegate.window.rootViewController;
//        }
//        
//        if (@available(iOS 15, *)) {
//            return curWinSc.keyWindow.rootViewController;
//        }else {
//            UIWindow *foundWindow = curWinSc.windows.firstObject;
//            for (UIWindow *window in curWinSc.windows) {
//                if (window.isKeyWindow) {
//                    foundWindow = window;
//                    break;
//                }
//            }
//            return foundWindow.rootViewController;
//        }
//        
//    } else {
//        return [UIApplication sharedApplication].keyWindow.rootViewController;
//    }
//}

/**
 @brief 获取当前 rootViewController（兼容 iOS 12 ~ iOS 18+）
 
 @discussion
 内部委托 +keyWindow 方法获取当前关键窗口，再取其 rootViewController。
 查找优先级与 +keyWindow 完全一致：
 1. ForegroundActive scene → keyWindow.rootViewController
 2. ForegroundInactive 兜底（键盘/Alert 等系统 UI 占用场景）
 3. iOS 12 及以下：UIApplication.keyWindow.rootViewController
 
 @return 当前 rootViewController，极端情况下可能返回 nil
 @warning 不应在 App Launch 早期调用，此时 Scene / Window 可能尚未就绪
 
 @code
 // ✅ 安全获取 rootController
 UIViewController *root = [WindowsManager rootController];
 if (root) {
 [root addChildViewController:childVC];
 [root.view addSubview:childVC.view];
 }
 
 // ✅ 作为导航容器起点
 UINavigationController *nav = [[UINavigationController alloc]
 initWithRootViewController:[WindowsManager rootController]];
 @endcode
 */
+ (UIViewController *)rootController {
    UIWindow *kw = [self keyWindow];
    return kw.rootViewController;
}

/**
 获取当前控制器
 
 @return 当前控制器
 */
+ (UIViewController *)presentController {
    /**
     获取当前 keyWindow
     */
    UIViewController* vc = [WindowsManager keyWindow].rootViewController;
    // = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (!vc) {
        vc = [UIApplication sharedApplication].windows.firstObject.rootViewController;;
    }
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



@end
