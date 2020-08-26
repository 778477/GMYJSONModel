//
//  GMYModelToJSONTests.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/24.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "GMYTestModels.h"
#import "MusicComment.h"
#import <GMYJSONModel/NSObject+GMYJSONModel.h>
#import <XCTest/XCTest.h>

@interface GMYModelToJSONTests : XCTestCase

@end

@implementation GMYModelToJSONTests

- (void)testGMYJSONModelToDictionary {
  //    NSBundle *bundle = [NSBundle
  //    bundleWithPath:[NSBundle.mainBundle.resourcePath
  //    stringByAppendingPathComponent:@"resources.bundle"]]; NSString *filePath
  //    = [bundle.resourcePath
  //    stringByAppendingPathComponent:@"163Music_comment.json"]; NSData
  //    *content = [NSData dataWithContentsOfFile:filePath];
  //    MusicCommetsResponse *res = [MusicCommetsResponse
  //    gmy_objectWithKeyValues:content]; NSDictionary *objDic = [res
  //    gmy_modelJSONDic]; XCTAssertNotNil(objDic); NSData *objJsonData = [res
  //    gmy_modelJSONData]; XCTAssertTrue([content isEqualToData:objJsonData]);
  //    XCTAssertNotNil(objJsonData);
  //    NSString *objJsonStr = [res gmy_modelJSONString];
  //    XCTAssertNotNil(objJsonStr);
}

@end
