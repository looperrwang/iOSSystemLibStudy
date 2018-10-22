//
//  ImageIOViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2018/9/28.
//  Copyright © 2018年 looperwang. All rights reserved.
//

#import "ImageIOViewController.h"

@interface ImageIOViewController ()

@end

@implementation ImageIOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ImageIO";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CFArrayRef arrayRef = CGImageSourceCopyTypeIdentifiers();
    CFIndex count = CFArrayGetCount(arrayRef);
    for (CFIndex index = 0; index < count; index++) {
        const void *value = CFArrayGetValueAtIndex(arrayRef, index);
        CFStringRef stringRef = (CFStringRef)value;
        const char *c_str = CFStringGetCStringPtr(stringRef, kCFStringEncodingUTF8);
        printf("%s\n", c_str);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








- (NSArray<UIImage *> *)imagesWithFilePath:(NSString *)filePath
{
    if (filePath.length == 0)
        return nil;
    
    NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    if (!url)
        return nil;
    
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

@end
