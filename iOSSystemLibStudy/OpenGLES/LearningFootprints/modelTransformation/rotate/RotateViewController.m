//
//  RotateViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/15.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "RotateViewController.h"
#import "RotateRenderer.h"

@interface RotateViewController ()

@end

@implementation RotateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Rotate";
}

- (EAGLRenderer *)renderer
{
    return [[RotateRenderer alloc] init];
}

@end
