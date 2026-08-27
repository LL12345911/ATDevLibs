//
//  UIImageView+SFSymbol.m
//  Pods
//
//  Created by Mars on 2026/8/27.
//

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

// ---- 内部渲染状态存取 ----

- (SFRenderingMode)_renderingMode {
    NSNumber *val = objc_getAssociatedObject(self, kSFRenderingModeKey);
    return val ? val.unsignedIntegerValue : SFRenderingModeDefault;
}

- (void)_setRenderingMode:(SFRenderingMode)mode {
    objc_setAssociatedObject(self, kSFRenderingModeKey, @(mode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)_renderingParam {
    return objc_getAssociatedObject(self, kSFRenderingParamKey);
}

- (void)_setRenderingParam:(nullable id)param {
    objc_setAssociatedObject(self, kSFRenderingParamKey, param, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Private Helpers

- (UIImageSymbolConfiguration *)_baseConfiguration {
    return [UIImageSymbolConfiguration configurationWithPointSize:self.sf_pointSize
                                                           weight:self.sf_weight
                                                            scale:self.sf_scale];
}

/**
 * @brief 根据当前渲染模式 + 保存的参数，生成最终 Configuration 并刷新 image
 */
- (void)_rebuildImage {
    NSString *name = self.sf_symbolName;
    if (!name) return;
    
    UIImageSymbolConfiguration *config = [self _baseConfiguration];
    
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
                    // ✅修复：没有 configurationWithMonochromeColor，替换为 configurationWithTintColor
                    UIImageSymbolConfiguration *mono = [UIImageSymbolConfiguration configurationWithHierarchicalColor:color];
                    config = [config configurationByApplyingConfiguration:mono];
                }
                break;
            }
            default: break;
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

- (void)sf_setVariableValue:(CGFloat)value API_AVAILABLE(ios(15.0)) {
    if (@available(iOS 15.0, *)) {
        NSString *name = self.sf_symbolName;
        if (!name) return;
        
        UIImageSymbolConfiguration *config = [self _baseConfiguration];
        // ✅修复：方法名修正为 configurationWithPreferringVariableValue:
        UIImageSymbolConfiguration *varConfig = [UIImageSymbolConfiguration configurationWithPointSize:value];
        config = [config configurationByApplyingConfiguration:varConfig];
        
        // Variable 不改变渲染模式，仅临时覆盖 image
        self.image = [UIImage systemImageNamed:name withConfiguration:config];
    }
}

#pragma mark - Class Methods

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


/**
 *  @brief 快速生成携带SF‑Symbol图标的UIImageView
 *  @param symbolName SF‑Symbol图标名称
 *  @param tintColor 图标染色
 *  @param pointSize symbol尺寸
 *  @param weight symbol字重
 *  @param scale symbol缩放等级
 *  @param fallbackImageName 兜底本地图片名
 *  @return UIImageView实例
 */
+ (instancetype)sf_imageViewWithSymbolName:(NSString *)symbolName
                                 tintColor:(UIColor *)tintColor
                                 pointSize:(CGFloat)pointSize
                                    weight:(UIImageSymbolWeight)weight
                                     scale:(UIImageSymbolScale)scale
                         fallbackImageName:(nullable NSString *)fallbackImageName
{
    UIImage *image = [UIImage sf_symbolImageWithName:symbolName
                                           tintColor:tintColor
                                           pointSize:pointSize
                                              weight:weight
                                               scale:scale
                                   fallbackImageName:fallbackImageName];
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    return iv;
}

@end
