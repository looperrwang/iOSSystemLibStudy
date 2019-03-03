//
//  RenderToTextureViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/27.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "RenderToTextureViewController.h"
#import "RenderToTextureRenderer.h"

@interface RenderToTextureViewController ()

@end

@implementation RenderToTextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"RenderToTexture";
}

- (EAGLRenderer *)renderer
{
    return [[RenderToTextureRenderer alloc] init];
}

@end
