//
//  VisualDepthValueViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/24.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "VisualDepthValueViewController.h"
#import "VisualDepthValueRenderer.h"

@interface VisualDepthValueViewController ()

@end

@implementation VisualDepthValueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"VisualDepthValue";
}

- (EAGLRenderer *)renderer
{
    return [[VisualDepthValueRenderer alloc] init];
}

@end
