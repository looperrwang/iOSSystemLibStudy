//
//  ImageIOTypeViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/10/23.
//  Copyright © 2018 looperwang. All rights reserved.
//

#import "ImageIOTypeViewController.h"

@interface ImageIOTypeViewController ()

@property (nonatomic, assign) CGImageSourceRef isrc;

@end

@implementation ImageIOTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CFTypeID typeId = CGImageSourceGetTypeID();
    printf("CGImageSource CFTypeID : %zd\n", typeId); //305
    
    _isrc = NULL;
    
    if (self.isrc) {
        CFStringRef typeIdentifier = CGImageSourceGetType(self.isrc);
        const char *cType = CFStringGetCStringPtr(typeIdentifier, kCFStringEncodingUTF8);
        if (cType) {
            printf("CGImageSource typeIdentifier : %s\n", cType); //public.jpeg/public.png/com.compuserve.gif
        }
        
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    CFMutableDictionaryRef dicRef = CFDictionaryCreateMutable(NULL, 1, NULL, NULL);
    const void *key = (const void *)kCGImageSourceTypeIdentifierHint;
    CFStringRef stringRef = CFStringCreateWithCString(NULL, self.type.UTF8String, kCFStringEncodingUTF8);
    const void *value = (const void *)stringRef;
    if (key && value) {
        CFDictionaryAddValue(dicRef, key, value);
    }
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)url, dicRef);
    if (stringRef) {
        CFRelease(stringRef);
    }
    if (dicRef) {
        CFRelease(dicRef);
    }
    
    return imageSourceRef;
}

- (CGImageSourceRef)isrc
{
    if (!_isrc) {
        _isrc = [self imageSourceRefWithFilePath:[self filePath]];
    }
    
    return _isrc;
}








- (NSArray<UIImage *> *)imagesWithFilePath:(NSString *)filePath
{
    if (filePath.length == 0)
        return nil;
    
    NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    if (!url)
        return nil;
    
    /* CGImageSourceCopyPropertiesAtIndex/CGImageSourceCreateImageAtIndex调用时，可用的选项keys有:
     * kCGImageSourceShouldCache - 指定是否解码image并缓存解码之后的image。
     * kCGImageSourceShouldCacheImmediately - 指定解码并缓存image的时机，kCFBooleanFalse表示渲染时，kCFBooleanTrue表示创建该image时。
     * kCGImageSourceShouldAllowFloat - 如果文件格式支持，是否将image作为浮点CGImageRef返回，对于扩展了范围的浮点CGImageRef可能需要额外的处理，渲染出来的结果才能令人满意。
     */
    
    /* CGImageSourceCreateThumbnailAtIndex调用时，可用的选项keys有:
     * kCGImageSourceCreateThumbnailFromImageIfAbsent - 如果image源文件中不存在缩略图的话，指定是否自动生成一个缩略图，如果为kCFBooleanTrue，缩略图将会由原始image生成，其大小由kCGImageSourceThumbnailMaxPixelSize对应的值指定，若没有指定kCGImageSourceThumbnailMaxPixelSize的话，缩略图的小小与原始image大小一致。
     * kCGImageSourceCreateThumbnailFromImageAlways - 指定是否总是生成缩略图，即使源文件中存在。
     * kCGImageSourceThumbnailMaxPixelSize - 指定缩略图的最大宽高，单位为像素，没有指定的话，缩略图宽高与原image一致
     * kCGImageSourceCreateThumbnailWithTransform - 设置缩略图是否根据原image的旋转与宽高比进行旋转与缩放
     * kCGImageSourceSubsampleFactor - 返回一个按照指定因子缩小了的image，返回的image与原始的image相比，将会更小但将保存同样的特征，如果指定的因子不支持的话，将返回不小于原始image的image，支持的文件格式为JPEG, HEIF, TIFF, and PNG，允许指定的因为有2, 4, 8
     */
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    if (!imageSourceRef)
        return nil;
    
    NSMutableArray<UIImage *> *array = [NSMutableArray<UIImage *> new];
    
    size_t imageCount = CGImageSourceGetCount(imageSourceRef);
    for (size_t index = 0; index < imageCount; index++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, index, NULL);
        if (!imageRef)
            continue;
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        if (!image) {
            CGImageRelease(imageRef);
            continue;
        }
        
        [array addObject:image];
        CGImageRelease(imageRef);
    }
    
    CFRelease(imageSourceRef);
    
    return [NSArray<UIImage *> arrayWithArray:array];
}

- (void)dealloc
{
    if (_isrc) {
        CFRelease(_isrc);
    }
    _isrc = NULL;
}

@end
