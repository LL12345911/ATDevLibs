//
//  PhotosPermission.m
//  AuthorizationDemo
//
//  Created by Jacklin on 2019/1/24.
//  Copyright © 2019年 com.jack.lin. All rights reserved.
//

//@import Photos;
//@import AssetsLibrary;
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotosPermission.h"

@implementation PhotosPermission

- (AuthorizationType)type {
    return AuthorizationTypePhotoLibrary;
}

- (AuthorizationStatus)authorizationStatus {
    PHAuthorizationStatus authStatus;
    if (@available(iOS 14, *)) {
        authStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }else{
        authStatus = [PHPhotoLibrary authorizationStatus];
    }
    switch (authStatus) {
        case PHAuthorizationStatusAuthorized:
            return AuthorizationStatusAuthorized;
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            return AuthorizationStatusUnAuthorized;
            break;
        case PHAuthorizationStatusNotDetermined:
            return AuthorizationStatusNotDetermined;
            break;
        default:
            return AuthorizationStatusDisabled;
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
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self safeAsyncWithCompletion:^{
                if (completion) {
                    completion(status == PHAuthorizationStatusAuthorized);
                }
            }];
        }];
    } else {
        if (completion) {
            completion(status == AuthorizationStatusAuthorized);
        }
    }
}

@end
