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

//参考链接 ： http://blog.sunnyxx.com/2014/03/06/rac_3_racsignal/

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
 *   想解函数一样编程 f1(x) = 2x + 1 ==> 求f1(2);
                    f2(x) = x -4; ==> f2(3);
                    f3(x) = 3x + 5 ==> f3(2)
 
            ==> 求 f1(f3(f2(3)))的值
 *   函数组合之后仍然是个函数，所以也很容易理解两个Stream对象的组合其实就是生成一个新的Stream对象，它返回了分别由两个子Stream先后运算产生的最终结果 --> 函数式编程
 */


/**
 *  push-driven是“生产一个吃一个”，而pull-driven是“吃完一个才生产下一个”，对于工厂来说前者是主动模式：生产了巧克力就“push”给各个供销商，后者是被动模式：各个供销商过来“pull”产品时才给你现做巧克力。
 *  RACSigna的push-driven的生产模式，首先，当工厂发现没有供销商签合同准备要巧克力的时候，工厂当然没有必要开动生产；只要当有一个以上准备收货的经销商时，工厂才开动生产。这就是RACSignal的休眠（cold）和激活（hot）状态，也就是所谓的冷信号和热信号。一般情况下，一个RACSignal创建之后都处于cold状态，有人去subscribe才被激活
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