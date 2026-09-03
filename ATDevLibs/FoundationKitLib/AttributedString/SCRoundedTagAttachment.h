//
//  SCRoundedTagAttachment.h
//  EngineeringCool
//
//  Created by Mars on 2026/9/2.
//  Copyright © 2026 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  SCRoundedTagAttachment
 *  圆角文字标签 Attachment（直接绘制，不生成 UIImage）
 *
 *  用于在 NSAttributedString 中嵌入“圆角文字标签”的 NSTextAttachment 子类。
 *
 *  特点：
 *  - 不依赖外部 UIImage，标签由 attachment 内部直接绘制
 *  - 支持字体、文字颜色、背景色、圆角、内边距配置
 *  - 通过缓存渲染结果提升性能，属性变更时自动失效缓存
 *  - 同时兼容 TextKit 的 image 渲染路径与旧系统的 drawInRect 路径
 */
@interface SCRoundedTagAttachment : NSTextAttachment

/// 标签文字
@property (nonatomic, copy) NSString *text;

/// 标签字体（为 nil 时使用系统 14 号字体）
@property (nonatomic, strong, nullable) UIFont *font;

/// 文字颜色
@property (nonatomic, strong, nullable) UIColor *textColor;

/// 圆角背景填充色
@property (nonatomic, strong, nullable) UIColor *fillColor;

/// 圆角半径
@property (nonatomic, assign) CGFloat cornerRadius;

/// 标签内容与背景边缘的内边距
@property (nonatomic, assign) UIEdgeInsets insets;

@end

NS_ASSUME_NONNULL_END
