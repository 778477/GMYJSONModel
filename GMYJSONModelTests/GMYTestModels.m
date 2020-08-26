//
//  GMYTestModels.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "GMYTestModels.h"
#import <GMYJSONModel/GMYJSONModel.h>

@implementation Pic

@end

@implementation Student

+ (NSDictionary<NSString *, NSString *> *)gmy_propertyToJSONNameMapping {
  return @{@"indentifier" : @"id"};
}

+ (NSDictionary<NSString *, Class> *)gmy_propertyToClsMapping {
  return @{
    @"scores" : NSNumber.class,
    @"friends" : NSString.class,
    @"pics" : Pic.class
  };
}

- (void)setMyAge:(NSUInteger)age {
  _customAgeSetterCalled = YES;
  _age = age;
}

@end
