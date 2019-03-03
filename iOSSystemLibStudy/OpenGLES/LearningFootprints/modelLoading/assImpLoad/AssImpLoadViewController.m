//
//  AssImpLoadViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/23.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "AssImpLoadViewController.h"
#import "AssImpLoadRenderer.h"

@interface AssImpLoadViewController ()

@end

@implementation AssImpLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"AssImpLoad";
}

- (EAGLRenderer *)renderer
{
    return [[AssImpLoadRenderer alloc] init];
}

@end
