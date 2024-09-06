//
//  AlignmentLabel.m
//  HighwayDoctor
//
//  Created by Mars on 2019/6/20.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "AlignmentLabel.h"

@interface AlignmentLabel ()
/* 对齐方式 */
@property(nonatomic, strong) NSArray * typeArray;
//上
@property(nonatomic, assign) BOOL hasTop;
//左
@property(nonatomic, assign) BOOL hasLeft;
//下
@property(nonatomic, assign) BOOL hasBottom;
//右
@property(nonatomic, assign) BOOL hasRight;

@end

@implementation AlignmentLabel


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    //CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    CGRect textRect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _edgeInsets) limitedToNumberOfLines:numberOfLines];
    if (self.typeArray){
        for (int i=0; i<self.typeArray.count; i++) {
            TextAlignType type = [self.typeArray[i] integerValue];
            switch (type) {
                case TextAlignType_top:  //顶部对齐
                    self.hasTop = YES;
                    textRect.origin.y = bounds.origin.y;
                    break;
                case TextAlignType_left: //左部对齐
                    self.hasLeft = YES;
                    textRect.origin.x = bounds.origin.x;
                    break;
                case TextAlignType_bottom: //底部对齐
                    self.hasBottom = YES;
                    textRect.origin.y = bounds.size.height - textRect.size.height;
                    break;
                case TextAlignType_right: //右部对齐
                    self.hasRight = YES;
                    textRect.origin.x = bounds.size.width - textRect.size.width;
                    break;
                case TextAlignType_center:
                    if (self.hasTop) {  //上中
                        textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
                    }
                    else if (self.hasLeft) { //左中
                        textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
                    }
                    else if (self.hasBottom) { //下中
                        textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
                    }
                    else if (self.hasRight) { //右中
                        textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
                    }
                    else{   //上下左右居中
                        textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
                        textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
                    }
                    break;
                default:
                    break;
            }
        }
    }
    return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = requestedRect;
    if (self.typeArray) {
        actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
        
//        actualRect = [self drawTextInRect:UIEdgeInsetsInsetRect(rect, _edgeInsets)];
    }
    [super drawTextInRect:actualRect];
}

- (void)textAlign:(void(^)(ATMaker *make))alignType {
    ATMaker *make = [[ATMaker alloc]init];
    alignType(make);
    self.typeArray = make.typeArray;
}


/**
 初始化 Label

 @param textColor 字体颜色
 @param newline 是否换行
 @param font 字体大小
 @param alignType 对齐方式
 @return label
 */
+ (instancetype)inittextColor:(UIColor *)textColor newline:(NSInteger)newline font:(UIFont *)font textAlign:(void(^)(ATMaker *make))alignType{
    AlignmentLabel *labe = [[AlignmentLabel alloc] init];
    labe.font = font;
    labe.numberOfLines = newline;
    labe.textColor = textColor;
    
    ATMaker *make = [[ATMaker alloc]init];
    alignType(make);
    labe.typeArray = make.typeArray;
    
    return labe;
}


@end



//工具类
@implementation ATMaker

- (instancetype)init {
    self = [super init];
    if (self) {
        self.typeArray = [NSMutableArray array];
    }
    return self;
}

- (ATMaker *(^)(enum TextAlignType type))addAlignType {
    __weak typeof (self) weakSelf = self;
    return ^(enum TextAlignType type)
    {
        [weakSelf.typeArray addObject:@(type)];
        return weakSelf;
    };
}

@end

