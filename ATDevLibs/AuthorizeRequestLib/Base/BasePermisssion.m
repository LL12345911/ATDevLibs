//
//  BasePermisssion.m
//  AuthorizationDemo
//
//  Created by Jacklin on 2019/1/24.
//  Copyright © 2019年 com.jack.lin. All rights reserved.
//

#import "BasePermisssion.h"

@implementation BasePermisssion
@synthesize type;

+ (instancetype)instance {
    return [[self alloc] init];
}

- (void)safeAsyncWithCompletion:(dispatch_block_t)completion {
    if (NSThread.isMainThread) {
        if (completion) {
            completion();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }
}

- (AuthorizationStatus)authorizationStatus {
    return AuthorizationStatusNotDetermined;
}

- (BOOL)hasSpecificPermissionKeyFromInfoPlist {
    return YES;
}

- (void)requestAuthorizationWithCompletion:(nonnull AuthorizationCompletion)completion {}

- (NSString *)permissionDescriptionKey {
    switch (self.type) {
        case AuthorizationTypePhotoLibrary:
            return AuthorizationInfoPlistKeyPhotoLibrary;
            break;
        case AuthorizationTypeCamera:
            return AuthorizationInfoPlistKeyCamera;
            break;
        case AuthorizationTypeMicrophone:
            return AuthorizationInfoPlistKeyMicrophone;
            break;
        case AuthorizationTypeAddressBook:
            return AuthorizationInfoPlistKeyContact;
            break;
        case AuthorizationTypeCalendar:
            return AuthorizationInfoPlistKeyCalendar;
            break;
        case AuthorizationTypeReminder:
            return AuthorizationInfoPlistKeyReminder;
            break;
        case AuthorizationTypeMapWhenInUse:
            return AuthorizationInfoPlistKeyLocationWhenInUse;
            break;
        case AuthorizationTypeMapAlways:
            return AuthorizationInfoPlistKeyLocationAlways;
            break;
        case AuthorizationTypeAppleMusic:
            return AuthorizationInfoPlistKeyAppleMusic;
            break;
        case AuthorizationTypeSpeechRecognizer:
            return AuthorizationInfoPlistKeySpeechRecognizer;
            break;
        case AuthorizationTypeMotion:
            return AuthorizationInfoPlistKeyMotion;
            break;
        case AuthorizationTypeHealth:// only return healthShareType
            return AuthorizationInfoPlistKeyHealthShare;
            break;
            
        default:
            return @" ";
            break;
    }
}

@end
