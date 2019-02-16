//
//  TriangleViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/14.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "TriangleViewController.h"
#import "TriangleRenderer.h"

@implementation TriangleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Triangle";
}

- (EAGLRenderer *)renderer
{
    return [[TriangleRenderer alloc] init];
}

@end
