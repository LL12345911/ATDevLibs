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
 获取当前 keyWindow
 
 @return KeyWindow
 */
+ (UIWindow *)keyWindow {
    if (@available(iOS 13, *)) {
        __block UIScene * _Nonnull tmpSc;
        [[[UIApplication sharedApplication] connectedScenes] enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.activationState == UISceneActivationStateForegroundActive) {
                tmpSc = obj;
                *stop = YES;
            }
        }];
        UIWindowScene *curWinSc = (UIWindowScene *)tmpSc;
        if (@available(iOS 15, *)) {
            return curWinSc.keyWindow;
        }else {
            UIWindow *foundWindow = curWinSc.windows.firstObject;
            for (UIWindow *window in curWinSc.windows) {
                if (window.isKeyWindow) {
                    foundWindow = window;
                    break;
                }
            }
            return foundWindow;
        }
        
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
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
        return curWinSc.windows;
        
    } else {
        return [[UIApplication sharedApplication] windows];
    }
}


/**
 获取 rootViewController
 
 @return rootViewController
 */
+ (UIViewController *)rootController {
    if (@available(iOS 13, *)) {
        __block UIScene * _Nonnull tmpSc;
        [[[UIApplication sharedApplication] connectedScenes] enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.activationState == UISceneActivationStateForegroundActive) {
                tmpSc = obj;
                *stop = YES;
            }
        }];
        UIWindowScene *curWinSc = (UIWindowScene *)tmpSc;
        if (@available(iOS 15, *)) {
            return curWinSc.keyWindow.rootViewController;
        }else {
            UIWindow *foundWindow = curWinSc.windows.firstObject;
            for (UIWindow *window in curWinSc.windows) {
                if (window.isKeyWindow) {
                    foundWindow = window;
                    break;
                }
            }
            return foundWindow.rootViewController;
        }
        
    } else {
        return [UIApplication sharedApplication].keyWindow.rootViewController;
    }
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
