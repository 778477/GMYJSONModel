//
//  ViewController.m
//  Example
//
//  Created by miaoyou.gmy on 2020/2/25.
//  Copyright © 2020 miaoyou.gmy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    id _viewModel;
}

/**
 实验KVC 和 KVO
 
 结论：
 使用KVC setValue:forKey: 最终还是会落到 setter上，进行触发KVO
    KVC比直接调用setter还是有性能开销的。按照文档提示：
    1. 搜索当前类的访问器，支持别名(an accessor method whose name matches the pattern -set<Key>)
    2. 当accessInstanceVariablesDirectly = YES时，进行查找实例成员变量，并完成设置
    3. -setValue:forUndefinedKey: 被调用，并抛出异常
 
 
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver:self
           forKeyPath:@"viewModel"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self setValue:@"viewModel" forKey:@"viewModel"];
    
    NSLog(@"%@", _viewModel);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
}

#pragma mark -


@end
