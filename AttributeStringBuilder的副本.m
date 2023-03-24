//
//  AttributeStringBuilder.m
//  EngineeringCool
//
//  Created by Mars on 2022/3/28.
//  Copyright © 2022 Mars. All rights reserved.
//

#import "AttributeStringBuilder.h"

#define kINVALID_SPACING_VALUE -1

@interface AttributeStringBuilder ()

@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *attributes;
@property (nonatomic, strong) NSMutableAttributedString *source;
@property (nonatomic, assign) NSUInteger countOfLineBreaks;
@property (nonatomic, assign) CGFloat sourceLineSpacing;
@property (nonatomic, assign) CGFloat sourceSegmentSpacing;
@property (nonatomic, copy) NSAttributedString *imageString;
@property (nonatomic, copy) NSString *current;
@end

@implementation AttributeStringBuilder

#pragma mark - Private
- (instancetype)init {
    if (self = [super init]) {
        self.attributes = [[NSMutableDictionary alloc] init];
        self.source = [[NSMutableAttributedString alloc] init];
        self.countOfLineBreaks = 0;
        self.sourceLineSpacing = kINVALID_SPACING_VALUE;
        self.sourceSegmentSpacing = kINVALID_SPACING_VALUE;
    }
    return self;
}

- (NSMutableParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *style = [self.attributes objectForKey:NSParagraphStyleAttributeName];
    if (!style) {
        style = [[NSMutableParagraphStyle alloc] init];
        [_attributes setObject:style forKey:NSParagraphStyleAttributeName];
    }
    return style;
}

- (NSAttributedString *)attributedString {
    return [[NSAttributedString alloc] initWithString:_current attributes:_attributes];
}

- (void)appendLineBreaks {
    for (int i = 0; i < _countOfLineBreaks; i++) {
        self.current = [_current stringByAppendingString:@"\n"];
    }
}

- (void)clean {
    self.current = nil;
    self.imageString = nil;
    self.countOfLineBreaks = 0;
    [self.attributes removeAllObjects];
}

#pragma mark - 文字样式
- (AttributeStringBuilder * _Nonnull (^)(NSString * _Nonnull))text {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (NSString *attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.current = attribute;
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIFont * _Nonnull))font {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (UIFont *attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attributes setObject:attribute forKey:NSFontAttributeName];
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))skew {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (CGFloat attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attributes setObject:@(attribute) forKey:NSObliquenessAttributeName];
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))color {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (UIColor *attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attributes setObject:attribute forKey:NSForegroundColorAttributeName];
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))mark {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (UIColor *attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attributes setObject:attribute forKey:NSBackgroundColorAttributeName];
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))underscore {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (UIColor *attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [strongSelf.attributes setObject:attribute forKey:NSUnderlineColorAttributeName];
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))strikethrough {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (UIColor *attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attributes setObject:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
        [strongSelf.attributes setObject:attribute forKey:NSStrikethroughColorAttributeName];
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))wordSpacing {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (CGFloat attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.attributes setObject:@(attribute) forKey:NSKernAttributeName];
        return strongSelf;
    };
}

#pragma mark - 图片
- (AttributeStringBuilder * _Nonnull (^)(UIImage * _Nonnull, CGSize, CGFloat))image {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (UIImage *attribute, CGSize size, CGFloat y) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = attribute;
        attachment.bounds = CGRectMake(0, y, size.width, size.height);
        strongSelf.imageString = [NSAttributedString attributedStringWithAttachment:attachment];
        return strongSelf;
    };
}

#pragma mark - 段落样式
- (AttributeStringBuilder * _Nonnull (^)(NSUInteger))wrap {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (NSUInteger attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.countOfLineBreaks = attribute;
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(NSTextAlignment))aligment {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (NSTextAlignment attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf paragraphStyle].alignment = attribute;
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(NSLineBreakMode))breakMode {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (NSLineBreakMode attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf paragraphStyle].lineBreakMode = attribute;
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))lineIndent {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (CGFloat attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf paragraphStyle].firstLineHeadIndent = attribute;
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))lineSpacing {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (CGFloat attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf paragraphStyle].lineSpacing = attribute;
        return strongSelf;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))segmentSpacing {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (CGFloat attribute) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf paragraphStyle].paragraphSpacing = attribute;
        return strongSelf;
    };
}

- (AttributeStringBuilder * (^)(NSString *urlString))link {
    __weak __typeof(self) weakSelf = self;
    return ^AttributeStringBuilder* (NSString *urlString) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSURL * url = [NSURL URLWithString:urlString];
        [strongSelf.attributes setObject:url forKey:NSLinkAttributeName];
        return strongSelf;
    };
}

- (void)setLineSpacing:(CGFloat)spacing {
    self.sourceLineSpacing = spacing;
}

- (void)setSegmentSpacing:(CGFloat)spacing {
    self.sourceSegmentSpacing = spacing;
}

- (void (^)(void))commit {
    return ^void (void) {
        if (self.countOfLineBreaks > 0)
        {
            [self appendLineBreaks];
        }
        if (self.current) {
            NSAttributedString *string = [self attributedString];
            [self.source appendAttributedString:string];
        }
        if (self.imageString) {
            [self.source appendAttributedString:self.imageString];
        }
        [self clean];
    };
}

- (void (^)(void))commitImagePriority {
    return ^void (void) {
        if (self.countOfLineBreaks > 0)
        {
            [self appendLineBreaks];
        }
        if (self.imageString) {
            [self.source appendAttributedString:self.imageString];
        }
        if (self.current) {
            NSAttributedString *string = [self attributedString];
            [self.source appendAttributedString:string];
        }
        [self clean];
    };
}

- (NSAttributedString *)result {
    if (_sourceLineSpacing == kINVALID_SPACING_VALUE && _sourceSegmentSpacing == kINVALID_SPACING_VALUE) {
        return [_source copy];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (_sourceLineSpacing != kINVALID_SPACING_VALUE) {
        [paragraphStyle setLineSpacing:_sourceLineSpacing];
    }
    if (_sourceSegmentSpacing != kINVALID_SPACING_VALUE) {
        [paragraphStyle setParagraphSpacing:_sourceSegmentSpacing];
    }
    [_source addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_source length])];
    return [_source copy];
}

@end
