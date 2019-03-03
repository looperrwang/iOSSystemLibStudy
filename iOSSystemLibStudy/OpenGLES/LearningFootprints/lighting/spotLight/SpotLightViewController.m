//
//  SpotLightViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/19.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SpotLightViewController.h"
#import "SpotLightRenderer.h"

@interface SpotLightViewController ()

@end

@implementation SpotLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SpotLight";
}

- (EAGLRenderer *)renderer
{
    return [[SpotLightRenderer alloc] init];
}

@end
