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

@property (nonatomic, strong) NSBundle *resources;

@end

@implementation GMYJSONModelTests

- (void)setUp {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"resources" ofType:@"bundle"];
    XCTAssertNotNil(path, @"not found resources path!");
    self.resources = [NSBundle bundleWithPath:path];
}

- (void)testGMYJSONModelFromLocalJSONFile {
    NSString *jsonFilePath = [self.resources pathForResource:@"student" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:jsonFilePath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    Student *t = [Student gmy_objectWithKeyValues:data];
    XCTAssertTrue([t.name isEqualToString:@"blob"]);
    XCTAssertEqual(t.age, 18);
//    XCTAssertTrue(t.customAgeSetterCalled);
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

@end
