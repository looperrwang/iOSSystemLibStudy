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

- (const void *)valueOfCGImageProperty:(CFDictionaryRef)dic key:(const void *)key
{
    Boolean isContains = CFDictionaryContainsKey(dic, key);
    if (isContains) {
        return CFDictionaryGetValue(dic, key);
    }
    
    return NULL;
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
        const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyFileSize];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyFileSize : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPixelHeight];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyPixelHeight : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPixelWidth];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyPixelWidth : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDPIHeight];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyDPIHeight : %f\n", num.floatValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDPIWidth];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyDPIWidth : %f\n", num.floatValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDepth];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyDepth : %ld\n", num.longValue); //8
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyOrientation];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyOrientation : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIsFloat];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge_transfer NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyIsFloat : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIsIndexed];
        if (value) {
            CFBooleanRef booleanRef = (CFBooleanRef)value;
            printf("    - CGImageSource Properties kCGImagePropertyIsIndexed : %s\n", booleanRef == kCFBooleanTrue ? "true" : "false");
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyHasAlpha];
        if (value) {
            CFBooleanRef booleanRef = (CFBooleanRef)value;
            printf("    - CGImageSource Properties kCGImagePropertyHasAlpha : %s\n", booleanRef == kCFBooleanTrue ? "true" : "false");
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyColorModel];
        if (value) {
            CFStringRef strRef = (CFStringRef)value;
            const char *str = CFStringGetCStringPtr(strRef, kCFStringEncodingUTF8);
            //NSString *string = (__bridge_transfer NSString *)strRef;
            printf("    - CGImageSource Properties kCGImagePropertyColorModel : %s\n", str == NULL ? "" : str);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyProfileName];
        if (value) {
            CFStringRef strRef = (CFStringRef)value;
            const char *str = CFStringGetCStringPtr(strRef, kCFStringEncodingUTF8);
            printf("    - CGImageSource Properties kCGImagePropertyProfileName : %s\n", str == NULL ? "" : str);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        /*
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPrimaryImage];
        if (value) {
            CFBooleanRef booleanRef = (CFBooleanRef)value;
            printf("    - CGImageSource Properties kCGImagePropertyPrimaryImage : %s\n", booleanRef == kCFBooleanTrue ? "true" : "false");
        }*/
        
        Boolean isContains = CFDictionaryContainsKey(dic, (const void *)kCGImagePropertyTIFFDictionary);
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
    
    printf("    CGImagePropertyTIFFDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFCompression];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFPhotometricInterpretation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFDocumentName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFImageDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFMake];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFModel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFOrientation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFXResolution];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFYResolution];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFResolutionUnit];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFSoftware];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFTransferFunction];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFDateTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFArtist];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFHostComputer];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFCopyright];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFWhitePoint];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFPrimaryChromaticities];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFTileWidth];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyTIFFTileLength];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyGIFDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyGIFDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGIFLoopCount];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGIFDelayTime];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge_transfer NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyGIFDelayTime : %f\n", num.doubleValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGIFImageColorMap];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGIFHasGlobalColorMap];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGIFUnclampedDelayTime];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge_transfer NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyGIFUnclampedDelayTime : %f\n", num.doubleValue);
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyJFIFDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyJFIFDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyJFIFVersion];
    if (value) {
        CFArrayRef arrayRef = (CFArrayRef)value;
        NSArray *array = (__bridge_transfer NSArray *)arrayRef;
        printf("    - CGImageSource Properties kCGImagePropertyJFIFVersion : ");
        int count = (int)array.count;
        for (int index = 0; index < count; index++) {
            NSNumber *num = array[index];
            if (index != count - 1) {
                printf("%d.", num.intValue);
            } else {
                printf("%d", num.intValue);
            }
        }
        printf("\n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyJFIFXDensity];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge_transfer NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyJFIFXDensity : %d\n", num.intValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyJFIFYDensity];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge_transfer NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyJFIFYDensity : %d\n", num.intValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyJFIFDensityUnit];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge_transfer NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyJFIFDensityUnit : %d\n", num.intValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyJFIFIsProgressive];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyExifDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyExifDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifExposureTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifExposureProgram];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSpectralSensitivity];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifISOSpeedRatings];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifOECF];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSensitivityType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifStandardOutputSensitivity];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifRecommendedExposureIndex];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifISOSpeed];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifISOSpeedLatitudeyyy];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifISOSpeedLatitudezzz];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifVersion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifDateTimeOriginal];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifDateTimeDigitized];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifComponentsConfiguration];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifCompressedBitsPerPixel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifShutterSpeedValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifApertureValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifBrightnessValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifExposureBiasValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifMaxApertureValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSubjectDistance];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifMeteringMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifLightSource];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFlash];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFocalLength];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSubjectArea];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifMakerNote];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifUserComment];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSubsecTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSubsecTimeOriginal];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSubsecTimeDigitized];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFlashPixVersion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifColorSpace];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifPixelXDimension];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifPixelYDimension];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifRelatedSoundFile];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFlashEnergy];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSpatialFrequencyResponse];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFocalPlaneXResolution];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFocalPlaneYResolution];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFocalPlaneResolutionUnit];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSubjectLocation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifExposureIndex];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSensingMethod];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFileSource];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSceneType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifCFAPattern];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifCustomRendered];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifExposureMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifWhiteBalance];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifDigitalZoomRatio];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifFocalLenIn35mmFilm];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSceneCaptureType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifGainControl];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifContrast];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSaturation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSharpness];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifDeviceSettingDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifSubjectDistRange];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifImageUniqueID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifCameraOwnerName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifBodySerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifLensSpecification];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifLensMake];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifLensModel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifLensSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifGamma];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyPNGDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyPNGDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGGamma];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGInterlaceType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGXPixelsPerMeter];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGYPixelsPerMeter];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGsRGBIntent];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGChromaticities];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGAuthor];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGCopyright];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGCreationTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGModificationTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGSoftware];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGTitle];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyAPNGLoopCount];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyAPNGDelayTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyAPNGUnclampedDelayTime];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyIPTCDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyIPTCDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyGPSDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyGPSDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyRawDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyRawDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyCIFFDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyCIFFDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerCanonDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerCanonDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerNikonDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerNikonDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerMinoltaDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerMinoltaDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerFujiDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerFujiDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerOlympusDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerOlympusDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerPentaxDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerPentaxDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImageProperty8BIMDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImageProperty8BIMDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyDNGDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyDNGDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyExifAuxDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyExifAuxDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxLensInfo];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxLensModel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxLensID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxLensSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxImageNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxFlashCompensation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxOwnerName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyExifAuxFirmware];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyOpenEXRDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyOpenEXRDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerAppleDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerAppleDictionary\n");
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyFileContentsDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyFileContentsDictionary\n");
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
