//
//  UIColor+HexColor.h
//  EngineeringCool
//
//  Created by Mars on 2019/8/21.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HexColor)

//颜色分量提取，即R,G,B,A，请保证当前颜色域为RGB模式，否则无法获取
@property (nonatomic, assign, readonly) CGFloat red;
@property (nonatomic, assign, readonly) CGFloat green;
@property (nonatomic, assign, readonly) CGFloat blue;
@property (nonatomic, assign, readonly) CGFloat alpha;


/**
 *  创建一个UIColor实例 使用16进制码
 *
 *  @param hexCode 16进制码
 *
 *  @return UIColor instance
 */
+ (UIColor *)colorWithHexCode:(NSString *)hexCode;

+ (UIColor *)colorWithHexCode:(NSString *)hexCode alpha:(CGFloat)alpha;


//[UIColor jg_colorHex:0x333333]
+ (instancetype)jg_colorHex:(uint32_t)hex;

+ (instancetype)jg_colorHex:(uint32_t)hex alpha:(CGFloat)alpha;

/**2019-2-26随机色*/
+ (instancetype)jg_randomColor;

@end

NS_ASSUME_NONNULL_END
