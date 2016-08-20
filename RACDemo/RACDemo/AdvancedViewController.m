//
//  AdvancedViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "AdvancedViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

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
 *  值去后面三个发出的消息
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
 *  待处理
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
 *  distinctUntilChanged : 如果新的消息，和上一次的消息是一样的，只发送一次消息
 *  ignore : 忽略某个消息,忽略某个极端的情况
 *  switchToLatest :
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
@end
