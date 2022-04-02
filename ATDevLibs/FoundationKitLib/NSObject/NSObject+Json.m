//
//  NSObject+Json.m
//  HighwayDoctor
//
//  Created by Mars on 2019/6/28.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "NSObject+Json.h"
#import <objc/objc.h>
#import <objc/runtime.h>

@implementation NSObject (Json)


//将字典转成当前对象
- (void)convert:(NSDictionary*)dataSource{
    for (NSString *key in [dataSource allKeys]) {
        if ([[self propertyKeys] containsObject:key]) {
            id propertyValue = [dataSource valueForKey:key];
            if (![propertyValue isKindOfClass:[NSNull class]]
                && propertyValue != nil) {
                [self setValue:propertyValue
                        forKey:key];
            }
        }
    }
}
//将对象转成字典
-(NSDictionary*)changeToDic{
    NSMutableDictionary*mDic = [NSMutableDictionary dictionary];
    for (NSString*key in [self propertyKeys]) {
        
        [mDic setValue:[self valueForKey:key] forKey:key];
    }
    return mDic;
}
//获取属性列表
- (NSArray*)propertyKeys{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableArray *propertys = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i<outCount; i++){
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [propertys addObject:propertyName];
    }
    free(properties);
    return propertys;
}




#pragma mark -


//通过对象返回一个NSDictionary，键是属性名称，值是属性值。
+ (NSDictionary*)getObjectData:(id)obj{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++){
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil){
            value = [NSNull null];
        }else{
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

//直接通过NSLog输出getObjectData方法返回的NSDictionary
+ (void)print:(id)obj{
    NSLog(@"%@", [self getObjectData:obj]);
}

//将getObjectData方法返回的NSDictionary转化成JSON
+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error{
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj] options:options error:error];
}


+ (id)getObjectInternal:(id)obj{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]]
       || [obj isKindOfClass:[NSDate class]]){
        
        return obj;
    }
    if([obj isKindOfClass:[NSArray class]]){
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++){
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]]){
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys){
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return  [self getObjectData:obj];
}


@end
