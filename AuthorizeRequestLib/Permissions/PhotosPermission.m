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
    if (@available(iOS 8.0, *)) {
        //used `PHPhotoLibrary`
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
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
        }
        
    }else{
        //used `AssetsLibrary`
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        switch (authStatus) {
            case ALAuthorizationStatusAuthorized:
                return AuthorizationStatusAuthorized;
                break;
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied:
                return AuthorizationStatusUnAuthorized;
                break;
            case ALAuthorizationStatusNotDetermined:
                return AuthorizationStatusNotDetermined;
                break;
            default:
                return AuthorizationStatusDisabled;
                break;
        }
#pragma clang diagnostic pop
    }
    return AuthorizationStatusDisabled;
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
