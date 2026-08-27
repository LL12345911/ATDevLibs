//
//  UIButton+SFSymbol.m
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import "UIButton+SFSymbol.h"
#import <objc/runtime.h>

@implementation UIButton (SFSymbol)

#pragma mark - Associated Object Keys

// 使用静态变量地址作为关联对象的唯一 key，避免字符串碰撞
static const void *kSFSymbolNameKey       = &kSFSymbolNameKey;
static const void *kSFPointSizeKey        = &kSFPointSizeKey;
static const void *kSFWeightKey           = &kSFWeightKey;
static const void *kSFScaleKey            = &kSFScaleKey;
static const void *kSFPaletteEnabledKey   = &kSFPaletteEnabledKey;

#pragma mark - Property Accessors

- (NSString *)sf_symbolName {
    return objc_getAssociatedObject(self, kSFSymbolNameKey);
}

- (void)setSf_symbolName:(NSString *)name {
    objc_setAssociatedObject(self, kSFSymbolNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)sf_pointSize {
    NSNumber *val = objc_getAssociatedObject(self, kSFPointSizeKey);
    return val ? val.doubleValue : 17.0; // 默认 17pt
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

- (BOOL)sf_paletteEnabled {
    NSNumber *val = objc_getAssociatedObject(self, kSFPaletteEnabledKey);
    return val ? val.boolValue : NO;
}

- (void)setSf_paletteEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, kSFPaletteEnabledKey, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Private Helpers

/**
 * @brief 根据参数生成 UIImageSymbolConfiguration
 * @discussion 内部复用，避免各方法重复构建配置对象
 */
- (UIImageSymbolConfiguration *)_sf_configurationWithPointSize:(CGFloat)pointSize
                                                        weight:(UIImageSymbolWeight)weight
                                                         scale:(UIImageSymbolScale)scale {
    return [UIImageSymbolConfiguration configurationWithPointSize:pointSize
                                                           weight:weight
                                                            scale:scale];
}

/**
 * @brief 将生成的 UIImage 应用到指定状态
 */
- (void)_sf_applyImage:(UIImage *)image forState:(UIControlState)state {
    [self setImage:image forState:state];
}

#pragma mark - Instance Methods

- (void)sf_setSymbol:(NSString *)name forState:(UIControlState)state {
    // 委托给完整参数版本，使用当前实例的全局样式
    [self sf_setSymbol:name
              forState:state
             pointSize:self.sf_pointSize
                weight:self.sf_weight
                 scale:self.sf_scale];
}

- (void)sf_setSymbol:(NSString *)name
            forState:(UIControlState)state
           pointSize:(CGFloat)pointSize
              weight:(UIImageSymbolWeight)weight
               scale:(UIImageSymbolScale)scale {
    UIImageSymbolConfiguration *config = [self _sf_configurationWithPointSize:pointSize
                                                                       weight:weight
                                                                        scale:scale];
    UIImage *image = [UIImage systemImageNamed:name withConfiguration:config];
    
    // 仅 Normal 状态记录 symbol 名称，供 palette 等方法回溯
    if (state == UIControlStateNormal) {
        self.sf_symbolName = name;
    }
    
    [self _sf_applyImage:image forState:state];
}

- (void)sf_setSymbolsForStates:(NSDictionary<NSNumber *, NSString *> *)symbolMap {
    [symbolMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *stateNum, NSString *name, BOOL *stop) {
        UIControlState state = (UIControlState)stateNum.unsignedIntegerValue;
        [self sf_setSymbol:name forState:state];
    }];
}

- (void)sf_setPaletteColors:(NSArray<UIColor *> *)colors
                   forState:(UIControlState)state API_AVAILABLE(ios(15.0)) {
    if (@available(iOS 15.0, *)) {
        // 优先使用传入 state 对应的 symbol；若未单独设置则回退到 Normal
        NSString *name = self.sf_symbolName;
        if (!name) return; // 无可用 symbol，静默返回
        
        UIImageSymbolConfiguration *baseConfig = [self _sf_configurationWithPointSize:self.sf_pointSize
                                                                               weight:self.sf_weight
                                                                                scale:self.sf_scale];
        UIImageSymbolConfiguration *paletteConfig =
        [UIImageSymbolConfiguration configurationWithPaletteColors:colors];
        // 合并基础配置与 palette 配置
        UIImageSymbolConfiguration *mergedConfig =
        [baseConfig configurationByApplyingConfiguration:paletteConfig];
        
        UIImage *image = [UIImage systemImageNamed:name withConfiguration:mergedConfig];
        [self _sf_applyImage:image forState:state];
    }
}

#pragma mark - Class Methods

+ (instancetype)sf_buttonWithSymbol:(NSString *)name
                           forState:(UIControlState)state {
    // 委托给完整参数版本，使用系统默认样式
    return [self sf_buttonWithSymbol:name
                            forState:state
                           pointSize:17.0
                              weight:UIImageSymbolWeightMedium
                               scale:UIImageSymbolScaleMedium];
}

+ (instancetype)sf_buttonWithSymbol:(NSString *)name
                           forState:(UIControlState)state
                          pointSize:(CGFloat)pointSize
                             weight:(UIImageSymbolWeight)weight
                              scale:(UIImageSymbolScale)scale {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.sf_pointSize = pointSize;
    button.sf_weight = weight;
    button.sf_scale = scale;
    [button sf_setSymbol:name forState:state];
    return button;
}

+ (instancetype)sf_buttonWithSymbols:(NSDictionary<NSNumber *, NSString *> *)symbolMap
                           pointSize:(CGFloat)pointSize
                              weight:(UIImageSymbolWeight)weight
                               scale:(UIImageSymbolScale)scale {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.sf_pointSize = pointSize;
    button.sf_weight = weight;
    button.sf_scale = scale;
    [button sf_setSymbolsForStates:symbolMap];
    return button;
}

@end
