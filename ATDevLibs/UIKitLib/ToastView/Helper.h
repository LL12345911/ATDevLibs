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


/**
 判断是否存在该key
 */
+ (BOOL)objectIsIncludeForKey:(NSString *)defaultName;

/// **-stringForKey:**  与  **-objectForKey:** 相当，
/// 不同之处在于它会将 NSNumber 值转换为其 NSString 表示形式。如果找到的值既不是字符串也不是数字，则返回 nil。
+ (nullable NSString *)stringForKey:(nullable NSString *)defaultName;

/// **-arrayForKey:** 与 **-objectForKey:`** 相当，
/// 不同之处在于，如果值不是 NSArray 类型，它将返回 nil 。
+ (nullable NSArray *)arrayForKey:(nullable NSString *)defaultName;

/// **dictionaryForKey：”** 方法的功能与 **objectForKey：”** 方法相同，
/// 不同之处在于，如果所返回的值不是字典类型，则该方法会返回 nil 。
+ (nullable NSDictionary<NSString *, id> *)dictionaryForKey:(nullable NSString *)defaultName;

/// -dataForKey: 等同于 -objectForKey:，区别在于如果值不是 NSData 类型则返回 nil。
+ (nullable NSData *)dataForKey:(nullable NSString *)defaultName;

/// -stringArrayForKey: 等同于 -objectForKey:，区别在于如果值不是 NSArray<NSString *> 类型则返回 nil。
/// 注意：与 -stringForKey: 不同，NSNumber 不会被转换为 NSString。
+ (nullable NSArray<NSString *> *)stringArrayForKey:(nullable NSString *)defaultName;


/*!
 -integerForKey: 等同于 -objectForKey:，区别在于会将返回值转换为 NSInteger。
 如果值是 NSNumber 类型，则返回 -integerValue 的结果。
 如果值是 NSString 类型，则会尝试转换为 NSInteger。
 如果值是布尔值，YES 转换为 1，NO 转换为 0。
 如果值不存在或无法转换为整数，则返回 0。
 */
+ (NSInteger)integerForKey:(nullable NSString *)defaultName;

/// -floatForKey: 类似 -integerForKey:，区别在于返回 float 类型且不转换布尔值。
+ (float)floatForKey:(nullable NSString *)defaultName;

/// -doubleForKey: 类似 -integerForKey:，区别在于返回 double 类型且不转换布尔值。
+ (double)doubleForKey:(nullable NSString *)defaultName;
/*!
 -boolForKey: 等同于 -objectForKey:，区别在于会将返回值转换为 BOOL。
 如果值是 NSNumber 类型：0 返回 NO，非零值返回 YES。
 如果值是 NSString 类型："YES" 或 "1" 返回 YES，"NO"、"0" 或其他字符串返回 NO。
 如果值不存在或无法转换为 BOOL，则返回 NO。
 */
+ (BOOL)boolForKey:(nullable NSString *)defaultName;

/*!
 -URLForKey: 等同于 -objectForKey:，区别在于会将返回值转换为 NSURL。
 如果值是 NSString 类型的路径，则会根据该路径构造一个文件 URL。
 如果值是通过 -setURL:forKey: 归档的 URL，则会进行解档操作。
 如果值不存在或无法转换为 NSURL，则返回 nil。
 */
+ (nullable NSURL *)URLForKey:(nullable NSString *)defaultName;


@end
