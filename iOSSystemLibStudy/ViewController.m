//
//  ViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/9/25.
//  Copyright © 2018年 looperwang. All rights reserved.
//

#import "ViewController.h"

@interface CellData : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *vcName;

@end

@implementation CellData
@end





@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<CellData *> *data;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [NSMutableArray array];
    CellData *data0 = [CellData new];
    data0.text = @"ImageIO";
    data0.vcName = @"ImageIOViewController";
    [self.data addObject:data0];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.title = @"iOSSystemLibStudy";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    NSString *text = @"";
    if (indexPath.row >= 0 && indexPath.row < self.data.count) {
        text = self.data[indexPath.row].text;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
