//
//  AttributeStringBuilder.h
//  EngineeringCool
//
//  Created by Mars on 2022/3/28.
//  Copyright © 2022 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AttributeStringBuilder : NSObject

/// 添加内容
- (AttributeStringBuilder * (^)(NSString *attribute))text;
/// 字体
- (AttributeStringBuilder * (^)(UIFont *attribute))font;
/// 斜体
- (AttributeStringBuilder * (^)(CGFloat attribute))skew;
/// 文字颜色
- (AttributeStringBuilder * (^)(UIColor *attribute))color;
/// 文字背景色
- (AttributeStringBuilder * (^)(UIColor *attribute))mark;
/// 下划线
- (AttributeStringBuilder * (^)(UIColor *attribute))underscore;
/// 删除线
- (AttributeStringBuilder * (^)(UIColor *attribute))strikethrough;
/// 字间距
- (AttributeStringBuilder * (^)(CGFloat attribute))wordSpacing;
/// 图片
- (AttributeStringBuilder * (^)(UIImage *attribute, CGSize size, CGFloat y))image;
/// 换行
- (AttributeStringBuilder * (^)(NSUInteger attribute))wrap;
/// 对齐方式
- (AttributeStringBuilder * (^)(NSTextAlignment attribute))aligment;
/// 分割方式
- (AttributeStringBuilder * (^)(NSLineBreakMode attribute))breakMode;
/// 缩进
- (AttributeStringBuilder * (^)(CGFloat attribute))lineIndent;
/// 行间距
- (AttributeStringBuilder * (^)(CGFloat attribute))lineSpacing;
/// 段间距
- (AttributeStringBuilder * (^)(CGFloat attribute))segmentSpacing;
/// 超链接
- (AttributeStringBuilder * (^)(NSString *url))link;
/// 整体行间距
- (void)setLineSpacing:(CGFloat)spacing;
/// 整体段间距
- (void)setSegmentSpacing:(CGFloat)spacing;

/// 生成当前节点字符串
- (void (^)(void))commit;
/// 当前节点如右图则显示在文字前面
- (void (^)(void))commitImagePriority;
/// 最终字符串
- (NSAttributedString *)result;

@end

NS_ASSUME_NONNULL_END
