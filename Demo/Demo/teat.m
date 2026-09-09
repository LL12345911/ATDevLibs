//
//  teat.m
//  Demo
//
//  Created by Mars on 2026/9/8.
//

#import "teat.h"
// 运行时验证 AttributeStringBuilder 新功能（在模拟器环境执行）
// 覆盖：段落对齐 / 一行两段对齐 / 图片对齐 / 分割线（含像素级视觉验证）
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AttributeStringBuilder.h"


@implementation teat



static int s_failures = 0;
static void check(BOOL cond, NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    NSString *name = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    if (cond) {
        printf("[PASS] %s\n", name.UTF8String);
    } else {
        printf("[FAIL] %s\n", name.UTF8String);
        s_failures++;
    }
}

// 将富文本在固定宽度容器内排版，返回指定字符的布局矩形
static CGRect rectOfCharIndex(NSAttributedString *attr, NSUInteger charIndex, CGFloat containerWidth) {
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:attr];
    NSLayoutManager *lm = [[NSLayoutManager alloc] init];
    [storage addLayoutManager:lm];
    NSTextContainer *tc = [[NSTextContainer alloc] initWithSize:CGSizeMake(containerWidth, CGFLOAT_MAX)];
    tc.lineFragmentPadding = 0;
    [lm addTextContainer:tc];
    [lm glyphRangeForTextContainer:tc];
    NSRange glyphRange = [lm glyphRangeForCharacterRange:NSMakeRange(charIndex, 1) actualCharacterRange:NULL];
    return [lm boundingRectForGlyphRange:glyphRange inTextContainer:tc];
}

// 将富文本排版并渲染成图片（scale=1），返回指定颜色像素的 x 范围
// 用于像素级验证分割线的左右留白
static void scanColorXRange(NSAttributedString *attr, CGFloat containerWidth, BOOL *found,
                            CGFloat *minX, CGFloat *maxX) {
    *found = NO;
    *minX = CGFLOAT_MAX;
    *maxX = -CGFLOAT_MAX;
    
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:attr];
    NSLayoutManager *lm = [[NSLayoutManager alloc] init];
    [storage addLayoutManager:lm];
    NSTextContainer *tc = [[NSTextContainer alloc] initWithSize:CGSizeMake(containerWidth, 200)];
    tc.lineFragmentPadding = 0;
    [lm addTextContainer:tc];
    NSRange all = [lm glyphRangeForTextContainer:tc];
    
    UIGraphicsImageRendererFormat *fmt = [UIGraphicsImageRendererFormat defaultFormat];
    fmt.scale = 1; // 1 像素 = 1 点，便于断言
    fmt.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(containerWidth, 200)
                                                                               format:fmt];
    UIImage *img = [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [lm drawGlyphsForGlyphRange:all atPoint:CGPointZero];
    }];
    
    CGImageRef cg = img.CGImage;
    CGDataProviderRef provider = CGImageGetDataProvider(cg);
    CFDataRef data = CGDataProviderCopyData(provider);
    const UInt8 *px = CFDataGetBytePtr(data);
    size_t width = CGImageGetWidth(cg);
    size_t height = CGImageGetHeight(cg);
    size_t bpp = CGImageGetBitsPerPixel(cg) / 8;
    size_t bpr = CGImageGetBytesPerRow(cg);
    
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            const UInt8 *p = px + y * bpr + x * bpp;
            UInt8 c0 = p[0], c1 = p[1], c2 = p[2];
            // 蓝色像素：蓝通道显著高于红通道（兼容 BGRA / RGBA 两种字节序）
            if (((c0 > 150 && c2 < 100) || (c2 > 150 && c0 < 100)) && c1 < 100) {
                *found = YES;
                if (x < *minX) *minX = x;
                if (x > *maxX) *maxX = x;
            }
        }
    }
    CFRelease(data);
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        // ---------- 1. 段落对齐 ----------
        {
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"第一行内容\n");
            [[b all] alignCenter];
            NSAttributedString *attr = [b commit];
            NSMutableParagraphStyle *ps = [attr attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
            check(ps.alignment == NSTextAlignmentCenter, @"alignCenter 作用于完整段落");
            NSRange styleRange = NSMakeRange(NSNotFound, 0);
            id styleVal = [attr attribute:NSParagraphStyleAttributeName atIndex:0
                    longestEffectiveRange:&styleRange inRange:NSMakeRange(0, attr.length)];
            check(styleVal != nil && styleRange.location == 0 && styleRange.length == attr.length,
                  @"alignCenter 扩展到完整段落（含换行符，length=%lu）", (unsigned long)styleRange.length);
        }
        {
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"第一行内容\n");
            [[b all] alignRight];
            NSMutableParagraphStyle *ps = [[b commit] attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
            check(ps.alignment == NSTextAlignmentRight, @"alignRight 生效");
        }
        {
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"第一行内容\n");
            [[b all] alignJustified];
            NSMutableParagraphStyle *ps = [[b commit] attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
            check(ps.alignment == NSTextAlignmentJustified, @"alignJustified 生效");
        }
        
        // ---------- 2. 一行两段对齐（文本） ----------
        {
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"");
            b.appendLeftRightLine(@"商品名称", @"¥99.00", 300, [UIFont systemFontOfSize:14]);
            NSAttributedString *attr = [b commit];
            NSString *str = attr.string;
            check([str containsString:@"\t"], @"appendLeftRightLine 自动拼接 \\t");
            check([str hasSuffix:@"\n"], @"appendLeftRightLine 末尾换行");
            NSMutableParagraphStyle *ps = [attr attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
            check(ps.alignment == NSTextAlignmentLeft, @"两段对齐时整段保持左对齐");
            check(ps.tabStops.count == 1 && fabs(ps.tabStops.firstObject.location - 300) < 0.001 &&
                  ps.tabStops.firstObject.alignment == NSTextAlignmentRight, @"右对齐制表位位于 lineWidth 处");
            UIFont *f = [attr attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
            check(f && f.pointSize == 14, @"appendLeftRightLine 应用字体");
            // 排版验证：右段末端应落在制表位 300 附近
            NSString *str2 = attr.string;
            NSUInteger rightStart = [str2 rangeOfString:@"¥"].location;
            CGRect rightRect = rectOfCharIndex(attr, rightStart, 320);
            check(rightRect.origin.x > 200, @"右段文本被推到行尾附近（x=%.1f）", rightRect.origin.x);
        }
        {
            // 手动 \t + alignLeftRight
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"");
            b.append(@"商品名称");
            b.append(@"\t");
            b.append(@"¥99.00");
            b.alignLeftRight(300);
            NSMutableParagraphStyle *ps = [[b commit] attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
            check(ps.tabStops.firstObject.location == 300, @"alignLeftRight 设置制表位");
        }
        
        // ---------- 3. 一行两段对齐（右段为图片） ----------
        {
            UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
            UIImage *img = [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
                [[UIColor redColor] setFill];
                [ctx fillRect:CGRectMake(0, 0, 20, 20)];
            }];
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"");
            b.append(@"左段文字").font([UIFont systemFontOfSize:14]);
            b.append(@"\t");
            b.appendSizeImage(img, CGSizeMake(20, 20)).append(@"右段图片").font([UIFont systemFontOfSize:14]);
            b.alignLeftRight(300);
            NSAttributedString *attr = [b commit];
            NSUInteger imgIdx = [attr.string rangeOfString:@"\uFFFC"].location;
            check(imgIdx != NSNotFound, @"找到右段图片附件");
            CGRect imgRect = rectOfCharIndex(attr, imgIdx, 320);
            check(imgRect.origin.x >= 200, @"右段图片被推到行尾附近（x=%.1f）", imgRect.origin.x);
        }
        
        // ---------- 4. 分割线 ----------
        {
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"标题");
            b.append(@"\n");
            b.appendDividerLine(20, 30);   // 左留白 20、右留白 30
            b.dividerColor([UIColor blueColor]);
            b.dividerThickness(2);
            b.append(@"正文");
            NSAttributedString *attr = [b commit];
            NSUInteger idx = [attr.string rangeOfString:@"\uFFFC"].location;
            check(idx != NSNotFound, @"分割线以附件形式追加");
            check([attr.string characterAtIndex:idx + 1] == '\n', @"分割线后自动换行");
            id attach = [attr attribute:NSAttachmentAttributeName atIndex:idx effectiveRange:NULL];
            check(attach != nil, @"分割线附件存在");
            // 布局验证：附件占满整行（宽 = 容器宽 320）
            CGRect rect = rectOfCharIndex(attr, idx, 320);
            check(fabs(rect.size.width - 320) < 1.0, @"分割线附件占满整行（%.1f）", rect.size.width);
            check(rect.size.width > 0 && rect.size.height > 0, @"分割线有可见布局矩形");
            check(fabs([[attach valueForKey:@"lineThickness"] doubleValue] - 2) < 0.001, @"dividerThickness 生效");
            check([[attach valueForKey:@"lineColor"] isEqual:[UIColor blueColor]], @"dividerColor 生效");
            
            // 像素级验证：蓝色线条应恰好位于 [20, 290]（容器 320 - 左 20 - 右 30）
            BOOL foundBlue = NO;
            CGFloat blueMinX = 0, blueMaxX = 0;
            scanColorXRange(attr, 320, &foundBlue, &blueMinX, &blueMaxX);
            check(foundBlue, @"渲染出蓝色分割线");
            check(foundBlue && fabs(blueMinX - 20) <= 1.5, @"左端留白 20（蓝色起点 x=%.1f）", blueMinX);
            check(foundBlue && fabs(blueMaxX - 290) <= 1.5, @"右端留白 30（蓝色终点 x=%.1f）", blueMaxX);
        }
        {
            // 分割线独占一行：前一段未以换行结尾时自动补换行
            AttributeStringBuilder *b = AttributeStringBuilder.build(@"标题");
            b.appendDividerLine(10, 10);
            NSAttributedString *attr = [b commit];
            NSString *str = attr.string;
            NSUInteger idx = [str rangeOfString:@"\uFFFC"].location;
            check(idx == 3 && [str characterAtIndex:2] == '\n', @"分割线自动独占一行");
        }
        
        printf(s_failures == 0 ? "\nALL TESTS PASSED\n" : "\n%d TEST(S) FAILED\n", s_failures);
        return s_failures == 0 ? 0 : 1;
    }
}


@end
