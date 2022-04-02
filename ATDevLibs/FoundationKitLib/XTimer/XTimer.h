//
//  XTimer.h
//  ProjectManager
//
//  Created by Mars on 2019/4/9.
//  Copyright © 2019 qingpugonglusuo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTimer : NSObject

@property  NSTimeInterval ti;
@property (nullable,weak) id atarget;
@property (nullable,nonatomic, assign) SEL aSelector;
@property (nullable, retain) id userInfo;


+ (nullable XTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(nullable id)aTarget selector:(nullable SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;



- (void)reStart;
- (void)stop;
- (void)invalidate;


@end

NS_ASSUME_NONNULL_END
