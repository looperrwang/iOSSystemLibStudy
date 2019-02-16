//
//  IndexedDrawingViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/14.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "IndexedDrawingViewController.h"
#import "IndexedDrawingRenderer.h"

@implementation IndexedDrawingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"IndexedDrawing";
}

- (EAGLRenderer *)renderer
{
    return [[IndexedDrawingRenderer alloc] init];
}

@end
