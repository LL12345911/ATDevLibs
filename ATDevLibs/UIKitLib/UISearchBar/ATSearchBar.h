//
//  ATSearchBar.h
//  HighwayDoctor
//
//  Created by Mars on 2019/7/1.
//  Copyright © 2019 Mars. All rights reserved.
//

//iOS11.0后搜索框居中显示

// 默认白色背景 5.0f无边框圆角  占位符字体大小15.0f


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATSearchBar : UISearchBar



// searchBar的textField
@property (nonatomic, strong) UITextField *textField;

/**
 清除搜索条以外的控件
 */
- (void)cleanOtherSubViews;

@end

NS_ASSUME_NONNULL_END
