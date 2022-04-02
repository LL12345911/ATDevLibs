//
//  OpenShareManager.m
//  EngineeringCool
//
//  Created by Mars on 2019/8/27.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "OpenShareManager.h"
#import <Social/Social.h>
#import "Toast.h"

//#import "LWShareService.h"
//#import "OpenShareHeader.h"

@implementation OpenShareManager

+ (NSArray *)excludetypes{
    NSMutableArray *excludeTypesM =  [NSMutableArray arrayWithArray:@[UIActivityTypePostToFacebook,
                                                                      UIActivityTypePostToTwitter,
                                                                      UIActivityTypePostToWeibo,
                                                                      UIActivityTypeMessage,
                                                                      UIActivityTypeMail,
                                                                      UIActivityTypePrint,
                                                                      UIActivityTypeCopyToPasteboard,
                                                                      UIActivityTypeAssignToContact,
                                                                     //UIActivityTypeSaveToCameraRoll,
                                                                      UIActivityTypeAddToReadingList,
                                                                      UIActivityTypePostToFlickr,
                                                                      UIActivityTypePostToVimeo,
                                                                      UIActivityTypePostToTencentWeibo,
                                                                      UIActivityTypeAirDrop,
                                                                      //@"com.tencent.xin.sharetimeline",
                                                                      UIActivityTypeOpenInIBooks]];
    
     if (@available(iOS 11.0, *)) {
        [excludeTypesM addObject:UIActivityTypeMarkupAsPDF];
    }
    return excludeTypesM;
}

///  分享
/// @param linkUrl link
/// @param desc 详细说明
/// @param imageName 图片名
+ (void)invitedToJoinUs:(NSString *)linkUrl desc:(NSString *)desc image:(NSString *)imageName{
    
    NSString *shareTitle = [NSString stringWithFormat:@"%@",desc];;
    UIImage *shareImage = [UIImage imageNamed:imageName];
    NSURL *shareUrl = [NSURL URLWithString:linkUrl];
    NSArray *activityItems = @[shareTitle,shareImage,shareUrl];
    
    UIActivity *actice = [[UIActivity alloc] init];
     NSArray *activities = @[actice];
    
    [self pushActivityViewControllerWithActivityItems:activityItems applicationActivities:activities excludetypes:nil];
    
//    UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
//
//    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
//        if (completed) {
//            //分享完成
//            [Toast showWithText:@"分享成功"];
//        }else{
//            //分享失败
//            [Toast showWithText:@"分享失败"];
//        }
//
//        [activityVC dismissViewControllerAnimated:YES completion:nil];
//    };
//
//    activityVC.completionWithItemsHandler = myBlock;
//    // 设定不想显示的平台和功能
//    activityVC.excludedActivityTypes = [self excludetypes];
//    //这儿一定要做iPhone与iPad的判断，因为这儿只有iPhone可以present，iPad需pop，所以这儿actVC.popoverPresentationController.sourceView = self.view;在iPad下必须有，不然iPad会crash，self.view你可以换成任何view，你可以理解为弹出的窗需要找个依托。
//    activityVC.modalPresentationStyle = UIModalPresentationFullScreen;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        activityVC.popoverPresentationController.sourceView = [OpenShareManager currentVC].view;
//        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
//    } else {
//        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
//    }
}

/// 分享
/// @param linkUrl 链接
/// @param desc 描述
/// @param imageName 图片名
/// @param excludetypes 例外（不支持）
+ (void)invitedToJoinUs:(NSString *)linkUrl desc:(NSString *)desc image:(NSString *)imageName excludetypes:(NSArray *)excludetypes{
    NSString *shareTitle = [NSString stringWithFormat:@"%@",desc];;
    UIImage *shareImage = [UIImage imageNamed:imageName];
    NSURL *shareUrl = [NSURL URLWithString:linkUrl];
    NSArray *activityItems = @[shareTitle,shareImage,shareUrl];
    
    UIActivity *actice = [[UIActivity alloc] init];
     NSArray *activities = @[actice];
    
    [self pushActivityViewControllerWithActivityItems:activityItems applicationActivities:activities excludetypes:excludetypes];
    
}

+ (void)pushActivityViewControllerWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)activities excludetypes:(NSArray *)excludetypes{
    UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
    
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        if (completed) {
            //分享完成
            [Toast showWithText:@"分享成功"];
        }else{
            //分享失败
            [Toast showWithText:@"分享失败"];
        }
        
        [activityVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    activityVC.completionWithItemsHandler = myBlock;
    // 设定不想显示的平台和功能
    activityVC.excludedActivityTypes = excludetypes ? excludetypes : [self excludetypes];
    //这儿一定要做iPhone与iPad的判断，因为这儿只有iPhone可以present，iPad需pop，所以这儿actVC.popoverPresentationController.sourceView = self.view;在iPad下必须有，不然iPad会crash，self.view你可以换成任何view，你可以理解为弹出的窗需要找个依托。
    activityVC.modalPresentationStyle = UIModalPresentationFullScreen;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = [OpenShareManager currentVC].view;
        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
    } else {
        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
    }
}


//判断字符串是否为空
CG_INLINE BOOL ATValidStr(NSString *f){
    return (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""]);
}

//如果 不为空 返回原字符串 为空返回空字符串
CG_INLINE NSString* kIfNullString(NSString *f){
    return ATValidStr(f) ? f : @"";
}

/// 分享
/// @param linkUrl 链接
/// @param title 描述
/// @param image  UIImage 图片名
+ (void)shareMessage_LinkUrl:(NSString *)linkUrl title:(NSString *)title image:(UIImage *)image{
    NSURL *shareUrl = [NSURL URLWithString:linkUrl];
    NSArray *activityItems;
    if (image) {
       activityItems = @[kIfNullString(title),image,shareUrl];
    }else {
       activityItems = @[kIfNullString(title),shareUrl];
    }
    //    UIActivity *actice = [[UIActivity alloc] init];
    //    NSArray *activities = @[actice];
    
    [self pushActivityViewControllerWithActivityItems:activityItems applicationActivities:nil excludetypes:nil];

    
//    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//
//    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
//        if (completed) {
//            //分享完成
//            [Toast showWithText:@"分享成功"];
//        }else{
//            //分享失败
//            [Toast showWithText:@"分享失败"];
//        }
//
//        [activityVC dismissViewControllerAnimated:YES completion:nil];
//    };
//
//    activityVC.completionWithItemsHandler = myBlock;
//    // 设定不想显示的平台和功能
//    activityVC.excludedActivityTypes = [self excludetypes];
//    //这儿一定要做iPhone与iPad的判断，因为这儿只有iPhone可以present，iPad需pop，所以这儿actVC.popoverPresentationController.sourceView = self.view;在iPad下必须有，不然iPad会crash，self.view你可以换成任何view，你可以理解为弹出的窗需要找个依托。
//    activityVC.modalPresentationStyle = UIModalPresentationFullScreen;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        activityVC.popoverPresentationController.sourceView = [OpenShareManager currentVC].view;
//        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
//    } else {
//        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
//    }
}
/// 分享
/// @param linkUrl 链接
/// @param title 描述
/// @param image  UIImage 图片名
/// @param excludetypes 例外（不支持）
+ (void)shareMessage_LinkUrl:(NSString *)linkUrl title:(NSString *)title image:(UIImage *)image excludetypes:(NSArray *)excludetypes{
    NSURL *shareUrl = [NSURL URLWithString:linkUrl];
    NSArray *activityItems;
    if (image) {
       activityItems = @[kIfNullString(title),image,shareUrl];
    }else {
       activityItems = @[kIfNullString(title),shareUrl];
    }
    //    UIActivity *actice = [[UIActivity alloc] init];
    //    NSArray *activities = @[actice];
    [self pushActivityViewControllerWithActivityItems:activityItems applicationActivities:nil excludetypes:excludetypes];

}


// 邀请加入
+ (void)sharePDF:(NSString *)linkUrl{
    
    NSURL *shareUrl = [NSURL fileURLWithPath:linkUrl];
    NSData *data = [[NSData alloc] initWithContentsOfFile:linkUrl];
    NSArray *activityItems = @[data,shareUrl];
    
    UIActivity *actice = [[UIActivity alloc] init];
    NSArray *activities = @[actice];
    
    UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
    
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        if (completed) {
            //分享完成
            [Toast showWithText:@"分享成功"];
        }else{
            //分享失败
            [Toast showWithText:@"分享失败"];
        }
        
        [activityVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    activityVC.completionWithItemsHandler = myBlock;
    // 设定不想显示的平台和功能
    activityVC.excludedActivityTypes = [self excludetypes];
    //这儿一定要做iPhone与iPad的判断，因为这儿只有iPhone可以present，iPad需pop，所以这儿actVC.popoverPresentationController.sourceView = self.view;在iPad下必须有，不然iPad会crash，self.view你可以换成任何view，你可以理解为弹出的窗需要找个依托。
    activityVC.modalPresentationStyle = UIModalPresentationFullScreen;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = [OpenShareManager currentVC].view;
        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
    } else {
        [[OpenShareManager currentVC] presentViewController:activityVC animated:YES completion:nil];
    }
}


#pragma mark -
#pragma mark - 获取当前控制器
+ (UIViewController *)currentVC {
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

@end
