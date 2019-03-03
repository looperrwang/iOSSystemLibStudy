//
//  ObjectOutlineViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/24.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "ObjectOutlineViewController.h"
#import "ObjectOutlineRenderer.h"

@interface ObjectOutlineViewController ()

@end

@implementation ObjectOutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ObjectOutline";
}

- (EAGLRenderer *)renderer
{
    return [[ObjectOutlineRenderer alloc] init];
}

@end
