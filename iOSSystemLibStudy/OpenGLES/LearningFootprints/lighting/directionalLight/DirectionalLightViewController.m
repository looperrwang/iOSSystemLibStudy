//
//  DirectionalLightViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/18.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "DirectionalLightViewController.h"
#import "DirectionalLightRenderer.h"

@interface DirectionalLightViewController ()

@end

@implementation DirectionalLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"DirectionalLight";
}

- (EAGLRenderer *)renderer
{
    return [[DirectionalLightRenderer alloc] init];
}

@end
