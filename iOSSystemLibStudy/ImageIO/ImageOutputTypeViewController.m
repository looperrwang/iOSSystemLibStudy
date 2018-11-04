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
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self studyCGImageDestination];
}

- (NSString *)filePath
{
    NSString *dirPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/ImageIO/"];
    NSString *filePath = nil;
    if ([self.type isEqualToString:@"public.jpeg"]) {
        filePath = [dirPath stringByAppendingPathComponent:@"apple.jpeg"];
    } else if ([self.type isEqualToString:@"public.png"]) {
        filePath = [dirPath stringByAppendingPathComponent:@"apple.png"];
    } else if ([self.type isEqualToString:@"com.compuserve.gif"]) {
        filePath = [dirPath stringByAppendingPathComponent:@"peppa.gif"];
    }
    
    return filePath;
}

- (CGImageSourceRef)imageSourceRefWithFilePath:(NSString *)filePath
{
    if (filePath.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return nil;
    
    NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    if (!url)
        return nil;
    
    /* CGImageSourceCreateWithDataProvider/CGImageSourceCreateWithData/CGImageSourceCreateWithURL调用时，可用的选项keys有:
     * kCGImageSourceTypeIdentifierHint - 创建CGImageSourceRef时，需要知道文件的格式，这个格式由一个叫做type identifier（public.jpeg、public.png、com.compuserve.gif类似这种，更多见"UTType.h"文件）的东西指定，这个key对应的value说明对文件type identifier的一个大致推测。
     */
    CFMutableDictionaryRef options = CFDictionaryCreateMutable(NULL, 1, NULL, NULL);
    const void *key = (const void *)kCGImageSourceTypeIdentifierHint;
    CFStringRef stringRef = CFStringCreateWithCString(NULL, self.type.UTF8String, kCFStringEncodingUTF8);
    const void *value = (const void *)stringRef;
    if (key && value) {
        CFDictionaryAddValue(options, key, value);
    }
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)url, options);
    if (stringRef) {
        CFRelease(stringRef);
    }
    if (options) {
        CFRelease(options);
    }
    
    return imageSourceRef;
}

#pragma mark - CGImageDestination

- (void)studyCGImageDestination
{
    printf("%s : \n", self.type == NULL ? "" : self.type.UTF8String);
    CFTypeID typeId = CGImageDestinationGetTypeID();
    printf("    - CGImageDestination CGImageDestinationGetTypeID : %zd\n", typeId); //313
    
    if ([self.type isEqualToString:@"public.jpeg"]) {
        //jpeg->png
        [self convertJpegToPng];
    } else if ([self.type isEqualToString:@"public.png"]) {
        //png->jpeg
        [self convertPngToJpeg];
    } else if ([self.type isEqualToString:@"com.compuserve.gif"]) {
        //jpeg+png->gif
        [self compositeJpegAndPngToGif];
    }
}

- (void)convertJpegToPng
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count == 0)
        return;
    
    NSString *dirPath = [paths objectAtIndex:0];
    if (dirPath.length == 0)
        return;
    
    dirPath = [dirPath stringByAppendingPathComponent:@"ImageIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *pngFilePath = [dirPath stringByAppendingPathComponent:@"apple.png"];
    NSURL *url = [NSURL fileURLWithPath:pngFilePath isDirectory:NO];
    if (!url)
        return;
    
    //第二个参数必须为CGImageDestinationCopyTypeIdentifiers返回数组中其中之一
    CGImageDestinationRef imageDestinationRef = CGImageDestinationCreateWithURL((CFURLRef)url, (CFStringRef)@"public.png", 1, NULL);
    if (!imageDestinationRef)
        return;
    
    CGImageSourceRef imageSourceRef = [self imageSourceRefWithFilePath:[self filePath]];
    if (!imageSourceRef) {
        CFRelease(imageDestinationRef);
        return;
    }
    
    //创建CGImageDestinationRef时，指定的image数为2，这里就必须增加2个image
    /* CGImageDestinationAddImage/CGImageDestinationAddImageFromSource调用时，可使用的属性，这些属性将影响最终输出的图像文件，同时，这些属性只应用于一个CGImageDestination表示的单独的image上 :
     * 1、kCGImageDestinationLossyCompressionQuality - 压缩质量，0.0～1.0，1.0代表无损压缩
     * 2、kCGImageDestinationBackgroundColor - 当将带alpha通道的图片转为不支持alpha的图片格式时，指定的背景色，如果指定的话，对应的值为不包含alpha通道的CGColorRef对象，否则的话，白色作为默认颜色
     * 3、kCGImageDestinationImageMaxPixelSize - 目标图片尺寸
     * 4、kCGImageDestinationEmbedThumbnail - 目标图片中是否内嵌缩略图
     * 5、kCGImageDestinationOptimizeColorForSharing - 是否使用兼容老设备的颜色空间来生成image，默认为kCFBooleanFalse，不做任何颜色转换
     */
    CFMutableDictionaryRef options = CFDictionaryCreateMutable(NULL, 1, NULL, NULL);
    const void *key1 = (const void *)kCGImageDestinationLossyCompressionQuality;
    CFNumberRef numberRef = (__bridge CFNumberRef)@(1.0);
    const void *value1 = (const void *)numberRef;
    if (key1 && value1) {
        CFDictionaryAddValue(options, key1, value1);
    }
    
    //影响生成image的尺寸
    const void *key2 = (const void *)kCGImageDestinationImageMaxPixelSize;
    numberRef = (__bridge CFNumberRef)@(256);
    const void *value2 = (const void *)numberRef;
    if (key2 && value2) {
        CFDictionaryAddValue(options, key2, value2);
    }
    
    const void *key3 = (const void *)kCGImageDestinationEmbedThumbnail;
    const void *value3 = (const void *)kCFBooleanTrue;
    if (key3 && value3) {
        CFDictionaryAddValue(options, key3, value3);
    }
    
    const void *key4 = (const void *)kCGImageDestinationBackgroundColor;
    CGFloat color[] = {0, 0, 0};
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpaceRef, color);
    const void *value4 = (const void *)colorRef;
    if (key4 && value4) {
        CFDictionaryAddValue(options, key4, value4);
    }
    
    CGImageDestinationAddImageFromSource(imageDestinationRef, imageSourceRef, 0, options);
    bool result = CGImageDestinationFinalize(imageDestinationRef);
    printf("    - CGImageDestination convertJpegToPng : %s\n", result ? "success" : "fail");
    
    if (colorRef) {
        CFRelease(colorRef);
    }
    
    if (colorSpaceRef) {
        CFRelease(colorSpaceRef);
    }
    
    if (options) {
        CFRelease(options);
    }
    
    CFRelease(imageSourceRef);
    CFRelease(imageDestinationRef);
}

- (void)convertPngToJpeg
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count == 0)
        return;
    
    NSString *dirPath = [paths objectAtIndex:0];
    if (dirPath.length == 0)
        return;
    dirPath = [dirPath stringByAppendingPathComponent:@"ImageIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *jpegFilePath = [dirPath stringByAppendingPathComponent:@"apple.jpeg"];
    NSURL *url = [NSURL fileURLWithPath:jpegFilePath isDirectory:NO];
    if (!url)
        return;
    
    CGImageDestinationRef imageDestinationRef = CGImageDestinationCreateWithURL((CFURLRef)url, (CFStringRef)@"public.jpeg", 1, NULL);
    if (!imageDestinationRef)
        return;
    
    CGImageSourceRef imageSourceRef = [self imageSourceRefWithFilePath:[self filePath]];
    if (!imageSourceRef) {
        CFRelease(imageDestinationRef);
        return;
    }
    
    //创建CGImageDestinationRef时，指定的image数为2，这里就必须增加2个image
    /* CGImageDestinationAddImage/CGImageDestinationAddImageFromSource调用时，可使用的属性，这些属性将影响最终输出的图像文件，同时，这些属性只应用于一个CGImageDestination表示的单独的image上 :
     * 1、kCGImageDestinationLossyCompressionQuality - 压缩质量，0.0～1.0，1.0代表无损压缩
     * 2、kCGImageDestinationBackgroundColor - 当将带alpha通道的图片转为不支持alpha的图片格式时，指定的背景色，如果指定的话，对应的值为不包含alpha通道的CGColorRef对象，否则的话，白色作为默认颜色
     * 3、kCGImageDestinationImageMaxPixelSize - 目标图片尺寸
     * 4、kCGImageDestinationEmbedThumbnail - 目标图片中是否内嵌缩略图
     * 5、kCGImageDestinationOptimizeColorForSharing - 是否使用兼容老设备的颜色空间来生成image，默认为kCFBooleanFalse，不做任何颜色转换
     */
    CFMutableDictionaryRef options = CFDictionaryCreateMutable(NULL, 1, NULL, NULL);
    const void *key1 = (const void *)kCGImageDestinationLossyCompressionQuality;
    CFNumberRef numberRef = (__bridge CFNumberRef)@(1.0);
    const void *value1 = (const void *)numberRef;
    if (key1 && value1) {
        CFDictionaryAddValue(options, key1, value1);
    }
    
    //影响生成image的尺寸
    const void *key2 = (const void *)kCGImageDestinationImageMaxPixelSize;
    numberRef = (__bridge CFNumberRef)@(256);
    const void *value2 = (const void *)numberRef;
    if (key2 && value2) {
        CFDictionaryAddValue(options, key2, value2);
    }
    
    const void *key3 = (const void *)kCGImageDestinationEmbedThumbnail;
    const void *value3 = (const void *)kCFBooleanTrue;
    if (key3 && value3) {
        CFDictionaryAddValue(options, key3, value3);
    }
    
    const void *key4 = (const void *)kCGImageDestinationBackgroundColor;
    CGFloat color[] = {0, 0, 0};
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpaceRef, color);
    const void *value4 = (const void *)colorRef;
    if (key4 && value4) {
        //由支持alpha的格式转向不支持alpha格式的情况下，才会用到
        CFDictionaryAddValue(options, key4, value4);
    }
    
    CGImageDestinationAddImageFromSource(imageDestinationRef, imageSourceRef, 0, options);
    bool result = CGImageDestinationFinalize(imageDestinationRef);
    printf("    - CGImageDestination convertPngToJpeg : %s\n", result ? "success" : "fail");
    
    if (colorRef) {
        CFRelease(colorRef);
    }
    
    if (colorSpaceRef) {
        CFRelease(colorSpaceRef);
    }
    
    if (options) {
        CFRelease(options);
    }
    
    CFRelease(imageSourceRef);
    CFRelease(imageDestinationRef);
}

- (void)compositeJpegAndPngToGif
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count == 0)
        return;
    
    NSString *dirPath = [paths objectAtIndex:0];
    if (dirPath.length == 0)
        return;
    dirPath = [dirPath stringByAppendingPathComponent:@"ImageIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *gifFilePath = [dirPath stringByAppendingPathComponent:@"apple.gif"];
    NSURL *url = [NSURL fileURLWithPath:gifFilePath isDirectory:NO];
    if (!url)
        return;
    
    CGImageDestinationRef imageDestinationRef = CGImageDestinationCreateWithURL((CFURLRef)url, (CFStringRef)@"com.compuserve.gif", 2, NULL);
    if (!imageDestinationRef)
        return;
    
    NSString *filePath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/ImageIO/"] stringByAppendingPathComponent:@"apple.jpeg"];
    CGImageSourceRef imageSourceRef1 = [self imageSourceRefWithFilePath:filePath];
    if (!imageSourceRef1) {
        CFRelease(imageDestinationRef);
        return;
    }
    
    filePath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/ImageIO/"] stringByAppendingPathComponent:@"sea.jpg"];
    CGImageSourceRef imageSourceRef2 = [self imageSourceRefWithFilePath:filePath];
    if (!imageSourceRef2) {
        CFRelease(imageSourceRef1);
        CFRelease(imageDestinationRef);
        return;
    }
    
    CGImageRef imageRef2 = CGImageSourceCreateImageAtIndex(imageSourceRef2, 0, NULL);
    if (!imageRef2) {
        CFRelease(imageSourceRef2);
        CFRelease(imageSourceRef1);
        CFRelease(imageDestinationRef);
        return;
    }
    
    //可以指定CGImagePropertyGIFDictionary相关property，自定义gif帧间隔等参数
    CFMutableDictionaryRef options = CFDictionaryCreateMutable(NULL, 1, NULL, NULL);
    const void *key = (const void *)kCGImagePropertyGIFDictionary;
    CFMutableDictionaryRef value = CFDictionaryCreateMutable(NULL, 1, NULL, NULL);
    const void *keyInteral = (const void *)kCGImagePropertyGIFDelayTime;
    CFNumberRef numberRef = (__bridge CFNumberRef)@(2.0);
    const void *valueInteral = (const void *)numberRef;
    if (keyInteral && valueInteral) {
        CFDictionaryAddValue(value, keyInteral, valueInteral);
    }
    if (key && value) {
        CFDictionaryAddValue(options, key, value);
    }
    
    //kCGImagePropertyPixelHeight/kCGImagePropertyPixelWidth无效
    const void *key2 = (const void *)kCGImageDestinationImageMaxPixelSize;
    numberRef = (__bridge CFNumberRef)@(512);
    const void *value2 = (const void *)numberRef;
    if (key2 && value2) {
        CFDictionaryAddValue(options, key2, value2);
    }
    
    CGImageDestinationAddImageFromSource(imageDestinationRef, imageSourceRef1, 0, options);
    CGImageDestinationAddImage(imageDestinationRef, imageRef2, options);
    bool result = CGImageDestinationFinalize(imageDestinationRef);
    printf("    - CGImageDestination compositeJpegAndPngToGif : %s\n", result ? "success" : "fail");
    
    if (value) {
        CFRelease(value);
    }
    if (options) {
        CFRelease(options);
    }
    
    CFRelease(imageRef2);
    CFRelease(imageSourceRef2);
    CFRelease(imageSourceRef1);
    CFRelease(imageDestinationRef);
}

@end
