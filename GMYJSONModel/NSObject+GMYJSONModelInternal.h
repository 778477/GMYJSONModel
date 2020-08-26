//
//  NSObject+GMYJSONModelInternal.h
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface GMYJSONModelPropertyAttribute : NSObject {
  @public
	NSString *_name;
	NSString *_val;
}
@end

typedef NS_ENUM(NSUInteger, GMYPropertyEncodingType) {
	GMYPropertyEncodingUnknown = 0,
	GMYPropertyEncodingId = 100,					 // '@'
	GMYPropertyEncodingTypeBOOL = 101,				 // 'B'
	GMYPropertyEncodingTypeShort = 102,				 // 's'
	GMYPropertyEncodingTypeUnsignedShort = 103,		 // 'S'
	GMYPropertyEncodingTypeInt = 104,				 // 'i'
	GMYPropertyEncodingTypeUnsignedInt = 105,		 // 'I'
	GMYPropertyEncodingTypeLong = 106,				 // 'l'
	GMYPropertyEncodingTypeUnsignedLong = 107,		 // 'L'
	GMYPropertyEncodingTypeLongLong = 108,			 // 'q'
	GMYPropertyEncodingTypeUnsignedLongLong = 109,   // 'Q'
	GMYPropertyEncodingTypeFloat = 110,				 // 'f'
	GMYPropertyEncodingTypeDouble = 111,			 // 'd'
};

@interface GMYJSONModelProperty : NSObject {
  @public
	NSString *_ivarName;
	GMYPropertyEncodingType _ivarType;
	Class _ivarTypeClazz;
	SEL _getter, _setter;
	ptrdiff_t _iverOffset;
	BOOL isReadOnly;
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
