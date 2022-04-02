
//
//  ATTextView.m
//  HighwayDoctor
//
//  Created by Mars on 2019/6/24.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "ATPlaceholdTextView.h"

@implementation ATPlaceholdTextView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:nil];
        
        // 外界文字颜色不设置,默认为灰色
        self.placeholdColor = [UIColor grayColor];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textChange{
    [self setNeedsDisplay];
}

// 调用drawRect时,会将之前的图像擦除掉,重新绘制
- (void)drawRect:(CGRect)rect {
    
    if ([self hasText]) return;
    
    rect.origin.y += (0 + 7);
    rect.origin.x += 5;
    rect.size.width -= 2 * rect.origin.x;
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = self.placeholdColor;
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    [self.placehold drawInRect:rect withAttributes:attrs];
}

// 设计框架需注意,给外界提供了属性后,一定重写出行的setter,这样既可以时时监听使用者对属性的更改,还可以跟好的与外界代码进行交互
- (void)setPlacehold:(NSString *)placehold{
    _placehold = placehold;
    // 设置了站位文字后,需要重绘一遍
    [self setNeedsDisplay];
}

- (void)setPlaceholdColor:(UIColor *)placeholdColor{
    _placeholdColor = placeholdColor;
    [self setNeedsDisplay];
}

// 同时,也要考虑到
- (void)setFont:(UIFont *)font{
    [super setFont:font];
    
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text{
    [super setText:text];
    
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
    [super setAttributedText:attributedText];
    
    [self setNeedsDisplay];
}

@end
