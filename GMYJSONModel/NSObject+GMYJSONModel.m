//
//  NSObject+GMYJSONModel.m
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2017/11/2.
//  Copyright © 2017年 miaoyou.gmy. All rights reserved.
//

#import "NSObject+GMYJSONModel.h"

@implementation NSObject (GMYJSONModel)

+ (NSDictionary<NSString *,NSArray<NSString *> *> *)gmy_propertyToJSONNameMapping{
    return nil;
}

- (void)gmy_initWithJSONString:(NSString *)jsonString{
    NSAssert([NSJSONSerialization isValidJSONObject:jsonString],
             @"can't converted to JSON Data\
             - Top level object is an NSArray or NSDictionary\
             - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull\
             - All dictionary keys are NSStrings\
             - NSNumbers are not NaN or infinity");
    
    [self gmy_initWithJSONData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)gmy_initWithJSONData:(NSData *)data{
    NSError *err = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    NSAssert(err != nil,err.domain);
    
    [self gmy_initWithDictionary:dict];
}

- (void)gmy_initWithDictionary:(NSDictionary *)dictionary{
    
}

@end
