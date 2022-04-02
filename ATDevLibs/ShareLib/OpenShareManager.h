//
//  OpenShareManager.h
//  EngineeringCool
//
//  Created by Mars on 2019/8/27.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenShareManager : NSObject

///  分享
/// @param linkUrl link
/// @param desc 详细说明
/// @param imageName 图片名
+ (void)invitedToJoinUs:(NSString *)linkUrl desc:(NSString *)desc image:(NSString *)imageName;


/// 分享
/// @param linkUrl 链接
/// @param desc 描述
/// @param imageName 图片名
/// @param excludetypes 例外（不支持）
+ (void)invitedToJoinUs:(NSString *)linkUrl desc:(NSString *)desc image:(NSString *)imageName excludetypes:(NSArray *)excludetypes;


/// 分享
/// @param linkUrl 链接
/// @param title 描述
/// @param image  UIImage 图片名
+ (void)shareMessage_LinkUrl:(NSString *)linkUrl title:(NSString *)title image:(UIImage *)image;

/// 分享
/// @param linkUrl 链接
/// @param title 描述
/// @param image  UIImage 图片名
/// @param excludetypes 例外（不支持）
+ (void)shareMessage_LinkUrl:(NSString *)linkUrl title:(NSString *)title image:(UIImage *)image excludetypes:(NSArray *)excludetypes;

//邀请加入
+ (void)sharePDF:(NSString *)linkUrl;


@end

NS_ASSUME_NONNULL_END
