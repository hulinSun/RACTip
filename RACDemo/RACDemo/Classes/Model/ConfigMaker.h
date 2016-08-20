//
//  ConfigMaker.h
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigMaker : NSObject


- (instancetype)initWithView:(UIView *)view;

-(ConfigMaker * (^)(UIColor *color))bgColor;

-(ConfigMaker * (^)(NSValue *frame))frame;

-(ConfigMaker * (^)(NSNumber *cr))coreRadius;



@end
