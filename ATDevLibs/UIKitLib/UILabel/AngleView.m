//
//  AngleLabel.m
//  EngineeringCool
//
//  Created by Mars on 2020/1/13.
//  Copyright © 2020 Mars. All rights reserved.
//

#import "AngleView.h"

@interface AngleView()

//@property (nonatomic,strong) UILabel *textLabel;

@end

@implementation AngleView

//
//- (void)setTextStr:(NSString *)textStr{
//    _textStr = textStr;
//    _textLabel.text = _textStr;
//}
//
//- (void)setTextFont:(UIFont *)textFont{
//    _textFont = textFont;
//    _textLabel.font = _textFont;
//}
//
//- (void)setTextColor:(UIColor *)textColor{
//    _textColor = textColor;
//    _textLabel.textColor = _textColor;
//}

//绘制带箭头的矩形

-(void)drawArrowRectangle:(CGRect) frame{
    // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    
    // 创建一个新的空图形路径。
    CGContextBeginPath(ctx);
    
    //启始位置坐标x，y
    CGFloat origin_x = frame.origin.x;
    CGFloat origin_y = frame.origin.y;
    
    //第一条线的位置坐标
    CGFloat line_1_x = frame.size.width;
    CGFloat line_1_y = origin_y;
    
    //第二条线的位置坐标
    CGFloat line_2_x = line_1_x;
    CGFloat line_2_y = frame.size.height;
    
    //第三条线的位置坐标
    if (_angleHeight == 0) {
        _angleHeight = 10;
    }
    CGFloat line_3_x = origin_x +  frame.size.width/2.0 + _angleHeight;//origin_x +  frame.size.width/2.0 + 10;
    CGFloat line_3_y = line_2_y;
    
    //尖角的顶点位置坐标
    CGFloat line_4_x = line_3_x - _angleHeight;//line_3_x - 10;
    CGFloat line_4_y = line_2_y + _angleHeight;// 10
    
    //第五条线位置坐标
    CGFloat line_5_x = line_4_x - _angleHeight; //line_4_x - 10;
    CGFloat line_5_y = line_3_y;
    
    //第六条线位置坐标
    CGFloat line_6_x = origin_x;
    CGFloat line_6_y = line_2_y;
        
    CGContextAddArc(ctx, origin_x + _cornerRadius, origin_y + _cornerRadius, _cornerRadius, M_PI, M_PI/2 * 3, 0);
//    CGContextMoveToPoint(ctx, origin_x, origin_y);
    CGContextAddLineToPoint(ctx, line_1_x-_cornerRadius, line_1_y);
    CGContextAddArc(ctx, line_1_x - _cornerRadius, line_1_y + _cornerRadius, _cornerRadius, M_PI/2 * 3, 0, 0);
    CGContextAddLineToPoint(ctx, line_2_x, line_2_y-_cornerRadius);
    CGContextAddArc(ctx, line_2_x - _cornerRadius, line_2_y - _cornerRadius, _cornerRadius, 0, M_PI_2, 0);
    CGContextAddLineToPoint(ctx, line_3_x, line_3_y);
    CGContextAddLineToPoint(ctx, line_4_x, line_4_y);
    CGContextAddLineToPoint(ctx, line_5_x, line_5_y);
    CGContextAddLineToPoint(ctx, line_6_x + _cornerRadius, line_6_y);
    CGContextAddArc(ctx, line_6_x + _cornerRadius, line_6_y - _cornerRadius, _cornerRadius, M_PI_2, M_PI, 0);
    
    CGContextClosePath(ctx);
    
//    CGContextMoveToPoint(ctx, origin_x, origin_y);
//    CGContextAddLineToPoint(ctx, line_1_x, line_1_y);
//    CGContextAddLineToPoint(ctx, line_2_x, line_2_y);
//    CGContextAddLineToPoint(ctx, line_3_x, line_3_y);
//    CGContextAddLineToPoint(ctx, line_4_x, line_4_y);
//    CGContextAddLineToPoint(ctx, line_5_x, line_5_y);
//    CGContextAddLineToPoint(ctx, line_6_x, line_6_y);
    
    CGContextClosePath(ctx);
    
    if (!_costomColor) {
        _costomColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    CGContextSetFillColorWithColor(ctx, _costomColor.CGColor);
//     [[UIColor redColor] setStroke];
//     CGContextStrokePath(ctx);
    
    CGContextFillPath(ctx);
}

//
////绘制文本
//- (void)drawText:(CGRect)rect {
//
//    //文本段落样式
//    NSMutableParagraphStyle * textStyle = [[NSMutableParagraphStyle alloc] init];
//    textStyle.lineBreakMode = NSLineBreakByWordWrapping;//结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab…yz”)
//    textStyle.alignment = NSTextAlignmentCenter;//文本对齐方式：（左，中，右，两端对齐，自然）
////    textStyle.lineSpacing = 8; //字体的行间距
////    textStyle.firstLineHeadIndent = 35.0; //首行缩进
////    textStyle.headIndent = 0.0; //整体缩进(首行除外)
////    textStyle.tailIndent = 0.0; //尾部缩进
//    textStyle.minimumLineHeight = rect.size.height;//40.0; //最低行高
//    textStyle.maximumLineHeight = rect.size.height;//40.0; //最大行高
//    textStyle.paragraphSpacing = 15; //段与段之间的间距
////    textStyle.paragraphSpacingBefore = 22.0f; // 段首行空白空间
//    textStyle.baseWritingDirection = NSWritingDirectionLeftToRight; //从左到右的书写方向
////    textStyle.lineHeightMultiple = 15;
////    textStyle.hyphenationFactor = 1; //连字属性 在iOS，唯一支持的值分别为0和1
//    //文本属性
//    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
//    //段落样式
//    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
//    //字体名称和大小
//    [textAttributes setValue:[UIFont systemFontOfSize:10.0] forKey:NSFontAttributeName];
//    //颜色
//    [textAttributes setValue:[UIColor redColor] forKey:NSForegroundColorAttributeName];
//    //绘制文字
//    [_textStr drawInRect:rect withAttributes:textAttributes];
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGRect frame = rect;
    frame.size.height = frame.size.height - _angleHeight;// - 10;
    rect = frame;
    
    //绘制带箭头的框框
    [self drawArrowRectangle:rect];
   
//     [self drawText:rect];
}


@end
