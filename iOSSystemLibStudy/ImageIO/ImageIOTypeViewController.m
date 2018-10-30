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
//        CFArrayRef arrayRef = (CFArrayRef)value;
//        NSArray *array = (__bridge NSArray *)arrayRef;
//        printf("    - CGImageSource Properties kCGImagePropertyJFIFVersion : ");
//        int count = (int)array.count;
//        for (int index = 0; index < count; index++) {
//            NSNumber *num = array[index];
//            if (index != count - 1) {
//                printf("%d.", num.intValue);
//            } else {
//                printf("%d", num.intValue);
//            }
//        }
//        printf("\n");
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
    
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCCaptionAbstract  IMAGEIO_AVAILABLE_STARTING(10.4, 4.0);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCWriterEditor  IMAGEIO_AVAILABLE_STARTING(10.4, 4.0);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCImageType  IMAGEIO_AVAILABLE_STARTING(10.4, 4.0);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCImageOrientation  IMAGEIO_AVAILABLE_STARTING(10.4, 4.0);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCLanguageIdentifier  IMAGEIO_AVAILABLE_STARTING(10.4, 4.0);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCStarRating  IMAGEIO_AVAILABLE_STARTING(10.4, 4.0);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCCreatorContactInfo  IMAGEIO_AVAILABLE_STARTING(10.6, 4.0);  // IPTC Core
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCRightsUsageTerms  IMAGEIO_AVAILABLE_STARTING(10.6, 4.0);    // IPTC Core
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCScene  IMAGEIO_AVAILABLE_STARTING(10.6, 4.0);               // IPTC Core
    
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAboutCvTerm  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAboutCvTermCvId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAboutCvTermId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAboutCvTermName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAboutCvTermRefinedAbout  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAddlModelInfo  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkOrObject  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkCircaDateCreated  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkContentDescription  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkContributionDescription  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkCopyrightNotice  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkCreator  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkCreatorID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkCopyrightOwnerID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkCopyrightOwnerName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkLicensorID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkLicensorName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkDateCreated  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkPhysicalDescription  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkSource  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkSourceInventoryNo  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkSourceInvURL  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkStylePeriod  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtArtworkTitle  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAudioBitrate  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAudioBitrateMode  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtAudioChannelCount  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtCircaDateCreated  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtContainerFormat  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtContainerFormatIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtContainerFormatName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtContributor  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtContributorIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtContributorName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtContributorRole  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtCopyrightYear  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtCreator  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtCreatorIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtCreatorName     IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtCreatorRole  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtControlledVocabularyTerm  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreen  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegion  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegionD  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegionH  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegionText  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegionUnit  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegionW  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegionX  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDataOnScreenRegionY  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDigitalImageGUID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDigitalSourceFileType  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDigitalSourceType  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDopesheet  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDopesheetLink  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDopesheetLinkLink  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtDopesheetLinkLinkQualifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEmbdEncRightsExpr  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEmbeddedEncodedRightsExpr  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprType  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprLangID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEpisode  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEpisodeIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEpisodeName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEpisodeNumber  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtEvent  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtShownEvent  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtShownEventIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtShownEventName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtExternalMetadataLink  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtFeedIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtGenre  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtGenreCvId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtGenreCvTermId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtGenreCvTermName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtGenreCvTermRefinedAbout  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtHeadline  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtIPTCLastEdited  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLinkedEncRightsExpr  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLinkedEncodedRightsExpr  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLinkedEncodedRightsExprType  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLinkedEncodedRightsExprLangID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationCreated  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationCity  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationCountryCode  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationCountryName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationGPSAltitude  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationGPSLatitude  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationGPSLongitude  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationLocationId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationLocationName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationProvinceState  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationSublocation  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationWorldRegion  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtLocationShown  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtMaxAvailHeight  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtMaxAvailWidth  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtModelAge  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtOrganisationInImageCode  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtOrganisationInImageName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonHeard  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonHeardIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonHeardName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImage  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageWDetails  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageCharacteristic  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageCvTermCvId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageCvTermId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageCvTermName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageCvTermRefinedAbout  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageDescription  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPersonInImageName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtProductInImage  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtProductInImageDescription  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtProductInImageGTIN  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtProductInImageName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPublicationEvent  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPublicationEventDate  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPublicationEventIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtPublicationEventName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRating  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRatingRegion  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionCity  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionCountryCode  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionCountryName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionGPSAltitude  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionGPSLatitude  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionGPSLongitude  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionLocationId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionLocationName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionProvinceState  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionSublocation  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingRegionWorldRegion  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingScaleMaxValue  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingScaleMinValue  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingSourceLink  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingValue  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRatingValueLogoLink  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRegistryID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRegistryEntryRole  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRegistryItemID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtRegistryOrganisationID  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtReleaseReady  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSeason  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSeasonIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSeasonName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSeasonNumber  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSeries  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSeriesIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSeriesName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtStorylineIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtStreamReady  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtStylePeriod  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSupplyChainSource  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSupplyChainSourceIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtSupplyChainSourceName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtTemporalCoverage  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtTemporalCoverageFrom  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtTemporalCoverageTo  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtTranscript  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtTranscriptLink  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtTranscriptLinkLink  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtTranscriptLinkLinkQualifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoBitrate  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoBitrateMode  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoDisplayAspectRatio  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoEncodingProfile  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoShotType  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoShotTypeIdentifier  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoShotTypeName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVideoStreamsCount  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtVisualColor  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtWorkflowTag  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtWorkflowTagCvId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtWorkflowTagCvTermId  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtWorkflowTagCvTermName  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
    IMAGEIO_EXTERN const CFStringRef kCGImagePropertyIPTCExtWorkflowTagCvTermRefinedAbout  IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
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
