//
//  PlanarReflection ViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/24.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "PlanarReflectionViewController.h"
#import "PlanarReflectionRenderer.h"

@interface PlanarReflectionViewController ()

@end

@implementation PlanarReflectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"PlanarReflection";
}

- (EAGLRenderer *)renderer
{
    return [[PlanarReflectionRenderer alloc] init];
}

@end
