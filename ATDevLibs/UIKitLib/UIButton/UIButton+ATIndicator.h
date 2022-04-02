//
//  UIButton+ATIndicator.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Simple category that lets you replace the text of a button with an activity indicator.
 */

@interface UIButton (ATIndicator)

/**
 This method will show the activity indicator in place of the button text.
 */
- (void)at_showIndicator;

/**
 This method will show the activity indicator in place of the button text.

 @param statusText 替换的文字
 */
- (void)at_showIndicatorStatusText:(NSString *)statusText;



/**
 This method will remove the indicator and put thebutton text back in place.
 */
- (void)at_hideIndicator;

/**
 *  @brief  按钮是否正在提交中
 */
@property(nonatomic, readonly, getter=isSubmitting) NSNumber *submitting;


@end
