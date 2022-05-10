//
//  UIView+ATKit.m
//  AirCnC
//
//  Created by Mars on 2018/11/30.
//  Copyright © 2018 Mars. All rights reserved.
//

#import "UIView+Util.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Frame.h"
#import "WindowsManager.h"

//定义常量 必须是C语言字符串
static char *IndicatorBackViewKey = "IndicatorBackKKViewKey";

//static const CGFloat kDGActivityIndicatorDefaultSize = 40.0f;

//
static NSString *const kDTActionHandlerTapGestureKey   = @"kDTActionHandlerTapGestureKey";
static NSString *const kDTActionHandlerTapBlockKey     = @"kDTActionHandlerTapBlockKey";
static NSString *const kDTActionHandlerLongPressGestureKey = @"kDTActionHandlerLongPressGestureKey";
static NSString *const kDTActionHandlerLongPressBlockKey   = @"kDTActionHandlerLongPressBlockKey";

//Animation
#define ANIMATIONWIDTH self.frame.size.width
#define ANIMATIONHEIGHT self.frame.size.height
float radiansForDegress(int degrees){
    return degrees * M_PI/180;
}


@implementation UIView (ATKit)


- (void)setIndicatorBack:(UIView *)indicatorBack{
    objc_setAssociatedObject(self, IndicatorBackViewKey, indicatorBack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)indicatorBack{
    return objc_getAssociatedObject(self, IndicatorBackViewKey);
}

- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat bigDuration = 1.0f;
    CGFloat smallDuration = bigDuration / 2;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Big circle
    {
        CGFloat circleSize = size.width;
        CAShapeLayer *circle = [CAShapeLayer layer];
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        
        [circlePath addArcWithCenter:CGPointMake(circleSize / 2, circleSize / 2) radius:circleSize / 2 startAngle:-3 * M_PI / 4 endAngle:-M_PI / 4 clockwise:true];
        [circlePath moveToPoint:CGPointMake(circleSize / 2 - circleSize / 2 * cosf(M_PI / 4), circleSize / 2 + circleSize / 2 * sinf(M_PI / 4))];
        [circlePath addArcWithCenter:CGPointMake(circleSize / 2, circleSize / 2) radius:circleSize / 2 startAngle:-5 * M_PI / 4 endAngle:-7 * M_PI / 4 clockwise:false];
        circle.path = circlePath.CGPath;
        circle.lineWidth = 2;
        circle.fillColor = nil;
        circle.strokeColor = tintColor.CGColor;
        
        circle.frame = CGRectMake((layer.bounds.size.width - circleSize) / 2, (layer.bounds.size.height - circleSize) / 2, circleSize, circleSize);
        [circle addAnimation: [self createAnimationInDuration:bigDuration withTimingFunction:timingFunction reverse:false] forKey:@"animation"];
        [layer addSublayer:circle];
    }
    
    // Small circle
    {
        CGFloat circleSize = size.width / 2;
        CAShapeLayer *circle = [CAShapeLayer layer];
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        
        [circlePath addArcWithCenter:CGPointMake(circleSize / 2, circleSize / 2) radius:circleSize / 2 startAngle:3 * M_PI / 4 endAngle:5 * M_PI / 4 clockwise:true];
        [circlePath moveToPoint:CGPointMake(circleSize / 2 + circleSize / 2 * cosf(M_PI / 4), circleSize / 2 - circleSize / 2 * sinf(M_PI / 4))];
        [circlePath addArcWithCenter:CGPointMake(circleSize / 2, circleSize / 2) radius:circleSize / 2 startAngle:-M_PI / 4 endAngle:M_PI / 4 clockwise:true];
        circle.path = circlePath.CGPath;
        circle.lineWidth = 2;
        circle.fillColor = nil;
        circle.strokeColor = tintColor.CGColor;
        
        circle.frame = CGRectMake((layer.bounds.size.width - circleSize) / 2, (layer.bounds.size.height - circleSize) / 2, circleSize, circleSize);
        [circle addAnimation:[self createAnimationInDuration:smallDuration withTimingFunction:timingFunction reverse:true] forKey:@"animation"];
        [layer addSublayer:circle];
    }
}

- (CAAnimation *)createAnimationInDuration:(CGFloat) duration withTimingFunction:(CAMediaTimingFunction *) timingFunction reverse:(BOOL) reverse {
    // Scale animation
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    scaleAnimation.keyTimes = @[@0.0f, @0.5f, @1.0f];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6f, 0.6f, 1.0f)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)]];
    scaleAnimation.duration = duration;
    scaleAnimation.timingFunctions = @[timingFunction, timingFunction];
    
    // Rotate animation
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    if (!reverse) {
        rotateAnimation.values = @[@0, @M_PI, @(2 * M_PI)];
    } else {
        rotateAnimation.values = @[@0, @-M_PI, @(-2 * M_PI)];
    }
    rotateAnimation.keyTimes = scaleAnimation.keyTimes;
    rotateAnimation.duration = duration;
    rotateAnimation.timingFunctions = @[timingFunction, timingFunction];
    
    // Animation
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    
    animation.animations = @[scaleAnimation, rotateAnimation];
    animation.repeatCount = HUGE_VALF;
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    
    return animation;
}


/**
 开启动画
 */
- (void)startLoadingOther{
    @autoreleasepool {
        UIWindow *window = [WindowsManager keyWindow];
        //    window.windowLevel = UIWindowLevelAlert;
        CGFloat height = window.frame.size.height;
        CGFloat width = window.frame.size.width;
        if (self.indicatorBack) {
            [self.indicatorBack removeAllSubviews];
            self.indicatorBack.frame = CGRectMake(0, height, width, height);
        }
        
        
        self.indicatorBack = [[UIView alloc] init];
        self.indicatorBack.frame = CGRectMake(0, 0, width, height);
        self.indicatorBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [window addSubview:self.indicatorBack];
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //设置显示位置
        indicator.center = CGPointMake(width/2.0, height/2.0);
        indicator.hidesWhenStopped = NO;
        //    _indicator.color = [UIColor whiteColor];
        [self.indicatorBack addSubview:indicator];
        [indicator startAnimating];
        self.indicatorBack.hidden = NO;
    }
}

- (void)startIndicatorLoading{
    @autoreleasepool {
        [self.indicatorBack removeFromSuperview];
        
        UIWindow *window = [WindowsManager keyWindow];
        //    window.windowLevel = UIWindowLevelAlert;
        CGFloat height = window.frame.size.height;
        CGFloat width = window.frame.size.width;
        if (self.indicatorBack) {
            [self.indicatorBack removeAllSubviews];
            self.indicatorBack.frame = CGRectMake(0, height, width, height);
        }
        
        
        self.indicatorBack = [[UIView alloc] init];
        self.indicatorBack.frame = CGRectMake(0, 0, width, height);
        self.indicatorBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [window addSubview:self.indicatorBack];
        
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //设置显示位置
        indicator.center = CGPointMake(width/2.0, height/2.0);
        indicator.hidesWhenStopped = NO;
        //    _indicator.color = [UIColor whiteColor];
        [self.indicatorBack addSubview:indicator];
        [indicator startAnimating];
        self.indicatorBack.hidden = NO;
    }
}

- (void)stopIndicatorLoading{
    __block typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [weakSelf.indicatorBack removeAllSubviews];
            UIWindow *window = [WindowsManager keyWindow];
            CGFloat height = window.frame.size.height;
            CGFloat width = window.frame.size.width;
            
            weakSelf.indicatorBack.frame = CGRectMake(0, height, width, height);
            //[weakSelf.indicator removeAllSubviews];
            weakSelf.indicatorBack.hidden = YES;
        }
        
    });
}

- (void)stopIndicatorLoading:(float)time{
    __block typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [weakSelf.indicatorBack removeAllSubviews];
            UIWindow *window = [WindowsManager keyWindow];
            CGFloat height = window.frame.size.height;
            CGFloat width = window.frame.size.width;
            
            weakSelf.indicatorBack.frame = CGRectMake(0, height, width, height);
            //[weakSelf.indicator removeAllSubviews];
            weakSelf.indicatorBack.hidden = YES;
        }
    });
}

///**
// *    @brief    删除所有子对象
// */
//- (void)removeAllSubviews{
//    while (self.subviews.count)
//    {
//        UIView *child = self.subviews.lastObject;
//        [child removeFromSuperview];
//    }
//}



//判断两个视图在同一窗口是否有重叠
- (BOOL)intersectWithView:(UIView *)view{
    UIWindow *window = [WindowsManager keyWindow];
    CGRect selfRect = [self convertRect:self.bounds toView:window];
    CGRect viewRect = [view convertRect:view.bounds toView:window];
    return CGRectIntersectsRect(selfRect, viewRect);
}




#pragma mark - 实现虚线功能  -
- (void)addBorderDottedLinewithColor:(UIColor *)color {
    
    CAShapeLayer *border = [CAShapeLayer layer];
    //  线条颜色
    border.strokeColor = color.CGColor;
    
    border.fillColor = nil;
    
    
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 0)];
    if (CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame)) {
        [pat addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    }else{
        [pat addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    }
    border.path = pat.CGPath;
    
    border.frame = self.bounds;
    
    // 不要设太大 不然看不出效果
    border.lineWidth = 0.5;
    border.lineCap = @"butt";
    
    //  第一个是 线条长度   第二个是间距    nil时为实线
    border.lineDashPattern = @[@4, @3];
    
    [self.layer addSublayer:border];
    
    
}



- (CGFloat)orientationWidth{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? self.height : self.width;
}

- (CGFloat)orientationHeight{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? self.width : self.height;
}


//#pragma mark -
//#pragma mark -
///**
// *  @brief  找到当前view所在的viewcontroler
// */
//- (UIViewController *)at_viewController{
//    UIResponder *responder = self.nextResponder;
//    do {
//        if ([responder isKindOfClass:[UIViewController class]]) {
//            return (UIViewController *)responder;
//        }
//        responder = responder.nextResponder;
//    } while (responder);
//    return nil;
//}

/**
 *  @brief  找到指定类名的view对象
 *
 *  @param clazz view类名
 *
 *  @return view对象
 */
- (id)at_findSubViewWithSubViewClass:(Class)clazz{
    for (id subView in self.subviews) {
        if ([subView isKindOfClass:clazz]) {
            return subView;
        }
    }
    
    return nil;
}
/**
 *  @brief  找到指定类名的SuperView对象
 *
 *  @param clazz SuperView类名
 *
 *  @return view对象
 */
- (id)at_findSuperViewWithSuperViewClass:(Class)clazz{
    if (self == nil) {
        return nil;
    } else if (self.superview == nil) {
        return nil;
    } else if ([self.superview isKindOfClass:clazz]) {
        return self.superview;
    } else {
        return [self.superview at_findSuperViewWithSuperViewClass:clazz];
    }
}
/**
 *  @brief  找到并且resign第一响应者
 *
 *  @return 结果
 */
- (BOOL)at_findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    
    for (UIView *v in self.subviews) {
        if ([v at_findAndResignFirstResponder]) {
            return YES;
        }
    }
    
    return NO;
}
/**
 *  @brief  找到第一响应者
 *
 *  @return 第一响应者
 */
- (UIView *)at_findFirstResponder {
    
    if (([self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]])
        && (self.isFirstResponder)) {
        return self;
    }
    
    for (UIView *v in self.subviews) {
        UIView *fv = [v at_findFirstResponder];
        if (fv) {
            return fv;
        }
    }
    
    return nil;
}




- (UIViewController *)belongsViewController {
    for (UIView *next = self; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)removeAllSubviews {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    //    while (self.subviews.count) {
    //    UIView *child = self.subviews.lastObject;
    //    [child removeFromSuperview];
    //    }
}





- (CGPoint)offsetFromView:(UIView *)otherView{
    CGFloat x = 0.0f, y = 0.0f;
    for (UIView *view = self; view && view != otherView; view = view.superview) {
        x += view.left;
        y += view.top;
    }
    return CGPointMake(x, y);
}

- (void)setTapActionWithBlock:(void (^)(void))block{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerTapGestureKey);
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kDTActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForTapGesture:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        void(^action)(void) = objc_getAssociatedObject(self, &kDTActionHandlerTapBlockKey);
        
        if (action) {
            action();
        }
    }
}

- (void)setLongPressActionWithBlock:(void (^)(void))block{
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerLongPressGestureKey);
    if (!gesture) {
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerLongPressGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kDTActionHandlerLongPressBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForLongPressGesture:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        void(^action)(void) = objc_getAssociatedObject(self, &kDTActionHandlerLongPressBlockKey);
        
        if (action) {
            action();
        }
    }
}



#pragma mark -
#pragma mark - 截屏
/**
 *  @brief  view截图
 *
 *  @return 截图
 */
- (UIImage *)screenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}
/**
 *  @author Jakey
 *
 *  @brief  截图一个view中所有视图 包括旋转缩放效果
 *
 *  param aView    一个view
 *  param limitWidth 限制缩放的最大宽度 保持默认传0
 *
 *  @return 截图
 */
- (UIImage *)screenshot:(CGFloat)maxWidth{
    CGAffineTransform oldTransform = self.transform;
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    
    //    if (!isnan(scale)) {
    //        CGAffineTransform transformScale = CGAffineTransformMakeScale(scale, scale);
    //        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
    //    }
    if (!isnan(maxWidth) && maxWidth>0) {
        CGFloat maxScale = maxWidth/CGRectGetWidth(self.frame);
        CGAffineTransform transformScale = CGAffineTransformMakeScale(maxScale, maxScale);
        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
        
    }
    if(!CGAffineTransformEqualToTransform(scaleTransform, CGAffineTransformIdentity)){
        self.transform = scaleTransform;
    }
    
    CGRect actureFrame = self.frame; //已经变换过后的frame
    CGRect actureBounds= self.bounds;//CGRectApplyAffineTransform();
    
    //begin
    UIGraphicsBeginImageContextWithOptions(actureFrame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    CGContextTranslateCTM(context,actureFrame.size.width/2, actureFrame.size.height/2);
    CGContextConcatCTM(context, self.transform);
    CGPoint anchorPoint = self.layer.anchorPoint;
    CGContextTranslateCTM(context,
                          -actureBounds.size.width * anchorPoint.x,
                          -actureBounds.size.height * anchorPoint.y);
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //end
    self.transform = oldTransform;
    
    return screenshot;
}





#pragma mark -
#pragma mark - 阴影

#define kShadowViewTag 2132
#define kValidDirections [NSArray arrayWithObjects: @"top", @"bottom", @"left", @"right",nil]


- (void)at_makeInsetShadow{
    NSArray *shadowDirections = [NSArray arrayWithObjects:@"top", @"bottom", @"left" , @"right" , nil];
    UIColor *color = [UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.5];
    
    UIView *shadowView = [self at_createShadowViewWithRadius:3 Color:color Directions:shadowDirections];
    shadowView.tag = kShadowViewTag;
    
    [self addSubview:shadowView];
}

- (void)at_makeInsetShadowWithRadius:(float)radius Alpha:(float)alpha{
    NSArray *shadowDirections = [NSArray arrayWithObjects:@"top", @"bottom", @"left" , @"right" , nil];
    UIColor *color = [UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:alpha];
    
    UIView *shadowView = [self at_createShadowViewWithRadius:radius Color:color Directions:shadowDirections];
    shadowView.tag = kShadowViewTag;
    
    [self addSubview:shadowView];
}

- (void)at_makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions{
    UIView *shadowView = [self at_createShadowViewWithRadius:radius Color:color Directions:directions];
    shadowView.tag = kShadowViewTag;
    
    [self addSubview:shadowView];
}

- (UIView *)at_createShadowViewWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions{
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    shadowView.backgroundColor = [UIColor clearColor];
    
    // Ignore duplicate direction
    NSMutableDictionary *directionDict = [[NSMutableDictionary alloc] init];
    for (NSString *direction in directions) [directionDict setObject:@"1" forKey:direction];
    
    for (NSString *direction in directionDict) {
        // Ignore invalid direction
        if ([kValidDirections containsObject:direction]){
            CAGradientLayer *shadow = [CAGradientLayer layer];
            
            if ([direction isEqualToString:@"top"]) {
                [shadow setStartPoint:CGPointMake(0.5, 0.0)];
                [shadow setEndPoint:CGPointMake(0.5, 1.0)];
                shadow.frame = CGRectMake(0, 0, self.bounds.size.width, radius);
            }else if ([direction isEqualToString:@"bottom"]){
                [shadow setStartPoint:CGPointMake(0.5, 1.0)];
                [shadow setEndPoint:CGPointMake(0.5, 0.0)];
                shadow.frame = CGRectMake(0, self.bounds.size.height - radius, self.bounds.size.width, radius);
            }else if ([direction isEqualToString:@"left"]){
                shadow.frame = CGRectMake(0, 0, radius, self.bounds.size.height);
                [shadow setStartPoint:CGPointMake(0.0, 0.5)];
                [shadow setEndPoint:CGPointMake(1.0, 0.5)];
            }else if ([direction isEqualToString:@"right"]){
                shadow.frame = CGRectMake(self.bounds.size.width - radius, 0, radius, self.bounds.size.height);
                [shadow setStartPoint:CGPointMake(1.0, 0.5)];
                [shadow setEndPoint:CGPointMake(0.0, 0.5)];
            }
            
            shadow.colors = [NSArray arrayWithObjects:(id)[color CGColor], (id)[[UIColor clearColor] CGColor], nil];
            [shadowView.layer insertSublayer:shadow atIndex:0];
        }
    }
    
    return shadowView;
}



#pragma mark -
#pragma mark - 动画


#pragma mark - 位移
-(void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option{
    //    [self moveTo:destination duration:secs option:option delegate:self callBack:nil];
    [self moveTo:destination duration:secs option:option delegate:nil callBack:nil];
}

-(void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option delegate:(id)delegate callBack:(SEL)method{
    [UIView animateWithDuration:secs delay:0.0 options:option animations:^{
        self.frame = CGRectMake(destination.x, destination.y, ANIMATIONWIDTH, ANIMATIONHEIGHT);
    } completion:^(BOOL finished) {
        if (delegate != nil) {
#pragma mark - 处理编译器警告->performselector可能引起泄漏因为它是未知的
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:method];
#pragma clang diagnostic pop
        }
    }];
}

-(void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapback{
    [self raceTo:destination withSnapBack:withSnapback delegate:nil callBack:nil];
}

-(void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapback delegate:(id)delegate callBack:(SEL)method{
    CGPoint stopPoint = destination;
    if (withSnapback) {
        // Determine our stop point, from which we will "snap back" to the final destination
        int diffx = destination.x - self.frame.origin.x;
        int diffy = destination.y - self.frame.origin.y;
        if (diffx < 0) {
            // Destination is to the left of current position
            stopPoint.x -= 10.0;
        }else if (diffx > 0){
            stopPoint.x += 10.0;
        }
        if (diffy < 0) {
            // Destination is to the left of current position
            stopPoint.y -= 10.0;
        }else if (diffy > 0){
            stopPoint.y += 10.0;
        }
    }
    //动画
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(stopPoint.x, stopPoint.y, ANIMATIONWIDTH, ANIMATIONHEIGHT);
    } completion:^(BOOL finished) {
        if (withSnapback) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.frame = CGRectMake(destination.x, destination.y, ANIMATIONWIDTH, ANIMATIONHEIGHT);
            } completion:^(BOOL finished) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [delegate performSelector:method];
#pragma clang diagnostic pop
            }];
        }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:method];
#pragma clang diagnostic pop
        }
    }];
}

-(void)rotateWithCenterPoint:(CGPoint)point angle:(float)angle duration:(float)secs{
    CATransform3D tranform = CATransform3DIdentity;
    tranform = CATransform3DRotate(tranform, angle, 1.0, 1.0, 1.0);
    CALayer* layer = self.layer;
    //设置反转中心点
    layer.anchorPoint = point;
    layer.transform = tranform;
}

#pragma mark - 淡入淡出
-(void)sadeInDuration:(float)secs finish:(void (^)(void))finishBlock{
    self.alpha = 0.0;
    [UIView animateWithDuration:secs animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finishBlock != nil) {
            finishBlock();
        }
    }];
}

-(void)sadeOutDuration:(float)secs finish:(void (^)(void))finishBlock{
    self.alpha = 1.0;
    [UIView animateWithDuration:secs animations:^{
        self.alpha = 0.1;
    } completion:^(BOOL finished) {
        if (finishBlock != nil) {
            finishBlock();
        }
    }];
}

#pragma mark - 形变
-(void)rotate:(int)degrees secs:(float)secs delegate:(id)delegate callBack:(SEL)method{
    [UIView animateWithDuration:secs delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.transform = CGAffineTransformRotate(self.transform, radiansForDegress(degrees));
    } completion:^(BOOL finished) {
        if (delegate != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:method];
#pragma clang diagnostic pop
        }
    }];
}

-(void)scale:(float)secs x:(float)scaleX y:(float)scaleY delegate:(id)delegate callBack:(SEL)method{
    [UIView animateWithDuration:secs delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.transform = CGAffineTransformScale(self.transform, scaleX, scaleY);
    } completion:^(BOOL finished) {
        if (delegate != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:method];
#pragma clang diagnostic pop
        }
    }];
}

-(void)spinClockwise:(float)secs{
    [UIView animateWithDuration:secs/4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.transform = CGAffineTransformRotate(self.transform, radiansForDegress(90));
    } completion:^(BOOL finished) {
        [self spinClockwise:secs];
    }];
}

-(void)spinCounterClockwise:(float)secs{
    [UIView animateWithDuration:secs/4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.transform = CGAffineTransformRotate(self.transform, radiansForDegress(270));
    } completion:^(BOOL finished) {
        [self spinCounterClockwise:secs];
    }];
}

#pragma mark - 过度动画
-(void)curlDown:(float)secs{
    [UIView transitionWithView:self duration:secs options:UIViewAnimationOptionTransitionCurlDown animations:^{
        [self setAlpha:1.0];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)curUpAndAway:(float)secs{
    [UIView transitionWithView:self duration:secs options:UIViewAnimationOptionTransitionCurlUp animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)drainAway:(float)secs{
    self.tag = 20;
    [NSTimer scheduledTimerWithTimeInterval:secs/50 target:self selector:@selector(drainTimer:) userInfo:nil repeats:YES];
}

-(void)drainTimer:(NSTimer*)timer{
    CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformScale(self.transform, 0.9, 0.9), 0.314);
    self.transform = trans;
    self.alpha = self.alpha* 0.98;
    self.tag = self.tag - 1;
    if (self.tag <= 0) {
        [timer invalidate];
        [self removeFromSuperview];
    }
}

#pragma mark - 动画效果
-(void)changeAlpha:(float)newAlpha secs:(float)secs{
    [UIView animateWithDuration:secs delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = newAlpha;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)pulse:(float)secs continuously:(BOOL)continuously{
    [UIView animateWithDuration:secs/2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        //Fade out , but not completely
        self.alpha = 0.3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:secs/2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            //fade in
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (continuously) {
                [self pulse:secs continuously:continuously];
            }
        }];
    }];
}

#pragma mark - add subView
-(void)addSubviewWithFadeanimation:(UIView *)subview{
    CGFloat finalalpha = subview.alpha;
    subview.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        subview.alpha = finalalpha;
    }];
}

#pragma mark - particle animation
-(void)particleAnimationImage:(NSString *)image{
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.frame = self.bounds;
    [self.layer addSublayer:emitter];
    //发射模式
    emitter.renderMode = kCAEmitterLayerOutline;
    //动画的位置
    emitter.emitterPosition = self.center;
    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
    //设置图片
    cell.contents = (__bridge id)[UIImage imageNamed:image].CGImage;
    //设置粒子产生系数,默认是1.0 ->必须要设置 每秒某个点产生的cell的数量
    cell.birthRate = 20;
    //设置粒子的生命周期->在屏幕上显示时间的长短
    cell.lifetime = 2.0;
    cell.color = [UIColor colorWithRed:1 green:0.5 blue:0.1 alpha:1.0].CGColor;
    //粒子透明度在生命周期内的改变速度
    cell.alphaSpeed = -0.4;
    //cell向屏幕右边飞行的速度
    cell.velocity = 50;
    //在右边什么范围内飞行
    cell.velocityRange = 50;
    //cell的角度扩散
    cell.emissionRange = M_PI * 2.0;
    emitter.emitterCells = @[cell];
}



@end
