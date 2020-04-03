//
//  NSObject+GMYJSONModelKeyValues.m
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "NSObject+GMYJSONModelKeyValues.h"

@implementation NSObject (GMYJSONModelKeyValues)

+ (NSDictionary<NSString *, NSString *> *)gmy_propertyToJSONNameMapping {
  return @{};
}

+ (NSDictionary<NSString *, Class> *)gmy_propertyToClsMapping {
  return @{};
}

+ (NSArray<NSString *> *)gmy_ignorePropertyNames {
  return @[];
}

@end
