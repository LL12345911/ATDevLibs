//
//  UIColor+HexAlpha.m
//  Demo
//
//  Created by Mars on 2026/1/20.
//  Copyright © 2026 Mars. All rights reserved.
//

#import "UIColor+HexAlpha.h"

@implementation UIColor (HexAlpha)

#pragma mark - 字符串格式颜色创建

+ (UIColor *)colorWithHexAlphaString:(NSString *)hexString {
    if (!hexString || hexString.length == 0) {
        return [UIColor clearColor];
    }
    
    // 删除字符串中的空格和换行符
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // 处理常见的格式前缀
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    } else if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    // 验证长度
    NSUInteger length = cString.length;
    if (length != 6 && length != 8) {
        // NSLog(@"❌ 颜色格式错误: %@，长度应为6或8位", hexString);
        return [UIColor clearColor];
    }
    
    // 检查是否是有效的十六进制字符串
    NSCharacterSet *hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
    for (NSUInteger i = 0; i < cString.length; i++) {
        unichar character = [cString characterAtIndex:i];
        if (![hexCharacterSet characterIsMember:character]) {
            // NSLog(@"❌ 颜色格式错误: %@，包含非十六进制字符", hexString);
            return [UIColor clearColor];
        }
    }
    
    // 解析颜色值
    unsigned int rgbValue = 0;
    unsigned int alphaValue = 255; // 默认不透明度
    
    if (length == 6) {
        // 6位：RRGGBB
        [[NSScanner scannerWithString:cString] scanHexInt:&rgbValue];
    } else if (length == 8) {
        // 8位：RRGGBBAA
        NSString *rgbPart = [cString substringToIndex:6];
        NSString *alphaPart = [cString substringFromIndex:6];
        
        [[NSScanner scannerWithString:rgbPart] scanHexInt:&rgbValue];
        [[NSScanner scannerWithString:alphaPart] scanHexInt:&alphaValue];
    }
    
    // 计算各分量
    CGFloat red = ((rgbValue >> 16) & 0xFF) / 255.0f;
    CGFloat green = ((rgbValue >> 8) & 0xFF) / 255.0f;
    CGFloat blue = (rgbValue & 0xFF) / 255.0f;
    CGFloat alpha = alphaValue / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString format:(HexColorFormat)format {
    if (!hexString || hexString.length == 0) {
        return [UIColor clearColor];
    }
    
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // 移除前缀
    if ([cString hasPrefix:@"0X"] || [cString hasPrefix:@"0x"]) {
        cString = [cString substringFromIndex:2];
    } else if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    NSUInteger length = cString.length;
    
    // 根据格式处理
    switch (format) {
        case HexColorFormat6Digit: {
            if (length != 6) {
                // NSLog(@"❌ 6位颜色格式错误: %@", hexString);
                return [UIColor clearColor];
            }
            return [self colorFrom6DigitHex:cString alpha:1.0];
        }
            
        case HexColorFormat8Digit: {
            if (length != 8) {
                // NSLog(@"❌ 8位颜色格式错误: %@", hexString);
                return [UIColor clearColor];
            }
            return [self colorFrom8DigitHex:cString];
        }
            
        case HexColorFormatARGB: {
            if (length != 8) {
                // NSLog(@"❌ ARGB格式错误: %@", hexString);
                return [UIColor clearColor];
            }
            return [self colorFromARGBHex:cString];
        }
            
        case HexColorFormatAuto:
        default: {
            if (length == 6) {
                return [self colorFrom6DigitHex:cString alpha:1.0];
            } else if (length == 8) {
                // 自动检测是RRGGBBAA还是AARRGGBB
                // 先尝试RRGGBBAA格式
                return [self colorFrom8DigitHex:cString];
            } else {
                // NSLog(@"❌ 自动检测格式错误: %@", hexString);
                return [UIColor clearColor];
            }
        }
    }
}

#pragma mark - 数值格式颜色创建

+ (UIColor *)colorWithHexValue:(CGFloat)hexValue {
    return [self colorWithHexValue:hexValue alpha:1.0f];
}

+ (UIColor *)colorWithHexValue:(CGFloat)hexValue alpha:(CGFloat)alpha {
    // 确保alpha在有效范围内
    alpha = MIN(MAX(alpha, 0.0), 1.0);
    
    // 从CGFloat中提取RGB值
    NSUInteger rgbValue = (NSUInteger)hexValue;
    
    // 验证是否为有效的6位十六进制值
    if (rgbValue > 0xFFFFFF) {
        // NSLog(@"⚠️ 警告: hexValue 0x%lX 可能超出6位范围，将截取后6位", (unsigned long)rgbValue);
        rgbValue = rgbValue & 0xFFFFFF; // 只取后6位
    }
    
    CGFloat red = ((CGFloat)((rgbValue >> 16) & 0xFF)) / 255.0f;
    CGFloat green = ((CGFloat)((rgbValue >> 8) & 0xFF)) / 255.0f;
    CGFloat blue = ((CGFloat)(rgbValue & 0xFF)) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithHexWithAlphaValue:(CGFloat)hexWithAlpha {
    // 从CGFloat中提取RGBA值
    NSUInteger rgbaValue = (NSUInteger)hexWithAlpha;
    
    // 如果小于0x1000000，说明只有6位，没有透明度
    if (rgbaValue < 0x1000000) {
        // NSLog(@"⚠️ 警告: hexWithAlpha 0x%lX 小于7位，将使用默认透明度1.0", (unsigned long)rgbaValue);
        return [self colorWithHexValue:rgbaValue alpha:1.0f];
    }
    
    // 提取各个分量
    CGFloat red = ((CGFloat)((rgbaValue >> 24) & 0xFF)) / 255.0f;
    CGFloat green = ((CGFloat)((rgbaValue >> 16) & 0xFF)) / 255.0f;
    CGFloat blue = ((CGFloat)((rgbaValue >> 8) & 0xFF)) / 255.0f;
    CGFloat alpha = ((CGFloat)(rgbaValue & 0xFF)) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - 其他类型格式颜色创建

+ (UIColor *)colorWithHexInteger:(NSInteger)hexInteger {
    return [self colorWithHexValue:(CGFloat)hexInteger];
}

+ (UIColor *)colorWithHexNumber:(NSNumber *)hexNumber {
    if (!hexNumber) {
        return [UIColor clearColor];
    }
    return [self colorWithHexValue:[hexNumber floatValue]];
}

+ (UIColor *)colorWithAutoDetectHex:(CGFloat)hex {
    NSUInteger hexValue = (NSUInteger)hex;
    
    // 自动检测：如果值大于0xFFFFFF，则认为是8位带透明度的值
    if (hexValue > 0xFFFFFF) {
        return [self colorWithHexWithAlphaValue:hex];
    } else {
        return [self colorWithHexValue:hex];
    }
}

#pragma mark - 批量颜色创建

+ (NSArray<UIColor *> *)colorsWithHexValues:(NSArray<NSNumber *> *)hexValues {
    if (!hexValues || hexValues.count == 0) {
        return @[];
    }
    
    NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:hexValues.count];
    for (NSNumber *hexNumber in hexValues) {
        UIColor *color = [self colorWithHexNumber:hexNumber];
        [colors addObject:color];
    }
    
    return [colors copy];
}

+ (NSArray<UIColor *> *)colorsWithHexStrings:(NSArray<NSString *> *)hexStrings {
    if (!hexStrings || hexStrings.count == 0) {
        return @[];
    }
    
    NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:hexStrings.count];
    for (NSString *hexString in hexStrings) {
        UIColor *color = [self colorWithHexAlphaString:hexString];
        [colors addObject:color];
    }
    
    return [colors copy];
}

#pragma mark - 常用颜色快捷方法（字符串版）

+ (UIColor *)efefefColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEFFF"];
}

+ (UIColor *)efefefColorWithAlpha:(CGFloat)alpha {
    UIColor *baseColor = [UIColor colorWithHexAlphaString:@"#EFEFEFFF"];
    if (alpha >= 0 && alpha <= 1) {
        return [baseColor colorWithAlphaComponent:alpha];
    }
    return baseColor;
}

#pragma mark - 常用颜色快捷方法（数值版）

+ (UIColor *)efefefHexColor {
    return [self colorWithHexValue:0xEFEFEF];
}

+ (UIColor *)efefefWithAlphaHexColor {
    return [self colorWithHexWithAlphaValue:0xEFEFEFFF];
}

+ (UIColor *)efefefHexColorWithAlpha:(CGFloat)alpha {
    return [self colorWithHexValue:0xEFEFEF alpha:alpha];
}

#pragma mark - 系统常用颜色扩展

+ (UIColor *)lightGrayBackgroundColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEFFF"];
}

+ (UIColor *)lightGrayBackgroundColorWithAlpha:(CGFloat)alpha {
    return [UIColor efefefColorWithAlpha:alpha];
}

+ (UIColor *)borderColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEF80"];
}

+ (UIColor *)lightBorderColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEF40"];
}

+ (UIColor *)separatorColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEF"];
}

+ (UIColor *)lightSeparatorColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEF20"];
}

+ (UIColor *)shadowColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEF60"];
}

+ (UIColor *)shadowColorWithAlpha:(CGFloat)alpha {
    UIColor *baseColor = [UIColor colorWithHexAlphaString:@"#EFEFEF"];
    return [baseColor colorWithAlphaComponent:alpha];
}

+ (UIColor *)disabledColor {
    return [UIColor colorWithHexAlphaString:@"#EFEFEFA0"];
}

#pragma mark - 工具方法

- (BOOL)isLightColor {
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    // 使用W3C推荐的亮度计算公式
    CGFloat brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000;
    return brightness > 0.5;
}

- (NSString *)hexStringWithAlpha:(BOOL)includeAlpha {
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    if (includeAlpha) {
        return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
                lroundf(red * 255),
                lroundf(green * 255),
                lroundf(blue * 255),
                lroundf(alpha * 255)];
    } else {
        return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                lroundf(red * 255),
                lroundf(green * 255),
                lroundf(blue * 255)];
    }
}

- (NSString *)hexString {
    return [self hexStringWithAlpha:YES];
}

- (NSUInteger)hexValueWithAlpha:(BOOL)includeAlpha {
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSUInteger r = lroundf(red * 255);
    NSUInteger g = lroundf(green * 255);
    NSUInteger b = lroundf(blue * 255);
    NSUInteger a = lroundf(alpha * 255);
    
    if (includeAlpha) {
        return (r << 24) | (g << 16) | (b << 8) | a;
    } else {
        return (r << 16) | (g << 8) | b;
    }
}

- (CGFloat)brightness {
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    // 计算亮度 (HSL模型)
    CGFloat max = MAX(MAX(red, green), blue);
    CGFloat min = MIN(MIN(red, green), blue);
    return (max + min) / 2.0;
}

- (UIColor *)contrastingColor {
    if ([self isLightColor]) {
        return [UIColor blackColor];
    } else {
        return [UIColor whiteColor];
    }
}

- (UIColor *)lighterColorWithFactor:(CGFloat)factor {
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    // 确保factor在有效范围内
    factor = MIN(MAX(factor, 0.0), 1.0);
    
    // 增加亮度
    red = MIN(red + (1.0 - red) * factor, 1.0);
    green = MIN(green + (1.0 - green) * factor, 1.0);
    blue = MIN(blue + (1.0 - blue) * factor, 1.0);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)darkerColorWithFactor:(CGFloat)factor {
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    // 确保factor在有效范围内
    factor = MIN(MAX(factor, 0.0), 1.0);
    
    // 减小亮度
    red = MAX(red * (1.0 - factor), 0.0);
    green = MAX(green * (1.0 - factor), 0.0);
    blue = MAX(blue * (1.0 - factor), 0.0);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - 私有方法

+ (UIColor *)colorFrom6DigitHex:(NSString *)hexString alpha:(CGFloat)alpha {
    unsigned int rgbValue = 0;
    [[NSScanner scannerWithString:hexString] scanHexInt:&rgbValue];
    
    CGFloat red = ((rgbValue >> 16) & 0xFF) / 255.0f;
    CGFloat green = ((rgbValue >> 8) & 0xFF) / 255.0f;
    CGFloat blue = (rgbValue & 0xFF) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorFrom8DigitHex:(NSString *)hexString {
    NSString *rgbPart = [hexString substringToIndex:6];
    NSString *alphaPart = [hexString substringFromIndex:6];
    
    unsigned int rgbValue = 0;
    unsigned int alphaValue = 0;
    
    [[NSScanner scannerWithString:rgbPart] scanHexInt:&rgbValue];
    [[NSScanner scannerWithString:alphaPart] scanHexInt:&alphaValue];
    
    CGFloat red = ((rgbValue >> 16) & 0xFF) / 255.0f;
    CGFloat green = ((rgbValue >> 8) & 0xFF) / 255.0f;
    CGFloat blue = (rgbValue & 0xFF) / 255.0f;
    CGFloat alpha = alphaValue / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorFromARGBHex:(NSString *)hexString {
    NSString *alphaPart = [hexString substringToIndex:2];
    NSString *rgbPart = [hexString substringFromIndex:2];
    
    unsigned int alphaValue = 0;
    unsigned int rgbValue = 0;
    
    [[NSScanner scannerWithString:alphaPart] scanHexInt:&alphaValue];
    [[NSScanner scannerWithString:rgbPart] scanHexInt:&rgbValue];
    
    CGFloat red = ((rgbValue >> 16) & 0xFF) / 255.0f;
    CGFloat green = ((rgbValue >> 8) & 0xFF) / 255.0f;
    CGFloat blue = (rgbValue & 0xFF) / 255.0f;
    CGFloat alpha = alphaValue / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
