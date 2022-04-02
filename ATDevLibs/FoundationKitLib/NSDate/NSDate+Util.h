//
//  NSDate+Util.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/15.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE    60
#define D_HOUR    3600
#define D_DAY    86400
#define D_WEEK    604800
#define D_YEAR    31556926

//NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Util)

+ (NSCalendar *)currentCalendar; // avoid bottlenecks
#pragma mark ---- Decomposing dates 分解的日期
@property (readonly) NSUInteger nearestHour;
@property (readonly) NSUInteger hour;
@property (readonly) NSUInteger minute;
@property (readonly) NSUInteger seconds;
@property (readonly) NSUInteger day;
@property (readonly) NSUInteger month;
@property (readonly) NSUInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSUInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSUInteger year;

#pragma mark ----short time 格式化的时间
@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;

///使用dateStyle timeStyle格式化时间
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
///给定format格式化时间
- (NSString *)stringWithFormat:(NSString *)format;

#pragma mark ---- 从当前日期相对日期时间
///明天
+ (NSDate *)dateTomorrow;
///昨天
+ (NSDate *)dateYesterday;
///今天后几天
+ (NSDate *)dateWithDaysFromNow:(NSInteger)days;
///今天前几天
+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days;
///当前小时后dHours个小时
+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours;
///当前小时前dHours个小时
+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours;
///当前分钟后dMinutes个分钟
+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes;
///当前分钟前dMinutes个分钟
+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes;

+ (NSDate *)date:(NSString *)datestr WithFormat:(NSString *)format;


#pragma mark ---- Comparing dates 比较时间
///比较年月日是否相等
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;
///是否是今天
- (BOOL)isToday;
///是否是明天
- (BOOL)isTomorrow;
///是否是昨天
- (BOOL)isYesterday;

///是否是同一周
- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
///是否是本周
- (BOOL)isThisWeek;
///是否是本周的下周
- (BOOL)isNextWeek;
///是否是本周的上周
- (BOOL)isLastWeek;

///是否是同一月
- (BOOL)isSameMonthAsDate:(NSDate *)aDate;
///是否是本月
- (BOOL)isThisMonth;
///是否是本月的下月
- (BOOL)isNextMonth;
///是否是本月的上月
- (BOOL)isLastMonth;

///是否是同一年
- (BOOL)isSameYearAsDate:(NSDate *)aDate;
///是否是今年
- (BOOL)isThisYear;
///是否是今年的下一年
- (BOOL)isNextYear;
///是否是今年的上一年
- (BOOL)isLastYear;

///是否提前aDate
- (BOOL)isEarlierThanDate:(NSDate *)aDate;
///是否晚于aDate
- (BOOL)isLaterThanDate:(NSDate *)aDate;
///是否晚是未来
- (BOOL)isInFuture;
///是否晚是过去
- (BOOL)isInPast;

/**
 得到当天00:00时间

 @return 00:00时间
 */
- (NSDate*)firstTime;

/**
 得到当天23:59时间

 @return 23:59时间
 */
- (NSDate*)lastTime;



///是否是工作日
- (BOOL)isTypicallyWorkday;
///是否是周末
- (BOOL)isTypicallyWeekend;

#pragma mark ---- Adjusting dates 调节时间
///增加dYears年
- (NSDate *)dateByAddingYears:(NSInteger)dYears;
///减少dYears年
- (NSDate *)dateBySubtractingYears:(NSInteger)dYears;
///增加dMonths月
- (NSDate *)dateByAddingMonths:(NSInteger)dMonths;
///减少dMonths月
- (NSDate *)dateBySubtractingMonths:(NSInteger)dMonths;
///增加dDays天
- (NSDate *)dateByAddingDays:(NSInteger)dDays;
///减少dDays天
- (NSDate *)dateBySubtractingDays:(NSInteger)dDays;
///增加dHours小时
- (NSDate *)dateByAddingHours:(NSInteger)dHours;
///减少dHours小时
- (NSDate *)dateBySubtractingHours:(NSInteger)dHours;
///增加dMinutes分钟
- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes;
///减少dMinutes分钟
- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes;



// Date extremes
- (NSDate *)dateAtStartOfDay;
// Thanks gsempe & mteece
- (NSDate *)dateAtEndOfDay;

#pragma mark ---- 时间间隔
///比aDate晚多少分钟
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
///比aDate早多少分钟
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
///比aDate晚多少小时
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
///比aDate早多少小时
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
///比aDate晚多少天
- (NSInteger)daysAfterDate:(NSDate *)aDate;
///比aDate早多少天
- (NSInteger)daysBeforeDate:(NSDate *)aDate;

///与anotherDate间隔几天
- (NSInteger)distanceDaysToDate:(NSDate *)anotherDate;
///与anotherDate间隔几月
- (NSInteger)distanceMonthsToDate:(NSDate *)anotherDate;
///与anotherDate间隔几年
- (NSInteger)distanceYearsToDate:(NSDate *)anotherDate;

- (NSDate *)dateWithYMD;
- (NSDate *)dateWithFormatter:(NSString *)formatter;


/**
 * 获取日、月、年、小时、分钟、秒
 */

+ (NSUInteger)day:(NSDate *)date;
+ (NSUInteger)month:(NSDate *)date;
+ (NSUInteger)year:(NSDate *)date;
+ (NSUInteger)hour:(NSDate *)date;
+ (NSUInteger)minute:(NSDate *)date;
+ (NSUInteger)second:(NSDate *)date;

/**
 * 获取一年中的总天数
 */
- (NSUInteger)daysInYear;
+ (NSUInteger)daysInYear:(NSDate *)date;

/**
 * 判断是否是润年
 * @return YES表示润年，NO表示平年
 */
- (BOOL)isLeapYear;
+ (BOOL)isLeapYear:(NSDate *)date;

/**
 * 获取该日期是该年的第几周
 */
- (NSUInteger)weekOfYear;
+ (NSUInteger)weekOfYear:(NSDate *)date;

/**
 * 获取格式化为YYYY-MM-dd格式的日期字符串
 */
- (NSString *)formatYMD;
+ (NSString *)formatYMD:(NSDate *)date;

/**
 * 返回当前月一共有几周(可能为4,5,6)
 */
- (NSUInteger)weeksOfMonth;
+ (NSUInteger)weeksOfMonth:(NSDate *)date;

/**
 * 获取该月的第一天的日期
 */
- (NSDate *)begindayOfMonth;
+ (NSDate *)begindayOfMonth:(NSDate *)date;

/**
 * 获取该月的最后一天的日期
 */
- (NSDate *)lastdayOfMonth;
+ (NSDate *)lastdayOfMonth:(NSDate *)date;

/**
 * 返回day天后的日期(若day为负数,则为|day|天前的日期)
 */
- (NSDate *)dateAfterDay:(NSUInteger)day;
+ (NSDate *)dateAfterDate:(NSDate *)date day:(NSInteger)day;

/**
 * 返回day天后的日期(若day为负数,则为|day|天前的日期)
 */
- (NSDate *)dateAfterMonth:(NSUInteger)month;
+ (NSDate *)dateAfterDate:(NSDate *)date month:(NSInteger)month;

/**
 * 返回numYears年后的日期
 */
- (NSDate *)offsetYears:(int)numYears;
+ (NSDate *)offsetYears:(int)numYears fromDate:(NSDate *)fromDate;

/**
 * 返回numMonths月后的日期
 */
- (NSDate *)offsetMonths:(int)numMonths;
+ (NSDate *)offsetMonths:(int)numMonths fromDate:(NSDate *)fromDate;

/**
 * 返回numDays天后的日期
 */
- (NSDate *)offsetDays:(int)numDays;
+ (NSDate *)offsetDays:(int)numDays fromDate:(NSDate *)fromDate;

/**
 * 返回numHours小时后的日期
 */
- (NSDate *)offsetHours:(int)hours;
+ (NSDate *)offsetHours:(int)numHours fromDate:(NSDate *)fromDate;

/**
 * 距离该日期前几天
 */
- (NSUInteger)daysAgo;
+ (NSUInteger)daysAgo:(NSDate *)date;

/**
 *  获取星期几
 *
 *  @return Return weekday number
 *  [1 - Sunday]
 *  [2 - Monday]
 *  [3 - Tuerday]
 *  [4 - Wednesday]
 *  [5 - Thursday]
 *  [6 - Friday]
 *  [7 - Saturday]
 */
- (NSInteger)weekday;
+ (NSInteger)weekday:(NSDate *)date;

/**
 *  获取星期几(名称)
 *
 *  @return Return weekday as a localized string
 *  [1 - Sunday]
 *  [2 - Monday]
 *  [3 - Tuerday]
 *  [4 - Wednesday]
 *  [5 - Thursday]
 *  [6 - Friday]
 *  [7 - Saturday]
 */
- (NSString *)dayFromWeekday;
+ (NSString *)dayFromWeekday:(NSDate *)date;

/**
 *  日期是否相等
 *
 *  @param anotherDate The another date to compare as NSDate
 *  @return Return YES if is same day, NO if not
 */
- (BOOL)isSameDay:(NSDate *)anotherDate;



/**
 *  Get the month as a localized string from the given month number
 *
 *  @param month The month to be converted in string
 *  [1 - January]
 *  [2 - February]
 *  [3 - March]
 *  [4 - April]
 *  [5 - May]
 *  [6 - June]
 *  [7 - July]
 *  [8 - August]
 *  [9 - September]
 *  [10 - October]
 *  [11 - November]
 *  [12 - December]
 *
 *  @return Return the given month as a localized string
 */
+ (NSString *)monthWithMonthNumber:(NSInteger)month;

/**
 * 根据日期返回字符串
 */
+ (NSString *)stringWithDate:(NSDate *)date format:(NSString *)format;
+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format;

/**
 * 获取指定月份的天数
 */
- (NSUInteger)daysInMonth:(NSUInteger)month;
+ (NSUInteger)daysInMonth:(NSDate *)date month:(NSUInteger)month;

/**
 * 获取当前月份的天数
 */
- (NSUInteger)daysInMonth;
+ (NSUInteger)daysInMonth:(NSDate *)date;

/**
 * 返回x分钟前/x小时前/昨天/x天前/x个月前/x年前
 */
- (NSString *)timeInfo;
+ (NSString *)timeInfoWithDate:(NSDate *)date;
+ (NSString *)timeInfoWithDateString:(NSString *)dateString;

/**
 * 分别获取yyyy-MM-dd/HH:mm:ss/yyyy-MM-dd HH:mm:ss格式的字符串
 */
- (NSString *)ymdFormat;
- (NSString *)hmsFormat;
- (NSString *)ymdHmsFormat;
+ (NSString *)ymdFormat;
+ (NSString *)hmsFormat;
+ (NSString *)ymdHmsFormat;



+ (NSCalendar *)chineseCalendar;
//例如 五月初一
+ (NSString*)currentMDDateString;
//例如 乙未年五月初一
+ (NSString*)currentYMDDateString;
//例如 星期一
+ (NSString *)currentWeek:(NSDate*)date;
//例如 星期一
+ (NSString *)currentWeekWithDateString:(NSString*)datestring;
//例如 五月一
+ (NSString*)currentCapitalDateString;




@end

//NS_ASSUME_NONNULL_END
