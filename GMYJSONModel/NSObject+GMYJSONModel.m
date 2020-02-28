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
#pragma mark - 解序列化

+ (instancetype)gmy_ObjectFromJSONString:(NSString *)jsonString {
	return [[self.class alloc] gmy_initWithJSONString:jsonString];
}

- (instancetype)gmy_initWithJSONString:(NSString *)jsonString {
	return [self gmy_initWithJSONData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (instancetype)gmy_ObjectFromJSONData:(NSData *)jsonData {
	return [[self.class alloc] gmy_initWithJSONData:jsonData];
}

- (instancetype)gmy_initWithJSONData:(NSData *)data {
	NSError *err = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
														 options:kNilOptions
														   error:&err];
	NSAssert(!err, err.localizedDescription);
	return [self gmy_initWithDictionary:dict];
}

+ (instancetype)gmy_ObjectWithJSONDicionary:(NSDictionary *)dictionary {
	return [[self.class alloc] gmy_initWithDictionary:dictionary];
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
			  withJSONNodeVal:valFromJson
				 onStrictMode:self.class.gmy_enableStrictMode];
	}

	return self;
}

#pragma mark - 序列化
- (NSData *)gmy_modelJSONData {
	NSAssert([NSJSONSerialization isValidJSONObject:self.gmy_modelJSONDic], @"invalid");
	NSData *data = [NSJSONSerialization dataWithJSONObject:self.gmy_modelJSONDic
												   options:kNilOptions
													 error:nil];
	return data;
}

- (NSString *)gmy_modelJSONString {
	return [[NSString alloc] initWithData:self.gmy_modelJSONData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)gmy_modelJSONDic {
	return nil;
}

#pragma mark - Private
- (void)gmy_setProperty:(GMYJSONModelProperty *)property
		withJSONNodeVal:(id)val
		   onStrictMode:(BOOL)onStrictMode {

	if (onStrictMode && !gmy_propertyMatchJSONNodeVal(property, val)) {
		return;
	}

	if (property->_ivarType == GMYPropertyEncodingId) {
		id penddingVal = val;
		if (gmy_JSONNodeVal_is_Array(val)) {
			Class itemClass = self.class.gmy_propertyToClsMapping[property->_ivarName];
			if (itemClass) {
				NSMutableArray *array = @[].mutableCopy;
				for (id item in val) {
					if ([item isKindOfClass:NSDictionary.class]) {
						id itemObj = [[itemClass alloc] gmy_initWithDictionary:item];
						if (itemObj) {
							[array addObject:itemObj];
						}
					} else if ([item isKindOfClass:itemClass]) {
						[array addObject:item];
					} else {
						NSAssert(NO, @"unsupport type!");
					}
				}
				penddingVal = array.mutableCopy;
			}
		} else if (gmy_JSONNodeVal_is_Object(val)) {
			Class objcClass = property->_ivarTypeClazz;
			if (objcClass) {
				penddingVal = [[objcClass alloc] gmy_initWithDictionary:val];
			}
		}
		if (property->isReadOnly) {
			[self setValue:penddingVal forKey:property->_ivarName];
		} else {
			((id(*)(id, SEL, id))objc_msgSend)(self, property->_setter, penddingVal);
		}
	} else {
		[self setValue:val forKey:property->_ivarName];
#define msgSend_Setter(type, typeVal)                                                              \
	if (property->isReadOnly) {                                                                    \
		[self setValue:val forKey:property->_ivarName];                                            \
	} else {                                                                                       \
		((id(*)(id, SEL, type))objc_msgSend)(self, property->_setter, typeVal);                    \
	}
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
