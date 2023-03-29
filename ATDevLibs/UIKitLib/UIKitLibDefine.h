//
//  UIKitLibDefine.h
//  Demo
//
//  Created by Mars on 2020/9/23.
//  Copyright © 2020 Mars. All rights reserved.
//

#ifndef UIKitLibDefine_h
#define UIKitLibDefine_h


/**
 Add this macro before each category implementation, so we don't have to use
 -all_load or -force_load to load object files from static libraries that only
 contain categories and no classes.
 More info: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 Example:
     ATSYNTH_DUMMY_CLASS(NSString_YYAdd)
 */
#ifndef ATSYNTH_DUMMY_CLASS
#define ATSYNTH_DUMMY_CLASS(_name_) \
@interface ATSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation ATSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


/**
 Synthsize @implementation范围中的动态对象属性。
 它允许我们向类别中的现有类添加自定义属性。
 
 Synthsize a dynamic object property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
     @interface NSObject (MyAdd)
     @property (nonatomic, retain) UIColor *myColor;
     @end
     
     #import <objc/runtime.h>
     @implementation NSObject (MyAdd)
     ATSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
     @end
 */
#ifndef ATSYNTH_DYNAMIC_PROPERTY_OBJECT
#define ATSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ :(_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif


/**
 Synthsize @implementation作用域中的动态c类型属性。
 它允许我们向类别中的现有类添加自定义属性。
 
 Synthsize a dynamic c type property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
     @interface NSObject (MyAdd)
     @property (nonatomic, retain) CGPoint myPoint;
     @end
     
     #import <objc/runtime.h>
     @implementation NSObject (MyAdd)
     ATSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
     @end
 */
#ifndef ATSYNTH_DYNAMIC_PROPERTY_CTYPE
#define ATSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ :(_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (type)_getter_ { \
    _type_ cValue = { 0 }; \
    NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
    [value getValue:&cValue]; \
    return cValue; \
}
#endif


#endif /* UIKitLibDefine_h */
