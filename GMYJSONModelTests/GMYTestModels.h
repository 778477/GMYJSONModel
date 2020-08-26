//
//  GMYTestModels.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pic : NSObject
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *urlPattern;
@end

@interface Student : NSObject
@property(nonatomic, strong) NSArray<Pic *> *pics;
@property(nonatomic, assign) BOOL male;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *indentifier;
@property(nonatomic, assign, setter=setMyAge:) NSUInteger age;
@property(nonatomic, copy) NSArray<NSNumber *> *scores;
@property(nonatomic, copy) NSArray<NSString *> *friends;
@property(nonatomic, assign) BOOL customAgeSetterCalled;
@end
