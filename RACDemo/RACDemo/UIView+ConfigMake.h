//
//  UIView+ConfigMake.h
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfigMaker.h"


@interface UIView (ConfigMake)

- (void )cm_configMaker:(void(^)(ConfigMaker *make))block;

@end
