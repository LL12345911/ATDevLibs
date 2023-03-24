//
//  AttributeStringBuilder.m
//  SCRAttributedStringBuilderDemo
//
//  Created by Mars on 2023/3/24.
//  Copyright © 2023 Chuanren Shang. All rights reserved.
//

#import "AttributeStringBuilder.h"

@interface AttributeStringBuilder ()

@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *attributes;
@property (nonatomic, strong) NSMutableAttributedString *source;
@property (nonatomic, strong) NSArray *scr_ranges;

@end


@implementation AttributeStringBuilder

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


#pragma mark - Content

+ (AttributeStringBuilder *(^)(NSString *))build {
    return ^(NSString *string) {
        NSRange range = NSMakeRange(0, string.length);
        AttributeStringBuilder *builder = [[AttributeStringBuilder alloc] init];// initWithString:string];
        [builder.source appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        
        builder.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return builder;
    };
}

- (AttributeStringBuilder *(^)(NSString *))append {
    return ^(NSString *string) {
        NSRange range = NSMakeRange(self.source.length, string.length);
        [self.source appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

- (AttributeStringBuilder *(^)(NSAttributedString *))attributedAppend {
    return ^(NSAttributedString *attributedString) {
        NSRange range = NSMakeRange(self.source.length, attributedString.string.length);
        [self.source appendAttributedString:attributedString];
        self.scr_ranges = @[ [NSValue valueWithRange:range] ];
        return self;
    };
}

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

- (AttributeStringBuilder *(^)(NSTextAttachment *))appendAttachment {
    return ^(NSTextAttachment *attachment) {
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attachment];
        [self.source appendAttributedString:string];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIImage *))appendImage {
    return ^(UIImage *image) {
        return self.appendSizeImage(image, image.size);
    };
}

- (AttributeStringBuilder *(^)(UIImage *, CGSize))appendSizeImage {
    return ^(UIImage *image, CGSize imageSize) {
        UIFont *font = [self.source attribute:NSFontAttributeName atIndex:self.source.string.length - 1 effectiveRange:nil];
        return self.appendCustomImage(image, imageSize, font);
    };
}

- (AttributeStringBuilder *(^)(UIImage *, UIFont *))appendFontImage {
    return ^(UIImage *image, UIFont *font) {
        return self.appendCustomImage(image, image.size, font);
    };
}

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

- (AttributeStringBuilder *)all {
    NSRange range = NSMakeRange(0, self.source.length);
    self.scr_ranges = @[ [NSValue valueWithRange:range] ];
    return self;
}

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

#pragma mark - Basic

- (AttributeStringBuilder *(^)(UIFont *))font {
    return ^(UIFont *font) {
        [self addAttribute:NSFontAttributeName value:font];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))fontSize {
    return ^(CGFloat fontSize) {
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        [self addAttribute:NSFontAttributeName value:font];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIColor *))color {
    return ^(UIColor *color) {
        [self addAttribute:NSForegroundColorAttributeName value:color];
        return self;
    };
}

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

- (AttributeStringBuilder *(^)(UIColor *))backgroundColor {
    return ^(UIColor *color) {
        [self addAttribute:NSBackgroundColorAttributeName value:color];
        return self;
    };
}

#pragma mark - Glyph

- (AttributeStringBuilder *(^)(NSUnderlineStyle))strikethroughStyle {
    return ^(NSUnderlineStyle style) {
        [self addAttribute:NSStrikethroughStyleAttributeName value:@(style)];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIColor *))strikethroughColor {
    return ^(UIColor *color) {
        [self addAttribute:NSStrikethroughColorAttributeName value:color];
        return self;
    };
}

- (AttributeStringBuilder *(^)(NSUnderlineStyle))underlineStyle {
    return ^(NSUnderlineStyle style) {
        [self addAttribute:NSUnderlineStyleAttributeName value:@(style)];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIColor *))underlineColor {
    return ^(UIColor * color) {
        [self addAttribute:NSUnderlineColorAttributeName value:color];
        return self;
    };
}

- (AttributeStringBuilder *(^)(UIColor *))strokeColor {
    return ^(UIColor *color) {
        [self addAttribute:NSStrokeColorAttributeName value:color];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))strokeWidth {
    return ^(CGFloat strokeWidth) {
        [self addAttribute:NSStrokeWidthAttributeName value:@(strokeWidth)];
        return self;
    };
}

- (AttributeStringBuilder *(^)(NSShadow *))shadow {
    return ^(NSShadow *shadow) {
        [self addAttribute:NSShadowAttributeName value:shadow];
        return self;
    };
}

- (AttributeStringBuilder *(^)(NSString *))textEffect {
    return ^(NSString *textEffect) {
        [self addAttribute:NSTextEffectAttributeName value:textEffect];
        return self;
    };
}

- (AttributeStringBuilder *(^)(NSURL *))link {
    return ^(NSURL *url) {
        [self addAttribute:NSLinkAttributeName value:url];
        return self;
    };
}

#pragma mark - Paragraph

- (AttributeStringBuilder *(^)(CGFloat))lineSpacing {
    return ^(CGFloat lineSpacing) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.lineSpacing = lineSpacing;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))paragraphSpacing {
    return ^(CGFloat paragraphSpacing) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.paragraphSpacing = paragraphSpacing;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(NSTextAlignment))alignment {
    return ^(NSTextAlignment alignment) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.alignment = alignment;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(NSLineBreakMode))lineBreakMode {
    return ^(NSLineBreakMode lineBreakMode) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.lineBreakMode = lineBreakMode;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))firstLineHeadIndent {
    return ^(CGFloat firstLineHeadIndent) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.firstLineHeadIndent = firstLineHeadIndent;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))headIndent {
    return ^(CGFloat headIndent) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.headIndent = headIndent;
        }];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))tailIndent {
    return ^(CGFloat tailIndent) {
        [self configParagraphStyle:^(NSMutableParagraphStyle *paragraphStyle) {
            paragraphStyle.tailIndent = tailIndent;
        }];
        return self;
    };
}

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

- (AttributeStringBuilder *(^)(CGFloat))baselineOffset {
    return ^(CGFloat baselineOffset) {
        [self addAttribute:NSBaselineOffsetAttributeName value:@(baselineOffset)];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))ligature {
    return ^(CGFloat ligature) {
        [self addAttribute:NSLigatureAttributeName value:@(ligature)];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))kern {
    return ^(CGFloat kern) {
        [self addAttribute:NSKernAttributeName value:@(kern)];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))obliqueness {
    return ^(CGFloat obliqueness) {
        [self addAttribute:NSObliquenessAttributeName value:@(obliqueness)];
        return self;
    };
}

- (AttributeStringBuilder *(^)(CGFloat))expansion {
    return ^(CGFloat expansion) {
        [self addAttribute:NSExpansionAttributeName value:@(expansion)];
        return self;
    };
}

#pragma mark - Private

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
