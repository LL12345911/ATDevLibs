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

@property (nonatomic, assign) UIButtonType buttonType;
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
// 批处理挂起：suspendLevel>0 时 setter 仅标记 pendingRefresh，不立即刷新
@property (nonatomic, assign) NSInteger suspendLevel;
@property (nonatomic, assign) BOOL pendingRefresh;
// 标题尺寸缓存：titleCacheVersion 变化即失效；cachedTitleVersion/MaxWidth/Size 三者共同命中才复用
@property (nonatomic, assign) NSInteger titleCacheVersion;
@property (nonatomic, assign) NSInteger cachedTitleVersion;
@property (nonatomic, assign) CGFloat   cachedTitleMaxWidth;
@property (nonatomic, assign) CGSize    cachedTitleSize;

@end

@implementation ATButton

#pragma mark - 初始化
+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    ATButton *button = [[self alloc] init];      // 走 initWithFrame: → setup
    [button configureForType:buttonType];
    return button;
}

+ (instancetype)buttonWithTitle:(NSString *)title image:(UIImage *)image {
    ATButton *button = [[self alloc] init];
    if (title) [button setTitle:title forState:UIControlStateNormal];
    if (image) [button setImage:image forState:UIControlStateNormal];
    return button;
}

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
    _buttonType = UIButtonTypeCustom;   // 新增这一行
    _imagePosition = ATButtonImagePositionLeft;
    _spacing = 0.0;
    _twoEndsAlignment = NO;
    _contentEdgeInsets = UIEdgeInsetsZero;
    _titleEdgeInsets = UIEdgeInsetsZero;
    _imageEdgeInsets = UIEdgeInsetsZero;
    _cornerRadius = 0;
    _borderWidth = 0;
    _titleFont = [UIFont systemFontOfSize:15];
    _contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _adjustsImageWhenHighlighted = YES;
    _adjustsImageWhenDisabled = YES;
    _showsTouchWhenHighlighted = NO;
    // 批处理挂起状态
    _suspendLevel = 0;            // > 0 表示处于 beginUpdates/endUpdates 之间
    _pendingRefresh = NO;         // 挂起期间是否有 setter 触发过刷新
    // 标题尺寸缓存（按 version + maxWidth 失效）
    _titleCacheVersion = 0;       // 任何属性变化都 bump，使缓存失效（保守策略）
    _cachedTitleVersion = -1;     // 上次计算时的 version，-1 表示无缓存
    _cachedTitleMaxWidth = -1;    // 上次计算时的 maxWidth
    _cachedTitleSize = CGSizeZero;
    
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
    _titleLabel.numberOfLines = 1;                         // 默认单行；0=不限行，N=最多 N 行
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.font = _titleFont;
    _titleLabel.textColor = [UIColor whiteColor];
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

#pragma mark - 类型配置
- (void)configureForType:(UIButtonType)buttonType {
    _buttonType = buttonType;
    switch (buttonType) {
        case UIButtonTypeSystem:                      // iOS 7+，近似系统样式
            [self applySystemStyle];
            break;
        case UIButtonTypeDetailDisclosure:
            [self _setSystemIcon:@"info.circle"];
            break;
        case UIButtonTypeInfoLight:
        case UIButtonTypeInfoDark:
            [self _setSystemIcon:@"info.circle"];
            break;
        case UIButtonTypeContactAdd:
            [self _setSystemIcon:@"plus.circle"];
            break;
        case UIButtonTypeClose:                       // iOS 15+
            [self _setSystemIcon:@"xmark"];
            break;
        case UIButtonTypeCustom:
        default:
            break;                                    // 完全自定义，保持默认
    }
}

/// 近似系统样式：蓝色文字、透明背景、按压变灰
- (void)applySystemStyle {
    [self setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor systemGrayColor] forState:UIControlStateHighlighted];
    self.backgroundColor = [UIColor clearColor];
}

/// 用 SF Symbol 近似系统图标按钮（iOS 13+；低于 13 时 systemImageNamed 返回 nil，需自行 setImage:）
- (void)_setSystemIcon:(NSString *)symbolName {
    if (@available(iOS 13.0, *)) {
        UIImage *img = [UIImage systemImageNamed:symbolName];
        if (!img) return;
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:img forState:UIControlStateNormal];
        self.imageView.tintColor = [UIColor systemBlueColor];
    }
    self.backgroundColor = [UIColor clearColor];
}



#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _titleLabel &&
        (context == &kCustomButtonKVOTitleFont ||
         context == &kCustomButtonKVOTitleText ||
         context == &kCustomButtonKVOTitleAttr)) {
        [self _refreshLayout];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - 布局刷新（所有 setter 统一入口）
/// 1) bump 标题尺寸缓存版本号（保守失效策略）
/// 2) 若处于批处理挂起态（suspendLevel>0），仅标记 pendingRefresh 直接返回
/// 3) 否则触发 setNeedsLayout + invalidateIntrinsicContentSize
- (void)_refreshLayout {
    _titleCacheVersion++;                       // 任何属性变化都让标题尺寸缓存失效（保守策略）
    if (_suspendLevel > 0) {                    // 批处理进行中：仅标记，不刷新
        _pendingRefresh = YES;
        return;
    }
    [self setNeedsLayout];                      // 触发 layoutSubviews 重排
    [self invalidateIntrinsicContentSize];      // 让 AutoLayout 重新询问内容尺寸
}

#pragma mark - 批量更新
/// 挂起刷新：可嵌套调用，最外层 endUpdates 才真正触发一次刷新
- (void)beginUpdates { _suspendLevel++; }
/// 结束挂起：suspendLevel 归零且期间有 setter 标记过 pendingRefresh 时，统一刷新一次
- (void)endUpdates {
    if (_suspendLevel > 0) _suspendLevel--;
    if (_suspendLevel == 0 && _pendingRefresh) {
        _pendingRefresh = NO;
        [self _refreshLayout];                  // 此时 _titleCacheVersion 已 bump 过；本调用再 bump 一次无副作用
    }
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
        self.titleLabel.textColor = [self _valueInDict:_titleColors forState:s] ?: [UIColor whiteColor];
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
    return _buttonType;
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
        [self sendActionsForControlEvents:inside ? UIControlEventTouchDragEnter : UIControlEventTouchDragExit];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) return;
    UITouch *t = touches.anyObject;
    BOOL inside = CGRectContainsPoint(self.bounds, [t locationInView:self]);
    self.highlighted = NO;
    self.touchInside = NO;
    [self sendActionsForControlEvents:inside ? UIControlEventTouchUpInside : UIControlEventTouchUpOutside];
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

#pragma mark - 水平对齐解析
/// 将 Leading/Trailing 按当前语义方向（RTL/LTR）解析为具体的 Left/Right
/// iOS 11+ 提供 Leading/Trailing；低于 11 或非 Leading/Trailing 直接返回原值
- (UIControlContentHorizontalAlignment)_resolvedHorizontalAlignment {
    UIControlContentHorizontalAlignment hAlign = self.contentHorizontalAlignment;
    if (@available(iOS 11.0, *)) {
        if (hAlign == UIControlContentHorizontalAlignmentLeading ||
            hAlign == UIControlContentHorizontalAlignmentTrailing) {
            BOOL isRTL = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
            if (hAlign == UIControlContentHorizontalAlignmentLeading) {
                hAlign = isRTL ? UIControlContentHorizontalAlignmentRight : UIControlContentHorizontalAlignmentLeft;
            } else {
                hAlign = isRTL ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
            }
        }
    }
    return hAlign;
}

#pragma mark - 图文间距
/// 图片与文字之间的基础间距，仅由spacing控制；
/// imageEdgeInsets / titleEdgeInsets 仅做位置偏移，不参与图文间隙计算（对齐原生UIButton）
- (CGFloat)_gapBetweenImageAndTitle {
    UIImage *img = self.imageView.image;
    BOOL hasImage = img.size.width > 0 && img.size.height > 0;
    BOOL hasTitle = self.titleLabel.text.length > 0;
    if (!hasImage || !hasTitle) return 0;
    return self.spacing;
}


#pragma mark - 测量标题（maxWidth 为宽度上限，受 numberOfLines 行数上限截断）
/// 测量标题；maxWidth 为宽度上限
/// numberOfLines 语义（与 UILabel 一致）：
///   0  → 不限行数，返回完整换行高度
///   1  → 单行，不换行
///   N>1 → 最多 N 行，超过的部分截断（高度不超过 N 行）
- (CGSize)_measureTitleWithMaxWidth:(CGFloat)maxWidth {
    NSString *text = self.titleLabel.text;
    if (text.length == 0) { _cachedTitleSize = CGSizeZero; return CGSizeZero; }

    // 命中缓存：版本号一致 + 同一 maxWidth 才复用（不同宽度换行结果不同）
    if (_cachedTitleVersion == _titleCacheVersion && _cachedTitleMaxWidth == maxWidth) {
        return _cachedTitleSize;
    }

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

    _cachedTitleVersion  = _titleCacheVersion;
    _cachedTitleMaxWidth = maxWidth;
    _cachedTitleSize     = size;
    return size;
}

#pragma mark - 两端对齐（水平方向：图与文字分别贴左右两端）
/// 仅当 twoEndsAlignment == YES 且同时存在图片与文字、且为水平方向时调用
/// spacing 复用为两端端边距（图距其端 = spacing，文字距其端 = spacing）
/// imagePosition: Left → 图在左端、文字在右端；Right → 文字在左端、图在右端
/// imageEdgeInsets / titleEdgeInsets 作为最终偏移叠加；垂直方向沿用 contentVerticalAlignment
- (void)_layoutTwoEndsHorizontalInRect:(CGRect)contentRect image:(UIImage *)img {
    UIImage *image = img ?: self.imageView.image;
    if (!image) return;

    CGFloat gap = self.spacing;                       // 端边距
    CGFloat cw = CGRectGetWidth(contentRect);
    CGFloat imgW = image.size.width;
    CGFloat imgH = image.size.height;

    // 标题可用宽度：总宽 - 图宽 - 两端 gap
    CGFloat availableTitleWidth = MAX(0, cw - imgW - gap * 2);
    CGSize titleSize = [self _measureTitleWithMaxWidth:availableTitleWidth];
    titleSize.width  = MIN(titleSize.width, availableTitleWidth);

    // 垂直对齐：以图文整体在 contentRect 内对齐
    CGFloat contentHeight = MAX(imgH, titleSize.height);
    CGFloat startY;
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            startY = CGRectGetMinY(contentRect);
            break;
        case UIControlContentVerticalAlignmentBottom:
            startY = CGRectGetMaxY(contentRect) - contentHeight;
            break;
        case UIControlContentVerticalAlignmentFill:
            startY = CGRectGetMinY(contentRect);
            break;
        default: // Center
            startY = CGRectGetMidY(contentRect) - contentHeight / 2.0;
            break;
    }

    CGFloat imgY   = startY + (contentHeight - imgH) / 2.0;
    CGFloat titleY = startY + (contentHeight - titleSize.height) / 2.0;

    CGFloat leftX       = CGRectGetMinX(contentRect) + gap;                          // 左端起点
    CGFloat rightImgX   = CGRectGetMaxX(contentRect) - gap - imgW;                  // 右端图起点
    CGFloat rightTitleX = CGRectGetMaxX(contentRect) - gap - titleSize.width;       // 右端文字起点

    CGRect imgFrame, titleFrame;
    if (self.imagePosition == ATButtonImagePositionLeft) {
        // 图在左端，文字在右端
        imgFrame   = CGRectMake(leftX,       imgY,   imgW,         imgH);
        titleFrame = CGRectMake(rightTitleX, titleY, titleSize.width, titleSize.height);
    } else {
        // 文字在左端，图在右端
        imgFrame   = CGRectMake(rightImgX,   imgY,   imgW,           imgH);
        titleFrame = CGRectMake(leftX,       titleY, titleSize.width, titleSize.height);
    }

    // 最终叠加 imageEdgeInsets / titleEdgeInsets（与默认布局尾部偏移语义一致）
    imgFrame.origin.x   += self.imageEdgeInsets.left - self.imageEdgeInsets.right;
    imgFrame.origin.y   += self.imageEdgeInsets.top  - self.imageEdgeInsets.bottom;
    titleFrame.origin.x += self.titleEdgeInsets.left - self.titleEdgeInsets.right;
    titleFrame.origin.y += self.titleEdgeInsets.top  - self.titleEdgeInsets.bottom;

    self.imageView.frame = imgFrame;
    self.titleLabel.frame = titleFrame;
}

#pragma mark - 布局（edgeInsets + 图片位置 + 多行 + 单内容居中 + 对齐）

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundImageView.frame = self.bounds;            // 背景图始终铺满
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, self.contentEdgeInsets);
    
    UIImage *img = self.imageView.image;
    BOOL hasImage = img.size.width > 0 && img.size.height > 0;
    BOOL hasTitle = self.titleLabel.text.length > 0;
    
    // ========== 两端对齐：图与文字分别贴左右两端（仅水平方向 + 同时有图文时生效）==========
    if (self.twoEndsAlignment && hasImage && hasTitle &&
        (self.imagePosition == ATButtonImagePositionLeft ||
         self.imagePosition == ATButtonImagePositionRight)) {
        [self _layoutTwoEndsHorizontalInRect:contentRect image:img];
        self.backgroundImageView.frame = self.bounds;
        _highlightEffectView.frame = self.bounds;
        return;
    }
    
    BOOL multiline = self.titleLabel.numberOfLines != 1;
    CGFloat gap = [self _gapBetweenImageAndTitle];
    
    BOOL horizontal = (self.imagePosition == ATButtonImagePositionLeft ||
                       self.imagePosition == ATButtonImagePositionRight);
    
    CGFloat availableTitleWidth = CGRectGetWidth(contentRect);
    if (horizontal && hasImage) {
        availableTitleWidth = MAX(0, availableTitleWidth - img.size.width - gap);
    }
    
    CGSize titleSize = CGSizeZero;
    if (hasTitle) {
        if (multiline) {
            titleSize = [self _measureTitleWithMaxWidth:availableTitleWidth];
            titleSize.width = MIN(titleSize.width, availableTitleWidth);
        } else {
            titleSize = [self _measureTitleWithMaxWidth:CGFLOAT_MAX];
        }
    }
    
    CGFloat mainTotal = horizontal ? (img.size.width + gap + titleSize.width)
    : (img.size.height + gap + titleSize.height);
    CGFloat crossMax = horizontal ? MAX(img.size.height, titleSize.height)
    : MAX(img.size.width, titleSize.width);
    
    CGFloat startX = CGRectGetMidX(contentRect) - (horizontal ? mainTotal : crossMax) / 2;
    CGFloat startY = CGRectGetMidY(contentRect) - (horizontal ? crossMax : mainTotal) / 2;
    
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
    
    if (!hasTitle) {
        imgFrame.origin.x = CGRectGetMidX(contentRect) - img.size.width / 2;
        imgFrame.origin.y = CGRectGetMidY(contentRect) - img.size.height / 2;
    } else if (!hasImage) {
        titleFrame.origin.x = CGRectGetMidX(contentRect) - titleSize.width / 2;
        titleFrame.origin.y = CGRectGetMidY(contentRect) - titleSize.height / 2;
    }
    
    // ========== 重点改动：先做内容对齐（基于未应用image/titleInsets的原始frame）==========
    CGRect contentBox = CGRectZero;
    BOOL hasBox = NO;
    if (imgFrame.size.width > 0 || imgFrame.size.height > 0) {
        contentBox = imgFrame;
        hasBox = YES;
    }
    if (titleFrame.size.width > 0 || titleFrame.size.height > 0) {
        contentBox = hasBox ? CGRectUnion(contentBox, titleFrame) : titleFrame;
        hasBox = YES;
    }
    if (hasBox) {
        UIControlContentHorizontalAlignment hAlign = [self _resolvedHorizontalAlignment];
        
        BOOL titleOnLeft   = hasTitle && (!hasImage || titleFrame.origin.x        <= imgFrame.origin.x);
        BOOL titleOnRight  = hasTitle && (!hasImage || CGRectGetMaxX(titleFrame)  >= CGRectGetMaxX(imgFrame));
        BOOL titleOnTop    = hasTitle && (!hasImage || titleFrame.origin.y        <= imgFrame.origin.y);
        BOOL titleOnBottom = hasTitle && (!hasImage || CGRectGetMaxY(titleFrame)  >= CGRectGetMaxY(imgFrame));
        
        CGFloat dx = 0, dy = 0;
        switch (hAlign) {
            case UIControlContentHorizontalAlignmentLeft: {
                CGFloat margin = titleOnLeft ? self.titleEdgeInsets.left : self.imageEdgeInsets.left;
                dx = CGRectGetMinX(contentRect) + margin - CGRectGetMinX(contentBox);
                break;
            }
            case UIControlContentHorizontalAlignmentRight: {
                CGFloat margin = titleOnRight ? self.titleEdgeInsets.right : self.imageEdgeInsets.right;
                dx = CGRectGetMaxX(contentRect) - margin - CGRectGetMaxX(contentBox);
                break;
            }
            case UIControlContentHorizontalAlignmentFill: {
                if (hasTitle) {
                    titleFrame.origin.x = CGRectGetMinX(contentRect) + self.titleEdgeInsets.left;
                    titleFrame.size.width = CGRectGetWidth(contentRect) - self.titleEdgeInsets.left - self.titleEdgeInsets.right;
                }
                break;
            }
            default: break;
        }
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop: {
                CGFloat margin = titleOnTop ? self.titleEdgeInsets.top : self.imageEdgeInsets.top;
                dy = CGRectGetMinY(contentRect) + margin - CGRectGetMinY(contentBox);
                break;
            }
            case UIControlContentVerticalAlignmentBottom: {
                CGFloat margin = titleOnBottom ? self.titleEdgeInsets.bottom : self.imageEdgeInsets.bottom;
                dy = CGRectGetMaxY(contentRect) - margin - CGRectGetMaxY(contentBox);
                break;
            }
            case UIControlContentVerticalAlignmentFill: {
                if (hasTitle) {
                    titleFrame.origin.y = CGRectGetMinY(contentRect) + self.titleEdgeInsets.top;
                    titleFrame.size.height = CGRectGetHeight(contentRect) - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom;
                }
                break;
            }
            default: break;
        }
        imgFrame.origin.x += dx;   imgFrame.origin.y += dy;
        titleFrame.origin.x += dx; titleFrame.origin.y += dy;
    }
    
    // ========== 最后一步：叠加 imageEdgeInsets / titleEdgeInsets 偏移（原生顺序：先整体对齐，再单独偏移图文） ==========
    imgFrame.origin.x   += self.imageEdgeInsets.left - self.imageEdgeInsets.right;
    imgFrame.origin.y   += self.imageEdgeInsets.top  - self.imageEdgeInsets.bottom;
    titleFrame.origin.x += self.titleEdgeInsets.left - self.titleEdgeInsets.right;
    titleFrame.origin.y += self.titleEdgeInsets.top  - self.titleEdgeInsets.bottom;
    
    self.imageView.frame = imgFrame;
    self.titleLabel.frame = titleFrame;
    _highlightEffectView.frame = self.bounds;
}



#pragma mark - 尺寸计算（sizeThatFits / sizeToFit / intrinsicContentSize 统一入口）

/// 内容自然尺寸；titleMaxWidth > 0 时按该宽度对多行标题换行测量
- (CGSize)_fittingContentSizeWithMaxTitleWidth:(CGFloat)titleMaxWidth {
    UIImage *img = self.imageView.image;
    // BOOL hasImage = img.size.width > 0 && img.size.height > 0;
    BOOL hasTitle = self.titleLabel.text.length > 0;
    BOOL multiline = self.titleLabel.numberOfLines != 1; // 0 或 N 都算多行
   // CGFloat gap = (hasImage && hasTitle) ? self.spacing : 0;
    CGFloat gap = [self _gapBetweenImageAndTitle]; // 图文间距 = spacing + 相对面 insets
    
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
    BOOL twoEnds = self.twoEndsAlignment && horizontal && hasTitle && img.size.width > 0;

    CGFloat w, h;
    if (twoEnds) {
        // 两端对齐：图 + 左右各一个 spacing 端边距 + 标题宽
        w = img.size.width + self.spacing * 2 + titleSize.width;
        h = MAX(img.size.height, titleSize.height);
    } else if (horizontal) {
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
        CGFloat gap = [self _gapBetweenImageAndTitle]; // 图文间距 = spacing + 相对面 insets

        BOOL horizontal = (self.imagePosition == ATButtonImagePositionLeft ||
                           self.imagePosition == ATButtonImagePositionRight);
        // twoEnds 模式下 spacing 复用为两端端边距（图占一端、标题占另一端，各距端 spacing）
        BOOL twoEnds = self.twoEndsAlignment && horizontal && hasImage && hasTitle;

        CGFloat titleMax = size.width;
        if (twoEnds) {
            // 两端对齐：扣图宽 + 左右各一个 spacing
            titleMax = MAX(0, titleMax - img.size.width - self.spacing * 2);
        } else if (horizontal && hasImage) {
            // 普通水平：扣图宽 + 图文间距
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

- (void)setTwoEndsAlignment:(BOOL)twoEndsAlignment {
    if (_twoEndsAlignment == twoEndsAlignment) return;
    _twoEndsAlignment = twoEndsAlignment;
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
