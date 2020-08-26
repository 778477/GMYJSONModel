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
	GMYEncodingId = 100,					 // '@'
	GMYEncodingTypeBOOL = 101,				 // 'B'
	GMYEncodingTypeShort = 102,				 // 's'
	GMYEncodingTypeUnsignedShort = 103,		 // 'S'
	GMYEncodingTypeInt = 104,				 // 'i'
	GMYEncodingTypeUnsignedInt = 105,		 // 'I'
	GMYEncodingTypeLong = 106,				 // 'l'
	GMYEncodingTypeUnsignedLong = 107,		 // 'L'
	GMYEncodingTypeLongLong = 108,			 // 'q'
	GMYEncodingTypeUnsignedLongLong = 109,   // 'Q'
	GMYEncodingTypeFloat = 110,				 // 'f'
	GMYEncodingTypeDouble = 111,			 // 'd'
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
bool gmy_propertyMatchJSONNodeVal(GMYJSONModelProperty *p, id cls);
bool gmy_JSONNodeVal_is_Object(id val);
bool gmy_JSONNodeVal_is_Array(id val);
NS_ASSUME_NONNULL_END
