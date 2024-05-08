//
//  NSString+ATKit.h
//  HighwayDoctor
//
//  Created by Mars on 2019/6/12.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索

///  获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索
///  三林四标浦林城建项目部  #sanlinsibiaopulinchengjianxiangmubu,#slsbplcjxmb,#三林四标浦林城建项目部
/// @param aString 待转换字符串（汉字）
CG_INLINE NSString* TransformToPinyin(NSString *aString){
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [[NSMutableString alloc] init];
    NSString *ss = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    [allString appendFormat:@"#%@,",ss];
    
    NSMutableString *initialStr = [[NSMutableString alloc] init];
    //拼音首字母
    for (NSString *s in pinyinArray){
        if (s.length > 0){
            [initialStr appendString:[s substringToIndex:1]];
        }
    }
    [allString appendFormat:@"#%@",initialStr];
    [allString appendFormat:@",#%@",aString];
    return allString;
}


@interface NSString (ATKit)


//判断一个字符串中是否都是数字
+ (BOOL)isAllNum:(NSString *)string;

/// 将汉语转化成拼音
/// @param aString 需要转化成拼音的字符串
+ (NSString *)transformhChineseToPinyin:(NSString *)aString;

/// 获取字符串首字母 firstLetterChineseToPinyin：
/// @param aString 字符串
+ (NSString *)firstLetterChineseToPinyin:(NSString *)aString;


/**
 去掉浮点数后面多余的0
 
 @param string 要去除多余0的字符串
 @return 去掉浮点数后面多余的0字符串
 */
+ (NSString*)removeFloatAllZero:(NSString*)string;

/**
 给字符串小数点后面补零
 
 @param price 字符串
 @param position 小数点后面 的位数，不足补零
 @return 字符串
 */
+(NSString *)notRounding:(NSString*)price afterPoint:(NSInteger)position;



+ (NSString *)md5:(NSString *)str;
/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */
- (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab;

#pragma mark -
#pragma mark - 计算文字的宽高

/**
 动态计算文字的宽高（多行）
 @param font 文字的字体
 @param limitSize 限制的范围
 @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitSize:(CGSize)limitSize;


/**
 动态计算文字的宽高（多行）
 @param font 文字的字体
 @param limitWidth 限制宽度 ，高度不限制
 @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth;


/**
 @brief 计算文字的高度
 @param font  字体(默认为系统字体)
 @param width 约束宽度
 */
- (CGFloat)at_heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;


/**
 @brief 计算文字的宽度
 @param font   字体(默认为系统字体)
 @param height 约束高度
 */
- (CGFloat)at_widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;


/**
 @brief  反转字符串
 @param strSrc 被反转字符串
 @return 反转后字符串
 */
+ (NSString *)at_reverseString:(NSString *)strSrc;


///根据字号及尺寸限制返回文本尺寸
-(CGSize)stringSizeWithFont:(UIFont *)font
                 widthLimit:(CGFloat)widthLimit
                heightLimit:(CGFloat)heightLimit;

#pragma mark - UrlEncode
/**
 @brief  urlEncode
 @return urlEncode 后的字符串
 */
- (NSString *)urlEncode;


/**
 @brief  urlEncode
 @param encoding encoding模式
 @return urlEncode 后的字符串
 */
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;


/**
 @brief  urlDecode
 @return urlDecode 后的字符串
 */
- (NSString *)urlDecode;


/**
 @brief  urlDecode
 @param encoding encoding模式
 @return urlDecode 后的字符串
 */
- (NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding;


/**
 @brief  url query转成NSDictionary
 @return NSDictionary
 */
- (NSDictionary *)dictionaryFromURLParameters;



#pragma mark -
#pragma mark - 汉字转拼音


///转拼音后的字符串
@property (nonatomic ,copy) NSString * pinyinString;


/**
 生成由N个元字符串组成的字符串
 
 metaString     元字符串，组成字符串的元素
 count          元字符串的个数
 */
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count;


///以长度生成随机字符串，字符串有大小写字母及数字组成
+(NSString *)stringWithRandomCharacterWithLength:(NSUInteger)length;


/**
 汉字转拼音
 @param neeAThiteSpace 是否需要空格间隔
 @param tone           是否需要音调
 @return 转换后用拼音
 */
-(NSString *)at_TransferChineseToPinYinWithWhiteSpace:(BOOL)neeAThiteSpace tone:(BOOL)tone;


///判断字符串是否是中文
-(BOOL)at_StringIsChinese;


/**
 将字符串中的包含在数组中的子串替换为另一字符串
 @param characters 要被替换的子串数组
 @param temp 替换的目标串
 @return 替换后的字符串
 */
-(NSString *)at_StringByReplacingCharactersInArray:(NSArray *)characters withString:(NSString *)temp;


///返回整串字符串中符合正则的结果集
-(NSArray <NSTextCheckingResult *> *)at_RangesConfirmToPattern:(NSString *)pattern;


///符合正则的子串集
-(NSArray <NSString *> *)at_SubStringConfirmToPattern:(NSString *)pattern;


///将字符串分割成词（中文汉字为最小单位，英文单词为最小单位）
-(NSArray *)at_TrimStringToWord;


/**
 去除首尾空格并压缩串中空格至1个
 @return 压缩后的字符串
 */
-(NSString *)at_StringByTrimmingWhitespace;


///将数组内字符串以拼音排序
+(NSMutableArray *)at_SortedStringsInPinyin:(NSArray <NSString *>*)strings;


/**
 返回以拼音比较的结果
 @param string 被比较的字符串
 @param tone   是否考虑音调
 @return 比较结果
 */
-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string considerTone:(BOOL)tone;


/**
 返回考虑音调的拼音比较结果
 @param string 被比较的字符串
 @return 比较结果
 */
-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string;



@end

NS_ASSUME_NONNULL_END
