//
//  GMYModelToJSONTests.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/24.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GMYTestModels.h"
#import "MusicComment.h"
#import <GMYJSONModel/NSObject+GMYJSONModel.h>

@interface GMYModelToJSONTests : XCTestCase

@end

@implementation GMYModelToJSONTests

- (void)testGMYJSONModelToDictionary {
    NSBundle *bundle = [NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"resources.bundle"]];
    NSString *filePath = [bundle.resourcePath stringByAppendingPathComponent:@"163Music_comment.json"];
    NSData *content = [NSData dataWithContentsOfFile:filePath];

    
    MusicCommetsResponse *res = [MusicCommetsResponse gmy_objectWithKeyValues:content];
    NSDictionary *objDic = [res gmy_objectKeyValues];
    XCTAssertNotNil(objDic);

    NSString *objJSONStr = [res gmy_JSONString];
    XCTAssertNotNil(objJSONStr);

}

@end
