//
//  UINavigationBar+NavBar.h
//  HighwayDoctor
//
//  Created by Mars on 2019/4/29.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationBar (NavBar)

/**
 判断 是否是 iPhone X
 
 @return 是 或 否
 */
+ (BOOL)isIphoneX;

/**
 判断 是否是 iPhone X
 
 @return 是 或 否
 */
+ (BOOL)isPhoneX;

- (void)at_setBackgroundColor:(UIColor *)backgroundColor;

- (void)at_setElementsAlpha:(CGFloat)alpha;

- (void)at_setTranslationY:(CGFloat)translationY;

- (void)at_reset;


- (void)at_setBackgroundImage:(UIImage *)backgroundImage;


/**
 设置导航栏背景图片

 @param backgroundImage 背景图片n名
 */
- (void)at_setBackgroundCustomImage:(NSString *)backgroundImage;

/**
 设置导航栏背景颜色
 
 @param color 背景颜色
 */
- (void)at_setBackgroundCustomColor:(UIColor *)color;

/**
 设置导航栏背景颜色
 
 @param alpha 设置透明度
 @param color 背景颜色
 */
- (void)at_setBackgroundCustomColor:(UIColor *)color alpha:(CGFloat)alpha;


/**
 设置导航栏标题颜色

 @param color 标题颜色
 */
- (void)at_setTitleTextAttribute:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END


//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.tableView.dataSource = self;
//    [self.navigationController.navigationBar at_setBackgroundColor:[UIColor clearColor]];
//    [self setBackButtonStyleLight:YES];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    UIColor * color = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1];
//    CGFloat offsetY = scrollView.contentOffset.y;
//    if (offsetY > NAVBAR_CHANGE_POINT) {
//        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64)); // NAVBAR_CHANGE_POINT  和  64  这两个参数 都是 看效果需求可酌情更改  就是 透明度变化的时机 系数
//        [self.navigationController.navigationBar at_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//
//        [self setBackButtonStyleLight:NO alpha:alpha];
//    } else {
//        [self.navigationController.navigationBar at_setBackgroundColor:[color colorWithAlphaComponent:0]];
//
//        [self setTitle:@""];
//        [self setBackButtonStyleLight:YES];
//    }
//}
//
//
//
//- (void)setBackButtonStyleLight:(BOOL)isLight
//{
//    [self setBackButtonStyleLight:isLight alpha:1];
//}
//
//- (void)setBackButtonStyleLight:(BOOL)isLight alpha:(CGFloat)alpha
//{
//    if(isLight){
//        [titleLabel setAlpha:1];//导航标题
//        [backButton setAlpha:1];//返回按钮
//        [titleLabel setText:@""];
//        UIImage *image = backButton.imageView.image;
//        UIImage *targetImage = [UIImage imageNamed:@"icon_fanhi"];
//        if(image != targetImage){
//            [backButton setImage:[UIImage imageNamed:@"icon_fanhi"] forState:UIControlStateNormal];
//            [backButton setImage:[UIImage imageNamed:@"icon_fanhi"] forState:UIControlStateHighlighted];
//        }
//    }else{
//        if(alpha < 0.5){
//            [titleLabel setText:@""];
//            UIImage *image = backButton.imageView.image;
//            UIImage *targetImage = [UIImage imageNamed:@"icon_fanhi"];
//            if(image != targetImage){
//                [backButton setImage:[UIImage imageNamed:@"icon_fanhi"] forState:UIControlStateNormal];
//                [backButton setImage:[UIImage imageNamed:@"icon_fanhi"] forState:UIControlStateHighlighted];
//            }
//            //先是之前的消失
//            [backButton setAlpha:(0.5 - alpha) * 2];
//        }else{
//            UIImage *image = backButton.imageView.image;
//            UIImage *targetImage = [UIImage imageNamed:@"icon_fanhihei"];
//            if(image != targetImage){
//                [backButton setImage:[UIImage imageNamed:@"icon_fanhihei"] forState:UIControlStateNormal];
//                [backButton setImage:[UIImage imageNamed:@"icon_fanhihei"] forState:UIControlStateHighlighted];
//            }
//            [titleLabel setText:foodItemModel.foodName];
//            //将返回和分享慢慢出现
//            CGFloat showAlpha = (alpha - 0.5) * 2;
//            [titleLabel setAlpha:showAlpha];
//            [backButton setAlpha:showAlpha];
//        }
//    }
//}
//
//
//
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:YES];
//    [self initScrollNav];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    //self.tableView.delegate = nil;//废弃代码
//    [self.navigationController.navigationBar at_reset];//页面消失时候要 恢复 正常导航栏模式
//}
//
//- (void)initScrollNav
//{
//    self.tableView.delegate = self;
//    [self scrollViewDidScroll:self.tableView];
//    [self.tableView reloadData];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//}
//
//- (void)dealloc
//{
//    self.tableView.delegate = nil;//不能在 viewWilldisappear 里nil 这时候 仍然会触发 scrollViewDidLoad 导致崩溃 需要卸写在这里
//}



#pragma mark - 还有一种情况 就是滚动过程中 导航栏消失 保留状态栏  这种情况 一些产品比较青睐  我个人特别不喜欢  一直坚信 ios7以后 苹果就是倡导 状态栏 导航栏一体化 所以留个状态栏 你以为是安卓吗? 丑爆了  然并卵  开发者只有提建议的权利 没有决定权 怎么实现 还是要会的 是吧
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat offsetY = scrollView.contentOffset.y;
//    if (offsetY > 0) {
//        if (offsetY >= 44) {
//            [self setNavigationBarTransformProgress:1];
//        } else {
//            [self setNavigationBarTransformProgress:(offsetY / 44)];
//        }
//    } else {
//        [self setNavigationBarTransformProgress:0];
//        self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
//    }
//}
//
//- (void)setNavigationBarTransformProgress:(CGFloat)progress
//{
//    [self.navigationController.navigationBar at_setTranslationY:(-44 * progress)];
//    [self.navigationController.navigationBar at_setElementsAlpha:(1-progress)];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:YES];//保留状态栏的那种情况
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [self.navigationController.navigationBar at_reset];
//}
