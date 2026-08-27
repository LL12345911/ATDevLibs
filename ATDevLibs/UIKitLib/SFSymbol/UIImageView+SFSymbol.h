//
//  UIImageView+SFSymbol.h
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UIImageView 的 SF Symbol 便捷分类
 * @discussion 提供类方法与实例方法，支持样式配置、Palette 多色、Variable Color 动画等高级特性。
 *             所有自定义属性与方法均以 `sf_` 为前缀，避免命名冲突。
 *
 * @note 最低支持 iOS 13.0，Palette/Variable/Hierarchical 功能需 iOS 15.0+。
 */
@interface UIImageView (SFSymbol)

#pragma mark - Properties

/**
 * @brief 当前 Symbol 名称（只读）
 * @discussion 记录最后一次通过 sf_ 方法设置的 symbol 名称，供后续样式更新时复用。
 *
 * @code
 * NSString *name = imageView.sf_symbolName;
 * NSLog(@"Current: %@", name); // e.g. "cloud.sun.rain.fill"
 * @endcode
 */
@property (nonatomic, copy, readonly, nullable) NSString *sf_symbolName;

/**
 * @brief Symbol pointSize
 * @discussion 默认 17.0。修改后需调用 sf_updateImage 或重新设置 symbol 才生效。
 *
 * @code
 * imageView.sf_pointSize = 32.0;
 * [imageView sf_updateImage]; // 以新字号重新渲染当前 symbol
 * @endcode
 */
@property (nonatomic, assign) CGFloat sf_pointSize;

/**
 * @brief Symbol weight
 * @discussion 默认 UIImageSymbolWeightMedium。
 *
 * @code
 * imageView.sf_weight = UIImageSymbolWeightUltralight;
 * [imageView sf_updateImage];
 * @endcode
 */
@property (nonatomic, assign) UIImageSymbolWeight sf_weight;

/**
 * @brief Symbol scale
 * @discussion 默认 UIImageSymbolScaleMedium。可选 Small / Medium / Large。
 *
 * @code
 * imageView.sf_scale = UIImageSymbolScaleLarge;
 * [imageView sf_updateImage];
 * @endcode
 */
@property (nonatomic, assign) UIImageSymbolScale sf_scale;

#pragma mark - Instance Methods (基础)

/**
 * @brief 设置 SF Symbol（使用当前全局样式）
 * @param name Symbol 名称，如 @"heart.fill"
 *
 * @code
 * imageView.sf_pointSize = 24.0;
 * imageView.sf_weight = UIImageSymbolWeightSemibold;
 * [imageView sf_setSymbol:@"star.fill"];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name;

/**
 * @brief 设置 SF Symbol（带独立样式）
 * @param name      Symbol 名称
 * @param pointSize 字号
 * @param weight    粗细
 * @param scale     缩放
 *
 * @code
 * [imageView sf_setSymbol:@"bolt.circle.fill"
 *               pointSize:40.0
 *                  weight:UIImageSymbolWeightBold
 *                   scale:UIImageSymbolScaleLarge];
 * @endcode
 */
- (void)sf_setSymbol:(NSString *)name
           pointSize:(CGFloat)pointSize
              weight:(UIImageSymbolWeight)weight
               scale:(UIImageSymbolScale)scale;

/**
 * @brief 以当前保存的 symbol 名称和样式重新生成图片
 * @discussion 适用于仅修改了 sf_pointSize / sf_weight / sf_scale 后刷新显示。
 *
 * @code
 * imageView.sf_pointSize = 28.0;
 * [imageView sf_updateImage];
 * @endcode
 */
- (void)sf_updateImage;

#pragma mark - Instance Methods (iOS 15+ 高级渲染)

/**
 * @brief 设置 Palette 多色模式
 * @param colors 颜色数组，按 Symbol 层级顺序排列
 * @warning 需 iOS 15.0+，低版本静默忽略。
 *
 * @code
 * if (@available(iOS 15.0, *)) {
 *     [imageView sf_setSymbol:@"theatermasks.fill"];
 *     [imageView sf_setPaletteColors:@[UIColor.systemPurpleColor,
 *                                      UIColor.systemOrangeColor]];
 * }
 * @endcode
 */
- (void)sf_setPaletteColors:(NSArray<UIColor *> *)colors API_AVAILABLE(ios(15.0));

/**
 * @brief 设置 Hierarchical 单色分层模式
 * @param color 基准色，系统自动派生各层级透明度
 * @warning 需 iOS 15.0+。与 Palette 互斥，后设置的优先。
 *
 * @code
 * if (@available(iOS 15.0, *)) {
 *     [imageView sf_setSymbol:@"person.crop.circle.badge.checkmark"];
 *     [imageView sf_setHierarchicalColor:UIColor.systemGreenColor];
 * }
 * @endcode
 */
- (void)sf_setHierarchicalColor:(UIColor *)color API_AVAILABLE(ios(15.0));

/**
 * @brief 设置 Monochrome 单色模式
 * @param color 单一着色
 * @warning 需 iOS 15.0+。与 Palette/Hierarchical 互斥，后设置的优先。
 *
 * @code
 * if (@available(iOS 15.0, *)) {
 *     [imageView sf_setSymbol:@"heart.fill"];
 *     [imageView sf_setMonochromeColor:UIColor.systemRedColor];
 * }
 * @endcode
 */
- (void)sf_setMonochromeColor:(UIColor *)color API_AVAILABLE(ios(15.0));

/**
 * @brief 应用 Variable Color 可变值（用于动画/进度指示）
 * @param value 0.0 ~ 1.0 之间的浮点数
 * @warning 需 iOS 15.0+。仅对支持 variable 的 symbol 有效（如 "wifi"、"battery.100"）。
 *
 * @code
 * if (@available(iOS 15.0, *)) {
 *     [imageView sf_setSymbol:@"wifi"];
 *     // 模拟信号强度变化
 *     [imageView sf_setVariableValue:0.75];
 * }
 * @endcode
 */
- (void)sf_setVariableValue:(CGFloat)value API_AVAILABLE(ios(15.0));

#pragma mark - Class Methods

/**
 * @brief 快速创建 SF Symbol ImageView（默认 17pt Medium）
 * @param name Symbol 名称
 * @return 配置完成的 UIImageView
 *
 * @code
 * UIImageView *iv = [UIImageView sf_imageViewWithSymbol:@"info.circle"];
 * [self.view addSubview:iv];
 * @endcode
 */
+ (instancetype)sf_imageViewWithSymbol:(NSString *)name;

/**
 * @brief 快速创建 SF Symbol ImageView（自定义样式）
 * @param name      Symbol 名称
 * @param pointSize 字号
 * @param weight    粗细
 * @param scale     缩放
 * @return 配置完成的 UIImageView
 *
 * @code
 * UIImageView *iv = [UIImageView sf_imageViewWithSymbol:@"checkmark.seal.fill"
 *                                             pointSize:48.0
 *                                                weight:UIImageSymbolWeightBold
 *                                                 scale:UIImageSymbolScaleLarge];
 * iv.tintColor = UIColor.systemGreenColor;
 * @endcode
 */
+ (instancetype)sf_imageViewWithSymbol:(NSString *)name
                             pointSize:(CGFloat)pointSize
                                weight:(UIImageSymbolWeight)weight
                                 scale:(UIImageSymbolScale)scale;



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
                         fallbackImageName:(nullable NSString *)fallbackImageName;




@end

NS_ASSUME_NONNULL_END
