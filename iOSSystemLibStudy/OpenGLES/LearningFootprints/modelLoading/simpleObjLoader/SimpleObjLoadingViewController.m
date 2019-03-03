//
//  SimpleObjLoadingViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/20.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SimpleObjLoadingViewController.h"
#import "SimpleObjLoadingRenderer.h"

@interface SimpleObjLoadingViewController ()

@end

@implementation SimpleObjLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SimpleObjLoading";
}

- (SimpleObjLoadingRenderer *)renderer
{
    return [[SimpleObjLoadingRenderer alloc] init];
}

@end
