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

- (id)gmy_objectKeyValues {
	return self.copy;
}

@end

@implementation NSString (GMYJSONModel)

- (instancetype)gmy_initWithKeyValues:(id)val {
	return [val copy];
}

- (id)gmy_objectKeyValues {
	return self.copy;
}

@end

@implementation NSArray (GMYJSONModel)

- (id)gmy_objectKeyValues {
	NSMutableArray *mut = @[].mutableCopy;
	for (id item in self) {
		[mut addObject:[item gmy_objectKeyValues]];
	}
	return mut;
}

@end

@implementation NSDictionary (GMYJSONModel)

- (id)gmy_objectKeyValues {
	return self.copy;
}

@end

@implementation NSObject (GMYJSONModel)
#pragma mark - 解序列化

+ (instancetype)gmy_objectWithKeyValues:(id)keyValues {
	return [[self.class alloc] gmy_initWithKeyValues:keyValues];
}

+ (NSArray *)gmy_objectArrayWithKeyValueArray:(NSArray *)keyValues {
	NSMutableArray *mut = @[].mutableCopy;
	[keyValues enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
		[mut addObject:[self.class gmy_objectWithKeyValues:obj]];
	}];
	return mut.copy;
}

- (instancetype)gmy_initWithKeyValues:(id)keyValues {
	NSDictionary *dic = @{};

	if ([keyValues isKindOfClass:NSString.class]) {
		NSString *str = (NSString *)keyValues;
		NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
		dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	} else if ([keyValues isKindOfClass:NSData.class]) {
		dic = [NSJSONSerialization JSONObjectWithData:keyValues options:kNilOptions error:nil];
	} else if ([keyValues isKindOfClass:NSDictionary.class]) {
		dic = keyValues;
	}

	return [[self.class alloc] gmy_initWithDictionary:dic];
}

- (instancetype)gmy_initWithDictionary:(NSDictionary *)dictionary {
	if (!dictionary || ![dictionary isKindOfClass:NSDictionary.class]) {
		return [self init];
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

#pragma mark -

- (NSDictionary *)gmy_objectKeyValues {
	NSMutableDictionary *dic = @{}.mutableCopy;

	for (GMYJSONModelProperty *p in self.gmy_propertys) {
		NSString *key = self.class.gmy_propertyToJSONNameMapping[p->_ivarName];
		if (!key) {
			key = p->_ivarName;
		}
		id val = [self valueForKey:p->_ivarName];
		if (p->_ivarType == GMYPropertyEncodingId) {
			val = [val gmy_objectKeyValues];
		}
		[dic setValue:val forKey:key];
	}

	return dic;
}

- (NSData *)gmy_JSONData {
	return [NSJSONSerialization dataWithJSONObject:self.gmy_objectKeyValues
										   options:NSJSONWritingPrettyPrinted
											 error:nil];
}

- (NSString *)gmy_JSONString {
	return [[NSString alloc] initWithData:self.gmy_JSONData encoding:NSUTF8StringEncoding];
}

#pragma mark - Private

- (void)gmy_setProperty:(GMYJSONModelProperty *)property withJSONNodeVal:(id)val {
	if (!gmy_propertyMatchJSONNodeVal(property, val)) {
		id convertedVal = convertValToMatchPropertyClass(val, property);
		if (!convertedVal)
			return;
		val = convertedVal;
	}
	id penddingVal = val;
	if (property->_ivarType == GMYPropertyEncodingId) {
		if (gmy_JSONNodeVal_is_Array(val)) {
			Class itemClass = self.class.gmy_propertyToClsMapping[property->_ivarName];
			if (itemClass)
				penddingVal = [itemClass gmy_objectArrayWithKeyValueArray:val];
		} else if (gmy_JSONNodeVal_is_Object(val)) {
			Class objcClass = property->_ivarTypeClazz;
			if (objcClass)
				penddingVal = [objcClass gmy_objectWithKeyValues:val];
		}
	}
	/// TODO: use quick setter to set iVar
	/// https://stackoverflow.com/questions/1972753/get-ivar-value-from-object-in-objective-c
	[self setValue:penddingVal forKey:property->_ivarName];
}

@end
