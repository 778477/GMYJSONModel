//
//  GMYJSONModelMusicCommentTests.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/27.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "MusicComment.h"
#import <GMYJSONModel/GMYJSONModel.h>
#import <XCTest/XCTest.h>

@interface GMYJSONModelMusicCommentTests : XCTestCase

@end

@implementation GMYJSONModelMusicCommentTests

- (void)testGMYJSONModelCreateResponse {
  NSBundle *bundle = [NSBundle
      bundleWithPath:[NSBundle.mainBundle.resourcePath
                         stringByAppendingPathComponent:@"resources.bundle"]];
  NSString *filePath = [bundle.resourcePath
      stringByAppendingPathComponent:@"163Music_comment.json"];
  NSData *content = [NSData dataWithContentsOfFile:filePath];
  MusicCommetsResponse *response =
      [MusicCommetsResponse gmy_objectWithKeyValues:content];
  XCTAssertNotNil(response);
  XCTAssertTrue(response.total == 171);
  XCTAssertNotNil(response.userId);
}

@end
