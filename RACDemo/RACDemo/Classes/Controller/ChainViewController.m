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
    
    UIView *view = [[UIView alloc]init];
    
    [view cm_configMaker:^(ConfigMaker *make) {
     make.bgColor([UIColor redColor])
        .coreRadius(@50)
        .frame([NSValue valueWithCGRect:CGRectMake(100, 100, 100, 100)]);
    }];
    
    [self.view addSubview:view];
    
    
    /**
     泛型 + 多态 --> 能不能扩展通用性？
     */
    UILabel *lable = [[UILabel alloc]init];
    lable.text = @"See the code in ChainViewController please";
    lable.numberOfLines = 2;
    lable.textAlignment = NSTextAlignmentCenter;
    
    [lable cm_configMaker:^(ConfigMaker *make) {
    make.bgColor([UIColor colorWithRed:.3 green:.6 blue:.5 alpha:.8])
        .frame([NSValue valueWithCGRect:CGRectMake(30, 250, 260, 66)])
        .coreRadius(@(33));
    }];
    [self.view addSubview:lable];
}

// 参考链接:http://limboy.me/tech/2013/06/19/frp-reactivecocoa.html
/**
 *  响应式编程思想：
 *  不需要考虑调用顺序，只需要知道考虑结果，类似于蝴蝶效应，产生一个事件，会影响很多东西，这些事件像流一样的传播出去，然后影响结果，借用面向对象的一句话，万物皆是流 (KVO 的实现思想)
 
 * a=2;b=3;c=a+b; b=5 --> c=??
 */

/**
 *  函数式编程思想
 *  是把操作尽量写成一系列嵌套的函数或者方法调用
 *  链式编程
 *  ReactiveCocoa被描述为函数响应式编程（FRP）框架(核心是信号)
 
 *  可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的，不会出现并发情况)。水龙头的开关默认是关的，除非有了接收方(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给接收方。可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，也可以加一个改动装置，把球改变成符合自己的需求(map)。也可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球
 */



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