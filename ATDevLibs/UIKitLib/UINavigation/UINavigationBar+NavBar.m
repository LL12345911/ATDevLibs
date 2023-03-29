//
//  UINavigationBar+NavBar.m
//  HighwayDoctor
//
//  Created by Mars on 2019/4/29.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UINavigationBar+NavBar.h"
#import <objc/runtime.h>
#import <sys/utsname.h>

@implementation UINavigationBar (NavBar)

static char overlayKey;
static char overlayImageKey;



/**
 判断 是否是 iPhone X
 
 @return 是 或 否
 */
+ (BOOL)isIphoneX {
    BOOL isBangsScreen = NO;
    /// 在这里之所以使用 windows 是因为，keyWindow、delegate.window有时候会获取不到，为null
//    if (@available(iOS 11.0, *)) {
//        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
//        isBangsScreen = window.safeAreaInsets.bottom > 0;
//    }
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        isBangsScreen = window.safeAreaInsets.bottom > 0;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        isBangsScreen = window.safeAreaInsets.bottom > 0;
    }
    return isBangsScreen;
//    //为 Ipad
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        return NO;
//    }
//    struct utsname systemInfo;
//    uname(&systemInfo);
//    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
//    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
//        // judgment by height when in simulators
//        return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
//                CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||
//                CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)) ||
//                CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)));
//    }
//    BOOL isIPhoneX = [platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"] || [platform isEqualToString:@"iPhone11,8"] || [platform isEqualToString:@"iPhone11,2"] || [platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"] || [platform isEqualToString:@"iPhone12,1"] || [platform isEqualToString:@"iPhone12,3"] || [platform isEqualToString:@"iPhone12,5"] || [platform isEqualToString:@"iPhone13,1"] || [platform isEqualToString:@"iPhone13,2"] || [platform isEqualToString:@"iPhone13,3"] || [platform isEqualToString:@"iPhone13,4"];
//    return isIPhoneX;
}


/**
 判断 是否是 iPhone X
 
 @return 是 或 否
 */
+ (BOOL)isPhoneX {
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return iPhoneX;
    }
//    if (@available(iOS 11.0, *)) {
//        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
//        //UIApplication.shared.windows[0].safeAreaInsets != UIEdgeInsets.zero
//        if (mainWindow.safeAreaInsets.bottom > 0.0) {
//            iPhoneX = YES;
//        }
//    }
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        iPhoneX = window.safeAreaInsets.bottom > 0;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        iPhoneX = window.safeAreaInsets.bottom > 0;
    }
    
    return iPhoneX;
}



- (UIView *)overlay{
    return objc_getAssociatedObject(self, &overlayKey);
}


- (void)setOverlay:(UIView *)overlay{
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIImageView *)overlayImage{
    return objc_getAssociatedObject(self, &overlayImageKey);
}


- (void)setOverlayImage:(UIView *)overlayImage{
    objc_setAssociatedObject(self, &overlayImageKey, overlayImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




- (void)at_setBackgroundColor:(UIColor *)backgroundColor{
//    [self at_reset];
    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        CGFloat navHeight = [UINavigationBar isPhoneX] ? 44.0 : 20.0;
//        //获取状态栏的rect
//        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
//        CGFloat navHeight = statusRect.size.height;
        
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -navHeight, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.bounds) + navHeight)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;
}

- (void)at_setBackgroundImage:(UIImage *)backgroundImage{
//    [self at_reset];
    if (!self.overlayImage) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        CGFloat navHeight = [UINavigationBar isPhoneX] ? 44.0 : 20.0;
//        //获取状态栏的rect
//        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
//        CGFloat navHeight = statusRect.size.height;
        
        
        self.overlayImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, -navHeight, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.bounds) + navHeight)];
        self.overlayImage.userInteractionEnabled = NO;
        self.overlayImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.overlayImage atIndex:0];
    }
    self.overlayImage.image = backgroundImage;
}



- (void)at_setTranslationY:(CGFloat)translationY{
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

- (void)at_setElementsAlpha:(CGFloat)alpha{
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    
    
    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha = alpha;
    //    when viewController first load, the titleView maybe nil
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            obj.alpha = alpha;
            *stop = YES;
        }
        
    }];
    
}

- (void)at_reset{
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.overlay removeFromSuperview];
    self.overlay = nil;
    [self.overlayImage removeFromSuperview];
    self.overlayImage = nil;
    
}

/**
 设置导航栏背景图片
 
 @param backgroundImage 背景图片n名
 */
- (void)at_setBackgroundCustomImage:(NSString *)backgroundImage{
    [self setBackgroundImage:[UIImage imageNamed:backgroundImage] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self setShadowImage:[[UIImage alloc] init]];
    self.translucent = YES;
}

/**
 设置导航栏背景颜色 导航栏下边无黑边
 
 @param color 背景颜色
 */
- (void)at_setBackgroundCustomColor:(UIColor *)color{
    [self at_reset];
    [self setBackgroundImage:[self createImageWithColor:color] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self setShadowImage:[[UIImage alloc] init]];
    self.translucent = YES;
}



/**
 设置导航栏背景颜色 导航栏下边无黑边
 
@param alpha 设置透明度
 @param color 背景颜色
 */
- (void)at_setBackgroundCustomColor:(UIColor *)color alpha:(CGFloat)alpha{
    [self at_reset];
    [self setBackgroundImage:[self createImageWithColor:color alpha:alpha] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self setShadowImage:[[UIImage alloc] init]];
    self.translucent = YES;
}


/**
 设置导航栏背景颜色  导航栏下边有黑边
 
 @param color 背景颜色
 */
- (void)at_setLineBackgroundCustomColor:(UIColor *)color {
    [self at_reset];
    [self setBackgroundImage:[self createImageWithColor:color] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self setShadowImage:nil];
    self.translucent = YES;
}


/**
 设置导航栏背景颜色 导航栏下边有黑边
 
 @param alpha 设置透明度
 @param color 背景颜色
 */
- (void)at_setLineBackgroundCustomColor:(UIColor *)color alpha:(CGFloat)alpha {
    [self at_reset];
    [self setBackgroundImage:[self createImageWithColor:color alpha:alpha] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:nil];
    self.translucent = YES;
}



/**
 颜色转变成图片
 
 @param color UIColor
 @return UIImage
 */

/**
 颜色转变成图片
 
 @param color UIColor
 @param alpha 设置透明度
 @return UIImage
 */
- (UIImage *)createImageWithColor:(UIColor *)color alpha:(CGFloat)alpha{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
     CGContextSetAlpha(context, alpha);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
    
//
//    UIGraphicsBeginImageContextWithOptions(self.size,NO,0.0f);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGRectarea = CGRectMake(0,0,self.size.width,self.size.height);
//    CGContextScaleCTM(ctx, 1, -1);
//    CGContextTranslateCTM(ctx, 0, -area.size.height);
//    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
//    CGContextSetAlpha(ctx, alpha);
//    CGContextDrawImage(ctx, area,self.CGImage);
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
   
    
}


/**
 颜色转变成图片

 @param color UIColor
 @return UIImage
 */
- (UIImage *)createImageWithColor:(UIColor *) color{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
    
}


/**
 设置导航栏标题颜色
 
 @param color 标题颜色
 */
- (void)at_setTitleTextAttribute:(UIColor *)color{
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName : color ? color : [UIColor whiteColor],
                                              NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:17]
                                   
                                   }];
}

@end
