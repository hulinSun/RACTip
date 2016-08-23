//
//  AdvancedViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "AdvancedViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

//  参考链接 http://www.jianshu.com/p/a4fefb434652?utm_campaign=hugo&utm_medium=reader_share&utm_content=note
@interface AdvancedViewController ()

@property (nonatomic, strong)UITextField *textField;



@end

@implementation AdvancedViewController


- (UITextField *)textField{
    if (!_textField) {
        self.textField =[[UITextField alloc]init];
        _textField.frame = CGRectMake(100, 100, 200, 44);
        _textField.backgroundColor = [UIColor cyanColor];
    }
    return _textField;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textField];
    
    
//    [self signalDemo1];
    
//    [self map];
//    [self filter];
//    [self delay];
    
//    [self startWith];
//    [self timeout];
//    [self take];
//    [self skip];
//    [self takeLast];
//    [self takeUntil];
//    [self takeWhileBlock];
//    [self skipWhileBlock];
//    [self skipUntilBlock];
//    [self throttle];
    
//    [self signalOfSignal];
//    [self flatmap];
    [self repeat];
}



#pragma mark - 信号的操作

/**
 *  简单的信号操作
 */
-(void )signalDemo1{
    
    // 创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送一个信号
        [subscriber sendNext:@"发送啦"];
        
        [subscriber sendError:[NSError errorWithDomain:@"domain" code:200 userInfo:@{@"key" : @"value"}]];
        
        [subscriber sendCompleted]; // 发送完之后一定要调用 sendCompleted 告诉信号发送完毕
        
        //        return [RACDisposable disposableWithBlock:^{
        //            NSLog(@"取消信号的操作啦"); // 我们会看到，接受完信号之后。会自动调用取消信号的方法
        //        }];
        return nil;
    }];
    
    // 订阅信号
    RACDisposable *dispose = [signal subscribeNext:^(id x) {
        NSLog(@"接受这个信号啦 x = %@",x);
    }error:^(NSError *error) {
        NSLog(@" 接收到了错误 error = %@",error.description);
    } completed:^{
#pragma mark - 这里为什么不执行？
        NSLog(@"接受信号完毕");
    }];
    
    //    [dispose dispose]; // 取消订阅信号
}

/**
 *  map
 */
-(void)map{
    // map ： 映射。你给我一个东西，我吧这个东西经过某个规则加工之后，返回基于你给我的东西的一个结果给你
    
    // x --> f(x)
    
    /** 写法1
    [[[self.textField rac_signalForControlEvents:UIControlEventEditingChanged] map:^id(UITextField *field) {
        NSLog(@"text = %@",field.text);
        return  @(field.text.length);
    }] subscribeNext:^(NSNumber *number) {
        NSLog(@"length = %@",number);
    }]; */
    
    [[[self.textField rac_textSignal] map:^id(NSString *text) {
        NSLog(@"text = %@",text);
        return [NSString stringWithFormat:@"%@  *",text];
    }] subscribeNext:^(id x) { // 订阅这个被map 操作之后的信号
        NSLog(@"x = %@",x);
    }];
}

/**
 *  过滤
 */
-(void)filter{
    
    // 过滤掉不符合条件的情况
    [[[self.textField rac_textSignal]filter:^BOOL(NSString *text) {
        NSLog(@"text = %@",text);
        // 意思是 只有 text 的长度大于4 才可以去订阅这个信号
        return text.length > 4;
    }] subscribeNext:^(id x) { // 订阅这个经过过滤操作的信号
        NSLog(@"只有x 的长度大于4 才会打印哦x = %@",x);
        
    }];
}

/**
 *  延迟
 */
-(void)delay{
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"来了"];
        [subscriber sendCompleted];
        return nil;
    }] delay:2];
    
    NSLog(@"-----");
    
    [signal subscribeNext:^(id x) {
        // 两秒之后才来到这个地方 , 可以理解为这个信号两秒之后才发出信号 。 也可以理解为两秒之后再订阅
        NSLog(@"接收到了订阅的信号 x = %@",x);
    }];
}


/**
 *  startWith 其实就是 将传过来的id对象 放在最前面，等同于 sendNext 放在最前面
 */
-(void)startWith{
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"到底谁装逼"];
        [subscriber sendNext:@"Talk is cheap , show me the code"];
        [subscriber sendCompleted];
        return nil;
    }] startWith:@"别装逼，亮代码吧"];
    
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
}


/**
 *  超时操作: 2s 内都接收信号，2s之后还没接收到信号，走error
 */
-(void)timeout{
    
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:3 schedule:^{
            [subscriber sendNext:@"come on"];
            [subscriber sendCompleted];
        }];
        return  nil;
        
    }] timeout:2 onScheduler:[RACScheduler currentScheduler]];
    
    NSLog(@"-------");
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }error:^(NSError *error) {
        NSLog(@"timeout -> 超时了error");
    }completed:^{
        NSLog(@"completed");
    }];
}


/**
 *  同时发出了多个消息，即多个sendNext ，只取给的几个.只发出前两个消息
 *  从开始一共取N次的信号
 */
-(void)take{

    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Talk is cheap , show me the code 1"];
        [subscriber sendNext:@"Talk is cheap , show me the code 2"];
        [subscriber sendNext:@"Talk is cheap , show me the code 3"];
        [subscriber sendNext:@"Talk is cheap , show me the code 4"];
        [subscriber sendNext:@"Talk is cheap , show me the code 5"];
        [subscriber sendCompleted];
        return nil;
    }] take:2];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x); // 只接收到了两次消息
    }];
}

/**
 *  跳过 第一个消息，接收后面的所有消息
 */
-(void)skip{
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Talk is cheap , show me the code 1"];
        [subscriber sendNext:@"Talk is cheap , show me the code 2"];
        [subscriber sendNext:@"Talk is cheap , show me the code 3"];
        [subscriber sendNext:@"Talk is cheap , show me the code 4"];
        [subscriber sendNext:@"Talk is cheap , show me the code 5"];
        [subscriber sendCompleted];
        return nil;
    }] skip:1];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x); //
    }];
}


/**
 *  值去后面三个发出的消息 ,
 *  取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号
 */
-(void)takeLast{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Talk is cheap , show me the code 1"];
        [subscriber sendNext:@"Talk is cheap , show me the code 2"];
        [subscriber sendNext:@"Talk is cheap , show me the code 3"];
        [subscriber sendNext:@"Talk is cheap , show me the code 4"];
        [subscriber sendNext:@"Talk is cheap , show me the code 5"];
        [subscriber sendCompleted];
        return nil;
    }] takeLast:3];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x); // 只接收到后面三个的消息，
    }];
}

/**
 *  获取信号直到某个信号执行完成
 */
-(void)takeUntil
{
    RACSignal *until = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"until"];
        [subscriber sendCompleted];
        return  nil;
    }];
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Talk is cheap , show me the code 1"];

        [subscriber sendCompleted];
        return nil;
    }] takeUntil:until];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
}


/**
 *  当这个block 返回为yes 的时候，才去订阅这个消息 subscribeNext 会执行， 
 *  no 的话。不去订阅这个消息 ， subscribeNext不会执行
 */
-(void)takeWhileBlock{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Talk is cheap , show me the code 1"];
        
        [subscriber sendCompleted];
        return nil;
    }] takeWhileBlock:^BOOL(id x) {
        NSLog(@"takeWhileBlock x = %@",x);
        return NO;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
}


/**
 *  如果 skipWhileBlock 返回no， 会执行一次skipWhileBlock ，
 *  如果skipWhileBlock 返回yes 。不会执行skipWhileBlock
 *  都会执行 subscribeNext
 */
-(void)skipWhileBlock{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Talk is cheap , show me the code 1"];
        [subscriber sendNext:@"Talk is cheap , show me the code 2"];
        [subscriber sendNext:@"Talk is cheap , show me the code 3"];

        
        [subscriber sendCompleted];
        return nil;
    }] skipWhileBlock:^BOOL(id x) {
        NSLog(@"skipWhileBlock x = %@",x);
        return YES;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
}

/**
 *  和 skipWhileBlock 情况相反
 */
-(void)skipUntilBlock
{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Talk is cheap , show me the code 1"];
        [subscriber sendNext:@"Talk is cheap , show me the code 2"];
        [subscriber sendNext:@"Talk is cheap , show me the code 3"];
        
        
        [subscriber sendCompleted];
        return nil;
    }] skipUntilBlock:^BOOL(id x) {
        NSLog(@"skipUntilBlock x = %@",x);
        return NO;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
}

/**
 *  throttle节流 ： 各种不同情况的优化
 *  distinctUntilChanged : 如果新的消息，和上一次的消息是一样的，只发送一次消息 , :当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
 *  ignore : 忽略某个消息,忽略某个极端的情况
 *  switchToLatest:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
 */
-(void)throttle{
    
    [[[[[self.textField rac_textSignal] throttle:0.4] distinctUntilChanged] ignore:@""] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

/**
 *  信号的信号
 * switchToLatest : 处理信号的信号，就是处理最后的那个信号
 */
-(void)signalOfSignal
{
    
    [[[[[[[self.textField rac_textSignal] throttle:0.4] distinctUntilChanged] ignore:@""]
     map:^id(id value) {
         
         return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
             [subscriber sendNext:value];
             [subscriber sendCompleted];
             
             return [RACDisposable disposableWithBlock:^{
                  // 这里是取消订阅信号的代码.
             }];
         }];
     }] switchToLatest] subscribeNext:^(id x) {
         // ...
        NSLog(@"%@",x);
    }];
}



/**
 *  扁平化映射 . 信号的信号( 类似于盒子的盒子)
 */
-(void)flatmap{
    
    /***
    [[[self.textField rac_textSignal] map:^id(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:value];
            [subscriber sendCompleted];
            return  nil;
        }];
    }] subscribeNext:^(id x) {
        // 订阅之后，接受到的也是一个信号。怎么玩。
        NSLog(@"x = %@ class = %@",x , [x class]);
    }]; */
    
    
    // 扁平化映射
    [[[self.textField rac_textSignal] flattenMap:^id(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:value];
            [subscriber sendCompleted];
            return  nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"x = %@ class = %@",x , [x class]);
    }];
}

/**
 *  无线循环--> 内存暴涨，会crash 。一般不直接使用
 */
-(void)repeat{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"Talk is cheap , show me the code "];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[[signal repeat] take:10] subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }completed:^{
        NSLog(@"-----over------");
    }];
}

/**
 *  用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
 */
-(void)switchTolatst
{
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    
    // 获取信号中信号最近发出信号，订阅最近发出的信号。
    // 注意switchToLatest：只能用于信号中的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    [signalOfSignals sendNext:signal];
    [signal sendNext:@1];
}

/**
 * flattenMap map 用于把源信号内容映射成新的内容。
 * concat 组合 按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号
 * then 用于连接两个信号，当第一个信号完成，才会连接then返回的信号。
 * merge 把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
 * zipWith 把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
 * combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
 * reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
 * filter:过滤信号，使用它可以获取满足条件的信号.
 * ignore:忽略完某些值的信号.
 * distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
 * take:从开始一共取N次的信号
 * takeLast:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
 * takeUntil:(RACSignal *):获取信号直到某个信号执行完成
 * skip:(NSUInteger):跳过几个信号,不接受。
 * switchToLatest:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
 * doNext: 执行Next之前，会先执行这个Block
 * doCompleted: 执行sendCompleted之前，会先执行这个Block
 * timeout：超时，可以让一个信号在一定的时间后，自动报错。
 * interval 定时：每隔一段时间发出信号
 * delay 延迟发送next。
 * retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
 * replay重放：当一个信号被多次订阅,反复播放内容
 * throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。
 */
@end
