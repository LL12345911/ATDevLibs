//
//  CameraPermission.m
//  AuthorizationDemo
//
//  Created by Jacklin on 2019/1/24.
//  Copyright © 2019年 com.jack.lin. All rights reserved.
//

//@import AVFoundation;
#import <AVFoundation/AVFoundation.h>
#import "CameraPermission.h"

@implementation CameraPermission

- (AuthorizationType)type {
    return AuthorizationTypeCamera;
}

- (AuthorizationStatus)authorizationStatus {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            return AuthorizationStatusAuthorized;
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            return AuthorizationStatusUnAuthorized;
            break;
        case AVAuthorizationStatusNotDetermined:
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
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self safeAsyncWithCompletion:^{
                if (completion) {
                    completion(granted);
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
