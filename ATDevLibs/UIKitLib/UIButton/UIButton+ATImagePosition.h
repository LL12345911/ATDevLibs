//
//  UIButton+JKImagePosition.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//
//https://github.com/Phelthas/Demo_ButtonImageTitleEdgeInsets
// 用button的titleEdgeInsets和 imageEdgeInsets属性来实现button文字图片上下或者左右排列的
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ATImagePosition) {
   ATImagePositionLeft = 0,              //图片在左，文字在右，默认
   ATImagePositionRight = 1,             //图片在右，文字在左
   ATImagePositionTop = 2,               //图片在上，文字在下
   ATImagePositionBottom = 3,            //图片在下，文字在上
};

@interface UIButton (ATImagePosition)

/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 *
 *  @param spacing 图片和文字的间隔
 */
- (void)at_setImagePosition:(ATImagePosition)postion spacing:(CGFloat)spacing;


// 设置图文位置
- (void)TagSetImagePosition:(ATImagePosition)postion spacing:(CGFloat)spacing;

    
////
/////**
//// 设置button的imageView和titleLabel的布局样式及它们的间距
////
//// @param style imageView和titleLabel的布局样式
//// @param space imageView和titleLabel的间距
//// */
////- (void)layoutButtonWithImageStyle:(ATImagePosition)style
////                 imageTitleToSpace:(CGFloat)space;
////
//
///**
// @param spacing The middle spacing between imageView and titleLabel.
// @discussion The middle aligning method for imageView and titleLabel.
// */
//- (void)at_middleAlignButtonWithSpacing:(CGFloat)spacing;
//


@end
