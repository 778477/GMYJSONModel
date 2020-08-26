//
//  163MusicCommenter.h
//  GMYJSONModelTests
//
//  Created by miaoyou.gmy on 2020/2/27.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicCommeUser : NSObject
@property(nonatomic, strong, readonly) NSString *locationInfo;
@property(nonatomic, strong, readonly) NSString *liveInfo;
@property(nonatomic, assign, readonly) NSInteger authStatus;
@property(nonatomic, strong, readonly) NSString *userId;
@property(nonatomic, assign, readonly) NSUInteger userType;
@property(nonatomic, strong, readonly) NSString *nickname;
@property(nonatomic, strong, readonly) NSString *avatarUrl;
@end

@interface MusicBeRepliedComment : NSObject
@property(nonatomic, strong, readonly) MusicCommeUser *user;
@property(nonatomic, strong, readonly) NSString *beRepliedCommentId;
@property(nonatomic, strong, readonly) NSString *content;

@end

@interface MusicComment : NSObject
@property(nonatomic, strong, readonly) MusicCommeUser *user;
@property(nonatomic, strong, readonly)
    NSArray<MusicBeRepliedComment *> *beReplied;
@property(nonatomic, strong, readonly) NSString *commentId;
@property(nonatomic, strong, readonly) NSString *content;
@property(nonatomic, assign, readonly) int64_t time;
@property(nonatomic, assign, readonly) NSInteger likedCount;
@end

@interface MusicCommetsResponse : NSObject

@property(nonatomic, strong, readonly) NSArray<MusicComment *> *topCommments;
@property(nonatomic, assign, readonly) BOOL moreHot;
@property(nonatomic, strong, readonly) NSArray<MusicComment *> *comments;
@property(nonatomic, assign, readonly) BOOL more;

@property(nonatomic, assign, readonly) BOOL isMusiciaon;
@property(nonatomic, assign, readonly) NSInteger cnum;
@property(nonatomic, strong, readonly) NSString *userId;
@property(nonatomic, assign, readonly) NSUInteger code;
@property(nonatomic, assign, readonly) NSUInteger total;
@end

NS_ASSUME_NONNULL_END
