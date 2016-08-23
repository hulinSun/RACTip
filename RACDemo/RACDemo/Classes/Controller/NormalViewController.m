//
//  NormalViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "NormalViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface NormalViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UIButton *button;

@property (nonatomic, copy) NSString *name;
@end

@implementation NormalViewController

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
    }
    return _button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.button];
    
        [self target_actionDemo];
    //    [self guesture];
    //    [self notification];
    //    [self delay];
    
    //    [self timer];
    //    [self replaceDelegate];
//    [self KVO];
}

/**
 *  RAC 替代target-action 机制
 */
-(void)target_actionDemo{
    
    // 标准的写法
    
    @weakify(self); // 注意 rac里面的block 会发生循环引用。
    
    //    subscribeNext : 订阅这个信号
    [[self_weak_.textField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(UITextField *x) { // 传过来的是 textfield 对象
        //        NSLog(@"x = %@ class = %@",x , [x class]);
        //        NSLog(@"text = %@",x.text);
    }];
    
    // 简单写法
    [[self_weak_.textField rac_textSignal] subscribeNext:^(id x) {
        NSLog(@"x = %@",x); // 传过来的是字符串对象
    }];
    
    [[self_weak_.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"点击了按钮");
    }];
    
}


/**
 *  RAC 替代手势
 */
-(void)guesture{
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"clicked -- x = %@",x); // 传过来的是手势UITapGestureRecognizer
    }];
    [self.view addGestureRecognizer:tap];
}

/**
 *  通知
 */
-(void)notification{
    
    // 监听文字的改变
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidChangeNotification object:nil] subscribeNext:^(id x) {
        NSLog(@" change  x = %@ class = %@",x , [x class]); // 传过来NSNotification
    }];
}


/**
 *  延迟调用
 */
-(void)delay{
    NSLog(@"-----");
    // 在主线程调用
    [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
        NSLog(@"++++++"); // 只调用一次
    }];
    
    //    [[RACScheduler currentScheduler]schedule:^{ // 立即执行
    //        NSLog(@"++++++");
    //    }];
    
    // 到达某个时间之后执行
    //    [[RACScheduler currentScheduler] after:[NSDate dateWithTimeIntervalSinceNow:3] schedule:^{
    //        NSLog(@"eeeee");
    //    }];
}

/**
 *  定时器重复执行
 */
-(void)timer{
    
    // onScheduler 意味着在哪个线程执行
    [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id x) { //订阅信号
        NSLog(@"x = %@ class = %@",x ,[x class]); // 传过来的是时间nsdate 对象
    }];
}


/**
 *  替换代理 : 只能替换没有返回值的代理，有返回值的代理不能用rac 来替代
 */
-(void)replaceDelegate
{
    
    self.textField.delegate = self;
    // self 作为代理
    [[self rac_signalForSelector:@selector(textFieldDidBeginEditing:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple *tuple) { // 传过来的是元祖类型 , 代理方法中的参数用元祖包装起来
        NSLog(@"%@",[tuple.first class]);
        //        tuple.count 参数的个数
    }];
}

/**
 *  KVO
 */

-(void)KVO{
    
    [RACObserve(self.textField, text) subscribeNext:^(id x) {
        NSLog(@"textchange  x =%@ , class = %@",x , [x class]);
    }];
    self.textField.text = @"哈哈";
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIScrollView *sc = [[UIScrollView alloc]init];
    sc.frame = self.view.bounds;
    sc.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:sc];
    sc.contentSize = CGSizeMake(1000, 1000);
    
    [RACObserve(sc, contentOffset) subscribeNext:^(id x) {
        NSLog(@"x = %@ , class = %@",x , [x class]); // 监听的是什么属性，传过来的就是什么属性。
    }];
    
//    [sc rac_valuesAndChangesForKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionNew observer:self];
}



-(void)dealloc{
    NSLog(@"控制器被销毁了");
}

@end
