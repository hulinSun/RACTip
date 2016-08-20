//
//  MutiSignalViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "MutiSignalViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MutiSignalViewController ()

@property (nonatomic, strong)UITextField *textField;



@end

@implementation MutiSignalViewController



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
    
//    [self merge];
//    [self concat];
//    [self zipWith];
    
    [self zip];
}

/**
 *  合并 ( 两种写法)
 *  无先后顺序
 *  同时订阅了两个信号。ab 发消息了都在订阅的block 里响应，只不过是各玩各的
 */
-(void)merge{
    
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:2 schedule:^{
            NSLog(@"signalA");
            [subscriber sendNext:@"A"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:1 schedule:^{
            NSLog(@"signalB");
            [subscriber sendNext:@"B"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    NSLog(@"-------  %@" , [NSDate date].description);
    
    // 谁再前在后都没关系。 同时订阅了两个信号。ab 发消息了都在这个block里响应
    
//    [[signalA merge:signalB] subscribeNext:^(id x) {
//        NSLog(@" I come from  %@" ,x);
//    }];
    
    [[RACSignal merge:@[signalA , signalB]] subscribeNext:^(id x) {
         NSLog(@" I come from  %@   %@" ,x , [NSDate date].description);
    }];
    
}


/**
 *  有先后顺序
 *  连接  前面的执行完之后，在执行完的基础上再执行后面的。
 *  如果前面的执行错误 或者senderror ，走了error 。那么后面的就不执行了
 *  注意打印时间 ，出现
 */
-(void)concat
{
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:2 schedule:^{
            NSLog(@"signalA");
            [subscriber sendNext:@"A"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:1 schedule:^{
            NSLog(@"signalB");
            [subscriber sendNext:@"B"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    NSLog(@"------ %@", [NSDate date ].description);
    // 有先后顺序，谁放在前面谁先执行

//    [[RACSignal concat:@[signalB ,signalA]] subscribeNext:^(id x) {
//        NSLog(@" I come from  %@   %@" ,x , [NSDate date].description);
//    }];
    
    [[signalA concat: signalB] subscribeNext:^(id x) {
        NSLog(@" I come from  %@   %@" ,x , [NSDate date].description);
    }];
}


/**
 *  类似于dispatch_group 。 多个异步，在统一的地方处理返回
 *  至少都发送一次消息，才会订阅这个信号
 *  无先后顺序
 */
-(void)zipWith{
    
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:2 schedule:^{
            NSLog(@"signalA");
            [subscriber sendNext:@"A"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:1 schedule:^{
            NSLog(@"signalB");
            [subscriber sendNext:@"B"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    
    NSLog(@"---- %@",[NSDate date].description);
    
    // 只能两个
    [[signalA zipWith:signalB] subscribeNext:^(id x) {
        NSLog(@"x = %@  %@",x ,[NSDate date].description);
    }];
    
}

/**
 *  比较通用。多少个信号都可以
 */
-(void)zip{
    
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:2 schedule:^{
            NSLog(@"signalA");
            [subscriber sendNext:@"A"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:1 schedule:^{
            NSLog(@"signalB");
            [subscriber sendNext:@"B"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    RACSignal * signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler currentScheduler]afterDelay:1.4 schedule:^{
            NSLog(@"signalC");
            [subscriber sendNext:@"C"];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    NSLog(@"---- %@",[NSDate date].description);
    
    
    // zip 是多个
        [[RACSignal zip:@[signalA , signalB , signalC]] subscribeNext:^(id x) {
            NSLog(@"x = %@  %@",x ,[NSDate date].description);
        }];
    
    // combineLatest 和 zip 是一样的
//    [[RACSignal combineLatest:@[signalA , signalB , signalC]] subscribeNext:^(RACTuple *x) {
//        NSLog(@"x = %@  %@",x ,[NSDate date].description);
//        NSLog(@"tuple.first = %@",x.first);
//    }];
    
}

@end


