//
//  NSObject+GMYJSONModelKeyValues.h
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (GMYJSONModelKeyValues)

/// 对象属性对应JSON字段名的映射表
+ (NSDictionary<NSString *, NSString *> *)gmy_propertyToJSONNameMapping;

/// NSArray<Student *> *students =>
/// @{@"students":Stuent.Class};
+ (NSDictionary<NSString *, Class> *)gmy_propertyToClsMapping;

/// 需要忽略的赋值
+ (NSArray<NSString *> *)gmy_ignorePropertyNames;

@end

NS_ASSUME_NONNULL_END
