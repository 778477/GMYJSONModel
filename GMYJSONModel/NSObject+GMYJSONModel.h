//
//  NSObject+GMYJSONModel.h
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2017/11/2.
//  Copyright © 2017年 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GMYJSONModel)
#pragma mark - 解序列化

- (instancetype)gmy_initWithKeyValues:(id)keyValues;
+ (instancetype)gmy_objectWithKeyValues:(id)keyValues;
+ (NSArray *)gmy_objectArrayWithKeyValueArray:(NSArray *)keyValues;

#pragma mark - 序列化

- (id)gmy_objectKeyValues;
- (NSString *)gmy_JSONString;
- (NSData *)gmy_JSONData;
@end
