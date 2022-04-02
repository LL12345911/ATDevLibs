//
//  UIViewController+Animation.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/29.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIViewController+Animation.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kPopupModalAnimationDuration 0.35
#define kATPopupViewController @"kATPopupViewController"
#define kATPopupBackgroundView @"kATPopupBackgroundView"
#define kATSourceViewTag 23941
#define kATPopupViewTag 23942
#define kATOverlayViewTag 23945

@interface UIViewController (ATPopupViewControllerPrivate)
- (UIView*)topView;
- (void)presentPopupView:(UIView*)popupView;
@end

static NSString *ATPopupViewDismissedKey = @"ATPopupViewDismissed";

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public

@implementation UIViewController (Animation)

static void * const keypath = (void*)&keypath;

- (UIViewController*)at_popupViewController {
    return objc_getAssociatedObject(self, kATPopupViewController);
}

- (void)setAt_popupViewController:(UIViewController *)at_popupViewController {
    objc_setAssociatedObject(self, kATPopupViewController, at_popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (ATPopupBackgroundView*)at_popupBackgroundView {
    return objc_getAssociatedObject(self, kATPopupBackgroundView);
}

- (void)setAt_popupBackgroundView:(ATPopupBackgroundView *)at_popupBackgroundView {
    objc_setAssociatedObject(self, kATPopupBackgroundView, at_popupBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(ATPopupViewAnimation)animationType backgroundTouch:(BOOL)enable dismissed:(void(^)(void))dismissed
{
    self.at_popupViewController = popupViewController;
    [self presentPopupView:popupViewController.view animationType:animationType backgroundTouch:enable dismissed:dismissed];
}

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(ATPopupViewAnimation)animationType
{
    [self presentPopupViewController:popupViewController animationType:animationType backgroundTouch:YES dismissed:nil];
}

- (void)dismissPopupViewControllerWithanimationType:(ATPopupViewAnimation)animationType
{
    UIView *sourceView = [self topView];
    UIView *popupView = [sourceView viewWithTag:kATPopupViewTag];
    UIView *overlayView = [sourceView viewWithTag:kATOverlayViewTag];
    
    switch (animationType) {
        case ATPopupViewAnimationSlideBottomTop:
        case ATPopupViewAnimationSlideBottomBottom:
        case ATPopupViewAnimationSlideTopTop:
        case ATPopupViewAnimationSlideTopBottom:
        case ATPopupViewAnimationSlideLeftLeft:
        case ATPopupViewAnimationSlideLeftRight:
        case ATPopupViewAnimationSlideRightLeft:
        case ATPopupViewAnimationSlideRightRight:
            [self slideViewOut:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
            break;
            
        default:
            [self fadeViewOut:popupView sourceView:sourceView overlayView:overlayView];
            break;
    }
}

//水波纹
-(void)pushDropsWaterViewController:(UIViewController*)viewController{
    
    [self.navigationController pushViewController:viewController animated:NO];
    CATransition *animation = [CATransition animation];
    animation.duration = 0.8;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:animation forKey:nil];
    
    
}


//水波纹
-(void)presentDropsWaterViewController:(UIViewController*)viewController{
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.7;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:animation forKey:nil];
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self  presentViewController:viewController animated: NO completion:nil];
    
    
}

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Handling

- (void)presentPopupView:(UIView*)popupView animationType:(ATPopupViewAnimation)animationType
{
    [self presentPopupView:popupView animationType:animationType backgroundTouch:YES dismissed:nil];
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        if (rootViewController) {
            return rootViewController;
        }else{
            UIViewController *recentView = self;
            
            while (recentView.parentViewController != nil) {
                recentView = recentView.parentViewController;
            }
            return recentView;
            
        }
    }
}

- (void)presentPopupView:(UIView*)popupView animationType:(ATPopupViewAnimation)animationType backgroundTouch:(BOOL)enable dismissed:(void(^)(void))dismissed
{
    UIView *sourceView = [self topView];
    sourceView.tag = kATSourceViewTag;
    popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    popupView.tag = kATPopupViewTag;
    
    // check if source view controller is not in destination
    if ([sourceView.subviews containsObject:popupView]) return;
    
    // customize popupView
    popupView.layer.shadowPath = [UIBezierPath bezierPathWithRect:popupView.bounds].CGPath;
    popupView.layer.masksToBounds = NO;
    popupView.layer.shadowOffset = CGSizeMake(5, 5);
    popupView.layer.shadowRadius = 5;
    popupView.layer.shadowOpacity = 0.5;
    popupView.layer.shouldRasterize = YES;
    popupView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // Add semi overlay
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.tag = kATOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];
    
    // BackgroundView
    self.at_popupBackgroundView = [[ATPopupBackgroundView alloc] initWithFrame:sourceView.bounds];
    self.at_popupBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.at_popupBackgroundView.backgroundColor = [UIColor clearColor];
    self.at_popupBackgroundView.alpha = 0.0f;
    [overlayView addSubview:self.at_popupBackgroundView];
    
    // Make the Background Clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.bounds;
    [overlayView addSubview:dismissButton];
    
    popupView.alpha = 0.0f;
    [overlayView addSubview:popupView];
    [sourceView addSubview:overlayView];
    
    
    [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimation:) forControlEvents:UIControlEventTouchUpInside];
    switch (animationType) {
        case ATPopupViewAnimationSlideBottomTop:
        case ATPopupViewAnimationSlideBottomBottom:
        case ATPopupViewAnimationSlideTopTop:
        case ATPopupViewAnimationSlideTopBottom:
        case ATPopupViewAnimationSlideLeftLeft:
        case ATPopupViewAnimationSlideLeftRight:
        case ATPopupViewAnimationSlideRightLeft:
        case ATPopupViewAnimationSlideRightRight:
            dismissButton.tag = animationType;
            [self slideViewIn:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
            break;
        default:
            dismissButton.tag = ATPopupViewAnimationFade;
            [self fadeViewIn:popupView sourceView:sourceView overlayView:overlayView];
            break;
    }
    dismissButton.enabled = enable;
    [self setDismissedCallback:dismissed];
}

-(UIView*)topView {
    
    return  [self topViewController].view;
}
//-(UIView*)topView {
//    UIViewController *recentView = self;
//
//    while (recentView.parentViewController != nil) {
//        recentView = recentView.parentViewController;
//    }
//    return recentView.view;
//}

- (void)dismissPopupViewControllerWithanimation:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* dismissButton = sender;
        switch (dismissButton.tag) {
            case ATPopupViewAnimationSlideBottomTop:
            case ATPopupViewAnimationSlideBottomBottom:
            case ATPopupViewAnimationSlideTopTop:
            case ATPopupViewAnimationSlideTopBottom:
            case ATPopupViewAnimationSlideLeftLeft:
            case ATPopupViewAnimationSlideLeftRight:
            case ATPopupViewAnimationSlideRightLeft:
            case ATPopupViewAnimationSlideRightRight:
                [self dismissPopupViewControllerWithanimationType:dismissButton.tag];
                break;
            default:
                [self dismissPopupViewControllerWithanimationType:ATPopupViewAnimationFade];
                break;
        }
    } else {
        [self dismissPopupViewControllerWithanimationType:ATPopupViewAnimationFade];
    }
}

//////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations

#pragma mark --- Slide

- (void)slideViewIn:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView withAnimationType:(ATPopupViewAnimation)animationType
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupStartRect;
    switch (animationType) {
        case ATPopupViewAnimationSlideBottomTop:
        case ATPopupViewAnimationSlideBottomBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        sourceSize.height,
                                        popupSize.width,
                                        popupSize.height);
            
            break;
        case ATPopupViewAnimationSlideLeftLeft:
        case ATPopupViewAnimationSlideLeftRight:
            popupStartRect = CGRectMake(-sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;
            
        case ATPopupViewAnimationSlideTopTop:
        case ATPopupViewAnimationSlideTopBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        -popupSize.height,
                                        popupSize.width,
                                        popupSize.height);
            break;
            
        default:
            popupStartRect = CGRectMake(sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;
    }
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupStartRect;
    popupView.alpha = 1.0f;
    [UIView animateWithDuration:kPopupModalAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.at_popupViewController viewWillAppear:NO];
        self.at_popupBackgroundView.alpha = 1.0f;
        popupView.frame = popupEndRect;
    } completion:^(BOOL finished) {
        [self.at_popupViewController viewDidAppear:NO];
    }];
}

- (void)slideViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView withAnimationType:(ATPopupViewAnimation)animationType
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect;
    switch (animationType) {
        case ATPopupViewAnimationSlideBottomTop:
        case ATPopupViewAnimationSlideTopTop:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      -popupSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case ATPopupViewAnimationSlideBottomBottom:
        case ATPopupViewAnimationSlideTopBottom:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      sourceSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case ATPopupViewAnimationSlideLeftRight:
        case ATPopupViewAnimationSlideRightRight:
            popupEndRect = CGRectMake(sourceSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
        default:
            popupEndRect = CGRectMake(-popupSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
    }
    
    [UIView animateWithDuration:kPopupModalAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.at_popupViewController viewWillDisappear:NO];
        popupView.frame = popupEndRect;
        self.at_popupBackgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self.at_popupViewController viewDidDisappear:NO];
        self.at_popupViewController = nil;
        
        id dismissed = [self dismissedCallback];
        if (dismissed != nil)
        {
            ((void(^)(void))dismissed)();
            [self setDismissedCallback:nil];
        }
    }];
}

#pragma mark --- Fade

- (void)fadeViewIn:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupEndRect;
    popupView.alpha = 0.0f;
    
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        [self.at_popupViewController viewWillAppear:NO];
        self.at_popupBackgroundView.alpha = 0.5f;
        popupView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.at_popupViewController viewDidAppear:NO];
    }];
}

- (void)fadeViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        [self.at_popupViewController viewWillDisappear:NO];
        self.at_popupBackgroundView.alpha = 0.0f;
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self.at_popupViewController viewDidDisappear:NO];
        self.at_popupViewController = nil;
        
        id dismissed = [self dismissedCallback];
        if (dismissed != nil)
        {
            ((void(^)(void))dismissed)();
            [self setDismissedCallback:nil];
        }
    }];
}

#pragma mark -
#pragma mark Category Accessors

#pragma mark --- Dismissed

- (void)setDismissedCallback:(void(^)(void))dismissed
{
    objc_setAssociatedObject(self, &ATPopupViewDismissedKey, dismissed, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.at_popupViewController, &ATPopupViewDismissedKey, dismissed, OBJC_ASSOCIATION_RETAIN);
    
}

- (void(^)(void))dismissedCallback
{
    return objc_getAssociatedObject(self, &ATPopupViewDismissedKey);
}

@end



@implementation ATPopupBackgroundView

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}


@end
