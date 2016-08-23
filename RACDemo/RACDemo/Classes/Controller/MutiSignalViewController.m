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
    [self concat];
//    [self zipWith];
    
//    [self zip];
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
    
    // 底层实现：
    // 1.合并信号被订阅的时候，就会遍历所有信号，并且发出这些信号。
    // 2.每发出一个信号，这个信号就会被订阅
    // 3.也就是合并信号一被订阅，就会订阅里面所有的信号。
    // 4.只要有一个信号被发出就会被监听。
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

/**
 *  reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
 */
-(void)reduce{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        return nil;
    }];
    
    // 聚合
    // 常见的用法，（先组合在聚合）。combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock
    // reduce中的block简介:
    // reduceblcok中的参数，有多少信号组合，reduceblcok就有多少参数，每个参数就是之前信号发出的内容
    // reduceblcok的返回值：聚合信号之后的内容。
    RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA,signalB] reduce:^id(NSNumber *num1 ,NSNumber *num2){
        return [NSString stringWithFormat:@"%@ %@",num1,num2];
    }];
    
    [reduceSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 底层实现:
    // 1.订阅聚合信号，每次有内容发出，就会执行reduceblcok，把信号内容转换成reduceblcok返回的值。

    /**
     *  经典例子
     
     RAC(self.submitButton, enabled) = [RACSignal combineLatest:@[self.usernameField.rac_textSignal, self.passwordField.rac_textSignal] reduce:^id(NSString *userName, NSString *password) {
     return @(userName.length >= 6 && password.length >= 6);
     }];
     */

}
@end


