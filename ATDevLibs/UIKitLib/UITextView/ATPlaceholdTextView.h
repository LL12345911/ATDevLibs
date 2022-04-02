//
//  ATTextView.h
//  HighwayDoctor
//
//  Created by Mars on 2019/6/24.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATPlaceholdTextView : UITextView

/**
 占位文字
 */
@property (nonatomic,copy) NSString *placehold;

/**
 占位文字的颜色
 */
@property (nonatomic,strong) UIColor *placeholdColor;

@end

NS_ASSUME_NONNULL_END
