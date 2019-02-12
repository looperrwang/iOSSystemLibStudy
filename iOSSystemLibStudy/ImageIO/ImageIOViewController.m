//
//  ImageIOViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/9/28.
//  Copyright © 2018年 looperwang. All rights reserved.
//

#import "ImageIOViewController.h"

@interface ImageIOViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ImageIOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ImageIO";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"ImageIO";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    NSString *text = @"";
    if (indexPath.row == 0) {
        text = @"ImageInput";
    } else if (indexPath.row == 1) {
        text = @"ImageOutput";
    }
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0 || indexPath.row >= 2)
        return;
    
    NSString *className = @"";
    if (indexPath.row == 0) {
        className = @"ImageInputViewController";
    } else if (indexPath.row == 1) {
        className = @"ImageOutputViewController";
    }
    
    if (className.length > 0) {
        UIViewController *vc = [[NSClassFromString(className) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
