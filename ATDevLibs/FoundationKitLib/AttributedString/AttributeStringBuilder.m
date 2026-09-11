//
//  AttributeStringBuilder.m
//  SCRAttributedStringBuilderDemo
//
//  Created by Mars on 2023/3/24.
//  Copyright © 2023 Chuanren Shang. All rights reserved.
//

#import "AttributeStringBuilder.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "SCRoundedTagAttachment.h"
#import "SCDividerLineAttachment.h"

NSAttributedStringKey const SCRAttributedStringTapIDAttributeName = @"SCRAttributedStringTapIDAttributeName";
NSAttributedStringKey const SCRAttributedStringTapActionsAttributeName = @"SCRAttributedStringTapActionsAttributeName";


@interface AttributeStringBuilder ()

@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *attributes;
@property (nonatomic, strong) NSMutableAttributedString *source;
@property (nonatomic, strong) NSArray *scr_ranges;

/// 点击事件注册表：tapID -> action 块
/// 在 commit 时以 SCRAttributedStringTapActionsAttributeName 挂到整个字符串上
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *scr_tapActions;

@end


@implementation AttributeStringBuilder


/// 计算文本尺寸
/// - Parameters:
///   - attributedString: 富文本
///   - width: 宽度
+ (CGSize)calculateForAttributedString:(NSAttributedString *)attributedString withWidth:(CGFloat)width {
    
    if (!attributedString || attributedString.length == 0) {
        return CGSizeZero;
    }
    
    if (width <= 0) {
        return CGSizeZero;
    }
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];
    textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    // 强制完成排版，否则 usedRect 会返回空值
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect textRect = [layoutManager usedRectForTextContainer:textContainer];
    
    return CGSizeMake(ceil(textRect.size.width), ceil(textRect.size.height));
}

- (instancetype)init {
    if (self = [super init]) {
        self.attributes = [[NSMutableDictionary alloc] init];
        self.source = [[NSMutableAttributedString alloc] init];
        self.scr_tapActions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSAttributedString *)commit {
    // 存在点击注册表时，把它挂到整个字符串上，供 SCRTappableLabel 读取
    if (self.scr_tapActions.count > 0 && self.source.length > 0) {
        [self.source addAttribute:SCRAttributedStringTapActionsAttributeName
                            value:[self.scr_tapActions copy]
                            range:NSMakeRange(0, self.source.length)];
    }
    return [_source copy];
}

/**
 获取当前 NSRange，当append、及获取range时
 */
- (NSRange)currentRange {
    if (self.scr_ranges.count > 0) {
        NSValue *rangeValue = self.scr_ranges[0];
        return [rangeValue rangeValue];
    }
    return NSMakeRange(NSNotFound, NSNotFound);
}


#pragma mark - Content
/// 创建一个 Attributed String
+ (AttributeStringBuilder *(^)(NSString *))build {
    return ^(NSString *string) {
        if (!string) {
            string = @"";
        }

        
        NSRange range = NSMakeRange(0, string.length);
        AttributeStringBuilder *builder = [[AttributeStringBuilder alloc] init];// initWithString:string];
        [builder.source appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        
        builder.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return builder;
    };
}

/// 尾部追加一个新的 Attributed String
- (AttributeStringBuilder *(^)(NSString *))append {
    return ^(NSString *string) {
        if (!string) {
            string = @"";
        }
        
        NSRange range = NSMakeRange(self.source.length, string.length);
        [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

/// 同 append 比，参数是 NSAttributedString
- (AttributeStringBuilder *(^)(NSAttributedString *))attributedAppend {
    return ^(NSAttributedString *attributedString) {
        if (!attributedString || attributedString.length == 0) {
            return self;
        }

        // 合并来源字符串携带的点击注册表，保证拼接后点击事件仍然可用
        NSDictionary *actions = [attributedString attribute:SCRAttributedStringTapActionsAttributeName
                                                    atIndex:0
                                             effectiveRange:NULL];
        if ([actions isKindOfClass:[NSDictionary class]] && actions.count > 0) {
            [self.scr_tapActions addEntriesFromDictionary:actions];
        }

        NSRange range = NSMakeRange(self.source.length, attributedString.string.length);
        [self.source appendAttributedString:attributedString];
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

/// 插入一个新的 Attributed String
- (AttributeStringBuilder *(^)(NSString *, NSUInteger index))insert {
    return ^(NSString *string, NSUInteger index) {
        if (!string || index > self.source.length) {
            return self;
        }
        [self.source insertAttributedString:[[NSAttributedString alloc] initWithString:string] atIndex:index];
        NSRange range = NSMakeRange(index, string.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}


/// 增加间隔，spacing 的单位是 point。放到 Content 的原因是，间隔是通过空格+字体模拟的，但不会导致 Range 的切换
- (AttributeStringBuilder *(^)(CGFloat))appendSpacing {
    return ^(CGFloat spacing) {
        if (spacing <= 0) {
            return self;
        }
        
        NSTextAttachment *attachment = [NSTextAttachment new];
        attachment.image = nil;
        attachment.bounds = CGRectMake(0, 0, spacing, 0);
        return self.appendAttachment(attachment);
    };
}


/// 尾部追加一个附件。同插入字符不同，插入附件并不会将当前 Range 切换成附件所在的 Range，下同
- (AttributeStringBuilder *(^)(NSTextAttachment *))appendAttachment {
    return ^(NSTextAttachment *attachment) {
        if (!attachment) {
            return self;
        }
        
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attachment];
        [self.source appendAttributedString:string];
        return self;
    };
}


/// 在尾部追加图片附件，默认使用图片尺寸，图片垂直居中，为了设置处理垂直居中（基于字体的 capHeight），需要在添加图片附件之前设置字体
- (AttributeStringBuilder *(^)(UIImage *))appendImage {
    return ^(UIImage *image) {
        if (!image) {
            return self;
        }
        
        return self.appendSizeImage(image, image.size);
    };
}


/// 在尾部追加图片附件，可以自定义尺寸，默认使用图片前一位的字体进行对齐，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *, CGSize))appendSizeImage {
    return ^(UIImage *image, CGSize imageSize) {
        if (!image) {
            return self;
        }

        // 空字符串时不存在可取的字符，index 0 会越界并抛 NSRangeException
        UIFont *font = nil;
        if (self.source.length > 0) {
            font = [self.source attribute:NSFontAttributeName
                                  atIndex:self.source.length - 1
                           effectiveRange:nil];
        }
        return self.appendCustomImage(image, imageSize, font);
    };
}


/// 在尾部追加图片附件，可以自定义想对齐的字体，图片使用自身尺寸，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *, UIFont *))appendFontImage {
    return ^(UIImage *image, UIFont *font) {
        if (!image) {
            return self;
        }

        return self.appendCustomImage(image, image.size, font);
    };
}


/// 在尾部追加图片附件，可以自定义尺寸和想对齐的字体，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *, CGSize, UIFont *))appendCustomImage {
    return ^(UIImage *image, CGSize imageSize, UIFont *font) {
        if (!image) {
            return self;
        }
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, [self p_offsetForImageSize:imageSize font:font],
                                       imageSize.width, imageSize.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        return self;
    };
}


/// 在 index 位置插入图片附件，由于不确定字体信息，因此需要显式输入字体
- (AttributeStringBuilder *(^)(UIImage *, CGSize, NSUInteger, UIFont *))insertImage {
    return ^(UIImage *image, CGSize imageSize, NSUInteger index, UIFont *font) {
        if (!image || index > self.source.length) {
            return self;
        }

        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, [self p_offsetForImageSize:imageSize font:font],
                                       imageSize.width, imageSize.height);
        [self.source insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]
                                    atIndex:index];

        // 只有位于插入点之后（含插入点）的 Range 需要右移一位，
        // 插入点之前的 Range 位置不受影响。
        NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:self.scr_ranges.count];
        for (NSValue *value in self.scr_ranges) {
            NSRange range = [value rangeValue];
            if (range.location != NSNotFound && range.location >= index) {
                range.location += 1;
            }
            [ranges addObject:[NSValue valueWithRange:range]];
        }
        self.scr_ranges = [ranges copy];
        return self;
    };
}


/// 同 insertImage 的区别在于，会在当前 Range 的头部插入图片附件，如果没有 Range 则什么也不做
- (AttributeStringBuilder *(^)(UIImage *, CGSize, UIFont *))headInsertImage {
    return ^(UIImage *image, CGSize imageSize, UIFont *font) {
        if (!image || self.scr_ranges.count == 0) {
            return self;
        }

        CGFloat offset = [self p_offsetForImageSize:imageSize font:font];

        NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:self.scr_ranges.count];
        NSUInteger insertedCount = 0;
        for (NSValue *value in self.scr_ranges) {
            NSRange range = [value rangeValue];
            if (range.location == NSNotFound || range.location > self.source.length) {
                [ranges addObject:value];
                continue;
            }

            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, offset, imageSize.width, imageSize.height);
            [self.source insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]
                                        atIndex:range.location];

            // 本轮之前已插入的图片会把当前 Range 整体右移 insertedCount 位；
            // 当前 Range 自身再因为头部插入而后移一位。
            range.location += insertedCount + 1;
            insertedCount += 1;
            [ranges addObject:[NSValue valueWithRange:range]];
        }
        self.scr_ranges = [ranges copy];
        return self;
    };
}

#pragma mark - Range


/// 根据 start 和 length 设置范围
- (AttributeStringBuilder *(^)(NSInteger, NSInteger))range {
    return ^(NSInteger location, NSInteger length) {
        if (location < 0 || length <= 0) {
            return self;
        }
        NSUInteger total = self.source.length;
        // 先转成无符号再比较，避免有符号/无符号混用导致判断失真
        if ((NSUInteger)location > total || (NSUInteger)length > total - (NSUInteger)location) {
            return self;
        }
        NSRange range = NSMakeRange(location, length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

/// 从结尾倒数location 、 length 设置范围
- (AttributeStringBuilder *(^)(NSInteger, NSInteger))lastRange {
    return ^(NSInteger location, NSInteger length) {
        if (location < 0 || length <= 0) {
            return self;
        }
        NSUInteger total = self.source.length;
        // location 超过总长时，total - location 会无符号下溢成巨大值，
        // 进而构造出非法 Range 并触发越界崩溃
        if ((NSUInteger)location > total || (NSUInteger)length > (NSUInteger)location) {
            return self;
        }
        NSRange range = NSMakeRange(total - (NSUInteger)location, length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

/// 将范围设置为当前字符串全部
- (AttributeStringBuilder *)all {
    if (self.source.length == 0) {
        return self;
    }
    NSRange range = NSMakeRange(0, self.source.length);
    self.scr_ranges = @[ [NSValue valueWithRange:range] ];
    return self;
}


/// 匹配所有符合的字符串
- (AttributeStringBuilder *(^)(NSString *))match {
    return ^(NSString *string) {
        if (string.length == 0) {
            return self;
        }
        NSMutableArray *ranges = [NSMutableArray array];
        NSRange searchRange = NSMakeRange(0, self.source.length);
        NSRange foundRange;
        while (searchRange.location < self.source.string.length) {
            foundRange = [self.source.string rangeOfString:string options:0 range:searchRange];
            if (foundRange.location == NSNotFound) {
                break;
            }
            [ranges addObject:[NSValue valueWithRange:foundRange]];
            searchRange.location = foundRange.location + foundRange.length;
            searchRange.length = self.source.string.length - searchRange.location;
        }
        self.scr_ranges = [ranges copy];
        return self;
    };
}


/// 从头开始匹配第一个符合的字符串
- (AttributeStringBuilder *(^)(NSString *))matchFirst {
    return ^(NSString *string) {
        if (string.length == 0) {
            return self;
        }
        NSRange range = [self.source.string rangeOfString:string];
        if (range.location != NSNotFound) {
            self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        }
        return self;
    };
}

/// 为尾开始匹配第一个符合的字符串
- (AttributeStringBuilder *(^)(NSString *))matchLast {
    return ^(NSString *string) {
        if (string.length == 0) {
            return self;
        }
        NSRange range = [self.source.string rangeOfString:string options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        }
        return self;
    };
}


/**
 正则表达式
 
 @Discussion string 正则表达式
 @Discussion all 是否匹配所有
 */
-(AttributeStringBuilder *(^)(NSString *regularExpression, BOOL all))regular {
    return ^(NSString *regularExpression, BOOL all) {
        if (regularExpression.length == 0) {
            return self;
        }
        
        self.scr_ranges = [self searchString:regularExpression options:NSRegularExpressionSearch all:all];
        
        return self;
    };
}

-(NSArray<NSValue *> *)searchString:(NSString*)searchString options:(NSStringCompareOptions)options all:(BOOL)all {
    if (self.source == nil || self.source.length == 0) {
        return @[];
    }

    
    NSMutableArray<NSValue *> *tempArr = [NSMutableArray arrayWithCapacity:1];
    NSString *str = self.source.string;
    if (!all) {
        NSRange range = [str rangeOfString:searchString options:options];
        if (range.location != NSNotFound) {
            [tempArr addObject:[NSValue valueWithRange:range]];
        }
        
    }else {
        NSUInteger total = str.length;
        NSRange searchRange = NSMakeRange(0, total);

        while (searchRange.location < total) {
            NSRange range = [str rangeOfString:searchString options:options range:searchRange];
            if (range.location == NSNotFound) {
                break;
            }

            [tempArr addObject:[NSValue valueWithRange:range]];

            NSUInteger next = range.location + range.length;
            // 正则可能匹配到零长度（如 a*），此时若不前进一步，
            // searchRange.location 永不变化会导致死循环
            if (next == searchRange.location) {
                next += 1;
            }
            if (next > total) {
                break;
            }
            searchRange = NSMakeRange(next, total - next);
        }
    }
    
    return tempArr;
    
}

#pragma mark - Basic

/// 字体
- (AttributeStringBuilder *(^)(UIFont *))font {
    return ^(UIFont *font) {
        [self addAttribute:NSFontAttributeName value:font];
        return self;
    };
}

/// 字号，默认字体
- (AttributeStringBuilder *(^)(CGFloat))fontSize {
    return ^(CGFloat fontSize) {
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        [self addAttribute:NSFontAttributeName value:font];
        return self;
    };
}

/// 字号，默认字体
- (AttributeStringBuilder *(^)(CGFloat boldFontSize))boldFontSize{
    return ^(CGFloat boldFontSize) {
        UIFont *font = [UIFont boldSystemFontOfSize:boldFontSize];
        [self addAttribute:NSFontAttributeName value:font];
        return self;
    };
}

/// 字体颜色
- (AttributeStringBuilder *(^)(UIColor *))color {
    return ^(UIColor *color) {
        [self addAttribute:NSForegroundColorAttributeName value:color];
        return self;
    };
}

/// 字体颜色，16 进制
- (AttributeStringBuilder *(^)(NSInteger))hexColor {
    return ^(NSInteger hex) {
        UIColor *color = [UIColor colorWithRed:((float)(((hex) & 0xFF0000) >> 16))/255.0
                                         green:((float)(((hex) & 0xFF00) >> 8))/255.0
                                          blue:((float)((hex) & 0xFF))/255.0
                                         alpha:1.0];
        [self addAttribute:NSForegroundColorAttributeName value:color];
        return self;
    };
}

/// 背景颜色
- (AttributeStringBuilder *(^)(UIColor *))backgroundColor {
    return ^(UIColor *color) {
        [self addAttribute:NSBackgroundColorAttributeName value:color];
        return self;
    };
}

#pragma mark - 圆角文字标签（不生成图片）
- (AttributeStringBuilder *(^)(NSString *))appendRoundedTag {
    return ^(NSString *text) {
        SCRoundedTagAttachment *attachment = [[SCRoundedTagAttachment alloc] init];
        attachment.text = text ?: @"";
        attachment.font = [UIFont systemFontOfSize:14];
        attachment.textColor = UIColor.blackColor;
        attachment.fillColor = UIColor.clearColor;
        attachment.cornerRadius = 0;
        attachment.insets = UIEdgeInsetsZero;
        
        // 占位 attachment
        NSTextAttachment *placeholder = [[NSTextAttachment alloc] init];
        placeholder.bounds = CGRectZero;
        NSAttributedString *attr = [NSAttributedString attributedStringWithAttachment:placeholder];
        [self.source appendAttributedString:attr];
        
        NSRange range = NSMakeRange(self.source.length - 1, 1);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        // 替换为自定义 attachment
        [self.source addAttribute:NSAttachmentAttributeName value:attachment range:range];
        
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIFont *))tagFont {
    return ^(UIFont *font) {
        [self p_updateCurrentTagAttachment:^(SCRoundedTagAttachment *tag) {
            tag.font = font;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIColor *))tagTextColor {
    return ^(UIColor *color) {
        [self p_updateCurrentTagAttachment:^(SCRoundedTagAttachment *tag) {
            tag.textColor = color;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIColor *))tagBackgroundColor {
    return ^(UIColor *color) {
        [self p_updateCurrentTagAttachment:^(SCRoundedTagAttachment *tag) {
            tag.fillColor = color;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))tagCornerRadius {
    return ^(CGFloat radius) {
        [self p_updateCurrentTagAttachment:^(SCRoundedTagAttachment *tag) {
            tag.cornerRadius = radius;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIEdgeInsets))tagInsets {
    return ^(UIEdgeInsets insets) {
        [self p_updateCurrentTagAttachment:^(SCRoundedTagAttachment *tag) {
            tag.insets = insets;
        }];
        return self;
    };
}

#pragma mark - Private

- (void)p_updateCurrentTagAttachment:(void (^)(SCRoundedTagAttachment *tag))block {
    if (!block) {
        return;
    }
    for (NSValue *value in self.scr_ranges) {
        NSRange range = [value rangeValue];
        // location 为 NSNotFound 或越界时取属性会抛 NSRangeException
        if (![self p_isValidRange:range]) {
            continue;
        }
        id attachment = [self.source attribute:NSAttachmentAttributeName
                                       atIndex:range.location
                                effectiveRange:nil];
        if ([attachment isKindOfClass:[SCRoundedTagAttachment class]]) {
            block((SCRoundedTagAttachment *)attachment);
        }
    }
}

#pragma mark - 圆角文字标签（生成图片）
/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGFloat offsetY))appendBackgroundColor {
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGFloat offsetY) {
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0 textHorizontalMargin:0 textVerticalMargin:0];
        
        return [self appendImageWithOffset:img1 offsetY:offsetY];
    };
}

/**
 绘制带圆角边框和居中文本的自定义图片 （文本内边距）
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义图片大小
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion insets  文本内边距 文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移

 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *_Nullable textColor, UIColor *_Nullable fillColor, CGFloat radius, UIEdgeInsets insets, CGFloat offsetY))appendBackgroundInsetsColor {
    
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIEdgeInsets insets, CGFloat offsetY) {
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:insets margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0 textHorizontalMargin:0 textVerticalMargin:0];
        
        return [self appendImageWithOffset:img1 offsetY:offsetY];
    };
}

/**
 绘制带圆角边框和居中文本的自定义图片 （文本边距、边框以外的边距）
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义图片大小
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion insets  文本内边距 文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion margins  图片外边框边距（始终生效）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移

 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *_Nullable textColor, UIColor *_Nullable fillColor, CGFloat radius, UIEdgeInsets insets, UIEdgeInsets margins, CGFloat offsetY))appendBackgroundMarginsColor {
    
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIEdgeInsets insets, UIEdgeInsets margins, CGFloat offsetY) {
  
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:insets margins:margins strokeColor:nil lineWidth:0 textHorizontalMargin:0 textVerticalMargin:0];
        
        
        return [self appendImageWithOffset:img1 offsetY:offsetY];
    };
}


/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义图片大小
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion imgSize  图片固定宽高（width/height=0 表示该方向自适应）固定宽高(size.width=0/size.height=0表示不固定，文本水平/垂直居中)
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGSize imgSize, CGFloat offsetY))appendBackgroundSize {
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGSize imgSize, CGFloat offsetY) {
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:imgSize textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0 textHorizontalMargin:0 textVerticalMargin:0];
        
        return [self appendImageWithOffset:img1 offsetY:offsetY];
    };
}

/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。定义圆角方向
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion corners  圆角方向组合（如：UIRectCornerTopLeft | UIRectCornerBottomRight）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGFloat offsetY))appendBackgroundCornerColor {
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGFloat offsetY) {
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:corners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0 textHorizontalMargin:0 textVerticalMargin:0];
        
        return [self appendImageWithOffset:img1 offsetY:offsetY];
    };
}

/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。
 若固定宽高被指定，文本严格居中；否则根据内容自适应宽高，并按边距布局。
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion corners  圆角方向组合（如：UIRectCornerTopLeft | UIRectCornerBottomRight）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, CGFloat offsetY))appendBackgroundCornerSize {
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, CGFloat offsetY) {
  
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:corners imgSize:imgSize textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0 textHorizontalMargin:0 textVerticalMargin:0];
        
        return [self appendImageWithOffset:img1 offsetY:offsetY];
    };
}


/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。
 若固定宽高被指定，文本严格居中；否则根据内容自适应宽高，并按边距布局。
 
 @discussion text  需要绘制的文本内容
 @discussion font  文本字体（nil 时使用系统默认）
 @discussion textColor  文本颜色（nil 时默认黑色）
 @discussion fillColor  背景填充色（nil 时透明）
 @discussion radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @discussion corners  圆角方向组合（如：UIRectCornerTopLeft | UIRectCornerBottomRight）
 @discussion imgSize  图片固定宽高（width/height=0 表示该方向自适应）固定宽高(size.width=0/size.height=0表示不固定，文本水平/垂直居中)
 @discussion insets  文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion margins  图片外边框边距（始终生效）
 @discussion strokeColor  边框线颜色（nil 时无边框）
 @discussion lineWidth   边框线宽度（0 时无边框）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移
 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, UIEdgeInsets insets, UIEdgeInsets margins, UIColor *strokeColor, CGFloat lineWidth, CGFloat offsetY))appendBackgroundRadiusColor {
    
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, UIEdgeInsets insets, UIEdgeInsets margins, UIColor *strokeColor, CGFloat lineWidth, CGFloat offsetY) {
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:corners imgSize:imgSize textColor:textColor fillColor:fillColor insets:insets margins:margins strokeColor:strokeColor lineWidth:lineWidth textHorizontalMargin:0 textVerticalMargin:0];
        
        return [self appendImageWithOffset:img1 offsetY:offsetY];
    };
}


/// 辅助方法：追加图片并设置偏移
- (AttributeStringBuilder *)appendImageWithOffset:(UIImage *)image offsetY:(CGFloat)offsetY {
    if (!image) {
        return self;
    }
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, attachment.image.size.width, attachment.image.size.height);
    
    NSMutableAttributedString *attachmentString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    
    // 为附件添加基线偏移属性
    [attachmentString addAttribute:NSBaselineOffsetAttributeName value:@(-offsetY) range:NSMakeRange(0, attachmentString.length)];
    
    [self.source appendAttributedString:attachmentString];
    
    NSRange range = NSMakeRange(self.source.length - attachmentString.length, attachmentString.length);
    self.scr_ranges = @[ [NSValue valueWithRange:range] ];
    
    return self;
}

/**
 绘制带圆角边框和居中文本的自定义图片
 
 @brief 根据参数生成一个带圆角矩形边框的图片，文本内容在图片中自动居中显示。
 若固定宽高被指定，文本严格居中；否则根据内容自适应宽高，并按边距布局。
 
 @Param radius  基础圆角半径（实际生效半径需结合 corners 参数）
 @Param text  需要绘制的文本内容
 @Param font  文本字体（nil 时使用系统默认）
 @Param corners  圆角方向组合（如：UIRectCornerTopLeft | UIRectCornerBottomRight）
 @Param imgSize  图片固定宽高（width/height=0 表示该方向自适应)
 @Param textColor 文本颜色（nil 时默认黑色）
 @Param fillColor 背景填充色（nil 时透明）
 @Param insets  文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @Param margins  图片外边框边距（始终生效）
 @Param strokeColor  边框线颜色（nil 时无边框）
 @Param lineWidth   边框线宽度（0 时无边框）
 @Param textHorizontalMargin 文本左右边距（固定宽高时有效）
 @Param textVerticalMargin 文本上下边距（固定宽高时有效）
 
 @return 渲染完成的 UIImage 对象
 */
- (UIImage*)drawRadius:(CGFloat)radius text:(NSString *)text font:(UIFont *)font corners:(UIRectCorner)corners imgSize:(CGSize)imgSize textColor:(UIColor *)textColor fillColor:(UIColor *)fillColor insets:(UIEdgeInsets)insets margins:(UIEdgeInsets)margins strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth textHorizontalMargin:(CGFloat)textHorizontalMargin textVerticalMargin:(CGFloat)textVerticalMargin {
    
    // 1. 构建富文本属性
    NSString *displayText = text ?: @"";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:displayText];
    if (font) {
        [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrStr.length)];
    }
    if (textColor) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, attrStr.length)];
    }
    
    // 2. 解析圆角方向组合
    CGFloat radiusTopLeft = (corners & UIRectCornerTopLeft) ? radius : 0.0; // 左上角启用圆角
    CGFloat radiusTopRight = (corners & UIRectCornerTopRight) ? radius : 0.0; // 右上角启用圆角
    CGFloat radiusBottomLeft = (corners & UIRectCornerBottomLeft) ? radius : 0.0; // 左下角启用圆角
    CGFloat radiusBottomRight = (corners & UIRectCornerBottomRight) ? radius : 0.0; // 右下角启用圆角
    
    
    // 3. 计算文本绘制区域（考虑边距和边框）
    CGFloat maxStrWidth = imgSize.width - (insets.left + insets.right + lineWidth);
    CGFloat maxStrHeight = imgSize.height - (insets.top + insets.bottom + lineWidth);
    CGSize strSize = [attrStr boundingRectWithSize:CGSizeMake(maxStrWidth > 0 ? maxStrWidth : CGFLOAT_MAX, maxStrHeight > 0 ? maxStrHeight : CGFLOAT_MAX)
                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           context:nil].size;
    
    // 4. 确定最终画布尺寸（优先使用固定宽高，否则根据文本内容自适应）
    CGSize drawSize = imgSize;
    // drawSize = CGSizeMake(drawSize.width > 0 ? drawSize.width : strSize.width + insets.left + insets.right + lineWidth, drawSize.height > 0 ? drawSize.height : strSize.height + insets.top + insets.bottom + lineWidth);
    if (imgSize.width <= 0) {
        drawSize.width = strSize.width + insets.left + insets.right + lineWidth;
    }
    if (imgSize.height <= 0) {
        drawSize.height = strSize.height + insets.top + insets.bottom + lineWidth;
    }
    drawSize.width += margins.left + margins.right;
    drawSize.height += margins.top + margins.bottom;
    
    // 确保尺寸不为零
    drawSize.width = ceil(MAX(1, drawSize.width));
    drawSize.height = ceil(MAX(1, drawSize.height));
    
    // 5. 是否真正需要描边。
    //    注意：CoreGraphics 中 lineWidth = 0 并非“不描边”，而是“画一条设备像素宽的发丝线”，
    //    因此没有边框时必须使用 kCGPathFill，而不是 kCGPathFillStroke。
    BOOL needsStroke = (strokeColor != nil && lineWidth > 0);

    // 6. 计算圆角矩形区域（考虑边框偏移和外边距）
    CGRect rrect = CGRectMake(lineWidth / 2 + margins.left,
                              lineWidth / 2 + margins.top,
                              drawSize.width - lineWidth - margins.left - margins.right,
                              drawSize.height - lineWidth - margins.top - margins.bottom);

    // 圆角半径不能超过短边的一半，否则四段圆弧会互相侵占、路径自交
    CGFloat maxRadius = MIN(CGRectGetWidth(rrect), CGRectGetHeight(rrect)) / 2.0;
    if (maxRadius < 0) {
        maxRadius = 0;
    }
    radiusTopLeft     = MIN(radiusTopLeft, maxRadius);
    radiusTopRight    = MIN(radiusTopRight, maxRadius);
    radiusBottomLeft  = MIN(radiusBottomLeft, maxRadius);
    radiusBottomRight = MIN(radiusBottomRight, maxRadius);

    // 7. 绘制文本区域（固定宽高时严格居中，否则按 insets 布局）
    CGRect textRect;
    if (imgSize.width > 0 && imgSize.height > 0) {
        CGFloat textAreaWidth = drawSize.width - margins.left - margins.right - lineWidth;
        CGFloat textAreaHeight = drawSize.height - margins.top - margins.bottom - lineWidth;

        CGFloat textX = margins.left + (textAreaWidth - strSize.width) / 2 + textHorizontalMargin;
        CGFloat textY = margins.top + (textAreaHeight - strSize.height) / 2 + textVerticalMargin;

        textRect = CGRectMake(textX, textY, strSize.width, strSize.height);
    } else {
        CGFloat textX = insets.left + lineWidth / 2 + margins.left;
        CGFloat textY = insets.top + lineWidth / 2 + margins.top;
        textRect = CGRectMake(textX, textY, strSize.width, strSize.height);
    }

    // 8. 使用 UIGraphicsImageRenderer 渲染。
    //    相比 UIGraphicsBeginImageContextWithOptions（iOS 17 起已废弃），
    //    它自动处理 scale 与色彩空间，且无需手动配对关闭上下文。
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:drawSize
                                                                              format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef ctx = rendererContext.CGContext;

        // 9. 构建四角可独立设置半径的圆角路径。
        //    UIKit 坐标系 y 轴向下：miny 是上边，maxy 是下边。
        CGFloat minx = CGRectGetMinX(rrect);
        CGFloat midx = CGRectGetMidX(rrect);
        CGFloat maxx = CGRectGetMaxX(rrect);
        CGFloat miny = CGRectGetMinY(rrect);
        CGFloat midy = CGRectGetMidY(rrect);
        CGFloat maxy = CGRectGetMaxY(rrect);

        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, minx, midy);
        CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radiusTopLeft);      // 左上角
        CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radiusTopRight);     // 右上角
        CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radiusBottomRight);  // 右下角
        CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radiusBottomLeft);   // 左下角
        CGContextClosePath(ctx);

        // 10. 填充与描边。
        //     直接用 UIColor 的 setFill/setStroke，可正确处理灰度、P3、图案等
        //     任意色彩空间；此前用 getRed:green:blue:alpha: 在这类颜色上会返回
        //     NO 并留下全 0 的分量，导致背景/边框被画成不透明黑色。
        if (fillColor) {
            [fillColor setFill];
        }
        if (needsStroke) {
            [strokeColor setStroke];
            CGContextSetLineWidth(ctx, lineWidth);
            CGContextDrawPath(ctx, kCGPathFillStroke);
        } else {
            CGContextDrawPath(ctx, kCGPathFill);
        }

        // 11. 绘制文本
        [attrStr drawInRect:textRect];
    }];
}



#pragma mark - Glyph

/**
 删除线风格
 
 @discussion NSUnderlineStyleNone 默认值
 @discussion NSUnderlineStyleNone 不设置删除线
 @discussion NSUnderlineStyleSingle 设置删除线为细单实线
 @discussion NSUnderlineStyleThick 设置删除线为粗单实线
 @discussion NSUnderlineStyleDouble 设置删除线为细双实线
 */
- (AttributeStringBuilder *(^)(NSUnderlineStyle))strikethroughStyle {
    return ^(NSUnderlineStyle style) {
        [self addAttribute:NSStrikethroughStyleAttributeName value:@(style)];
        return self;
    };
}

/// 删除线颜色
/// 由于 iOS 的 Bug，删除线在 iOS 10.3 中无法正确显示，需要配合 baseline 使用
/// 具体见：https://stackoverflow.com/questions/43074652/ios-10-3-nsstrikethroughstyleattributename-is-not-rendered-if-applied-to-a-sub
- (AttributeStringBuilder *(^)(UIColor *))strikethroughColor {
    return ^(UIColor *color) {
        [self addAttribute:NSStrikethroughColorAttributeName value:color];
        return self;
    };
}

/**
 下划线风格
 
 @discussion NSUnderlineStyleNone 默认值
 @discussion NSUnderlineStyleNone 不设置删除线
 @discussion NSUnderlineStyleSingle 设置删除线为细单实线
 @discussion NSUnderlineStyleThick 设置删除线为粗单实线
 @discussion NSUnderlineStyleDouble 设置删除线为细双实线
 */
- (AttributeStringBuilder *(^)(NSUnderlineStyle))underlineStyle {
    return ^(NSUnderlineStyle style) {
        [self addAttribute:NSUnderlineStyleAttributeName value:@(style)];
        return self;
    };
}

/// 下划线颜色
- (AttributeStringBuilder *(^)(UIColor *))underlineColor {
    return ^(UIColor * color) {
        [self addAttribute:NSUnderlineColorAttributeName value:color];
        return self;
    };
}

/// 字形边框颜色
/// @discussion 中空文字的颜色
- (AttributeStringBuilder *(^)(UIColor *))strokeColor {
    return ^(UIColor *color) {
        [self addAttribute:NSStrokeColorAttributeName value:color];
        return self;
    };
}

/// 字形边框宽度
/// @discussion 中空的线宽度
- (AttributeStringBuilder *(^)(CGFloat))strokeWidth {
    return ^(CGFloat strokeWidth) {
        [self addAttribute:NSStrokeWidthAttributeName value:@(strokeWidth)];
        return self;
    };
}

/// 设置文本特殊效果
/// @discussion NSTextEffectLetterpressStyle
- (AttributeStringBuilder *(^)(NSString *))textEffect {
    return ^(NSString *textEffect) {
        [self addAttribute:NSTextEffectAttributeName value:textEffect];
        return self;
    };
}

/// 阴影
- (AttributeStringBuilder *(^)(NSShadow *))shadow {
    return ^(NSShadow *shadow) {
        [self addAttribute:NSShadowAttributeName value:shadow];
        return self;
    };
}

/// 链接URL对象 NSURL
- (AttributeStringBuilder *(^)(NSURL *))link {
    return ^(NSURL *url) {
        [self addAttribute:NSLinkAttributeName value:url];
        return self;
    };
}

/// 链接URL 字符串
- (AttributeStringBuilder *(^)(NSString *))linkUrlStr {
    return ^(NSString *linkUrlStr) {
        [self addAttribute:NSLinkAttributeName value:linkUrlStr];
        return self;
    };
}

#pragma mark - Paragraph
/// 行间距
- (AttributeStringBuilder *(^)(CGFloat))lineSpacing {
    return ^(CGFloat lineSpacing) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.lineSpacing = lineSpacing;
        }];
        return self;
    };
}

/// 段间距
- (AttributeStringBuilder *(^)(CGFloat))paragraphSpacing {
    return ^(CGFloat paragraphSpacing) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.paragraphSpacing = paragraphSpacing;
        }];
        return self;
    };
}

/// 对齐
- (AttributeStringBuilder *(^)(NSTextAlignment))alignment {
    return ^(NSTextAlignment alignment) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.alignment = alignment;
        }];
        return self;
    };
}

/// 左对齐（自动扩展到当前 Range 所在的完整段落）
- (AttributeStringBuilder *)alignLeft {
    [self p_applyParagraphStyleToFullParagraphs:^(NSMutableParagraphStyle *paragraphStyle) {
        paragraphStyle.alignment = NSTextAlignmentLeft;
    }];
    return self;
}

/// 右对齐（自动扩展到当前 Range 所在的完整段落）
- (AttributeStringBuilder *)alignRight {
    [self p_applyParagraphStyleToFullParagraphs:^(NSMutableParagraphStyle *paragraphStyle) {
        paragraphStyle.alignment = NSTextAlignmentRight;
    }];
    return self;
}

/// 居中对齐（自动扩展到当前 Range 所在的完整段落）
- (AttributeStringBuilder *)alignCenter {
    [self p_applyParagraphStyleToFullParagraphs:^(NSMutableParagraphStyle *paragraphStyle) {
        paragraphStyle.alignment = NSTextAlignmentCenter;
    }];
    return self;
}

/// 两端对齐（自动扩展到当前 Range 所在的完整段落）
- (AttributeStringBuilder *)alignJustified {
    [self p_applyParagraphStyleToFullParagraphs:^(NSMutableParagraphStyle *paragraphStyle) {
        paragraphStyle.alignment = NSTextAlignmentJustified;
    }];
    return self;
}

/**
 一行内容两段对齐：同一行内前半段靠左、后半段靠右

 通过在该行放置一个右对齐制表位实现：`\t` 之前的内容保持靠左，
 之后的内容（文本或图片附件）被推到 lineWidth 处并右对齐。
 */
- (AttributeStringBuilder *(^)(CGFloat))alignLeftRight {
    return ^(CGFloat lineWidth) {
        [self p_applyParagraphStyleToFullParagraphs:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.alignment = NSTextAlignmentLeft;
            if (lineWidth > 0) {
                paragraphStyle.tabStops = @[ [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentRight
                                                                             location:lineWidth
                                                                              options:@{}] ];
            }
        }];
        return self;
    };
}

/**
 追加「左段 + 右段」一行内容，左段靠左、右段靠右（自动独占一行）

 内部自动拼接 `\t`、末尾换行并应用两段对齐。
 若前一段内容未以换行结尾，会自动补一个换行，保证该行独占一行。
 */
- (AttributeStringBuilder *(^)(NSString *, NSString *, CGFloat, UIFont *))appendLeftRightLine {
    return ^(NSString *leftText, NSString *rightText, CGFloat lineWidth, UIFont *font) {
        NSString *left = leftText ?: @"";
        NSString *right = rightText ?: @"";

        // 确保该行独占一行：若已有内容且未以换行结尾，先补一个换行
        if (self.source.length > 0 && [self.source.string characterAtIndex:self.source.length - 1] != '\n') {
            [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }

        NSMutableString *line = [NSMutableString string];
        [line appendString:left];
        [line appendString:@"\t"];
        [line appendString:right];
        [line appendString:@"\n"];

        NSRange lineRange = NSMakeRange(self.source.length, line.length);
        [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:line]];
        self.scr_ranges = @[ [NSValue valueWithRange:lineRange] ];

        if (font) {
            [self.source addAttribute:NSFontAttributeName value:font range:lineRange];
        }

        // 两段对齐：左对齐 + 行尾右对齐制表位
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        if (lineWidth > 0) {
            paragraphStyle.tabStops = @[ [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentRight
                                                                         location:lineWidth
                                                                          options:@{}] ];
        }
        NSRange paragraphRange = [self.source.string paragraphRangeForRange:lineRange];
        [self.source addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:paragraphRange];
        return self;
    };
}

#pragma mark - 分割线

/**
 追加一行分割线（占一行高度，自动独占一行）

 分割线宽度自动撑满文本行，左右两端分别留出 leftSpacing / rightSpacing 的间距；
 线条粗细与颜色可通过 dividerThickness / dividerColor 配置（作用于最近追加的分割线）。
 */
- (AttributeStringBuilder *(^)(CGFloat, CGFloat))appendDividerLine {
    return ^(CGFloat leftSpacing, CGFloat rightSpacing) {
        // 确保分割线独占一行：若已有内容且未以换行结尾，先补一个换行
        if (self.source.length > 0 && [self.source.string characterAtIndex:self.source.length - 1] != '\n') {
            [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }

        SCDividerLineAttachment *attachment = [[SCDividerLineAttachment alloc] init];
        attachment.leftSpacing = leftSpacing;
        attachment.rightSpacing = rightSpacing;

        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];

        // 记录附件 Range，供 dividerColor / dividerThickness 使用
        NSRange range = NSMakeRange(self.source.length - 1, 1);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];

        // 分割线后的内容另起一行
        [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];

        return self;
    };
}

/// 分割线颜色（作用于最近追加的分割线）
- (AttributeStringBuilder *(^)(UIColor *))dividerColor {
    return ^(UIColor *color) {
        [self p_updateCurrentDividerAttachment:^(SCDividerLineAttachment *divider) {
            divider.lineColor = color;
        }];
        return self;
    };
}

/// 分割线粗细（pt，作用于最近追加的分割线）
- (AttributeStringBuilder *(^)(CGFloat))dividerThickness {
    return ^(CGFloat thickness) {
        [self p_updateCurrentDividerAttachment:^(SCDividerLineAttachment *divider) {
            divider.lineThickness = thickness;
        }];
        return self;
    };
}

/// 换行
- (AttributeStringBuilder *(^)(NSLineBreakMode))lineBreakMode {
    return ^(NSLineBreakMode lineBreakMode) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.lineBreakMode = lineBreakMode;
        }];
        return self;
    };
}

/// 段第一行头部缩进
- (AttributeStringBuilder *(^)(CGFloat))firstLineHeadIndent {
    return ^(CGFloat firstLineHeadIndent) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.firstLineHeadIndent = firstLineHeadIndent;
        }];
        return self;
    };
}


/// 段第一行头部缩进字符数
/// @Discussion headIndentCharacters  缩进字符数
/// @Discussion indentFont  缩进字符的字体大小
- (AttributeStringBuilder *(^)(NSInteger, UIFont *))firstLineHeadIndentCharacters {
    return ^(NSInteger headIndentCharacters, UIFont *headIndentFont) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            CGFloat padding = [self widthForCharacterCount:headIndentCharacters withFont:headIndentFont];
            paragraphStyle.firstLineHeadIndent = padding;
        }];
        return self;
    };
}


/// 段头部缩进  后续行的左边距
- (AttributeStringBuilder *(^)(CGFloat))headIndent {
    return ^(CGFloat headIndent) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.headIndent = headIndent;
        }];
        return self;
    };
}

/// 段头部缩进字符数  后续行的左边距
/// @Discussion headIndentCharacters  缩进字符数
/// @Discussion headIndentFont  缩进字符的字体大小
- (AttributeStringBuilder *(^)(NSInteger, UIFont *))headIndentCharacters {
    return ^(NSInteger headIndentCharacters, UIFont *headIndentFont) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            CGFloat padding = [self widthForCharacterCount:headIndentCharacters withFont:headIndentFont];
            paragraphStyle.headIndent = padding;
        }];
        return self;
    };
}

#pragma mark - get labelSize

/// 段尾部缩进
- (AttributeStringBuilder *(^)(CGFloat))tailIndent {
    return ^(CGFloat tailIndent) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.tailIndent = tailIndent;
        }];
        return self;
    };
}

/// 行高，iOS 的行高会在顶部增加空隙，效果一般不符合 UI 的认知，很少使用
/// 这里为了完全匹配 Sketch 的行高效果，会根据当前字体对 baselineOffset 进行修正
/// 具体见: https://joeshang.github.io/2018/03/29/ios-multiline-text-spacing/
- (AttributeStringBuilder *(^)(CGFloat))lineHeight {
    return ^(CGFloat lineHeight) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *style) {
            style.minimumLineHeight = lineHeight;
            style.maximumLineHeight = lineHeight;
        }];
        for (NSValue *value in self.scr_ranges) {
            NSRange range = [value rangeValue];
            if (![self p_isValidRange:range]) {
                continue;
            }

            NSUInteger index = NSMaxRange(range) - 1;
            UIFont *font = [self.source attribute:NSFontAttributeName atIndex:index effectiveRange:nil];
            if (!font) {
                // 取不到字体时无法计算修正量，跳过即可，
                // 否则会把该区间已有的 baselineOffset 覆盖成 0
                continue;
            }
            CGFloat offset = (lineHeight - font.lineHeight) / 4;
            [self.source addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:range];
        }
        return self;
    };
}

#pragma mark - Special
/// 基线偏移
- (AttributeStringBuilder *(^)(CGFloat))baselineOffset {
    return ^(CGFloat baselineOffset) {
        [self addAttribute:NSBaselineOffsetAttributeName value:@(baselineOffset)];
        return self;
    };
}

/// 连字
- (AttributeStringBuilder *(^)(CGFloat))ligature {
    return ^(CGFloat ligature) {
        [self addAttribute:NSLigatureAttributeName value:@(ligature)];
        return self;
    };
}

/// 字间距
- (AttributeStringBuilder *(^)(CGFloat))kern {
    return ^(CGFloat kern) {
        [self addAttribute:NSKernAttributeName value:@(kern)];
        return self;
    };
}


/// 对已追加的末尾文本动态调整字间距，使其渲染宽度与参考文本对齐
///
/// @discussion 与 appendDynamicFitKern 的区别：
///             - 本方法 **不追加** 新文本，仅修改 builder 当前末尾已存在的文本属性
///             - 适用于先 .append(@"上报人") 再链式调用 .dynamicKern(...) 的场景
///             - 内部固定 suffixLength = 1（排除末尾1个字符），若需其他值请使用 appendDynamicFitKern
///
///             ⚠️ 调用前必须确保 builder 末尾已有文本，否则无效果
///
/// @code
/// AttributeStringBuilder.build(@"")
///     .append(@"道路名称：").font(labelFont)
///     .append(@"\n").font(labelFont)
///     .append(@"上报人").font(labelFont)
///     .dynamicKern(@"道路名称", @"上报人", labelFont);
/// @endcode
///
/// @note 本方法返回一个 Block，该 Block 接受以下三个参数：
///       - referenceText: 参考基准文本，以其渲染宽度作为对齐目标（不含后缀）
///       - fittingText:   用于计算宽度差值的动态文本（应与 builder 末尾文本内容一致）
///       - font:          文本使用的字体（参考文本与动态文本必须使用相同字体）
- (AttributeStringBuilder *(^)(NSString *referenceText, NSString *fittingText, UIFont *font))dynamicKern {
    return ^(NSString *referenceText, NSString *fittingText, UIFont *font) {
        
        // 参数校验
        if (!referenceText || !fittingText || fittingText.length < 2) {
            return self;
        }
        
        // 可调节字符数 = 总长度 - 尾部固定后缀长度(1)
        NSInteger adjustableCount = fittingText.length - 1;
        if (adjustableCount <= 0) {
            return self;
        }
        
        // 计算宽度差值并均摊
        CGFloat referenceWidth = [self textWidth:referenceText font:font];
        CGFloat fittingWidth   = [self textWidth:fittingText font:font];
        CGFloat kernAdjustment = (referenceWidth - fittingWidth) / adjustableCount;
        
        // 对 builder 当前末尾的 fittingText 范围应用字间距
        // addAttribute:value: 应作用于最近一次 append 的文本范围
        [self addAttribute:NSKernAttributeName value:@(kernAdjustment)];
        
        return self;
    };
}



/// 追加动态文本并自动调整字间距，使其渲染宽度与参考文本对齐（固定排除尾部2个字符）
///
/// @discussion 这是 appendDynamicFitKern:suffixLength: 的便捷方法，
///             内部固定 suffixLength = 2，适用于标签后缀为两个字符的场景，如：
///             "道路名称：" ← 参考文本
///             "上报人："   ← 动态文本，末2位"人："不参与间距调整
///
///             ⚠️ 若后缀长度不为2，请使用 appendDynamicFitKern:suffixLength:
///
/// @code
/// AttributeStringBuilder.build(@"")
///     .append(@"道路名称：").font(labelFont)
///     .appendDynamicKern(@"道路名称：", @"上报人：", labelFont)
///     .append(@"\n").font(labelFont);
/// @endcode
///
/// @discussion 本方法返回一个 Block，该 Block 接受以下参数：
/// @discussion  - referenceText: 参考基准文本，以其渲染宽度作为对齐目标（不含后缀）<br/>
/// @discussion  - fittingText:   用于计算宽度差值的动态文本（长度必须 > 2）（应与 builder 末尾文本内容一致）<br/>
/// @discussion  - font:          文本使用的字体（参考文本与动态文本必须使用相同字体）
- (AttributeStringBuilder *(^)(NSString *referenceText, NSString *fittingText, UIFont *font))appendDynamicKern {
    return ^(NSString *referenceText, NSString *fittingText, UIFont *font) {
        
        // 直接委托给通用方法，固定后缀长度为 2
        return self.appendDynamicFitKern(referenceText, fittingText, font, 2);
    };
}



/// 追加动态文本并自动调整字间距，使其渲染宽度与参考文本对齐
///
/// @discussion 核心原理：计算「参考文本」与「动态文本」的宽度差值，
///             将差值均摊到动态文本的可调节字符上（排除尾部固定后缀），
///             通过 NSKernAttributeName 实现视觉上的等宽对齐。
///             适用于标签列对齐场景，如：
///             "道路名称：" ← 参考文本（4字中文+冒号）
///             "上报人："   ← 动态文本（3字中文+冒号），自动撑开至与上方等宽
///
/// @code
/// AttributeStringBuilder.build(@"")
///     .append(@"道路名称：").font(labelFont)
///     .appendDynamicFitKern(@"道路名称：", @"上报人：", labelFont, 1)
///     .append(@"\n").font(labelFont)
///     .appendDynamicFitKern(@"道路名称：", @"审核意见：", labelFont, 1);
/// @endcode
///
/// @note 本方法返回一个 Block，该 Block 接受以下参数：
///       - referenceText: 参考基准文本，以其渲染宽度作为对齐目标（不含后缀）
///       - fittingText:    需要调整字间距的动态文本（长度必须 > 2）（应与 builder 末尾文本内容一致）
///       - font:          文本使用的字体（参考文本与动态文本必须使用相同字体）
///       - suffixLength:          动态文本尾部不参与字间距调整的固定字符数
///                       （通常为冒号、空格等后缀，如 @"：" 传 1）
///                       字间距仅作用于前 (fittingText.length - suffixLength) 个字符
- (AttributeStringBuilder *(^)(NSString *referenceText, NSString *fittingText, UIFont *font, NSInteger suffixLength))appendDynamicFitKern {
    return ^(NSString *referenceText, NSString *fittingText, UIFont *font, NSInteger suffixLength) {
        
        // 参数校验：无效输入直接返回，避免除零或越界
        if (!referenceText || !fittingText || fittingText.length < 2) {
            return self;
        }
        
        // 可调节字间距的字符数 = 总长度 - 尾部固定后缀长度
        NSInteger adjustableCount = fittingText.length - suffixLength;
        if (adjustableCount <= 0) {
            return self;
        }
        
        // 记录动态文本在当前 source 中的范围，用于后续添加属性
        NSRange fittingRange = NSMakeRange(self.source.length, fittingText.length);
        [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:fittingText]];
        self.scr_ranges = @[[NSValue valueWithRange:fittingRange]];
        
        // 计算宽度差值并均摊到可调节字符上
        CGFloat referenceWidth = [self textWidth:referenceText font:font];
        CGFloat fittingWidth   = [self textWidth:fittingText font:font];
        CGFloat kernAdjustment = (referenceWidth - fittingWidth) / adjustableCount;
        
        // 仅对可调节部分应用字间距，保留尾部后缀原始间距
        for (NSValue *rangeValue in self.scr_ranges) {
            NSRange range = [rangeValue rangeValue];
            NSRange kernRange = NSMakeRange(range.location, adjustableCount);
            [self.source addAttribute:NSKernAttributeName value:@(kernAdjustment) range:kernRange];
        }
        
        return self;
    };
}



/// 倾斜
- (AttributeStringBuilder *(^)(CGFloat))obliqueness {
    return ^(CGFloat obliqueness) {
        [self addAttribute:NSObliquenessAttributeName value:@(obliqueness)];
        return self;
    };
}

/// 扩张（压缩文字，正值为伸，负值为缩）
- (AttributeStringBuilder *(^)(CGFloat))expansion {
    return ^(CGFloat expansion) {
        [self addAttribute:NSExpansionAttributeName value:@(expansion)];
        return self;
    };
}


#pragma mark - 点击事件

/// 给当前 Range 注册点击事件（配合普通 UILabel + scr_enableTapOnLabel: 使用）
- (AttributeStringBuilder *(^)(void (^)(void)))tapAction {
    return ^(void (^action)(void)) {
        if (!action) {
            return self;
        }
        
        // 生成唯一 ID，将回调登记到注册表，并把 ID 标记到当前 Range 上
        NSString *tapID = [NSUUID UUID].UUIDString;
        self.scr_tapActions[tapID] = [action copy];
        [self addAttribute:SCRAttributedStringTapIDAttributeName value:tapID];
        return self;
    };
}

#pragma mark - 点击事件（通用 TextKit 命中测试）

///// 通用命中测试：使用标准 TextKit 栈将触摸点映射到字符索引
///// @param point 相对于视图的触摸点
///// @param attributedText 当前显示的富文本
///// @param bounds 视图的内容边界
///// @param lineBreakMode 换行模式（UILabel/UITextView 可能不同）
///// @param maxLines 最大行数（0 表示无限制）
//static NSUInteger scr_characterIndexAtPoint(CGPoint point,
//                                            NSAttributedString *attributedText,
//                                            CGRect bounds,
//                                            NSLineBreakMode lineBreakMode,
//                                            NSUInteger maxLines) {
//    if (!attributedText || attributedText.length == 0 || CGRectIsEmpty(bounds)) {
//        return NSNotFound;
//    }
//    
//    // 1. 构建标准 TextKit 栈（不依赖任何私有 API）
//    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
//    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
//    [textStorage addLayoutManager:layoutManager];
//    
//    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:bounds.size];
//    textContainer.lineFragmentPadding = 0.0; // UILabel/UITextView 默认均为 0
//    textContainer.lineBreakMode = lineBreakMode;
//    if (maxLines > 0) {
//        textContainer.maximumNumberOfLines = maxLines;
//    }
//    [layoutManager addTextContainer:textContainer];
//    
//    // 2. 强制完成排版
//    [layoutManager ensureLayoutForTextContainer:textContainer];
//    
//    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
//    if (glyphRange.length == 0)
//        return NSNotFound;
//    
//    // 3. 查找触摸点对应的 Glyph
//    CGFloat fraction = 0;
//    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point
//                                              inTextContainer:textContainer
//                               fractionOfDistanceThroughGlyph:&fraction];
//    
//    // glyphIndexForPoint 在点超出范围时返回最接近的 glyph，需要二次校验
//    if (glyphIndex >= NSMaxRange(glyphRange))
//        return NSNotFound;
//    
//    // 4. Y 轴校验：确保点确实在该行内（防止点到行间距区域误触发）
//    NSRange lineRange;
//    CGRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex
//                                                      effectiveRange:&lineRange];
//    // 放宽容差 3pt，覆盖行间距和控件内部 padding
//    if (!CGRectContainsPoint(CGRectInset(lineRect, 0, -3.0), point)) {
//        return NSNotFound;
//    }
//    
////    // 5. X 轴校验：确保点在 glyph 的水平范围内
////    CGRect glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
////                                                inTextContainer:textContainer];
////    // 对自定义附件（SCRoundedTagAttachment）和普通文本统一放宽 6pt 容差
////    CGRect expandedGlyphRect = CGRectInset(glyphRect, -6.0, 0);
////    if (!CGRectContainsPoint(expandedGlyphRect, point)) {
////        return NSNotFound;
////    }
////    
////    // 6. 映射到字符索引并校验 TapID
////    NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
////    if (charIndex == NSNotFound || charIndex >= attributedText.length) {
////        return NSNotFound;
////    }
////    
////    NSString *tapID = [attributedText attribute:SCRAttributedStringTapIDAttributeName
////                                        atIndex:charIndex
////                                 effectiveRange:nil];
////    return (tapID.length > 0) ? charIndex : NSNotFound;
//    
//    // 5. 映射到字符索引
//    NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
//    if (charIndex == NSNotFound || charIndex >= attributedText.length) {
//        return NSNotFound;
//    }
//    
//    // 6. 针对自定义附件（U+FFFC）进行精确命中测试
//    unichar c = [attributedText.string characterAtIndex:charIndex];
//    if (c == 0xFFFC) {
//        // ✅ 修复1: id<NSTextAttachment> 必须加 * 表示指针类型
//      NSTextAttachment * attachment = [attributedText attribute:NSAttachmentAttributeName
//                                                            atIndex:charIndex
//                                                     effectiveRange:nil];
//        
//        if ([attachment respondsToSelector:@selector(attachmentBoundsForTextContainer:proposedLineFragment:glyphPosition:characterIndex:)]) {
//            CGRect proposedLineFragment = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex
//                                                                          effectiveRange:nil];
//            
//            // ✅ 修复2: ObjC 中获取 glyph 位置的正确方法是 locationForGlyphAtIndex:
//            CGPoint glyphPosition = [layoutManager locationForGlyphAtIndex:glyphIndex];
//            
//            // 获取附件自己声明的真实渲染边界
//            CGRect realAttachmentBounds = [(id)attachment attachmentBoundsForTextContainer:textContainer
//                                                                      proposedLineFragment:proposedLineFragment
//                                                                             glyphPosition:glyphPosition
//                                                                            characterIndex:charIndex];
//            
//            // 将 attachmentBounds 转换为 TextContainer 坐标系
//            CGRect realRectInContainer = CGRectMake(
//                                                    glyphPosition.x + realAttachmentBounds.origin.x,
//                                                    glyphPosition.y + realAttachmentBounds.origin.y,
//                                                    realAttachmentBounds.size.width,
//                                                    realAttachmentBounds.size.height
//                                                    );
//            
//            // ⚠️ 仅允许 2pt 极小容差，防止误触相邻元素
//            if (!CGRectContainsPoint(CGRectInset(realRectInContainer, -2.0, -2.0), point)) {
//                return NSNotFound;
//            }
//        } else {
//            // 普通系统 NSTextAttachment，使用原有放宽容差
//            CGRect glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
//                                                        inTextContainer:textContainer];
//            if (!CGRectContainsPoint(CGRectInset(glyphRect, -6.0, 0), point)) {
//                return NSNotFound;
//            }
//        }
//    } else {
//        // 7. 普通文本 X 轴校验
//        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
//                                                    inTextContainer:textContainer];
//        if (!CGRectContainsPoint(CGRectInset(glyphRect, -4.0, 0), point)) {
//            return NSNotFound;
//        }
//    }
//    
//    // 8. 最终业务校验
//    NSString *tapID = [attributedText attribute:SCRAttributedStringTapIDAttributeName
//                                        atIndex:charIndex
//                                 effectiveRange:nil];
//    return (tapID.length > 0) ? charIndex : NSNotFound;
//}
//
//static void scr_executeTapAction(NSAttributedString *attributedText, NSUInteger charIndex) {
//    if (!attributedText || charIndex >= attributedText.length)
//        return;
//    
//    NSString *tapID = [attributedText attribute:SCRAttributedStringTapIDAttributeName
//                                        atIndex:charIndex
//                                 effectiveRange:nil];
//    if (tapID.length == 0)
//        return;
//    
//    // ✅ 获取同一 TapID 覆盖的完整文本范围
//    NSRange effectiveRange = NSMakeRange(0, 0);
//    [attributedText attribute:SCRAttributedStringTapIDAttributeName
//                      atIndex:charIndex
//               effectiveRange:&effectiveRange];
//    
//    NSString *clickedText = [attributedText.string substringWithRange:effectiveRange];
//    
//    NSLog(@"[ScrTap] ✅ 点击触发 | range=(%lu,%lu) | tapID=%@ | text='%@'",
//          (unsigned long)effectiveRange.location,
//          (unsigned long)effectiveRange.length,
//          tapID,
//          clickedText);
//    
//    // 执行回调
//    NSDictionary<NSString *, id> *actions = [attributedText attribute:SCRAttributedStringTapActionsAttributeName
//                                                              atIndex:0
//                                                       effectiveRange:nil];
//    if ([actions isKindOfClass:[NSDictionary class]]) {
//        void (^action)(void) = actions[tapID];
//        if (action)
//            action();
//    }
//}
//
//
//#pragma mark - UILabel 支持
//
//+ (void)scr_handleLabelTap:(UITapGestureRecognizer *)gesture {
//    if (gesture.state != UIGestureRecognizerStateRecognized)
//        return;
//    UIView *view = gesture.view;
//    if (![view isKindOfClass:[UILabel class]]) return;
//    UILabel *label = (UILabel *)view;
//    
//    
//    CGPoint point = [gesture locationInView:label];
//    NSUInteger charIndex = scr_characterIndexAtPoint(point,
//                                                     label.attributedText,
//                                                     label.bounds,
//                                                     label.lineBreakMode,
//                                                     (NSUInteger)label.numberOfLines);
//    scr_executeTapAction(label.attributedText, charIndex);
//}
//
//+ (void)scr_enableTapOnLabel:(UILabel *)label {
//    if (!label)
//        return;
//    
//    static char kSCRTapGestureKey;
//    if (objc_getAssociatedObject(label, &kSCRTapGestureKey))
//        return;
//    
//    label.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                          action:@selector(scr_handleLabelTap:)];
//    tap.cancelsTouchesInView = NO;
//    [label addGestureRecognizer:tap];
//    objc_setAssociatedObject(label, &kSCRTapGestureKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//+ (void)scr_handleTapAtPoint:(CGPoint)point onLabel:(UILabel *)label {
//    if (!label)
//        return;
//    NSUInteger charIndex = scr_characterIndexAtPoint(point,
//                                                     label.attributedText,
//                                                     label.bounds,
//                                                     label.lineBreakMode,
//                                                     (NSUInteger)label.numberOfLines);
//    scr_executeTapAction(label.attributedText, charIndex);
//}
//
//#pragma mark - UITextView / UITextField 支持
//
//+ (void)scr_handleTextViewTap:(UITapGestureRecognizer *)gesture {
//    if (gesture.state != UIGestureRecognizerStateRecognized)
//        return;
//    UIView *view = gesture.view;
//    if (![view isKindOfClass:[UITextView class]]) return;
//    UITextView *textView = (UITextView *)view;
//    
//    // UITextView 有 contentInset 和 textContainerInset，需要转换坐标系
//    CGPoint point = [gesture locationInView:textView];
//    point.x -= textView.textContainerInset.left + textView.contentInset.left;
//    point.y -= textView.textContainerInset.top + textView.contentInset.top;
//    
//    NSUInteger charIndex = scr_characterIndexAtPoint(point,
//                                                     textView.attributedText,
//                                                     CGRectMake(0, 0,
//                                                                textView.bounds.size.width - textView.textContainerInset.left - textView.textContainerInset.right,
//                                                                textView.bounds.size.height - textView.textContainerInset.top - textView.textContainerInset.bottom),
//                                                     textView.textContainer.lineBreakMode,
//                                                     0);
//    scr_executeTapAction(textView.attributedText, charIndex);
//}
//
//+ (void)scr_enableTapOnTextView:(UITextView *)textView {
//    if (!textView)
//        return;
//    
//    static char kSCTextViewTapKey;
//    if (objc_getAssociatedObject(textView, &kSCTextViewTapKey))
//        return;
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                          action:@selector(scr_handleTextViewTap:)];
//    tap.cancelsTouchesInView = NO;
//    // 不阻断 UITextView 自身的编辑/选择手势
//    tap.delegate = (id<UIGestureRecognizerDelegate>)self;
//    [textView addGestureRecognizer:tap];
//    objc_setAssociatedObject(textView, &kSCTextViewTapKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//#pragma mark - UIGestureRecognizerDelegate
//
//+ (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//


#pragma mark - Private


/// 计算图片附件相对基线的垂直偏移，使图片与文字视觉居中
/// - Parameters:
///   - imageSize: 图片绘制尺寸
///   - font: 对齐所依据的字体，为 nil 时不偏移
- (CGFloat)p_offsetForImageSize:(CGSize)imageSize font:(UIFont *)font {
    if (!font) {
        return 0;
    }
    return round((font.capHeight - imageSize.height) / 2.0);
}


/// 计算文本宽度
/// - Parameters:
///   - baseText:  基准文本
///   - font: 字体
- (CGFloat)textWidth:(NSString *)text font:(UIFont *)font {
    if (!text || text.length == 0) {
        return 0;
    }
    
    UIFont *actualFont = font ?: [UIFont systemFontOfSize:17];
    NSDictionary *attributes = @{NSFontAttributeName: actualFont};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    return ceil(rect.size.width);
}


/// 计算指定字符数的宽度
- (CGFloat)widthForCharacterCount:(NSInteger)count withFont:(UIFont *)font {
    if (count <= 0) {
        return 0;
    }
    
    NSString *tempStr = [@"" stringByPaddingToLength:count withString:@"字" startingAtIndex:0];
    return [self textWidth:tempStr font:font];
}



- (void)addAttribute:(NSAttributedStringKey)name value:(id)value {
    // value 为 nil 时 NSAttributedString 会抛 NSInvalidArgumentException，这里直接忽略
    if (!name || !value) {
        return;
    }
    
    for (NSValue *rangeValue in self.scr_ranges) {
        NSRange range = [rangeValue rangeValue];
        if ([self p_isValidRange:range]) {
            [self.source addAttribute:name value:value range:range];
        }
    }
}

/// 校验 Range 是否落在当前字符串内（NSNotFound 与越界都视为无效）
- (BOOL)p_isValidRange:(NSRange)range {
    if (range.location == NSNotFound || range.length == 0) {
        return NO;
    }
    // 用无符号运算避免 location + length 溢出后比较失真
    return range.location < self.source.length && range.length <= self.source.length - range.location;
}

/// 配置段落样式
- (void)configParagraphStyle:(void (^)(NSMutableParagraphStyle *style))block {
    if (!block) {
        return;
    }

    for (NSValue *value in self.scr_ranges) {
        NSRange range = [value rangeValue];
        if (![self p_isValidRange:range]) {
            continue;
        }

        NSUInteger index = NSMaxRange(range) - 1;
        
        NSMutableParagraphStyle *paragraphStyle = [[self.source attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:nil] mutableCopy];
        if (!paragraphStyle) {
            paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        }
        block(paragraphStyle);
        [self.source addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }
}

/// 将段落样式配置应用到当前 Range 覆盖的完整段落（含段落分隔符）
/// 供 alignLeft / alignRight / alignCenter / alignJustified / alignLeftRight 使用
- (void)p_applyParagraphStyleToFullParagraphs:(void (^)(NSMutableParagraphStyle *style))block {
    if (!block) {
        return;
    }

    for (NSValue *value in self.scr_ranges) {
        NSRange range = [value rangeValue];
        if (![self p_isValidRange:range]) {
            continue;
        }

        // 扩展到 Range 所在的完整段落（可能跨多个段落）
        NSRange paragraphRange = [self.source.string paragraphRangeForRange:range];
        if (![self p_isValidRange:paragraphRange]) {
            continue;
        }

        NSMutableParagraphStyle *paragraphStyle = [[self.source attribute:NSParagraphStyleAttributeName
                                                                  atIndex:paragraphRange.location
                                                           effectiveRange:nil] mutableCopy];
        if (!paragraphStyle) {
            paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        }
        block(paragraphStyle);
        [self.source addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:paragraphRange];
    }
}

/// 更新当前 Range 内的分割线附件
- (void)p_updateCurrentDividerAttachment:(void (^)(SCDividerLineAttachment *divider))block {
    if (!block) {
        return;
    }
    for (NSValue *value in self.scr_ranges) {
        NSRange range = [value rangeValue];
        // location 为 NSNotFound 或越界时取属性会抛 NSRangeException
        if (![self p_isValidRange:range]) {
            continue;
        }
        id attachment = [self.source attribute:NSAttachmentAttributeName
                                       atIndex:range.location
                                effectiveRange:nil];
        if ([attachment isKindOfClass:[SCDividerLineAttachment class]]) {
            block((SCDividerLineAttachment *)attachment);
        }
    }
}

//
///// 整体行间距  lineSpacing为零，则为默认行间距
//- (AttributeStringBuilder *(^)(CGFloat lineSpacing))lineSpacing {
//    return ^(CGFloat lineSpacing) {
//        [self configParagraph:lineSpacing segmentSpacing:0];
//        return self;
//    };
//}
//
///// 整体段间距  segmentSpacing为零，则为默认段间距
//- (AttributeStringBuilder *(^)(CGFloat segmentSpacing))segmentSpacing {
//    return ^(CGFloat segmentSpacing) {
//        [self configParagraph:0 segmentSpacing:segmentSpacing];
//        return self;
//    };
//}
//
//
//
//- (void)configParagraph:(CGFloat)lineSpacing segmentSpacing:(CGFloat)segmentSpacing {
//
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    if (_sourceLineSpacing != kINVALID_SPACING_VALUE) {
//        [paragraphStyle setLineSpacing:_sourceLineSpacing];
//    }
//    if (_sourceSegmentSpacing != kINVALID_SPACING_VALUE) {
//        [paragraphStyle setParagraphSpacing:_sourceSegmentSpacing];
//    }
//    [_source addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_source length])];
//    return [_source copy];
//}



@end
