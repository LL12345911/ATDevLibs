//
//  AuthorizationManager.h
//  AuthorizationManager<https://github.com/123sunxiaolin/AuthorizationManager.git>
//
//  <Wechat Public:iOSDevSkills>
//  Created by Jacklin on 2017/3/27.
//  Copyright © 2017年 com.jack.lin. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

typedef void (^GeneralAuthorizationCompletion) (void);

@interface AuthorizationManager : NSObject

+ (AuthorizationManager *)defaultManager;

/**
 请求权限统一入口

 @param authorizationType 权限类型
 @param authorizedHandler 授权后的回调
 @param unAuthorizedHandler 未授权的回调
 */
- (void)requestAuthorizationWithAuthorizationType:(AuthorizationType)authorizationType
                                   authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                 unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler;

///**
// 请求健康数据权限统一入口
//
// @param typesToShare 共享/写入共享数据类型集合
// @param typesToRead 读入共享数据类型集合
// @param authorizedHandler 授权后的回调
// @param unAuthorizedHandler 未授权的回调
// */
//- (void)requestHealthAuthorizationWithShareTypes:(NSSet*)typesToShare
//                                          readTypes:(NSSet*)typesToRead
//                                  authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler;
///**
//  请求社交账号访问权限
//
// @param authorizationType 权限类型
// @param options 请求账号时需要的配置信息(Facebook 和 腾讯微博不能为空)
// @param authorizedHandler 授权后的回调
// @param unAuthorizedHandler 未授权的回调
// @param errorHandler 产生错误的回调
// */
//- (void)requestAccountAuthorizationWithAuthorizationType:(AuthorizationType)authorizationType
//                                                    options:(NSDictionary *)options
//                                          authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                        unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler
//                                               errorHandler:(void(^)(NSError *error))errorHandler;
@end
