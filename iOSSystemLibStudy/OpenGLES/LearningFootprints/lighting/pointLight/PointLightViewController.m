//
//  PointLightViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/18.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "PointLightViewController.h"
#import "PointLightRenderer.h"

@interface PointLightViewController ()

@end

@implementation PointLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"PointLight";
}

- (EAGLRenderer *)renderer
{
    return [[PointLightRenderer alloc] init];
}

@end
