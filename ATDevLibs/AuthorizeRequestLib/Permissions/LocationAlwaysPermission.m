//
//  LocationAlwaysPermission.m
//  AuthorizationManager
//
//  Created by Jacklin on 2019/1/27.
//

//@import CoreLocation;
#import <CoreLocation/CoreLocation.h>
#import "LocationAlwaysPermission.h"

@interface LocationAlwaysPermission()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) AuthorizationCompletion completion;

@end

@implementation LocationAlwaysPermission

+ (instancetype)instance {
    NSAssert(NO, @"please use 'sharedInstance' singleton method!");
    return nil;
}

+ (instancetype)sharedInstance {
    static LocationAlwaysPermission *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationAlwaysPermission alloc] init];
    });
    return instance;
}

- (AuthorizationType)type {
    return AuthorizationTypeMapAlways;
}

- (AuthorizationStatus)authorizationStatus {
    
    if (![CLLocationManager locationServicesEnabled]) {
        return  AuthorizationStatusDisabled;
    }
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            return AuthorizationStatusAuthorized;
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            // InUse to Always upgrade case
            BOOL isAlwaysFormInUse = [NSUserDefaults.standardUserDefaults boolForKey:AuthorizationRequestedInUseToAlwaysUpgradeKey];
            if (isAlwaysFormInUse) {
                return AuthorizationStatusAuthorized;
            }
            return AuthorizationStatusNotDetermined;
        }
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
        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [NSUserDefaults.standardUserDefaults setBool:YES
                                                  forKey:AuthorizationRequestedInUseToAlwaysUpgradeKey];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
        }
        [self.locationManager requestAlwaysAuthorization];
        
    } else {
        if (completion) {
            completion(status == AuthorizationStatusAuthorized);
        }
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (self.completion) {
        self.completion(status == kCLAuthorizationStatusAuthorizedAlways);
    }
}
@end
