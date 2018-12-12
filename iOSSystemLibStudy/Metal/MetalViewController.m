//
//  MetalViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/12/6.
//  Copyright © 2018 looperwang. All rights reserved.
//

#import "MetalViewController.h"
#import "CellData.h"

@interface MetalViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<CellData *> *data;

@end

@implementation MetalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.data = [NSMutableArray array];
    [self initCellData];
    
    self.title = @"Metal";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
}

- (void)initCellData
{
    [self.data addObject:[[CellData alloc] initWithText:@"DevicesAndCommands" vcName:@"DevicesAndCommandsViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"CPU-GPUSynchronization" vcName:@"CPUGPUSynchronizationViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"ImageFilteringWithHeapsAndEvents" vcName:@"ImageFilteringWithHeapsAndEventsViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"ImageFilteringWithHeapsAndFences" vcName:@"ImageFilteringWithHeapsAndFencesViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"BasicIndirectCommandBuffers" vcName:@"BasicIndirectCommandBuffersViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"IndirectCommandBuffersWithGPUEncoding" vcName:@"IndirectCommandBuffersWithGPUEncodingViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"HelloTriangle" vcName:@"HelloTriangleViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"BasicBuffers" vcName:@"BasicBuffersViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"BasicTexturing" vcName:@"BasicTexturingViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"DeferredLighting" vcName:@"AAPLViewController"]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Metal";
    
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
        UIStoryboard *board = [UIStoryboard storyboardWithName:data.text bundle:nil];
        UIViewController *vc = [board instantiateViewControllerWithIdentifier:data.vcName];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
