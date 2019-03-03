//
//  SpotLightSoftEdgeViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/20.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SpotLightSoftEdgeViewController.h"
#import "SpotLightSoftEdgeRenderer.h"

@interface SpotLightSoftEdgeViewController ()

@end

@implementation SpotLightSoftEdgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SpotLightSoftEdge";
}

- (EAGLRenderer *)renderer
{
    return [[SpotLightSoftEdgeRenderer alloc] init];
}

@end
