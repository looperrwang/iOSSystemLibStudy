//
//  OpenGLLearningFootprintsViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/1/30.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "OpenGLLearningFootprintsViewController.h"
#import "CellData.h"

@interface OpenGLLearningFootprintsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<CellData *> *data;

@end

@implementation OpenGLLearningFootprintsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.data = [NSMutableArray array];
    [self initCellData];
    
    self.title = @"OpenGLLearningFootprints";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

- (void)initCellData
{
    [self.data addObject:[[CellData alloc] initWithText:@"" vcName:@""]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"OpenGLLearningFootprints";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    CellData *data = self.data[indexPath.row];
    
    NSString *text = @"";
    if (indexPath.row >= 0 && indexPath.row < self.data.count) {
        text = data.text;
    }
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0 || indexPath.row >= self.data.count)
        return;
    
    CellData *data = self.data[indexPath.row];
    if (data && data.vcName.length > 0) {
        UIViewController *vc = [[NSClassFromString(data.vcName) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end