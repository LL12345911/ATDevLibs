//
//  Wolf_Macro.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/7.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 返回 图片 UIViewContentModeScaleAspectFit 后的size
/// @param Width 图片的真实宽度
/// @param Heigth 图片的真实高度
/// @param boundWidth 图片视图容器的真实宽度
/// @param boundHeight 图片视图容器的真实高度
CG_INLINE CGSize getImageSize(CGFloat Width,CGFloat Heigth,CGFloat boundWidth,CGFloat boundHeight){
    if (Heigth == 0 || Width == 0) {
        return CGSizeMake(boundWidth, boundHeight);
    }else{
        float widthRatio = boundWidth / Width;
        float heightRatio = boundHeight / Heigth;
        float scale = MIN(widthRatio, heightRatio);
        float imageWidth = scale * Width;
        float imageHeight = scale * Heigth;
        return CGSizeMake(imageWidth,imageHeight);
    }
}




#pragma mark -
#pragma mark - 颜色
//*************十六进制颜色*************//  //RGBCOLOR(0x444444)
CG_INLINE UIColor* RGBCOLOR(NSInteger color){
    return [UIColor colorWithRed:(((color)>>16)&0xff)*1.0/255.0 green:(((color)>>8)&0xff)*1.0/255.0 blue:((color)&0xff)*1.0/255.0 alpha:1.0];
}

CG_INLINE UIColor* RGBCOLORAlpha(NSInteger color, CGFloat alpha){
    return [UIColor colorWithRed:(((color)>>16)&0xff)*1.0/255.0 green:(((color)>>8)&0xff)*1.0/255.0 blue:((color)&0xff)*1.0/255.0 alpha:alpha];
}

CG_INLINE UIColor* kRGBAColor(NSInteger r,NSInteger g,NSInteger b,float a){
    return [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(r)/255.0 alpha:a];
}

CG_INLINE UIColor* kRandomColor(void){
    return [UIColor colorWithRed:(arc4random()%256)/255.0 green:(arc4random()%256)/255.0 blue:(arc4random()%256)/255.0 alpha:1];//随机色生成
}
////颜色 色值
//#define kColorBlack         Color333333()//深灰：0x333333
//#define kColorGray          Color999999()//浅灰：0x999999
//#define kColorOrange        RGBCOLOR(0xF29600)//橙色 色值 :0xF29600

#pragma mark -
#pragma mark - 正则匹配用户密码6-18位数字和字母组合

//CG_INLINE BOOL checkPassword(NSString *password){
//    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,18}";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
//    BOOL isMatch = [pred evaluateWithObject:password];
//    return isMatch;
//}



#pragma mark - 字符串验证

/// 判断字符串是否有效（非 nil、类型正确、非空串、非 NSNull）
/// 返回: YES=有效字符串，NO=nil/NSNull/非NSString类型/空字符串@""
CG_INLINE BOOL kValidStr(NSString *f){
    if (f == nil) return NO;
    if ([f isKindOfClass:[NSNull class]]) return NO;
    if (![f isKindOfClass:[NSString class]]) return NO;
    return ![f isEqualToString:@""];
}

/// 判断 allStr 中是否包含 keyStr（大小写敏感）
/// 返回: YES=allStr 中包含 keyStr，NO=不包含/keyStr 未找到/任一参数无效
CG_INLINE BOOL HasString(NSString *allStr, NSString *keyStr){
    if (!kValidStr(allStr) || !kValidStr(keyStr)) return NO;
    return [allStr rangeOfString:keyStr].location != NSNotFound;
}

#pragma mark - 字典验证

/// 判断字典是否有效（非 nil、非 NSNull、类型正确）
/// 返回: YES=有效NSDictionary（含空字典@{}），NO=nil/NSNull/非NSDictionary类型
CG_INLINE BOOL kValidDict(NSDictionary *f){
    if (f == nil) return NO;
    if ([f isKindOfClass:[NSNull class]]) return NO;
    return [f isKindOfClass:[NSDictionary class]];
}

#pragma mark - 数组验证

/// 判断数组是否有效（非 nil、非 NSNull、类型正确、且元素数量 > 0）
/// 返回: YES=有效且非空数组，NO=nil/NSNull/非NSArray类型/count==0
CG_INLINE BOOL kValidArray(NSArray *f){
    if (f == nil) return NO;
    if ([f isKindOfClass:[NSNull class]]) return NO;
    if (![f isKindOfClass:[NSArray class]]) return NO;
    return [f count] > 0;
}

#pragma mark - 数值 & 二进制验证

/// 判断 NSNumber 是否有效（非 nil、非 NSNull、类型正确）
/// 返回: YES=有效NSNumber（含 @0），NO=nil/NSNull/非NSNumber类型
/// 注意: @0 / @NO 视为有效，只有 nil 或类型不匹配才返回 NO
CG_INLINE BOOL kValidNum(NSNumber *f){
    if (f == nil) return NO;
    if ([f isKindOfClass:[NSNull class]]) return NO;
    return [f isKindOfClass:[NSNumber class]];
}

/// 判断 NSData 是否有效（非 nil、非 NSNull、类型正确）
/// 返回: YES=有效NSData（含空data），NO=nil/NSNull/非NSData类型
CG_INLINE BOOL kValidData(NSData *f){
    if (f == nil) return NO;
    if ([f isKindOfClass:[NSNull class]]) return NO;
    return [f isKindOfClass:[NSData class]];
}

#pragma mark - 安全取值 / 默认值

/// 字符串安全取值：有效返回原字符串 f，无效返回空字符串 @""
CG_INLINE NSString* kIfNull(NSString *f){
    return kValidStr(f) ? f : @"";
}

/// 字符串安全取值：有效返回原字符串 f，无效返回指定的默认字符串
/// 返回: 有效时返回 f，无效时返回 tempStr（若 tempStr 本身无效则回退到 @""）
CG_INLINE NSString* kIfNullStr(NSString *f, NSString *tempStr){
    if (kValidStr(f)) return f;
    return kValidStr(tempStr) ? tempStr : @"";
}

/// 字符串安全取值：有效返回原字符串 f，无效返回 @"0"
/// 返回: 有效时返回 f，无效时返回 @"0"
CG_INLINE NSString* kIfNullForZero(NSString *f){
    return kValidStr(f) ? f : @"0";
}

/// 字典安全取值：有效返回原字典 f，无效返回空字典 @{}
/// 返回: 有效时返回 f，无效时返回 @{}
CG_INLINE NSDictionary* kIfDictNull(NSDictionary *f){
    return kValidDict(f) ? f : @{};
}

/// 数组安全取值：有效返回原数组 f，无效返回空数组 @[]
/// 返回: 有效时返回 f，无效时返回 @[]
CG_INLINE NSArray* kSafeArray(NSArray *f){
    return kValidArray(f) ? f : @[];
}

#pragma mark - 宏定义（仅保留必须用宏的场景）

/// 判断对象是否为指定类的实例（需要动态类型参数，无法用内联函数替代）
/// 返回: YES=f 非 nil 且 isKindOfClass:cls 通过，NO=nil 或类型不匹配
#define kValidClass(f, cls)   ((f) != nil && [(f) isKindOfClass:[cls class]])

/// 判断对象是否为 nil 或 NSNull（常用于 JSON 解析后判空）
/// 返回: YES=_ref 为 nil 或等于 [NSNull null]，NO=其他情况
#define IsNilOrNull(_ref)     (((_ref) == nil) || [(_ref) isEqual:[NSNull null]])

/// 字符串是否为空（覆盖 NSNull、nil、非 NSString 类型、长度为 0 四种情况）
/// 返回: YES=空/无效，NO=有内容的字符串
#define kStringIsEmpty(str)   ((str) == nil \
    || [(str) isKindOfClass:[NSNull class]] \
    || ![(str) isKindOfClass:[NSString class]] \
    || [(str) length] < 1 ? YES : NO)

/// 数组是否为空（覆盖 nil、NSNull、非 NSArray 类型、count == 0 四种情况）
/// 返回: YES=空/无效，NO=有元素的数组
#define kArrayIsEmpty(array)  ((array) == nil \
    || [(array) isKindOfClass:[NSNull class]] \
    || ![(array) isKindOfClass:[NSArray class]] \
    || (array).count == 0)

/// 字典是否为空（覆盖 nil、NSNull、非 NSDictionary 类型、无 key 四种情况）
/// 返回: YES=空/无效，NO=有 key-value 的字典
#define kDictIsEmpty(dic)     ((dic) == nil \
    || [(dic) isKindOfClass:[NSNull class]] \
    || ![(dic) isKindOfClass:[NSDictionary class]] \
    || (dic).allKeys.count == 0)

/// 通用对象判空（覆盖 nil、NSNull、length==0、count==0）
/// 返回: YES=空/无效，NO=有内容的对象
/// ✅ 已修复：按类型分路判断，避免 NSDictionary 响应 length 返回 0 导致非空字典被误判为空
#define kObjectIsEmpty(_object) ((_object) == nil \
    || [(_object) isKindOfClass:[NSNull class]] \
    || ([(_object) isKindOfClass:[NSString class]] && [(_object) length] == 0) \
    || ([(_object) isKindOfClass:[NSData class]] && [(_object) length] == 0) \
    || ([(_object) isKindOfClass:[NSArray class]] && [(_object) count] == 0) \
    || ([(_object) isKindOfClass:[NSDictionary class]] && [(_object) count] == 0) \
    || ([(_object) isKindOfClass:[NSSet class]] && [(_object) count] == 0))



////获取一段时间间隔
//
//#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
//
//#define kEndTime NSLog(@"Time: %f",CFAbsoluteTimeGetCurrent()- start)

////由角度转换弧度
//#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
////由弧度转换角度
//#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)
//
///// 判断是否是横屏Judge whether current orientation is landscape.
//CG_INLINE BOOL kIsLandscape(){
//    return (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]));
//}


///*
// block self
// */
//#define ATWeakify(type)      __weak typeof(type) weakSelf = type;
//#define ATStrongify(type)    __strong typeof(type) type = weakSelf;


/** 弱引用 */
#define WEAK __weak typeof(self) weakSelf = self;
//#define Weak(weakSelf) __weak __typeof(&*self) weakSelf = self;
/** 避免self的提前释放 */
#define STRONG __strong typeof(weakSelf) strongSelf = weakSelf;

//弱引用/强引用
#define kWeakSelf(type)   __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;



//#define LRWeakSelf(type)  __weak typeof(type) weak##type = type;
//#define LRStrongSelf(type)  __strong typeof(type) type = weak##type;

/**
 是否模拟器 NS_INLINE
 */
CG_INLINE BOOL isSimulator(void){
    return ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location != NSNotFound);
}


/// 显示 错误原因 NS_INLINE
/// @param error 错误
CG_INLINE NSString* debugReason(NSError * error){
    NSLog(@"🔥🔥🔥🔥🔥  错误代码：%ld  🔥🔥🔥🔥🔥",(long)error.code);
    
    
//    switch (error.code) {
//        case -1://NSURLErrorUnknown
//            errorMesg = @"未知错误";
//            break;
//        case -999://NSURLErrorCancelled
//            errorMesg = @"无效的URL地址";
//            break;
//        case -1000://NSURLErrorBadURL
//            errorMesg = @"无效的URL地址";
//            break;
//        case -1001://NSURLErrorTimedOut
//            errorMesg = @"网络不给力，请稍后再试";
//            break;
//        case -1002://NSURLErrorUnsupportedURL
//            errorMesg = @"不支持的URL地址";
//            break;
//        case -1003://NSURLErrorCannotFindHost
//            errorMesg = @"找不到服务器";
//            break;
//        case -1004://NSURLErrorCannotConnectToHost
//            errorMesg = @"连接不上服务器";
//            break;
//        case -1103://NSURLErrorDataLengthExceedsMaximum
//            errorMesg = @"请求数据长度超出最大限度";
//            break;
//        case -1005://NSURLErrorNetworkConnectionLost
//            errorMesg = @"网络连接异常";
//            break;
//        case -1006://NSURLErrorDNSLookupFailed
//            errorMesg = @"DNS查询失败";
//            break;
//        case -1007://NSURLErrorHTTPTooManyRedirects
//            errorMesg = @"HTTP请求重定向";
//            break;
//        case -1008://NSURLErrorResourceUnavailable
//            errorMesg = @"资源不可用";
//            break;
//        case -1009://NSURLErrorNotConnectedToInternet
//            errorMesg = @"无网络连接";
//            break;
//        case -1010://NSURLErrorRedirectToNonExistentLocation
//            errorMesg = @"重定向到不存在的位置";
//            break;
//        case -1011://NSURLErrorBadServerResponse
//            errorMesg = @"服务器响应异常(服务器内部错误)";
//            break;
//        case -1012://NSURLErrorUserCancelledAuthentication
//            errorMesg = @"用户取消授权";
//            break;
//        case -1013://NSURLErrorUserAuthenticationRequired
//            errorMesg = @"需要用户授权";
//            break;
//        case -1014://NSURLErrorZeroByteResource
//            errorMesg = @"零字节资源";
//            break;
//        case -1015://NSURLErrorCannotDecodeRawData
//            errorMesg = @"无法解码原始数据";
//            break;
//        case -1016://NSURLErrorCannotDecodeContentData
//            errorMesg = @"无法解码内容数据";
//            break;
//        case -1017://NSURLErrorCannotParseResponse
//            errorMesg = @"无法解析响应";
//            break;
//        case -1018://NSURLErrorInternationalRoamingOff
//            errorMesg = @"国际漫游关闭";
//            break;
//        case -1019://NSURLErrorCallIsActive
//            errorMesg = @"被叫激活";
//            break;
//        case -1020://NSURLErrorDataNotAllowed
//            errorMesg = @"数据不被允许";
//            break;
//        case -1021://NSURLErrorRequestBodyStreamExhausted
//            errorMesg = @"请求体";
//            break;
//        case -1100://NSURLErrorFileDoesNotExist
//            errorMesg = @"文件不存在";
//            break;
//        case -1101://NSURLErrorFileIsDirectory
//            errorMesg = @"文件是个目录";
//            break;
//        case -1102://NSURLErrorNoPermissionsToReadFile
//            errorMesg = @"无读取文件权限";
//            break;
//        case -1200://NSURLErrorSecureConnectionFailed
//            errorMesg = @"安全连接失败";
//            break;
//        case -1201://NSURLErrorServerCertificateHasBadDate
//            errorMesg = @"服务器证书失效";
//            break;
//        case -1202://NSURLErrorServerCertificateUntrusted
//            errorMesg = @"不被信任的服务器证书";
//            break;
//        case -1203://NSURLErrorServerCertificateHasUnknownRoot
//            errorMesg = @"未知Root的服务器证书";
//            break;
//        case -1204://NSURLErrorServerCertificateNotYetValid
//            errorMesg = @"服务器证书未生效";
//            break;
//        case -1205://NSURLErrorClientCertificateRejected
//            errorMesg = @"客户端证书被拒";
//            break;
//        case -1206://NSURLErrorClientCertificateRequired
//            errorMesg = @"需要客户端证书";
//            break;
//        case -2000://NSURLErrorCannotLoadFromNetwork
//            errorMesg = @"无法从网络获取";
//            break;
//        case -3000://NSURLErrorCannotCreateFile
//            errorMesg = @"无法创建文件";
//            break;
//        case -3001:// NSURLErrorCannotOpenFile
//            errorMesg = @"无法打开文件";
//            break;
//        case -3002://NSURLErrorCannotCloseFile
//            errorMesg = @"无法关闭文件";
//            break;
//        case -3003://NSURLErrorCannotWriteToFile
//            errorMesg = @"无法写入文件";
//            break;
//        case -3004://NSURLErrorCannotRemoveFile
//            errorMesg = @"无法删除文件";
//            break;
//        case -3005://NSURLErrorCannotMoveFile
//            errorMesg = @"无法移动文件";
//            break;
//        case -3006://NSURLErrorDownloadDecodingFailedMidStream
//            errorMesg = @"下载解码数据失败";
//            break;
//        case -3007://NSURLErrorDownloadDecodingFailedToComplete
//            errorMesg = @"下载解码数据失败";
//            break;
//        default:
//            errorMesg = @"其他未知错误";
//            break;
//    }
   
    // 重点： 根据错误的code码，替换AFN传入的error 中NSLocalizedDescriptionKey键值对，重新组装返回
//    NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc]initWithDictionary:error.userInfo];
//    [errorInfo setObject:errorMesg forKey:NSLocalizedDescriptionKey];
//    NSError *newError = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:errorInfo];
//    return newError;
//    //  失败的请求地址
//    NSLog(@"%@",newError.userInfo[@"NSErrorFailingURLKey"]);
//    // 中文提示语
//    NSLog(@"%@",newError.localizedDescription);
    
    return error.localizedDescription;
}



//NS_ASSUME_NONNULL_BEGIN

@interface ATMacro : NSObject


@end


