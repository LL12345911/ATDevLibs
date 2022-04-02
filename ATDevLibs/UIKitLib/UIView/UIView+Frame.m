//
//  UIView+Frame.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/15.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

#pragma mark - frame
- (CGFloat)x{
    return self.frame.origin.x;
}
- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


- (CGFloat)y{
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


- (CGFloat)left {
    return self.frame.origin.x;
}
- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}
- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}


- (CGFloat)top {
    return self.frame.origin.y;
}
- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}
- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


- (CGFloat)centerX {
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}


- (CGFloat)centerY {
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


- (CGFloat)width {
    return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


- (CGFloat)height {
    return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


- (CGSize)size {
    return self.frame.size;
}
- (void)setSize:(CGSize)size {
    self.frame = CGRectMake(self.left, self.top, size.width, size.height);
}


- (CGPoint)origin {
    return self.frame.origin;
}
- (void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.width, self.height);
}

- (CGFloat)screenX{
    CGFloat x  = 0.0f;
    for (UIView *view = self; view; view = view.superview) {
        x += view.left;
    }
    return x;
}
- (CGFloat)screenY{
    CGFloat y = 0.0f;
    for (UIView *view = self; view; view = view.superview) {
        y += view.top;
    }
    return y;
}

- (CGFloat)screenViewX{
    CGFloat x = 0.0f;
    for (UIView *view = self; view; view = view.superview) {
        x += view.left;
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *) view;
            x -= scrollView.contentOffset.x;
        }
    }
    return x;
}

- (CGFloat)screenViewY{
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.top;
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *) view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}


- (CGRect)screenFrame{
    return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}

- (void)changeTopByAdding:(NSNumber *)number
{
    CGFloat top = number.floatValue;
    self.top += top;
}

//加载同名的xib
+ (instancetype)viewFromXib{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}


-(BOOL)isInScreen {
    SEL selec = NSSelectorFromString(@"_isInVisibleHierarchy");
    NSMethodSignature * sign = [[UIView class] instanceMethodSignatureForSelector:selec];
    NSInvocation * inv = [NSInvocation invocationWithMethodSignature:sign];
    inv.target = self;
    inv.selector = selec;
    
    BOOL visible = NO;
    [inv invoke];
    [inv getReturnValue:&visible];
    return visible;
}

/**
 以递归的方式遍历(查找)subview
 Return YES from the block to recurse into the subview.
 Set stop to YES to return the subview.
 */
- (UIView*)findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop))recurse{
    for( UIView* subview in self.subviews ) {
        BOOL stop = NO;
        if( recurse( subview, &stop ) ) {
            return [subview findViewRecursively:recurse];
        } else if( stop ) {
            return subview;
        }
    }
    
    return nil;
}

/**
 Returns the superView of provided class type.
 */
- (UIView*)superviewOfClass:(Class)classType{
    UIView *superview = self.superview;
    while (superview){
        static Class UITableViewCellScrollViewClass = Nil;   //UITableViewCell
        static Class UITableViewWrapperViewClass = Nil;      //UITableViewCell
        static Class UIQueuingScrollViewClass = Nil;         //UIPageViewController
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UITableViewCellScrollViewClass      = NSClassFromString(@"UITableViewCellScrollView");
            UITableViewWrapperViewClass         = NSClassFromString(@"UITableViewWrapperView");
            UIQueuingScrollViewClass            = NSClassFromString(@"_UIQueuingScrollView");
        });
        if ([superview isKindOfClass:classType] &&
            ([superview isKindOfClass:UITableViewCellScrollViewClass] == NO) &&
            ([superview isKindOfClass:UITableViewWrapperViewClass] == NO) &&
            ([superview isKindOfClass:UIQueuingScrollViewClass] == NO)){
            return superview;
        }else{
            superview = superview.superview;
        }
    }
    return nil;
}
/**
 Returns the navigationController, if exsit.
 */
- (UINavigationController *)getNavigationController {
    UIView *view = self.superview;
    while(view) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)nextResponder;
        }
        view = view.superview;
    }
    return nil;
}


-(void)dw_AddLineWithFrame:(CGRect)frame color:(UIColor *)color {
    CALayer * line = [CALayer layer];
    line.frame = frame;
    line.backgroundColor = color.CGColor;
    [self.layer addSublayer:line];
}

-(void)dw_AddCorner:(UIRectCorner)corners radius:(CGFloat)radius {
    UIBezierPath * maskP = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.fillColor = [UIColor blackColor].CGColor;
    layer.path = maskP.CGPath;
    self.layer.mask = layer;
}

@end



@implementation UIView (CGAffineTransform)

- (CGFloat)at_scaleX {
    return self.transform.a;
}

- (CGFloat)at_scaleY {
    return self.transform.d;
}

- (CGFloat)at_translationX {
    return self.transform.tx;
}

- (CGFloat)at_translationY {
    return self.transform.ty;
}

@end



@implementation UIView (superFrame)

- (void)qmui_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (CGPoint)qmui_convertPoint:(CGPoint)point toView:(nullable UIView *)view {
    if (view) {
        return [view qmui_convertPoint:point fromView:view];
    }
    return [self convertPoint:point toView:view];
}

- (CGPoint)qmui_convertPoint:(CGPoint)point fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGPoint pointInFromWindow = fromWindow == view ? point : [view convertPoint:point toView:nil];
        CGPoint pointInSelfWindow = [selfWindow convertPoint:pointInFromWindow fromWindow:fromWindow];
        CGPoint pointInSelf = selfWindow == self ? pointInSelfWindow : [self convertPoint:pointInSelfWindow fromView:nil];
        return pointInSelf;
    }
    return [self convertPoint:point fromView:view];
}

- (CGRect)qmui_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    if (view) {
        return [view qmui_convertRect:rect fromView:self];
    }
    return [self convertRect:rect toView:view];
}

- (CGRect)qmui_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGRect rectInFromWindow = fromWindow == view ? rect : [view convertRect:rect toView:nil];
        CGRect rectInSelfWindow = [selfWindow convertRect:rectInFromWindow fromWindow:fromWindow];
        CGRect rectInSelf = selfWindow == self ? rectInSelfWindow : [self convertRect:rectInSelfWindow fromView:nil];
        return rectInSelf;
    }
    return [self convertRect:rect fromView:view];
}

@end
