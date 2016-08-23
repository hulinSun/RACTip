//
//  ColdHotController.m
//  RACDemo
//
//  Created by mac on 16/8/23.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "ColdHotController.h"

@interface ColdHotController ()

@end

@implementation ColdHotController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /**
     *  Hot Observable是主动的，尽管你并没有订阅事件，但是它会时刻推送，就像鼠标移动；而Cold Observable是被动的，只有当你订阅的时候，它才会发布消息。
     *  Hot Observable可以有多个订阅者，是一对多，集合可以与订阅者共享信息；而Cold Observable只能一对一，当有不同的订阅者，消息是重新完整发送。
     */
}
@end
