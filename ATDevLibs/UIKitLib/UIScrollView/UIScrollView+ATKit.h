//
//  UIScrollView+ATKit.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ATScrollDirection) {
    ATScrollDirectionUp,
    ATScrollDirectionDown,
    ATScrollDirectionLeft,
    ATScrollDirectionRight,
    ATScrollDirectionWTF
};

@interface UIScrollView (ATKit)


/// 判断UIScrollView是否已经处于顶部（当UIScrollView内容不够多不可滚动时，也认为是在顶部）
@property(nonatomic, assign, readonly) BOOL alreadyAtTop;

///// 判断UIScrollView是否已经处于底部（当UIScrollView内容不够多不可滚动时，也认为是在底部）
//@property(nonatomic, assign, readonly) BOOL alreadyAtBottom;

/// UIScrollView 的真正 inset，在 iOS11 以后需要用到 adjustedat_contentInset 而在 iOS11 以前只需要用 at_contentInset
@property(nonatomic, assign, readonly) UIEdgeInsets at_contentInset;
/**
 * 判断当前的scrollView内容是否足够滚动
 * @warning 避免与<i>scrollEnabled</i>混淆
 */
- (BOOL)canScroll;

@property(nonatomic) CGFloat contentWidth;
@property(nonatomic) CGFloat contentHeight;
@property(nonatomic) CGFloat contentOffsetX;
@property(nonatomic) CGFloat contentOffsetY;

- (CGPoint)topContentOffset;
- (CGPoint)bottomContentOffset;
- (CGPoint)leftContentOffset;
- (CGPoint)rightContentOffset;

- (ATScrollDirection)ScrollDirection;

- (BOOL)isScrolledToTop;
- (BOOL)isScrolledToBottom;
- (BOOL)isScrolledToLeft;
- (BOOL)isScrolledToRight;
- (void)scrollToTopAnimated:(BOOL)animated;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)scrollToLeftAnimated:(BOOL)animated;
- (void)scrollToRightAnimated:(BOOL)animated;

- (NSUInteger)verticalPageIndex;
- (NSUInteger)horizontalPageIndex;

- (void)scrollToVerticalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)scrollToHorizontalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;


#pragma mark - Pages
- (NSInteger)pages;
- (NSInteger)currentPage;
- (CGFloat)scrollPercent;

- (CGFloat)pagesY;
- (CGFloat)pagesX;
- (CGFloat)currentPageY;
- (CGFloat)currentPageX;
- (void)setPageY:(CGFloat)page;
- (void)setPageX:(CGFloat)page;
- (void)setPageY:(CGFloat)page animated:(BOOL)animated;
- (void)setPageX:(CGFloat)page animated:(BOOL)animated;

#pragma mark -
/**
 Scroll content to top with animation.
 */
- (void)scrollToTop;
/**
 Scroll content to bottom with animation.
 */
- (void)scrollToBottom;
/**
 Scroll content to left with animation.
 */
- (void)scrollToLeft;
/**
 Scroll content to right with animation.
 */
- (void)scrollToRight;
/**
 Scroll content to top.
 @param animated  Use animation.
 */
- (void)at_scrollToTopAnimated:(BOOL)animated;
/**
 Scroll content to bottom.
 @param animated  Use animation.
 */
- (void)at_scrollToBottomAnimated:(BOOL)animated;
/**
 Scroll content to left.
 @param animated  Use animation.
 */
- (void)at_scrollToLeftAnimated:(BOOL)animated;
/**
 Scroll content to right.
 @param animated  Use animation.
 */
- (void)at_scrollToRightAnimated:(BOOL)animated;

@end



