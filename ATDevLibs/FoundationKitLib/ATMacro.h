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
CG_INLINE UIColor* kRGBAColor(NSInteger r,NSInteger g,NSInteger b,float a){
    return [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(r)/255.0 alpha:a];
}
CG_INLINE UIColor* kRandomColor(){
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

#pragma mark -
#pragma mark - 数据验证 是否 为空
//*************数据验证*************//
CG_INLINE BOOL StrValid(NSString *f){
    return (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""]);
}
//字符串是否存在
CG_INLINE BOOL HasString(NSString *allStr,NSString *keyStr){
    return [allStr rangeOfString:keyStr].location != NSNotFound;
}
//判断字符串是否为空
CG_INLINE BOOL kValidStr(NSString *f){
    return (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""]);
}
CG_INLINE NSString* kSafeStr(NSString *f){
    return StrValid(f) ? f : @"";
}
//判断字典是否为空
CG_INLINE BOOL kValidDict(NSDictionary *f){
    return (f!=nil &&[f isKindOfClass:[NSDictionary class]]);
}
CG_INLINE NSDictionary* kIfDictNull(NSDictionary *f){
    return kValidDict(f) ? f : @{};
}
//判断数组是否为空
CG_INLINE BOOL kValidArray(NSArray *f){
    return  (f!=nil &&[f isKindOfClass:[NSArray class]]&&[f count]>0);
}



//判断Number是否为空
CG_INLINE BOOL kValidNum(NSNumber *f){
    return (f!=nil &&[f isKindOfClass:[NSNumber class]]);
}
//判断Data是否为空
CG_INLINE BOOL kValidData(NSData *f){
    return (f!=nil &&[f isKindOfClass:[NSData class]]);
}
//如果 不为空 返回原字符串 为空返回空字符串
CG_INLINE NSString* kIfNull(NSString *f){
    return kValidStr(f) ? f : @"";
}
CG_INLINE NSString* kIfNullStr(NSString *f,NSString *tempStr){
    return kValidStr(f) ? f : tempStr;
}


//CG_INLINE NSString* kIfNullSpace(NSString *f){
//    return kValidStr(f) ? f : @"  ";
//}

//
CG_INLINE NSString* kIfNullForZero(NSString *f){
    return kValidStr(f) ? f : @"0";
}

#define kValidClass(f,cls)   (f!=nil &&[f isKindOfClass:[cls class]])//判断类是否为空
#define IsNilOrNull(_ref)   (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))


/// 字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
/// 数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
/// 字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)
/// 是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))



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
#define WEAK __weak typeof(self) weakSelf = self
//#define Weak(weakSelf) __weak __typeof(&*self) weakSelf = self;
/** 避免self的提前释放 */
#define STRONG __strong typeof(weakSelf) strongSelf = weakSelf

//弱引用/强引用
#define kWeakSelf(type)   __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;



//#define LRWeakSelf(type)  __weak typeof(type) weak##type = type;
//#define LRStrongSelf(type)  __strong typeof(type) type = weak##type;

/**
 是否模拟器
 */
CG_INLINE BOOL isSimulator(){
    return ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location != NSNotFound);
}


/// 显示 错误原因
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


