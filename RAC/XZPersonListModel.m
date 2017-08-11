//
//  XZPersonListModel.m
//  RAC
//
//  Created by admin on 2016/8/8.
//  Copyright © 2016年 XZ. All rights reserved.
//

#import "XZPersonListModel.h"

@implementation XZPersonListModel

- (RACSignal *)loadPersons {
    
    NSLog(@"==============%s",__FUNCTION__);
    
    // 直接返回一个 RAC 的信号
    // 一旦有了订阅者，block内部的代码能够执行
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        // 发送不同的信号
        _personList = [NSMutableArray array];
        
        // 模拟异步加载数据
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            // 模拟延时
            [NSThread sleepForTimeInterval:1.0];
            
            // 创建数据
            for (NSInteger i = 0; i < 20; i++) {
                XZPerson *person = [[XZPerson alloc] init];
                
                person.name = [@"zhangsan - " stringByAppendingFormat:@"%ld",(long)i];
                person.age = 15 + arc4random_uniform(20);
                
                [_personList addObject:person];
            }
            
            NSLog(@"%@",_personList);
            
            // 完成回调发送信号给订阅者，主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isError = NO;
                if (isError) {
                    [subscriber sendError:[NSError errorWithDomain:@"cn.xzproject.error" code:1001 userInfo:@{@"error message":@"异常错误"}]];
                }else {
                    [subscriber sendNext:_personList];
                }
                
                // 发送完成事件
                [subscriber sendCompleted];
                
            });
        });
        return nil;
    }];

}

@end
