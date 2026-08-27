//
//  UIImage+SFSymbol.h
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SFSymbol)

/**
 *  @brief 生成完整配置好的SF‑Symbol图片
 *  @param symbolName SF‑Symbol图标名称，例如 @"calendar"
 *  @param tintColor 图标渲染颜色，使用UIImageRenderingModeAlwaysOriginal模式
 *  @param pointSize symbol尺寸大小
 *  @param weight symbol字重 UIImageSymbolWeight
 *  @param scale symbol缩放等级 UIImageSymbolScale
 *  @param fallbackImageName 兜底本地图片名；symbol无效/系统版本过低返回nil时使用；传nil无兜底
 *  @return 处理完成的UIImage，失败返回nil
 *
 *  @code
 UIImage *img = [UIImage sf_symbolImageWithName:@"heart" tintColor:[UIColor redColor] pointSize:20 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleDefault fallbackImageName:@"icon_heart_default"];
 *  @endcode
 */
+ (nullable UIImage *)sf_symbolImageWithName:(NSString *)symbolName
                                   tintColor:(UIColor *)tintColor
                                   pointSize:(CGFloat)pointSize
                                      weight:(UIImageSymbolWeight)weight
                                       scale:(UIImageSymbolScale)scale
                           fallbackImageName:(nullable NSString *)fallbackImageName API_AVAILABLE(ios(13.0));

/**
 *  @brief 便捷默认版本生成SF‑Symbol图片
 *  @discussion 默认参数：pointSize=Inch(12)，weight=Regular，scale=Small，无兜底图
 *  @param symbolName SF‑Symbol图标名称
 *  @param tintColor 图标渲染颜色
 *  @param pointSize symbol尺寸大小
 *  @return 处理完成的UIImage，失败返回nil
 *
 *  @code
 UIImage *img = [UIImage sf_defaultSymbolImageWithName:@"search" tintColor:[UIColor blueColor] pointSize:20];
 *  @endcode
 */
+ (nullable UIImage *)sf_defaultSymbolImageWithName:(NSString *)symbolName tintColor:(UIColor *)tintColor pointSize:(CGFloat)pointSize;


@end

NS_ASSUME_NONNULL_END

