//
//  ChainViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "ChainViewController.h"
#import "UIView+ConfigMake.h"
#import "ConfigMaker.h"


@interface ChainViewController ()

@end

@implementation ChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /**
     *  block 的链式调用
     *  特点 ： 函数的返回值是 block ，而 block 的返回值是 对象本身 。这样就可以了
     */
    [self easyChainDemo];
    
    [self parmChainDemo];
    
    [self config];
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
    // 是不是越来有masonry 的意思了
    hony.call(@"老公").takeOff(@"bar...");
}


/**
 *  就是这么吊
 */
-(void)config{
    
    UIView *v = [[UIView alloc]init];
    [v cm_configMaker:^(ConfigMaker *make) {
        
    make.bgColor([UIColor redColor])
        .coreRadius(@20)
        .frame([NSValue valueWithCGRect:CGRectMake(100, 100, 200, 100)]);
    }];
    [self.view addSubview:v];
}
@end


@implementation  Hony

-( Hony *(^)() )shopping
{
    return ^{
        NSLog(@"别特么烦老子敲代码，逛街去");
        return self;
    };
}

-(Hony *(^)())eating
{
    return ^{
        NSLog(@"逛累了就去吃点东西.");
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