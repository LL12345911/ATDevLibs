//
//  WindowsManager.h
//  EngineeringCool
//
//  Created by Mars on 2022/5/9.
//  Copyright © 2022 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowsManager : NSObject

/**
 获取当前 keyWindow
 
 @return KeyWindow
 */
+ (UIWindow *)keyWindow;


/**
 获取当前 keyWindows
 
 @return UIWindow数组
 */
+ (NSArray<UIWindow *> *)keyWindows;


/**
 获取 rootViewController
 
 @return rootViewController
 */
+ (UIViewController *)rootController;


/**
 获取当前控制器
 
 @return 当前控制器
 */
+ (UIViewController *)presentController;

@end

NS_ASSUME_NONNULL_END
