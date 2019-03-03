//
//  LightingViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/16.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "LightingViewController.h"
#import "CellData.h"

@interface LightingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<CellData *> *data;

@end

@implementation LightingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.data = [NSMutableArray array];
    [self initCellData];
    
    self.title = @"Lighting";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

- (void)initCellData
{
    [self.data addObject:[[CellData alloc] initWithText:@"Phong shading - LightingInWorldSpace - 片段着色器中进行光照计算" vcName:@"LightingInWorldSpaceViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"Phong shading - LightingInViewSpace - 片段着色器中进行光照计算" vcName:@"LightingInViewSpaceViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"GouraudShading - 顶点着色器中进行光照计算" vcName:@"GouraudShadingViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"LightWithMaterial - 不同物体不同材质属性" vcName:@"LightWithMaterialViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"LightWithMap - 同一个物体不同部分不同材质属性" vcName:@"LightWithMapViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"DirectionalLight" vcName:@"DirectionalLightViewController"]]; //渲染有问题
    [self.data addObject:[[CellData alloc] initWithText:@"PointLight" vcName:@"PointLightViewController"]]; //渲染有问题
    [self.data addObject:[[CellData alloc] initWithText:@"SpotLight" vcName:@"SpotLightViewController"]]; //渲染有问题
    [self.data addObject:[[CellData alloc] initWithText:@"SpotLightSoftEdge" vcName:@"SpotLightSoftEdgeViewController"]]; //渲染有问题
    [self.data addObject:[[CellData alloc] initWithText:@"MultipleLight" vcName:@"MultipleLightViewController"]]; //渲染有问题
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Lighting";
    
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
