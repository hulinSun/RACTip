//
//  ConfigMaker.h
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigMaker : NSObject

/**
 *  背景颜色
// */
//@property (nonatomic, strong)UIColor *cm_backgroundColor;
//
///**
// *  圆角度
// */
//@property (nonatomic, strong)NSNumber *cm_coreRadius;
//
///**
// *  尺寸
// */
//@property (nonatomic, strong)NSValue *cm_frame;


- (instancetype)initWithView:(UIView *)view;


-(ConfigMaker * (^)(UIColor *color))bgColor;

-(ConfigMaker * (^)(NSValue *frame))frame;

-(ConfigMaker * (^)(NSNumber *cr))coreRadius;



@end
