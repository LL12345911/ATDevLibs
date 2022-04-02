//
//  NSString+ATKit.m
//  HighwayDoctor
//
//  Created by Mars on 2019/6/12.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "NSString+ATKit.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <objc/runtime.h>

#define replaceIfContains(string,target,replacement,tone) \
do {\
if ([string containsString:target]) {\
string = [string stringByReplacingOccurrencesOfString:target withString:replacement];\
string = [NSString stringWithFormat:@"%@%d",string,tone];\
}\
} while(0)

//xml字符串转换成NSDictionary
#define AT_ASSOCIATIVE_CURRENT_DICTIONARY_KEY @"ASSOCIATIVE_CURRENT_DICTIONARY_KEY"
#define AT_ASSOCIATIVE_CURRENT_TEXT_KEY @"ASSOCIATIVE_CURRENT_TEXT_KEY"


@interface NSString ()<NSXMLParserDelegate>
////xml字符串转换成NSDictionary
//@property(nonatomic, retain)NSMutableArray *currentDictionaries;
//@property(nonatomic, retain)NSMutableString *currentText;
//汉字转拼音
@property (nonatomic ,strong) NSArray *wordArray;
@property (nonatomic ,copy) NSString *wordPinyinWithTone;
@property (nonatomic ,copy) NSString *wordPinyinWithoutTone;

@end


@implementation NSString (ATKit)

+ (BOOL)isAllNum:(NSString *)string{
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - 获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索
+ (NSString *)transformhChineseToPinyin:(NSString *)aString{
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [NSMutableString new];
    
    
        for(int i = 0; i < pinyinArray.count;i++){
            [allString appendFormat:@"%@",pinyinArray[i]];
        }
       
   
    return allString;
}

/// 获取字符串首字母大写 firstLetterChineseToPinyin：
/// @param aString 字符串
+ (NSString *)firstLetterChineseToPinyin:(NSString *)aString{
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    
    if (pinyinArray.count > 0) {
        //转化为大写拼音
        NSString *pPinYin = [pinyinArray[0] capitalizedString];
        return pPinYin;
    }else{
        return @"#";
    }
//    if (pinyinArray.count > 0) {
//        return pinyinArray[0];
//    }else{
//        return @"#";
//    }
}

/**
 去掉浮点数后面多余的0
 
 @param string 要去除多余0的字符串
 @return 去掉浮点数后面多余的0字符串
 */
+ (NSString*)removeFloatAllZero:(NSString*)string{
    //    NSNumber * nsNumber = @(string.floatValue);
    //    NSString * outNumber = [NSString stringWithFormat:@"%@",nsNumber];
    /*---------第一种方法-----------*/
    
    long len = string.length;
    for (int i = 0; i < len; i++){
        if (![string  hasSuffix:@"0"]){
            break;
        }else{
            if (![string containsString:@"."]) {
                break;
            }else{
                string = [string substringToIndex:[string length]-1];
            }
        }
    }
    if ([string hasSuffix:@"."])//避免像2.0000这样的被解析成2.
        {
        //s.substring(0, len - i - 1);
        return [string substringToIndex:[string length]-1];
        }else{
            return string;
        }
}


/**
 给字符串小数点后面补零
 
 @param price 字符串
 @param position 小数点后面 的位数，不足补零
 @return 字符串
 */
+(NSString *)notRounding:(NSString*)price afterPoint:(NSInteger)position{
    
    NSRange range = [price rangeOfString:@"."];
    if (range.length != 0 && (price.length-range.location-1>=position)) {
        position = price.length-range.location-1;
    }
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc]initWithString:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    //    return roundedOunces;// 整数的不带小数点
    NSString* string = [NSString stringWithFormat:@"%@",roundedOunces];
    
    if ([string rangeOfString:@"."].length==0) {
        NSString *str = @".";
        for (int i = 0;  i < position; i++) {
            str = [str stringByAppendingString:@"0"];
        }
        //string=  [string stringByAppendingString:@".00000"];
        string=  [string stringByAppendingString:str];
    }else{
        
        NSRange range = [string rangeOfString:@"."];
        for (NSInteger i = ((string.length-range.location-1) > 0 ?(string.length-range.location-1):position);  i < position; i++) {
            string=   [string stringByAppendingString:@"0"];
        }
    }
    return string;//整数.00格式
}




+ (NSString *)md5:(NSString *)str {
    if (!str) return nil;
    
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}


//获取文本高度
+ (float)heightForTextView:(CGSize)constraint WithText: (NSString *) strText WithFont:(CGFloat)font{
    if (!strText||strText.length==0) {
        return 0;
    }
    CGRect size = [strText boundingRectWithSize:constraint
                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:font]}
                                        context:nil];
    float textHeight = size.size.height;
    return textHeight;
}


/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */
- (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab {
    int location = 0;
    NSMutableArray *locationArr = [NSMutableArray new];
    NSRange range = [content rangeOfString:tab];
    if (range.location == NSNotFound){
        return locationArr;
    }
    //声明一个临时字符串,记录截取之后的字符串
    NSString * subStr = content;
    while (range.location != NSNotFound) {
        if (location == 0) {
            location += range.location;
        } else {
            location += range.location + tab.length;
        }
        //记录位置
        NSNumber *number = [NSNumber numberWithUnsignedInteger:location];
        [locationArr addObject:number];
        //每次记录之后,把找到的字串截取掉
        subStr = [subStr substringFromIndex:range.location + range.length];
        NSLog(@"subStr %@",subStr);
        range = [subStr rangeOfString:tab];
        NSLog(@"rang %@",NSStringFromRange(range));
    }
    return locationArr;
    
}


#pragma mark -
#pragma mark - 计算文字的宽高

/**
 *  动态计算文字的宽高（多行）
 *
 *  @param font 文字的字体
 *  @param limitSize 限制的范围
 *
 *  @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitSize:(CGSize)limitSize{
    CGSize theSize;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGRect rect = [self boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    theSize.width = ceil(rect.size.width);
    theSize.height = ceil(rect.size.height);
    return theSize;
}


/**
 *  动态计算文字的宽高（多行）
 *
 *  @param font 文字的字体
 *  @param limitWidth 限制宽度 ，高度不限制
 *
 *  @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth{
    return [self at_sizeWithFont:font limitSize:CGSizeMake(limitWidth, MAXFLOAT)];
}


/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)at_heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textSize = [self backCGRectByFont:textFont size:CGSizeMake(width, CGFLOAT_MAX)].size;
    } else {
        textSize = [self sizeWithFont:textFont constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    textSize = [self backCGRectByFont:textFont size:CGSizeMake(width, CGFLOAT_MAX)].size;
#endif
    
    return ceil(textSize.height);
}


/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)at_widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        
        textSize = [self backCGRectByFont:textFont size:CGSizeMake(CGFLOAT_MAX, height)].size;
        
    } else {
        textSize = [self sizeWithFont:textFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, height) lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    textSize = [self backCGRectByFont:textFont size:CGSizeMake(CGFLOAT_MAX, height)].size;
    
#endif
    
    return ceil(textSize.width);
}


/**
 返回文字的CGRect

 @param textFont 字体
 @param size 文字宽高
 @return CGRect
 */
- (CGRect)backCGRectByFont:(UIFont *)textFont size:(CGSize)size{
    @autoreleasepool {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        CGRect textRect = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine) attributes:attributes context:nil];
        return textRect;
    }
}


/**
 *  @brief  反转字符串
 *
 *  @param strSrc 被反转字符串
 *
 *  @return 反转后字符串
 */
+ (NSString *)at_reverseString:(NSString *)strSrc{
    NSMutableString* reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [strSrc length];
    while (charIndex > 0) {
        charIndex --;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[strSrc substringWithRange:subStrRange]];
    }
    return reverseString;
}



-(CGSize)stringSizeWithFont:(UIFont *)font widthLimit:(CGFloat)widthLimit heightLimit:(CGFloat)heightLimit{
    return  [self boundingRectWithSize:CGSizeMake(widthLimit, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}




#pragma mark -
#pragma mark - UrlEncode
/**
 *  @brief  urlEncode
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncode {
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}
/**
 *  @brief  urlEncode
 *
 *  @param encoding encoding模式
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)self,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",CFStringConvertNSStringEncodingToEncoding(encoding));
#pragma clang diagnostic pop
}
/**
 *  @brief  urlDecode
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecode {
    return [self urlDecodeUsingEncoding:NSUTF8StringEncoding];
}
/**
 *  @brief  urlDecode
 *
 *  @param encoding encoding模式
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(__bridge CFStringRef)self,CFSTR(""),CFStringConvertNSStringEncodingToEncoding(encoding));
    
#pragma clang diagnostic pop
}
/**
 *  @brief  url query转成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryFromURLParameters{
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByRemovingPercentEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}



#pragma mark -
#pragma mark - 汉字转拼音
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count{
    return [@"" stringByPaddingToLength:(metaString.length * count) withString:metaString startingAtIndex:0];
}

+(NSString *)stringWithRandomCharacterWithLength:(NSUInteger)length {
    char data[length];
    for (int i = 0; i < length; i ++) {
        int ran = arc4random() % 62;
        if (ran < 10) {
            ran += 48;
        } else if (ran < 36) {
            ran += 55;
        } else {
            ran += 61;
        }
        data[i] = (char)ran;
    }
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}


-(NSString *)at_TransferChineseToPinYinWithWhiteSpace:(BOOL)neeAThiteSpace tone:(BOOL)tone {
    if (!self.wordArray.count) {
        return nil;
    }
    __block NSString * string = @"";
    NSString * whiteSpace = neeAThiteSpace ? @" " : @"";
    [self.wordArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * pinyin = [obj transferWordToPinYinWithTone:tone];
        if (!string.length) {
            string = [string stringByAppendingString:[NSString stringWithString:pinyin]];
        } else {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@%@",whiteSpace,pinyin]];
        }
    }];
    return string;
}


-(NSArray<NSTextCheckingResult *> *)at_RangesConfirmToPattern:(NSString *)pattern {
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    return [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
}


-(NSArray<NSString *> *)at_SubStringConfirmToPattern:(NSString *)pattern {
    NSArray * ranges = [self at_RangesConfirmToPattern:pattern];
    NSMutableArray * strings = [NSMutableArray array];
    for (NSTextCheckingResult * result in ranges) {
        [strings addObject:[self substringWithRange:result.range]];
    }
    return strings;
}


-(NSArray *)at_TrimStringToWord {
    if (self.length) {
        NSMutableArray * temp = [NSMutableArray array];
        [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            if (substring.length > 1 && temp.count == 0 && ![substring at_StringIsChinese] && [substring at_SubStringConfirmToPattern:@"[\\u4E00-\\u9FA5]+"].count > 0) {///为防止第一个字与英文连在一起
                [temp addObject:[substring substringToIndex:1]];
                [temp addObject:[substring substringFromIndex:1]];
            } else {
                if (substring.length > 1 && [substring at_StringIsChinese]) {
                    [substring enumerateSubstringsInRange:NSMakeRange(0, substring.length) options:(NSStringEnumerationByComposedCharacterSequences) usingBlock:^(NSString * _Nullable substring2, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                        [temp addObject:substring2];
                    }];
                } else {
                    if (substring.length) {
                        [temp addObject:substring];
                    }
                }
            }
        }];
        return [temp copy];
    }
    return nil;
}


-(BOOL)at_StringIsChinese {
    if (self.length == 0) {
        return NO;
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[\\u4E00-\\u9FA5]+"];
    return [predicate evaluateWithObject:self];
}


-(NSString *)at_StringByReplacingCharactersInArray:(NSArray *)characters withString:(NSString *)temp {
    if (characters.count == 0) {
        return nil;
    }
    NSString * pattern = [characters componentsJoinedByString:@","];
    pattern = [@"[" stringByAppendingString:pattern];
    pattern = [pattern stringByAppendingString:@"]"];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive) error:nil];
    return [regex stringByReplacingMatchesInString:self options:(NSMatchingReportProgress) range:NSMakeRange(0, self.length) withTemplate:temp];
}


-(NSString *)at_StringByTrimmingWhitespace {
    NSString * temp = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *components = [temp componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    return [components componentsJoinedByString:@" "];
}


#pragma mark --- setter/getter ---
-(void)setPinyinString:(NSString *)pinyinString {
    objc_setAssociatedObject(self, @selector(pinyinString), pinyinString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


-(NSString *)pinyinString {
    NSString * pinyin = objc_getAssociatedObject(self, _cmd);
    if (!pinyin) {
        pinyin = [self at_TransferChineseToPinYinWithWhiteSpace:YES tone:YES];
        objc_setAssociatedObject(self, @selector(pinyinString), pinyin, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return pinyin;
}


#pragma mark --- tool method ---
-(NSString *)transferWordToPinYinWithTone:(BOOL)tone {
    if (tone && self.wordPinyinWithTone) {
        return self.wordPinyinWithTone;
    } else if (!tone && self.wordPinyinWithoutTone) {
        return self.wordPinyinWithoutTone;
    }
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSStringCompareOptions toneOption = tone ?NSCaseInsensitiveSearch:NSDiacriticInsensitiveSearch;
    NSString * pinyin = [mutableString stringByFoldingWithOptions:toneOption locale:[NSLocale currentLocale]];
    if (tone) {
        self.wordPinyinWithTone = pinyin;
    } else {
        self.wordPinyinWithoutTone = pinyin;
    }
    return pinyin;
}


+(NSMutableArray *)at_SortedStringsInPinyin:(NSArray<NSString *> *)strings {
    NSMutableArray * newStrings = [NSMutableArray arrayWithArray:strings];
    ///按拼音/汉字排序指定范围联系人
    [newStrings sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 at_ComparedInPinyinWithString:obj2 considerTone:YES];
    }];
    return newStrings;
}


-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string considerTone:(BOOL)tone {
    if ([self isEqualToString:string]) {
        return NSOrderedSame;
    }
    NSArray <NSString *>* arr1 = self.wordArray;
    NSArray <NSString *>* arr2 = string.wordArray;
    NSUInteger minL = MIN(arr1.count, arr2.count);
    for (int i = 0; i < minL; i ++) {
        if ([arr1[i] isEqualToString:arr2[i]]) {
            continue;
        }
        NSString * pinyin1 = [arr1[i] transferWordToPinYinWithTone:tone];
        NSString * pinyin2 = [arr2[i] transferWordToPinYinWithTone:tone];
        if (tone) {
            pinyin1 = transformPinyinTone(pinyin1);
            pinyin2 = transformPinyinTone(pinyin2);
        }
        NSComparisonResult result = [pinyin1 caseInsensitiveCompare:pinyin2];
        if (result != NSOrderedSame) {
            return result;
        } else {
            result = [arr1[i] localizedCompare:arr2[i]];
            if (result != NSOrderedSame) {
                return result;
            }
        }
    }
    if (arr1.count < arr2.count) {
        return NSOrderedAscending;
    } else if (arr1.count > arr2.count) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}


-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string {
    return [self at_ComparedInPinyinWithString:string considerTone:YES];
}

-(void)setWordPinyinWithTone:(NSString *)wordPinyinWithTone {
    objc_setAssociatedObject(self, @selector(wordPinyinWithTone), wordPinyinWithTone, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)wordPinyinWithTone {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWordPinyinWithoutTone:(NSString *)wordPinyinWithoutTone {
    objc_setAssociatedObject(self, @selector(wordPinyinWithoutTone), wordPinyinWithoutTone, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)wordPinyinWithoutTone {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWordArray:(NSArray *)wordArray {
    objc_setAssociatedObject(self, @selector(wordArray), wordArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)wordArray {
    NSArray * array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [self at_TrimStringToWord];
        objc_setAssociatedObject(self, @selector(wordArray), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

#pragma mark --- inline method ---
static NSString * transformPinyinTone(NSString * pinyin) {
    replaceIfContains(pinyin, @"ā", @"a",1);
    replaceIfContains(pinyin, @"á", @"a",2);
    replaceIfContains(pinyin, @"ǎ", @"a",3);
    replaceIfContains(pinyin, @"à", @"a",4);
    replaceIfContains(pinyin, @"ō", @"o",1);
    replaceIfContains(pinyin, @"ó", @"o",2);
    replaceIfContains(pinyin, @"ǒ", @"o",3);
    replaceIfContains(pinyin, @"ò", @"o",4);
    replaceIfContains(pinyin, @"ē", @"e",1);
    replaceIfContains(pinyin, @"é", @"e",2);
    replaceIfContains(pinyin, @"ě", @"e",3);
    replaceIfContains(pinyin, @"è", @"e",4);
    replaceIfContains(pinyin, @"ī", @"i",1);
    replaceIfContains(pinyin, @"í", @"i",2);
    replaceIfContains(pinyin, @"ǐ", @"i",3);
    replaceIfContains(pinyin, @"ì", @"i",4);
    replaceIfContains(pinyin, @"ū", @"u",1);
    replaceIfContains(pinyin, @"ú", @"u",2);
    replaceIfContains(pinyin, @"ǔ", @"u",3);
    replaceIfContains(pinyin, @"ù", @"u",4);
    return pinyin;
}


@end
