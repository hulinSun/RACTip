//
//  ViewController.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "ViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString *const titleKey = @"title";
static NSString *const pushVCKey = @"pushVC";

@interface ViewController () <UITableViewDelegate , UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSArray *datas;
@end


@implementation ViewController

/**
 * 高阶信号处理
 * 冷信号与热信号专题
 * RAC 并发编程
 * 信号的生命周期
 * 信号的订阅取消操作
 */
- (NSArray *)datas{
    if (!_datas) {
        self.datas =@[
                      @{titleKey : @"ChainViewController 链式编程" ,
                        pushVCKey : @"ChainViewController"
                        },

                      @{titleKey : @"NormalViewController 响应机制替代" ,
                        pushVCKey : @"NormalViewController"
                        },
                      
                      @{titleKey : @"AdvancedViewController 单信号的处理",
                        pushVCKey : @"AdvancedViewController"
                        },
                      
                      @{titleKey : @"MutiSignalViewController 多信号的处理",
                        pushVCKey : @"MutiSignalViewController"
                        },
                      
                      @{titleKey : @"MacorViewController RAC宏",
                        pushVCKey : @"MacorViewController"
                        }
                     
                      ];
        
    }
    return _datas;
}
- (UITableView *)tableView{
    if (!_tableView) {
        self.tableView =[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
    }
    return _tableView;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"ReactiveCocoa";
    [self.view addSubview:self.tableView];
    
#pragma mark - 疑问: 为什么这里点击代理不执行?
    
//    [[self rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:) fromProtocol:@protocol(UITableViewDelegate)] subscribeNext:^(RACTuple *tuple) {
//        
//        NSIndexPath *indexPath = (NSIndexPath *)tuple.second;
//        NSDictionary *dict = self.datas[indexPath.row];
//
//        Class pushClass = NSClassFromString(dict[pushVCKey]);
//        
//        UIViewController *vc = [[pushClass alloc]init];
//        [self presentViewController:vc animated:YES completion:nil];
//    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *dict = self.datas[indexPath.row];
    cell.textLabel.text = dict[titleKey];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = self.datas[indexPath.row];
    Class pushClass = NSClassFromString(dict[pushVCKey]);
    UIViewController *vc = [[pushClass alloc]init];
    NSString *title = [dict[titleKey] componentsSeparatedByString:@" "].lastObject;
    vc.title = title;
    [self.navigationController pushViewController:vc animated:YES];
    
}
@end
