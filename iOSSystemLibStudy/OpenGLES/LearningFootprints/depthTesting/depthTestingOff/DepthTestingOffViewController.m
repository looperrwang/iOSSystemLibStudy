//
//  DepthTestingOffViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/24.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "DepthTestingOffViewController.h"
#import "DepthTestingOffRenderer.h"

@implementation DepthTestingOffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"DepthTestingOff";
}

- (EAGLRenderer *)renderer
{
    return [[DepthTestingOffRenderer alloc] init];
}

@end
