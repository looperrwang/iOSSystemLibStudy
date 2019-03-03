//
//  PostProcessViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/27.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "PostProcessViewController.h"
#import "PostProcessRenderer.h"

@interface PostProcessViewController ()

@end

@implementation PostProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"PostProcess";
}

- (EAGLRenderer *)renderer
{
    return [[PostProcessRenderer alloc] init];
}

@end
