//
//  NSMutableArray+HelperKit.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/30.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "NSMutableArray+ATKit.h"

@implementation NSMutableArray (ATKit)


- (id)objectAtIndexCheck:(NSUInteger)index {
    
    if (index >= [self count]) {
        return nil;
    }
    
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}


- (BOOL)at_addObject:(id)object {
    BOOL ret = NO;
    if (object) {
        ret = YES;
        [self addObject:object];
    }
    return ret;
}

- (BOOL)at_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject == nil|| index > [self count] ) {
        return NO;
    }
    if ([self containsObject:anObject]) {
        return NO;
    }
    
    [self insertObject:anObject atIndex:index];
    return YES;
}

- (BOOL)at_removeObjectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;
}

- (BOOL)at_exchangeObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if ([self count] != 0 && toIndex != fromIndex
        && fromIndex < [self count] && toIndex < [self count]) {
        [self exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
        
        return YES;
    }
    return NO;
}

-(void)at_addPoint:(CGPoint)o{
    [self addObject:NSStringFromCGPoint(o)];
}
-(void)at_addSize:(CGSize)o{
    [self addObject:NSStringFromCGSize(o)];
}
-(void)at_addRect:(CGRect)o{
    [self addObject:NSStringFromCGRect(o)];
}


@end


#pragma mark -
#pragma mark -  NSArray 不可变数组

@implementation NSArray (ATSafe)

- (NSString *_Nullable)implode:(NSString *_Nullable)delimiter {
    return [self componentsJoinedByString:delimiter];
}

- (NSString *_Nullable)toString {
    NSString *exploded = [self implode:@","];
    return [NSString stringWithFormat:@"[%@]", exploded];
}

- (NSString *_Nullable)toJson {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/**
 * 该数组是否包含这个字符串
 
 @param string 字符串
 @return Bool
 */
-(BOOL)at_isContainsString:(NSString *)string{
    
    for (NSString *element in self) {
        if ([element isKindOfClass:[NSString class]] && [element isEqualToString:string]) {
            return true;
        }
    }
    return false;
}

/**
 * 数组倒序
 */
-(NSArray *)at_reverseArray{
    NSMutableArray *arrayTemp = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    
    for (id element  in enumerator) {
        [arrayTemp addObject:element];
    }
    return arrayTemp;
}


- (id)at_firstObjectSafely {
    id answer = nil ;
    
    if ([self count] > 0) {
        answer = [self objectAtIndex:0] ;
    }
    return answer ;
}

- (id)at_lastObjectSafely {
    id answer = nil ;
    
    NSInteger count = [self count] ;
    if (count > 0) {
        answer = [self objectAtIndex:(count-1)] ;
    }
    return answer ;
}

- (id)at_objectSafelyAtIndex:(NSInteger)index {
    id answer = nil ;
    
    if ((index >= 0) && (index < [self count])) {
        answer = [self objectAtIndex:index] ;
    }
    return answer ;
}


-(id)at_objectWithIndex:(NSUInteger)index{
    if (index <self.count) {
        return self[index];
    }else{
        return nil;
    }
}

- (NSDecimalNumber *)at_decimalNumberWithIndex:(NSUInteger)index{
    id value = [self at_objectWithIndex:index];
    
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber * number = (NSNumber*)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}
//
- (NSArray*)at_arrayWithIndex:(NSUInteger)index
{
    id value = [self at_objectWithIndex:index];
    if (value == nil || value == [NSNull null])
        {
        return nil;
        }
    if ([value isKindOfClass:[NSArray class]])
        {
        return value;
        }
    return nil;
}


- (NSDictionary*)at_dictionaryWithIndex:(NSUInteger)index
{
    id value = [self at_objectWithIndex:index];
    if (value == nil || value == [NSNull null])
        {
        return nil;
        }
    if ([value isKindOfClass:[NSDictionary class]])
        {
        return value;
        }
    return nil;
}

- (double)at_doubleWithIndex:(NSUInteger)index
{
    id value = [self at_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
        {
        return 0;
        }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
        {
        return [value doubleValue];
        }
    return 0;
}

- (NSDate *)at_dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat {
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formater.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    formater.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formater.dateFormat = dateFormat;
    id value = [self at_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
        {
        return nil;
        }
    
    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

//CG
- (CGFloat)at_CGFloatWithIndex:(NSUInteger)index
{
    id value = [self at_objectWithIndex:index];
    
    CGFloat f = [value doubleValue];
    
    return f;
}

- (CGPoint)at_pointWithIndex:(NSUInteger)index
{
    id value = [self at_objectWithIndex:index];
    
    CGPoint point = CGPointFromString(value);
    
    return point;
}
- (CGSize)at_sizeWithIndex:(NSUInteger)index
{
    id value = [self at_objectWithIndex:index];
    
    CGSize size = CGSizeFromString(value);
    
    return size;
}
- (CGRect)at_rectWithIndex:(NSUInteger)index
{
    id value = [self at_objectWithIndex:index];
    
    CGRect rect = CGRectFromString(value);
    
    return rect;
}

@end
