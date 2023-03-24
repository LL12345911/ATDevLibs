//
//  JMBAttributedStringBuilder.h
//  MyAttributedStringDemo
//
//  Created by oybq on 15/6/18.
//  qq:156355113
//  e-mail:obq0387_cn@sina.com
//  Copyright (c) 2015年 youngsoft. All rights reserved.


/**
 
 MyAttributedStringBuilder *builder = nil;
 
 switch (indexPath.row) {
     case 0:
     {
         builder = [[MyAttributedStringBuilder alloc] initWithString:@"字体设置"];
         builder.firstRange.font = [UIFont systemFontOfSize:40];
         builder.lastRange.font = [UIFont systemFontOfSize:20];
     }
         break;
     case 1:
     {
         builder = [[MyAttributedStringBuilder alloc] initWithString:@"蓝色的背景红色的文字"];
         builder.allRange.backgroundColor = [UIColor blueColor];
         builder.allRange.textColor = [UIColor redColor];
     }
         break;
     case 2:
     {
         builder = [[MyAttributedStringBuilder alloc] initWithString:@"中间的文字中空"];
         [builder range:NSMakeRange(3, 2)].strokeColor = [UIColor greenColor];
         [builder range:NSMakeRange(3, 2)].strokeWidth = 2;

     }
         break;
     case 3:
     {
         builder = [[MyAttributedStringBuilder alloc] initWithString:@"删除线  和 下划线"];
         [builder includeString:@"删除线" all:NO].strikethroughStyle = 1;
         [builder includeString:@"删除线" all:NO].strikethroughColor = [UIColor redColor];
         

         [builder includeString:@"下划线" all:NO].underlineStyle = NSUnderlineStyleSingle;
         [builder includeString:@"下划线" all:NO].underlineColor = [UIColor redColor];

         
     }
         break;
     case 4:
     {
         builder = [[MyAttributedStringBuilder alloc] initWithString:@"我有阴影"];
         
         NSShadow *shadow = [[NSShadow alloc] init];
         shadow.shadowOffset = CGSizeMake(2, 2);
         shadow.shadowColor = [UIColor redColor];
         shadow.shadowBlurRadius = 2;
         
         builder.allRange.shadow = shadow;

     }
         break;
     case 5:
     {
         builder = [[MyAttributedStringBuilder alloc] initWithString:@"我是胖子 和 我是廋子  和  我歪了"];
         [builder includeString:@"我是胖子" all:NO].expansion = 1.1;
         [builder includeString:@"我是廋子" all:NO].expansion = -1.2;
         [builder includeString:@"我歪了" all:NO].obliqueness = 2;
         [[builder includeString:@"我歪了" all:NO] setObliqueness:5];
     }
         break;
     case 6:
     {
         builder = [[MyAttributedStringBuilder alloc] initWithString:@"看我的字间距越来越宽"];
         [builder range:NSMakeRange(0, 2)].kern = -5;
         [builder range:NSMakeRange(2, 4)].kern = 7;
         [builder range:NSMakeRange(6, 3)].kern = 15;
         

     }
         break;
     case 7:
     {
         cell.textLabel.numberOfLines = 0;
         builder = [[AttributedStringBuilder alloc] initWithString:@"第一行\n第二行\n第三行\n"];
         builder.allRange.lineSpacing = 20;

         
     }
         break;
     case 8:
     {
         NSTextAttachment *attach = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
         attach.image = [UIImage imageNamed:@"test"];
         builder = [[AttributedStringBuilder alloc] initWithString:@"文字\uFFFC混合排列"];
         builder.allRange.attachment = attach;
     }
         break;
     case 9:
     {
         builder = [[AttributedStringBuilder alloc] initWithString:@"基线偏移的文字效果"];
         [builder includeString:@"基线偏移" all:NO].baselineOffset = 3;
         [builder includeString:@"效果" all:NO].baselineOffset = -3;
         
     }
         break;
     case 10:
     {
         builder = [[AttributedStringBuilder alloc] initWithString:@"数字123是高亮的，456也是高亮的"];
         [builder characterSet:[NSCharacterSet  decimalDigitCharacterSet]].textColor = [UIColor greenColor];
     }
         break;
     case 11:
     {
         
         builder = [[AttributedStringBuilder alloc] initWithString:@"两只老虎，两只老虎 跑得快，跑得快"];
         [builder includeString:@"老虎" all:YES].textColor = [UIColor greenColor];

     }
         break;
     default:
         break;
 }
 
 cell.textLabel.attributedText = builder.commit;
 
 return cell;
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AttributedStringBuilder;

/**属性字符串区域***/
@interface AttributedStringRange : NSObject

/**
 @brief 字体
 
 @param font 字体
 @discussion 示例：
 @discussion AttributedStringBuilder *builder = nil;
 
 @discussion builder = [[AttributedStringBuilder alloc] initWithString:@"字体设置"];
 @discussion builder.firstRange.font = [UIFont systemFontOfSize:40];
 @discussion builder.lastRange.font = [UIFont systemFontOfSize:20];
 */
-(AttributedStringRange*)setFont:(UIFont*)font;
/**
 @brief 文字颜色
 
 @param color 字体颜色
 @discussion 示例：
 @discussion AttributedStringBuilder *builder = nil;
 
 @discussion builder = [[AttributedStringBuilder alloc] initWithString:@"蓝色的背景红色的文字"];
 @discussion builder.allRange.backgroundColor = [UIColor blueColor];
 @discussion builder.allRange.textColor = [UIColor redColor];
 */
-(AttributedStringRange*)setTextColor:(UIColor*)color;
/**
 @brief 背景色
 
 @param color 字体背景颜色
 @discussion 示例：
 @discussion AttributedStringBuilder *builder = nil;
 
 @discussion builder = [[AttributedStringBuilder alloc] initWithString:@"蓝色的背景红色的文字"];
 @discussion builder.allRange.backgroundColor = [UIColor blueColor];
 @discussion builder.allRange.textColor = [UIColor redColor];
 
 */
-(AttributedStringRange*)setBackgroundColor:(UIColor*)color;
/**
 @brief 段落样式
 
 @param paragraphStyle 段落
 
 @discussion NSMutableParagraphStyle *ps  = [[NSMutableParagraphStyle alloc] init];
 */
-(AttributedStringRange*)setParagraphStyle:(NSParagraphStyle*)paragraphStyle;
/**
 连体字符，好像没有什么作用
 */
-(AttributedStringRange*)setLigature:(BOOL)ligature;
/**
 @brief 字间距
 
 @param kern 字间距
 @discussion 示例：
 @discussion AttributedStringBuilder *builder = nil;
 
 @discussion builder = [[AttributedStringBuilder alloc] initWithString:@"看我的字间距越来越宽"];
 @discussion [builder range:NSMakeRange(0, 2)].kern = -5;
 @discussion [builder range:NSMakeRange(2, 4)].kern = 7;
 @discussion [builder range:NSMakeRange(6, 3)].kern = 15;
 */
-(AttributedStringRange*)setKern:(CGFloat)kern;
/**
 @brief 行间距
 
 @param lineSpacing 字间距
 @discussion 示例：
 @discussion AttributedStringBuilder *builder = nil;
 
 @discussion builder = [[AttributedStringBuilder alloc] initWithString:@"第一行\n第二行\n第三行\n"];
 @discussion builder.allRange.lineSpacing = 20;
 */
-(AttributedStringRange*)setLineSpacing:(CGFloat)lineSpacing;
/**
 @brief 删除线
 
 @param strikethroughStyle 删除线
 @discussion 示例：
 @discussion AttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"删除线  和 下划线"];
 @discussion [builder includeString:@"删除线" all:NO].strikethroughStyle = 1;
 @discussion [builder includeString:@"删除线" all:NO].strikethroughColor = [UIColor redColor];
 @discussion [builder includeString:@"下划线" all:NO].underlineStyle = NSUnderlineStyleSingle;
 @discussion [builder includeString:@"下划线" all:NO].underlineColor = [UIColor redColor];
 */
-(AttributedStringRange*)setStrikethroughStyle:(int)strikethroughStyle;
/**
 @brief 删除线颜色
 
 @param StrikethroughColor 删除线颜色
 @discussion 示例：
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"删除线  和 下划线"];
 @discussion [builder includeString:@"删除线" all:NO].strikethroughStyle = 1;
 @discussion [builder includeString:@"删除线" all:NO].strikethroughColor = [UIColor redColor];
 @discussion [builder includeString:@"下划线" all:NO].underlineStyle = NSUnderlineStyleSingle;
 @discussion [builder includeString:@"下划线" all:NO].underlineColor = [UIColor redColor];
 */
-(AttributedStringRange*)setStrikethroughColor:(UIColor*)StrikethroughColor NS_AVAILABLE_IOS(7_0);
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
-(AttributedStringRange*)setUnderlineStyle:(NSUnderlineStyle)underlineStyle;
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
-(AttributedStringRange*)setUnderlineColor:(UIColor*)underlineColor NS_AVAILABLE_IOS(7_0);
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
-(AttributedStringRange*)setShadow:(NSShadow*)shadow;
/**
 文本效果
 */
-(AttributedStringRange*)setTextEffect:(NSString*)textEffect NS_AVAILABLE_IOS(7_0);
/**
 将区域中的特殊字符: NSAttachmentCharacter,替换为attachement中指定的图片,这个来实现图片混排。
 
 @param attachment 富文本
 
 @discussion “\ufffc” 为对象占位符，目的是当富文本中有图像时，只复制文本信息！！！
 
 @discussion  示例：
 @discussion NSTextAttachment *attach = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
 
 @discussion attach.image = [UIImage imageNamed:@"test"];
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"文字\uFFFC混合排列"];
 @discussion builder.allRange.attachment = attach;
 
 */
-(AttributedStringRange*)setAttachment:(NSTextAttachment*)attachment NS_AVAILABLE_IOS(7_0);
/**
 设置区域内的文字点击后打开的链接
 */
-(AttributedStringRange*)setLink:(NSURL*)url NS_AVAILABLE_IOS(7_0);
/**
 @brief 设置基线的偏移量，正值为往上，负值为往下，可以用于控制UILabel的居顶或者居低显示
 
 @param baselineOffset 设置基线的偏移量，正值为往上，负值为往下，可以用于控制UILabel的居顶或者居低显示
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"基线偏移的文字效果"];
 @discussion [builder includeString:@"基线偏移" all:NO].baselineOffset = 3;
 @discussion [builder includeString:@"效果" all:NO].baselineOffset = -3;
 */
-(AttributedStringRange*)setBaselineOffset:(CGFloat)baselineOffset NS_AVAILABLE_IOS(7_0);
/**
 设置倾斜度
 
 @param obliqueness 倾斜度
 @discussion 示例：
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"我是胖子 和 我是廋子  和  我歪了"];
 @discussion [builder includeString:@"我是胖子" all:NO].expansion = 1.1;
 @discussion [builder includeString:@"我是廋子" all:NO].expansion = -1.2;
 @discussion [builder includeString:@"我歪了" all:NO].obliqueness = 2;
 */
-(AttributedStringRange*)setObliqueness:(CGFloat)obliqueness NS_AVAILABLE_IOS(7_0);
/**
 压缩文字，正值为伸，负值为缩
 
 @param expansion 压缩文字，正值为伸，负值为缩
 @discussion 示例：
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"我是胖子 和 我是廋子  和  我歪了"];
 @discussion [builder includeString:@"我是胖子" all:NO].expansion = 1.1;
 @discussion [builder includeString:@"我是廋子" all:NO].expansion = -1.2;
 @discussion [builder includeString:@"我歪了" all:NO].obliqueness = 2;
 */
-(AttributedStringRange*)setExpansion:(CGFloat)expansion NS_AVAILABLE_IOS(7_0);

/**
 @brief 中空文字的颜色
 
 @param strokeColor 中空文字的颜色
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"中间的文字中空"];
 @discussion [builder range:NSMakeRange(3, 2)].strokeColor = [UIColor greenColor];
 @discussion [builder range:NSMakeRange(3, 2)].strokeWidth = 2;
 */
-(AttributedStringRange*)setStrokeColor:(UIColor*)strokeColor;
/**
 @brief 中空的线宽度
 
 @param strokeWidth 中空的线宽度
 @discussion MyAttributedStringBuilder *builder = nil;
 
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"中间的文字中空"];
 @discussion [builder range:NSMakeRange(3, 2)].strokeColor = [UIColor greenColor];
 @discussion [builder range:NSMakeRange(3, 2)].strokeWidth = 2;
 */
-(AttributedStringRange*)setStrokeWidth:(CGFloat)strokeWidth;

/**
 @brief 可以设置多个属性
 */
-(AttributedStringRange*)setAttributes:(NSDictionary*)dict;

/**
 @brief 得到构建器
 */
-(AttributedStringBuilder*)builder;

@end


/*属性字符串构建器*/
@interface AttributedStringBuilder : NSObject

+(AttributedStringBuilder*)builderWith:(NSString*)string;


-(id)initWithString:(NSString*)string;
/**
 指定区域,如果没有属性串或者字符串为nil则返回nil,下面方法一样。
 */
-(AttributedStringRange*)range:(NSRange)range;
/**
 全部字符
 */
-(AttributedStringRange*)allRange;
/**
 最后一个字符
 */
-(AttributedStringRange*)lastRange;
/**
 最后N个字符
 */
-(AttributedStringRange*)lastNRange:(NSInteger)length;
/**
 第一个字符
 */
-(AttributedStringRange*)firstRange;
/**
 前面N个字符
 */
-(AttributedStringRange*)firstNRange:(NSInteger)length;
/**
 用于选择特殊的字符
 
 @param characterSet 用于选择特殊的字符
 @discussion builder = [[MyAttributedStringBuilder alloc] initWithString:@"数字123是高亮的，456也是高亮的"];
 @discussion [builder characterSet:[NSCharacterSet  decimalDigitCharacterSet]].textColor = [UIColor greenColor];
 */
-(AttributedStringRange*)characterSet:(NSCharacterSet*)characterSet;
/**
 用于选择特殊的字符串
 */
-(AttributedStringRange*)includeString:(NSString*)includeString all:(BOOL)all;
/**
 正则表达式
 */
-(AttributedStringRange*)regularExpression:(NSString*)regularExpression all:(BOOL)all;



/**
 段落处理,以\n结尾为一段，如果没有段落则返回nil
 */
-(AttributedStringRange*)firstParagraph;
/**
 */
-(AttributedStringRange*)nextParagraph;


/**
 插入，如果为0则是头部，如果为-1则是尾部
 */
-(void)insert:(NSInteger)pos attrstring:(NSAttributedString*)attrstring;
-(void)insert:(NSInteger)pos attrBuilder:(AttributedStringBuilder*)attrBuilder;

-(NSAttributedString*)commit;


@end
