//
//  ChainViewController.h
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//  链式编程

#import <UIKit/UIKit.h>

@interface Hony : NSObject

-(Hony *(^)())shopping;

-(Hony *(^)())eating;

/**
 *  叫老公
 */
-(Hony *(^)(NSString *))call;

/**
 *  脱衣服
 */
-(Hony *(^)(NSString *))takeOff;

@end


@interface ChainViewController : UIViewController

@end


