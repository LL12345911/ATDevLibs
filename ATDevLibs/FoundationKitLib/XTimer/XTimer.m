//
//  XTimer.m
//  ProjectManager
//
//  Created by Mars on 2019/4/9.
//  Copyright © 2019 qingpugonglusuo. All rights reserved.
//

#import "XTimer.h"

@interface XTimer()

@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, assign) BOOL yesOrNo;

@end


@implementation XTimer


- (id)init{
    self = [super init];
    _isValid = YES;
    _yesOrNo = YES;
    
    return self;
}
+ (nullable XTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(nullable id)aTarget selector:(nullable SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    XTimer *timer = [[XTimer alloc]init];
    timer.ti = ti;
    timer.atarget = aTarget;
    timer.aSelector = aSelector;
    timer.userInfo = userInfo;
    
    if (yesOrNo) {
        [timer repeatSelector];
    }else{
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ti * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [aTarget performSelectorOnMainThread:aSelector withObject:userInfo waitUntilDone:NO];
        });
    }
    return timer;
}

-(void)repeatSelector{
    
    __block typeof(self) weakSelf = self;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.ti * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (weakSelf.yesOrNo) {
            [self.atarget performSelectorOnMainThread:self.aSelector withObject:self.userInfo waitUntilDone:NO];
        }
        if (weakSelf.isValid) {
            [self repeatSelector];
        }
    });
    
}
- (void)reStart{
    _yesOrNo = YES;
}
- (void)stop{
    _yesOrNo = NO;
}
- (void)invalidate{
    _isValid = NO;
}


@end
