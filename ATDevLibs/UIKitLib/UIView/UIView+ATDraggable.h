//
//  UIView+ATDraggable.h
//  HighwayDoctor
//
//  Created by Mars on 2019/7/16.
//  Copyright © 2019 Mars. All rights reserved.
//
//一行代码使UIView可拖动, 且放开后回弹到原位置
/*
 
 【Feature】
 一行代码使UIView可拖动, 且放开后回弹到原位置
 使用分类方法，无需继承
 
 【Usage】
 #import "UIView+ATDraggable"
 [view makeDraggable];
 
 
 */


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ATDraggable)

/**
 *  Make view draggable.
 *
 *  @param view    Animator reference view, usually is super view.
 *  @param damping Value from 0.0 to 1.0. 0.0 is the least oscillation. default is 0.4.
 */
- (void)makeDraggableInView:(UIView *)view damping:(CGFloat)damping;
- (void)makeDraggable;

/**
 *  Disable view draggable.
 */
- (void)removeDraggable;

@end

NS_ASSUME_NONNULL_END
