//
//  ScaleViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/15.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "ScaleViewController.h"
#import "ScaleRenderer.h"

@interface ScaleViewController ()

@end

@implementation ScaleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Scale";
}

- (EAGLRenderer *)renderer
{
    return [[ScaleRenderer alloc] init];
}

@end
