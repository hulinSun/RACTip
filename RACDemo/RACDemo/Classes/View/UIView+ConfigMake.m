//
//  UIView+ConfigMake.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "UIView+ConfigMake.h"

@implementation UIView (ConfigMake)

- (void )cm_configMaker:(void(^)(ConfigMaker *make))block
{
    ConfigMaker *maker = [[ConfigMaker alloc]initWithView:self];
    block(maker);
}

@end
