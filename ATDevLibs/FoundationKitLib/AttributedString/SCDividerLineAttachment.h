//
//  SCDividerLineAttachment.h
//  ATDevLibs
//
//  Created by Mars on 2026/9/8.
//  Copyright © 2026 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  SCDividerLineAttachment
 *  分割线 Attachment（直接绘制，不依赖固定宽度的 UIImage）
 *
 *  用于在 NSAttributedString 中绘制一行水平分割线。
 *
 *  特点：
 *  - 宽度在排版时根据文本容器自动计算：容器宽度 - 左右两端间距
 *  - 左右两端间距可独立配置，实现「左边留白 / 右边留白」
 *  - 支持颜色、粗细配置，属性变更时自动失效缓存
 *  - 同时兼容 TextKit 1 / TextKit 2 的取图与直接绘制路径
 */
@interface SCDividerLineAttachment : NSTextAttachment

/// 分割线左端距文本区左边界的间距（pt）
@property (nonatomic, assign) CGFloat leftSpacing;

/// 分割线右端距文本区右边界的间距（pt）
@property (nonatomic, assign) CGFloat rightSpacing;

/// 分割线粗细（pt），默认 1
@property (nonatomic, assign) CGFloat lineThickness;

/// 分割线颜色，默认浅灰
@property (nonatomic, strong, nullable) UIColor *lineColor;

@end

NS_ASSUME_NONNULL_END
