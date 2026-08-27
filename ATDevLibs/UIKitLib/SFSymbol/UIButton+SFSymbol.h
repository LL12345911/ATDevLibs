//
//  UIButton+SFSymbol.h
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UIButton 的 SF Symbol 便捷分类
 * @discussion 提供类方法与实例方法，支持多状态（Normal / Highlighted / Selected / Disabled）独立配置。
 *             所有自定义属性与方法均以 `sf_` 为前缀，避免命名冲突。
 *
 * @note 最低支持 iOS 13.0（SF Symbol 首次引入），Palette 功能需 iOS 15.0+。
 */
@interface UIButton (SFSymbol)

#pragma mark - Properties

/**
 * @brief 当前 Normal 状态的 Symbol 名称（只读）
 * @discussion 仅在调用 @c sf_setSymbol:forState: 且 state 为 UIControlStateNormal 时更新。
 *
 * @code
 * // 读取当前 Normal 状态的 symbol 名称
 * NSString *name = button.sf_symbolName;
 * NSLog(@"Current symbol: %@", name); // e.g. "heart.fill"
 * @endcode
 */
@property (nonatomic, copy, readonly, nullable) NSString *sf_symbolName;

/**
 * @brief 全局 pointSize，作为无样式参数的 sf_setSymbol:forState: 的默认值
 * @discussion 默认值为 17.0。修改后仅影响后续调用，不会自动刷新已设置的图片。
 *
 * @code
 * // 设置全局字号后再批量应用
 * button.sf_pointSize = 24.0;
 * [button sf_setSymbol:@"star" forState:UIControlStateNormal];
 * [button sf_setSymbol:@"star.fill" forState:UIControlStateSelected];
 * @endcode
 */
@property (nonatomic, assign) CGFloat sf_pointSize;

/**
 * @brief 全局 symbol weight，作为无样式参数的 sf_setSymbol:forState: 的默认值
 * @discussion 默认值为 UIImageSymbolWeightMedium。
 *
 * @code
 * button.sf_weight = UIImageSymbolWeightBold;
 * [button sf_setSymbol:@"gearshape" forState:UIControlStateNormal];
 * @endcode
 */
@property (nonatomic, assign) UIImageSymbolWeight sf_weight;

/**
 * @brief 全局 symbol scale，作为无样式参数的 sf_setSymbol:forState: 的默认值
 * @discussion 默认值为 UIImageSymbolScaleMedium。可选 Small / Medium / Large。
 *
 * @code
 * button.sf_scale = UIImageSymbolScaleLarge;
 * [button sf_setSymbol:@"person.circle" forState:UIControlStateNormal];
 * @endcode
 */
@property (nonatomic, assign) UIImageSymbolScale sf_scale;

/**
 * @brief 是否启用 Palette 多色渲染模式（iOS 15.0+）
 * @discussion 默认为 NO。开启后配合 @c sf_setPaletteColors:forState: 使用。
 *             iOS 15 以下设置此属性无效。
 *
 * @code
 * if (@available(iOS 15.0, *)) {
 *     button.sf_paletteEnabled = YES;
 *     [button sf_setSymbol:@"cloud.sun.rain.fill" forState:UIControlStateNormal];
 *     [button sf_setPaletteColors:@[UIColor.systemBlueColor,
 *                                   UIColor.systemYellowColor,
 *                                   UIColor.systemTealColor]
 *                        forState:UIControlStateNormal];
 * }
 * @endcode
 */
@property (nonatomic, assign) BOOL sf_paletteEnabled API_AVAILABLE(ios(15.0));

#pragma mark - Instance Methods

/**
 * @brief 为指定状态设置 SF Symbol（使用当前全局样式）
 * @param name  Symbol 名称，如 @"heart.fill"
 * @param state 目标按钮状态
 *
 * @code
 * // 使用当前 sf_pointSize / sf_weight / sf_scale
 * [button sf_setSymbol:@"bookmark" forState:UIControlStateNormal];
 * [button sf_setSymbol:@"bookmark.fill" forState:UIControlStateSelected];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name forState:(UIControlState)state;

/**
 * @brief 为指定状态设置 SF Symbol（带独立样式，不受全局属性影响）
 * @param name      Symbol 名称
 * @param state     目标按钮状态
 * @param pointSize 字号大小
 * @param weight    粗细
 * @param scale     缩放比例
 *
 * @code
 * // Normal 用 20pt Regular，Highlighted 用 22pt Bold
 * [button sf_setSymbol:@"play.circle"
 *              forState:UIControlStateNormal
 *             pointSize:20.0
 *                weight:UIImageSymbolWeightRegular
 *                 scale:UIImageSymbolScaleMedium];
 *
 * [button sf_setSymbol:@"play.circle.fill"
 *              forState:UIControlStateHighlighted
 *             pointSize:22.0
 *                weight:UIImageSymbolWeightBold
 *                 scale:UIImageSymbolScaleMedium];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name
            forState:(UIControlState)state
           pointSize:(CGFloat)pointSize
              weight:(UIImageSymbolWeight)weight
               scale:(UIImageSymbolScale)scale;

/**
 * @brief 批量设置多个状态的 Symbol（使用当前全局样式）
 * @param symbolMap 字典，key 为 @(UIControlStateXxx)，value 为 Symbol 名称字符串
 *
 * @code
 * [button sf_setSymbolsForStates:@{
 *     @(UIControlStateNormal):   @"heart",
 *     @(UIControlStateSelected): @"heart.fill",
 *     @(UIControlStateDisabled): @"heart.slash"
 * }];
 * @endcode
 */
- (void)sf_setSymbolsForStates:(NSDictionary<NSNumber *, NSString *> *)symbolMap;

/**
 * @brief 为指定状态设置 Palette 多层颜色（iOS 15.0+）
 * @param colors 颜色数组，按 Symbol 层级顺序排列
 * @param state  目标按钮状态
 * @warning 调用前需先通过 sf_setSymbol:forState: 设置对应状态的 Symbol，
 *          且 sf_paletteEnabled 应为 YES。
 *
 * @code
 * if (@available(iOS 15.0, *)) {
 *     button.sf_paletteEnabled = YES;
 *     [button sf_setSymbol:@"theatermasks.fill" forState:UIControlStateNormal];
 *     [button sf_setPaletteColors:@[UIColor.systemPurpleColor,
 *                                   UIColor.systemOrangeColor]
 *                        forState:UIControlStateNormal];
 * }
 * @endcode
 */
- (void)sf_setPaletteColors:(NSArray<UIColor *> *)colors
                   forState:(UIControlState)state API_AVAILABLE(ios(15.0));

#pragma mark - Class Methods

/**
 * @brief 快速创建一个单状态 SF Symbol 按钮（默认 17pt Medium）
 * @param name  Symbol 名称
 * @param state 初始状态
 * @return 配置完成的 UIButton（System 类型）
 *
 * @code
 * UIButton *btn = [UIButton sf_buttonWithSymbol:@"square.and.arrow.up"
 *                                      forState:UIControlStateNormal];
 * [self.view addSubview:btn];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbol:(NSString *)name
                           forState:(UIControlState)state;

/**
 * @brief 快速创建一个单状态 SF Symbol 按钮（自定义样式）
 * @param name      Symbol 名称
 * @param state     初始状态
 * @param pointSize 字号
 * @param weight    粗细
 * @param scale     缩放
 * @return 配置完成的 UIButton（System 类型）
 *
 * @code
 * UIButton *btn = [UIButton sf_buttonWithSymbol:@"trash.fill"
 *                                      forState:UIControlStateNormal
 *                                     pointSize:28.0
 *                                        weight:UIImageSymbolWeightSemibold
 *                                         scale:UIImageSymbolScaleLarge];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbol:(NSString *)name
                           forState:(UIControlState)state
                          pointSize:(CGFloat)pointSize
                             weight:(UIImageSymbolWeight)weight
                              scale:(UIImageSymbolScale)scale;

/**
 * @brief 快速创建一个多状态 SF Symbol 按钮
 * @param symbolMap 状态→Symbol 映射字典
 * @param pointSize 统一字号
 * @param weight    统一粗细
 * @param scale     统一缩放
 * @return 配置完成的 UIButton（System 类型）
 *
 * @code
 * UIButton *toggleBtn = [UIButton sf_buttonWithSymbols:@{
 *     @(UIControlStateNormal):   @"moon.stars",
 *     @(UIControlStateSelected): @"sun.max.fill"
 * } pointSize:24.0 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
 *
 * [toggleBtn addTarget:self action:@selector(toggleTheme:) forControlEvents:UIControlEventTouchUpInside];
 * @endcode
 */
+ (instancetype)sf_buttonWithSymbols:(NSDictionary<NSNumber *, NSString *> *)symbolMap
                           pointSize:(CGFloat)pointSize
                              weight:(UIImageSymbolWeight)weight
                               scale:(UIImageSymbolScale)scale;

@end

NS_ASSUME_NONNULL_END
