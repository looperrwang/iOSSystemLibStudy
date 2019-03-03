//
//  MultipleLightViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/20.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "MultipleLightViewController.h"
#import "MultipleLightRenderer.h"

@interface MultipleLightViewController ()

@end

@implementation MultipleLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"MultipleLight";
}

- (MultipleLightRenderer *)renderer
{
    return [[MultipleLightRenderer alloc] init];
}

@end
