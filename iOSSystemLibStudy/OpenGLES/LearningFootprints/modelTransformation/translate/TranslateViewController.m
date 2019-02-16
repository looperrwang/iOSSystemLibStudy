//
//  TranslateViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/15.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "TranslateViewController.h"
#import "TranslateRenderer.h"

@interface TranslateViewController ()

@end

@implementation TranslateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Translation";
}

- (EAGLRenderer *)renderer
{
    return [[TranslateRenderer alloc] init];
}

@end
