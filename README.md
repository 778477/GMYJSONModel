#  README

要使用`runtime`特性自动的填充对象模型属性值，有一点需要注意的就是虽然JSON格式支持 string/number/array/dictionary 这个四种数据类型。

但dictionary其实可以对应到各种各样的类，number也是可以对到各种基本数字类型(int,unsigned,float,double)等。 

所以在做解析映射赋值的时候，我们需要关心这个属性的类型是什么，确保映射转化正确。


下面是一张code type的对应表来自Apple[Type Encodings](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1)

Code|Meaning
---|---
c|A char
i|An int
s|A short
l|A long l is treated as a 32-bit quantity on 64-bit programs.
q|A long long
C|An unsigned char
I|An unsigned int
S|An unsigned short
L|An unsigned long
Q|An unsigned long long
f|An float
d|An double
B|A C++ bool or a C99 _Bool
*|A character string(char *)
@|An object(whether statically typed or typed id)
#|A class object(Class)
:|A method selector(SEL)
[array type]|An array
{name=type}|An structure
(name=type)|A union
bnum|A bit field of num bits
^type|A pointer to type
?|An unknown type(among other things,this code is used for function pointers)

上表枚举了对象中各种可能会出现的属性类型。但对应到JSON可能会出现的类型，就要去掉一些了。

* 另外要注意的是在Objective-C中`BOOL`对应的type code是`c`。是个char类型，空间占一个字节。。

* `long double` Objective-C是不支持的，对应的encode type还是`d`

* 枚举`enum`类型等同于`int`


Apple 还有一张[Property Attribute](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW24) 可以看到`property`一些属性修饰词在`runtime`上的表现。

比如

* 自定义了 Getter和Setter
* readonly,readwrite
* copy,strong,weak




#  实现细节


如果通过`runtime class_copyPropertyList`获取到属性列表再解析赋值的话，是会漏掉下面这些属性的：

1. 不使用`property`声明的属性

~~2. 使用`@dynamic`不自动合成Getter和Setter的属性。~~

要完成彻底的解析赋值，应该要关心对象中的`iVar`(instance variables)。`@dynamic`的属性是没有`ivar`的。

#  扩展阅读

[KVC 和 KVO](https://www.objccn.io/issue-7-3/)
