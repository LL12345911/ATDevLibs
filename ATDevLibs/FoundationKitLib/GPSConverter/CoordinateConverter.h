//
//  JZLocationConverter.h
//  JZCLLocationMangerDome
//
//  Created by jack zhou on 13-8-22.
//  Copyright (c) 2013年 JZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/// 各种坐标系统转换工具
@interface CoordinateConverter : NSObject


/// @brief 把经纬度转化为字符串
/// @param coord 经纬度
/// @return 返回的字符串格式为  经度,维度
+ (NSString *)stringFromCoord:(CLLocationCoordinate2D)coord;

///


/// @brief 把 x,y形式的字符串，转换为经纬度，注意：经度在前，维度在后
/// 如无效则返回kCLLocationCoordinate2DInvalid
/// @param coordString 经纬度字符串格式为 经度,维度
/// @return 经纬度坐标
+ (CLLocationCoordinate2D)coordinateFromString:(NSString *)coordString;


/**
 世界标准地理坐标(WGS-84) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 
 @param coordinate GPS坐标（WGS-84）
 @return 火星坐标（GCJ-02）
 */
+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)coordinate;

/**
 中国国测局地理坐标 火星坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 
 @param coordinate 火星坐标（GCJ-02）
 @return GPS坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)coordinate;

/**
 世界标准地理坐标(WGS-84) 转换成 百度地理坐标（BD-09)
 
 @param coordinate GPS坐标（WGS-84）
 @return 百度坐标（BD-09）
 */
+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)coordinate;

/**
 百度地理坐标（BD-09) 转换成 世界标准地理坐标（WGS-84）
 
 @param coordinate 百度坐标（BD-09）
 @return GPS坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)coordinate;

/**
 火星坐标（GCJ-02）转百度坐标（BD-09）
 中国国测局地理坐标（GCJ-02）<火星坐标> 转换成 百度地理坐标（BD-09)
 
 @param coordinate 火星坐标（GCJ-02）
 @return 百度坐标（BD-09）
 */
+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)coordinate;

/**
 百度地理坐标（BD-09) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 
 @param coordinate 百度坐标（BD-09）
 @return 火星坐标（GCJ-02）
 */
+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)coordinate;


@end
