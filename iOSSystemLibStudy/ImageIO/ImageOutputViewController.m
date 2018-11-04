//
//  ImageOutputViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/11/4.
//  Copyright © 2018 looperwang. All rights reserved.
//

#import "ImageOutputViewController.h"
#import "ImageOutputTypeViewController.h"

@interface ImageOutputViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *supportTypes;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ImageOutputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ImageOutput";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.supportTypes = [NSMutableArray new];
    [self initSupportTypes];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSupportTypes
{
    //CGImageDestination支持的所有类型
    CFArrayRef supportTypes = CGImageDestinationCopyTypeIdentifiers();
    CFIndex count = CFArrayGetCount(supportTypes);
    for (CFIndex index = 0; index < count; index++) {
        const void *type = CFArrayGetValueAtIndex(supportTypes, index);
        if (type != NULL) {
            CFStringRef stringRef = (CFStringRef)type;
            const char *c_str = CFStringGetCStringPtr(stringRef, kCFStringEncodingUTF8);
            if (c_str != NULL) {
                NSString *string = [NSString stringWithUTF8String:c_str];
                [self.supportTypes addObject:string];
            }
        } else {
            assert(0);
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.supportTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"ImageOutput";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    NSString *text = @"";
    if (indexPath.row >= 0 && indexPath.row < self.supportTypes.count) {
        text = self.supportTypes[indexPath.row];
    }
    cell.textLabel.text = text;
    
    cell.textLabel.textColor = [UIColor blackColor];
    if (![text isEqualToString:@"public.jpeg"] && ![text isEqualToString:@"public.png"] && ![text isEqualToString:@"com.compuserve.gif"] && ![text isEqualToString:@"com.adobe.pdf"]) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0 || indexPath.row >= self.supportTypes.count)
        return;
    
    NSString *text = @"";
    if (indexPath.row >= 0 && indexPath.row < self.supportTypes.count) {
        text = self.supportTypes[indexPath.row];
    }
    
    if ([text isEqualToString:@"public.jpeg"] || [text isEqualToString:@"public.png"] || [text isEqualToString:@"com.compuserve.gif"] || [text isEqualToString:@"com.adobe.pdf"]) {
        ImageOutputTypeViewController *vc = [[ImageOutputTypeViewController alloc] init];
        vc.type = text;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
