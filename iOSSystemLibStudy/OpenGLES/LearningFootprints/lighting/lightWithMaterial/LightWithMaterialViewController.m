//
//  LightWithMaterialViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/17.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "LightWithMaterialViewController.h"
#import "LightWithMaterialRenderer.h"

@interface LightWithMaterialViewController ()

@property (nonatomic, strong) LightWithMaterialRenderer *renderer;

@end

@implementation LightWithMaterialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (EAGLRenderer *)renderer
{
    if (!_renderer) {
        _renderer = [[LightWithMaterialRenderer alloc] init];
    }
    
    return _renderer;
}

@end
