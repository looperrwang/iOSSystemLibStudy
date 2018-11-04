//
//  ImageOutputTypeViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/11/4.
//  Copyright © 2018 looperwang. All rights reserved.
//

#import "ImageOutputTypeViewController.h"

@interface ImageOutputTypeViewController ()

@end

@implementation ImageOutputTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.type;
    
    [self studyCGImageDestination];
}

#pragma mark - CGImageDestination

- (void)studyCGImageDestination
{
    /* CGImageDestinationAddImage/CGImageDestinationAddImageFromSource调用时，可使用的属性，这些属性将影响最终输出的图像文件，同时，这些属性只应用于一个CGImageDestination表示的单独的image上 :
     * 1、kCGImageDestinationLossyCompressionQuality - 压缩质量，0.0～1.0，1.0代表无损压缩
     * 2、kCGImageDestinationBackgroundColor - 当将带alpha通道的图片转为不支持alpha的图片格式时，指定的背景色，如果指定的话，对应的值为不包含alpha通道的CGColorRef对象，否则的话，白色作为默认颜色
     * 3、kCGImageDestinationImageMaxPixelSize - 目标图片尺寸
     * 4、kCGImageDestinationEmbedThumbnail - 目标图片中是否内嵌缩略图
     * 5、kCGImageDestinationOptimizeColorForSharing - 是否使用兼容老设备的颜色空间来生成image，默认为kCFBooleanFalse，不做任何颜色转换
     */
    CFTypeID typeId = CGImageDestinationGetTypeID();
    printf("    - CGImageDestination CGImageDestinationGetTypeID : %zd\n", typeId); //313
}

@end
