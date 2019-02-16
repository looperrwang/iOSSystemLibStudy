//
//  TexturesViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/15.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "TexturesViewController.h"
#import "TexturesRenderer.h"

@interface TexturesViewController ()

@end

@implementation TexturesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Textures";
}

- (EAGLRenderer *)renderer
{
    return [[TexturesRenderer alloc] init];
}

@end
