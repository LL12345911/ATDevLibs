//
//  AttributeStringBuilder.m
//  SCRAttributedStringBuilderDemo
//
//  Created by Mars on 2023/3/24.
//  Copyright © 2023 Chuanren Shang. All rights reserved.
//

#import "AttributeStringBuilder.h"
#import <UIKit/UIKit.h>

@interface AttributeStringBuilder ()

@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *attributes;
@property (nonatomic, strong) NSMutableAttributedString *source;
@property (nonatomic, strong) NSArray *scr_ranges;

@end


@implementation AttributeStringBuilder


/// 计算文本高度
/// - Parameters:
///   - attributedString: 富文本
///   - width: 宽度
+ (CGSize)calculateForAttributedString:(NSAttributedString *)attributedString withWidth:(CGFloat)width {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];
    textContainer.lineBreakMode = NSLineBreakByWordWrapping; // Set appropriate line break mode
    
    [layoutManager addTextContainer:textContainer];
    
    // Force layout
    [layoutManager glyphRangeForTextContainer:textContainer];
    // NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect textRect = [layoutManager usedRectForTextContainer:textContainer];
    
    //    CGFloat height = CGRectGetHeight(textRect);
    //    return textRect.size;
    
    //    // 计算宽高
    //    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    //    CGRect boundingRect = [attributedString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    //
    //    // 获取宽高
    //    CGFloat width = CGRectGetWidth(boundingRect);
    //    CGFloat height = CGRectGetHeight(boundingRect);
    //
    //    NSLog(@"宽度: %f, 高度: %f", width, height);
    
    
    return textRect.size;
}

- (instancetype)init {
    if (self = [super init]) {
        self.attributes = [[NSMutableDictionary alloc] init];
        self.source = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (NSAttributedString *)commit {
    return _source;
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
        NSRange range = NSMakeRange(self.source.length, string.length);
        [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

/// 同 append 比，参数是 NSAttributedString
- (AttributeStringBuilder *(^)(NSAttributedString *))attributedAppend {
    return ^(NSAttributedString *attributedString) {
        NSRange range = NSMakeRange(self.source.length, attributedString.string.length);
        [self.source appendAttributedString:attributedString];
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

/// 插入一个新的 Attributed String
- (AttributeStringBuilder *(^)(NSString *, NSUInteger index))insert {
    return ^(NSString *string, NSUInteger index) {
        if (index > self.source.length) {
            return self;
        }
        [self.source insertAttributedString:[[NSAttributedString alloc] initWithString:string]
                                    atIndex:index];
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
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attachment];
        [self.source appendAttributedString:string];
        return self;
    };
}


/// 在尾部追加图片附件，默认使用图片尺寸，图片垂直居中，为了设置处理垂直居中（基于字体的 capHeight），需要在添加图片附件之前设置字体
- (AttributeStringBuilder *(^)(UIImage *))appendImage {
    return ^(UIImage *image) {
        return self.appendSizeImage(image, image.size);
    };
}


/// 在尾部追加图片附件，可以自定义尺寸，默认使用图片前一位的字体进行对齐，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *, CGSize))appendSizeImage {
    return ^(UIImage *image, CGSize imageSize) {
        UIFont *font = [self.source attribute:NSFontAttributeName atIndex:self.source.string.length - 1 effectiveRange:nil];
        return self.appendCustomImage(image, imageSize, font);
    };
}


/// 在尾部追加图片附件，可以自定义想对齐的字体，图片使用自身尺寸，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *, UIFont *))appendFontImage {
    return ^(UIImage *image, UIFont *font) {
        return self.appendCustomImage(image, image.size, font);
    };
}


/// 在尾部追加图片附件，可以自定义尺寸和想对齐的字体，其他同 appendImage
- (AttributeStringBuilder *(^)(UIImage *, CGSize, UIFont *))appendCustomImage {
    return ^(UIImage *image, CGSize imageSize, UIFont *font) {
        CGFloat offset = 0;
        if (font) {
            offset = roundf((font.capHeight - imageSize.height) / 2);
        }
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, offset, imageSize.width, imageSize.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        return self;
    };
}


/// 在 index 位置插入图片附件，由于不确定字体信息，因此需要显式输入字体
- (AttributeStringBuilder *(^)(UIImage *, CGSize, NSUInteger, UIFont *))insertImage {
    return ^(UIImage *image, CGSize imageSize, NSUInteger index, UIFont *font) {
        CGFloat offset = roundf((font.capHeight - imageSize.height) / 2);
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, offset, imageSize.width, imageSize.height);
        [self.source insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]
                                    atIndex:index];
        NSMutableArray *ranges = [NSMutableArray array];
        for (NSInteger i = 0; i < self.scr_ranges.count; i++) {
            NSRange range = [self.scr_ranges[i] rangeValue];
            range.location += 1;
            [ranges addObject:[NSValue valueWithRange:range]];
        }
        self.scr_ranges = [ranges copy];
        return self;
    };
}


/// 同 insertImage 的区别在于，会在当前 Range 的头部插入图片附件，如果没有 Range 则什么也不做
- (AttributeStringBuilder *(^)(UIImage *, CGSize, UIFont *))headInsertImage {
    return ^(UIImage *image, CGSize imageSize, UIFont *font) {
        NSMutableArray *ranges = [NSMutableArray array];
        for (NSInteger index = 0; index < self.scr_ranges.count; index++) {
            NSRange range = [self.scr_ranges[index] rangeValue];
            CGFloat offset = roundf((font.capHeight - imageSize.height) / 2);
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, offset, imageSize.width, imageSize.height);
            [self.source insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]
                                        atIndex:range.location];
            range.location += (index + 1);
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
        if (location < 0 || length <= 0 || location + length > self.source.length) {
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
        if (location < 0 || length <= 0 || self.source.length - location + length > self.source.length) {
            return self;
        }
        NSRange range = NSMakeRange(self.source.length - location, length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

/// 将范围设置为当前字符串全部
- (AttributeStringBuilder *)all {
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

-(NSArray *)searchString:(NSString*)searchString options:(NSStringCompareOptions)options all:(BOOL)all {
    if (self.source == nil) {
        return nil;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:1];
    NSString *str = self.source.string;
    if (!all) {
        NSRange range = [str rangeOfString:searchString options:options];
        if (range.location != NSNotFound) {
            [tempArr addObject:[NSValue valueWithRange:range]];
        }
        
    }else {
        NSRange searchRange = NSMakeRange(0, str.length);
        NSRange range = NSMakeRange(0, 0);
        
        while(range.location != NSNotFound && searchRange.location < str.length) {
            range = [str rangeOfString:searchString options:options range:searchRange];
            
            if (range.location != NSNotFound) {
                [tempArr addObject:[NSValue valueWithRange:range]];
                
                searchRange.location = range.location + range.length;
                searchRange.length = str.length - searchRange.location;
            }
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
        
        NSRange range = NSMakeRange(self.source.length, text.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = img1;
        attachment.bounds = CGRectMake(0, -offsetY, attachment.image.size.width, attachment.image.size.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        return self;
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
 @discussion insets  文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移

 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *_Nullable textColor, UIColor *_Nullable fillColor, CGFloat radius, UIEdgeInsets insets, CGFloat offsetY))appendBackgroundInsetsColor {
    
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIEdgeInsets insets, CGFloat offsetY) {
        
        NSRange range = NSMakeRange(self.source.length, text.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:insets margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = img1;
        attachment.bounds = CGRectMake(0, -offsetY, attachment.image.size.width, attachment.image.size.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        return self;
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
 @discussion insets  文本内边距（固定宽高时水平/垂直方向边距失效）文本边距(设置固定宽size.width之后left/right失效，设置固定高size.height之后top/bottom失效)
 @discussion margins  图片外边框边距（始终生效）
 @discussion offsetY  偏移量 ， offsetY < 0 向上偏移，offsetY > 0  向下偏移，offsetY = 0  不偏移

 */
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *_Nullable textColor, UIColor *_Nullable fillColor, CGFloat radius, UIEdgeInsets insets, UIEdgeInsets margins, CGFloat offsetY))appendBackgroundMarginsColor {
    
    return ^(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIEdgeInsets insets, UIEdgeInsets margins, CGFloat offsetY) {
        
        NSRange range = NSMakeRange(self.source.length, text.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:insets margins:margins strokeColor:nil lineWidth:0];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = img1;
        attachment.bounds = CGRectMake(0, -offsetY, attachment.image.size.width, attachment.image.size.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        return self;
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
        
        NSRange range = NSMakeRange(self.source.length, text.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:UIRectCornerAllCorners imgSize:imgSize textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = img1;
        attachment.bounds = CGRectMake(0, -offsetY, attachment.image.size.width, attachment.image.size.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        return self;
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
        
        NSRange range = NSMakeRange(self.source.length, text.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:corners imgSize:CGSizeMake(0, 0) textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = img1;
        attachment.bounds = CGRectMake(0, -offsetY, attachment.image.size.width, attachment.image.size.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        return self;
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
        
        NSRange range = NSMakeRange(self.source.length, text.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:corners imgSize:imgSize textColor:textColor fillColor:fillColor insets:UIEdgeInsetsMake(0, 0, 0, 0) margins:UIEdgeInsetsMake(0, 0, 0, 0) strokeColor:nil lineWidth:0];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = img1;
        attachment.bounds = CGRectMake(0, -offsetY, attachment.image.size.width, attachment.image.size.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        return self;
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
        
        NSRange range = NSMakeRange(self.source.length, text.length);
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        
        UIImage *img1 = [self drawRadius:radius text:text font:font corners:corners imgSize:imgSize textColor:textColor fillColor:fillColor insets:insets margins:margins strokeColor:strokeColor lineWidth:lineWidth];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = img1;
        attachment.bounds = CGRectMake(0, -offsetY, attachment.image.size.width, attachment.image.size.height);
        [self.source appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        return self;
    };
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
 
 @return 渲染完成的 UIImage 对象
 */
- (UIImage*)drawRadius:(CGFloat)radius text:(NSString *)text font:(UIFont *)font corners:(UIRectCorner)corners imgSize:(CGSize)imgSize textColor:(UIColor *)textColor fillColor:(UIColor *)fillColor insets:(UIEdgeInsets)insets margins:(UIEdgeInsets)margins strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth {
    
    // 1. 构建富文本属性
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    if (font) {
        [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
    }
    if (textColor) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, text.length)];
    }
    
    // 2. 解析圆角方向组合
    CGFloat radiusTopLeft = 0.0;
    CGFloat radiusTopRight = 0.0;
    CGFloat radiusBottomLeft = 0.0;
    CGFloat radiusBottomRight = 0.0;
    
    if ((corners & UIRectCornerTopLeft) > 0) {
        radiusTopLeft = radius; // 左上角启用圆角
    }
    if ((corners & UIRectCornerTopRight) > 0) {
        radiusTopRight = radius; // 右上角启用圆角
    }
    if ((corners & UIRectCornerBottomLeft) > 0) {
        radiusBottomLeft = radius; // 左下角启用圆角
    }
    if ((corners & UIRectCornerBottomRight) > 0) {
        radiusBottomRight = radius; // 右下角启用圆角
    }
    
    // 3. 计算文本绘制区域（考虑边距和边框）
    CGFloat maxStrWidth = imgSize.width - (insets.left + insets.right + lineWidth);
    CGFloat maxStrHeight = imgSize.height - (insets.top + insets.bottom + lineWidth);
    CGSize strSize = [attrStr boundingRectWithSize:CGSizeMake(maxStrWidth > 0 ? maxStrWidth : CGFLOAT_MAX, maxStrHeight > 0 ? maxStrHeight : CGFLOAT_MAX)
                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           context:nil].size;
    
    // 4. 确定最终画布尺寸（优先使用固定宽高，否则根据文本内容自适应）
    CGSize drawSize = imgSize;
    drawSize = CGSizeMake(drawSize.width > 0 ? drawSize.width : strSize.width + insets.left + insets.right + lineWidth,
                          drawSize.height > 0 ? drawSize.height : strSize.height + insets.top + insets.bottom + lineWidth);
    
    drawSize = CGSizeMake(drawSize.width + margins.left + margins.right,
                          drawSize.height + margins.top + margins.bottom);
    
    // 5. 开启图像上下文
    UIGraphicsBeginImageContextWithOptions(drawSize, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 6. 定义圆角路径绘制闭包
    void (^drawBlock)(CGRect rrect,
                      CGFloat radiusTopLeft,
                      CGFloat radiusTopRight,
                      CGFloat radiusBottomLeft,
                      CGFloat radiusBottomRight) = ^(CGRect rrect,
                                                     CGFloat radiusTopLeft,
                                                     CGFloat radiusTopRight,
                                                     CGFloat radiusBottomLeft,
                                                     CGFloat radiusBottomRight){
                          CGFloat
                          minx = CGRectGetMinX(rrect),
                          midx = CGRectGetMidX(rrect),
                          maxx = CGRectGetMaxX(rrect);
                          CGFloat
                          miny = CGRectGetMinY(rrect),
                          midy = CGRectGetMidY(rrect),
                          maxy = CGRectGetMaxY(rrect);
                          CGContextMoveToPoint(ctx, minx, midy);
                          CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radiusTopLeft);
                          CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radiusTopRight);
                          CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radiusBottomLeft);
                          CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radiusBottomRight);
                          CGContextClosePath(ctx);
                          CGContextDrawPath(ctx, kCGPathFillStroke);
                      };
    
    // 7. 配置描边与填充色
    CGFloat r = 0, g, b, a;
    if (strokeColor && lineWidth > 0) {
        [strokeColor getRed:&r green:&g blue:&b alpha:&a];
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextSetRGBStrokeColor(ctx, r, g, b, a); // 有效描边
    } else {
        CGContextSetLineWidth(ctx, 0); // 禁用描边
       //CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0);
    }
    
    if (fillColor) {
        [fillColor getRed:&r green:&g blue:&b alpha:&a];
        CGContextSetRGBFillColor(ctx, r, g, b, a); // 背景填充
    } else {
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0); // 透明背景
    }
    
    // 8. 计算圆角矩形区域（考虑边框偏移和外边距）
    CGRect rrect = CGRectMake(lineWidth / 2 + margins.left,
                              lineWidth / 2 + margins.top,
                              drawSize.width - lineWidth - margins.left - margins.right,
                              drawSize.height - lineWidth - margins.top - margins.bottom);
    
    // 9. 绘制圆角矩形路径
    drawBlock(rrect,
              radiusTopLeft,
              radiusTopRight,
              radiusBottomLeft,
              radiusBottomRight);
    
    // 10. 绘制文本（根据是否固定宽高决定居中方式）
    [attrStr drawInRect:CGRectMake(imgSize.width > 0 ? drawSize.width / 2 - strSize.width / 2 : insets.left + lineWidth / 2 + margins.left,imgSize.height > 0 ? drawSize.height / 2 - strSize.height / 2 : insets.top + lineWidth / 2 + margins.top, strSize.width, strSize.height)];
    
    // 11. 生成图像并关闭上下文
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
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
            NSString *tempStr = @"";
            for (int i = 0; i < headIndentCharacters; i++) {
                tempStr = [NSString stringWithFormat:@"%@字", tempStr];
            }
            CGSize size = [self string:tempStr sizeWithFont:headIndentFont MaxSize:CGSizeMake(10000, 10000)];
            CGFloat padding = size.width;
            
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
            NSString *tempStr = @"";
            for (int i = 0; i < headIndentCharacters; i++) {
                tempStr = [NSString stringWithFormat:@"%@字", tempStr];
            }
            CGSize size = [self string:tempStr sizeWithFont:headIndentFont MaxSize:CGSizeMake(10000, 10000)];
            CGFloat padding = size.width;
            
            paragraphStyle.headIndent = padding;
        }];
        return self;
    };
}

#pragma mark - get labelSize
- (CGSize)string:(NSString *)str sizeWithFont:(UIFont *)font MaxSize:(CGSize)maxSize {
    @autoreleasepool {
        CGSize resultSize;
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        CGRect rect = [str boundingRectWithSize:maxSize
                                        options:(NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading)
                                     attributes:attrs
                                        context:nil];
        resultSize = rect.size;
        resultSize = CGSizeMake(ceil(resultSize.width), ceil(resultSize.height));
        
        return resultSize;
    }
}


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
            CGFloat offset = 0;
            NSRange range = [value rangeValue];
            NSInteger index = range.location + range.length - 1;
            UIFont *font = [self.source attribute:NSFontAttributeName atIndex:index effectiveRange:nil];
            if (font) {
                offset = (lineHeight - font.lineHeight) / 4;
            }
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

/// 动态添加字间距
/// @Discussion baseText  基准文本 ,   @"道路路路名名称"
/// @Discussion dynamicText  动态文本 , @"上报人“
/// @Discussion font 字体
/// @code
///  AttributeStringBuilder *build = AttributeStringBuilder.build(@"NSBackgroundColorAttributeName 圆角")
///  .append(@"\n").font([UIFont systemFontOfSize:14])
///  .append(@"道路路路名名称：").font([UIFont systemFontOfSize:14])
///  .append(@"\n").font([UIFont systemFontOfSize:14])
///  .append(@"上报人").font([UIFont systemFontOfSize:14]).dynamicKern(@"道路路路名名称", @"上报人", [UIFont systemFontOfSize:14])
- (AttributeStringBuilder *(^)(NSString *baseText, NSString *dynamicText, UIFont *font))dynamicKern {
    return ^(NSString *baseText, NSString *dynamicText, UIFont *font) {
        // 计算基准文本的宽度
        CGFloat baseTextWidth = [self generateAttributedString:baseText font:font];
        
        // 计算动态文本的宽度并调整字间距
        CGFloat dynamicTextWidth = [self generateAttributedString:dynamicText font:font];
        
        if (dynamicText.length < 2) {
            return self;
        }
        CGFloat kerningAdjustment = (baseTextWidth - dynamicTextWidth) / (dynamicText.length - 1);
        
        // 调整动态文本的字间距
        [self addAttribute:NSKernAttributeName value:@(kerningAdjustment)];
        
        return self;
    };
}

/// 添加文字并设置字间距
/// @Discussion baseText  基准文本 ,   @"道路路路名名称："
/// @Discussion dynamicText  动态文本 , @"上报人：“
/// @Discussion font 字体
/// @code
///  AttributeStringBuilder *build = AttributeStringBuilder.build(@"NSBackgroundColorAttributeName 圆角")
///  .append(@"\n").font([UIFont systemFontOfSize:14])
///  .append(@"道路路路名名称：").font([UIFont systemFontOfSize:14])
///  .append(@"\n").font([UIFont systemFontOfSize:14])
///  .append(@"上报人").font([UIFont systemFontOfSize:14]).dynamicKern(@"道路路路名名称", @"上报人", [UIFont systemFontOfSize:14])
///  .append(@"\n").font([UIFont systemFontOfSize:14])
///  .appendDynamicKern(@"道路路路名名称：", @"上报人：", [UIFont systemFontOfSize:14]).font([UIFont systemFontOfSize:14])
///  .append(@"\n").font([UIFont systemFontOfSize:14])
- (AttributeStringBuilder *(^)(NSString *baseText, NSString *dynamicText, UIFont *font))appendDynamicKern {
    return ^(NSString *baseText, NSString *dynamicText, UIFont *font) {
        
        /// 尾部追加一个新的 Attributed String
        NSRange range = NSMakeRange(self.source.length, dynamicText.length);
        [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:dynamicText]];
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        
        // 计算基准文本的宽度
        CGFloat baseTextWidth = [self generateAttributedString:baseText font:font];
        
        // 计算动态文本的宽度并调整字间距
        CGFloat dynamicTextWidth = [self generateAttributedString:dynamicText font:font];
        
        if (dynamicText.length <= 2) {
            return self;
        }
        CGFloat kerningAdjustment = (baseTextWidth - dynamicTextWidth) / (dynamicText.length - 2);
        
        // 调整动态文本的字间距
        for (NSValue *rangeValue in self.scr_ranges) {
            NSRange range = [rangeValue rangeValue];
            [self.source addAttribute:NSKernAttributeName value:@(kerningAdjustment) range:NSMakeRange(range.location, range.length-2)];
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

#pragma mark - Private


/// 返回 富文本宽度
/// - Parameters:
///   - baseText:  基准文本
///   - font: 字体
- (CGFloat)generateAttributedString:(NSString *)baseText font:(UIFont *)font {
    NSMutableAttributedString *baseAttributedString = [[NSMutableAttributedString alloc] initWithString:baseText];
    [baseAttributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, baseText.length)];
    
    // 计算基准文本的宽度
    CGRect baseTextRect = [baseText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    CGFloat baseTextWidth = baseTextRect.size.width;
    return baseTextWidth;
    
}

- (void)addAttribute:(NSAttributedStringKey)name value:(id)value {
    for (NSValue *rangeValue in self.scr_ranges) {
        NSRange range = [rangeValue rangeValue];
        [self.source addAttribute:name value:value range:range];
    }
}

- (void)configParagraphStyle:(void (^)(NSMutableParagraphStyle *style))block {
    for (NSValue *value in self.scr_ranges) {
        NSRange range = [value rangeValue];
        NSInteger index = range.location + range.length - 1;
        NSMutableParagraphStyle *paragraphStyle = [[self.source attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:nil] mutableCopy];
        if (!paragraphStyle) {
            paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        }
        block(paragraphStyle);
        [self.source addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
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
