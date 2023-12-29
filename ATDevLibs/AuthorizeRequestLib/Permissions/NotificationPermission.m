//
//  NotificationPermission.m
//  AuthorizationManager
//
//  Created by Jacklin on 2019/1/24.
//

//@import UserNotifications;
#import <UserNotifications/UserNotifications.h>
#import "NotificationPermission.h"
#import <UIKit/UIKit.h>

@interface NotificationPermission() {
    // temp use
    NSTimer *timer;
}

@property (nonatomic, assign) AuthorizationStatus currentAuthorizedStatus;

/**
 For iOS 10.0 before, user the property to store request notification status
 */
@property (nonatomic, assign) BOOL isRequestNotification;

@property (nonatomic, copy) AuthorizationCompletion authorizationCompletion;


@end

@implementation NotificationPermission

- (instancetype)init {
    if (self = [super init]) {
        self.currentAuthorizedStatus = AuthorizationStatusNotDetermined;
    }
    return self;
}

#pragma mark - AuthorizationNotificationProtocol

- (AuthorizationType)type {
    return AuthorizationTypeNotification;
}

- (AuthorizationStatus)authorizationStatus {
    
    if (@available(iOS 10.0, *)) {
        return self.currentAuthorizedStatus;
    } else {
        UIUserNotificationSettings *settings = UIApplication.sharedApplication.currentUserNotificationSettings;
        if (settings.types != UIUserNotificationTypeNone) {
            return AuthorizationStatusAuthorized;
        } else {
            if (self.isRequestNotification) {
                return AuthorizationStatusUnAuthorized;
            } else {
                return AuthorizationStatusNotDetermined;
            }
        }
    }
}

- (void)asyncFetchAuthorizedStatusWithCompletion:(void (^)(AuthorizationStatus))completion {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            AuthorizationStatus status = AuthorizationStatusNotDetermined;
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusAuthorized:
                    status = AuthorizationStatusAuthorized;
                    break;
                case UNAuthorizationStatusDenied:
                    status = AuthorizationStatusUnAuthorized;
                    break;
                case UNAuthorizationStatusNotDetermined:
                    status = AuthorizationStatusNotDetermined;
                    break;
                default:
                    if (@available(iOS 12.0, *)) {
                        status = AuthorizationStatusAuthorized;
                    } else {
                        status = AuthorizationStatusNotDetermined;
                    }
                    break;
            }
            
            self.currentAuthorizedStatus = status;
            
            [self safeAsyncWithCompletion:^{
                if (completion) {
                    completion(status);
                }
            }];
        }];
        
    } else {
        if (completion) {
            completion(AuthorizationStatusDisabled);
        }
    }
}

- (void)requestAuthorizationWithCompletion:(AuthorizationCompletion)completion {
    
    AuthorizationStatus status = [self authorizationStatus];
    if (status == AuthorizationStatusNotDetermined) {
        if (@available(iOS 10.0, *)) {
            UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
            [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
                [self safeAsyncWithCompletion:^{
                    if (completion) {
                        completion(granted);
                    }
                }];
            }];
        } else {
            self.authorizationCompletion = completion;
            [NSNotificationCenter.defaultCenter addObserver:self
                                                   selector:@selector(requestingNotificationPermission)
                                                       name:UIApplicationWillResignActiveNotification
                                                     object: nil];
            timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(finishedRequestNotificationPermission)
                                                   userInfo:nil
                                                    repeats:NO];
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
            [UIApplication.sharedApplication registerUserNotificationSettings:settings];
        }
        
    } else {
        if (completion) {
            completion(status == AuthorizationStatusAuthorized);
        }
    }
}


#pragma mark - Getters/Setters

- (BOOL)isRequestNotification {
    return [NSUserDefaults.standardUserDefaults boolForKey:AuthorizationRequestedNotificationsKey];
}

- (void)setIsRequestNotification:(BOOL)isRequestNotification {
    [NSUserDefaults.standardUserDefaults setBool:isRequestNotification forKey:AuthorizationRequestedNotificationsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark - Notification
- (void)requestingNotificationPermission {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(finishedRequestNotificationPermission)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)finishedRequestNotificationPermission {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object: nil];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    self.isRequestNotification = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.authorizationCompletion) {
            self.authorizationCompletion(self.currentAuthorizedStatus == AuthorizationStatusAuthorized);
        }
    });
}

@end
