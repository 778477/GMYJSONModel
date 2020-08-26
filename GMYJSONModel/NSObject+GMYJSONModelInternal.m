//
//  NSObject+GMYJSONModelInternal.m
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "NSObject+GMYJSONModelInternal.h"
#import <objc/runtime.h>

GMYEncodingType _MatchPropertyAttribueDescript(const char c) {
	switch (c) {
		case _C_ID:
			return GMYEncodingId;
		case _C_BOOL:
			return GMYEncodingTypeBOOL;
		case _C_SHT:
			return GMYEncodingTypeShort;
		case _C_USHT:
			return GMYEncodingTypeUnsignedShort;
		case _C_INT:
			return GMYEncodingTypeInt;
		case _C_UINT:
			return GMYEncodingTypeUnsignedInt;
		case _C_LNG:
			return GMYEncodingTypeLong;
		case _C_ULNG:
			return GMYEncodingTypeUnsignedLong;
		case _C_LNG_LNG:
			return GMYEncodingTypeLongLong;
		case _C_ULNG_LNG:
			return GMYEncodingTypeUnsignedLongLong;
		case _C_FLT:
			return GMYEncodingTypeFloat;
		case _C_DBL:
			return GMYEncodingTypeDouble;
		default:
			break;
	}

	return GMYEncodingUnknown;
}

NS_INLINE NSString *_CSStringToNSString(const char *str) {
	return [NSString stringWithUTF8String:str];
}

@implementation GMYJSONModelPropertyAttribute

+ (instancetype)attributeWithObjc_property_attribute_t:
	(objc_property_attribute_t)objc_p_a {
	__auto_type a = [[GMYJSONModelPropertyAttribute alloc] init];
	a->_name = _CSStringToNSString(objc_p_a.name);
	a->_val = _CSStringToNSString(objc_p_a.value);
	return a;
}

@end

@implementation GMYJSONModelProperty

SEL _propertyNormalSetter(NSString *ivarName) {
	NSString *str =
		[NSString stringWithFormat:@"set%@%@:",
								   [ivarName substringToIndex:1].uppercaseString,
								   [ivarName substringFromIndex:1]];
	return NSSelectorFromString(str);
}

SEL _propertyNormalGetter(NSString *ivarName) { return NSSelectorFromString(ivarName); }

+ (instancetype)propertyByClass:(Class)class withIvar:(Ivar)ivar {

	__auto_type p = [[GMYJSONModelProperty alloc] init];
	p->_ivar = ivar;
	p->_ivarName = _CSStringToNSString(&ivar_getName(ivar)[1]);
	p->_ivarType = _MatchPropertyAttribueDescript(ivar_getTypeEncoding(ivar)[0]);
	if (p->_ivarType == GMYEncodingId) {
		// @"NSArray"
		// @"NSString"
		NSString *ivarTypeEncoding = _CSStringToNSString(ivar_getTypeEncoding(ivar));
		p->_ivarClass = NSClassFromString([ivarTypeEncoding
			substringWithRange:NSMakeRange(2, ivarTypeEncoding.length - 3)]);
	} else if (
		p->_ivarType >= GMYEncodingTypeBOOL && p->_ivarType <= GMYEncodingTypeDouble) {
		p->_ivarClass = NSNumber.class;
	}

	return p;
}

@end

@implementation NSObject (GMYJSONModelInternal)
/**
 // 1. object interface. contains super property list
 // 2. object protocol. property list
 // 3. object category. property list

 property VS ivar

 */
- (NSArray<GMYJSONModelProperty *> *)gmy_lookupInstancePropertyList {
	NSMutableArray<GMYJSONModelProperty *> *ret = @[].mutableCopy;
	Class curClass = self.class;
	NSString *metaClassStr = NSStringFromClass(NSObject.class);
	// FIXME: 继承链上有重名属性怎么办？
	// dump class chain property_list
	// dump class chain ivar_list

	while (![NSStringFromClass(curClass) isEqualToString:metaClassStr]) {
		@autoreleasepool {
			unsigned pCnt = 0, iCnt = 0;

			typedef struct objc_ivar *objc_ivar_t;

			objc_property_t *_ps = class_copyPropertyList(curClass, &pCnt);
			objc_ivar_t *_is = class_copyIvarList(curClass, &iCnt);
			// 当且仅当 @property声明存在
			// 和有合成ivar实例成员变量
			NSMutableSet<NSString *> *hasProperty = [NSMutableSet set];
			for (size_t i = 0; i < pCnt; ++i) {
				[hasProperty addObject:_CSStringToNSString(property_getName(_ps[i]))];
			}

			for (size_t i = 0; i < iCnt; ++i) {
				NSString *ivarName = _CSStringToNSString(&ivar_getName(_is[i])[1]);
				if ([hasProperty containsObject:ivarName]) {
					[ret addObject:[GMYJSONModelProperty propertyByClass:curClass
																withIvar:_is[i]]];
				}
			}
			free(_ps);
			free(_is);
		}

		curClass = [curClass superclass];
	}

	return ret;
}

- (NSArray<GMYJSONModelProperty *> *)gmy_propertys {
	id p = objc_getAssociatedObject(self, _cmd);
	if (!p) {
		p = [self gmy_lookupInstancePropertyList];
	}
	return p;
}

- (void)setGmy_propertys:(NSArray<GMYJSONModelProperty *> *)gmy_propertys {
	objc_setAssociatedObject(
		self, @selector(gmy_propertys), gmy_propertys, OBJC_ASSOCIATION_RETAIN);
}

@end

// number -> __NSCFNumber
// true/false -> __NSCFBoolean
// string -> NSTaggedPointerString
// array -> __NSArray0/__NSArrayI
// object ->
// __NSSingleEntryDictionary/__NSDictionary0/__NSDictionaryI
// null -> NSNull
bool gmy_JSONNodeVal_is_Object(id val) {
	static NSArray<NSString *> *_list = nil;
	if (!_list) {
		_list = @[ @"__NSSingleEntryDictionary", @"__NSDictionary0", @"__NSDictionaryI" ];
	}
	return [_list containsObject:NSStringFromClass([val class])];
}

bool gmy_JSONNodeVal_is_Array(id val) {
	static NSArray<NSString *> *_list = nil;
	if (!_list) {
		_list = @[ @"__NSArray0", @"__NSArrayI" ];
	}
	return [_list containsObject:NSStringFromClass([val class])];
}

id convertValToMatchPropertyClass(id jsonNodeVal, GMYJSONModelProperty *p) {
	// NSNumber to NSString
	if ([[jsonNodeVal class] isSubclassOfClass:NSNumber.class] &&
		[p->_ivarClass isSubclassOfClass:NSString.class]) {
		return [jsonNodeVal stringValue];
	}

	// NSString to NSNumber
	if ([[jsonNodeVal class] isSubclassOfClass:NSNumber.class] &&
		[p->_ivarClass isSubclassOfClass:NSString.class]) {
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		return [f numberFromString:jsonNodeVal];
	}
	return nil;
}

bool gmy_propertyMatchJSONNodeVal(GMYJSONModelProperty *p, id nodeVal) {

	if ([nodeVal isMemberOfClass:p->_ivarClass]) {
		return true;
	}

	if ([nodeVal isKindOfClass:p->_ivarClass]) {
		return true;
	}

	if (gmy_JSONNodeVal_is_Object(nodeVal)) {
		NSArray<NSString *> *blockList = @[
			NSStringFromClass(NSString.class),
			NSStringFromClass(NSMutableString.class),
			NSStringFromClass(NSArray.class),
			NSStringFromClass(NSMutableArray.class)
		];
		return p->_ivarType == GMYEncodingId &&
			![blockList containsObject:NSStringFromClass(p->_ivarClass)];
	}
	return false;
}
