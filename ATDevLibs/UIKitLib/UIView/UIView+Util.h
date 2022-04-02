//
//  UIView+ATKit.h
//  AirCnC
//
//  Created by Mars on 2018/11/30.
//  Copyright © 2018 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

//Animation
float radiansForDegress (int degress);


@interface UIView (ATKit)


/// 获取 KeyWindow
- (UIWindow *)getKeyWindow;

/// 获取当前控制器
- (UIViewController *)currentController;
/**
 开启动画
 */
- (void)startIndicatorLoading;
/**
 移除动画 默认是 0.2秒
 */
- (void)stopIndicatorLoading;
- (void)stopIndicatorLoading:(float)time;
/**
 开启动画
 */
- (void)startLoadingOther;


/** 判断两个视图在同一窗口是否有重叠 */
- (BOOL)intersectWithView:(UIView *)view;


#pragma mark - 实现虚线功能  -
- (void)addBorderDottedLinewithColor:(UIColor *)color;


/**
 * Return the width in portrait or the height in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 * Return the height in portrait or the width in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationHeight;



#pragma mark -
#pragma mark -
/**
// *  @brief  找到当前view所在的viewcontroler
// */
//@property (readonly) UIViewController *at_viewController;
/**
 *  @brief  找到指定类名的SubVie对象
 *  @param clazz SubVie类名
 *  @return view对象
 */
- (id)at_findSubViewWithSubViewClass:(Class)clazz;
/**
 *  @brief  找到指定类名的SuperView对象
 *  @param clazz SuperView类名
 *  @return view对象
 */
- (id)at_findSuperViewWithSuperViewClass:(Class)clazz;
/**
 *  @brief  找到并且resign第一响应者
 *  @return 结果
 */
- (BOOL)at_findAndResignFirstResponder;
/**
 *  @brief  找到第一响应者
 *  @return 第一响应者
 */
- (UIView *)at_findFirstResponder;
/** 找到自己的所属viewController */
- (UIViewController *)belongsViewController;
/** 找到当前显示的viewController */
- (UIViewController *)currentViewController;
/**  获取viewcontroller */
- (UIViewController *)viewController;
/**
 *  @brief  移除所有子视图
 */
- (void)removeAllSubviews;
/**
 Attaches the given block for a single tap action to the receiver.
 @param block The block to execute.
 */
- (void)setTapActionWithBlock:(void (^)(void))block;

/**
 Attaches the given block for a long press action to the receiver.
 @param block The block to execute.
 */
- (void)setLongPressActionWithBlock:(void (^)(void))block;



#pragma mark - 截屏
/**
 *  @brief  view截图
 *  @return 截图
 */
- (UIImage *)screenshot;

/**
 *  @brief  截图一个view中所有视图 包括旋转缩放效果
 *  param limitWidth 限制缩放的最大宽度 保持默认传0
 *  @return 截图
 */
- (UIImage *)screenshot:(CGFloat)maxWidth;


#pragma mark - 阴影
- (void)at_makeInsetShadow;
- (void)at_makeInsetShadowWithRadius:(float)radius Alpha:(float)alpha;
- (void)at_makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions;


#pragma mark -
#pragma mark - 动画
//位移
-(void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option;
-(void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option delegate:(id)delegate callBack:(SEL)method;
-(void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapback;
-(void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapback delegate:(id)delegate callBack:(SEL)method;

//3D旋转
-(void)rotateWithCenterPoint:(CGPoint)point angle:(float)angle duration:(float)secs;
/**
 *  淡入
 */
-(void)sadeInDuration:(float)secs finish:(void(^)(void))finishBlock;
/**
 *  淡出
 */
-(void)sadeOutDuration:(float)secs finish:(void(^)(void))finishBlock;

//形变
/**
 * 旋转
 */
-(void)rotate:(int)degrees secs:(float)secs delegate:(id)delegate callBack:(SEL)method;

/**
 * 缩放
 */
-(void)scale:(float)secs x:(float)scaleX y:(float)scaleY delegate:(id)delegate callBack:(SEL)method;

/**
 * 顺时针旋转
 * @param secs 动画执行时间
 */
-(void)spinClockwise:(float)secs;

/**
 * 逆时针旋转
 * @param secs 动画执行时间
 */
-(void)spinCounterClockwise:(float)secs;

/**
 * 反翻页效果
 * @param secs 动画执行时间
 */
-(void)curlDown:(float)secs;

/**
 * 视图翻页后消失
 * @param secs 动画执行时间
 */
-(void)curUpAndAway:(float)secs;

/**
 * 旋转缩放到最后一点消失
 * @param secs 动画执行时间
 */
-(void)drainAway:(float)secs;

/**
 * 将视图改变到一定透明度
 * @param newAlpha 透明度
 * @param secs 动画执行时间
 */
-(void)changeAlpha:(float)newAlpha secs:(float)secs;

/**
 * 改变透明度结束动画后还原
 * @param secs 动画执行时间
 * @param continuously 是否循环
 */
-(void)pulse:(float)secs continuously:(BOOL)continuously;

/**
 * 以渐变方式添加子控件
 * @param subview 需要添加的子控件
 */
-(void)addSubviewWithFadeanimation:(UIView*)subview;

/**
 * 粒子动画
 * @param image 动画图片
 */
-(void)particleAnimationImage:(NSString*)image;



@end

