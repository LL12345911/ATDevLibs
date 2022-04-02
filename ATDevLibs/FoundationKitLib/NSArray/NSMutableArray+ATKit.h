//
//  NSMutableArray+HelperKit.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/30.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSMutableArray (ATKit)


- (id)objectAtIndexCheck:(NSUInteger)index;
/**
 * 添加一个元素
 
 @param object 对象
 @return BOOL
 */
- (BOOL)at_addObject:(id)object;

/**
 * 插入一个对象到数组中
 
 @param index 索引
 @return BOOL
 */

- (BOOL)at_insertObject:(id)anObject atIndex:(NSUInteger)index;

/**
 * 安全移除对象
 
 @param index 索引
 @return BOOL
 */
- (BOOL)at_removeObjectAtIndex:(NSUInteger)index;

/**
 *  Exchange double elements.
 *
 *  @param fromIndex The index to move from
 *  @param toIndex   The index to move to
 *
 *  @return YES if exchange successfully, otherwise NO.
 */
- (BOOL)at_exchangeObjectFromIndex:(NSUInteger)fromIndex
                           toIndex:(NSUInteger)toIndex;


-(void)at_addPoint:(CGPoint)o;

-(void)at_addSize:(CGSize)o;

-(void)at_addRect:(CGRect)o;

@end




#pragma mark -
#pragma mark -  NSArray 不可变数组

@interface NSArray (ATSafe)

/**
 * Returns an string concatedated with delimiter
 */
- (NSString *_Nullable)implode:(NSString *_Nullable)delimiter;

/// 数组转化为字符串
- (NSString *_Nullable)toString;

/// 数组转化为JSON字符串
- (NSString *_Nullable)toJson;

/**
 * 该数组是否包含这个字符串
 
 @param string 字符串
 @return Bool
 */
-(BOOL)at_isContainsString:(NSString *)string;
/**
 * 数组倒序
 */
-(NSArray *)at_reverseArray;

- (id)at_firstObjectSafely ;

- (id)at_lastObjectSafely ;

- (id)at_objectSafelyAtIndex:(NSInteger)index ;

-(id)at_objectWithIndex:(NSUInteger)index;

- (NSDecimalNumber *)at_decimalNumberWithIndex:(NSUInteger)index;

- (double)at_doubleWithIndex:(NSUInteger)index;

- (NSDate *)at_dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;
//CG
- (CGFloat)at_CGFloatWithIndex:(NSUInteger)index;

- (CGPoint)at_pointWithIndex:(NSUInteger)index;

- (CGSize)at_sizeWithIndex:(NSUInteger)index;

- (CGRect)at_rectWithIndex:(NSUInteger)index;


@end


NS_ASSUME_NONNULL_END
