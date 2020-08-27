//
//  NSObject+GMYJSONModelInternal.h
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface GMYJSONModelPropertyAttribute : NSObject {
  @public
	NSString *_name;
	NSString *_val;
}
@end

typedef NS_ENUM(NSUInteger, GMYEncodingType) {
	GMYEncodingUnknown = 0,
	GMYEncodingTypeId = 100,		  // '@'
	GMYEncodingTypeBOOL = 101,		  // 'B'
	GMYEncodingTypeShort = 102,		  // 's'
	GMYEncodingTypeUShort = 103,	  // 'S' UnsignedShort
	GMYEncodingTypeInt = 104,		  // 'i'
	GMYEncodingTypeUInt = 105,		  // 'I' UnsignedInt
	GMYEncodingTypeLong = 106,		  // 'l'
	GMYEncodingTypeULong = 107,		  // 'L' UnsignedLong
	GMYEncodingTypeLongLong = 108,	// 'q'
	GMYEncodingTypeULongLong = 109,   // 'Q' UnsignedLongLong
	GMYEncodingTypeFloat = 110,		  // 'f'
	GMYEncodingTypeDouble = 111,	  // 'd'
};

@interface GMYJSONModelProperty : NSObject {
  @public
	Ivar _ivar;
	NSString *_ivarName;
	Class _ivarClass;
	GMYEncodingType _ivarType;
}
@end

@interface NSObject (GMYJSONModelInternal)
@property(nonatomic, strong) NSArray<GMYJSONModelProperty *> *gmy_propertys;
@end

id convertValToMatchPropertyClass(id jsonNodeVal, GMYJSONModelProperty *p);
bool _propertyMatchJSONNodeVal(GMYJSONModelProperty *p, id cls);
bool _isObjectOfJSONNodeVal(id val);
bool _isArrayOfJSONNodeVal(id val);
NS_ASSUME_NONNULL_END
