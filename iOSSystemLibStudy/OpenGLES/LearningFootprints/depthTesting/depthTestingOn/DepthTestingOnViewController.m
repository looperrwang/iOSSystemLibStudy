//
//  DepthTestingOnViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/24.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "DepthTestingOnViewController.h"
#import "DepthTestingOnRenderer.h"

@interface DepthTestingOnViewController ()

@end

@implementation DepthTestingOnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"DepthTestingOn";
}

- (EAGLRenderer *)renderer
{
    return [[DepthTestingOnRenderer alloc] init];
}

@end
