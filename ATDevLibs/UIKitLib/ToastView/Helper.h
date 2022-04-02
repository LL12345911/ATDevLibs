//
//  Helper.h
//  ZenCushion
//
//  Created by Mars on 16/8/23.
//  Copyright © 2016年 Mars. All rights reserved.
//

//#import <Foundation/Foundation.h>


#import <Foundation/Foundation.h>

/**   记录App打开次数  */
static NSString * const kAppOpenTimes = @"kAppOpenTimes";

static NSString * const USER_CanOpenApp = @"user_CanOpenApp"; //1 是从其他APP唤醒 0自己打开
static NSString * const USER_AppName = @"user_AppName"; //从哪个APP打开


@interface Helper : NSObject

/**
 *  记录App打开次数
 */
+ (void)recordAppOpenTimes;
/**
 *  返回App打开次数
 */
+ (NSInteger)appOpenTimes;
/**
 *  是否是第一次打开App
 */
+ (BOOL)isFirstOpenApp;


//+ (void)setUserKeyValue:(id)value forKey:(NSString *)key;

+ (void)setUserObject:(id)object forkey:(NSString *)key;

+ (id)getObjectForKey:(NSString *)key;

+ (void)removeObjectForKey:(NSString *)key;

+ (void)removeAll;



@end
