//
//  UIImage+SFSymbol.m
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import "UIImage+SFSymbol.h"


@implementation UIImage (SFSymbol)

/**
 *  @brief 生成完整配置好的SF‑Symbol图片
 *  @param symbolName SF‑Symbol图标名称，例如 @"calendar"
 *  @param tintColor 图标渲染颜色，使用UIImageRenderingModeAlwaysOriginal模式
 *  @param pointSize symbol尺寸大小
 *  @param weight symbol字重 UIImageSymbolWeight
 *  @param scale symbol缩放等级 UIImageSymbolScale
 *  @param fallbackImageName 兜底本地图片名；symbol无效/系统版本过低返回nil时使用；传nil无兜底
 *  @return 处理完成的UIImage，失败返回nil
 */
+ (nullable UIImage *)sf_symbolImageWithName:(NSString *)symbolName
                                   tintColor:(UIColor *)tintColor
                                   pointSize:(CGFloat)pointSize
                                      weight:(UIImageSymbolWeight)weight
                                       scale:(UIImageSymbolScale)scale
                           fallbackImageName:(nullable NSString *)fallbackImageName
{
    // 名称为空，直接返回兜底图
    if (!symbolName.length) {
        return fallbackImageName ? [UIImage imageNamed:fallbackImageName] : nil;
    }
    
    // 获取系统SF‑Symbol原始图片，低版本系统会返回nil
    UIImage *rawImage = [UIImage systemImageNamed:symbolName];
    if (!rawImage) {
        // symbol不支持，返回兜底图片
        return fallbackImageName ? [UIImage imageNamed:fallbackImageName] : nil;
    }
    
    // 组装symbol配置
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight scale:scale];
    // 染色，使用AlwaysOriginal保留自定义颜色，不受控件tintColor影响
    UIImage *renderImage = [rawImage imageWithTintColor:tintColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    // 应用尺寸、字重、缩放配置
    renderImage = [renderImage imageByApplyingSymbolConfiguration:config];
    return renderImage;
}

/**
 *  @brief 便捷默认版本生成SF‑Symbol图片
 *  @discussion 默认参数：pointSize=Inch(12)，weight=Regular，scale=Small，无兜底图
 *  @param symbolName SF‑Symbol图标名称
 *  @param tintColor 图标渲染颜色
 *  @param pointSize symbol尺寸大小
 *  @return 处理完成的UIImage，失败返回nil
 */
+ (nullable UIImage *)sf_defaultSymbolImageWithName:(NSString *)symbolName tintColor:(UIColor *)tintColor pointSize:(CGFloat)pointSize {
    return [self sf_symbolImageWithName:symbolName
                              tintColor:tintColor
                              pointSize:pointSize
                                 weight:UIImageSymbolWeightRegular
                                  scale:UIImageSymbolScaleSmall
                      fallbackImageName:nil];
}
@end
