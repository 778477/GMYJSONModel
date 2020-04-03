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

@implementation NSNumber (GMYJSONModel)

- (instancetype)gmy_initWithKeyValues:(id)val {
  if ([[val class] isSubclassOfClass:NSNumber.class]) {
    return [val copy];
  }
  return nil;
}

@end

@implementation NSString (GMYJSONModel)

- (instancetype)gmy_initWithKeyValues:(id)val {
  if ([[val class] isSubclassOfClass:[NSString class]]) {
    return [val copy];
  }
  return nil;
}

@end

@implementation NSObject (GMYJSONModel)
#pragma mark - 解序列化

+ (instancetype)gmy_objectWithKeyValues:(id)keyValues {
  return [[self.class alloc] gmy_initWithKeyValues:keyValues];
}

+ (NSArray *)gmy_objectArrayWithKeyValueArray:(NSArray *)keyValues {
  NSMutableArray *mut = @[].mutableCopy;
  [keyValues enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                          BOOL *_Nonnull stop) {
    [mut addObject:[self.class gmy_objectWithKeyValues:obj]];
  }];
  return mut.copy;
}

- (instancetype)gmy_initWithKeyValues:(id)keyValues {
  NSDictionary *dic = @{};

  if ([keyValues isKindOfClass:NSString.class]) {
    NSString *str = (NSString *)keyValues;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    dic = [NSJSONSerialization JSONObjectWithData:data
                                          options:kNilOptions
                                            error:nil];
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
    if ([self.class.gmy_ignorePropertyNames
            containsObject:property->_ivarName]) {
      continue;
    }
    NSString *key =
        self.class.gmy_propertyToJSONNameMapping[property->_ivarName];
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
- (void)gmy_setProperty:(GMYJSONModelProperty *)property
        withJSONNodeVal:(id)val {

  if (!gmy_propertyMatchJSONNodeVal(property, val)) {
    id convertedVal = convertValToMatchPropertyClass(val, property);
    if (!convertedVal)
      return;
    val = convertedVal;
  }
  id penddingVal = val;
  if (property->_ivarType == GMYPropertyEncodingId) {
    if (gmy_JSONNodeVal_is_Array(val)) {
      Class itemClass =
          self.class.gmy_propertyToClsMapping[property->_ivarName];
      if (itemClass)
        penddingVal = [itemClass gmy_objectArrayWithKeyValueArray:val];
    } else if (gmy_JSONNodeVal_is_Object(val)) {
      Class objcClass = property->_ivarTypeClazz;
      if (objcClass)
        penddingVal = [objcClass gmy_objectWithKeyValues:val];
    }
  }
  [self setValue:penddingVal forKey:property->_ivarName];
  //    else {
  //		[self setValue:val forKey:property->_ivarName];
  //#define msgSend_Setter(type, typeVal)                                                              \
//	if (property->isReadOnly) {                                                                    \
//		[self setValue:val forKey:property->_ivarName];                                            \
//	} else {                                                                                       \
//		((void (*)(id, SEL, type))objc_msgSend)(self, property->_setter, typeVal);                 \
//	}
  //		switch (property->_ivarType) {
  //			case GMYPropertyEncodingTypeBOOL:
  //				msgSend_Setter(BOOL, [val boolValue]);
  //				break;
  //			case GMYPropertyEncodingTypeShort:
  //				msgSend_Setter(short, [val shortValue]);
  //				break;
  //			case GMYPropertyEncodingTypeUnsignedShort:
  //				msgSend_Setter(unsigned short, [val
  // unsignedShortValue]);
  //				break;
  //			case GMYPropertyEncodingTypeInt:
  //				msgSend_Setter(int, [val intValue]);
  //				break;
  //			case GMYPropertyEncodingTypeUnsignedInt:
  //				msgSend_Setter(unsigned int, [val
  // unsignedIntValue]);
  //				break;
  //			case GMYPropertyEncodingTypeLong:
  //				msgSend_Setter(long, [val longValue]);
  //				break;
  //			case GMYPropertyEncodingTypeUnsignedLong:
  //				msgSend_Setter(unsigned long, [val
  // unsignedLongValue]);
  //				break;
  //			case GMYPropertyEncodingTypeLongLong:
  //				msgSend_Setter(long long, [val longLongValue]);
  //				break;
  //			case GMYPropertyEncodingTypeUnsignedLongLong:
  //				msgSend_Setter(unsigned long long, [val
  // unsignedLongLongValue]);
  //				break;
  //			case GMYPropertyEncodingTypeFloat:
  //				msgSend_Setter(float, [val floatValue]);
  //				break;
  //			case GMYPropertyEncodingTypeDouble:
  //				msgSend_Setter(double, [val doubleValue]);
  //				break;
  //			default:
  //				break;
  //		}
  //#undef msgSend_Setter
  //	}
}

@end
