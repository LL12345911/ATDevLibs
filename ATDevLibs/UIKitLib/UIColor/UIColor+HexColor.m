//
//  UIColor+HexColor.m
//  EngineeringCool
//
//  Created by Mars on 2019/8/21.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

/// 
- (CGFloat)red {
    CGColorRef color = self.CGColor;
    CGFloat const *components = CGColorGetComponents(color);
    if(CGColorSpaceGetModel(CGColorGetColorSpace(color)) == kCGColorSpaceModelMonochrome)
        {
        return components[0];
        }
    else if (CGColorSpaceGetModel(CGColorGetColorSpace(color)) == kCGColorSpaceModelRGB) {
        return components[0];
    }
    
    return -1;
}


- (CGFloat)green {
    CGColorRef color = self.CGColor;
    CGFloat const *components = CGColorGetComponents(color);
    if(CGColorSpaceGetModel(CGColorGetColorSpace(color)) == kCGColorSpaceModelMonochrome)
        {
        return components[0];
        }
    else if (CGColorSpaceGetModel(CGColorGetColorSpace(color)) == kCGColorSpaceModelRGB)
        {
        return components[1];
        }
    return -1;
}


- (CGFloat)blue {
    CGColorRef color = self.CGColor;
    CGFloat const *components = CGColorGetComponents(color);
    if(CGColorSpaceGetModel(CGColorGetColorSpace(color)) == kCGColorSpaceModelMonochrome)
        {
        return components[0];
        }
    else if (CGColorSpaceGetModel(CGColorGetColorSpace(color)) == kCGColorSpaceModelRGB)
        {
        return components[2];
        }
    return -1;
}


- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}


/**
 *  创建一个UIColor实例 使用16进制码
 *
 *  @param hexCode 16进制码
 *
 *  @return UIColor instance
 */
+ (UIColor *)colorWithHexCode:(NSString *)hexCode
{
    NSString *cleanString = [hexCode stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 16) & 0xFF)/255.0f;
    float green = ((baseValue >> 8) & 0xFF)/255.0f;
    float blue = ((baseValue >> 0) & 0xFF)/255.0f;
    
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)colorWithHexCode:(NSString *)hexCode alpha:(CGFloat)alpha
{
    return [[self colorWithHexCode:hexCode] colorWithAlphaComponent:alpha];
}



+ (instancetype)jg_colorHex:(uint32_t)hex {
    return [self jg_colorHex:hex alpha:1.0];
}

+ (instancetype)jg_colorHex:(uint32_t)hex alpha:(CGFloat)alpha {
    u_int8_t red = (0xFF0000 & hex) >> 16;
    u_int8_t green = (0x00FF00 & hex) >> 8;
    u_int8_t blue = (0x0000FF & hex);
    
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}


+ (instancetype)jg_randomColor {
    
    uint32_t r = arc4random_uniform(256);
    uint32_t g = arc4random_uniform(256);
    uint32_t b = arc4random_uniform(256);
    
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}


@end
