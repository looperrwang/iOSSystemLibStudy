//
//  SelectableDrawingViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/24.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SelectableDrawingViewController.h"
#import "SelectableDrawingRenderer.h"

@interface SelectableDrawingViewController ()

@end

@implementation SelectableDrawingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SelectableDrawing";
}

- (SelectableDrawingRenderer *)renderer
{
    return [[SelectableDrawingRenderer alloc] init];
}

@end
