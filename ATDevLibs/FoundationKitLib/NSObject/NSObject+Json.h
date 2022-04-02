//
//  NSObject+Json.h
//  HighwayDoctor
//
//  Created by Mars on 2019/6/28.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Json)

#pragma mark - IOS 字典和对象互转
//将字典转成当前对象
- (void)convert:(NSDictionary*)dataSource;
//将对象转成字典
-(NSDictionary*)changeToDic;
//获取属性列表
- (NSArray*)propertyKeys;



#pragma mark -
//通过对象返回一个NSDictionary，键是属性名称，值是属性值。
+ (NSDictionary*)getObjectData:(id)obj;

//将getObjectData方法返回的NSDictionary转化成JSON
+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;

//直接通过NSLog输出getObjectData方法返回的NSDictionary
+ (void)print:(id)obj;


@end

NS_ASSUME_NONNULL_END
