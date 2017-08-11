//
//  XZPerson.m
//  RAC
//
//  Created by admin on 2016/8/8.
//  Copyright © 2016年 XZ. All rights reserved.
//

#import "XZPerson.h"

@implementation XZPerson

- (NSString *)description {
    NSArray *keys = @[@"name",@"age"];
    return [self dictionaryWithValuesForKeys:keys].description;
}

@end
