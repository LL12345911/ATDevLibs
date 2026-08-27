//
//  UIButton+SFSymbol.m
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import "UIButton+SFSymbol.h"
#import <objc/runtime.h>

#pragma mark - Constants

NSString * const SFSymbolConfigKeyName      = @"sf_symbol_name";
NSString * const SFSymbolConfigKeyTintColor = @"sf_symbol_tintColor";
NSString * const SFSymbolConfigKeyWeight    = @"sf_symbol_weight";
NSString * const SFSymbolConfigKeyScale     = @"sf_symbol_scale";


@implementation UIButton (SFSymbol)

#pragma mark - Associated Keys

static const void *kSFSymbolNameKey      = &kSFSymbolNameKey;
static const void *kSFPointSizeKey       = &kSFPointSizeKey;
static const void *kSFWeightKey          = &kSFWeightKey;
static const void *kSFScaleKey           = &kSFScaleKey;
static const void *kSFTintColorKey       = &kSFTintColorKey;
static const void *kSFPaletteEnabledKey  = &kSFPaletteEnabledKey;
static const void *kSFStateTintColorsKey = &kSFStateTintColorsKey;
static const void *kSFStateConfigsKey    = &kSFStateConfigsKey;
static const void *kSFStateNamesKey      = &kSFStateNamesKey;


#pragma mark - Property Accessors

- (NSString *)sf_symbolName {
    return objc_getAssociatedObject(self, kSFSymbolNameKey);
}

- (void)setSf_symbolName:(NSString *)n {
    objc_setAssociatedObject(self, kSFSymbolNameKey, n, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)sf_pointSize {
    NSNumber *v = objc_getAssociatedObject(self, kSFPointSizeKey);
    return v ? v.doubleValue : 17.0;
}

- (void)setSf_pointSize:(CGFloat)p {
    objc_setAssociatedObject(self, kSFPointSizeKey, @(p), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageSymbolWeight)sf_weight {
    NSNumber *v = objc_getAssociatedObject(self, kSFWeightKey);
    return v ? v.integerValue : UIImageSymbolWeightMedium;
}

- (void)setSf_weight:(UIImageSymbolWeight)w {
    objc_setAssociatedObject(self, kSFWeightKey, @(w), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageSymbolScale)sf_scale {
    NSNumber *v = objc_getAssociatedObject(self, kSFScaleKey);
    return v ? v.integerValue : UIImageSymbolScaleMedium;
}

- (void)setSf_scale:(UIImageSymbolScale)s {
    objc_setAssociatedObject(self, kSFScaleKey, @(s), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)sf_tintColor {
    return objc_getAssociatedObject(self, kSFTintColorKey);
}

- (void)setSf_tintColor:(UIColor *)c {
    objc_setAssociatedObject(self, kSFTintColorKey, c, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sf_paletteEnabled {
    NSNumber *v = objc_getAssociatedObject(self, kSFPaletteEnabledKey);
    return v ? v.boolValue : NO;
}

- (void)setSf_paletteEnabled:(BOOL)e {
    objc_setAssociatedObject(self, kSFPaletteEnabledKey, @(e), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Internal Storage (Lazy Init)

/// 每个状态的独立 tintColor 缓存
- (NSMutableDictionary<NSNumber *, UIColor *> *)_sf_stateTintColors {
    NSMutableDictionary *d = objc_getAssociatedObject(self, kSFStateTintColorsKey);
    if (!d) {
        d = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, kSFStateTintColorsKey, d, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return d;
}

/// 每个状态的 UIImageSymbolConfiguration 缓存（供 reload / setTintColor 复用）
- (NSMutableDictionary<NSNumber *, UIImageSymbolConfiguration *> *)_sf_stateConfigs {
    NSMutableDictionary *d = objc_getAssociatedObject(self, kSFStateConfigsKey);
    if (!d) {
        d = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, kSFStateConfigsKey, d, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return d;
}

/// 每个状态的 Symbol name 缓存（供 reload 重建图片）
- (NSMutableDictionary<NSNumber *, NSString *> *)_sf_stateNames {
    NSMutableDictionary *d = objc_getAssociatedObject(self, kSFStateNamesKey);
    if (!d) {
        d = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, kSFStateNamesKey, d, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return d;
}


#pragma mark - Core Generation

/**
 * @brief 构建 UIImageSymbolConfiguration
 * @discussion 统一入口，避免散落在各处的重复构造代码
 */
- (UIImageSymbolConfiguration *)_sf_configWithPointSize:(CGFloat)ps
                                                 weight:(UIImageSymbolWeight)w
                                                  scale:(UIImageSymbolScale)s {
    return [UIImageSymbolConfiguration configurationWithPointSize:ps weight:w scale:s];
}

/**
 * @brief 唯一图片生成入口
 * @discussion
 * - config 传 nil 时自动使用当前全局属性构建（防御性兜底）
 * - 始终使用 UIImageRenderingModeAlwaysOriginal 防止系统二次着色覆盖
 * - Palette 模式下跳过 tintColor 逻辑
 *
 * @code
 * UIImage *img = [self _sf_imageWithName:@"heart.fill"
 *                              tintColor:UIColor.redColor
 *                          configuration:config];
 * @endcode
 */
- (UIImage *)_sf_imageWithName:(NSString *)name
                     tintColor:(nullable UIColor *)tintColor
                 configuration:(nullable UIImageSymbolConfiguration *)config {
    if (!name.length) return nil;
    
    // ✅ 防御性兜底：config 为 nil 时使用当前全局属性
    if (!config) {
        config = [self _sf_configWithPointSize:self.sf_pointSize
                                        weight:self.sf_weight
                                         scale:self.sf_scale];
    }
    
    UIImage *base = [UIImage systemImageNamed:name withConfiguration:config];
    if (!base) {
        NSLog(@"[SFSymbol] ⚠️ Image nil for '%@' (pt=%.1f w=%ld s=%ld)",
              name, self.sf_pointSize, (long)self.sf_weight, (long)self.sf_scale);
        return nil;
    }
    
    // Palette 模式下保留原始多色，不做 tintColor 着色
    if (@available(iOS 15.0, *)) {
        if (self.sf_paletteEnabled) return base;
    }
    
    // 颜色优先级：方法参数 → 全局 sf_tintColor → 按钮自身 tintColor
    UIColor *final = tintColor ?: self.sf_tintColor ?: self.tintColor;
    return final
    ? [base imageWithTintColor:final renderingMode:UIImageRenderingModeAlwaysOriginal]
    : base;
}


#pragma mark - Internal: Parse Polymorphic Value

/**
 * @brief 解析 sf_setSymbolsForStates: 的多态 value
 * @param outWeight/outScale 未指定时返回 NSNotFound，调用方据此回退全局属性
 * @return YES 表示解析成功（至少拿到了有效 name）
 *
 * @code
 * NSString *name; UIColor *color; NSInteger w, s;
 * BOOL ok = [[self class] _sf_parseSymbolConfigValue:value
 *                                           outName:&name
 *                                          outColor:&color
 *                                         outWeight:&w
 *                                          outScale:&s];
 * // w == NSNotFound → 调用方应使用 self.sf_weight
 * @endcode
 */
+ (BOOL)_sf_parseSymbolConfigValue:(id)value
                           outName:(NSString * _Nullable __autoreleasing *)outName
                          outColor:(UIColor * _Nullable __autoreleasing *)outColor
                         outWeight:(NSInteger *)outWeight
                          outScale:(NSInteger *)outScale {
    // 纯字符串 → 仅 name，其余全部缺省
    if ([value isKindOfClass:[NSString class]]) {
        *outName   = (NSString *)value;
        *outColor  = nil;
        *outWeight = NSNotFound;
        *outScale  = NSNotFound;
        return (*outName != nil);
    }
    
    // 字典 → 逐字段安全解析
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)value;
        
        // name 必填
        NSString *name = dict[SFSymbolConfigKeyName];
        if (![name isKindOfClass:[NSString class]] || name.length == 0) return NO;
        *outName = name;
        
        // tintColor 可选
        UIColor *color = dict[SFSymbolConfigKeyTintColor];
        *outColor = [color isKindOfClass:[UIColor class]] ? color : nil;
        
        // weight 可选，NSNotFound 表示未指定
        NSNumber *wNum = dict[SFSymbolConfigKeyWeight];
        *outWeight = [wNum isKindOfClass:[NSNumber class]] ? wNum.integerValue : NSNotFound;
        
        // scale 可选，NSNotFound 表示未指定
        NSNumber *sNum = dict[SFSymbolConfigKeyScale];
        *outScale = [sNum isKindOfClass:[NSNumber class]] ? sNum.integerValue : NSNotFound;
        
        return YES;
    }
    
    return NO;
}


#pragma mark - Set Symbol

- (void)sf_setSymbol:(NSString *)name forState:(UIControlState)state {
    [self sf_setSymbol:name
              forState:state
             pointSize:self.sf_pointSize
                weight:self.sf_weight
                 scale:self.sf_scale
             tintColor:nil];
}

- (void)sf_setSymbol:(NSString *)name
           tintColor:(nullable UIColor *)c
            forState:(UIControlState)state {
    [self sf_setSymbol:name
              forState:state
             pointSize:self.sf_pointSize
                weight:self.sf_weight
                 scale:self.sf_scale
             tintColor:c];
}

- (void)sf_setSymbol:(NSString *)name
            forState:(UIControlState)state
           pointSize:(CGFloat)ps
              weight:(UIImageSymbolWeight)w
               scale:(UIImageSymbolScale)s {
    [self sf_setSymbol:name
              forState:state
             pointSize:ps
                weight:w
                 scale:s
             tintColor:nil];
}

/**
 * @brief 所有 sf_setSymbol 变体的最终汇聚点
 * @discussion 缓存 name / config / tintColor 三要素，供后续 reload 和 setTintColor 复用
 */
- (void)sf_setSymbol:(NSString *)name
            forState:(UIControlState)state
           pointSize:(CGFloat)ps
              weight:(UIImageSymbolWeight)w
               scale:(UIImageSymbolScale)s
           tintColor:(nullable UIColor *)c {
    UIImageSymbolConfiguration *cfg = [self _sf_configWithPointSize:ps weight:w scale:s];
    
    // 缓存三要素
    [self _sf_stateConfigs][@(state)] = cfg;
    [self _sf_stateNames][@(state)]   = name;
    c
    ? ([self _sf_stateTintColors][@(state)] = c)
    : [[self _sf_stateTintColors] removeObjectForKey:@(state)];
    
    // Normal 状态同步到只读属性
    if (state == UIControlStateNormal) {
        self.sf_symbolName = name;
    }
    
    [self setImage:[self _sf_imageWithName:name tintColor:c configuration:cfg] forState:state];
}


#pragma mark - Batch Set

- (void)sf_setSymbolsForStates:(NSDictionary<NSNumber *, id> *)map {
    [self sf_setSymbolsForStates:map defaultTintColor:nil];
}

/**
 * @brief 批量设置核心实现
 * @discussion
 * 遍历 symbolMap，对每个 entry：
 * 1. 解析多态 value → name / color / weight / scale
 * 2. weight/scale 为 NSNotFound 时回退全局属性
 * 3. 颜色优先级：字典内 tintColor > defaultTintColor > (底层回退链)
 * 4. 委托给完整参数的 sf_setSymbol 完成缓存与渲染
 */
- (void)sf_setSymbolsForStates:(NSDictionary<NSNumber *, id> *)map
              defaultTintColor:(nullable UIColor *)def {
    [map enumerateKeysAndObjectsUsingBlock:^(NSNumber *stateNum, id value, BOOL *stop) {
        NSString  *name  = nil;
        UIColor   *color = nil;
        NSInteger  wVal  = NSNotFound;
        NSInteger  sVal  = NSNotFound;
        
        if (![[self class] _sf_parseSymbolConfigValue:value
                                              outName:&name
                                             outColor:&color
                                            outWeight:&wVal
                                             outScale:&sVal]) {
            NSLog(@"[SFSymbol] ⚠️ Invalid config for state %@, skipped.", stateNum);
            return;
        }
        
        UIControlState state = (UIControlState)stateNum.unsignedIntegerValue;
        
        // ✅ 独立 weight/scale 优先，NSNotFound 时回退全局属性
        UIImageSymbolWeight finalWeight = (wVal != NSNotFound)
        ? (UIImageSymbolWeight)wVal : self.sf_weight;
        UIImageSymbolScale finalScale = (sVal != NSNotFound)
        ? (UIImageSymbolScale)sVal : self.sf_scale;
        
        // 颜色优先级：字典内 > defaultTintColor > (底层 _sf_imageWithName 回退链)
        UIColor *finalColor = color ?: def;
        
        [self sf_setSymbol:name
                  forState:state
                 pointSize:self.sf_pointSize
                    weight:finalWeight
                     scale:finalScale
                 tintColor:finalColor];
    }];
}


#pragma mark - Reload

/**
 * @brief 刷新单个状态
 * @discussion 始终使用最新的全局 sf_pointSize / sf_weight / sf_scale 重建 config，
 *             但保留该状态独立的 tintColor
 */
- (void)sf_reloadSymbolForState:(UIControlState)state {
    NSString *name = [self _sf_stateNames][@(state)];
    if (!name && state == UIControlStateNormal) name = self.sf_symbolName;
    if (!name) return;
    
    UIImageSymbolConfiguration *cfg = [self _sf_configWithPointSize:self.sf_pointSize
                                                             weight:self.sf_weight
                                                              scale:self.sf_scale];
    [self _sf_stateConfigs][@(state)] = cfg;
    
    UIColor *stateColor = [self _sf_stateTintColors][@(state)];
    [self setImage:[self _sf_imageWithName:name tintColor:stateColor configuration:cfg]
          forState:state];
}

/**
 * @brief 刷新所有已缓存状态
 * @discussion 额外处理 normal 状态可能不在 stateNames 中的边界情况
 */
- (void)sf_reloadAllSymbols {
    [[self _sf_stateNames] enumerateKeysAndObjectsUsingBlock:^(NSNumber *k, NSString *n, BOOL *stop) {
        [self sf_reloadSymbolForState:k.unsignedIntegerValue];
    }];
    
    // 确保 normal 也被刷新（即使它不在 stateNames 字典中）
    if (self.sf_symbolName && ![self _sf_stateNames][@(UIControlStateNormal)]) {
        [self sf_reloadSymbolForState:UIControlStateNormal];
    }
}


#pragma mark - Standalone Color & Palette

/**
 * @brief 仅修改某状态颜色，复用已缓存的 config 和 name
 * @discussion 如果该状态从未设置过 Symbol，静默忽略
 */
- (void)sf_setTintColor:(UIColor *)c forState:(UIControlState)state {
    NSString *name = [self _sf_stateNames][@(state)] ?: self.sf_symbolName;
    if (!name) return;
    
    [self _sf_stateTintColors][@(state)] = c;
    UIImageSymbolConfiguration *cfg = [self _sf_stateConfigs][@(state)];
    [self setImage:[self _sf_imageWithName:name tintColor:c configuration:cfg] forState:state];
}

/**
 * @brief Palette 多色着色（iOS 15.0+）
 * @discussion 将 paletteColors 配置叠加到已有 base config 上，不影响其他状态
 */
- (void)sf_setPaletteColors:(NSArray<UIColor *> *)colors
                   forState:(UIControlState)state API_AVAILABLE(ios(15.0)) {
    if (@available(iOS 15.0, *)) {
        NSString *name = [self _sf_stateNames][@(state)] ?: self.sf_symbolName;
        if (!name) return;
        
        UIImageSymbolConfiguration *base = [self _sf_stateConfigs][@(state)]
        ?: [self _sf_configWithPointSize:self.sf_pointSize weight:self.sf_weight scale:self.sf_scale];
        UIImageSymbolConfiguration *pal  = [UIImageSymbolConfiguration configurationWithPaletteColors:colors];
        UIImageSymbolConfiguration *merged = [base configurationByApplyingConfiguration:pal];
        
        [self setImage:[UIImage systemImageNamed:name withConfiguration:merged] forState:state];
    }
}


#pragma mark - Factory Methods

+ (instancetype)sf_buttonWithSymbol:(NSString *)n forState:(UIControlState)s {
    return [self sf_buttonWithSymbol:n forState:s
                           pointSize:17 weight:UIImageSymbolWeightMedium
                               scale:UIImageSymbolScaleMedium tintColor:nil];
}

+ (instancetype)sf_buttonWithSymbol:(NSString *)n
                           forState:(UIControlState)s
                          tintColor:(nullable UIColor *)c {
    return [self sf_buttonWithSymbol:n forState:s
                           pointSize:17 weight:UIImageSymbolWeightMedium
                               scale:UIImageSymbolScaleMedium tintColor:c];
}

+ (instancetype)sf_buttonWithSymbol:(NSString *)n
                           forState:(UIControlState)s
                          pointSize:(CGFloat)p
                             weight:(UIImageSymbolWeight)w
                              scale:(UIImageSymbolScale)sc {
    return [self sf_buttonWithSymbol:n forState:s
                           pointSize:p weight:w scale:sc tintColor:nil];
}

+ (instancetype)sf_buttonWithSymbol:(NSString *)n
                           forState:(UIControlState)s
                          pointSize:(CGFloat)p
                             weight:(UIImageSymbolWeight)w
                              scale:(UIImageSymbolScale)sc
                          tintColor:(nullable UIColor *)c {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.sf_pointSize = p;
    b.sf_weight = w;
    b.sf_scale = sc;
    [b sf_setSymbol:n forState:s pointSize:p weight:w scale:sc tintColor:c];
    return b;
}

+ (instancetype)sf_buttonWithSymbols:(NSDictionary<NSNumber *, id> *)m
                           pointSize:(CGFloat)p
                              weight:(UIImageSymbolWeight)w
                               scale:(UIImageSymbolScale)sc {
    return [self sf_buttonWithSymbols:m pointSize:p weight:w scale:sc defaultTintColor:nil];
}

+ (instancetype)sf_buttonWithSymbols:(NSDictionary<NSNumber *, id> *)m
                           pointSize:(CGFloat)p
                              weight:(UIImageSymbolWeight)w
                               scale:(UIImageSymbolScale)sc
                    defaultTintColor:(nullable UIColor *)c {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.sf_pointSize = p;
    b.sf_weight = w;
    b.sf_scale = sc;
    [b sf_setSymbolsForStates:m defaultTintColor:c];
    return b;
}

@end
