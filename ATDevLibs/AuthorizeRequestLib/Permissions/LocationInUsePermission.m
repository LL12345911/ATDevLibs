//
//  LocationInUsePermission.m
//  AuthorizationManager
//
//  Created by Jacklin on 2019/1/27.
//

//@import CoreLocation;
#import <CoreLocation/CoreLocation.h>
#import "LocationInUsePermission.h"

@interface LocationInUsePermission()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) AuthorizationCompletion completion;

@end

@implementation LocationInUsePermission

+ (instancetype)instance {
    NSAssert(NO, @"please use 'sharedInstance' singleton method!");
    return nil;
}

+ (instancetype)sharedInstance {
    static LocationInUsePermission *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationInUsePermission alloc] init];
    });
    return instance;
}

- (AuthorizationType)type {
    return AuthorizationTypeMapWhenInUse;
}

- (AuthorizationStatus)authorizationStatus {
    
    if (![CLLocationManager locationServicesEnabled]) {
        return  AuthorizationStatusDisabled;
    }
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            return AuthorizationStatusAuthorized;
            break;
        case  kCLAuthorizationStatusRestricted:
        case  kCLAuthorizationStatusDenied:
            return AuthorizationStatusUnAuthorized;
            break;
        case kCLAuthorizationStatusNotDetermined:
            return AuthorizationStatusNotDetermined;
            break;
    }
}

- (BOOL)hasSpecificPermissionKeyFromInfoPlist {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:self.permissionDescriptionKey];
}

- (void)requestAuthorizationWithCompletion:(AuthorizationCompletion)completion {
    NSString *desc = [NSString stringWithFormat:@"%@ not found in Info.plist.", self.permissionDescriptionKey];
    NSAssert([self hasSpecificPermissionKeyFromInfoPlist], desc);
    
    AuthorizationStatus status = [self authorizationStatus];
    if (status == AuthorizationStatusNotDetermined) {
        self.completion = completion;
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
        }
        [self.locationManager requestWhenInUseAuthorization];
        
    } else {
        if (completion) {
            completion(status == AuthorizationStatusAuthorized);
        }
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (self.completion) {
        self.completion(status == kCLAuthorizationStatusAuthorizedWhenInUse);
    }
}

@end
