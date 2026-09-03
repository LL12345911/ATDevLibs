//
//  SCRoundedTagAttachment.h
//  EngineeringCool
//
//  Created by Mars on 2026/9/2.
//  Copyright © 2026 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 圆角文字标签 Attachment（直接绘制，不生成 UIImage）
@interface SCRoundedTagAttachment : NSTextAttachment

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIEdgeInsets insets;

@end

NS_ASSUME_NONNULL_END
