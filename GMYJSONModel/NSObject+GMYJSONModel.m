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
#pragma mark - NSFounation
@implementation NSNumber (GMYJSONModel)

- (instancetype)gmy_initWithKeyValues:(id)val {
	return [val copy];
}

@end

@implementation NSString (GMYJSONModel)

- (instancetype)gmy_initWithKeyValues:(id)val {
	return [val copy];
}

@end

@implementation NSObject (GMYJSONModel)
#pragma mark - 解序列化

+ (instancetype)gmy_objectWithKeyValues:(id)keyValues {
	return [[self.class alloc] gmy_initWithKeyValues:keyValues];
}

+ (NSArray *)gmy_objectArrayWithKeyValueArray:(NSArray *)keyValues {
	NSMutableArray *mut = @[].mutableCopy;
	for (id obj in keyValues) {
		[mut addObject:[self.class gmy_objectWithKeyValues:obj]];
	}
	return mut.copy;
}

- (instancetype)gmy_initWithKeyValues:(id)keyValues {
	NSDictionary *dic = @{};

	if ([keyValues isKindOfClass:NSString.class]) {
		NSString *str = (NSString *)keyValues;
		NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
		dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	} else if ([keyValues isKindOfClass:NSData.class]) {
		dic = [NSJSONSerialization JSONObjectWithData:keyValues
											  options:kNilOptions
												error:nil];
	} else if ([keyValues isKindOfClass:NSDictionary.class]) {
		dic = keyValues;
	}

	return [[self.class alloc] gmy_initWithDictionary:dic];
}

- (instancetype)gmy_initWithDictionary:(NSDictionary *)dictionary {
	if (!dictionary || ![dictionary isKindOfClass:NSDictionary.class]) {
		return self;
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

		[self gmy_setProperty:property withJSONNodeVal:valFromJson];
	}

	return self;
}

#pragma mark - Private

/// TODO: use quick setter to set iVar
/// https://stackoverflow.com/questions/1972753/get-ivar-value-from-object-in-objective-c
- (void)gmy_setProperty:(GMYJSONModelProperty *)property withJSONNodeVal:(id)val {

	if (!gmy_propertyMatchJSONNodeVal(property, val)) {
		id convertedVal = convertValToMatchPropertyClass(val, property);
		if (!convertedVal)
			return;
		val = convertedVal;
	}
	id penddingVal = val;
	if (property->_ivarType == GMYEncodingId) {
		if (gmy_JSONNodeVal_is_Array(val)) {
			Class itemClass = self.class.gmy_propertyToClsMapping[property->_ivarName];
			if (itemClass)
				penddingVal = [itemClass gmy_objectArrayWithKeyValueArray:val];
		} else if (gmy_JSONNodeVal_is_Object(val)) {
			Class objcClass = property->_ivarClass;
			if (objcClass)
				penddingVal = [objcClass gmy_objectWithKeyValues:val];
		}
	}
	if (property->_ivarType == GMYEncodingId) {
		object_setIvar(self, property->_ivar, penddingVal);
	} else {
#define setAssignPropertyIfNeed(EnumTargetType, Type, OriginValue)                       \
	if (property->_ivarType == EnumTargetType) {                                         \
		char *address = (__bridge void *)self;                                           \
		address += ivar_getOffset(property->_ivar);                                      \
		*(Type *)address = OriginValue;                                                  \
	}
		setAssignPropertyIfNeed(GMYEncodingTypeBOOL, BOOL, [penddingVal boolValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeShort, short, [penddingVal shortValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeUnsignedShort,
			unsigned short,
			[penddingVal unsignedShortValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeUnsignedInt, int, [penddingVal intValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeUnsignedInt, unsigned int, [penddingVal unsignedIntValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeLong, long, [penddingVal longValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeUnsignedLong, unsigned long, [penddingVal unsignedLongValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeLongLong, long long, [penddingVal longLongValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeUnsignedLongLong,
			unsigned long long,
			[penddingVal unsignedLongLongValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeFloat, float, [penddingVal floatValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeDouble, double, [penddingVal doubleValue]);

#undef setAssignPropertyIfNeed
	}
}

@end
