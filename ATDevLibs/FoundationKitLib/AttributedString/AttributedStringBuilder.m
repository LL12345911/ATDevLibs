//
//  MyAttributedStringBuilder.m
//  MyAttributedStringDemo
//
//  Created by oybq on 15/6/18.
//  qq:156355113
//  e-mail:obq0387_cn@sina.com
//  Copyright (c) 2015年 youngsoft. All rights reserved.
//

#import "AttributedStringBuilder.h"


@interface AttributedStringRange ()


@property (nonatomic, strong) NSMutableArray *ranges;
@property (nonatomic, strong) NSMutableAttributedString *attrString;
@property (nonatomic, strong) AttributedStringBuilder *builder;


@end


@implementation AttributedStringRange
//{
//    NSMutableArray *_ranges;
//    NSMutableAttributedString *_attrString;
//
//    AttributedStringBuilder *_builder;
//
//}


-(id)initWithAttributeString:(NSMutableAttributedString*)attrString builder:(AttributedStringBuilder*)builder {
    self = [self init];
    if (self != nil)
    {
        _attrString = attrString;
        _builder = builder;
        _ranges = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addRange:(NSRange)range {
    [_ranges addObject:[NSValue valueWithRange:range]];
}

-(void)enumRange:(void(^)(NSRange range))block {
    if (self == nil || _attrString == nil)
        return;
    
    for (int i = 0; i < _ranges.count; i++) {
        NSRange range = ((NSValue*)[_ranges objectAtIndex:i]).rangeValue;
        if (range.location == NSNotFound || range.length == 0) {
            continue;
        }
        
        block(range);
    }
}

/**
 字体
 
 @param font 字体
 
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"字体设置"];
 @discussion builder.firstRange.font = [UIFont systemFontOfSize:40];
 @discussion builder.lastRange.font = [UIFont systemFontOfSize:20];
 */
-(AttributedStringRange*)setFont:(UIFont*)font {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSFontAttributeName value:font range:range];
    }];
    return self;
}



/**
 文字颜色
 
 @param color 字体颜色
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"蓝色的背景红色的文字"];
 @discussion builder.allRange.backgroundColor = [UIColor blueColor];
 @discussion builder.allRange.textColor = [UIColor redColor];
 */
-(AttributedStringRange*)setTextColor:(UIColor*)color {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
        
    }];
    return self;
}


/**
 @brief 背景色
 
 @param color 字体背景颜色
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"蓝色的背景红色的文字"];
 @discussion builder.allRange.backgroundColor = [UIColor blueColor];
 @discussion builder.allRange.textColor = [UIColor redColor];
 
 */
-(AttributedStringRange*)setBackgroundColor:(UIColor*)color {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSBackgroundColorAttributeName value:color range:range];
    }];
    return self;
}

/**
 段落样式
 
 @param paragraphStyle 段落
 
 @discussion NSMutableParagraphStyle *ps  = [[NSMutableParagraphStyle alloc] init];
 */
-(AttributedStringRange*)setParagraphStyle:(NSParagraphStyle*)paragraphStyle {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }];
    return self;
}

/**
 连体字符，好像没有什么作用
 */
-(AttributedStringRange*)setLigature:(BOOL)ligature {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSLigatureAttributeName value:[NSNumber numberWithInteger:ligature] range:range];
    }];
    return self;
}

/**
 @brief 字间距
 
 @param kern 字间距
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"看我的字间距越来越宽"];
 @discussion [builder range:NSMakeRange(0, 2)].kern = -5;
 @discussion [builder range:NSMakeRange(2, 4)].kern = 7;
 @discussion [builder range:NSMakeRange(6, 3)].kern = 15;
 */
-(AttributedStringRange*)setKern:(CGFloat)kern {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:kern] range:range];
    }];
    return self;
}

/**
 @brief 行间距
 @param lineSpacing 字间距
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"第一行\n第二行\n第三行\n"];
 @discussion builder.allRange.lineSpacing = 20;
 */
-(AttributedStringRange*)setLineSpacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *ps  = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = lineSpacing;
    return [self setParagraphStyle:ps];
}

/**
 @brief 删除线
 
 @param strikethroughStyle 删除线
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"删除线  和 下划线"];
 @discussion [builder includeString:@"删除线" all:NO].strikethroughStyle = 1;
 @discussion [builder includeString:@"删除线" all:NO].strikethroughColor = [UIColor redColor];
 @discussion [builder includeString:@"下划线" all:NO].underlineStyle = NSUnderlineStyleSingle;
 @discussion [builder includeString:@"下划线" all:NO].underlineColor = [UIColor redColor];
 */
-(AttributedStringRange*)setStrikethroughStyle:(int)strikethroughStyle {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:strikethroughStyle] range:range];
    }];
    return self;
}

/**
 @brief 删除线颜色
 
 @param strikethroughColor 删除线颜色
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"删除线  和 下划线"];
 @discussion [builder includeString:@"删除线" all:NO].strikethroughStyle = 1;
 @discussion [builder includeString:@"删除线" all:NO].strikethroughColor = [UIColor redColor];
 @discussion [builder includeString:@"下划线" all:NO].underlineStyle = NSUnderlineStyleSingle;
 @discussion [builder includeString:@"下划线" all:NO].underlineColor = [UIColor redColor];
 */
-(AttributedStringRange*)setStrikethroughColor:(UIColor*)strikethroughColor {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSStrikethroughColorAttributeName value:strikethroughColor range:range];
    }];
    return self;
}


/**
 @brief 下划线
 
 @param underlineStyle 下划线
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"删除线  和 下划线"];
 @discussion [builder includeString:@"删除线" all:NO].strikethroughStyle = 1;
 @discussion [builder includeString:@"删除线" all:NO].strikethroughColor = [UIColor redColor];
 
 @discussion [builder includeString:@"下划线" all:NO].underlineStyle = NSUnderlineStyleSingle;
 @discussion [builder includeString:@"下划线" all:NO].underlineColor = [UIColor redColor];
 */
-(AttributedStringRange*)setUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:underlineStyle] range:range];
    }];
    return self;
}

/**
 阴影
 
 @param shadow  阴影
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"我有阴影"];
 @discussion NSShadow *shadow = [[NSShadow alloc] init];
 
 @discussion shadow.shadowOffset = CGSizeMake(2, 2);
 @discussion shadow.shadowColor = [UIColor redColor];
 @discussion shadow.shadowBlurRadius = 2;
 @discussion builder.allRange.shadow = shadow;
 
 */
-(AttributedStringRange*)setShadow:(NSShadow*)shadow {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSShadowAttributeName value:shadow range:range];
    }];
    return self;
}

-(AttributedStringRange*)setTextEffect:(NSString*)textEffect {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSTextEffectAttributeName value:textEffect range:range];
    }];
    return self;
}

/**
 将区域中的特殊字符: NSAttachmentCharacter,替换为attachement中指定的图片,这个来实现图片混排。
 
 @param attachment 富文本
 
 @discussion “\ufffc” 为对象占位符，目的是当富文本中有图像时，只复制文本信息！！！
 */
-(AttributedStringRange*)setAttachment:(NSTextAttachment*)attachment {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSAttachmentAttributeName value:attachment range:range];
    }];
    return self;
}

-(AttributedStringRange*)setLink:(NSURL*)url {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSLinkAttributeName value:url range:range];
    }];
    return self;
}

/**
 @brief 设置基线的偏移量，正值为往上，负值为往下，可以用于控制UILabel的居顶或者居低显示
 
 @param baselineOffset 设置基线的偏移量，正值为往上，负值为往下，可以用于控制UILabel的居顶或者居低显示
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"基线偏移的文字效果"];
 @discussion [builder includeString:@"基线偏移" all:NO].baselineOffset = 3;
 @discussion [builder includeString:@"效果" all:NO].baselineOffset = -3;
 */
-(AttributedStringRange*)setBaselineOffset:(CGFloat)baselineOffset {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:baselineOffset] range:range];
    }];
    return self;
}

/**
 @brief 下划线颜色
 
 @param underlineColor 下划线颜色
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"删除线  和 下划线"];
 @discussion [builder includeString:@"删除线" all:NO].strikethroughStyle = 1;
 @discussion [builder includeString:@"删除线" all:NO].strikethroughColor = [UIColor redColor];
 
 @discussion [builder includeString:@"下划线" all:NO].underlineStyle = NSUnderlineStyleSingle;
 @discussion [builder includeString:@"下划线" all:NO].underlineColor = [UIColor redColor];
 */
-(AttributedStringRange*)setUnderlineColor:(UIColor*)underlineColor {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    }];
    return self;
}

/**
 设置倾斜度
 
 @param obliqueness 倾斜度
 @discussion 示例：
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"我是胖子 和 我是廋子  和  我歪了"];
 @discussion [builder includeString:@"我是胖子" all:NO].expansion = 1.1;
 @discussion [builder includeString:@"我是廋子" all:NO].expansion = -1.2;
 @discussion [builder includeString:@"我歪了" all:NO].obliqueness = 2;
 */
-(AttributedStringRange*)setObliqueness:(CGFloat)obliqueness {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSObliquenessAttributeName value:[NSNumber numberWithFloat:obliqueness] range:range];
    }];
    return self;
}

/**
 压缩文字，正值为伸，负值为缩
 
 @param expansion 压缩文字，正值为伸，负值为缩
 @discussion 示例：
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"我是胖子 和 我是廋子  和  我歪了"];
 @discussion [builder includeString:@"我是胖子" all:NO].expansion = 1.1;
 @discussion [builder includeString:@"我是廋子" all:NO].expansion = -1.2;
 @discussion [builder includeString:@"我歪了" all:NO].obliqueness = 2;
 */
-(AttributedStringRange*)setExpansion:(CGFloat)expansion {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSExpansionAttributeName value:[NSNumber numberWithFloat:expansion] range:range];
    }];
    return self;
    
}

/**
 @brief 中空文字的颜色
 
 @param strokeColor 中空文字的颜色
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"中间的文字中空"];
 @discussion [builder range:NSMakeRange(3, 2)].strokeColor = [UIColor greenColor];
 @discussion [builder range:NSMakeRange(3, 2)].strokeWidth = 2;
 */
-(AttributedStringRange*)setStrokeColor:(UIColor*)strokeColor {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSStrokeColorAttributeName value:strokeColor range:range];
    }];
    return self;
}

/**
 @brief 中空的线宽度
 
 @param strokeWidth 中空的线宽度
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"中间的文字中空"];
 @discussion [builder range:NSMakeRange(3, 2)].strokeColor = [UIColor greenColor];
 @discussion [builder range:NSMakeRange(3, 2)].strokeWidth = 2;
 */
-(AttributedStringRange*)setStrokeWidth:(CGFloat)strokeWidth {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:strokeWidth] range:range];
    }];
    return self;
}

-(AttributedStringRange*)setAttributes:(NSDictionary*)dict {
    __weak __typeof(self) weakSelf = self;
    [self enumRange:^(NSRange range){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attrString addAttributes:dict range:range];
    }];
    return self;
}

-(AttributedStringBuilder*)builder {
    return _builder;
}

@end


@implementation AttributedStringBuilder
{
    NSMutableAttributedString *attrString;
    NSInteger paragraphIndex;
}

+(AttributedStringBuilder*)builderWith:(NSString*)string {
    return [[AttributedStringBuilder alloc] initWithString:string];
}


-(id)initWithString:(NSString*)string {
    self = [self init];
    if (self != nil) {
        if (string != nil)
            attrString = [[NSMutableAttributedString alloc] initWithString:string];
        else
            attrString = nil;
        paragraphIndex = 0;
    }
    return self;
}

-(AttributedStringRange*)range:(NSRange)range {
    if (attrString == nil) {
        return nil;
    }
    
    if (attrString.length < range.location + range.length) {
        return nil;
    }
    
    AttributedStringRange *attrstrrang = [[AttributedStringRange alloc] initWithAttributeString:attrString builder:self];
    [attrstrrang addRange:range];
    return attrstrrang;
}

-(AttributedStringRange*)allRange {
    if (attrString == nil) {
        return nil;
    }
    
    NSRange range = NSMakeRange(0, attrString.length);
    return [self range:range];
}

-(AttributedStringRange*)lastRange {
    if (attrString == nil) {
        return nil;
    }
    
    NSRange range = NSMakeRange(attrString.length - 1, 1);
    return [self range:range];
}

-(AttributedStringRange*)lastNRange:(NSInteger)length {
    if (attrString == nil) {
        return nil;
    }
    
    return [self range:NSMakeRange(attrString.length - length, length)];
}


-(AttributedStringRange*)firstRange {
    if (attrString == nil) {
        return nil;
    }
    NSRange range = NSMakeRange(0, attrString.length > 0 ? 1 : 0);
    return [self range:range];
}

-(AttributedStringRange*)firstNRange:(NSInteger)length {
    if (attrString == nil) {
        return nil;
    }
    
    return [self range:NSMakeRange(0, length)];
}

/**
 用于选择特殊的字符
 
 @param characterSet 用于选择特殊的字符
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"数字123是高亮的，456也是高亮的"];
 @discussion [builder characterSet:[NSCharacterSet  decimalDigitCharacterSet]].textColor = [UIColor greenColor];
 */
-(AttributedStringRange*)characterSet:(NSCharacterSet*)characterSet {
    if (attrString == nil) {
        return nil;
    }
    
    //遍历所有字符，然后计算数值
    AttributedStringRange *attrstrrang = [[AttributedStringRange alloc] initWithAttributeString:attrString builder:self];
    
    NSString *str = attrString.string;
    NSRange range = NSMakeRange(0, 0);
    BOOL isStart = YES;
    for (int i = 0; i < str.length; i++) {
        unichar uc  = [str characterAtIndex:i];
        if ([characterSet characterIsMember:uc]) {
            if (isStart) {
                range.location = i;
                range.length = 0;
                isStart = NO;
            }
            range.length++;
        }else {
            if (!isStart){
                isStart = YES;
                
                [attrstrrang addRange:range];
            }
        }
    }
    
    if (!isStart) {
        [attrstrrang addRange:range];
    }
    
    return attrstrrang;
}


-(AttributedStringRange*)searchString:(NSString*)searchString options:(NSStringCompareOptions)options all:(BOOL)all {
    if (attrString == nil) {
        return nil;
    }
    
    AttributedStringRange *attRange = [[AttributedStringRange alloc] initWithAttributeString:attrString builder:self];
    NSString *str = attrString.string;
    if (!all) {
        return [self range:[str rangeOfString:searchString options:options]];
    }else {
        NSRange searchRange = NSMakeRange(0, str.length);
        NSRange range = NSMakeRange(0, 0);
        
        while(range.location != NSNotFound && searchRange.location < str.length) {
            range = [str rangeOfString:searchString options:options range:searchRange];
            [attRange addRange:range];
            if (range.location != NSNotFound) {
                searchRange.location = range.location + range.length;
                searchRange.length = str.length - searchRange.location;
            }
        }
    }
    
    return attRange;
    
}

-(AttributedStringRange*)includeString:(NSString*)includeString all:(BOOL)all {
    return [self searchString:includeString options:0 all:all];
}

-(AttributedStringRange*)regularExpression:(NSString*)regularExpression all:(BOOL)all {
    return [self searchString:regularExpression options:NSRegularExpressionSearch all:all];
}


-(AttributedStringRange*)firstParagraph {
    if (attrString == nil) {
        return nil;
    }
    
    paragraphIndex = 0;
    
    NSString *str = attrString.string;
    NSRange range = NSMakeRange(0, 0);
    NSInteger i;
    for (i = paragraphIndex; i < str.length; i++) {
        unichar uc = [str characterAtIndex:i];
        if (uc == '\n') {
            range.location =  0;
            range.length = i + 1;
            paragraphIndex = i + 1;
            break;
        }
    }
    
    if (i >= str.length) {
        range.location = 0;
        range.length = i;
        paragraphIndex = i;
    }
    
    
    return [self range:range];
}

-(AttributedStringRange*)nextParagraph {
    if (attrString == nil) {
        return nil;
    }
    
    NSString *str = attrString.string;
    
    if (paragraphIndex >= str.length) {
        return nil;
    }
    
    NSRange range = NSMakeRange(0, 0);
    NSInteger i;
    for (i = paragraphIndex; i < str.length; i++) {
        unichar uc = [str characterAtIndex:i];
        if (uc == '\n') {
            range.location =  paragraphIndex;
            range.length = i - paragraphIndex + 1;
            paragraphIndex = i + 1;
            break;
        }
    }
    
    if (i >= str.length) {
        range.location = paragraphIndex;
        range.length = i - paragraphIndex;
        paragraphIndex = i + 1;
    }
    
    return [self range:range];
}


-(void)insert:(NSInteger)pos attrstring:(NSAttributedString*)attrstring {
    if (attrString == nil || attrstring == nil) {
        return;
    }
    
    if (pos == -1) {
        [attrString appendAttributedString:attrstring];
    }else {
        [attrString insertAttributedString:attrstring atIndex:pos];
    }
}

-(void)insert:(NSInteger)pos attrBuilder:(AttributedStringBuilder*)attrBuilder {
    [self insert:pos attrstring:attrBuilder.commit];
}

-(NSAttributedString*)commit {
    return attrString;
}




@end
