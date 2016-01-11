//
//  KWModelTest.h
//  LoveMusic
//
//  Created by kevin xu on 16/1/8.
//  Copyright © 2016年 kevin xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ModelParser.h"

@class KWFitter;
@interface KWModelTest : NSObject<KWModelParserDelegate>

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) KWFitter *fitter;
@property (nonatomic, strong) NSMutableArray *cars;//KWCar
@property (nonatomic, strong) NSString *nike;
@property (nonatomic, assign) CGSize loc;

+ (void)getTestData;
@end

@class KWCar;
@interface KWFitter : NSObject<KWModelParserDelegate>

@property (nonatomic, assign) CGFloat yao;
@property (nonatomic, assign) CGFloat tun;
@property (nonatomic, assign) CGFloat xiong;
@property (nonatomic, strong) KWCar *car;
@end

@interface KWCar : NSObject

@property (nonatomic, assign) CGFloat weight;
@property (nonatomic, strong) NSString *carName;

@end
