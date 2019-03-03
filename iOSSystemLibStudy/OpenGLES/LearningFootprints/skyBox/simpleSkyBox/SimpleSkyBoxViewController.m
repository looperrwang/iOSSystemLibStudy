//
//  SimpleSkyBoxViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/3/2.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SimpleSkyBoxViewController.h"
#import "SimpleSkyBoxRenderer.h"

@interface SimpleSkyBoxViewController ()

@end

@implementation SimpleSkyBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SimpleSkyBox";
}

- (EAGLRenderer *)renderer
{
    return [[SimpleSkyBoxRenderer alloc] init];
}

@end
