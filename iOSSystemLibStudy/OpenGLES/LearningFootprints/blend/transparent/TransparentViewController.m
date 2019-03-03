//
//  TransparentViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/26.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "TransparentViewController.h"
#import "TransparentRenderer.h"

@interface TransparentViewController ()

@end

@implementation TransparentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Transparent";
}

- (EAGLRenderer *)renderer
{
    return [[TransparentRenderer alloc] init];
}

@end
