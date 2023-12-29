//
//  Constant.h
//  AuthorizationManager<https://github.com/123sunxiaolin/AuthorizationManager.git>
//
//  <Wechat Public:iOSDevSkills>
//  Created by Jacklin on 2019/1/17.
//  Copyright © 2019年 com.jack.lin. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#ifndef Constant_h
#define Constant_h

typedef NS_ENUM(NSInteger, AuthorizationType) {
    /**
     *  相册/PhotoLibrary
     */
    AuthorizationTypePhotoLibrary = 0,
    /**
     *  网络/Cellular Network
     */
    AuthorizationTypeCellularNetWork,
    /**
     *  相机/Camera
     */
    AuthorizationTypeCamera,
    /**
     *  麦克风/Microphone
     */
    AuthorizationTypeMicrophone,
    /**
     *  通讯录/AddressBook
     */
    AuthorizationTypeAddressBook,
    /**
     *  日历/Calendar
     */
    AuthorizationTypeCalendar,
    /**
     *  提醒事项/Reminder
     */
    AuthorizationTypeReminder,
    /**
     *  通知/Notification
     */
    AuthorizationTypeNotification,
    /**
     *  一直请求定位权限/AlwaysAuthorization
     */
    AuthorizationTypeMapAlways,
    /**
     *  使用时请求定位权限/WhenInUseAuthorization
     */
    AuthorizationTypeMapWhenInUse,
    /**
        *  使用时请求定位权限/WhenInUseAuthorization 或 AlwaysAuthorization
        */
    AuthorizationTypeMapWhenInUseOrMapAlways,
    
    /**
     *  媒体资料库/AppleMusic
     */
    AuthorizationTypeAppleMusic,
    /**
     *  语音识别/SpeechRecognizer
     */
    AuthorizationTypeSpeechRecognizer,
    /**
     *  Siri(must in iOS10 or later)
     */
    AuthorizationTypeSiri,
    /**
     *  蓝牙共享/Bluetooth
     */
    AuthorizationTypeBluetooth,
    /**
     *  分机蓝牙共享/PeripheralBluetooth
     */
    AuthorizationTypePeripheralBluetooth,
    /**
     *  健康数据/Health
     */
    AuthorizationTypeHealth,
    /**
     *  运动记录/Motion
     */
    AuthorizationTypeMotion,
    /**
     *  推特/Twitter
     */
    AuthorizationTypeTwitter,
    /**
     *  脸书/Facebook
     */
    AuthorizationTypeFacebook,
    /**
     *  新浪微博/SinaWeibo
     */
    AuthorizationTypeSinaWeibo,
    /**
     *  腾讯微博/TencentWeibo
     */
    AuthorizationTypeTencentWeibo,
    
};

/**
 AuthorizedStatus
 */
typedef NS_ENUM(NSInteger, AuthorizationStatus) {
    AuthorizationStatusNotDetermined = 0,
    AuthorizationStatusAuthorized,
    AuthorizationStatusUnAuthorized,
    AuthorizationStatusDisabled,
};

#pragma mark - Constant Key

/**
 Motion
 */
static NSString *const AuthorizationRequestedMotionKey               = @"AT_requestedMotion";

/**
 Notifications
 */
static NSString *const AuthorizationRequestedNotificationsKey        = @"AT_requestedNotifications";

/**
 Bluetooth
 */
static NSString *const AuthorizationRequestedBluetoothKey            = @"AT_requestedBluetooth";

/**
 Map
 */
static NSString *const AuthorizationRequestedInUseToAlwaysUpgradeKey = @"AT_requestedInUseToAlwaysUpgrade";

#pragma mark - App InfoPlist Key
static NSString *const AuthorizationInfoPlistKeyCamera               = @"NSCameraUsageDescription";
static NSString *const AuthorizationInfoPlistKeyMicrophone           = @"NSMicrophoneUsageDescription";
static NSString *const AuthorizationInfoPlistKeyPhotoLibrary         = @"NSPhotoLibraryUsageDescription";
static NSString *const AuthorizationInfoPlistKeyContact              = @"NSContactsUsageDescription";
static NSString *const AuthorizationInfoPlistKeyCalendar             = @"NSCalendarsUsageDescription";
static NSString *const AuthorizationInfoPlistKeyReminder             = @"NSRemindersUsageDescription";
static NSString *const AuthorizationInfoPlistKeyLocationWhenInUse    = @"NSLocationWhenInUseUsageDescription";
static NSString *const AuthorizationInfoPlistKeyLocationAlways       = @"NSLocationAlwaysUsageDescription";
static NSString *const AuthorizationInfoPlistKeyAppleMusic           = @"NSAppleMusicUsageDescription";
static NSString *const AuthorizationInfoPlistKeySpeechRecognizer     = @"NSSpeechRecognitionUsageDescription";
static NSString *const AuthorizationInfoPlistKeyMotion               = @"NSMotionUsageDescription";
static NSString *const AuthorizationInfoPlistKeyHealthUpdate         = @"NSHealthUpdateUsageDescription";
static NSString *const AuthorizationInfoPlistKeyHealthShare          = @"NSHealthShareUsageDescription";

#endif /* Constant_h */
