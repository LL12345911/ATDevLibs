//
//  MarsTabBar.m
//  AirCnCWallet
//
//  Created by Mars on 2018/1/24.
//  Copyright © 2018年 AirCnC车去车来. All rights reserved.
//
//


#import "MarsTabBar.h"

@interface MarsTabBar()

@property (nonatomic,assign)UIEdgeInsets oldSafeAreaInsets;

@end


@implementation MarsTabBar


//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        _oldSafeAreaInsets = UIEdgeInsetsZero;
//    }
//    return self;
//}
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//
//    _oldSafeAreaInsets = UIEdgeInsetsZero;
//}

//ipad tabbarItem 图标文字竖排变横排
- (UITraitCollection *)traitCollection {
    if (UIDevice.currentDevice.userInterfaceIdiom ==  UIUserInterfaceIdiomPad) {
        return [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassCompact];
    }
    return [super traitCollection];
}

- (void) safeAreaInsetsDidChange{
    [super safeAreaInsetsDidChange];
    if(self.oldSafeAreaInsets.left != self.safeAreaInsets.left ||
       self.oldSafeAreaInsets.right != self.safeAreaInsets.right ||
       self.oldSafeAreaInsets.top != self.safeAreaInsets.top ||
       self.oldSafeAreaInsets.bottom != self.safeAreaInsets.bottom)
    {
        self.oldSafeAreaInsets = self.safeAreaInsets;
        [self invalidateIntrinsicContentSize];
        [self.superview setNeedsLayout];
        //[self.superview layoutSubviews];
    }
    
}

- (CGSize) sizeThatFits:(CGSize) size{
    CGSize s = [super sizeThatFits:size];
    if(@available(iOS 11.0, *)){
        CGFloat bottomInset = self.safeAreaInsets.bottom;
        if( bottomInset > 0 && s.height < 50) {
            s.height += bottomInset;
        }
    }
    return s;
}


@end
