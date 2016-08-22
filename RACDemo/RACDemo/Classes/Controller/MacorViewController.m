//
//  MacorViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "MacorViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>


@interface MacorViewController ()

@property (nonatomic, strong)UIButton *button;

@property (nonatomic, strong)UILabel *label;

@end

@implementation MacorViewController


- (UILabel *)label{
    if (!_label) {
        self.label =[[UILabel alloc]init];
        _label.backgroundColor = [UIColor colorWithRed:0.4 green:.5 blue:.6 alpha:.8];
        _label.frame = CGRectMake(100, 300, 200, 44);
        _label.font = [UIFont systemFontOfSize:13];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}


- (UIButton *)button{
    if (!_button) {
        self.button =[[UIButton alloc]init];
        _button.frame = CGRectMake(200, 200, 100, 40);
        _button.backgroundColor = [UIColor redColor];
    }
    return _button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.button];
    [self.view addSubview:self.label];
    
    [self buttonDemo];
    [self labelDemo];
}

-(void)buttonDemo{
    

    RAC(self.button , backgroundColor) = [RACObserve(self.button, selected) map:^id(NSNumber *selected) {
        
        return selected.boolValue ?  [UIColor greenColor] : [UIColor redColor];
    }];
    
    @weakify(self);
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self_weak_.button.selected = !self_weak_.button.isSelected;
    }];
}

-(void)otherExam
{
    /**  假如对象的某个属性想绑定某个消息，可以使用RAC这个宏
    RAC(self.submitButton, enabled) = [RACSignal combineLatest:@[self.usernameField.rac_textSignal, self.passwordField.rac_textSignal] reduce:^id(NSString *userName, NSString *password) {
        return @(userName.length >= 6 && password.length >= 6);
    }]; */
}


/**
 *  婊 马金莲(马蓉)
 */
-(void)labelDemo{
    RAC(self.label , text) = [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]] map:^id(id value) {
        // id 不能使用点语法
        return [value description];
    }];
}

-(void)dealloc
{
    NSLog(@"dealoc");
}
@end
