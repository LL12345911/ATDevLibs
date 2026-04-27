//
//  UIViewController+Util.h
//  ATC
//
//  Created by Mars on 2018/4/23.
//  Copyright © 2018年 AirCnC车去车来. All rights reserved.
//
//


#import <UIKit/UIKit.h>

typedef void(^LeftBarButtonItemBlock)(void);


@interface UIViewController (Util)

///**
// 强制横屏方法
// 横屏(如果属性值为YES,仅允许屏幕向左旋转,否则仅允许竖屏)
// @param fullscreen 屏幕方向
// */
//- (void)setNewOrientation:(BOOL)fullscreen;

/**
 返回按钮方法拦截
 */
@property (nonatomic, copy) LeftBarButtonItemBlock leftBarButtonClickBlock;

/**
 设置 导航栏左侧 按钮的图片
 @param imageName 图片名
 */
- (void)at_leftNavigationBar:(NSString *)imageName;


#pragma mark -
#pragma mark - 导航栏 加载动画

/// 加载进度
- (void)startIndicatorLoading;

/// 加载进度
/// @param alpha 透明度 0-1（值范围）
- (void)startIndicatorLoadingWithAlpha:(CGFloat)alpha;

/// 全屏加载进度
- (void)startLoadingFullScreen;

/// 全屏加载进度
/// @param alpha 透明度 0-1（值范围）
- (void)startLoadingFullScreenWithAlpha:(CGFloat)alpha;

/// 停止加载
- (void)stopIndicatorLoading;

/// 停止加载
/// @param time 时间
- (void)stopIndicatorLoading:(float)time;


///**
// 导航栏背景色
//
// @param imageName 图片名
// */
//- (void)at_navigationBarBackImage:(NSString *)imageName;
//
//
///**
// 导航栏背景色
//
// @param backColor 颜色
// */
//- (void)at_navigationBarBackColor:(UIColor *)backColor;
//
//
///**
// 导航栏背透明
// */
//- (void)at_navigationBarClearColor;
//
//
///**
// 导航栏 标题字体颜色
//
// @param titleColor 字体颜色
// */
//- (void)at_navigationBarTitleColor:(UIColor *)titleColor;




/// 获取当前控制器
//- (UIViewController *)currentController;

@end
