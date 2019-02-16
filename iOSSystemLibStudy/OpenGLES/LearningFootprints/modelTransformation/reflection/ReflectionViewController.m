//
//  ReflectionViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/16.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "ReflectionViewController.h"
#import "ReflectionRenderer.h"

@interface ReflectionViewController ()

@end

@implementation ReflectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Reflection";
}

- (EAGLRenderer *)renderer
{
    return [[ReflectionRenderer alloc] init];
}

@end
