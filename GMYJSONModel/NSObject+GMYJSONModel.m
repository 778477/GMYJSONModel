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
	if (![val isKindOfClass:NSNumber.class]) {
		return @(0);
	}
	return [val copy];
}

- (id)gmy_objectKeyValues {
	return self.copy;
}

@end

@implementation NSString (GMYJSONModel)

- (instancetype)gmy_initWithKeyValues:(id)val {
	if (![val isKindOfClass:NSString.class]) {
		return @"";
	}
	return [val copy];
}

- (id)gmy_objectKeyValues {
	return self.copy;
}

@end

@implementation NSArray (GMYJSONModel)

- (id)gmy_objectKeyValues {
	NSMutableArray *result = @[].mutableCopy;
	for (NSObject *obj in self) {
		[result addObject:obj.gmy_objectKeyValues];
	}
	return result.copy;
}

@end

@implementation NSDictionary (GMYJSONModel)

- (id)gmy_objectKeyValues {
	NSMutableDictionary *result = @{}.mutableCopy;
	for (NSObject *key in self.allKeys) {
		if (![key isKindOfClass:NSString.class]) {
			continue;
		}
		id obj = self[key];
		[result setValue:[obj gmy_objectKeyValues] forKey:(NSString *)key];
	}
	return result.copy;
}

@end

@implementation NSNull (GMYJSONModel)

- (id)gmy_objectKeyValues {
	return nil;
}

@end

@implementation NSObject (GMYJSONModel)
#pragma mark - 解序列化

+ (instancetype)gmy_objectWithKeyValues:(id)keyValues {
	return [[self.class alloc] gmy_initWithKeyValues:keyValues];
}

+ (NSArray *)gmy_objectArrayWithKeyValueArray:(NSArray *)keyValues {
	NSMutableArray *result = @[].mutableCopy;
	for (id obj in keyValues) {
		[result addObject:[self.class gmy_objectWithKeyValues:obj]];
	}
	return result.copy;
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

/**
 refs:
 https://stackoverflow.com/questions/1972753/get-ivar-value-from-object-in-objective-c
 */
- (void)gmy_setProperty:(GMYJSONModelProperty *)property withJSONNodeVal:(id)val {

	if (!_propertyMatchJSONNodeVal(property, val)) {
		id convertedVal = convertValToMatchPropertyClass(val, property);
		if (!convertedVal)
			return;
		val = convertedVal;
	}
	id result = val;
	if (property->_ivarType == GMYEncodingTypeId) {
		if (_isArrayOfJSONNodeVal(val)) {
			Class itemClass = self.class.gmy_propertyToClsMapping[property->_ivarName];
			if (itemClass)
				result = [itemClass gmy_objectArrayWithKeyValueArray:val];
		} else if (_isObjectOfJSONNodeVal(val)) {
			Class objcClass = property->_ivarClass;
			if (objcClass)
				result = [objcClass gmy_objectWithKeyValues:val];
		}
	}
	if (property->_ivarType == GMYEncodingTypeId) {
		object_setIvar(self, property->_ivar, result);
	} else {
#define setAssignPropertyIfNeed(EnumTargetType, Type, OriginValue)                       \
	if (property->_ivarType == EnumTargetType) {                                         \
		char *address = (__bridge void *)self;                                           \
		address += ivar_getOffset(property->_ivar);                                      \
		*(Type *)address = OriginValue;                                                  \
	}
		setAssignPropertyIfNeed(GMYEncodingTypeBOOL, BOOL, [result boolValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeShort, short, [result shortValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeUShort, unsigned short, [result unsignedShortValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeUInt, int, [result intValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeUInt, unsigned int, [result unsignedIntValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeLong, long, [result longValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeULong, unsigned long, [result unsignedLongValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeLongLong, long long, [result longLongValue]);
		setAssignPropertyIfNeed(
			GMYEncodingTypeULongLong, unsigned long long, [result unsignedLongLongValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeFloat, float, [result floatValue]);
		setAssignPropertyIfNeed(GMYEncodingTypeDouble, double, [result doubleValue]);

#undef setAssignPropertyIfNeed
	}
}

#pragma mark - 序列化
- (id)gmy_objectKeyValues {
	NSMutableDictionary<NSString *, id> *result = @{}.mutableCopy;
	for (GMYJSONModelProperty *property in self.gmy_propertys) {
		if ([self.class.gmy_ignorePropertyNames containsObject:property->_ivarName]) {
			continue;
		}
		NSString *key = self.class.gmy_propertyToJSONNameMapping[property->_ivarName];
		if (!key) {
			key = property->_ivarName;
		}

		id val = [self gmy_getJSONNodeValForProperty:property];
		[result setValue:val forKey:key];
	}
	return result;
}

- (NSString *)gmy_JSONString {
	return [[NSString alloc] initWithData:self.gmy_JSONData
								 encoding:NSUTF8StringEncoding];
}

- (NSData *)gmy_JSONData {
	NSDictionary *dic = self.gmy_objectKeyValues;
	if ([NSJSONSerialization isValidJSONObject:dic]) {
		return [NSJSONSerialization
			dataWithJSONObject:dic
					   options:NSJSONWritingSortedKeys | NSJSONWritingPrettyPrinted
						 error:nil];
	}
	return NSData.data;
}

#pragma mark -
- (id)gmy_getJSONNodeValForProperty:(GMYJSONModelProperty *)property {
	id val = NSNull.null;
	if (property->_ivarType >= GMYEncodingTypeBOOL &&
		property->_ivarType <= GMYEncodingTypeDouble) {
#define getAssignPropertyIfNeed(EnumTargetType, Type)                                    \
	if (property->_ivarType == EnumTargetType) {                                         \
		char *address = (__bridge void *)self;                                           \
		address += ivar_getOffset(property->_ivar);                                      \
		val = @(*(Type *)address);                                                       \
	}
		getAssignPropertyIfNeed(GMYEncodingTypeBOOL, BOOL);
		getAssignPropertyIfNeed(GMYEncodingTypeShort, short);
		getAssignPropertyIfNeed(GMYEncodingTypeUShort, unsigned short);
		getAssignPropertyIfNeed(GMYEncodingTypeUInt, int);
		getAssignPropertyIfNeed(GMYEncodingTypeUInt, unsigned int);
		getAssignPropertyIfNeed(GMYEncodingTypeLong, long);
		getAssignPropertyIfNeed(GMYEncodingTypeULong, unsigned long);
		getAssignPropertyIfNeed(GMYEncodingTypeLongLong, long long);
		getAssignPropertyIfNeed(GMYEncodingTypeULongLong, unsigned long long);
		getAssignPropertyIfNeed(GMYEncodingTypeFloat, float);
		getAssignPropertyIfNeed(GMYEncodingTypeDouble, double);
#undef getAssignPropertyIfNeed
	}

	if (property->_ivarType == GMYEncodingTypeId) {
		val = object_getIvar(self, property->_ivar);
		val = [(NSObject *)val gmy_objectKeyValues];
	}

	return val;
}

@end
