//
//  SemitransparentViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/26.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SemitransparentViewController.h"
#import "SemitransparentRenderer.h"

@interface SemitransparentViewController ()

@end

@implementation SemitransparentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Semitransparent";
}

- (EAGLRenderer *)renderer
{
    return [[SemitransparentRenderer alloc] init];
}

@end
