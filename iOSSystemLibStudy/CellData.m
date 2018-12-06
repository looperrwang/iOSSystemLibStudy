//
//  CellData.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/12/6.
//  Copyright © 2018 looperwang. All rights reserved.
//

#import "CellData.h"

@implementation CellData

- (instancetype)initWithText:(NSString *)text vcName:(NSString *)vcName
{
    if (self = [super init]) {
        self.text = text;
        self.vcName = vcName;
    }
    
    return self;
}

@end
