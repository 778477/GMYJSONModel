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

/**
 对象属性对应JSON字段名的映射表，支持一对多
 
 一对多场景：服务端变更字段名，更新映射表即可/服务端不是驼峰命名风格，命名未对齐
 
 @return 映射表
 */
+ (NSDictionary<NSString *,NSArray<NSString *> *> *)gmy_propertyToJSONNameMapping;

/**
 根据提供的JSON序列化数据初始化。自动解析JSON，填充属性值

 @param data JSON序列化数据
 */
- (void)gmy_initWithJSONData:(NSData *)data;

/**
 根据提供的JSON序列化字符串初始化。自动解析JSON，填充属性值
 
 @param jsonString JSON序列化字符串
 */
- (void)gmy_initWithJSONString:(NSString *)jsonString;

/**
 根据提供的字典初始化。按照属性名取用字典中对应字段值填充属性

 @param dictionary 字典
 */
- (void)gmy_initWithDictionary:(NSDictionary *)dictionary;


@end
