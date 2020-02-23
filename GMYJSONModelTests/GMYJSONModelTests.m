//
//  GMYJSONModelTests.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2017/11/2.
//  Copyright © 2017年 miaoyou.gmy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GMYTestModels.h"
#import <GMYJSONModel/NSObject+GMYJSONModel.h>
#import <GMYJSONModel/NSObject+GMYJSONModelKeyValues.h>

@interface GMYJSONModelTests : XCTestCase

@end

@implementation GMYJSONModelTests

- (void)testModelFromDic {
    NSDictionary *dic = StudentModelJSONDic();
    Student *t = [[Student alloc] gmy_initWithDictionary:dic];
    XCTAssertTrue([t.name isEqualToString:@"blob"]);
    XCTAssertEqual(t.age, 18);
    XCTAssertTrue(t.customAgeSetterCalled);
    XCTAssertTrue([t.indentifier isEqualToString:@"A2020"]);
    XCTAssertEqual(t.male, YES);
    NSArray *scores = dic[@"scores"];
    XCTAssertTrue([scores isEqualToArray:t.scores]);
    NSArray *friends = dic[@"friends"];
    XCTAssertTrue([friends isEqualToArray:t.friends]);
    XCTAssertNotNil(t.pics);
    XCTAssertTrue([t.pics isKindOfClass:NSArray.class]);
    XCTAssertTrue([t.pics.firstObject isKindOfClass:Pic.class]);
    XCTAssertTrue(t.pics.count == 3);
}

- (void)testModelFromJSONString {
    Student *t = [[Student alloc] gmy_initWithJSONString:StudentModelJSONString()];
    XCTAssertTrue([t.name isEqualToString:@"blob"]);
    XCTAssertEqual(t.age, 18);
    XCTAssertTrue([t.indentifier isEqualToString:@"A2020"]);
    XCTAssertEqual(t.male, YES);
}

- (void)testModelFromJSONData {
    Student *t = [[Student alloc] gmy_initWithJSONData:StudentModelJSONData()];
    XCTAssertTrue([t.name isEqualToString:@"blob"]);
    XCTAssertEqual(t.age, 18);
    XCTAssertTrue([t.indentifier isEqualToString:@"A2020"]);
    XCTAssertEqual(t.male, YES);
}

@end
