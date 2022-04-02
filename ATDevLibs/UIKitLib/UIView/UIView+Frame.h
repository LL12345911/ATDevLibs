//
//  UIView+Frame.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/15.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CGRectOrigin(v)      v.frame.origin
#define CGRectSize(v)        v.frame.size
#define CGRectX(v)           CGRectOrigin(v).x
#define CGRectY(v)           CGRectOrigin(v).y
#define CGRectW(v)           CGRectSize(v).width
#define CGRectH(v)           CGRectSize(v).height
#define CGRectXW(v)          (CGRectSize(v).width+CGRectOrigin(v).x)
#define CGRectYH(v)          (CGRectSize(v).height+CGRectOrigin(v).y)

@interface UIView (Frame)

/**
 *  返回UIView及其子类的位置和尺寸。分别为左、右边界在X轴方向上的距离，上、下边界在Y轴上的距离，View的宽和高。
 */
@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;
@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat right;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign) CGFloat bottom;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat centerX;
@property(nonatomic, assign) CGFloat centerY;
@property(nonatomic, assign) CGSize  size;
@property(nonatomic, assign) CGPoint origin;
@property(nonatomic, readonly) CGFloat screenX;
@property(nonatomic, readonly) CGFloat screenY;
@property(nonatomic, readonly) CGFloat screenViewX;
@property(nonatomic, readonly) CGFloat screenViewY;
@property(nonatomic, readonly) CGRect screenFrame;

- (void)changeTopByAdding:(NSNumber *)number;

////加载同名的xib
//+ (instancetype)viewFromXib;


/**
 是否在屏幕中，即是否在可显示层级中
 
 当view与屏幕frame有交集且hidden为NO，alpha不为0时等一切可视情况（被完全遮盖也视作可视情况）为YES，其他为NO
 */
@property (nonatomic ,assign ,readonly,getter=isInScreen) BOOL inScreen;


/**
 以递归的方式遍历(查找)subview
 Return YES from the block to recurse into the subview.
 Set stop to YES to return the subview.
 */
- (UIView*)findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop))recurse;
/**
 Returns the superView of provided class type.
 */
- (__kindof UIView *)superviewOfClass:(Class)classType;
/**
 Returns the navigationController, if exsit.
 */
@property (nonatomic, readonly, strong) UINavigationController *getNavigationController;

///添加线
-(void)dw_AddLineWithFrame:(CGRect)frame color:(UIColor *)color;

///添加圆角
-(void)dw_AddCorner:(UIRectCorner)corners radius:(CGFloat)radius;


@end



@interface UIView (CGAffineTransform)

/// 获取当前 view 的 transform scale x
@property(nonatomic, assign, readonly) CGFloat at_scaleX;

/// 获取当前 view 的 transform scale y
@property(nonatomic, assign, readonly) CGFloat at_scaleY;

/// 获取当前 view 的 transform translation x
@property(nonatomic, assign, readonly) CGFloat at_translationX;

/// 获取当前 view 的 transform translation y
@property(nonatomic, assign, readonly) CGFloat at_translationY;

@end





@interface UIView (superFrame)
/**
 移除当前所有 subviews
 */
- (void)qmui_removeAllSubviews;

/// 同 [UIView convertPoint:toView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGPoint)qmui_convertPoint:(CGPoint)point toView:(UIView *)view;

/// 同 [UIView convertPoint:fromView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGPoint)qmui_convertPoint:(CGPoint)point fromView:(UIView *)view;

/// 同 [UIView convertRect:toView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGRect)qmui_convertRect:(CGRect)rect toView:(UIView *)view;

/// 同 [UIView convertRect:fromView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGRect)qmui_convertRect:(CGRect)rect fromView:(UIView *)view;


@end

