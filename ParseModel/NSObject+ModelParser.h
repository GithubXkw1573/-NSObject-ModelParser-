//
//  NSObject+ModelParser.h
//  LoveMusic
//
//  Created by kevin xu on 16/1/8.
//  Copyright © 2016年 kevin xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KWModelParserDelegate <NSObject>

@optional
+ (NSDictionary *)kw_modelDictionary;

@end

@interface NSObject (ModelParser) <KWModelParserDelegate>

/**
 * 通过字典来创建一个模型
 * @param keyValues 字典(可以是NSDictionary、NSString)
 * @return 新建的对象
 */
+ (id)kw_ObjectWithKeyValues:(id)keyValues;

/**
 * 通过字典数组来创建一个模型数组
 * @param array 数组
 * @return 新建的对象数组
 */
+ (NSArray *)kw_ObjectWithKeyValueArray:(NSArray *)array;


@end
