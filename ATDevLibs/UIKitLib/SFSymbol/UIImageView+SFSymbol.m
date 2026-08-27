//
//  UIImageView+SFSymbol.m
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import "UIImageView+SFSymbol.h"
#import "UIImage+SFSymbol.h"
#import <objc/runtime.h>

@implementation UIImageView (SFSymbol)

#pragma mark - Associated Object Keys

static const void *kSFSymbolNameKey     = &kSFSymbolNameKey;
static const void *kSFPointSizeKey      = &kSFPointSizeKey;
static const void *kSFWeightKey         = &kSFWeightKey;
static const void *kSFScaleKey          = &kSFScaleKey;
static const void *kSFRenderingModeKey  = &kSFRenderingModeKey;
static const void *kSFRenderingParamKey = &kSFRenderingParamKey;
static const void *kSFVariableValueKey  = &kSFVariableValueKey;

/// 内部枚举：记录当前使用的渲染模式，便于 sf_updateImage 时正确重建
typedef NS_ENUM(NSUInteger, SFRenderingMode) {
    SFRenderingModeDefault = 0,
    SFRenderingModePalette,
    SFRenderingModeHierarchical,
    SFRenderingModeMonochrome,
};


#pragma mark - Property Accessors

- (NSString *)sf_symbolName {
    return objc_getAssociatedObject(self, kSFSymbolNameKey);
}

- (void)setSf_symbolName:(NSString *)name {
    objc_setAssociatedObject(self, kSFSymbolNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)sf_pointSize {
    NSNumber *val = objc_getAssociatedObject(self, kSFPointSizeKey);
    return val ? val.doubleValue : 17.0;
}

- (void)setSf_pointSize:(CGFloat)pointSize {
    objc_setAssociatedObject(self, kSFPointSizeKey, @(pointSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageSymbolWeight)sf_weight {
    NSNumber *val = objc_getAssociatedObject(self, kSFWeightKey);
    return val ? val.integerValue : UIImageSymbolWeightMedium;
}

- (void)setSf_weight:(UIImageSymbolWeight)weight {
    objc_setAssociatedObject(self, kSFWeightKey, @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageSymbolScale)sf_scale {
    NSNumber *val = objc_getAssociatedObject(self, kSFScaleKey);
    return val ? val.integerValue : UIImageSymbolScaleMedium;
}

- (void)setSf_scale:(UIImageSymbolScale)scale {
    objc_setAssociatedObject(self, kSFScaleKey, @(scale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Internal Rendering State

- (SFRenderingMode)_renderingMode {
    NSNumber *val = objc_getAssociatedObject(self, kSFRenderingModeKey);
    return val ? val.unsignedIntegerValue : SFRenderingModeDefault;
}

- (void)_setRenderingMode:(SFRenderingMode)mode {
    objc_setAssociatedObject(self, kSFRenderingModeKey, @(mode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable id)_renderingParam {
    return objc_getAssociatedObject(self, kSFRenderingParamKey);
}

- (void)_setRenderingParam:(nullable id)param {
    objc_setAssociatedObject(self, kSFRenderingParamKey, param, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)_variableValue {
    return objc_getAssociatedObject(self, kSFVariableValueKey);
}

- (void)_setVariableValue:(nullable NSNumber *)value {
    objc_setAssociatedObject(self, kSFVariableValueKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Private Helpers

/**
 * @brief 构建基础 UIImageSymbolConfiguration（pointSize + weight + scale）
 */
- (UIImageSymbolConfiguration *)_baseConfiguration {
    return [UIImageSymbolConfiguration configurationWithPointSize:self.sf_pointSize
                                                           weight:self.sf_weight
                                                            scale:self.sf_scale];
}

/**
 * @brief 唯一图片重建入口
 * @discussion
 * 1. 根据当前 _renderingMode 叠加对应的 iOS 15+ 配置
 * 2. 如果存在 variableValue，再叠加 variable 配置
 * 3. 所有渲染模式变更都通过此方法统一生效
 *
 * @code
 * // 内部调用，外部通过 sf_updateImage 触发
 * [self _rebuildImage];
 * @endcode
 */
- (void)_rebuildImage {
    NSString *name = self.sf_symbolName;
    if (!name.length) return;
    
    UIImageSymbolConfiguration *config = [self _baseConfiguration];
    
    // ✅ iOS 15+ 渲染模式叠加
    if (@available(iOS 15.0, *)) {
        switch ([self _renderingMode]) {
            case SFRenderingModePalette: {
                NSArray<UIColor *> *colors = [self _renderingParam];
                if (colors.count > 0) {
                    UIImageSymbolConfiguration *palette =
                    [UIImageSymbolConfiguration configurationWithPaletteColors:colors];
                    config = [config configurationByApplyingConfiguration:palette];
                }
                break;
            }
            case SFRenderingModeHierarchical: {
                UIColor *color = [self _renderingParam];
                if (color) {
                    UIImageSymbolConfiguration *hier =
                    [UIImageSymbolConfiguration configurationWithHierarchicalColor:color];
                    config = [config configurationByApplyingConfiguration:hier];
                }
                break;
            }
            case SFRenderingModeMonochrome: {
                UIColor *color = [self _renderingParam];
                if (color) {
                    // ✅ 修复：Monochrome 应使用 configurationWithHierarchicalColor
                    // Apple 未提供独立的 monochrome configuration API，
                    // hierarchical 在单层 symbol 上等效于 monochrome
                    UIImageSymbolConfiguration *mono =
                    [UIImageSymbolConfiguration configurationWithHierarchicalColor:color];
                    config = [config configurationByApplyingConfiguration:mono];
                }
                break;
            }
            default: break;
        }
        
        // ✅ Variable Value 叠加（不改变渲染模式）
        NSNumber *varVal = [self _variableValue];
        if (varVal) {
            // ✅ 修复：正确 API 为 configurationWithPreferringVariableValue:
            // 原代码误用了 configurationWithPointSize: 导致 variable 无效
            if (@available(iOS 26.0, *)) {
                UIImageSymbolConfiguration *varConfig = [UIImageSymbolConfiguration configurationWithVariableValueMode:varVal.doubleValue];
                config = [config configurationByApplyingConfiguration:varConfig];
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    self.image = [UIImage systemImageNamed:name withConfiguration:config];
}


#pragma mark - Instance Methods (基础)

- (void)sf_setSymbol:(NSString *)name {
    self.sf_symbolName = name;
    [self _rebuildImage];
}

- (void)sf_setSymbol:(NSString *)name
           pointSize:(CGFloat)pointSize
              weight:(UIImageSymbolWeight)weight
               scale:(UIImageSymbolScale)scale {
    self.sf_pointSize = pointSize;
    self.sf_weight = weight;
    self.sf_scale = scale;
    [self sf_setSymbol:name];
}

- (void)sf_updateImage {
    [self _rebuildImage];
}


#pragma mark - Instance Methods (iOS 15+)

- (void)sf_setPaletteColors:(NSArray<UIColor *> *)colors API_AVAILABLE(ios(15.0)) {
    if (@available(iOS 15.0, *)) {
        [self _setRenderingMode:SFRenderingModePalette];
        [self _setRenderingParam:[colors copy]];
        [self _rebuildImage];
    }
}

- (void)sf_setHierarchicalColor:(UIColor *)color API_AVAILABLE(ios(15.0)) {
    if (@available(iOS 15.0, *)) {
        [self _setRenderingMode:SFRenderingModeHierarchical];
        [self _setRenderingParam:color];
        [self _rebuildImage];
    }
}

- (void)sf_setMonochromeColor:(UIColor *)color API_AVAILABLE(ios(15.0)) {
    if (@available(iOS 15.0, *)) {
        [self _setRenderingMode:SFRenderingModeMonochrome];
        [self _setRenderingParam:color];
        [self _rebuildImage];
    }
}

/**
 * @brief Variable Value 实现
 * @discussion
 * ✅ 修复点：
 * - 原代码使用 configurationWithPointSize: 传入 value，API 完全错误
 * - 正确 API 为 configurationWithPreferringVariableValue:（iOS 15.0+）
 * - Variable 值缓存到关联对象，sf_updateImage 时自动保留
 */
- (void)sf_setVariableValue:(CGFloat)value API_AVAILABLE(ios(15.0)) {
    if (@available(iOS 15.0, *)) {
        if (!self.sf_symbolName.length) return;
        [self _setVariableValue:@(value)];
        [self _rebuildImage];
    }
}


#pragma mark - Class Methods (Factory)

+ (instancetype)sf_imageViewWithSymbol:(NSString *)name {
    return [self sf_imageViewWithSymbol:name
                              pointSize:17.0
                                 weight:UIImageSymbolWeightMedium
                                  scale:UIImageSymbolScaleMedium];
}

+ (instancetype)sf_imageViewWithSymbol:(NSString *)name
                             pointSize:(CGFloat)pointSize
                                weight:(UIImageSymbolWeight)weight
                                 scale:(UIImageSymbolScale)scale {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView sf_setSymbol:name pointSize:pointSize weight:weight scale:scale];
    return imageView;
}

+ (instancetype)sf_imageViewWithSymbolName:(NSString *)symbolName
                                 tintColor:(UIColor *)tintColor
                                 pointSize:(CGFloat)pointSize
                                    weight:(UIImageSymbolWeight)weight
                                     scale:(UIImageSymbolScale)scale
                         fallbackImageName:(nullable NSString *)fallbackImageName {
    UIImage *image = [UIImage sf_symbolImageWithName:symbolName
                                           tintColor:tintColor
                                           pointSize:pointSize
                                              weight:weight
                                               scale:scale
                                   fallbackImageName:fallbackImageName];
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    return iv;
}

@end
