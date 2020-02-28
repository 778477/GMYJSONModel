//
//  163MusicCommenter.m
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/27.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "MusicComment.h"
#import <GMYJSONModel/NSObject+GMYJSONModelKeyValues.h>

@implementation MusicCommeUser

@end

@implementation MusicBeRepliedComment

@end

@implementation MusicComment

+ (NSDictionary<NSString *,Class> *)gmy_propertyToClsMapping {
    return @{
        @"beReplied" : MusicBeRepliedComment.class
    };
}

@end

@implementation MusicCommetsResponse

+ (NSDictionary<NSString *,Class> *)gmy_propertyToClsMapping {
    return @{
        @"topCommments" : MusicComment.class,
        @"comments" :MusicComment.class
    };
}

@end
