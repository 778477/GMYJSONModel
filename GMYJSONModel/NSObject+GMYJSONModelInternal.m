//
//  NSObject+GMYJSONModelInternal.m
//  GMYJSONModel
//
//  Created by miaoyou.gmy on 2020/2/21.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "NSObject+GMYJSONModelInternal.h"
#import <objc/runtime.h>

GMYPropertyEncodingType matchPropertyAttribueDescript(const char c) {
	switch (c) {
		case _C_ID:
			return GMYPropertyEncodingId;
		case _C_BOOL:
			return GMYPropertyEncodingTypeBOOL;
		case _C_SHT:
			return GMYPropertyEncodingTypeInt;
		case _C_USHT:
			return GMYPropertyEncodingTypeInt;
		case _C_INT:
			return GMYPropertyEncodingTypeInt;
		case _C_UINT:
			return GMYPropertyEncodingTypeUnsignedInt;
		case _C_LNG:
			return GMYPropertyEncodingTypeLong;
		case _C_ULNG:
			return GMYPropertyEncodingTypeUnsignedLong;
		case _C_LNG_LNG:
			return GMYPropertyEncodingTypeLongLong;
		case _C_ULNG_LNG:
			return GMYPropertyEncodingTypeUnsignedLongLong;
		case _C_FLT:
			return GMYPropertyEncodingTypeFloat;
		case _C_DBL:
			return GMYPropertyEncodingTypeDouble;
		default:
			break;
	}

	return GMYPropertyEncodingUnknown;
}

NS_INLINE NSString *gmy_cs_to_ns(const char *str) { return [NSString stringWithUTF8String:str]; }

@implementation GMYJSONModelPropertyAttribute

+ (instancetype)attributeWithObjc_property_attribute_t:(objc_property_attribute_t)objc_p_a {
	__auto_type a = [[GMYJSONModelPropertyAttribute alloc] init];
	a->_name = gmy_cs_to_ns(objc_p_a.name);
	a->_val = gmy_cs_to_ns(objc_p_a.value);
	return a;
}

@end

@implementation GMYJSONModelProperty

+ (instancetype)propertyWithObjc_property_t:(objc_property_t)objc_p {

	__auto_type p = [[GMYJSONModelProperty alloc] init];
	p->_ivarName = gmy_cs_to_ns(property_getName(objc_p));
	unsigned cnt = 0;
	objc_property_attribute_t *alist = property_copyAttributeList(objc_p, &cnt);
	for (size_t i = 0; i < cnt; i++) {
		// The property defines a custom setter selector name.
		if (alist[i].name[0] == 'S') {
			p->_setter = NSSelectorFromString(gmy_cs_to_ns(alist[i].value));
		} else if (alist[i].name[0] == 'T') {
			NSString *tmp = gmy_cs_to_ns(alist[i].value);
			p->_ivarType = matchPropertyAttribueDescript(alist[i].value[0]);
			if (alist[i].value[0] == '@') {
				p->_ivarTypeClazz =
					NSClassFromString([tmp substringWithRange:NSMakeRange(2, tmp.length - 3)]);
			}
		}
	}
	free(alist);
	return p;
}

@end

@implementation NSObject (GMYJSONModelInternal)

- (NSArray<GMYJSONModelProperty *> *)gmy_lookupInstancePropertyList {
	// 1. object interface. contains super propertylist
	// 2. object protocol. propertylist
	// 3. object category. propertylist
	NSMutableArray<GMYJSONModelProperty *> *ret = @[].mutableCopy;
	Class curClazz = self.class;
	NSString *metaClassStr = NSStringFromClass(NSObject.class);
	// FIXME: 继承链上有重名属性怎么办？
	while (![NSStringFromClass(curClazz) isEqualToString:metaClassStr]) {
		unsigned count = 0;
		objc_property_t *plist = class_copyPropertyList(curClazz, &count);
		for (size_t i = 0; i < count; i++) {
			[ret addObject:[GMYJSONModelProperty propertyWithObjc_property_t:plist[i]]];
		}
		free(plist);
		curClazz = [curClazz superclass];
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
// array->__NSArray0/__NSArrayI
// object->__NSDictionary0/__NSDictionaryI
// null->NSNull
bool gmy_propertyTypeMatchJSONValClass(GMYJSONModelProperty *p, Class cls) {
	NSString *str = NSStringFromClass(cls);

	__auto_type eqByClassBlock = ^(Class lhs, Class rhs) {
		return [NSStringFromClass(lhs) isEqualToString:NSStringFromClass(rhs)];
	};

	if ([str isEqualToString:@"__NSCFNumber"]) {
		return p->_ivarType >= GMYPropertyEncodingTypeShort &&
			p->_ivarType <= GMYPropertyEncodingTypeDouble;
	} else if ([str isEqualToString:@"__NSCFBoolean"]) {
		return p->_ivarType == GMYPropertyEncodingTypeBOOL;
	} else if ([str isEqualToString:@"NSTaggedPointerString"]) {
		return p->_ivarType == GMYPropertyEncodingId &&
			(eqByClassBlock(NSString.class, p->_ivarTypeClazz) ||
			 eqByClassBlock(NSMutableString.class, p->_ivarTypeClazz));
	} else if ([str isEqualToString:@"__NSArray0"] || [str isEqualToString:@"__NSArrayI"]) {
		return p->_ivarType == GMYPropertyEncodingId &&
			(eqByClassBlock(p->_ivarTypeClazz, NSArray.class) ||
			 eqByClassBlock(p->_ivarTypeClazz, NSMutableArray.class));
	} else if (
		[str isEqualToString:@"__NSDictionary0"] || [str isEqualToString:@"__NSDictionaryI"]) {
	}
	return false;
}