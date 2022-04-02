//
//  AngleLabel.h
//  EngineeringCool
//
//  Created by Mars on 2020/1/13.
//  Copyright © 2020 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AngleView : UIView

@property (nonatomic,strong) UIColor *costomColor;
//角的高度
@property (nonatomic,assign) float angleHeight;
//圆角半径
@property (nonatomic,assign) float cornerRadius;


//@property (nonatomic,copy) NSString *textStr;
//@property (nonatomic,copy) UIFont *textFont;
//@property (nonatomic,copy) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
