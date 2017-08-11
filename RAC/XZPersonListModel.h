//
//  XZPersonListModel.h
//  RAC
//
//  Created by admin on 2016/8/8.
//  Copyright © 2016年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "XZPerson.h"

// 列表数据模型，负责加载数据(包含网络数据/本地缓存数据)
@interface XZPersonListModel : NSObject

// 联系人数组,泛型数组
@property (nonatomic) NSMutableArray <XZPerson *> *personList;

// 加载联系人数组 返回一个RAC的信号
- (RACSignal *)loadPersons;

@end
