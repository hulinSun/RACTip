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

- (NSArray *)datas{
    if (!_datas) {
        self.datas =@[
                      @{titleKey : @"NormalViewController 响应机制替代" ,
                        pushVCKey : @"NormalViewController"
                        },
                      
                      @{titleKey : @"AdvancedViewController 单信号的处理" ,
                        pushVCKey : @"AdvancedViewController"
                        },
                      
                      @{titleKey : @"NormalViewController 基础知识" ,
                        pushVCKey : @"NormalViewController"
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
    [self.navigationController pushViewController:vc animated:YES];
    
}
@end
