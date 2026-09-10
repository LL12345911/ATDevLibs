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

#pragma mark - 状态（对齐 UIControl 语义）
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, readonly) UIControlState state;

#pragma mark - 标题（对齐 UIButton 风格 API）
@property (nonatomic, strong) UIFont *titleFont;   // 默认 system 17，设置后自动刷新
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

#pragma mark - 事件（UIControl 风格，sender 为按钮自身）
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;

#pragma mark - 图片位置与间距（设置后自动刷新）
@property (nonatomic, assign) ATButtonImagePosition imagePosition;
@property (nonatomic, assign) CGFloat spacing;   // 图片与文字间距，默认 4

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

#pragma mark - 类型（对齐 UIButton，固定返回 UIButtonTypeCustom）
@property (nonatomic, readonly) UIButtonType buttonType;

#pragma mark - 外观（只改 layer，立即生效）
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;


@end

NS_ASSUME_NONNULL_END
