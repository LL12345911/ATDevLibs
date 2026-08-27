//
//  UIImageView+SFSymbol.h
//  Pods
//
//  Created by Mars on 2026/8/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UIImageView SF Symbol 便捷分类
 * @discussion
 * 核心设计原则（与 UIButton+SFSymbol 保持一致）：
 * 1. sf_setSymbol 系列方法在调用时立即生成图片并缓存配置
 * 2. sf_pointSize / sf_weight / sf_scale 仅为关联存储，
 *    修改后不会自动刷新图片，必须手动调用 sf_updateImage
 * 3. iOS 15+ 渲染模式（Palette / Hierarchical / Monochrome）互斥，后设置的优先
 * 4. Variable Value 不改变渲染模式，仅临时覆盖当前 image
 *
 * @note 最低支持 iOS 13.0；Palette / Hierarchical / Monochrome / Variable 需 iOS 15.0+
 *
 * @code
 * // ✅ 推荐：工厂方法一行创建
 * UIImageView *iv = [UIImageView sf_imageViewWithSymbol:@"cloud.sun.rain.fill"
 *                                             pointSize:32.0
 *                                                weight:UIImageSymbolWeightSemibold
 *                                                 scale:UIImageSymbolScaleLarge];
 *
 * // ✅ 动态修改属性后刷新
 * iv.sf_pointSize = 48.0;
 * [iv sf_updateImage];
 * @endcode
 */
@interface UIImageView (SFSymbol)

#pragma mark - Properties

/**
 * @brief 当前 Symbol 名称（只读）
 * @discussion 记录最后一次通过 sf_ 方法设置的 symbol 名称，供 sf_updateImage 复用
 * @code
 * NSString *name = imageView.sf_symbolName; // @"cloud.sun.rain.fill" or nil
 * @endcode
 */
@property (nonatomic, copy, readonly, nullable) NSString *sf_symbolName;

/**
 * @brief Symbol pointSize（默认 17.0）
 * @warning 修改后需调用 sf_updateImage 才生效
 * @code
 * imageView.sf_pointSize = 32.0;
 * [imageView sf_updateImage];
 * @endcode
 */
@property (nonatomic, assign) CGFloat sf_pointSize;

/**
 * @brief Symbol weight（默认 UIImageSymbolWeightMedium）
 * @warning 修改后需调用 sf_updateImage
 * @code
 * imageView.sf_weight = UIImageSymbolWeightBold;
 * [imageView sf_updateImage];
 * @endcode
 */
@property (nonatomic, assign) UIImageSymbolWeight sf_weight;

/**
 * @brief Symbol scale（默认 UIImageSymbolScaleMedium）
 * @warning 修改后需调用 sf_updateImage
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
               scale:(UIImageSymbolScale)scale API_AVAILABLE(ios(13.0));

/**
 * @brief 以当前保存的 symbol 名称和样式重新生成图片
 * @discussion ⭐ 修改 sf_pointSize / sf_weight / sf_scale 或 iOS 15+ 渲染参数后必须调用
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
 * @warning 需 iOS 15.0+，低版本静默忽略。与 Hierarchical / Monochrome 互斥
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
 * @warning 需 iOS 15.0+。与 Palette / Monochrome 互斥，后设置的优先
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
 * @warning 需 iOS 15.0+。与 Palette / Hierarchical 互斥，后设置的优先
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
 * @warning 需 iOS 15.0+。仅对支持 variable 的 symbol 有效（如 "wifi"、"battery.100"）
 * @discussion Variable 不改变当前渲染模式，仅临时覆盖 image；
 *             调用 sf_updateImage 会保留 variable 效果
 * @code
 * if (@available(iOS 15.0, *)) {
 *     [imageView sf_setSymbol:@"wifi"];
 *     [imageView sf_setVariableValue:0.75]; // 模拟信号强度
 * }
 * @endcode
 */
- (void)sf_setVariableValue:(CGFloat)value API_AVAILABLE(ios(15.0));


#pragma mark - Class Methods (Factory)

/**
 * @brief 快速创建 SF Symbol ImageView（默认 17pt Medium）
 * @code
 * UIImageView *iv = [UIImageView sf_imageViewWithSymbol:@"info.circle"];
 * [self.view addSubview:iv];
 * @endcode
 */
+ (instancetype)sf_imageViewWithSymbol:(NSString *)name;

/**
 * @brief 快速创建 SF Symbol ImageView（自定义样式）
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
 * @brief 快速创建带兜底图片的 SF Symbol ImageView
 * @param symbolName        SF Symbol 名称
 * @param tintColor         图标染色
 * @param pointSize         字号
 * @param weight            字重
 * @param scale             缩放等级
 * @param fallbackImageName 当 Symbol 不可用时的兜底本地图片名
 * @code
 * UIImageView *iv = [UIImageView sf_imageViewWithSymbolName:@"custom.icon"
 *                                                 tintColor:UIColor.labelColor
 *                                                 pointSize:24.0
 *                                                    weight:UIImageSymbolWeightMedium
 *                                                     scale:UIImageSymbolScaleMedium
 *                                         fallbackImageName:@"placeholder_icon"];
 * @endcode
 */
+ (instancetype)sf_imageViewWithSymbolName:(NSString *)symbolName
                                 tintColor:(UIColor *)tintColor
                                 pointSize:(CGFloat)pointSize
                                    weight:(UIImageSymbolWeight)weight
                                     scale:(UIImageSymbolScale)scale
                         fallbackImageName:(nullable NSString *)fallbackImageName;

@end

NS_ASSUME_NONNULL_END
