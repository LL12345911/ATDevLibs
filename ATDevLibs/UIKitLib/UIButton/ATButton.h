//
//  ATButton.h
//  ATDevLibs
//
//  Created by Mars on 2026/9/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 图片与文字的相对位置
typedef NS_ENUM(NSUInteger, ATButtonImagePosition) {
    ATButtonImagePositionLeft,   // 图片在左，文字在右（默认，等同旧版 UIButton 行为）
    ATButtonImagePositionRight,  // 图片在右，文字在左
    ATButtonImagePositionTop,    // 图片在上，文字在下
    ATButtonImagePositionBottom  // 图片在下，文字在上
};


@interface ATButton : UIView

#pragma mark - 类型（对齐 UIButton）
+ (instancetype)buttonWithType:(UIButtonType)buttonType;
@property (nonatomic, readonly) UIButtonType buttonType; // 由 buttonWithType: 指定，init 默认 Custom

/// 便捷构造：title 或 image 可传 nil；为 Normal 状态同时设标题与图片
+ (instancetype)buttonWithTitle:(nullable NSString *)title image:(nullable UIImage *)image;


#pragma mark - 状态（对齐 UIControl 语义）
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, readonly) UIControlState state;

#pragma mark - 标题（对齐 UIButton 风格 API）
@property (nonatomic, strong) UIFont *titleFont;   // 默认 system 15，设置后自动刷新
- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state;
- (nullable NSString *)titleForState:(UIControlState)state;
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;
- (nullable UIColor *)titleColorForState:(UIControlState)state;
- (void)setAttributedTitle:(nullable NSAttributedString *)title forState:(UIControlState)state;
- (nullable NSAttributedString *)attributedTitleForState:(UIControlState)state;

#pragma mark - 图片
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;
- (nullable UIImage *)imageForState:(UIControlState)state;
- (void)setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state;
- (nullable UIImage *)backgroundImageForState:(UIControlState)state;

#pragma mark - 当前状态读取（对齐 UIButton）
@property (nonatomic, readonly, strong, nullable) NSString *currentTitle;
@property (nonatomic, readonly, strong, nullable) UIColor *currentTitleColor;
@property (nonatomic, readonly, strong, nullable) NSAttributedString *currentAttributedTitle;
@property (nonatomic, readonly, strong, nullable) UIImage *currentImage;
@property (nonatomic, readonly, strong, nullable) UIImage *currentBackgroundImage;

#pragma mark - 子视图（对齐 UIButton，只读）
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UIImageView *imageView;
/// 背景图视图（只读，可直接设置 contentMode 等属性）
@property (nonatomic, readonly, strong) UIImageView *backgroundImageView;

#pragma mark - 图片填充方式
/// imageView 的 contentMode，默认 UIViewContentModeScaleAspectFit
@property (nonatomic, assign) UIViewContentMode imageContentMode;
/// backgroundImageView 的 contentMode，默认 UIViewContentModeScaleToFill
@property (nonatomic, assign) UIViewContentMode backgroundImageContentMode;

#pragma mark - 事件（UIControl 风格，sender 为按钮自身）
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;

/// 是否启用点击缩放动画，默认 NO
@property (nonatomic, assign) BOOL enableTapScaleAnimation;

/// 点击缩放比例，默认 0.96（仅在 enableTapScaleAnimation 为 YES 时有效）
@property (nonatomic, assign) CGFloat tapScaleFactor;


#pragma mark - 图片位置与间距（设置后自动刷新）
@property (nonatomic, assign) ATButtonImagePosition imagePosition;
@property (nonatomic, assign) CGFloat spacing;   // 图片与文字间距，默认 0；twoEndsAlignment=YES 时复用为两端端边距

/// 两端对齐：YES 时图片贴一端、文字贴另一端（仅水平方向 Left/Right 生效；垂直方向或缺图/缺文字时回退默认布局）
/// 此时 spacing 复用为两端的端边距（图与文字各距其端 edge 距离）；
/// imagePosition 决定图与文字各在哪一端：Left=图在左端文字在右端，Right=文字在左端图在右端
/// 忽略 contentHorizontalAlignment；imageEdgeInsets / titleEdgeInsets 仍作为最终偏移叠加
@property (nonatomic, assign) BOOL twoEndsAlignment;

#pragma mark - 批量更新（挂起中间刷新，endUpdates 时统一刷新一次）
/// 连续设置多个属性时（如 title + color + image），用 beginUpdates/endUpdates 包起来可避免中间态多次刷新。
/// 可选优化，不调用时每个 setter 都会自动刷新，行为与旧版一致。
/// 用法：
///   [btn beginUpdates];
///   [btn setTitle:@"xxx" forState:UIControlStateNormal];
///   [btn setImage:img forState:UIControlStateNormal];
///   [btn endUpdates];   // 此处统一刷新一次
- (void)beginUpdates;
- (void)endUpdates;

#pragma mark - iOS 15 起废弃的 insets（保留旧版语义，设置后自动刷新）
@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@property (nonatomic) UIEdgeInsets titleEdgeInsets;
@property (nonatomic) UIEdgeInsets imageEdgeInsets;

#pragma mark - 内容对齐（对齐 UIButton）
@property (nonatomic) UIControlContentHorizontalAlignment contentHorizontalAlignment;
@property (nonatomic) UIControlContentVerticalAlignment contentVerticalAlignment;

#pragma mark - 图片高亮/禁用处理（对齐 UIButton）
@property (nonatomic) BOOL adjustsImageWhenHighlighted;   // 默认 YES，高亮时图片变暗
@property (nonatomic) BOOL adjustsImageWhenDisabled;      // 默认 YES，禁用时图片变暗
@property (nonatomic) BOOL showsTouchWhenHighlighted;     // 默认 NO，高亮时显示覆盖层

#pragma mark - 标题阴影（对齐 UIButton）
/// 标题阴影偏移，默认 {0, -1}（阴影向上），与 UIButton 默认一致
@property (nonatomic, assign) CGSize titleShadowOffset;
- (void)setTitleShadowColor:(nullable UIColor *)color forState:(UIControlState)state;
- (nullable UIColor *)titleShadowColorForState:(UIControlState)state;
@property (nonatomic, readonly, strong, nullable) UIColor *currentTitleShadowColor;

/// 高亮时是否翻转阴影方向（默认 YES）：高亮时阴影变为 {0, 1} 向下
@property (nonatomic) BOOL reversesTitleShadowWhenHighlighted;

#pragma mark - 跟踪状态（对齐 UIControl，只读）
/// 跟踪中：有手指按下且尚未松开
@property (nonatomic, readonly, getter=isTracking) BOOL tracking;
/// 当前触摸点是否在按钮内部
@property (nonatomic, readonly, getter=isTouchInside) BOOL touchInside;

#pragma mark - 事件查询（对齐 UIControl）
@property (nonatomic, readonly) NSSet *allTargets;
@property (nonatomic, readonly) UIControlEvents allControlEvents;
- (NSArray<NSString *> *)actionsForTarget:(nullable id)target forControlEvent:(UIControlEvents)controlEvent;

#pragma mark - 点击区域扩展
/// 扩大点击热区：insets 负值表示向外扩展（如 {-10,-10,-10,-10} 各方向扩大 10pt）
@property (nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

#pragma mark - SF Symbol 配置（iOS 13+，对齐 UIButton）
- (void)setPreferredSymbolConfiguration:(nullable UIImageSymbolConfiguration *)configuration forImageInState:(UIControlState)state API_AVAILABLE(ios(13.0));
- (nullable UIImageSymbolConfiguration *)preferredSymbolConfigurationForImageInState:(UIControlState)state API_AVAILABLE(ios(13.0));

#pragma mark - 角色（iOS 14+，对齐 UIButton）
@property (nonatomic) UIButtonRole role API_AVAILABLE(ios(14.0));

#pragma mark - 切换选中（iOS 15+，对齐 UIButton）
/// YES 时，点击（TouchUpInside）会自动切换 selected 状态，模拟 toggle 按钮
@property (nonatomic) BOOL changesSelectionAsPrimaryAction API_AVAILABLE(ios(15.0));

#pragma mark - 大内容辅助（iOS 11+，对齐 UIButton）
@property (nonatomic, copy, nullable) NSString *largeContentTitle API_AVAILABLE(ios(11.0));
@property (nonatomic) BOOL scalesLargeContentImage API_AVAILABLE(ios(11.0));
@property (nonatomic, strong, nullable) UIImage *largeContentImage API_AVAILABLE(ios(11.0));


#pragma mark - 外观（只改 layer，立即生效）
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;


@end

NS_ASSUME_NONNULL_END
