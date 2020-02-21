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

	[dictionary
		enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
			NSLog(@"%@ - %@ - %@", key, [obj class], obj);
		}];

	for (GMYJSONModelProperty *property in self.gmy_propertys) {
		if ([self.class.gmy_ignorePropertyNames containsObject:property->_ivarName]) {
			continue;
		}
		NSString *key = self.class.gmy_propertyToJSONNameMapping[property->_ivarName];
		if (!key) {
			key = property->_ivarName;
		}
		id valFromJson = [dictionary valueForKey:key];

		// 1. strict mode. check valFromJson is equal to property type
		// 2. if has customze setter. call custom setter
		if (!valFromJson)
			continue;

		[self gmy_setProperty:property
						  val:valFromJson
				 OnStrictMode:self.class.gmy_enableStrictMode];
	}

	return self;
}

#pragma mark - Private

- (void)gmy_setProperty:(GMYJSONModelProperty *)property
					val:(id)val
		   OnStrictMode:(BOOL)onStrictMode {

	if (onStrictMode && !gmy_propertyTypeMatchJSONValClass(property, [val class])) {
		return;
	}

	[self setValue:val forKey:property->_ivarName];
}

@end
