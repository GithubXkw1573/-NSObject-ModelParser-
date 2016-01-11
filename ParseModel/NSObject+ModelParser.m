//
//  NSObject+ModelParser.m
//  LoveMusic
//
//  Created by kevin xu on 16/1/8.
//  Copyright © 2016年 kevin xu. All rights reserved.

//  封装了一个字典映射model的分类
//  支持基本数据类型（int, float 等）、支持二元数据类型（结构体、CGSize 等）

#import "NSObject+ModelParser.h"
#import  <objc/runtime.h>


@implementation NSObject (ModelParser)


+ (id)kw_ObjectWithKeyValues:(id)keyValues
{
    if ([keyValues isKindOfClass:[NSDictionary class]]) {
        return [self kw_ObjectWithDictionary:keyValues];
    }else{
        return keyValues;
    }
}

+ (NSArray *)kw_ObjectWithKeyValueArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }
    NSMutableArray *modelArray = [NSMutableArray array];
    for(id obj in array){
        [modelArray addObject:[self kw_ObjectWithKeyValues:obj]];
    }
    return modelArray;
}

+ (id)kw_ObjectWithDictionary:(NSDictionary *)dic
{
    if (!dic) {
        return nil;
    }
    
    //通过类创建实例
    NSObject *entity = [[[self class] alloc] init];
    
    //需要递归解析的字典映射
    NSDictionary *parseDic = nil;
    
    Method med = class_getClassMethod(self, @selector(kw_modelDictionary));
    //解析是否实现协议类方法
    if (med) {
        //获取协议的类方法返回值
        parseDic = [self kw_modelDictionary];
        
    }
    
    for(NSString *keyName in [dic allKeys]){
        
        //构建setter方法名
        NSString *setterMethodName = [NSString stringWithFormat:@"set%@:",[self firstUpperString:keyName]];
        
        //通过setter方法名反射setter方法
        SEL propertySelector = NSSelectorFromString(setterMethodName);
        
        if ([[dic objectForKey:keyName] isKindOfClass:[NSDictionary class]]) {
            //如果返回的是一个字典，则继续递归解析
            for (NSString *parseKey in [parseDic allKeys]){
                if ([keyName isEqualToString:parseKey]) {
                    NSString *classString = [parseDic objectForKey:parseKey];
                    Class itemCls = NSClassFromString(classString);
                    //递归解析
                    id modelEntity = [itemCls kw_ObjectWithDictionary:[dic objectForKey:keyName]];
                    if ([entity respondsToSelector:propertySelector]) {
                        //利用runtime给属性复制
                        objc_msgSend(entity,propertySelector, modelEntity);
                    }
                    break;
                }
            }
        }else if ([[dic objectForKey:keyName] isKindOfClass:[NSArray class]]){
            //如果返回的是一个数组，则解析数组
            NSMutableArray *itemList = [NSMutableArray array];
            for(NSString *parseKey in [parseDic allKeys]){
                if ([parseKey isEqualToString:keyName]) {
                    NSString *classString = [parseDic objectForKey:parseKey];
                    Class itemCls = NSClassFromString(classString);
                    for(id obj in [dic objectForKey:keyName]){
                        //递归解析
                        [itemList addObject:[itemCls kw_ObjectWithKeyValues:obj]];
                    }
                    if ([entity respondsToSelector:propertySelector]) {
                        //利用runtime给属性复制
                        objc_msgSend(entity,propertySelector, itemList);
                    }
                }
                break;
            }
            
        }else{
            //普通元素（nsstring, 基本数据类型等）
            if ([entity respondsToSelector:propertySelector]) {
                //给属性复制
                id value = [dic objectForKey:keyName];
                unsigned int count;
                objc_property_t *properties = class_copyPropertyList(self, &count);
                for (NSInteger i=0; i < count; i ++) {
                    objc_property_t property = properties[i];
                    const char *name = property_getName(property);
                    NSString *proName = [[NSString alloc] initWithUTF8String:name];
                    if ([proName isEqualToString:keyName]) {
                        const char *attributes = property_getAttributes(property);
                        char* type = [self typeOfPropertyFromAttributes:attributes];
                        if (1 == strlen(type)){
                            [entity encodeType:type[0] ofPropertySelector:propertySelector value:value];
                        }else{
                            [entity encodePlusType:type ofPropertySelector:propertySelector value:value];
                        }
                        break;
                    }
                    
                }
            }
        }
        
    }
    
    return entity;
}



//根据数据类型，给属性赋值(一元数据类型)
- (void)encodeType:(char)cType ofPropertySelector:(SEL)selector value:(id)value
{
    switch (cType) {
        case Bool:
        {
            BOOL myg = [(NSNumber*)value boolValue];
            objc_msgSend(self,selector, myg);
        }
            break;
            
        case UnsignedShort:
        case UnsignedInt:
        case UnsignedLong:
        case UnsignedLongLong:
        case Short:
        case Long:
        case LongLong:
        {
            long long dd = [(NSNumber*)value longLongValue];
            objc_msgSend(self,selector, dd);
        }
            break;
            
        case Int:
        {
            int bbb = [(NSNumber*)value intValue];
            objc_msgSend(self,selector, bbb);
        }
            break;
            
        case Float:
        {
            float bbb = [(NSNumber*)value floatValue];
#if __LP64__
            objc_msgSend(self,selector, bbb);
#else
            ((void(*)(id, SEL, float))objc_msgSend)(self,selector, bbb);
#endif
        }
            break;
            
        case Double:
        {
            double bbb = [(NSNumber*)value doubleValue];
#if __LP64__
            objc_msgSend(self,selector, bbb);
#else
            ((void(*)(id, SEL, double))objc_msgSend)(self,selector, bbb);
#endif
        }
            break;
            
        case Object:
        {
            objc_msgSend(self,selector, value);
        }
            break;
        default:
            objc_msgSend(self,selector, value);
            break;
    }
}

//根据数据类型，给属性赋值(二元数据类型)
- (void)encodePlusType:(char*)type ofPropertySelector:(SEL)selector value:(id)value
{
    if (!strcmp(type, @encode(CGPoint))){
        CGPoint pointValue = [(NSValue*)value CGPointValue];
        objc_msgSend(self,selector, pointValue);
    }else if (!strcmp(type, @encode(CGSize))){
        CGSize sizeValue = [(NSValue*)value CGSizeValue];
        objc_msgSend(self,selector, sizeValue);
    }else if (!strcmp(type, @encode(CGRect))){
        CGRect rectValue = [(NSValue*)value CGRectValue];
        objc_msgSend(self,selector, rectValue);
    }else if (!strcmp(type, @encode(CGAffineTransform))){
        CGAffineTransform affineValue = [(NSValue*)value CGAffineTransformValue];
        objc_msgSend(self,selector, affineValue);
    }else if (!strcmp(type, @encode(UIEdgeInsets))){
        UIEdgeInsets edgeInsetsValue = [(NSValue*)value UIEdgeInsetsValue];
        objc_msgSend(self,selector, edgeInsetsValue);
    }else if (!strcmp(type, @encode(UIOffset))){
        UIOffset offset = [(NSValue*)value UIOffsetValue];
        objc_msgSend(self,selector, offset);
    }
    else{
        objc_msgSend(self,selector, value);
    }
}

//返回首字母大写
+ (NSString *)firstUpperString:(NSString *)str
{
    if (str && str.length > 0) {
        NSString *firstChar = [str substringToIndex:1];
        return [str stringByReplacingOccurrencesOfString:firstChar withString:[firstChar uppercaseString]];
    }
    
    return @"";
}

//判断属性的数据类型
+ (char*)typeOfPropertyFromAttributes:(const char*)attributes{
    if (!attributes || strlen(attributes) <= 1)
        return 0x00;
    
    char* result = NULL;
    if (!(attributes[1] == '{')){
        result = malloc(sizeof(char) * 2);
        memset(result, 0, 2);
        strncpy(result, attributes + 1, 1);
        return result;
    }
    
    //"{"和"}"之间即为type
    char* start = strstr(attributes, "{");
    
    //找到最后一个"}"
    char* end = start;
    while (true) {
        char* tmp = strstr(end + 1, "}");
        if (!tmp)
            break;
        end = tmp;
    }
    
    NSInteger len = end - start + 1;
    result = malloc(sizeof(char) * (len + 1));
    memset(result, 0, len + 1);
    strncpy(result, start, len);
    return result;
}

@end
