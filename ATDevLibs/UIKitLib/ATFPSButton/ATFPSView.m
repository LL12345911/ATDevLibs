//
//  OttoFPSButton.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/5.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "ATFPSView.h"
#import <mach/mach.h>
#import "WindowsManager.h"

@interface ATFPSView ()

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSUInteger     count;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) UILabel *memoryLabel;
@property (nonatomic, strong) UILabel *cpuLabel;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIView *line2;


@end


@implementation ATFPSView

+ (instancetype)sharedInstance {
    static ATFPSView *config = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        config = [[ATFPSView alloc]init];
    });
    return config;
}
+ (void)show{
    [[WindowsManager keyWindow] addSubview:[ATFPSView sharedInstance]];
}

+ (void)hide{
    [[ATFPSView sharedInstance].link invalidate];
    [[ATFPSView sharedInstance] removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame{
    frame = CGRectMake(0, 300, 100, 60);
    
    NSLog(@"=++++++++==");
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
        [self createView];
        //添加拖拽手势-改变控件的位置
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
        [self addGestureRecognizer:pan];
        
        __weak typeof(self) weakSelf = self;
        _link = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _fpsLabel.frame = CGRectMake(15, 0, 70, 20);
    _memoryLabel.frame = CGRectMake(15, 20, 70, 20);
    _cpuLabel.frame = CGRectMake(15, 40, 70, 20);
    _line.frame = CGRectMake(30, 19.7, 40, 0.5);
    _line2.frame = CGRectMake(30, 39.7, 40, 0.5);
//    NSParameterAssert(<#condition#>)
}

- (void)createView{
    
    NSLog(@"====================");
    _fpsLabel = [[UILabel alloc] init];
    _fpsLabel.textAlignment = NSTextAlignmentCenter;
    _fpsLabel.textColor = [UIColor whiteColor];
    _fpsLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:_fpsLabel];
    
    _memoryLabel = [[UILabel alloc] init];
    _memoryLabel.textAlignment = NSTextAlignmentCenter;
    _memoryLabel.textColor = [UIColor whiteColor];
    _memoryLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:_memoryLabel];
    
    _cpuLabel = [[UILabel alloc] init];
    _cpuLabel.textAlignment = NSTextAlignmentCenter;
    _cpuLabel.textColor = [UIColor whiteColor];
    _cpuLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:_cpuLabel];
    
    _line = [[UIView alloc] init];
    _line.backgroundColor = [UIColor whiteColor];
    [self addSubview:_line];
    
    _line2 = [[UIView alloc] init];
    _line2.backgroundColor = [UIColor whiteColor];
    [self addSubview:_line2];
}



- (void)tick:(CADisplayLink *)link {
    @autoreleasepool {
        if (_lastTime == 0) {
            _lastTime = link.timestamp;
            return;
        }
        _count++;
        NSTimeInterval delta = link.timestamp - _lastTime;
        if (delta < 1) return;
        _lastTime = link.timestamp;
        float fps = _count / delta;
        _count = 0;
        
        int fpss = (int)round(fps);
        _fpsLabel.attributedText = [self getAttributedString:fpss type:1];
        _memoryLabel.attributedText = [self getAttributedString:0 type:2];
        _cpuLabel.attributedText = [self getAttributedString:0 type:3];
    }
}

- (NSMutableAttributedString* )getAttributedString:(int)forstValue type:(int)type{
    @autoreleasepool {
        int fpss;
        UIColor *cpuColor;
        NSString *fpsValue;
        
        UIFont *fontName = [UIFont boldSystemFontOfSize:13];
        NSMutableAttributedString *attText;
        if (type == 1) {
            fpss = (int)round(forstValue);
            cpuColor = [self getColorByPercent:fpss / 100];
            fpsValue = [NSString stringWithFormat:@"%d FPS",fpss];
            attText = [[NSMutableAttributedString alloc] initWithString:fpsValue];
            [attText addAttribute:NSForegroundColorAttributeName value:cpuColor range:NSMakeRange(0, fpsValue.length-3)];
            [attText addAttribute:NSFontAttributeName value:fontName range:NSMakeRange(0, fpsValue.length-3)];
        }else if(type == 2){
            fpss = (int)[self getMemoryValue];
            cpuColor = [self getColorByPercent:fpss / 350];
            fpsValue = [NSString stringWithFormat:@"%d M",fpss];
            attText = [[NSMutableAttributedString alloc] initWithString:fpsValue];
            [attText addAttribute:NSForegroundColorAttributeName value:cpuColor range:NSMakeRange(0, fpsValue.length-1)];
            [attText addAttribute:NSFontAttributeName value:fontName range:NSMakeRange(0, fpsValue.length-1)];
            
        }else{
            fpss = (int)round([self getValue]);
            cpuColor = [self getColorByPercent:fpss / 100];// [UIColor colorWithHue:0.27 * (fpss / 60.0 - 0.2) saturation:1 brightness:0.9 alpha:1];
            fpsValue = [NSString stringWithFormat:@"%d%% CPU",fpss];
            attText = [[NSMutableAttributedString alloc] initWithString:fpsValue];
            [attText addAttribute:NSForegroundColorAttributeName value:cpuColor range:NSMakeRange(0, fpsValue.length-3)];
            [attText addAttribute:NSFontAttributeName value:fontName range:NSMakeRange(0, fpsValue.length-3)];
        }
        return attText;
    }
}





#pragma mark - Color

- (UIColor*)getColorByPercent:(CGFloat)percent {
    NSInteger r = 0, g = 0, one = 255 + 255;
    if (percent < 0.5) {
        r = one * percent;
        g = 255;
    }
    if (percent >= 0.5) {
        g = 255 - ((percent - 0.5 ) * one) ;
        r = 255;
    }
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:0 alpha:1];
}


- (void)changePostion:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:self];
    
    CGRect originalFrame = self.frame;
    
    originalFrame = [self changeXWithFrame:originalFrame point:point];
    originalFrame = [self changeYWithFrame:originalFrame point:point];
    
    self.frame = originalFrame;
    
    [pan setTranslation:CGPointZero inView:self];
    
    UIButton *button = (UIButton *)pan.view;
    if (pan.state == UIGestureRecognizerStateBegan) {
        button.enabled = NO;
    }else if (pan.state == UIGestureRecognizerStateChanged){
    } else {
        
        CGRect frame = self.frame;
        
        if (self.center.x <= [UIScreen mainScreen].bounds.size.width / 2.0){
            frame.origin.x = 0;
        }else{
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width;
        }
        
        if (frame.origin.y < 20) {
            frame.origin.y = 20;
        } else if (frame.origin.y + frame.size.height > [UIScreen mainScreen].bounds.size.height) {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
        }];
        
        button.enabled = YES;
        
    }
}

//拖动改变控件的水平方向x值
- (CGRect)changeXWithFrame:(CGRect)originalFrame point:(CGPoint)point{
    BOOL q1 = originalFrame.origin.x >= 0;
    BOOL q2 = originalFrame.origin.x + originalFrame.size.width <= [UIScreen mainScreen].bounds.size.width;
    
    if (q1 && q2) {
        originalFrame.origin.x += point.x;
    }
    return originalFrame;
}

//拖动改变控件的竖直方向y值
- (CGRect)changeYWithFrame:(CGRect)originalFrame point:(CGPoint)point{
    
    BOOL q1 = originalFrame.origin.y >= 0;//BOOL q1 = originalFrame.origin.y >= 20;
    BOOL q2 = originalFrame.origin.y + originalFrame.size.height <= [UIScreen mainScreen].bounds.size.height;
    if (q1 && q2) {
        originalFrame.origin.y += point.y;
    }
    return originalFrame;
}


//MemoryMonitor
- (float)getMemoryValue {
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (kernReturn != KERN_SUCCESS) { return NSNotFound; }
    memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
    return memoryUsageInByte/1024.0/1024.0;
}


//CpuMonitor
- (float)getValue {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++){
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}



@end
