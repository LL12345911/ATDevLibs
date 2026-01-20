//
//  UIColor+HexAlpha.h
//  Demo
//
//  Created by Mars on 2026/1/20.
//  Copyright © 2026 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

// 颜色类型枚举
typedef NS_ENUM(NSInteger, HexColorFormat) {
    HexColorFormatAuto,      // 自动检测
    HexColorFormat6Digit,    // 强制6位
    HexColorFormat8Digit,    // 强制8位
    HexColorFormatARGB       // ARGB格式
};

@interface UIColor (HexAlpha)

#pragma mark - 字符串格式颜色创建

/**
 创建颜色，支持多种格式
 
 @param hexString 颜色字符串，支持格式：
 #EFEFEF    - 6位，不带透明度
 #EFEFEFFF  - 8位，带透明度
 0xEFEFEF   - 6位，不带透明度
 0xEFEFEFFF - 8位，带透明度
 @return UIColor对象
 */
+ (UIColor *)colorWithHexAlphaString:(NSString *)hexString;

/**
 创建颜色，支持多种格式
 
 @param hexString 颜色字符串，支持格式：
 #EFEFEF    - 6位，不带透明度
 #EFEFEFFF  - 8位，带透明度
 0xEFEFEF   - 6位，不带透明度
 0xEFEFEFFF - 8位，带透明度
 @param format 颜色格式
 @return UIColor对象
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString format:(HexColorFormat)format;

#pragma mark - 数值格式颜色创建

/**
 通过CGFloat值创建颜色（十六进制整数转颜色）
 
 @param hexValue 十六进制整数值
 示例: 0xEFEFEF, 0xFF0000
 @return UIColor对象
 */
+ (UIColor *)colorWithHexValue:(CGFloat)hexValue;

/**
 通过CGFloat值创建颜色，指定透明度
 
 @param hexValue 十六进制整数值
 示例: 0xEFEFEF, 0xFF0000
 @param alpha 透明度 (0.0 - 1.0)
 @return UIColor对象
 */
+ (UIColor *)colorWithHexValue:(CGFloat)hexValue alpha:(CGFloat)alpha;

/**
 通过CGFloat值创建颜色，支持8位带透明度的值
 
 @param hexWithAlpha 8位十六进制整数值（包含透明度）
 示例: 0xEFEFEFFF, 0xFF0000FF
 @return UIColor对象
 */
+ (UIColor *)colorWithHexWithAlphaValue:(CGFloat)hexWithAlpha;

#pragma mark - 其他类型格式颜色创建

/**
 从NSInteger创建颜色
 
 @param hexInteger 十六进制整数值
 示例: 0xEFEFEF, 0xFF0000
 @return UIColor对象
 */
+ (UIColor *)colorWithHexInteger:(NSInteger)hexInteger;

/**
 从NSNumber创建颜色
 
 @param hexNumber 十六进制数值
 示例: @(0xEFEFEF), @(0xFF0000)
 @return UIColor对象
 */
+ (UIColor *)colorWithHexNumber:(NSNumber *)hexNumber;

/**
 从十六进制整数创建颜色，自动检测是否包含透明度
 
 @param hex 十六进制数值
 @return UIColor对象
 */
+ (UIColor *)colorWithAutoDetectHex:(CGFloat)hex;

#pragma mark - 批量颜色创建

/**
 批量创建颜色数组
 
 @param hexValues 十六进制值数组
 示例: @[@(0xEFEFEF), @(0xFF0000), @(0x00FF00)]
 @return UIColor对象数组
 */
+ (NSArray<UIColor *> *)colorsWithHexValues:(NSArray<NSNumber *> *)hexValues;

/**
 批量创建颜色数组（从字符串）
 
 @param hexStrings 十六进制字符串数组
 示例: @[@"#EFEFEF", @"#FF0000", @"#00FF00"]
 @return UIColor对象数组
 */
+ (NSArray<UIColor *> *)colorsWithHexStrings:(NSArray<NSString *> *)hexStrings;

#pragma mark - 常用颜色快捷方法（字符串版）

/**
 快捷方法：使用#EFEFEFFF颜色
 */
+ (UIColor *)efefefColor;

/**
 快捷方法：使用#EFEFEFFF颜色，可自定义透明度
 
 @param alpha 透明度 (0.0 - 1.0)
 @return UIColor对象
 */
+ (UIColor *)efefefColorWithAlpha:(CGFloat)alpha;

#pragma mark - 常用颜色快捷方法（数值版）

/**
 快捷方法：使用0xEFEFEF颜色
 */
+ (UIColor *)efefefHexColor;

/**
 快捷方法：使用0xEFEFEFFF颜色（带透明度）
 */
+ (UIColor *)efefefWithAlphaHexColor;

/**
 快捷方法：使用0xEFEFEF颜色，可自定义透明度
 
 @param alpha 透明度 (0.0 - 1.0)
 @return UIColor对象
 */
+ (UIColor *)efefefHexColorWithAlpha:(CGFloat)alpha;

#pragma mark - 系统常用颜色扩展

// 浅灰色背景
+ (UIColor *)lightGrayBackgroundColor;           // #EFEFEFFF
+ (UIColor *)lightGrayBackgroundColorWithAlpha:(CGFloat)alpha;

// 边框颜色
+ (UIColor *)borderColor;                        // #EFEFEF80 (50%透明度)
+ (UIColor *)lightBorderColor;                   // #EFEFEF40 (25%透明度)

// 分隔线颜色
+ (UIColor *)separatorColor;                     // #EFEFEF
+ (UIColor *)lightSeparatorColor;                // #EFEFEF20 (12.5%透明度)

// 阴影颜色
+ (UIColor *)shadowColor;                        // #EFEFEF60 (37.5%透明度)
+ (UIColor *)shadowColorWithAlpha:(CGFloat)alpha;

// 禁用状态颜色
+ (UIColor *)disabledColor;                      // #EFEFEFA0 (62.5%透明度)

#pragma mark - 工具方法

/**
 判断颜色是否为浅色
 
 @return YES-浅色，NO-深色
 */
- (BOOL)isLightColor;

/**
 获取颜色的十六进制字符串表示
 
 @param includeAlpha 是否包含透明度
 @return 十六进制字符串
 */
- (NSString *)hexStringWithAlpha:(BOOL)includeAlpha;

/**
 获取颜色的十六进制字符串表示（默认包含透明度）
 
 @return 十六进制字符串
 */
- (NSString *)hexString;

/**
 获取颜色的十六进制整数值
 
 @param includeAlpha 是否包含透明度
 @return 十六进制整数值
 */
- (NSUInteger)hexValueWithAlpha:(BOOL)includeAlpha;

/**
 获取颜色的亮度值 (0.0 - 1.0)
 
 @return 亮度值
 */
- (CGFloat)brightness;

/**
 获取颜色的对比色（黑白反色）
 
 @return 对比颜色
 */
- (UIColor *)contrastingColor;

/**
 创建比当前颜色更浅的颜色
 
 @param factor 变浅系数 (0.0 - 1.0)
 @return 更浅的颜色
 */
- (UIColor *)lighterColorWithFactor:(CGFloat)factor;

/**
 创建比当前颜色更深的颜色
 
 @param factor 变深系数 (0.0 - 1.0)
 @return 更深的颜色
 */
- (UIColor *)darkerColorWithFactor:(CGFloat)factor;

@end
