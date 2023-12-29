//
//  NotificationPermission.h
//  AuthorizationManager
//
//  Created by Jacklin on 2019/1/24.
//

#import "BasePermisssion.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AuthorizationNotificationProtocol <AuthorizationProtocol>

/**
 *  For iOS 10.0, async fetch notification permission.
 */
- (void)asyncFetchAuthorizedStatusWithCompletion:(void (^)(AuthorizationStatus status))completion;

@end

@interface NotificationPermission : BasePermisssion <AuthorizationNotificationProtocol>

@end

NS_ASSUME_NONNULL_END
