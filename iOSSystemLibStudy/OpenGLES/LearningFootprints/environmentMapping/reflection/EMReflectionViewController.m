//
//  ReflectionViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/3/6.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "EMReflectionViewController.h"
#import "EMReflectionRenderer.h"

@interface EMReflectionViewController ()

@end

@implementation EMReflectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Reflection";
}

- (EAGLRenderer *)renderer
{
    return [[EMReflectionRenderer alloc] init];
}

@end
