//
//  GMYTestModels.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *StudentModelJSONString() {
    return @"{\
    \"age\":18,\
    \"name\":\"blob\",\
    \"id\":\"A2020\",\
    \"scores\":[20,-1,3,9.01,32],\
    \"male\":true,\
    \"friends\":[\"nick\",\"jack\",\"tom\"],\
    \"pic\":{\"url\":\"www.xxx.com/pic1\"}\
    }";
}

static NSData *StudentModelJSONData() {
    return [StudentModelJSONString() dataUsingEncoding:NSUTF8StringEncoding];
}

static NSDictionary *StudentModelJSONDic() {
    return [NSJSONSerialization JSONObjectWithData:StudentModelJSONData()
                                           options:kNilOptions
                                             error:nil];
}

@interface Pic : NSObject
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *urlPattern;
@end

@interface Student : NSObject
@property (nonatomic, strong) Pic *pic;
@property (nonatomic, assign) BOOL male;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *indentifier;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, copy) NSArray<NSNumber *> *scores;
@property (nonatomic, copy) NSArray<NSString *> *friends;
@end


