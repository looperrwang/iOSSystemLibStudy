//
//  FaceCullingViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/27.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "FaceCullingViewController.h"
#import "FaceCullingRenderer.h"

@interface FaceCullingViewController ()

@end

@implementation FaceCullingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"FaceCulling";
}

- (EAGLRenderer *)renderer
{
    return [[FaceCullingRenderer alloc] init];
}

@end
