//
//  LightWithMapViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/17.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "LightWithMapViewController.h"
#import "LightWithMapRenderer.h"

@interface LightWithMapViewController ()

@end

@implementation LightWithMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"LightWithDiffuseMap";
}

- (EAGLRenderer *)renderer
{
    return [[LightWithMapRenderer alloc] init];
}

@end
