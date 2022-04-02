//
//  JsonTransform.h
//  EngineeringCool
//
//  Created by Mars on 2020/8/19.
//  Copyright © 2020 Mars. All rights reserved.
//

#ifndef JsonTransform_h
#define JsonTransform_h

//// json

#pragma mark -
#pragma mark - JSON
/*!
 * @brief 把json字符串转化成数组或者字典
 * @param jsonString JSON格式的字符串
 * @return id (Array数组 或 NSDictionary字典)
 */
CG_INLINE id IdWithJsonString(NSString *jsonString){
    if (jsonString == nil) {
          return nil;
      }
    NSData *JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil){
        if ([jsonObject isKindOfClass:[NSDictionary class]]){
            NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
            #ifdef DEBUG
            NSLog(@"反序列化后的dictionary数据 = %@", deserializedDictionary);
            #endif
            return deserializedDictionary;
            
        }else if ([jsonObject isKindOfClass:[NSArray class]]){
            
            NSArray *deserializedArray = (NSArray *)jsonObject;
            #ifdef DEBUG
            NSLog(@"反序列化json后的数组 = %@", deserializedArray);
            #endif
            return deserializedArray;
            
        }else {
            return nil;
        }
        
    }else{
        #ifdef DEBUG
        NSLog(@"反序列化时发生一个错误：%@", error);
        #endif
        return nil;
    }
}



/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
CG_INLINE NSDictionary* DictionaryWithJsonString(NSString *jsonString){
    if (jsonString == nil) {
           return nil;
       }
       
       NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
       NSError *err;
       NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:NSJSONReadingMutableContainers
                                                             error:&err];
       if(err) {
           #ifdef DEBUG
           NSLog(@"json解析失败：%@",err);
           #endif
           return nil;
       }
       return dic;
}
/*!
 * @brief json格式字符串转数组
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
CG_INLINE NSArray* ArrayWithJsonString(NSString *jsonString){
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
        // 解析错误
        return nil;
    }
}


/*!
 * @brief 把字典转换成JSON字符串
 * @param dict 字典
 * @return 返回JSON
 */
CG_INLINE NSString* JSONString(NSDictionary *dict){
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"%@",error);
#endif
        return nil;
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //NSRange range = {0,jsonString.length};
    ////去掉字符串中的空格
    //[mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
/**
 *  @brief  将NSArray转换成JSON 字符串
 *
 *  @param array url参数
 *
 *  @return NSString
 */
CG_INLINE NSString* JSONStringWithArray(NSArray *array){
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"%@",error);
#endif
        return nil;
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //NSRange range = {0,jsonString.length};
    ////去掉字符串中的空格
    //[mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
CG_INLINE NSDictionary* DictionaryWithURLQuery(NSString *query){
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
CG_INLINE NSString* URLQueryStringWithDic(NSDictionary *dic){

    NSMutableString *string = [NSMutableString string];
    for (NSString *key in [dic allKeys]) {
        if ([string length]) {
            [string appendString:@"&"];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)[[dic objectForKey:key] description],NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
        
#pragma clang diagnostic pop
        [string appendFormat:@"%@=%@", key, escaped];
        CFRelease(escaped);
    }
    return string;
}



#endif /* JsonTransform_h */
