//
//  SkyBoxOptimizedViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/3/2.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SkyBoxOptimizedViewController.h"
#import "SkyBoxOptimizedRenderer.h"

@interface SkyBoxOptimizedViewController ()

@end

@implementation SkyBoxOptimizedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SkyBoxOptimized";
}

- (EAGLRenderer *)renderer
{
    return [[SkyBoxOptimizedRenderer alloc] init];
}

@end
