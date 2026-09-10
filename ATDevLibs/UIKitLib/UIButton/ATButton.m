//
//  ATButton.m
//  ATDevLibs
//
//  Created by Mars on 2026/9/10.
//

#import "ATButton.h"


#pragma mark - 内部辅助：一组 target/action/事件
@interface _ButtonTargetAction : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) UIControlEvents events;

@end


@implementation _ButtonTargetAction

@end

#pragma mark - KVO context
static char kCustomButtonKVOTitleFont;
static char kCustomButtonKVOTitleText;
static char kCustomButtonKVOTitleAttr;

#pragma mark - CustomButton
@interface ATButton ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong, nullable) UIView *highlightEffectView;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *titles;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *titleColors;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSAttributedString *> *attributedTitles;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *images;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *backgroundImages;
@property (nonatomic, strong) NSMutableArray<_ButtonTargetAction *> *targetActions;
@property (nonatomic, assign) BOOL touchInside;

@end

@implementation ATButton

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) [self setup];
    return self;
}

- (void)dealloc {
    if (_titleLabel) {
        [_titleLabel removeObserver:self forKeyPath:@"font"];
        [_titleLabel removeObserver:self forKeyPath:@"text"];
        [_titleLabel removeObserver:self forKeyPath:@"attributedText"];
    }
}

- (void)setup {
    _enabled = YES;
    _imagePosition = ATButtonImagePositionLeft;
    _spacing = 4.0;
    _contentEdgeInsets = UIEdgeInsetsZero;
    _titleEdgeInsets = UIEdgeInsetsZero;
    _imageEdgeInsets = UIEdgeInsetsZero;
    _cornerRadius = 0;
    _borderWidth = 0;
    _titleFont = [UIFont systemFontOfSize:17];
    _contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _adjustsImageWhenHighlighted = YES;
    _adjustsImageWhenDisabled = YES;
    _showsTouchWhenHighlighted = NO;
    
    _titles = [NSMutableDictionary dictionary];
    _titleColors = [NSMutableDictionary dictionary];
    _attributedTitles = [NSMutableDictionary dictionary];
    _images = [NSMutableDictionary dictionary];
    _backgroundImages = [NSMutableDictionary dictionary];
    _targetActions = [NSMutableArray array];
    
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.userInteractionEnabled = NO;
    [self insertSubview:_backgroundImageView atIndex:0];   // 最底层：背景图
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.userInteractionEnabled = NO;               // 避免子视图拦截触摸
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 1;                         // 默认单行，外部可改为 2 / 3 / 0
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.font = _titleFont;
    _titleLabel.textColor = [UIColor blackColor];
    [self addSubview:_titleLabel];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = NO;
    [self addSubview:_imageView];
    
    self.layer.masksToBounds = YES;
    
    // KVO：外部直接改 titleLabel 属性也能自动刷新布局
    [_titleLabel addObserver:self forKeyPath:@"font"           options:0 context:&kCustomButtonKVOTitleFont];
    [_titleLabel addObserver:self forKeyPath:@"text"           options:0 context:&kCustomButtonKVOTitleText];
    [_titleLabel addObserver:self forKeyPath:@"attributedText" options:0 context:&kCustomButtonKVOTitleAttr];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == _titleLabel &&
        (context == &kCustomButtonKVOTitleFont ||
         context == &kCustomButtonKVOTitleText ||
         context == &kCustomButtonKVOTitleAttr)) {
        [self _refreshLayout];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - 布局刷新（设置属性后统一调用）
- (void)_refreshLayout {
    [self setNeedsLayout];                 // 触发 layoutSubviews 重排
    [self invalidateIntrinsicContentSize]; // 让 AutoLayout 重新询问内容尺寸
}

#pragma mark - 状态（组合为 UIControlState）
- (UIControlState)state {
    UIControlState s = UIControlStateNormal;
    if (self.highlighted) s |= UIControlStateHighlighted;
    if (self.selected)    s |= UIControlStateSelected;
    if (!self.enabled)    s |= UIControlStateDisabled;
    return s;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted == highlighted) return;
    _highlighted = highlighted;
    [self refreshContentForCurrentState];
    [self animatePress:highlighted];
    [self updateImageAppearance];
    [self updateHighlightEffect];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self refreshContentForCurrentState];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self refreshContentForCurrentState];
    [self updateImageAppearance];
}

#pragma mark - 按状态取值（含回退逻辑，模拟 UIButton）
- (nullable id)_valueInDict:(NSDictionary *)dict forState:(UIControlState)state {
    id v = dict[@(state)];                                  // 1. 精确匹配
    if (v) return v;
    if (state & UIControlStateHighlighted) {                // 2. 回退 Highlighted
        v = dict[@(UIControlStateHighlighted)];
        if (v) return v;
    }
    if (state & UIControlStateSelected) {                   // 3. 回退 Selected
        v = dict[@(UIControlStateSelected)];
        if (v) return v;
    }
    if (state & UIControlStateDisabled) {                   // 4. 回退 Disabled
        v = dict[@(UIControlStateDisabled)];
        if (v) return v;
    }
    return dict[@(UIControlStateNormal)];                   // 5. 最终回退 Normal
}

- (void)refreshContentForCurrentState {
    UIControlState s = self.state;
    
    NSAttributedString *attr = [self _valueInDict:_attributedTitles forState:s];
    if (attr) {
        self.titleLabel.attributedText = attr;              // 有 attributedTitle 优先
    } else {
        self.titleLabel.attributedText = nil;               // 清掉旧的富文本
        self.titleLabel.text = [self _valueInDict:_titles forState:s];
        self.titleLabel.textColor = [self _valueInDict:_titleColors forState:s] ?: [UIColor blackColor];
    }
    self.imageView.image = [self _valueInDict:_images forState:s];
    self.backgroundImageView.image = [self _valueInDict:_backgroundImages forState:s];
    
    [self _refreshLayout];                                  // 内容变化，位置和尺寸都可能变
}

#pragma mark - 标题 API
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    if (title) _titles[@(state)] = title;
    else [_titles removeObjectForKey:@(state)];
    [self refreshContentForCurrentState];
}

- (NSString *)titleForState:(UIControlState)state {
    return [self _valueInDict:_titles forState:state];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (color) _titleColors[@(state)] = color;
    else [_titleColors removeObjectForKey:@(state)];
    [self refreshContentForCurrentState];
}

- (UIColor *)titleColorForState:(UIControlState)state {
    return [self _valueInDict:_titleColors forState:state];
}

- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state {
    if (title) _attributedTitles[@(state)] = title;
    else [_attributedTitles removeObjectForKey:@(state)];
    [self refreshContentForCurrentState];
}

- (NSAttributedString *)attributedTitleForState:(UIControlState)state {
    return [self _valueInDict:_attributedTitles forState:state];
}

#pragma mark - 图片 API
- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (image) _images[@(state)] = image;
    else [_images removeObjectForKey:@(state)];
    [self refreshContentForCurrentState];
}

- (UIImage *)imageForState:(UIControlState)state {
    return [self _valueInDict:_images forState:state];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    if (image) _backgroundImages[@(state)] = image;
    else [_backgroundImages removeObjectForKey:@(state)];
    [self refreshContentForCurrentState];
}

- (UIImage *)backgroundImageForState:(UIControlState)state {
    return [self _valueInDict:_backgroundImages forState:state];
}

#pragma mark - 当前状态读取（对齐 UIButton）
- (NSString *)currentTitle {
    return [self _valueInDict:_titles forState:self.state];
}

- (UIColor *)currentTitleColor {
    return [self _valueInDict:_titleColors forState:self.state];
}

- (NSAttributedString *)currentAttributedTitle {
    return [self _valueInDict:_attributedTitles forState:self.state];
}

- (UIImage *)currentImage {
    return [self _valueInDict:_images forState:self.state];
}

- (UIImage *)currentBackgroundImage {
    return [self _valueInDict:_backgroundImages forState:self.state];
}

- (UIButtonType)buttonType {
    return UIButtonTypeCustom;
}

#pragma mark - 事件机制
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    for (_ButtonTargetAction *ta in _targetActions) {
        if (ta.target == target && ta.action == action && ta.events == controlEvents) return; // 去重
    }
    _ButtonTargetAction *ta = [[_ButtonTargetAction alloc] init];
    ta.target = target;
    ta.action = action;
    ta.events = controlEvents;
    [_targetActions addObject:ta];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    NSMutableArray *toRemove = [NSMutableArray array];
    for (_ButtonTargetAction *ta in _targetActions) {
        BOOL hitTarget = (target == nil || ta.target == target);
        BOOL hitAction = (action == NULL || ta.action == action);
        BOOL hitEvents = (controlEvents == 0 || (ta.events & controlEvents) != 0);
        if (hitTarget && hitAction && hitEvents) [toRemove addObject:ta];
    }
    [_targetActions removeObjectsInArray:toRemove];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    for (_ButtonTargetAction *ta in _targetActions) {
        if ((ta.events & controlEvents) && ta.target && ta.action
            && [ta.target respondsToSelector:ta.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [ta.target performSelector:ta.action withObject:self];   // sender 为按钮自身
#pragma clang diagnostic pop
        }
    }
}

#pragma mark - 触摸处理（模拟 UIControl）
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) return;
    self.highlighted = YES;
    self.touchInside = YES;
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) return;
    UITouch *t = touches.anyObject;
    BOOL inside = CGRectContainsPoint(self.bounds, [t locationInView:self]);
    if (inside != self.touchInside) {
        self.touchInside = inside;
        self.highlighted = inside;
        [self sendActionsForControlEvents:inside ? UIControlEventTouchDragEnter
                                         : UIControlEventTouchDragExit];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) return;
    UITouch *t = touches.anyObject;
    BOOL inside = CGRectContainsPoint(self.bounds, [t locationInView:self]);
    self.highlighted = NO;
    self.touchInside = NO;
    [self sendActionsForControlEvents:inside ? UIControlEventTouchUpInside
                                     : UIControlEventTouchUpOutside];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) return;
    self.highlighted = NO;
    self.touchInside = NO;
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
}

#pragma mark - 图片外观（adjustsImageWhenHighlighted / Disabled）
- (void)updateImageAppearance {
    CGFloat alpha = 1.0;
    if (!self.enabled && self.adjustsImageWhenDisabled)        alpha = 0.5;
    if (self.highlighted && self.adjustsImageWhenHighlighted)  alpha = MIN(alpha, 0.5);
    self.imageView.alpha = alpha;
}

#pragma mark - 高亮覆盖层（showsTouchWhenHighlighted）
- (void)updateHighlightEffect {
    if (!self.showsTouchWhenHighlighted) {
        [_highlightEffectView removeFromSuperview];
        _highlightEffectView = nil;
        return;
    }
    if (!_highlightEffectView) {
        UIView *v = [[UIView alloc] initWithFrame:self.bounds];
        v.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
        v.userInteractionEnabled = NO;
        [self addSubview:v];
        _highlightEffectView = v;
    }
    _highlightEffectView.frame = self.bounds;
    _highlightEffectView.layer.cornerRadius = self.layer.cornerRadius;
    _highlightEffectView.hidden = !self.highlighted;
}

#pragma mark - 测量标题（maxWidth 为宽度上限，受 numberOfLines 行数上限截断）
/// 测量标题；maxWidth 为宽度上限
/// numberOfLines 语义（与 UILabel 一致）：
///   0  → 不限行数，返回完整换行高度
///   1  → 单行，不换行
///   N>1 → 最多 N 行，超过的部分截断（高度不超过 N 行）
- (CGSize)_measureTitleWithMaxWidth:(CGFloat)maxWidth {
    NSString *text = self.titleLabel.text;
    if (text.length == 0) return CGSizeZero;
    
    NSAttributedString *attr = self.titleLabel.attributedText;
    NSAttributedString *str = attr;
    if (!str) {
        str = [[NSAttributedString alloc] initWithString:text
                                              attributes:@{NSFontAttributeName: self.titleLabel.font}];
    }
    CGRect r = [str boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 context:nil];
    CGSize size = CGSizeMake(ceil(r.size.width), ceil(r.size.height));
    
    // numberOfLines > 1 时，高度不超过 lines 行（超出截断）
    NSInteger maxLines = self.titleLabel.numberOfLines;
    if (maxLines > 1) {
        CGFloat lineHeight = ceil(self.titleLabel.font.lineHeight);
        size.height = MIN(size.height, lineHeight * maxLines);
    }
    // numberOfLines == 0：不截断，返回全部行高
    // numberOfLines == 1：单行，高度自然为一行
    return size;
}

#pragma mark - 布局（edgeInsets + 图片位置 + 多行 + 单内容居中 + 对齐）
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundImageView.frame = self.bounds;            // 背景图始终铺满
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, self.contentEdgeInsets);
    
    UIImage *img = self.imageView.image;
    BOOL hasImage = img.size.width > 0 && img.size.height > 0;
    BOOL hasTitle = self.titleLabel.text.length > 0;
    BOOL multiline = self.titleLabel.numberOfLines != 1;
    CGFloat gap = (hasImage && hasTitle) ? self.spacing : 0;
    
    BOOL horizontal = (self.imagePosition == ATButtonImagePositionLeft ||
                       self.imagePosition == ATButtonImagePositionRight);
    
    // 标题可用宽度：水平布局时扣掉图片 + 间距
    CGFloat availableTitleWidth = CGRectGetWidth(contentRect);
    if (horizontal && hasImage) {
        availableTitleWidth = MAX(0, availableTitleWidth - img.size.width - gap);
    }
    
    // 测量标题（多行按可用宽度换行）
    CGSize titleSize = CGSizeZero;
    if (hasTitle) {
        if (multiline) {
            titleSize = [self _measureTitleWithMaxWidth:availableTitleWidth];
            titleSize.width = MIN(titleSize.width, availableTitleWidth);
        } else {
            titleSize = [self _measureTitleWithMaxWidth:CGFLOAT_MAX];
        }
    }
    
    // 主轴总尺寸，默认整体居中
    CGFloat mainTotal = horizontal ? (img.size.width + gap + titleSize.width)
    : (img.size.height + gap + titleSize.height);
    CGFloat crossMax = horizontal ? MAX(img.size.height, titleSize.height)
    : MAX(img.size.width, titleSize.width);
    
    CGFloat startX = CGRectGetMidX(contentRect) - (horizontal ? mainTotal : crossMax) / 2;
    CGFloat startY = CGRectGetMidY(contentRect) - (horizontal ? crossMax : mainTotal) / 2;
    
    // 先按"图片在左/上"摆好
    CGRect imgFrame = CGRectZero, titleFrame = CGRectZero;
    if (horizontal) {
        imgFrame = CGRectMake(startX,
                              CGRectGetMidY(contentRect) - img.size.height / 2,
                              img.size.width, img.size.height);
        titleFrame = CGRectMake(startX + img.size.width + gap,
                                CGRectGetMidY(contentRect) - titleSize.height / 2,
                                titleSize.width, titleSize.height);
        if (self.imagePosition == ATButtonImagePositionRight) {
            imgFrame.origin.x = startX + titleSize.width + gap;
            titleFrame.origin.x = startX;
        }
    } else {
        imgFrame = CGRectMake(CGRectGetMidX(contentRect) - img.size.width / 2,
                              startY,
                              img.size.width, img.size.height);
        titleFrame = CGRectMake(CGRectGetMidX(contentRect) - titleSize.width / 2,
                                startY + img.size.height + gap,
                                titleSize.width, titleSize.height);
        if (self.imagePosition == ATButtonImagePositionBottom) {
            imgFrame.origin.y = startY + titleSize.height + gap;
            titleFrame.origin.y = startY;
        }
    }
    
    // 只有图片或只有文字时，单独居中
    if (!hasTitle) {
        imgFrame.origin.x = CGRectGetMidX(contentRect) - img.size.width / 2;
        imgFrame.origin.y = CGRectGetMidY(contentRect) - img.size.height / 2;
    } else if (!hasImage) {
        titleFrame.origin.x = CGRectGetMidX(contentRect) - titleSize.width / 2;
        titleFrame.origin.y = CGRectGetMidY(contentRect) - titleSize.height / 2;
    }
    
    // 应用废弃 API 的 insets（正 left/top = 向右/向下偏移，与旧版 UIButton 方向一致）
    imgFrame.origin.x   += self.imageEdgeInsets.left - self.imageEdgeInsets.right;
    imgFrame.origin.y   += self.imageEdgeInsets.top  - self.imageEdgeInsets.bottom;
    titleFrame.origin.x += self.titleEdgeInsets.left - self.titleEdgeInsets.right;
    titleFrame.origin.y += self.titleEdgeInsets.top  - self.titleEdgeInsets.bottom;
    
    // 内容对齐（仅合并非零 frame，避免零尺寸 frame 干扰包围盒）
    CGRect contentBox = CGRectZero;
    BOOL hasBox = NO;
    if (imgFrame.size.width > 0 || imgFrame.size.height > 0) {
        contentBox = imgFrame;
        hasBox = YES;
    }
    if (titleFrame.size.width > 0 || titleFrame.size.height > 0) {
        contentBox = hasBox ? CGRectUnion(contentBox, titleFrame) : titleFrame;
    }
    if (hasBox) {
        CGFloat dx = 0, dy = 0;
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                dx = CGRectGetMinX(contentRect) - CGRectGetMinX(contentBox);
                break;
            case UIControlContentHorizontalAlignmentRight:
                dx = CGRectGetMaxX(contentRect) - CGRectGetMaxX(contentBox);
                break;
            default:                                    // Center / Fill：保持居中
                break;
        }
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop:
                dy = CGRectGetMinY(contentRect) - CGRectGetMinY(contentBox);
                break;
            case UIControlContentVerticalAlignmentBottom:
                dy = CGRectGetMaxY(contentRect) - CGRectGetMaxY(contentBox);
                break;
            default:                                    // Center / Fill：保持居中
                break;
        }
        imgFrame.origin.x += dx;   imgFrame.origin.y += dy;
        titleFrame.origin.x += dx; titleFrame.origin.y += dy;
    }
    
    self.imageView.frame = imgFrame;
    self.titleLabel.frame = titleFrame;
    _highlightEffectView.frame = self.bounds;
}

#pragma mark - 尺寸计算（sizeThatFits / sizeToFit / intrinsicContentSize 统一入口）

/// 内容自然尺寸；titleMaxWidth > 0 时按该宽度对多行标题换行测量
- (CGSize)_fittingContentSizeWithMaxTitleWidth:(CGFloat)titleMaxWidth {
    UIImage *img = self.imageView.image;
    BOOL hasImage = img.size.width > 0 && img.size.height > 0;
    BOOL hasTitle = self.titleLabel.text.length > 0;
    BOOL multiline = self.titleLabel.numberOfLines != 1;
    CGFloat gap = (hasImage && hasTitle) ? self.spacing : 0;
    
    CGSize titleSize = CGSizeZero;
    if (hasTitle) {
        if (multiline && titleMaxWidth > 0) {
            titleSize = [self _measureTitleWithMaxWidth:titleMaxWidth];
            titleSize.width = MIN(titleSize.width, titleMaxWidth);
        } else {
            titleSize = [self _measureTitleWithMaxWidth:CGFLOAT_MAX];
        }
    }
    
    BOOL horizontal = (self.imagePosition == ATButtonImagePositionLeft ||
                       self.imagePosition == ATButtonImagePositionRight);
    
    CGFloat w, h;
    if (horizontal) {
        w = img.size.width + gap + (hasTitle ? titleSize.width : 0);
        h = MAX(img.size.height, hasTitle ? titleSize.height : 0);
    } else {
        w = MAX(img.size.width, hasTitle ? titleSize.width : 0);
        h = img.size.height + gap + (hasTitle ? titleSize.height : 0);
    }
    w += self.contentEdgeInsets.left + self.contentEdgeInsets.right;
    h += self.contentEdgeInsets.top  + self.contentEdgeInsets.bottom;
    return CGSizeMake(ceil(w), ceil(h));
}

- (CGSize)fittingContentSize {
    return [self _fittingContentSizeWithMaxTitleWidth:CGFLOAT_MAX];
}

- (CGSize)sizeThatFits:(CGSize)size {
    BOOL multiline = self.titleLabel.numberOfLines != 1;
    if (multiline && size.width > 0) {
        // 多行 + 宽度受限：把整体宽度约束换算成标题可用宽，返回真实换行高度
        UIImage *img = self.imageView.image;
        BOOL hasImage = img.size.width > 0 && img.size.height > 0;
        BOOL hasTitle = self.titleLabel.text.length > 0;
        CGFloat gap = (hasImage && hasTitle) ? self.spacing : 0;
        BOOL horizontal = (self.imagePosition == ATButtonImagePositionLeft ||
                           self.imagePosition == ATButtonImagePositionRight);
        
        CGFloat titleMax = size.width;
        if (horizontal && hasImage) {
            titleMax = MAX(0, titleMax - img.size.width - gap);
        }
        return [self _fittingContentSizeWithMaxTitleWidth:titleMax];
    }
    // 单行或宽度不受限：内容自然尺寸 + 上限约束
    CGSize fitting = [self fittingContentSize];
    if (size.width > 0 && fitting.width > size.width) {
        fitting.width = size.width;
    }
    if (size.height > 0 && fitting.height > size.height) {
        fitting.height = size.height;
    }
    return fitting;
}

- (void)sizeToFit {
    // 单行自然尺寸；多行按钮请用 sizeThatFits: 传宽度约束，或固定宽度 + AutoLayout
    CGSize size = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGPoint center = self.center;
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    self.center = center;
}

- (CGSize)intrinsicContentSize {
    // AutoLayout 默认按"最紧凑单行"上报；配合宽度约束后换行显示，
    // 需要完整多行高度时用 sizeThatFits: 计算后约束高度
    return [self fittingContentSize];
}

#pragma mark - 属性 setter（设置后自动刷新布局与尺寸）

- (void)setImagePosition:(ATButtonImagePosition)imagePosition {
    if (_imagePosition == imagePosition) return;
    _imagePosition = imagePosition;
    [self _refreshLayout];
}

- (void)setSpacing:(CGFloat)spacing {
    if (_spacing == spacing) return;
    _spacing = spacing;
    [self _refreshLayout];
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentEdgeInsets, contentEdgeInsets)) return;
    _contentEdgeInsets = contentEdgeInsets;
    [self _refreshLayout];
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_titleEdgeInsets, titleEdgeInsets)) return;
    _titleEdgeInsets = titleEdgeInsets;
    [self _refreshLayout];
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_imageEdgeInsets, imageEdgeInsets)) return;
    _imageEdgeInsets = imageEdgeInsets;
    [self _refreshLayout];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont ?: [UIFont systemFontOfSize:17];
    self.titleLabel.font = _titleFont;   // 会经 KVO 再刷新一次，无副作用
    [self _refreshLayout];
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    if (_contentHorizontalAlignment == contentHorizontalAlignment) return;
    _contentHorizontalAlignment = contentHorizontalAlignment;
    [self _refreshLayout];
}

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    if (_contentVerticalAlignment == contentVerticalAlignment) return;
    _contentVerticalAlignment = contentVerticalAlignment;
    [self _refreshLayout];
}

- (void)setAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted {
    _adjustsImageWhenHighlighted = adjustsImageWhenHighlighted;
    [self updateImageAppearance];
}

- (void)setAdjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled {
    _adjustsImageWhenDisabled = adjustsImageWhenDisabled;
    [self updateImageAppearance];
}

- (void)setShowsTouchWhenHighlighted:(BOOL)showsTouchWhenHighlighted {
    _showsTouchWhenHighlighted = showsTouchWhenHighlighted;
    [self updateHighlightEffect];
}

#pragma mark - 按下动画（不想要就删掉此方法）
- (void)animatePress:(BOOL)pressed {
    [UIView animateWithDuration:pressed ? 0.08 : 0.12
                     animations:^{
        self.transform = pressed ? CGAffineTransformMakeScale(0.96, 0.96)
        : CGAffineTransformIdentity;
    }];
}

#pragma mark - 外观 setter（只改 layer，立即生效）
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    _highlightEffectView.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

@end
