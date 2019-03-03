//
//  SkyBoxUsingScaleViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/3/2.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SkyBoxUsingScaleViewController.h"
#import "SkyBoxUsingScaleRenderer.h"

@interface SkyBoxUsingScaleViewController ()

@end

@implementation SkyBoxUsingScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SkyBoxUsingScale";
}

- (EAGLRenderer *)renderer
{
    return [[SkyBoxUsingScaleRenderer alloc] init];
}

@end
