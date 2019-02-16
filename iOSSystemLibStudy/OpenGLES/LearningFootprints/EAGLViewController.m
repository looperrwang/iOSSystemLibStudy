//
//  EAGLViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/12.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "EAGLViewController.h"
#import "EAGLView.h"
#import "EAGLRenderer.h"

@interface EAGLViewController ()

@property (nonatomic, strong) EAGLView *eaglView;

@end

@implementation EAGLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _eaglView = [[EAGLView alloc] initWithFrame:self.view.bounds renderer:[self renderer]];
    [self.view addSubview:_eaglView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_eaglView startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_eaglView stopAnimation];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    [_eaglView stopAnimation];
    [_eaglView onApplicationDidEnterBackground];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [_eaglView stopAnimation];
    [_eaglView onApplicationDidEnterBackground];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [_eaglView startAnimation];
}

- (EAGLRenderer *)renderer
{
    return [[EAGLRenderer alloc] init];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_eaglView stopAnimation];
}

@end
