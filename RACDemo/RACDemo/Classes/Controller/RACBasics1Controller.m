//
//  RACBasics1Controller.m
//  RACDemo
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "RACBasics1Controller.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACBasics1Controller ()

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UIButton *button;


/**
 *  代理信号
 */
@property (nonatomic, strong)RACSubject *delegateSubject;

@end

@implementation RACBasics1Controller

//参考链接 ： http://www.jianshu.com/p/87ef6720a096 ， http://nshipster.cn/reactivecocoa/

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
        [_button setTitle:@"点我啊" forState:UIControlStateNormal];
        _button.layer.cornerRadius = 5;
        _button.clipsToBounds = YES;
    }
    return _button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.button];
    
//    [self subject];
//    [self replaySubject];
    
    
    // delegateSubject 一定要有值才能调用订阅信号的方法
    self.delegateSubject = [RACSubject subject];
    [self.delegateSubject subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
    [self replaceDelegate];
    
    [self sequence];
    
}


-(void)signal{
    /**
     *  信号类(RACSiganl)，只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。
     
     *   默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。
     */
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送信号"];
        [subscriber sendError:[NSError errorWithDomain:@"domain" code:214 userInfo:@{@"key" : @"value"}]];
        // 一定要调用completed ,内部会 取消订阅这个信号 dispose
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
//            block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
             // 执行完Block后，当前信号就不在被订阅了。
        }];
    }];
    
    // 订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }error:^(NSError *error) {
        NSLog(@"error = %@",error);
    }completed:^{
        NSLog(@"completed");
    }];
    
    /** 一个signal的生命由很多下一个(next)事件和一个错误(error)或完成(completed)事件组成（后两者不同时出现）
     
     *   Sequence是一种集合，很像 NSArray。但和数组不同的是，一个sequence里的值默认是延迟加载的（只有需要的时候才加载），这样的话如果sequence只有一部分被用到，那么这种机制就会提高性能。像Cocoa的集合类型一样，sequence不接受 nil 值。
     *
     */
    
    /**
     *  RACSubscriber : 订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据
     *  RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
     */
    
}

-(void)subject{
    
    /**
     *  RACReplaySubject与RACSubject区别
     *  RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。(可以代替代理，不在需要些自定义代理 )
     *  RACReplaySubject:重复提供信号类，RACSubject的子类。
     *  RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以。
     *  如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类
     *  可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。
     */
    
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"x1 = %@",x);
    }];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"x2 = %@",x);
    }];
    
    [subject sendNext:@"subject"];
    
    //如果发送信号写在 订阅信号之前，将什么都不会打印。 subject 必须先订阅信号， 在发送信号
    
    
    /** 使用步骤
     *  1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
     *  2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
     *  3.发送信号 sendNext:(id)value
     */
    
}

-(void)replaySubject{
    
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    [replaySubject sendNext:@"replaySubject1"];
    [replaySubject sendNext:@"replaySubject2"];
    
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"x1 = %@",x);
    }];
    
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"x2 = %@",x);
    }];
    
    
    // RACReplaySubject 可以先发送信号，在订阅信号，而 RACSubject 只能先订阅信号，在发送信号/
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。 (1 2 1 2) 与 (1 1 2 2)
    // sendNext 发送信号的放在订阅信号的之前，调用结果也不一样
}

/**
 *  subject 替换代理用法
 */
-(void)replaceDelegate{
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"I clicked the button, tell someone the things");
        
        // 通知代理
        if (self.delegateSubject) {
            [self.delegateSubject sendNext:@"the thing ..."];
        }
    }];
}

/**
 *  RAC 集合类
 */
-(void)sequence{
    
    // 数组
    NSArray *numbers = @[@1,@2,@3,@4];

    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

    
    // 字典
    NSDictionary *dict = @{@"name":@"shl",@"age":@22};
    
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;

//                NSString *key = x[0];
//                NSString *value = x[1];

//        NSLog(@"first = %@ value = %@",x.first , x.second);
        
        NSLog(@"%@ %@",key,value);
    
    }];

    
}
@end
