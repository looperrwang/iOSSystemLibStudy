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
    
    [self studyCGImageSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (_isrc) {
        CFRelease(_isrc);
    }
    _isrc = NULL;
}

#pragma mark - CGImageSource

- (void)studyCGImageSource
{
    CFTypeID typeId = CGImageSourceGetTypeID();
    printf("%s : \n", self.type == NULL ? "" : self.type.UTF8String);
    printf("    - CGImageSource CGImageSourceGetTypeID : %zd\n", typeId); //305
    
    _isrc = NULL;
    
    if (self.isrc) {
        CFStringRef typeIdentifier = CGImageSourceGetType(self.isrc);
        const char *cType = CFStringGetCStringPtr(typeIdentifier, kCFStringEncodingUTF8);
        if (cType) {
            printf("    - CGImageSource CGImageSourceGetType : %s\n", cType); //public.jpeg/public.png/com.compuserve.gif
        }
        
        size_t count = CGImageSourceGetCount(self.isrc);
        printf("    - CGImageSource CGImageSourceGetCount : %zd\n", count);
        
        /* CGImageSourceCopyPropertiesAtIndex/CGImageSourceCreateImageAtIndex调用时，可用的选项keys有:
         * kCGImageSourceShouldCache - 指定是否解码image并缓存解码之后的image。
         * kCGImageSourceShouldCacheImmediately - 指定解码并缓存image的时机，kCFBooleanFalse表示渲染时，kCFBooleanTrue表示创建该image时。
         * kCGImageSourceShouldAllowFloat - 如果文件格式支持，是否将image作为浮点CGImageRef返回，对于扩展了范围的浮点CGImageRef可能需要额外的处理，渲染出来的结果才能令人满意。
         */
        CFMutableDictionaryRef options = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        const void *key1 = (const void *)kCGImageSourceShouldCache;
        CFBooleanRef value1 = kCFBooleanTrue; //kCFBooleanFalse
        if (key1 && value1) {
            CFDictionaryAddValue(options, key1, (const void *)value1);
        }
        
        const void *key2 = (const void *)kCGImageSourceShouldCacheImmediately;
        CFBooleanRef value2 = kCFBooleanTrue;
        if (key2 && value2) {
            CFDictionaryAddValue(options, key2, (const void *)value2);
        }
        
        const void *key3 = (const void *)kCGImageSourceShouldAllowFloat;
        CFBooleanRef value3 = kCFBooleanTrue;
        if (key3 && value3) {
            CFDictionaryAddValue(options, key3, (const void *)value3);
        }
        
        //CFDictionaryRef properties = CGImageSourceCopyProperties(self.isrc, options);
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(self.isrc, 0, options);
        if (properties) {
            [self printCGImageProperties:properties];
            CFRelease(properties);
        }
        
        if (options) {
            CFRelease(options);
        }
    }
}

- (void)printCGImageProperties:(CFDictionaryRef)dic
{
    CFIndex count = CFDictionaryGetCount(dic);
    if (count > 0) {
        /*
        void **keys = calloc(count, sizeof(void *));
        void **values = calloc(count, sizeof(void *));
        CFDictionaryGetKeysAndValues(dic, (const void **)keys, (const void **)values);
        
        for (size_t index = 0; index < count; index++) {
            const void *key = keys[index];
            const void *value = values[index];
        }*/
        
        //CGImageSourceCopyProperties
        Boolean isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyFileSize);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyFileSize);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyFileSize : %ld\n", num.longValue);
            }
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyPixelHeight);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyPixelHeight);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyPixelHeight : %ld\n", num.longValue);
            }
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyPixelWidth);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyPixelWidth);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyPixelWidth : %ld\n", num.longValue);
            }
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyDPIHeight);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyDPIHeight);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyDPIHeight : %f\n", num.floatValue);
            }
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyDPIWidth);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyDPIWidth);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyDPIWidth : %f\n", num.floatValue);
            }
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyDepth);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyDepth);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyDepth : %ld\n", num.longValue); //8
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyOrientation);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyOrientation);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyOrientation : %ld\n", num.longValue); //8
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyIsFloat);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyIsFloat);
            if (value) {
                CFNumberRef numRef = (CFNumberRef)value;
                NSNumber *num = (__bridge_transfer NSNumber *)numRef;
                printf("    - CGImageSource Properties kCGImagePropertyIsFloat : %ld\n", num.longValue); //8
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyIsIndexed);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyIsIndexed);
            if (value) {
                CFBooleanRef booleanRef = (CFBooleanRef)value;
                printf("    - CGImageSource Properties kCGImagePropertyIsIndexed : %s\n", booleanRef == kCFBooleanTrue ? "true" : "false");
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyHasAlpha);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyHasAlpha);
            if (value) {
                CFBooleanRef booleanRef = (CFBooleanRef)value;
                printf("    - CGImageSource Properties kCGImagePropertyHasAlpha : %s\n", booleanRef == kCFBooleanTrue ? "true" : "false");
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyColorModel);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyColorModel);
            if (value) {
                CFStringRef strRef = (CFStringRef)value;
                const char *str = CFStringGetCStringPtr(strRef, kCFStringEncodingUTF8);
                //NSString *string = (__bridge_transfer NSString *)strRef;
                printf("    - CGImageSource Properties kCGImagePropertyColorModel : %s\n", str == NULL ? "" : str);
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyProfileName);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyProfileName);
            if (value) {
                CFStringRef strRef = (CFStringRef)value;
                const char *str = CFStringGetCStringPtr(strRef, kCFStringEncodingUTF8);
                printf("    - CGImageSource Properties kCGImagePropertyProfileName : %s\n", str == NULL ? "" : str);
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyPrimaryImage);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyPrimaryImage);
            if (value) {
                CFBooleanRef booleanRef = (CFBooleanRef)value;
                printf("    - CGImageSource Properties kCGImagePropertyPrimaryImage : %s\n", booleanRef == kCFBooleanTrue ? "true" : "false");
            }
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyTIFFDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyTIFFDictionary);
            //TIFF
            [self printCGImagePropertyTIFFDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyGIFDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyGIFDictionary);
            //GIF
            [self printCGImagePropertyGIFDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyJFIFDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyJFIFDictionary);
            //JFIF
            [self printCGImagePropertyJFIFDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyExifDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyExifDictionary);
            //Exif
            [self printCGImagePropertyExifDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyPNGDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyPNGDictionary);
            //PNG
            [self printCGImagePropertyPNGDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyIPTCDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyIPTCDictionary);
            //IPTC
            [self printCGImagePropertyIPTCDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyGPSDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyGPSDictionary);
            //GPS
            [self printCGImagePropertyGPSDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyRawDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyRawDictionary);
            //RAW
            [self printCGImagePropertyRawDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyCIFFDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyCIFFDictionary);
            //CIFF
            [self printCGImagePropertyCIFFDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyMakerCanonDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyMakerCanonDictionary);
            //MakerCanon
            [self printCGImagePropertyMakerCanonDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyMakerNikonDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyMakerNikonDictionary);
            //MakerNikon
            [self printCGImagePropertyMakerNikonDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyMakerMinoltaDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyMakerMinoltaDictionary);
            //MakerMinolta
            [self printCGImagePropertyMakerMinoltaDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyMakerFujiDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyMakerFujiDictionary);
            //MakerFuji
            [self printCGImagePropertyMakerFujiDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyMakerOlympusDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyMakerOlympusDictionary);
            //MakerOlympus
            [self printCGImagePropertyMakerOlympusDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyMakerPentaxDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyMakerPentaxDictionary);
            //MakerPentax
            [self printCGImagePropertyMakerPentaxDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImageProperty8BIMDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImageProperty8BIMDictionary);
            //8BIM
            [self printCGImageProperty8BIMDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyDNGDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyDNGDictionary);
            //DNG
            [self printCGImagePropertyDNGDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyExifAuxDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyExifAuxDictionary);
            //ExifAux
            [self printCGImagePropertyExifAuxDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyOpenEXRDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyOpenEXRDictionary);
            //OpenEXR
            [self printCGImagePropertyOpenEXRDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyMakerAppleDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyMakerAppleDictionary);
            //MakerApple
            [self printCGImagePropertyMakerAppleDictionary:(CFDictionaryRef)value];
        }
        
        isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyFileContentsDictionary);
        if (isContains) {
            const void *value = CFDictionaryGetValue(dic, (const void *)kCGImagePropertyFileContentsDictionary);
            //Contents
            [self printCGImagePropertyFileContentsDictionary:(CFDictionaryRef)value];
        }
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyTIFFDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyGIFDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyJFIFDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyExifDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyPNGDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyIPTCDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyGPSDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyRawDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyCIFFDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerCanonDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerNikonDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerMinoltaDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerFujiDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerOlympusDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerPentaxDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImageProperty8BIMDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyDNGDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyExifAuxDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyOpenEXRDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerAppleDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyFileContentsDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    
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

@end
