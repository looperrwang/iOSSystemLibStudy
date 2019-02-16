//
//  ViewTransformationViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/16.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "ViewTransformationViewController.h"
#import "ViewTransformationRenderer.h"

@interface ViewTransformationViewController ()

@end

@implementation ViewTransformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ViewTransformation";
}

- (EAGLRenderer *)renderer
{
    return [[ViewTransformationRenderer alloc] init];
}

@end
