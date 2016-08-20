//
//  ConfigMaker.m
//  RACDemo
//
//  Created by mac on 16/8/20.
//  Copyright © 2016年 shl. All rights reserved.
//

#import "ConfigMaker.h"

@interface ConfigMaker ()

@property (nonatomic, strong)UIView *view;

@end

@implementation ConfigMaker

- (id)initWithView:(UIView *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    return self;
}










-(ConfigMaker * (^)(UIColor *color))bgColor{
    return ^(UIColor *color){
        self.view.backgroundColor = color;
        return self;
    };
}


-(ConfigMaker * (^)(NSValue *frame))frame
{
    return ^(NSValue *frame){
        self.view.frame = frame.CGRectValue;
        return self;
    };
}

-(ConfigMaker * (^)(NSNumber *cr))coreRadius
{
    return ^(NSNumber *cr){
        self.view.layer.cornerRadius = cr.floatValue;
        self.view.clipsToBounds = YES;
        return self;
    };
}

@end
