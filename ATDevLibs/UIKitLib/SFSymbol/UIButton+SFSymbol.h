//
//  UIButton+SFSymbol.h
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Configuration Dictionary Keys

/**
 * @brief Symbol 配置字典 Key：Symbol 名称（NSString *，必填）
 * @discussion 批量设置时，若 value 为纯 NSString，等价于仅包含此 Key 的字典
 * @code
 * // 作为字典使用
 * @{ SFSymbolConfigKeyName: @"heart.fill" }
 *
 * // 纯字符串简写（等价于上面）
 * @"heart.fill"
 * @endcode
 */
extern NSString * const SFSymbolConfigKeyName;

/**
 * @brief Symbol 配置字典 Key：独立色调（UIColor *，可选）
 * @discussion 缺省时依次回退到 defaultTintColor → sf_tintColor → self.tintColor
 * @code
 * @{
 *     SFSymbolConfigKeyName: @"heart.fill",
 *     SFSymbolConfigKeyTintColor: UIColor.systemRedColor
 * }
 * @endcode
 */
extern NSString * const SFSymbolConfigKeyTintColor;

/**
 * @brief Symbol 配置字典 Key：独立 weight（NSNumber, UIImageSymbolWeight，可选）
 * @discussion 缺省时回退到按钮全局属性 sf_weight
 * @code
 * @{
 *     SFSymbolConfigKeyName: @"star.fill",
 *     SFSymbolConfigKeyWeight: @(UIImageSymbolWeightBold)
 * }
 * @endcode
 */
extern NSString * const SFSymbolConfigKeyWeight;

/**
 * @brief Symbol 配置字典 Key：独立 scale（NSNumber, UIImageSymbolScale，可选）
 * @discussion 缺省时回退到按钮全局属性 sf_scale
 * @code
 * @{
 *     SFSymbolConfigKeyName: @"star.fill",
 *     SFSymbolConfigKeyScale: @(UIImageSymbolScaleLarge)
 * }
 * @endcode
 */
extern NSString * const SFSymbolConfigKeyScale;


#pragma mark - UIButton (SFSymbol)

/**
 * @brief UIButton SF Symbol 便捷分类
 * @note 最低支持 iOS 13.0；Palette 多色模式需 iOS 15.0+
 *
 * @discussion
 * 核心设计原则：
 * 1. sf_setSymbol 系列方法在调用时立即生成图片并缓存配置
 * 2. sf_pointSize / sf_weight / sf_scale / sf_tintColor 仅为关联存储，
 *    修改后不会自动刷新已设置的图片，必须手动调用 sf_reloadSymbolForState:
 *    或 sf_reloadAllSymbols
 * 3. 批量接口 sf_setSymbolsForStates: 支持多态 value（NSString / NSDictionary），
 *    字典中可独立指定 weight / scale / tintColor，缺省项取全局属性
 *
 * @code
 * // ✅ 推荐：工厂方法一行创建
 * UIButton *btn = [UIButton sf_buttonWithSymbol:@"trash.fill"
 *                                      forState:UIControlStateNormal
 *                                     pointSize:24.0
 *                                        weight:UIImageSymbolWeightSemibold
 *                                         scale:UIImageSymbolScaleMedium
 *                                     tintColor:UIColor.systemRedColor];
 *
 * // ✅ 动态修改属性后刷新
 * btn.sf_pointSize = 32.0;
 * [btn sf_reloadSymbolForState:UIControlStateNormal];
 * @endcode
 */
@interface UIButton (SFSymbol)

#pragma mark - Properties

/**
 * @brief Normal 状态 Symbol 名称（只读）
 * @discussion 通过 sf_setSymbol:forState: 设置 UIControlStateNormal 时自动同步
 * @code
 * NSString *name = button.sf_symbolName; // @"heart.fill" or nil
 * @endcode
 */
@property (nonatomic, copy, readonly, nullable) NSString *sf_symbolName;

/**
 * @brief 全局 pointSize（默认 17.0）
 * @warning 修改后已设置的图片不会自动更新，需调用 reload 方法
 * @code
 * button.sf_pointSize = 24.0;
 * [button sf_reloadSymbolForState:UIControlStateNormal];
 * @endcode
 */
@property (nonatomic, assign) CGFloat sf_pointSize;

/**
 * @brief 全局 weight（默认 UIImageSymbolWeightMedium）
 * @warning 修改后需手动 reload
 * @code
 * button.sf_weight = UIImageSymbolWeightBold;
 * [button sf_reloadAllSymbols];
 * @endcode
 */
@property (nonatomic, assign) UIImageSymbolWeight sf_weight API_AVAILABLE(ios(13.0));

/**
 * @brief 全局 scale（默认 UIImageSymbolScaleMedium）
 * @warning 修改后需手动 reload
 * @code
 * button.sf_scale = UIImageSymbolScaleLarge;
 * [button sf_reloadAllSymbols];
 * @endcode
 */
@property (nonatomic, assign) UIImageSymbolScale sf_scale API_AVAILABLE(ios(13.0));

/**
 * @brief 全局 TintColor（nil 时回退到 self.tintColor）
 * @warning 修改后需手动 reload
 * @code
 * button.sf_tintColor = UIColor.systemBlueColor;
 * [button sf_reloadAllSymbols];
 * @endcode
 */
@property (nonatomic, strong, nullable) UIColor *sf_tintColor;

/**
 * @brief Palette 多色模式开关（iOS 15.0+，默认 NO）
 * @discussion 开启后 tintColor 着色逻辑被忽略，Symbol 以原始多色渲染
 * @code
 * if (@available(iOS 15.0, *)) {
 *     button.sf_paletteEnabled = YES;
 *     [button sf_reloadAllSymbols];
 * }
 * @endcode
 */
@property (nonatomic, assign) BOOL sf_paletteEnabled API_AVAILABLE(ios(15.0));


#pragma mark - Set Symbol

/**
 * @brief 使用当前全局样式 + 全局 tintColor 设置 Symbol
 * @param name  SF Symbol 名称，如 @"heart.fill"
 * @param state 按钮状态
 * @code
 * button.sf_pointSize = 20.0;
 * button.sf_weight = UIImageSymbolWeightSemibold;
 * [button sf_setSymbol:@"gearshape.fill" forState:UIControlStateNormal];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name forState:(UIControlState)state;

/**
 * @brief 使用当前全局样式 + 指定 tintColor 设置 Symbol
 * @param name      SF Symbol 名称
 * @param tintColor 该状态的独立颜色，传 nil 则回退全局
 * @param state     按钮状态
 * @code
 * [button sf_setSymbol:@"heart.fill"
 *             tintColor:UIColor.systemRedColor
 *              forState:UIControlStateSelected];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name
           tintColor:(nullable UIColor *)tintColor
            forState:(UIControlState)state;

/**
 * @brief 使用独立 pointSize / weight / scale + 全局 tintColor 设置 Symbol
 * @code
 * [button sf_setSymbol:@"star.fill"
 *              forState:UIControlStateNormal
 *             pointSize:28.0
 *                weight:UIImageSymbolWeightBold
 *                 scale:UIImageSymbolScaleLarge];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name
            forState:(UIControlState)state
           pointSize:(CGFloat)pointSize
              weight:(UIImageSymbolWeight)weight
               scale:(UIImageSymbolScale)scale API_AVAILABLE(ios(13.0));

/**
 * @brief 完整参数设置（⭐ 推荐）
 * @discussion 内部使用 UIImageRenderingModeAlwaysOriginal 确保颜色精确不受系统干扰
 * @param name      SF Symbol 名称
 * @param state     按钮状态
 * @param pointSize 字号
 * @param weight    字重
 * @param scale     缩放等级
 * @param tintColor 色调，传 nil 则依次回退 sf_tintColor → self.tintColor
 * @code
 * [button sf_setSymbol:@"trash.fill"
 *              forState:UIControlStateNormal
 *             pointSize:28.0
 *                weight:UIImageSymbolWeightSemibold
 *                 scale:UIImageSymbolScaleLarge
 *             tintColor:UIColor.systemRedColor];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name
            forState:(UIControlState)state
           pointSize:(CGFloat)pointSize
              weight:(UIImageSymbolWeight)weight
               scale:(UIImageSymbolScale)scale
           tintColor:(nullable UIColor *)tintColor API_AVAILABLE(ios(13.0));


#pragma mark - Batch Set

/**
 * @brief 批量设置多状态 Symbol（value 支持 NSString 或 NSDictionary）
 * @discussion
 * - NSString：仅指定 name，其余属性取全局默认值
 * - NSDictionary：可包含 SFSymbolConfigKeyName（必填）、
 *   SFSymbolConfigKeyTintColor / SFSymbolConfigKeyWeight / SFSymbolConfigKeyScale（可选）
 * - 字典中未指定的字段自动回退到按钮全局属性
 *
 * @param symbolMap key 为 @(UIControlState)，value 为 NSString 或 NSDictionary
 * @code
 * [button sf_setSymbolsForStates:@{
 *     @(UIControlStateNormal): @"moon.stars",
 *     @(UIControlStateSelected): @{
 *         SFSymbolConfigKeyName:   @"sun.max.fill",
 *         SFSymbolConfigKeyTintColor: UIColor.systemYellowColor,
 *         SFSymbolConfigKeyWeight: @(UIImageSymbolWeightBold),
 *         SFSymbolConfigKeyScale:  @(UIImageSymbolScaleLarge)
 *     },
 *     @(UIControlStateDisabled): @{
 *         SFSymbolConfigKeyName:   @"moon.stars",
 *         SFSymbolConfigKeyTintColor: UIColor.tertiaryLabelColor,
 *         SFSymbolConfigKeyWeight: @(UIImageSymbolWeightUltraLight)
 *         // scale 未指定 → 自动取 button.sf_scale
 *     }
 * }];
 * @endcode
 */
- (void)sf_setSymbolsForStates:(NSDictionary<NSNumber *, id> *)symbolMap;

/**
 * @brief 批量设置 + 全局兜底 tintColor
 * @param defaultTintColor 当字典中未指定 SFSymbolConfigKeyTintColor 时的兜底颜色
 * @code
 * [button sf_setSymbolsForStates:@{
 *     @(UIControlStateNormal):   @"bell",
 *     @(UIControlStateSelected): @{
 *         SFSymbolConfigKeyName: @"bell.fill",
 *         SFSymbolConfigKeyWeight: @(UIImageSymbolWeightBold)
 *     }
 * } defaultTintColor:UIColor.labelColor];
 * @endcode
 */
- (void)sf_setSymbolsForStates:(NSDictionary<NSNumber *, id> *)symbolMap
              defaultTintColor:(nullable UIColor *)defaultTintColor;


#pragma mark - Reload & Color

/**
 * @brief 用当前全局属性重新生成指定状态的 Symbol 图片
 * @discussion ⭐ 修改 sf_pointSize / sf_weight / sf_scale / sf_tintColor 后必须调用
 * @param state 需要刷新的按钮状态
 * @code
 * button.sf_pointSize = 32.0;
 * button.sf_weight = UIImageSymbolWeightHeavy;
 * [button sf_reloadSymbolForState:UIControlStateNormal];
 * @endcode
 */
- (void)sf_reloadSymbolForState:(UIControlState)state;

/**
 * @brief 用当前全局属性重新生成所有已设置状态的 Symbol 图片
 * @code
 * button.sf_scale = UIImageSymbolScaleLarge;
 * [button sf_reloadAllSymbols];
 * @endcode
 */
- (void)sf_reloadAllSymbols;

/**
 * @brief 单独修改某状态的颜色（无需重新设置完整 Symbol）
 * @discussion 前提是该状态已通过 sf_setSymbol 设置过 Symbol
 * @code
 * [button sf_setTintColor:UIColor.systemGreenColor forState:UIControlStateHighlighted];
 * @endcode
 */
- (void)sf_setTintColor:(UIColor *)tintColor forState:(UIControlState)state;

/**
 * @brief Palette 多层颜色着色（iOS 15.0+）
 * @discussion 适用于支持多色的 Symbol（如 @"wifi"），colors 数组按层级对应
 * @code
 * if (@available(iOS 15.0, *)) {
 *     [button sf_setPaletteColors:@[UIColor.systemBlueColor, UIColor.systemOrangeColor]
 *                          forState:UIControlStateNormal];
 * }
 * @endcode
 */
- (void)sf_setPaletteColors:(NSArray<UIColor *> *)colors
                   forState:(UIControlState)state API_AVAILABLE(ios(15.0));


#pragma mark - Factory Methods

/**
 * @brief 工厂：全局默认样式（17pt / Medium / Medium）
 * @code
 * UIButton *btn = [UIButton sf_buttonWithSymbol:@"info.circle" forState:UIControlStateNormal];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbol:(NSString *)name forState:(UIControlState)state;

/**
 * @brief 工厂：全局默认样式 + 指定颜色
 * @code
 * UIButton *btn = [UIButton sf_buttonWithSymbol:@"info.circle"
 *                                      forState:UIControlStateNormal
 *                                     tintColor:UIColor.systemBlueColor];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbol:(NSString *)name
                           forState:(UIControlState)state
                          tintColor:(nullable UIColor *)tintColor;

/**
 * @brief 工厂：自定义 pointSize / weight / scale
 * @code
 * UIButton *btn = [UIButton sf_buttonWithSymbol:@"arrow.right"
 *                                      forState:UIControlStateNormal
 *                                     pointSize:22.0
 *                                        weight:UIImageSymbolWeightSemibold
 *                                         scale:UIImageSymbolScaleMedium];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbol:(NSString *)name
                           forState:(UIControlState)state
                          pointSize:(CGFloat)pointSize
                             weight:(UIImageSymbolWeight)weight
                              scale:(UIImageSymbolScale)scale;

/**
 * @brief 工厂：完整参数（⭐ 最安全的一行创建方式）
 * @code
 * UIButton *btn = [UIButton sf_buttonWithSymbol:@"trash.fill"
 *                                      forState:UIControlStateNormal
 *                                     pointSize:24.0
 *                                        weight:UIImageSymbolWeightSemibold
 *                                         scale:UIImageSymbolScaleMedium
 *                                     tintColor:UIColor.systemRedColor];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbol:(NSString *)name
                           forState:(UIControlState)state
                          pointSize:(CGFloat)pointSize
                             weight:(UIImageSymbolWeight)weight
                              scale:(UIImageSymbolScale)scale
                          tintColor:(nullable UIColor *)tintColor;

/**
 * @brief 工厂：批量多状态 + 全局样式
 * @code
 * UIButton *btn = [UIButton sf_buttonWithSymbols:@{
 *     @(UIControlStateNormal): @"moon",
 *     @(UIControlStateSelected): @{
 *         SFSymbolConfigKeyName: @"sun.max.fill",
 *         SFSymbolConfigKeyTintColor: UIColor.systemYellowColor,
 *         SFSymbolConfigKeyWeight: @(UIImageSymbolWeightBold),
 *         SFSymbolConfigKeyScale:  @(UIImageSymbolScaleLarge)
 *     }
 * } pointSize:20.0 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbols:(NSDictionary<NSNumber *, id> *)symbolMap
                           pointSize:(CGFloat)pointSize
                              weight:(UIImageSymbolWeight)weight
                               scale:(UIImageSymbolScale)scale;

/**
 * @brief 工厂：批量多状态 + 全局样式 + 兜底颜色
 * @code
 * NSDictionary *symbolMap = @{
 *     @(UIControlStateNormal): @"moon",
 *     @(UIControlStateSelected): @{
 *         SFSymbolConfigKeyName: @"sun.max.fill",
 *         SFSymbolConfigKeyTintColor: UIColor.systemYellowColor,
 *         SFSymbolConfigKeyWeight: @(UIImageSymbolWeightBold),
 *         SFSymbolConfigKeyScale:  @(UIImageSymbolScaleLarge)
 *     }
 * }
 * UIButton *btn = [UIButton sf_buttonWithSymbols:symbolMap
 *                                      pointSize:20.0
 *                                         weight:UIImageSymbolWeightMedium
 *                                          scale:UIImageSymbolScaleMedium
 *                               defaultTintColor:UIColor.labelColor];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbols:(NSDictionary<NSNumber *, id> *)symbolMap
                           pointSize:(CGFloat)pointSize
                              weight:(UIImageSymbolWeight)weight
                               scale:(UIImageSymbolScale)scale
                    defaultTintColor:(nullable UIColor *)defaultTintColor;

@end

NS_ASSUME_NONNULL_END
