//
//  UIScrollView+ATKit.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/17.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIScrollView+ATKit.h"
#import "UIKitLibDefine.h"

//
ATSYNTH_DUMMY_CLASS(UIScrollView_ATKit)


@implementation UIScrollView (ATKit)


- (BOOL)alreadyAtTop {
    if (((NSInteger)self.contentOffset.y) == -((NSInteger)self.at_contentInset.top)) {
        return YES;
    }
    
    return NO;
}

//- (BOOL)alreadyAtBottom {
//    if (!self.canScroll) {
//        return YES;
//    }
//    
//    if (((NSInteger)self.contentOffset.y) == ((NSInteger)self.contentSize.height + self.contentInset.bottom - CGRectGetHeight(self.bounds))) {
//        return YES;
//    }
//    
//    return NO;
//}

- (UIEdgeInsets)at_contentInset {
    if (@available(iOS 11, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

/// 判断一个 CGSize 是否为空（宽或高为0）
CG_INLINE BOOL
CGSizeIsEmpty(CGSize size) {
    return size.width <= 0 || size.height <= 0;
}
/// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}
/// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

- (BOOL)canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGSizeIsEmpty(self.bounds.size)) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.at_contentInset) > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.at_contentInset) > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}


//frame
- (CGFloat)contentWidth {
    return self.contentSize.width;
}
- (void)setContentWidth:(CGFloat)width {
    self.contentSize = CGSizeMake(width, self.frame.size.height);
}
- (CGFloat)contentHeight {
    return self.contentSize.height;
}
- (void)setContentHeight:(CGFloat)height {
    self.contentSize = CGSizeMake(self.frame.size.width, height);
}
- (CGFloat)contentOffsetX {
    return self.contentOffset.x;
}
- (void)setContentOffsetX:(CGFloat)x {
    self.contentOffset = CGPointMake(x, self.contentOffset.y);
}
- (CGFloat)contentOffsetY {
    return self.contentOffset.y;
}
- (void)setContentOffsetY:(CGFloat)y {
    self.contentOffset = CGPointMake(self.contentOffset.x, y);
}
//


- (CGPoint)topContentOffset{
    return CGPointMake(0.0f, -self.at_contentInset.top);
}
- (CGPoint)bottomContentOffset{
    return CGPointMake(0.0f, self.contentSize.height + self.at_contentInset.bottom - self.bounds.size.height);
}
- (CGPoint)leftContentOffset{
    return CGPointMake(-self.at_contentInset.left, 0.0f);
}
- (CGPoint)rightContentOffset{
    return CGPointMake(self.contentSize.width + self.at_contentInset.right - self.bounds.size.width, 0.0f);
}

- (ATScrollDirection)ScrollDirection{
    ATScrollDirection direction;
    
    if ([self.panGestureRecognizer translationInView:self.superview].y > 0.0f){
        direction = ATScrollDirectionUp;
    }else if ([self.panGestureRecognizer translationInView:self.superview].y < 0.0f){
        direction = ATScrollDirectionDown;
    }else if ([self.panGestureRecognizer translationInView:self].x < 0.0f){
        direction = ATScrollDirectionLeft;
    }else if ([self.panGestureRecognizer translationInView:self].x > 0.0f){
        direction = ATScrollDirectionRight;
    }else{
        direction = ATScrollDirectionWTF;
    }
    
    return direction;
}
- (BOOL)isScrolledToTop{
    return self.contentOffset.y <= [self topContentOffset].y;
}
- (BOOL)isScrolledToBottom{
    return self.contentOffset.y >= [self bottomContentOffset].y;
}
- (BOOL)isScrolledToLeft{
    return self.contentOffset.x <= [self leftContentOffset].x;
}
- (BOOL)isScrolledToRight{
    return self.contentOffset.x >= [self rightContentOffset].x;
}
- (void)scrollToTopAnimated:(BOOL)animated{
    [self setContentOffset:[self topContentOffset] animated:animated];
}
- (void)scrollToBottomAnimated:(BOOL)animated{
    [self setContentOffset:[self bottomContentOffset] animated:animated];
}
- (void)scrollToLeftAnimated:(BOOL)animated{
    [self setContentOffset:[self leftContentOffset] animated:animated];
}
- (void)scrollToRightAnimated:(BOOL)animated{
    [self setContentOffset:[self rightContentOffset] animated:animated];
}
- (NSUInteger)verticalPageIndex{
    return (self.contentOffset.y + (self.frame.size.height * 0.5f)) / self.frame.size.height;
}
- (NSUInteger)horizontalPageIndex{
    return (self.contentOffset.x + (self.frame.size.width * 0.5f)) / self.frame.size.width;
}
- (void)scrollToVerticalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated{
    [self setContentOffset:CGPointMake(0.0f, self.frame.size.height * pageIndex) animated:animated];
}
- (void)scrollToHorizontalPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated{
    [self setContentOffset:CGPointMake(self.frame.size.width * pageIndex, 0.0f) animated:animated];
}



#pragma mark - Pages
- (NSInteger)pages{
    NSInteger pages = self.contentSize.width/self.frame.size.width;
    return pages;
}
- (NSInteger)currentPage{
    NSInteger pages = self.contentSize.width/self.frame.size.width;
    CGFloat scrollPercent = [self scrollPercent];
    NSInteger currentPage = (NSInteger)roundf((pages-1)*scrollPercent);
    return currentPage;
}
- (CGFloat)scrollPercent{
    CGFloat width = self.contentSize.width-self.frame.size.width;
    CGFloat scrollPercent = self.contentOffset.x/width;
    return scrollPercent;
}

- (CGFloat)pagesY {
    CGFloat pageHeight = self.frame.size.height;
    CGFloat contentHeight = self.contentSize.height;
    return contentHeight/pageHeight;
}
- (CGFloat)pagesX{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat contentWidth = self.contentSize.width;
    return contentWidth/pageWidth;
}
- (CGFloat)currentPageY{
    CGFloat pageHeight = self.frame.size.height;
    CGFloat offsetY = self.contentOffset.y;
    return offsetY / pageHeight;
}
- (CGFloat)currentPageX{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offsetX = self.contentOffset.x;
    return offsetX / pageWidth;
}
- (void)setPageY:(CGFloat)page{
    [self setPageY:page animated:NO];
}
- (void) setPageX:(CGFloat)page{
    [self setPageX:page animated:NO];
}
- (void)setPageY:(CGFloat)page animated:(BOOL)animated {
    CGFloat pageHeight = self.frame.size.height;
    CGFloat offsetY = page * pageHeight;
    CGFloat offsetX = self.contentOffset.x;
    CGPoint offset = CGPointMake(offsetX,offsetY);
    [self setContentOffset:offset];
}
- (void)setPageX:(CGFloat)page animated:(BOOL)animated{
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offsetY = self.contentOffset.y;
    CGFloat offsetX = page * pageWidth;
    CGPoint offset = CGPointMake(offsetX,offsetY);
    [self setContentOffset:offset animated:animated];
}




#pragma mark -

- (void)scrollToTop {
    [self scrollToTopAnimated:YES];
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:YES];
}

- (void)scrollToLeft {
    [self scrollToLeftAnimated:YES];
}

- (void)scrollToRight {
    [self scrollToRightAnimated:YES];
}

- (void)at_scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.at_contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)at_scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = self.contentSize.height - self.bounds.size.height + self.at_contentInset.bottom;
    [self setContentOffset:off animated:animated];
}

- (void)at_scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.at_contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)at_scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = self.contentSize.width - self.bounds.size.width + self.at_contentInset.right;
    [self setContentOffset:off animated:animated];
}

@end
