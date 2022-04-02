//
//  UIViewController+Animation.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/29.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATPopupBackgroundView;

typedef NS_ENUM(NSInteger, ATPopupViewAnimation) {
    ATPopupViewAnimationFade = 0,
    ATPopupViewAnimationSlideBottomTop = 1,
    ATPopupViewAnimationSlideBottomBottom,
    ATPopupViewAnimationSlideTopTop,
    ATPopupViewAnimationSlideTopBottom,
    ATPopupViewAnimationSlideLeftLeft,
    ATPopupViewAnimationSlideLeftRight,
    ATPopupViewAnimationSlideRightLeft,
    ATPopupViewAnimationSlideRightRight,
};

@interface UIViewController (Animation)

@property (nonatomic, retain) UIViewController *at_popupViewController;
@property (nonatomic, retain) ATPopupBackgroundView *at_popupBackgroundView;

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(ATPopupViewAnimation)animationType;
- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(ATPopupViewAnimation)animationType backgroundTouch:(BOOL)enable dismissed:(void(^)(void))dismissed;

- (void)dismissPopupViewControllerWithanimationType:(ATPopupViewAnimation)animationType;


//水波纹
-(void)pushDropsWaterViewController:(UIViewController*)viewController;
//水波纹
-(void)presentDropsWaterViewController:(UIViewController*)viewController;


@end



@interface ATPopupBackgroundView : UIView

@end
