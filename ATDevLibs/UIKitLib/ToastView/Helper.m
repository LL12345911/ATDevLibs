//
//  Helper.m
//  ZenCushion
//
//  Created by Mars on 16/8/23.
//  Copyright © 2016年 Mars. All rights reserved.
//

#import "Helper.h"
//#import "API.h"

@implementation Helper

/**
 *  记录App打开次数
 */
+ (void)recordAppOpenTimes  {
    //取出打开次数
    NSInteger times =  [[NSUserDefaults standardUserDefaults]integerForKey:kAppOpenTimes];
    //次数加1
    times++;
    [[NSUserDefaults standardUserDefaults] setInteger:times forKey:kAppOpenTimes];
}

/**
 *  返回App打开次数
 */
+ (NSInteger)appOpenTimes {
    return [[NSUserDefaults standardUserDefaults]integerForKey:kAppOpenTimes];
}

/**
 *  是否是第一次打开App
 */
+ (BOOL)isFirstOpenApp  {
    //    return YES
    
    if ([Helper appOpenTimes] == 1) {
        return YES;
    }
    return NO;
}

+ (void)setUserObject:(id)object forkey:(NSString *)key {
    [self removeObjectForKey:key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:object forKey:key];
    [userDefaults synchronize];
}


+ (void)removeAll {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //删除所有数据
    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
    for(NSString* key in [dictionary allKeys]){
        [userDefaults removeObjectForKey:key];
        [userDefaults synchronize];
    }
    //    userDefaults = nil;
    //    [userDefaults synchronize];
}


+ (id)getObjectForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSString *retStr = [userDefaults stringForKey:key];
    id retStr = [userDefaults objectForKey:key];
    return retStr;
}


+ (void)removeObjectForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}
@end
