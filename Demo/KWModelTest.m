//
//  KWModelTest.m
//  LoveMusic
//
//  Created by kevin xu on 16/1/8.
//  Copyright © 2016年 kevin xu. All rights reserved.
//

#import "KWModelTest.h"

#import "PrintObject.h"

@implementation KWModelTest

+ (NSDictionary *)kw_modelDictionary
{
    return @{@"fitter":@"KWFitter",
             @"cars":@"KWCar"};
}

+ (void)getTestData
{
    NSValue *value = [NSValue valueWithCGSize:CGSizeMake(112.6, 45.8)];
    NSDictionary *dic = @{@"userId":@"23",
                          @"userName":@"kevin",
                          @"loc":value,
                          @"fitter":@{@"yao":@(89.34),
                                      @"tun":@"46.34",
                                      @"xiong":@"78.34",
                                      @"car":@{@"weight":@"5555",@"carName":@"dazhong"}},
                          @"cars":@[@{@"weight":@"4090",@"carName":@"bmw"},
                                   @{@"weight":@"5090",@"carName":@"aodi"}]};
    
    KWModelTest *model = [KWModelTest kw_ObjectWithKeyValues:dic];
    
    NSDictionary *mydic = [PrintObject getObjectData:model];
    
    NSLog(@"%@",mydic);
}


@end





@implementation KWFitter


+ (NSDictionary *)kw_modelDictionary
{
    return @{@"car":@"KWCar"};
}

@end







@implementation KWCar

@end
