//
//  RACBasics2Controller.m
//  RACDemo
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "RACBasics2Controller.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACReturnSignal.h"

@interface RACBasics2Controller ()

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UIButton *button;

@end

@implementation RACBasics2Controller

// 原文链接：http://www.jianshu.com/p/e10e5ca413b7
- (UITextField *)textField{
    if (!_textField) {
        self.textField =[[UITextField alloc]init];
        _textField.frame = CGRectMake(100, 100, 200, 44);
        _textField.backgroundColor = [UIColor cyanColor];
    }
    return _textField;
}


- (UIButton *)button{
    if (!_button) {
        self.button =[[UIButton alloc]init];
        _button.frame = CGRectMake(200, 200, 100, 40);
        _button.backgroundColor = [UIColor colorWithRed:0.4 green:.5 blue:.6 alpha:.8];
        _button.layer.cornerRadius = 5;
        _button.clipsToBounds = YES;
    }
    return _button;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.button];
    [self.view addSubview:self.textField];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //  所有的信号（RACSignal）都可以进行操作处理，因为所有操作方法都定义在RACStream.h中，因此只要继承RACStream就有了操作处理方法。
    
    /**
     *  运用的是Hook（钩子）思想，Hook是一种用于改变API(应用程序编程接口：方法)执行结果的技术.
     *  Hook用处：截获API调用的技术。
     *  Hook原理：在每次调用一个API返回结果之前，先执行你自己的方法，改变结果的输出。
     */
//    [self bind];
//    [self faltmap];
//    [self then];
    
    [self thenExa];
}

/**
 *  绑定
 */
-(void)bind{
    
    /**
     *  ReactiveCocoa操作的核心方法是bind（绑定）,而且RAC中核心开发方式，也是绑定，之前的开发方式是赋值，而用RAC开发，应该把重心放在绑定，也就是可以在创建一个对象的时候，就绑定好以后想要做的事情，而不是等赋值之后在去做事情。
     
     *  列如：把数据展示到控件上，之前都是重写控件的setModel方法，用RAC就可以在一开始创建控件的时候，就绑定好数据。
     
     * 在开发中很少使用bind方法，bind属于RAC中的底层方法，RAC已经封装了很多好用的其他方法，底层都是调用bind，用法比bind简单.
     */
    
    /**
     *  在返回结果前，拼接，使用RAC中bind方法做处理。
     * bind方法参数:需要传入一个返回值是RACStreamBindBlock的block参数
     * RACStreamBindBlock是一个block的类型，返回值是信号，参数（value,stop），因此参数的block返回值也是一个block。
     
     // RACStreamBindBlock:
     * 参数一(value):表示接收到信号的原始值，还没做处理
     * 参数二(*stop):用来控制绑定Block，如果*stop = yes,那么就会结束绑定。
     * 返回值：信号，做好处理，在通过这个信号返回出去，一般使用RACReturnSignal,需要手动导入头文件RACReturnSignal.h。
     
     // bind方法使用步骤:
     * 1.传入一个返回值RACStreamBindBlock的block。
     * 2.描述一个RACStreamBindBlock类型的bindBlock作为block的返回值。
     * 3.描述一个返回结果的信号，作为bindBlock的返回值。
     * 注意：在bindBlock中做信号结果的处理。
     
     // 底层实现:
     * 1.源信号调用bind,会重新创建一个绑定信号。
     * 2.当绑定信号被订阅，就会调用绑定信号中的didSubscribe，生成一个bindingBlock。
     * 3.当源信号有内容发出，就会把内容传递到bindingBlock处理，调用bindingBlock(value,stop)
     * 4.调用bindingBlock(value,stop)，会返回一个内容处理完成的信号（RACReturnSignal）。
     * 5.订阅RACReturnSignal，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
     
     * 注意:不同订阅者，保存不同的nextBlock，看源码的时候，一定要看清楚订阅者是哪个。
     */
    
    
    // 需求： 在 文字改变前 加上输出：
    [[self.textField.rac_textSignal bind:^RACStreamBindBlock{
        
        return ^RACStream *(id value, BOOL *stop){
            
            // 什么时候调用block:当信号有新的值发出，就会来到这个block。
            
            // block作用:做返回值的处理
            
            // 做好处理，通过信号返回出去.
            return [RACReturnSignal return:[NSString stringWithFormat:@"输出:%@",value]];
        };
    }] subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
    
}


/**
 *  map 映射
 */
-(void)map{
    // Map作用:把源信号的值映射成一个新的值
    
    /** Map使用步骤:
     * 1.传入一个block,类型是返回对象，参数是value
     * 2.value就是源信号的内容，直接拿到源信号的内容做处理
     * 3.把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。
    
    // Map底层实现:
     * 0.Map底层其实是调用flatternMap,Map中block中的返回的值会作为flatternMap中block中的值。
     * 1.当订阅绑定信号，就会生成bindBlock。
     * 3.当源信号发送内容，就会调用bindBlock(value, *stop)
     * 4.调用bindBlock，内部就会调用flattenMap的block
     * 5.flattenMap的block内部会调用Map中的block，把Map中的block返回的内容包装成返回的信号。
     * 5.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
     * 6.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
     */
    
    [[_textField.rac_textSignal map:^id(id value) {
        // 当源信号发出，就会调用这个block，修改源信号的内容
        // 返回值：就是处理完源信号的内容。
        return [NSString stringWithFormat:@"输出:%@",value];
    }] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}


/**
 *  扁平化映射
 */
-(void)faltmap{
    
    /**
     * flattenMap作用:把源信号的内容映射成一个新的信号，信号可以是任意类型。
     
     // flattenMap使用步骤:
     * 1.传入一个block，block类型是返回值RACStream，参数value
     * 2.参数value就是源信号的内容，拿到源信号的内容做处理
     * 3.包装成RACReturnSignal信号，返回出去。
     
     // flattenMap底层实现:
     * 0.flattenMap内部调用bind方法实现的,flattenMap中block的返回值，会作为bind中bindBlock的返回值。
     * 1.当订阅绑定信号，就会生成bindBlock。
     * 2.当源信号发送内容，就会调用bindBlock(value, *stop)
     * 3.调用bindBlock，内部就会调用flattenMap的block，flattenMap的block作用：就是把处理好的数据包装成信号。
     * 4.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
     * 5.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
     *
     */
    [[[self.textField.rac_textSignal flattenMap:^RACStream *(id value) {
        return [RACReturnSignal return:[NSString stringWithFormat:@"输出：%@",value]];
    }]ignore:@"输出：" ]subscribeNext:^(id x) {
        // x 已经被压平了。signal of signals
        
        NSLog(@"x = %@",x);
    }];
    
    /**
     * 1.FlatternMap中的Block返回信号。
     * 2.Map中的Block返回对象。
     * 3.开发中，如果信号发出的值不是信号，映射一般使用Map
     * 4.开发中，如果信号发出的值是信号，映射一般使用FlatternMap。
     * signal Of signals用FlatternMap。
     */
}


/**
 * then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号
 */
-(void)then{
    // 注意使用then，之前信号的值会被忽略掉.
    // 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@2];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        
        // 只能接收到第二个信号的值，也就是then返回信号的值
        NSLog(@"%@",x);
    }];
}

-(void)thenExa
{
    //用那个著名的脑筋急转弯说明吧，“如何把大象放进冰箱里”  第一步，打开冰箱；第二步，把大象放进冰箱；第三步，关上冰箱门。
    
    //与信号传递类似，不过使用 `then` 表明的是秩序，没有传递value
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"RAC信号串------打开冰箱");
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------把大象放进冰箱");
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------关上冰箱门");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"RAC信号串------Over");
    }];
}
@end
