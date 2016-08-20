//
//  ChainViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "ChainViewController.h"



@interface ChainViewController ()

@end

@implementation ChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /**
     *  block 的链式调用
     */
//    [self easyChainDemo];
    
    [self parmChainDemo];
}

/**
 *  简单的链式调用
 */
-(void)easyChainDemo
{
    Hony *hony = [[Hony alloc]init];
    hony.shopping().eating();
}

/**
 *  带有参数的链式调用
 */
-(void)parmChainDemo
{
    Hony *hony = [[Hony alloc]init];
    // 是不是越来有mansory 的意思了
    hony.call(@"老公").takeOff(@"bar...");
}
@end


@implementation  Hony

-( Hony *(^)() )shopping
{
    return ^{
        NSLog(@"别特么烦老子敲代码，去逛街去");
        return self;
    };
}

-(Hony *(^)())eating
{
    return ^{
        NSLog(@"累了就去吃点东西.");
        return self;
    };
}


-(Hony *(^)(NSString *))takeOff
{
    return ^(NSString *bar){
        NSLog(@"脱%@",bar);
        return self;
    };
}

-(Hony *(^)(NSString *))call
{
    return ^(NSString *husband){
        NSLog(@"叫%@",husband);
        return self;
    };
}

@end