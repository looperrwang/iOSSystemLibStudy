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

- (instancetype)initWithText:(NSString *)text vcName:(NSString *)vcName
{
    if (self = [super init]) {
        self.text = text;
        self.vcName = vcName;
    }
    
    return self;
}

@end





@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<CellData *> *data;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [NSMutableArray array];
    [self initCellData];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.title = @"iOSSystemLibStudy";
}

- (void)initCellData
{
    [self.data addObject:[[CellData alloc] initWithText:@"Accelerate" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Accounts" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"AddressBook" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"AddressBookUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"AdSupport" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ARKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"AssetsLibrary" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"AudioToolbox" vcName:@""]];
    //[self.data addObject:[[CellData alloc] initWithText:@"AudioUnit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"AVFoundation" vcName:@"AVFoundationViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"AVKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"BusinessChat" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CallKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CFNetwork" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ClassKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CloundKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Contacts" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ContactsUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreAudio" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreAudioKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreBluetooth" vcName:@""]];
    //[self.data addObject:[[CellData alloc] initWithText:@"CoreData" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreFoundation" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreGraphics" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreImage" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreLocation" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreMedia" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreMIDI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreML" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreMotion" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreNFC" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreSpotlight" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreTelephony" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreText" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CoreVideo" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"DeviceCheck" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"EventKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"EventKitUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ExternalAccessory" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"FileProvider" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"FileProviderUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Foundation" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"GameController" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"GameKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"GameplayKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"GLKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"GSS" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"HealthKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"HealthKitUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"HomeKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"iAd" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"IdentityLookup" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ImageIO - 完成" vcName:@"ImageIOViewController"]];
    [self.data addObject:[[CellData alloc] initWithText:@"Intents" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"IntentsUI" vcName:@""]];
    //[self.data addObject:[[CellData alloc] initWithText:@"IOKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"IOSurface" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"JavaScriptCore" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"LocalAuthentication" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MapKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MediaAccessibility" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MediaPlayer" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MediaToolbox" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Messages" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MessageUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Metal" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MetalKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MetalPerformanceShaders" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MobileCoreServices" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ModelIO" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"MultipeerConnectivity" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"NetworkExtension" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"NewsstandKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"NotificationCenter" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"OpenAL" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"OpenGLES" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"PassKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"PDFKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Photos" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"PhotosUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"PushKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"QuartzCore" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"QuickLook" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ReplayKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"SafariServices" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"SceneKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Security" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Social" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Speech" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"SpriteKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"StoreKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"SystemConfiguration" vcName:@""]];
    //[self.data addObject:[[CellData alloc] initWithText:@"Twitter" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"UIKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"UserNotifications" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"UserNotificationsUI" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"VideoSubscriberAccount" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"VideoToolbox" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Vision" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"WatchConnectivity" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"WatchKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"WebKit" vcName:@""]];
    //[self.data addObject:[[CellData alloc] initWithText:@"Swift" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"CarPlay" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Natural Language" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"SiriKit" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"SMS and Call Reporting" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"AuthenticationServices" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Compression" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Core Services" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"DarwinNotify" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Dispatch" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"dnssd" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Objective-C Runtime" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"ServiceManagement" vcName:@""]];
    [self.data addObject:[[CellData alloc] initWithText:@"Network" vcName:@""]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"iOSSystemLibStudy";
    
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
    
    cell.textLabel.textColor = [UIColor redColor];
    if (data && data.vcName.length > 0) {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
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
