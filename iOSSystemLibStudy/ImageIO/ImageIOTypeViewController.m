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
            NSNumber *num = (__bridge NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyFileSize : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPixelHeight];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyPixelHeight : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPixelWidth];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyPixelWidth : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDPIHeight];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyDPIHeight : %f\n", num.floatValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDPIWidth];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyDPIWidth : %f\n", num.floatValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDepth];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyDepth : %ld\n", num.longValue); //8
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyOrientation];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge NSNumber *)numRef;
            printf("    - CGImageSource Properties kCGImagePropertyOrientation : %ld\n", num.longValue);
        }
        
        //CGImageSourceCopyPropertiesAtIndex
        value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIsFloat];
        if (value) {
            CFNumberRef numRef = (CFNumberRef)value;
            NSNumber *num = (__bridge NSNumber *)numRef;
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
            //NSString *string = (__bridge NSString *)strRef;
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
        //枚举CGImagePropertyOrientation
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
        NSNumber *num = (__bridge NSNumber *)numRef;
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
        NSNumber *num = (__bridge NSNumber *)numRef;
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
        NSArray *array = (__bridge NSArray *)arrayRef;
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
        NSNumber *num = (__bridge NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyJFIFXDensity : %d\n", num.intValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyJFIFYDensity];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyJFIFYDensity : %d\n", num.intValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyJFIFDensityUnit];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge NSNumber *)numRef;
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
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyPNGInterlaceType : %d\n", num.intValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGXPixelsPerMeter];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyPNGXPixelsPerMeter : %d\n", num.intValue);
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyPNGYPixelsPerMeter];
    if (value) {
        CFNumberRef numRef = (CFNumberRef)value;
        NSNumber *num = (__bridge NSNumber *)numRef;
        printf("        - CGImageSource Properties kCGImagePropertyPNGYPixelsPerMeter : %d\n", num.intValue);
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
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCObjectTypeReference];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCObjectAttributeReference];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCObjectName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCEditStatus];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCEditorialUpdate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCUrgency];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCSubjectReference];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCategory];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCSupplementalCategory];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCFixtureIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCKeywords];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContentLocationCode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContentLocationName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCReleaseDate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCReleaseTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExpirationDate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExpirationTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCSpecialInstructions];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCActionAdvised];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCReferenceService];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCReferenceDate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCReferenceNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCDateCreated];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCTimeCreated];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCDigitalCreationDate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCDigitalCreationTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCOriginatingProgram];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCProgramVersion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCObjectCycle];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCByline];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCBylineTitle];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCity];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCSubLocation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCProvinceState];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCountryPrimaryLocationCode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCountryPrimaryLocationName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCOriginalTransmissionReference];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCHeadline];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCredit];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCSource];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCopyrightNotice];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContact];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCaptionAbstract];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCWriterEditor];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCImageType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCImageOrientation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCLanguageIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCStarRating];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCCreatorContactInfo];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCRightsUsageTerms];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCScene];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAboutCvTerm];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAboutCvTermCvId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAboutCvTermId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAboutCvTermName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAboutCvTermRefinedAbout];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAddlModelInfo];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkOrObject];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkCircaDateCreated];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkContentDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkContributionDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkCopyrightNotice];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkCreator];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkCreatorID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkCopyrightOwnerID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkCopyrightOwnerName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkLicensorID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkLicensorName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkDateCreated];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkPhysicalDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkSource];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkSourceInventoryNo];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkSourceInvURL];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkStylePeriod];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtArtworkTitle];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAudioBitrate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAudioBitrateMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtAudioChannelCount];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtCircaDateCreated];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtContainerFormat];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtContainerFormatIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtContainerFormatName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtContributor];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtContributorIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtContributorName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtContributorRole];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtCopyrightYear];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtCreator];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtCreatorIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtCreatorName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtCreatorRole];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtControlledVocabularyTerm];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreen];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegionD];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegionH];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegionText];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegionUnit];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegionW];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegionX];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDataOnScreenRegionY];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDigitalImageGUID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDigitalSourceFileType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDigitalSourceType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDopesheet];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDopesheetLink];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDopesheetLinkLink];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtDopesheetLinkLinkQualifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEmbdEncRightsExpr];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEmbeddedEncodedRightsExpr];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprLangID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEpisode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEpisodeIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEpisodeName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEpisodeNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtEvent];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtShownEvent];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtShownEventIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtShownEventName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtExternalMetadataLink];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtFeedIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtGenre];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtGenreCvId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtGenreCvTermId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtGenreCvTermName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtGenreCvTermRefinedAbout];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtHeadline];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtIPTCLastEdited];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLinkedEncRightsExpr];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLinkedEncodedRightsExpr];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLinkedEncodedRightsExprType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLinkedEncodedRightsExprLangID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationCreated];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationCity];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationCountryCode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationCountryName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationGPSAltitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationGPSLatitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationGPSLongitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationLocationId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationLocationName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationProvinceState];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationSublocation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationWorldRegion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtLocationShown];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtMaxAvailHeight];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtMaxAvailWidth];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtModelAge];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtOrganisationInImageCode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtOrganisationInImageName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonHeard];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonHeardIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonHeardName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImage];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageWDetails];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageCharacteristic];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageCvTermCvId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageCvTermId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageCvTermName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageCvTermRefinedAbout];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPersonInImageName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtProductInImage];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtProductInImageDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtProductInImageGTIN];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtProductInImageName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPublicationEvent];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPublicationEventDate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPublicationEventIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtPublicationEventName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRating];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRatingRegion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionCity];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionCountryCode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionCountryName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionGPSAltitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionGPSLatitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionGPSLongitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionLocationId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionLocationName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionProvinceState];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionSublocation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingRegionWorldRegion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingScaleMaxValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingScaleMinValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingSourceLink];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingValue];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRatingValueLogoLink];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRegistryID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRegistryEntryRole];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRegistryItemID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtRegistryOrganisationID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtReleaseReady];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSeason];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSeasonIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSeasonName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSeasonNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSeries];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSeriesIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSeriesName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtStorylineIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtStreamReady];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtStylePeriod];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSupplyChainSource];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSupplyChainSourceIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtSupplyChainSourceName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtTemporalCoverage];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtTemporalCoverageFrom];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtTemporalCoverageTo];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtTranscript];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtTranscriptLink];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtTranscriptLinkLink];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtTranscriptLinkLinkQualifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoBitrate];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoBitrateMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoDisplayAspectRatio];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoEncodingProfile];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoShotType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoShotTypeIdentifier];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoShotTypeName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVideoStreamsCount];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtVisualColor];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtWorkflowTag];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtWorkflowTagCvId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtWorkflowTagCvTermId];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtWorkflowTagCvTermName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCExtWorkflowTagCvTermRefinedAbout];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoCity];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoCountry];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoAddress];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoPostalCode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoStateProvince];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoEmails];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoPhones];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyIPTCContactInfoWebURLs];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyGPSDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyGPSDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSVersion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSLatitudeRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSLatitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSLongitudeRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSLongitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSAltitudeRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSAltitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSTimeStamp];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSSatellites];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSStatus];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSMeasureMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDOP];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSSpeedRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSSpeed];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSTrackRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSTrack];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSImgDirectionRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSImgDirection];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSMapDatum];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestLatitudeRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestLatitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestLongitudeRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestLongitude];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestBearingRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestBearing];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestDistanceRef];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDestDistance];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSProcessingMethod];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSAreaInformation];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDateStamp];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSDifferental];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyGPSHPositioningError];
    if (value) {
        printf("        - \n");
    }
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
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFDescription];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFFirmware];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFOwnerName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFImageName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFImageFileName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFReleaseMethod];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFReleaseTiming];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFRecordID];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFSelfTimingTime];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFCameraSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFImageSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFContinuousDrive];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFFocusMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFMeteringMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFShootingMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFLensModel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFLensMaxMM];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFLensMinMM];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFWhiteBalanceIndex];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFFlashExposureComp];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyCIFFMeasuredEV];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerCanonDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerCanonDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonOwnerName];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonCameraSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonImageSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonFlashExposureComp];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonContinuousDrive];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonLensModel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonFirmware];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerCanonAspectRatioInfo];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyMakerNikonDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyMakerNikonDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonISOSetting];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonColorMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonQuality];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonWhiteBalanceMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonSharpenMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonFocusMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonFlashSetting];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonISOSelection];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonFlashExposureComp];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonImageAdjustment];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonLensAdapter];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonLensType];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonLensInfo];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonFocusDistance];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonDigitalZoom];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonShootingMode];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonCameraSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyMakerNikonShutterCount];
    if (value) {
        printf("        - \n");
    }
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
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImageProperty8BIMLayerNames];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImageProperty8BIMVersion];
    if (value) {
        printf("        - \n");
    }
}

//CGImageSourceCopyProperties/CGImageSourceCopyPropertiesAtIndex
- (void)printCGImagePropertyDNGDictionary:(CFDictionaryRef)dic
{
    if (!dic)
        return;
    
    printf("    CGImagePropertyDNGDictionary\n");
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGVersion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGBackwardVersion];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGUniqueCameraModel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGLocalizedCameraModel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGCameraSerialNumber];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGLensInfo];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGBlackLevel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGWhiteLevel];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGCalibrationIlluminant1];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGCalibrationIlluminant2];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGColorMatrix1];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGColorMatrix2];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGCameraCalibration1];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGCameraCalibration2];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGAsShotNeutral];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGAsShotWhiteXY];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGBaselineExposure];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGBaselineNoise];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGBaselineSharpness];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGPrivateData];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGCameraCalibrationSignature];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGProfileCalibrationSignature];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGNoiseProfile];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGWarpRectilinear];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGWarpFisheye];
    if (value) {
        printf("        - \n");
    }
    
    value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyDNGFixVignetteRadial];
    if (value) {
        printf("        - \n");
    }
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
    
    const void *value = [self valueOfCGImageProperty:dic key:(const void *)kCGImagePropertyOpenEXRAspectRatio];
    if (value) {
        printf("        - \n");
    }
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
