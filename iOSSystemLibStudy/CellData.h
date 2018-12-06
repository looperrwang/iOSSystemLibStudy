//
//  CellData.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/12/6.
//  Copyright © 2018 looperwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellData : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *vcName;

- (instancetype)initWithText:(NSString *)text vcName:(NSString *)vcName;

@end
