//
//  ATJsonDicTrans.m
//  EngineeringCool
//
//  Created by Mars on 2023/3/15.
//  Copyright © 2023 Mars. All rights reserved.
//

#import "JsonTransForm.h"
#import <objc/runtime.h>

@implementation JsonTransForm

/**
 * 字典转JSON
 *
 *
 * @param dict 需要序列换的参数
 *
 * @return JSON字符串
 
 */
+ (NSString *)dictToJsonString:(NSDictionary *)dict{
    
    NSError *error;
    NSData *jsonData;
    
    if (@available(iOS 11.0, *)) {
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys error:&error];
    } else {
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    }
    NSString *jsonString;
    if (!jsonData) {
#ifdef DEBUG
        NSLog(@"%@",error);
#endif
    }else{
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
//    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//    
//    //去掉字符串中的空格
//    NSRange range = NSMakeRange(0, jsonString.length);
//    [mutStr replaceOccurrencesOfString:@" : " withString:@":" options:NSLiteralSearch range:range];
//    
////    //去掉字符串中的换行符
////    NSRange range2 = NSMakeRange(0, mutStr.length);
////    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range2];
//    
//    //去掉字符串中的换行符
//    NSRange range4 = NSMakeRange(0, mutStr.length);
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range4];
    
    return jsonString;
}


/**
 * NSArray（数组）转JSON（NSString） 字符串
 *
 *
 * @param array 需要转换的参数（数组）
 *
 * @return JSON字符串
 
 */
+ (NSString *)toJsonStrWithArray:(NSArray *)array {
    
    NSError *error;
    NSData *jsonData;
    
    if (@available(iOS 11.0, *)) {
        jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingSortedKeys error:&error];
    } else {
        jsonData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
    }
    
    NSString *jsonString;
    if (!jsonData) {
#ifdef DEBUG
        NSLog(@"%@",error);
#endif
    }else{
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
//    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//    
////    //去掉字符串中的空格
////    NSRange range = NSMakeRange(0, jsonString.length);
////    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//    
//    //去掉字符串中的换行符
//    NSRange range2 = NSMakeRange(0, mutStr.length);
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return jsonString;
}


/**
 * JSON（NSString） 字符串   转   NSDictionary（字典）
 *
 *
 * @param jsonString   JSON字符串
 *
 * @return NSDictionary（字典）
 
 */
+ (NSDictionary *)jsonStringToDict:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){
#ifdef DEBUG
        NSLog(@"json解析失败：%@",err);
#endif
        return nil;
    }
    return dic;
}


/**
 * JSON（NSString） 字符串   转   NSArray（数组）
 *
 *
 * @param jsonString   JSON字符串
 *
 * @return NSArray（数组）
 
 */
+ (NSArray *)jsonStringToArray:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    NSError *err;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray* jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&err];
    if (jsonObject != nil && err == nil){
        return jsonObject;
    }else{
#ifdef DEBUG
        NSLog(@"json解析失败：%@",err);
#endif
        // 解析错误
        return nil;
    }
    
}




/**
 * 对象序列成字典
 *
 * @param obj 需要序列化的对象
 *
 * @return 字典
 */
+ (NSDictionary *)objectToDict:(id)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++) {
        objc_property_t prop = props[i];
        id value = nil;
        
        @try {
            NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
            value = [self getObjectInternal_Ext:[obj valueForKey:propName]];
            if(value != nil) {
                [dic setObject:value forKey:propName];
            }
        }
        @catch (NSException *exception) {
            //[self logError:exception];
            NSLog(@"%@",exception);
        }
    }
    free(props);
    return dic;
}

/**
 * 将对象序列换成JSON字符串
 *
 * @param obj 需要序列换的参数
 * @param options  设置nsjsonwritingprettyprinting选项将生成带有空格的JSON，以使输出更具可读性。如果没有设置该选项，将生成尽可能紧凑的
 * @param error 失败时，失败信息
 *
 * @return 修改的json 字符串的数据， 如果发生错误，error参数将被设置，返回值将为nil。
 */
+ (NSString *)objectToJsonString:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self objectToDict:obj] options:options error:error];
    if (!jsonData) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //NSRange range = {0,jsonString.length};
    ////去掉字符串中的空格
    //[mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = NSMakeRange(0, mutStr.length);
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

/**
 * 将对象序列换成JSON字符串
 *
 * @param obj 需要序列换的参数
 * @param options  设置nsjsonwritingprettyprinting选项将生成带有空格的JSON，以使输出更具可读性。如果没有设置该选项，将生成尽可能紧凑的
 *
 * @return 修改的json 字符串的数据 ， 如果发生错误，error参数将被设置，返回值将为nil。
 */
+ (NSString *)objectToJsonString:(id)obj options:(NSJSONWritingOptions)options {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self objectToDict:obj] options:options error:&error];
    if (!error) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //NSRange range = {0,jsonString.length};
    ////去掉字符串中的空格
    //[mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = NSMakeRange(0, mutStr.length);
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}


/**
 * 将对象序列换成JSON字符串
 *
 * @param obj 需要序列换的参数
 *
 * @return 修改的json 字符串的数据
 */
+ (NSString *)objectToJsonString:(id)obj {
    NSError *error;
    NSData *jsonData;
    if (@available(iOS 11.0, *)) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self objectToDict:obj] options:NSJSONWritingSortedKeys error:&error];
    } else {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self objectToDict:obj] options:kNilOptions error:&error];
    }
    if (!error) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//    //NSRange range = {0,jsonString.length};
//    ////去掉字符串中的空格
//    //[mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//    NSRange range2 = NSMakeRange(0, mutStr.length);
//    //去掉字符串中的换行符
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return jsonString;
}






/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)urlQueryToDict:(NSString *)query {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *parameters = [query componentsSeparatedByString:@"&"];
    for(NSString *parameter in parameters) {
        NSArray *contents = [parameter componentsSeparatedByString:@"="];
        if([contents count] == 2) {
            NSString *key = [contents objectAtIndex:0];
            NSString *value = [contents objectAtIndex:1];
            //    if (@available(iOS 9, *)) {
            //        value = [value stringByRemovingPercentEncoding];
            //    }else{
            //        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
            if (key && value) {
                [dict setObject:value forKey:key];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

/**
 *  @brief  将NSDictionary转换成url 参数字符串
 *
 *  @return url 参数字符串
 */
+ (NSString *)dictToUrlQuery:(NSDictionary *)dict {

    NSMutableString *string = [NSMutableString string];
    for (NSString *key in [dict allKeys]) {
        if ([string length]) {
            [string appendString:@"&"];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)[[dict objectForKey:key] description],NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
        
#pragma clang diagnostic pop
        [string appendFormat:@"%@=%@", key, escaped];
        CFRelease(escaped);
    }
    return string;
}


+ (id)getObjectInternal_Ext:(id)obj {
    if(!obj
       || [obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++) {
            [arr setObject:[self getObjectInternal_Ext:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys) {
            [dic setObject:[self getObjectInternal_Ext:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self objectToDict:obj];
}


@end
