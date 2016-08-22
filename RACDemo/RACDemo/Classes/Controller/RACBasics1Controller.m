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


@property (nonatomic, strong)RACCommand *conmmand;
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
    
//    [self sequence];
    [self command];
    
}

/**
 *  操作方法秩序
 */
-(void)nextOrder{
    
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        // 执行[subscriber sendNext:@1];之前会调用这个Block
        NSLog(@"doNext");;
    }] doCompleted:^{
        // 执行[subscriber sendCompleted];之前会调用这个Block
        NSLog(@"doCompleted");;
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
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
 * 可以用map flatmap reduce filter 等高阶函数
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

/**
 *  处理事件类: :RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。
 */
-(void)command{
    
    /** 一、RACCommand使用步骤:
     *  创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
     *  在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
     *  执行命令 - (RACSignal *)execute:(id)input
    
    // 二、RACCommand使用注意:
     * 1.signalBlock必须要返回一个信号，不能传nil.
     * 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
     * 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
     * 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
    
    // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
     
     * 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
     * 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
    
    // 四、如何拿到RACCommand中返回信号发出的数据。
     
     * 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
     * 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
    
    // 五、监听当前命令是否正在执行executing
    
    // 六、使用场景,监听按钮点击，网络请求 
     */
    
    
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        // 创建空信号,必须返回信号 return [RACSignal empty];
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            // 网络请求 ...
            [subscriber sendNext:@"请求数据"];
            
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            
            return nil;
        }];
        
    }];
    
    // 强引用命令，不要被销毁，否则接收不到数据
    _conmmand = command;
    
    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) { // 返回的是信号
        
        NSLog(@"1 class = %@", [x class]);
        [x subscribeNext:^(id x) {
            
            NSLog(@"%@ ",x);
            
            NSLog(@"2 class = %@", [x class]);
        }];
        
    }];
    
    // RAC高级用法
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
            
        }else{
            // 执行完成
            NSLog(@"执行完成");
        }
        
    }];
    // 5.执行命令
    [self.conmmand execute:@1];
}


/**
 *  RACMulticastConnection
 */

-(void)mutiCastConn{
    
    /** RACMulticastConnection使用步骤:
     * 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
     * 2.创建连接 RACMulticastConnection *connect = [signal publish];
     * 3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
     * 4.连接 [connect connect]
    
    // RACMulticastConnection底层原理:
     * 1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
     * 2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
     * 3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
     > 3.1.订阅原始信号，就会调用原始信号中的didSubscribe
     > 3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
     * 4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
     > 4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
    */
    
    // 需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
    // 解决：使用RACMulticastConnection就能解决.
    
    /**
    // 1.创建请求信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        return nil;
    }];
    
     // 2. 订阅信号
    [signal subscribeNext:^(id x) { NSLog(@"接收数据");}];
    [signal subscribeNext:^(id x) { NSLog(@"接收数据");}];
    
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    */
    
    // RACMulticastConnection:解决重复请求问题
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@1];
        return nil;
    }];
    
    // 2.创建连接
    RACMulticastConnection *connect = [signal publish];
    
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    
    [connect.signal subscribeNext:^(id x) {NSLog(@"订阅者一信号");}];
    [connect.signal subscribeNext:^(id x) {NSLog(@"订阅者二信号");}];
    
    // 4.连接,激活信号
    [connect connect];
}

/**
 *  当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法。
 *  使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
 *  和zip 类似，还特么没zip 灵活呢
 */
-(void)liftSel{
    
    // 处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
}

// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{   NSLog(@"更新UI%@  %@",data,data1); }
@end
