//
//  UIButton+JKImagePosition.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIButton+ATImagePosition.h"

@implementation UIButton (ATImagePosition)
/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 *
 *  @param spacing 图片和文字的间隔
 */
- (void)at_setImagePosition:(ATImagePosition)postion spacing:(CGFloat)spacing {
    CGFloat imageWidth = self.currentImage.size.width;
    CGFloat imageHeight = self.currentImage.size.height;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // Single line, no wrapping. Truncation based on the NSLineBreakMode.
    CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font];
    CGFloat labelWidth = size.width;
    CGFloat labelHeight = size.height;
#pragma clang diagnostic pop
    
    CGFloat imageOffsetX = (imageWidth + labelWidth) / 2 - imageWidth / 2;//image中心移动的x距离
    CGFloat imageOffsetY = imageHeight / 2 + spacing / 2;//image中心移动的y距离
    CGFloat labelOffsetX = (imageWidth + labelWidth / 2) - (imageWidth + labelWidth) / 2;//label中心移动的x距离
    CGFloat labelOffsetY = labelHeight / 2 + spacing / 2;//label中心移动的y距离
    
    CGFloat tempWidth = MAX(labelWidth, imageWidth);
    CGFloat changedWidth = labelWidth + imageWidth - tempWidth;
    CGFloat tempHeight = MAX(labelHeight, imageHeight);
    CGFloat changedHeight = labelHeight + imageHeight + spacing - tempHeight;
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets contentEdgeInsets = UIEdgeInsetsZero;
    
    switch (postion) {
        case ATImagePositionLeft:
            imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2);
            titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2);
            contentEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, spacing/2);
            break;
            
        case ATImagePositionRight:
            if (labelWidth+imageWidth+spacing >= self.frame.size.width) {
                CGFloat left = self.frame.size.width - spacing - imageWidth;
                imageEdgeInsets = UIEdgeInsetsMake(0, left + spacing/2, 0, -spacing/2);
                titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + spacing/2), 0, imageWidth + spacing/2);

            }else{
                imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + spacing/2, 0, -(labelWidth + spacing/2));
                titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + spacing/2), 0, imageWidth + spacing/2);
            }
            contentEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, spacing/2);

//            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + spacing/2, 0, -(labelWidth + spacing/2));
//            titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + spacing/2), 0, imageWidth + spacing/2);
//            contentEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, spacing/2);
            
            break;
            
        case ATImagePositionTop:
            imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY, labelOffsetX);
            contentEdgeInsets = UIEdgeInsetsMake(imageOffsetY, -changedWidth/2, changedHeight-imageOffsetY, -changedWidth/2);
            break;
            
        case ATImagePositionBottom:
            imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX, labelOffsetY, labelOffsetX);
            contentEdgeInsets = UIEdgeInsetsMake(changedHeight-imageOffsetY, -changedWidth/2, imageOffsetY, -changedWidth/2);
            break;
        default:
            break;
    }
  
    self.imageEdgeInsets = imageEdgeInsets;
    self.titleEdgeInsets = titleEdgeInsets;
    self.contentEdgeInsets = contentEdgeInsets;
    
}



- (void)TagSetImagePosition:(ATImagePosition)postion spacing:(CGFloat)spacing {
     CGFloat imgWidth = self.imageView.bounds.size.width;
     CGFloat imgHeight = self.imageView.bounds.size.height;
     CGFloat labWidth = self.titleLabel.bounds.size.width;
     CGFloat labHeight = self.titleLabel.bounds.size.height;
     CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
     CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
     if (labWidth < frameSize.width) {
         labWidth = frameSize.width;
     }
     CGFloat kMargin = spacing/2.0;
     switch (postion) {
         case ATImagePositionLeft:
             [self setImageEdgeInsets:UIEdgeInsetsMake(0, -kMargin, 0, kMargin)];
             [self setTitleEdgeInsets:UIEdgeInsetsMake(0, kMargin, 0, -kMargin)];
             break;
             
         case ATImagePositionRight:
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, labWidth + kMargin, 0, -labWidth - kMargin)];
             [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgWidth - kMargin, 0, imgWidth + kMargin)];
             break;
             
         case ATImagePositionTop:
             [self setImageEdgeInsets:UIEdgeInsetsMake(0,0, labHeight + spacing, -labWidth)];
             [self setTitleEdgeInsets:UIEdgeInsetsMake(imgHeight + spacing, -imgWidth, 0, 0)];
             break;
             
         case ATImagePositionBottom:
             [self setImageEdgeInsets:UIEdgeInsetsMake(labHeight + spacing,0, 0, -labWidth)];
             [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgWidth, imgHeight + spacing, 0)];
             break;
             
         default:
             break;
     }
}

@end
