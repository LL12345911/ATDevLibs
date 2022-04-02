//
//  AutoInch.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/9.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "ATMacro.h"

#ifndef AutoInch_h
#define AutoInch_h

#ifdef __OBJC__

//********* iPhone X系列判断 *********//
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

//#define kWidth (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))
//#define kHeight (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))


// 基准屏幕宽度
#define kRefereWidth 375.0

CG_INLINE CGFloat minWidth(){
    return (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
}
CG_INLINE CGFloat maxWidth(){
    return (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
}
CG_INLINE CGFloat maxHeight(){
    return (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
}
CG_INLINE CGFloat minHeight(){
    return (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
}

//获取导航栏+状态栏的高度
#define getRectNavAndStatusHight \
({\
CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];\    CGRect rectNav = self.navigationController.navigationBar.frame;\
( rectStatus.size.height+ rectNav.size.height);\
})\

////************ 屏幕的高度 ************//
//CG_INLINE CGFloat Scale_Width(CGFloat value){
//    return ((CGFloat)((minWidth() * (value) / 375.0f)));
//}
//刘海屏 isNotchScreen
CG_INLINE BOOL isIphoneX(){
    //return [ATMacro iPhoneX] || [ATMacro iPhoneXR] || [ATMacro iPhoneXMax];
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    /// 在这里之所以使用 windows 是因为，keyWindow、delegate.window有时候会获取不到，为null
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
        iPhoneXSeries = window.safeAreaInsets.bottom > 0;
    }
    return iPhoneXSeries;
    
//    if (@available(iOS 11.0, *)) {//x系列的系统从iOS11开始
//        if(UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom > 0.0) {
//            iPhoneXSeries = YES;
//        }
//    }
//    return iPhoneXSeries;
}


CG_INLINE UIEdgeInsets safeAreaInsets(void) {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets];
    }
    return safeAreaInsets;
}
/**
 状态栏的高度

 @return 不是刘海屏默认20，是的话44
 */
CG_INLINE CGFloat kStatusBar(){
//    //获取状态栏的rect
//    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
//    return statusRect.size.height;
    return (isIphoneX() ? 44.0 : 20.0);//状态栏;
}
/**
 导航栏的高度

 @return 不是刘海屏默认64，是的话88
 */
CG_INLINE CGFloat kNavHeight(){
   // return kStatusBar() + 44;
    return (isIphoneX() ? 88.0 : 64.0);//导航栏
}
/**
 底部tabbar的高度

 @return 不是刘海屏默认49，是的话83
 */
CG_INLINE CGFloat kTabBarHeight(){
    return (isIphoneX() ? 83.0 : 49.0);
}
/**
 底部高度

 @return 不是刘海屏默认0，是的话34
 */
CG_INLINE CGFloat kBottom(){
    return (isIphoneX() ? 34 : 0);//iphoneX斜刘海
}
/**
 去除导航栏和iPhone X底部圆弧的高度
 
 @return kHeight-kNavHeight()-kBottomHeight();
 */
CG_INLINE CGFloat kSafeHeight(){
    return [UIScreen mainScreen].bounds.size.height-kNavHeight()-kBottom();//kHeight-kNavHeight()-kBottom();
}

/**
 去除导航栏和iPhone X（或不是刘海屏） CGRect
 
 @return CGRect CGRectMake(0, kNavHeight(), kWidth, kHeight-kNavHeight()-kBottomHeight())
 */
CG_INLINE CGRect kRect(){
    return CGRectMake(0, kNavHeight(), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kNavHeight()-kBottom());
}
/**
 自动获取适应 屏幕的字体大小
 
 @param original 要设置的字体大小
 @return 自动适应后的字体（UIFont）
 */
CG_INLINE UIFont* AutoFont(CGFloat original){
    CGFloat autoSize = original * minWidth() / kRefereWidth;
    UIFont *font = [UIFont systemFontOfSize:autoSize];
    return font;
}
/**
字体大小
 
 @param original 要设置的字体大小
 @return 自动适应后的字体（UIFont）
 */
CG_INLINE UIFont* Font(CGFloat original){
    UIFont *font = [UIFont systemFontOfSize:original];
    return font;
}
/**
 自动获取适应 屏幕的字体大小(粗体)
 
 @param original 要设置的字体大小
 @return 自动适应后的字体（UIFont）
 */
CG_INLINE UIFont* AutoBlodFont(CGFloat original){
    CGFloat autoSize = original * minWidth() / kRefereWidth;
    UIFont *font = [UIFont boldSystemFontOfSize:autoSize];
    return font;
}
/**
 自字体大小(粗体)
 
 @param original 要设置的字体大小
 @return 自动适应后的字体（UIFont）
 */
CG_INLINE UIFont* BlodFont(CGFloat original){
    UIFont *font = [UIFont boldSystemFontOfSize:original];
    return font;
}
/**
 自动获取适应 屏幕的尺寸
 
 @param original 要设置的屏幕尺寸
 @return 自动适应后的屏幕尺寸
 */
CG_INLINE CGFloat Inch(CGFloat original){
    return original * minWidth() / kRefereWidth;
}
/**
 自动获取适应 缩放屏幕的比例
 
 @return 自动适应后的屏幕尺寸
 */
CG_INLINE CGFloat AutoScale(){
    return  minWidth() / kRefereWidth;
}
/**
 标准体

 @return UIFont(默认是15号字体)
 */
CG_INLINE UIFont* ATFont(){
    return AutoFont(15);
}

/**
 粗体

 @return UIFont(默认是15号字体)
 */
CG_INLINE UIFont* ATBoldFont(){
    return AutoBlodFont(15);
}
//CG_INLINE CGFloat screenWidth() {
//    return [UIScreen mainScreen].bounds.size.width;
//}
//
//CG_INLINE CGFloat screenHeight() {
//    return [UIScreen mainScreen].bounds.size.height;
//}
///**
// 去除导航栏和iPhone X（或不是刘海屏）底部导航栏的高度
//
// @return kHeight-kNavHeight()-kTabBarHeigh();
// */
//CG_INLINE CGFloat kNoBarHeight(){
//    return kHeight-kNavHeight()-kTabBarHeight();
//}

/// 获取当前控制器
CG_INLINE UIViewController* GetController(){
    //获取当前控制器
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


#endif



#endif /* AutoInch_h */
