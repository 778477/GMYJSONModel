//
//  NSObject+GMYJSONModel.h
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2017/11/2.
//  Copyright © 2017年 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 自动对象属性值
 */
@interface NSObject (GMYJSONModel)
#pragma mark- 解序列化

/**
 根据提供的JSON序列化数据初始化。自动解析JSON，填充属性值

 @param data JSON序列化数据
 */
- (instancetype)gmy_initWithJSONData:(NSData *)data;
+ (instancetype)gmy_ObjectFromJSONData:(NSData *)jsonData;

/**
 根据提供的JSON序列化字符串初始化。自动解析JSON，填充属性值

 @param jsonString JSON序列化字符串
 */
- (instancetype)gmy_initWithJSONString:(NSString *)jsonString;
+ (instancetype)gmy_ObjectFromJSONString:(NSString *)jsonString;

/**
 根据提供的字典初始化。按照属性名取用字典中对应字段值填充属性

 @param dictionary 字典
 */
- (instancetype)gmy_initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)gmy_ObjectWithJSONDicionary:(NSDictionary *)dictionary;


#pragma mark- 序列化
/// 序列化成JSON
- (NSDictionary *)gmy_modelJSONDic;

/// 序列化成JSON bytes
- (NSData *)gmy_modelJSONData;

/// 序列化成JSON string
- (NSString *)gmy_modelJSONString;


@end
