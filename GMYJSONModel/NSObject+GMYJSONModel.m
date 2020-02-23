//
//  NSObject+GMYJSONModel.m
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2017/11/2.
//  Copyright © 2017年 miaoyou.gmy. All rights reserved.
//

#import "NSObject+GMYJSONModel.h"
#import "NSObject+GMYJSONModelInternal.h"
#import "NSObject+GMYJSONModelKeyValues.h"
#import <objc/message.h>

@implementation NSObject (GMYJSONModel)

- (instancetype)gmy_initWithJSONString:(NSString *)jsonString {
	return [self gmy_initWithJSONData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (instancetype)gmy_initWithJSONData:(NSData *)data {
	NSError *err = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
														 options:kNilOptions
														   error:&err];
	NSAssert(!err, err.localizedDescription);
	return [self gmy_initWithDictionary:dict];
}

- (instancetype)gmy_initWithDictionary:(NSDictionary *)dictionary {

	if (!dictionary || ![dictionary isKindOfClass:NSDictionary.class]) {
		return nil;
	}

	for (GMYJSONModelProperty *property in self.gmy_propertys) {
		if ([self.class.gmy_ignorePropertyNames containsObject:property->_ivarName]) {
			continue;
		}
		NSString *key = self.class.gmy_propertyToJSONNameMapping[property->_ivarName];
		if (!key) {
			key = property->_ivarName;
		}
		id valFromJson = [dictionary valueForKey:key];

		if (!valFromJson) {
			continue;
		}

		[self gmy_setProperty:property
             withJSONNodelVal:valFromJson
				 onStrictMode:self.class.gmy_enableStrictMode];
	}

	return self;
}

#pragma mark - Private

- (void)gmy_setProperty:(GMYJSONModelProperty *)property
       withJSONNodelVal:(id)val
		   onStrictMode:(BOOL)onStrictMode {

	if (onStrictMode && !gmy_propertyMatchJSONNodeVal(property, val)) {
		return;
	}

	if (property->_ivarType == GMYPropertyEncodingId) {
		id penddingVal = val;
		if (gmy_JSONNodeVal_is_Array(val)) {
			Class itemClass = self.class.gmy_propertyToClsMapping[property->_ivarName];
			if (itemClass) {
                // TODO: support array type
			}
		} else if (gmy_JSONNodeVal_is_Object(val)) {
			Class objcClass = property->_ivarTypeClazz;
			if (objcClass) {
				penddingVal = [[objcClass alloc] gmy_initWithDictionary:val];
			}
		}
		((id(*)(id, SEL, id))objc_msgSend)(self, property->_setter, penddingVal);
	} else {
#define msgSend_Setter(type, typeVal)                                                              \
	((id(*)(id, SEL, type))objc_msgSend)(self, property->_setter, typeVal);
		switch (property->_ivarType) {
			case GMYPropertyEncodingTypeBOOL:
				msgSend_Setter(BOOL, [val boolValue]);
				break;
			case GMYPropertyEncodingTypeShort:
				msgSend_Setter(short, [val shortValue]);
				break;
			case GMYPropertyEncodingTypeUnsignedShort:
				msgSend_Setter(unsigned short, [val unsignedShortValue]);
				break;
			case GMYPropertyEncodingTypeInt:
				msgSend_Setter(int, [val intValue]);
				break;
			case GMYPropertyEncodingTypeUnsignedInt:
				msgSend_Setter(unsigned int, [val unsignedIntValue]);
				break;
			case GMYPropertyEncodingTypeLong:
				msgSend_Setter(long, [val longValue]);
				break;
			case GMYPropertyEncodingTypeUnsignedLong:
				msgSend_Setter(unsigned long, [val unsignedLongValue]);
				break;
			case GMYPropertyEncodingTypeLongLong:
				msgSend_Setter(long long, [val longLongValue]);
				break;
			case GMYPropertyEncodingTypeUnsignedLongLong:
				msgSend_Setter(unsigned long long, [val unsignedLongLongValue]);
				break;
			case GMYPropertyEncodingTypeFloat:
				msgSend_Setter(float, [val floatValue]);
				break;
			case GMYPropertyEncodingTypeDouble:
				msgSend_Setter(double, [val doubleValue]);
				break;
			default:
				break;
		}
#undef msgSend_Setter
	}
}

@end
