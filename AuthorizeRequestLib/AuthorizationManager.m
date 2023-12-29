//
//  AuthorizationManager.m
//  AuthorizationManager<https://github.com/123sunxiaolin/AuthorizationManager.git>
//
//  <Wechat Public:iOSDevSkills>
//  Created by Jacklin on 2017/3/27.
//  Copyright © 2017年 com.jack.lin. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "AuthorizationManager.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreTelephony/CTCellularData.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
//@import UIKit;
//@import Photos;
//@import AssetsLibrary;
//@import CoreTelephony;
//@import AVFoundation;
//@import CoreLocation;
//@import UserNotifications;
////@import AddressBook;
////@import Contacts;
////@import EventKit;
////@import MediaPlayer;
////@import Speech;//Xcode 8.0 or later
////@import HealthKit;
////@import Intents;
////@import CoreBluetooth;
////@import Accounts;

//@interface AuthorizationHealthManager : NSObject
//
//- (void)requestHealthAuthorizationWithShareTypes:(nullable NSSet<HKSampleType *> *)typesToShare
//                                          readTypes:(nullable NSSet<HKObjectType *> *)typesToRead
//                                  authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler;
//@end

//@implementation AuthorizationHealthManager
//
//- (void)requestHealthAuthorizationWithShareTypes:(nullable NSSet<HKSampleType *> *)typesToShare
//                                          readTypes:(nullable NSSet<HKObjectType *> *)typesToRead
//                                  authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//
//    BOOL isSupportHealthKit = [HKHealthStore isHealthDataAvailable];
//    NSAssert(isSupportHealthKit, @"Notice it is not support HealthKit!");
//
//    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
//   __block BOOL shouldRequestAccess = NO;
//    if (typesToShare.count > 0) {
//
//        [typesToShare enumerateObjectsUsingBlock:^(HKObjectType * _Nonnull type, BOOL * _Nonnull stop) {
//            HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:type];
//            if (authStatus == HKAuthorizationStatusNotDetermined) {
//                shouldRequestAccess = YES;
//                *stop = YES;
//            }
//        }];
//
//    }else{
//        if (typesToRead.count > 0) {
//
//            [typesToRead enumerateObjectsUsingBlock:^(HKObjectType * _Nonnull type, BOOL * _Nonnull stop) {
//                HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:type];
//                if (authStatus == HKAuthorizationStatusNotDetermined) {
//                    shouldRequestAccess = YES;
//                    *stop = YES;
//                }
//            }];
//
//
//        }else{
//            NSAssert(typesToRead.count > 0, @"待请求的权限类型数组不能为空");
//        }
//    }
//
//    if (shouldRequestAccess) {
//        [healthStore requestAuthorizationToShareTypes:typesToShare readTypes:typesToRead completion:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    authorizedHandler ? authorizedHandler() : nil;
//                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                });
//            }
//        }];
//    }else{
//       __block BOOL isAuthorized = NO;
//        if (typesToShare.count > 0) {
//            [typesToShare enumerateObjectsUsingBlock:^(HKSampleType * _Nonnull type, BOOL * _Nonnull stop) {
//                HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:type];
//                if (authStatus == HKAuthorizationStatusNotDetermined
//                    || authStatus == HKAuthorizationStatusSharingDenied) {
//                    isAuthorized = NO;
//                }else{
//                    isAuthorized = YES;
//                }
//            }];
//        }else{
//            if (typesToRead.count > 0) {
//
//                [typesToRead enumerateObjectsUsingBlock:^(HKObjectType * _Nonnull type, BOOL * _Nonnull stop) {
//                    HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:type];
//                    if (authStatus == HKAuthorizationStatusNotDetermined
//                        || authStatus == HKAuthorizationStatusSharingDenied) {
//                        isAuthorized = NO;
//                    }else{
//                        isAuthorized = YES;
//                    }
//                }];
//
//            }else{
//                NSAssert(typesToRead.count > 0, @"待请求的权限类型数组不能为空");
//            }
//        }
//
//        if (isAuthorized) {
//            authorizedHandler ? authorizedHandler() : nil;
//        }else{
//            unAuthorizedHandler ? unAuthorizedHandler() : nil;
//        }
//
//    }
//
//}
//@end

static NSString *const PushNotificationAuthorizationKey = @"PushNotificationAuthorizationKey";
static NSString *const RequestNotificationsKey = @"_requestedNotifications";

@interface AuthorizationManager ()<CLLocationManagerDelegate>

@property (nonatomic, copy) GeneralAuthorizationCompletion mapAlwaysAuthorizedHandler;
@property (nonatomic, copy) GeneralAuthorizationCompletion mapAlwaysUnAuthorizedHandler;
@property (nonatomic, copy) GeneralAuthorizationCompletion mapWhenInUseAuthorizedHandler;
@property (nonatomic, copy) GeneralAuthorizationCompletion mapWhenInUseUnAuthorizedHandler;

/**
 地理位置管理对象
 */
@property (nonatomic, strong) CLLocationManager *locationManager;
//@property (nonatomic, strong) ACAccountStore *accounStore;
@property (nonatomic, assign) BOOL isRequestMapAlways;

@end

@implementation AuthorizationManager

+ (AuthorizationManager *)defaultManager{
    static AuthorizationManager *authorizationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authorizationManager = [[AuthorizationManager alloc] init];
    });
    return authorizationManager;
}

- (instancetype)init{
    if (self = [super init]) {
        _isRequestMapAlways = NO;
    }
    return self;
}

//- (ACAccountStore *)accounStore{
//    if (!_accounStore) {
//        _accounStore = [[ACAccountStore alloc] init];
//    }
//    return _accounStore;
//}

- (void)requestAuthorizationWithAuthorizationType:(AuthorizationType)authorizationType
                                   authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                 unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    switch (authorizationType) {
        case AuthorizationTypePhotoLibrary:
            [self p_requestPhotoLibraryAccessWithAuthorizedHandler:authorizedHandler
                                               unAuthorizedHandler:unAuthorizedHandler];
            break;
            
        case AuthorizationTypeCellularNetWork:
            [self p_requestNetworkAccessWithAuthorizedHandler:authorizedHandler
                                          unAuthorizedHandler:unAuthorizedHandler];
            break;
        
        case AuthorizationTypeCamera:
            [self p_requestCameraAccessWithAuthorizedHandler:authorizedHandler
                                         unAuthorizedHandler:unAuthorizedHandler];
            break;
            
//        case AuthorizationTypeMicrophone:
//            [self p_requestAudioAccessWithAuthorizedHandler:authorizedHandler
//                                        unAuthorizedHandler:unAuthorizedHandler];
//            break;
//        case AuthorizationTypeAddressBook:
//            [self p_requestAddressBookAccessWithAuthorizedHandler:authorizedHandler
//                                        unAuthorizedHandler:unAuthorizedHandler];
//            break;
//        case AuthorizationTypeCalendar:
//            [self p_requestCalendarAccessWithAuthorizedHandler:authorizedHandler
//                                           unAuthorizedHandler:unAuthorizedHandler];
//            break;
//        case AuthorizationTypeReminder:
//            [self p_requestReminderAccessWithAuthorizedHandler:authorizedHandler
//                                           unAuthorizedHandler:unAuthorizedHandler];
//            break;
        case AuthorizationTypeNotification:
            [self p_requestNotificationAccessWithAuthorizedHandler:authorizedHandler
                                               unAuthorizedHandler:unAuthorizedHandler];
            break;
        case AuthorizationTypeMapAlways:
            [self p_requestMapAlwaysAccessWithAuthorizedHandler:authorizedHandler
                                            unAuthorizedHandler:unAuthorizedHandler];
            break;
        case AuthorizationTypeMapWhenInUse:
            [self p_requestMapWhenInUseAccessWithAuthorizedHandler:authorizedHandler
                                               unAuthorizedHandler:unAuthorizedHandler];
            break;
        case AuthorizationTypeMapWhenInUseOrMapAlways:
            [self p_requestMapAlwaysAccessOrWhenInUseAccessWithAuthorizedHandler:authorizedHandler unAuthorizedHandler:unAuthorizedHandler];
            break;
            
            
            
//        case AuthorizationTypeAppleMusic:
//            [self p_requestAppleMusicAccessWithAuthorizedHandler:authorizedHandler
//                                             unAuthorizedHandler:unAuthorizedHandler];
//            break;
//        case AuthorizationTypeSpeechRecognizer:
//            [self p_requestSpeechRecognizerAccessWithAuthorizedHandler:authorizedHandler
//                                                   unAuthorizedHandler:unAuthorizedHandler];
//            break;
//        case AuthorizationTypeSiri:
//            [self p_requestSiriAccessWithAuthorizedHandler:authorizedHandler
//                                       unAuthorizedHandler:unAuthorizedHandler];
//            break;
//        case AuthorizationTypeBluetooth:
//            [self p_requestBluetoothAccessWithAuthorizedHandler:authorizedHandler
//                                            unAuthorizedHandler:unAuthorizedHandler];
//            break;
            
        default:
            NSAssert(!1, @"该方法暂不提供");
            
            break;
    }
}

//- (void)requestHealthAuthorizationWithShareTypes:(NSSet*)typesToShare
//                                          readTypes:(NSSet*)typesToRead
//                                  authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//
//    AuthorizationHealthManager *healthManager = [AuthorizationHealthManager new];
//    [healthManager _requestHealthAuthorizationWithShareTypes:typesToShare
//                                                     readTypes:typesToRead
//                                             authorizedHandler:authorizedHandler
//                                           unAuthorizedHandler:unAuthorizedHandler];
//
//
//}

//- (void)_requestAccountAuthorizationWithAuthorizationType:(AuthorizationType)authorizationType
//                                                    options:(NSDictionary *)options
//                                          authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                        unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler
//                                               errorHandler:(void(^)(NSError *error))errorHandler{
//    switch (authorizationType) {
//        case AuthorizationTypeTwitter:
//            [self p_requestAccountWithaccountTypeIndentifier:ACAccountTypeIdentifierTwitter
//                                                     options:options
//                                           authorizedHandler:authorizedHandler
//                                         unAuthorizedHandler:unAuthorizedHandler
//                                                errorHandler:errorHandler];
//            break;
//        case AuthorizationTypeFacebook:
//            [self p_requestAccountWithaccountTypeIndentifier:ACAccountTypeIdentifierFacebook
//                                                     options:options
//                                           authorizedHandler:authorizedHandler
//                                         unAuthorizedHandler:unAuthorizedHandler
//                                                errorHandler:errorHandler];
//            break;
//        case AuthorizationTypeSinaWeibo:
//            [self p_requestAccountWithaccountTypeIndentifier:ACAccountTypeIdentifierSinaWeibo
//                                                     options:options
//                                           authorizedHandler:authorizedHandler
//                                         unAuthorizedHandler:unAuthorizedHandler
//                                                errorHandler:errorHandler];
//            break;
//        case AuthorizationTypeTencentWeibo:
//            [self p_requestAccountWithaccountTypeIndentifier:ACAccountTypeIdentifierTencentWeibo
//                                                     options:options
//                                           authorizedHandler:authorizedHandler
//                                         unAuthorizedHandler:unAuthorizedHandler
//                                                errorHandler:errorHandler];
//            break;
//
//        default:
//            break;
//    }
//}

#pragma mark - Photo Library
- (void)p_requestPhotoLibraryAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                     unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    if (@available(iOS 8.0, *)) {
        //used `PHPhotoLibrary`
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authorizedHandler ? authorizedHandler(): nil;
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        unAuthorizedHandler ? unAuthorizedHandler(): nil;
                    });
                }
            }];
        }else if (authStatus == PHAuthorizationStatusAuthorized){
            authorizedHandler ? authorizedHandler(): nil;
        }else{
            unAuthorizedHandler ? unAuthorizedHandler(): nil;
        }
        
    }else{
        //used `AssetsLibrary`
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusAuthorized) {
            authorizedHandler ? authorizedHandler() : nil;
        }else{
            unAuthorizedHandler ? unAuthorizedHandler() : nil;
        }
#pragma clang diagnostic pop
    }
}

#pragma mark - Network
- (void)p_requestNetworkAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    
    if (@available(iOS 9.0, *)) {
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        CTCellularDataRestrictedState authState = cellularData.restrictedState;
        if (authState == kCTCellularDataRestrictedStateUnknown) {
            cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
                if (state == kCTCellularDataNotRestricted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authorizedHandler ? authorizedHandler() : nil;
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
                    });
                }
            };
        }else if (authState == kCTCellularDataNotRestricted){
            authorizedHandler ? authorizedHandler() : nil;
        }else{
            unAuthorizedHandler ? unAuthorizedHandler() : nil;
        }
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - AvcaptureMedia
- (void)p_requestCameraAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                               unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorizedHandler ? authorizedHandler() : nil;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    unAuthorizedHandler ? unAuthorizedHandler() : nil;
                });
            }
        }];
        
    }else if(authStatus == AVAuthorizationStatusAuthorized){
        authorizedHandler ? authorizedHandler() : nil;
    }else{
        unAuthorizedHandler ? unAuthorizedHandler() : nil;
    }
}

- (void)p_requestAudioAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                              unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorizedHandler ? authorizedHandler() : nil;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    unAuthorizedHandler ? unAuthorizedHandler() : nil;
                });
            }
        }];
        
    }else if(authStatus == AVAuthorizationStatusAuthorized){
        authorizedHandler ? authorizedHandler() : nil;
    }else{
        unAuthorizedHandler ? unAuthorizedHandler() : nil;
    }
}

//#pragma mark - AddressBook
//- (void)p_requestAddressBookAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                              unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//    if (@available(iOS 9.0, *)) {
//        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//        if (authStatus == CNAuthorizationStatusNotDetermined) {
//            CNContactStore *contactStore = [[CNContactStore alloc] init];
//            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                if (granted) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        authorizedHandler ? authorizedHandler() : nil;
//                    });
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                    });
//                }
//            }];
//        }else if (authStatus == CNAuthorizationStatusAuthorized){
//            authorizedHandler ? authorizedHandler() : nil;
//        }else{
//            unAuthorizedHandler ? unAuthorizedHandler() : nil;
//        }
//    } else {
//        //iOS9.0 eariler
//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//
//        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
//        if (authStatus == kABAuthorizationStatusNotDetermined) {
//            ABAddressBookRef addressBook = ABAddressBookCreate();
//            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
//                if (granted) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        authorizedHandler ? authorizedHandler() : nil;
//                    });
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                    });
//                }
//            });
//
//            if (addressBook) {
//                CFRelease(addressBook);
//            }
//
//        }else if (authStatus == kABAuthorizationStatusAuthorized){
//            authorizedHandler ? authorizedHandler() : nil;
//        }else{
//            unAuthorizedHandler ? unAuthorizedHandler() : nil;
//        }
//#pragma clang diagnostic pop
//
//    }
//}

#pragma mark - Calendar
//- (void)p_requestCalendarAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                 unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//
//    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
//    if (authStatus == EKAuthorizationStatusNotDetermined) {
//        EKEventStore *eventStore = [[EKEventStore alloc] init];
//        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//            if (granted) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    authorizedHandler ? authorizedHandler() : nil;
//                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                });
//            }
//        }];
//    }else if (authStatus == EKAuthorizationStatusAuthorized){
//        authorizedHandler ? authorizedHandler() : nil;
//    }else{
//        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//    }
//}

#pragma mark - Reminder
//- (void)p_requestReminderAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                 unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
//    if (authStatus == EKAuthorizationStatusNotDetermined) {
//        EKEventStore *eventStore = [[EKEventStore alloc] init];
//        [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
//            if (granted) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    authorizedHandler ? authorizedHandler() : nil;
//                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                });
//            }
//        }];
//    }else if (authStatus == EKAuthorizationStatusAuthorized){
//        authorizedHandler ? authorizedHandler() : nil;
//    }else{
//        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//    }
//}

#pragma mark - Notifacations

- (void)p_authorizedStatusForPushNotificationsWithCompletion:(void (^)(AuthorizationStatus status))completion {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunguarded-availability"//-Wdeprecated-declarations"
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        
        AuthorizationStatus status = AuthorizationStatusNotDetermined;
        switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                status = AuthorizationStatusNotDetermined;
                break;
                
                case UNAuthorizationStatusDenied:
                status = AuthorizationStatusUnAuthorized;
                break;
                
                case UNAuthorizationStatusAuthorized:
                case UNAuthorizationStatusProvisional:
                status = AuthorizationStatusAuthorized;
                break;
                
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(status);
            }
        });
        
    }];
    #pragma clang diagnostic pop
}

- (AuthorizationStatus)p_authorizedStatusForPushNotifications {
    
    BOOL isAuthorized = [[NSUserDefaults standardUserDefaults] boolForKey:PushNotificationAuthorizationKey];
    if (!isAuthorized) {
        return AuthorizationStatusUnAuthorized;
    }
    
    if (@available(ios 8.0, *)) {
        
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            return AuthorizationStatusAuthorized;
        } else {
            return AuthorizationStatusUnAuthorized;
        }
        
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
            return AuthorizationStatusUnAuthorized;
        } else {
            return AuthorizationStatusAuthorized;
        }
#pragma clang diagnostic pop
    }
}

- (void)p_requestNotificationAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                     unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler {

    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    if (authorizedHandler) {
                        authorizedHandler();
                    }
                } else {
                    if (unAuthorizedHandler) {
                        unAuthorizedHandler();
                    }
                }
            });
        }];
    } else if (@available(iOS 8.0, *)) {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType type = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
#pragma clang diagnostic pop
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
}

#pragma mark - Map

- (void)p_requestMapAlwaysAccessOrWhenInUseAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                  unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    if (![CLLocationManager locationServicesEnabled]) {
        NSAssert([CLLocationManager locationServicesEnabled], @"Location service enabled failed");
        return;
    }
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (authStatus == kCLAuthorizationStatusNotDetermined) {
        
        self.mapAlwaysAuthorizedHandler = authorizedHandler;
        //新增
//        self.mapWhenInUseAuthorizedHandler = authorizedHandler;
//        self.mapAlwaysUnAuthorizedHandler = unAuthorizedHandler;
//        self.mapWhenInUseUnAuthorizedHandler = unAuthorizedHandler;

        [self.locationManager requestWhenInUseAuthorization];
        self.isRequestMapAlways = YES;
        
    }else if (authStatus == kCLAuthorizationStatusAuthorizedAlways){
        authorizedHandler ? authorizedHandler() : nil;
    }else if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        authorizedHandler ? authorizedHandler() : nil;
    }else{
        unAuthorizedHandler ? unAuthorizedHandler() : nil;
    }
}

- (void)p_requestMapAlwaysAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                  unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    if (![CLLocationManager locationServicesEnabled]) {
        NSAssert([CLLocationManager locationServicesEnabled], @"Location service enabled failed");
        return;
    }
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (authStatus == kCLAuthorizationStatusNotDetermined) {
        
        self.mapAlwaysAuthorizedHandler = authorizedHandler;
        self.mapAlwaysUnAuthorizedHandler = unAuthorizedHandler;
        [self.locationManager requestAlwaysAuthorization];
        self.isRequestMapAlways = YES;
        
    }else if (authStatus == kCLAuthorizationStatusAuthorizedAlways){
        authorizedHandler ? authorizedHandler() : nil;
    }else{
        unAuthorizedHandler ? unAuthorizedHandler() : nil;
    }
}

- (void)p_requestMapWhenInUseAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
                                     unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
    if (![CLLocationManager locationServicesEnabled]) {
        NSAssert([CLLocationManager locationServicesEnabled], @"Location service enabled failed");
        return;
    }
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (authStatus == kCLAuthorizationStatusNotDetermined) {
        
        self.mapWhenInUseAuthorizedHandler = authorizedHandler;
        self.mapAlwaysUnAuthorizedHandler = unAuthorizedHandler;
        [self.locationManager requestWhenInUseAuthorization];
        self.isRequestMapAlways = NO;
        
    }else if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        authorizedHandler ? authorizedHandler() : nil;
    }else{
        unAuthorizedHandler ? unAuthorizedHandler() : nil;
    }
}
#pragma mark - Apple Music
//- (void)p_requestAppleMusicAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                   unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//    if (@available(iOS 9.3, *)) {
//        MPMediaLibraryAuthorizationStatus authStatus = [MPMediaLibrary authorizationStatus];
//        if (authStatus == MPMediaLibraryAuthorizationStatusNotDetermined) {
//            [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
//                if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        authorizedHandler ? authorizedHandler() : nil;
//                    });
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                    });
//                }
//            }];
//        }else if (authStatus == MPMediaLibraryAuthorizationStatusAuthorized){
//            authorizedHandler ? authorizedHandler() : nil;
//        }else{
//            unAuthorizedHandler ? unAuthorizedHandler() : nil;
//        }
//    } else {
//        // Fallback on earlier versions
//    }
//}

#pragma mark - SpeechRecognizer
//- (void)p_requestSpeechRecognizerAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                         unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//    if (@available(iOS 10.0, *)) {
//        SFSpeechRecognizerAuthorizationStatus authStatus = [SFSpeechRecognizer authorizationStatus];
//        if (authStatus == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
//            [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
//                if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        authorizedHandler ? authorizedHandler() : nil;
//                    });
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                    });
//                }
//            }];
//
//        }else if (authStatus == SFSpeechRecognizerAuthorizationStatusAuthorized){
//            authorizedHandler ? authorizedHandler() : nil;
//        }else{
//            unAuthorizedHandler ? unAuthorizedHandler() : nil;
//        }
//    } else {
//        // Fallback on earlier versions
//    }
//}

#pragma mark - Health
//- (void)p_requestHealthAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                               unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//}
#pragma mark - Siri
//- (void)p_requestSiriAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                             unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//
//    if (@available(iOS 10.0, *)) {
//        INSiriAuthorizationStatus authStatus = [INPreferences siriAuthorizationStatus];
//        if (authStatus == INSiriAuthorizationStatusNotDetermined) {
//            [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
//                if (status == INSiriAuthorizationStatusAuthorized) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        authorizedHandler ? authorizedHandler() : nil;
//                    });
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                    });
//                }
//            }];
//
//        }else if (authStatus == INSiriAuthorizationStatusAuthorized){
//            authorizedHandler ? authorizedHandler() : nil;
//        }else{
//            unAuthorizedHandler ? unAuthorizedHandler() : nil;
//        }
//    } else {
//        printf("This method must used in iOS 10.0 or later/该方法必须在iOS10.0或以上版本使用!");
//        authorizedHandler = nil;
//        unAuthorizedHandler = nil;
//        return;
//    }
//
//}

#pragma mark - Bluetooth
//- (void)p_requestBluetoothAccessWithAuthorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                                  unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler{
//    CBPeripheralManagerAuthorizationStatus authStatus = [CBPeripheralManager authorizationStatus];
//    if (authStatus == CBPeripheralManagerAuthorizationStatusNotDetermined) {
//
//        CBCentralManager *cbManager = [[CBCentralManager alloc] init];
//        [cbManager scanForPeripheralsWithServices:nil
//                                          options:nil];
//
//    }else if (authStatus == CBPeripheralManagerAuthorizationStatusAuthorized) {
//        authorizedHandler ? authorizedHandler() : nil;
//    }else{
//        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//    }
//}

#pragma mark - Account
//- (void)p_requestAccountWithaccountTypeIndentifier:(NSString *)typeIndentifier
//                                           options:(NSDictionary *)options
//                                 authorizedHandler:(GeneralAuthorizationCompletion)authorizedHandler
//                               unAuthorizedHandler:(GeneralAuthorizationCompletion)unAuthorizedHandler
//                                      errorHandler:(void(^)(NSError *error))errorHandler{
//
//    ACAccountType *accountType = [self.accounStore accountTypeWithAccountTypeIdentifier:typeIndentifier];
//    if ([accountType accessGranted]) {
//        authorizedHandler ? authorizedHandler() : nil;
//    }else{
//        if ([typeIndentifier isEqualToString:ACAccountTypeIdentifierFacebook]
//            || [typeIndentifier isEqualToString:ACAccountTypeIdentifierTencentWeibo]) {
//            NSAssert(options, @"Option can't be nil!");
//        }
//        [self.accounStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (granted) {
//                    authorizedHandler ? authorizedHandler() : nil;
//                }else{
//                    if (error) {
//                        errorHandler ? errorHandler(error) : nil;
//                    }else{
//                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
//                    }
//                }
//            });
//        }];
//    }
//
//}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        self.mapAlwaysAuthorizedHandler ? self.mapAlwaysAuthorizedHandler() : nil;
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
        self.mapWhenInUseAuthorizedHandler ? self.mapWhenInUseAuthorizedHandler() : nil;
    }else{
        if (self.isRequestMapAlways) {
            self.mapAlwaysUnAuthorizedHandler ? self.mapAlwaysUnAuthorizedHandler() : nil;
        }else{
             self.mapWhenInUseUnAuthorizedHandler ? self.mapWhenInUseUnAuthorizedHandler() : nil;
        }
    }
}

@end
