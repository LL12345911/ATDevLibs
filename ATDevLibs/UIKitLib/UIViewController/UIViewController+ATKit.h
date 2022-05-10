//
//  UIViewController+ATKit.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ViewControllerHandlerProtocol <NSObject>
@optional
/** 重写下面的方法以拦截导航栏pop事件，返回 YES 则 pop，NO 则不 pop  默认返回上一页 */
- (BOOL)navigationBarWillReturn;

@end


@interface UIViewController (ATKit)<ViewControllerHandlerProtocol>

/** 从导航控制器栈中查找ViewController，没有时返回nil */
- (UIViewController *)findViewController:(NSString *)className;

/** 删除指定的视图控制器 */
- (void)deleteViewController:(NSString *)className complete:(void(^)(void))complete;

/** 跳转到指定的视图控制器 */
- (void)pushViewClassController:(NSString *)className animated:(BOOL)animated;


/// 跳转到指定的视图控制器 隐藏底部把导航栏
/// @param className 控制器
/// @param animated y动画
- (void)pushViewControllerHideBottom:(NSString *)className animated:(BOOL)animated;


/** 跳转到指定的视图控制器，此方法可防止循环跳转 */
- (void)preventCirculationPushViewController:(NSString *)className animated:(BOOL)animated;

/** 返回到指定的视图控制器 */
- (void)popViewController:(NSString *)className animated:(BOOL)animated;



/**
 让push跳转动画像modal跳转动画那样效果(从下往上推上来)
 @param view 转转
 */
- (void)pushViewControllerByAnimated:(UIViewController *)view;
- (void)pop;



#pragma mark -
#pragma mark -  ATKit

/**
 @brief 回收键盘
 */
- (void)setKeyBoardDismiss;
/**
 @brief  设置小导航栏
 */
- (void)setLargeTitleDisplayModeNever;

/**
 *  返回上一个界面
 */
- (void)goBackLast;
- (void)goBackLast:(BOOL)animated;
- (void)dismissOrPopToRootControlelr;
- (void)dismissOrPopToRootController:(BOOL)animated;


/**
 *  获取根目录
 */
- (UIViewController *)topPresentedController;
- (UIViewController *)topPresentedControllerWihtKeys:(NSArray<NSString *> *)keys;
+ (UIViewController *)rootTopPresentedController;
+ (UIViewController *)rootTopPresentedControllerWihtKeys:(NSArray<NSString *> *)keys;
/**
 *  控制器数组中 仅存在一个实例
 */
- (NSArray<UIViewController *> *)optimizeVcs:(NSArray<UIViewController *> *)vcs;
- (NSArray<UIViewController *> *)optimizeVcs:(NSArray<UIViewController *> *)vcs maxCount:(NSUInteger)count;
/**
 *  StoryBoard 创建
 */
+ (instancetype)vcFromStoryBoard:(NSString *)sbName theId:(NSString *)theId;



@end



