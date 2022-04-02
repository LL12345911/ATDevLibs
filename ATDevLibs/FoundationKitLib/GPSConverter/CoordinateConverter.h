//
//  JZLocationConverter.h
//  JZCLLocationMangerDome
//
//  Created by jack zhou on 13-8-22.
//  Copyright (c) 2013年 JZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoordinateConverter : NSObject
/**
 GPS坐标（WGS-84）转火星坐标（GCJ-02）
 @param coordinate GPS坐标（WGS-84）
 @return 火星坐标（GCJ-02）
 */
+ (CLLocationCoordinate2D)at_marsCoordinateFromGPSCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 火星坐标（GCJ-02）转GPS坐标（WGS-84）
 @param coordinate 火星坐标（GCJ-02）
 @return GPS坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)at_gpsCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 GPS坐标（WGS-84）转百度坐标（BD-09）
 @param coordinate GPS坐标（WGS-84）
 @return 百度坐标（BD-09）
 */
+ (CLLocationCoordinate2D)at_bdCoordinateFromGPSCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 百度坐标（BD-09）转GPS坐标（WGS-84）
 @param coordinate 百度坐标（BD-09）
 @return GPS坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)at_gpsCoordinateFromBDCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 火星坐标（GCJ-02）转百度坐标（BD-09）
 @param coordinate 火星坐标（GCJ-02）
 @return 百度坐标（BD-09）
 */
+ (CLLocationCoordinate2D)at_bdCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 百度坐标（BD-09）转火星坐标（GCJ-02）
 @param coordinate 百度坐标（BD-09）
 @return 火星坐标（GCJ-02）
 */
+ (CLLocationCoordinate2D)at_marsCoordinateFromBDCoordinate:(CLLocationCoordinate2D)coordinate;


@end
