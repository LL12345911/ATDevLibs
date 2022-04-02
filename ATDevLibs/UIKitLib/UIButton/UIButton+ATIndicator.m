//
//  UIButton+ATIndicator.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIButton+ATIndicator.h"
#import <objc/runtime.h>

// Associative reference keys.
static NSString *const at_IndicatorViewKey = @"indicatorView";
static NSString *const at_ButtonTextObjectKey = @"buttonTextObject";

@implementation UIButton (JKIndicator)

- (void)at_showIndicator {
    @autoreleasepool {
        [self at_hideIndicator];
        self.submitting = @YES;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        [indicator startAnimating];
        
        NSString *currentButtonText = self.titleLabel.text;
        
        objc_setAssociatedObject(self, &at_ButtonTextObjectKey, currentButtonText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &at_IndicatorViewKey, indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setTitle:@"" forState:UIControlStateNormal];
        self.enabled = NO;
        [self addSubview:indicator];
    }
}

- (void)at_showIndicatorStatusText:(NSString *)statusText{
    @autoreleasepool {
        [self at_hideIndicator];
        self.submitting = @YES;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGFloat width = [self calculateRowWidth:statusText];
        indicator.center = CGPointMake(self.bounds.size.width / 2 - width/2.0, self.bounds.size.height / 2);
        [indicator startAnimating];
        self.titleEdgeInsets = UIEdgeInsetsMake(0, width/2.0, 0, 0);
        
        NSString *currentButtonText = self.titleLabel.text;
        
        objc_setAssociatedObject(self, &at_ButtonTextObjectKey, currentButtonText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &at_IndicatorViewKey, indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        
        
        [self setTitle:statusText forState:UIControlStateNormal];
        self.enabled = NO;
        [self addSubview:indicator];
    }
}

//获取字符串的宽度
- (CGFloat)calculateRowWidth:(NSString *)string{
    NSDictionary *dic = @{NSFontAttributeName:self.titleLabel.font};
    CGRect rect = [string boundingRectWithSize:CGSizeMake(0, 100) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.width;
}


- (void)at_hideIndicator {
    if (!self.isSubmitting.boolValue) {
        return;
    }
    self.submitting = @NO;
    
    NSString *currentButtonText = (NSString *)objc_getAssociatedObject(self, &at_ButtonTextObjectKey);
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)objc_getAssociatedObject(self, &at_IndicatorViewKey);
    [indicator removeFromSuperview];
    indicator = nil;
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setTitle:currentButtonText forState:UIControlStateNormal];
    self.enabled = YES;
    
}


- (NSNumber *)isSubmitting {
    return objc_getAssociatedObject(self, @selector(setSubmitting:));
}

- (void)setSubmitting:(NSNumber *)submitting {
    objc_setAssociatedObject(self, @selector(setSubmitting:), submitting, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}


@end
