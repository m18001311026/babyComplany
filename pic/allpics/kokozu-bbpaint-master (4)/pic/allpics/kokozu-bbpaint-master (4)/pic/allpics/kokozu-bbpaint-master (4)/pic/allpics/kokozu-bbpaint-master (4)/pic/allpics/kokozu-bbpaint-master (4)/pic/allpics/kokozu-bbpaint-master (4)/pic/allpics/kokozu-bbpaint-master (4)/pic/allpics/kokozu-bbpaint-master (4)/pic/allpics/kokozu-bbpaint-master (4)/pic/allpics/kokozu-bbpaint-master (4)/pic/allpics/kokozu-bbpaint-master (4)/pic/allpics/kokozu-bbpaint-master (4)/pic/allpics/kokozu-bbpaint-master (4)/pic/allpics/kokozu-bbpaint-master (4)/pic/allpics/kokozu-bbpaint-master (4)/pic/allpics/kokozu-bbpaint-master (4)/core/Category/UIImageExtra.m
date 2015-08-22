//
//  UIImageExtra.m
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UIImageExtra.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation UIImage (Extra)

+ (void)readLocalLatestPicture:(LocalGalleryImageGot)callback {
    static ALAssetsLibrary *library = nil;
    if (!library) {
        library = [[ALAssetsLibrary alloc] init];
    }
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop){
                               if (group) {
                                   [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                   [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                          usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                       
                                       if (alAsset) {
                                           ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                           UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                                           *stop = YES;  *innerStop = YES;
                                           callback(latestPhoto);
                                           
                                       }
                                   }];
                               } else {
                                   callback(nil);
                               }
                           }
                         failureBlock:nil];
}

+ (CGRect)rectFromOriginSize:(CGSize)oSize toDesiredSize:(CGSize)dSize fill:(BOOL)fill {
    if (oSize.height == 0 || oSize.width == 0) {
        return CGRectZero;
    }
    
    CGSize fSize = CGSizeMake(
                    (dSize.width == 0? oSize.width / oSize.height * dSize.height: dSize.width),
                    (dSize.height == 0? oSize.height / oSize.width * dSize.width: dSize.height)
                   );
    
    if (fSize.width == 0) {
        fSize.width = oSize.width;
    }
    if (fSize.height == 0) {
        fSize.height = oSize.height;
    }
    
    float scaleW = fSize.width / oSize.width * 1.0;
    float scaleH = fSize.height / oSize.height * 1.0;
    float scaleFinal = fill? MAX(scaleW, scaleH): MIN(scaleW, scaleH);
    return CGRectMake((fSize.width - oSize.width * scaleFinal) / 2,
                      (fSize.height - oSize.height * scaleFinal) / 2,
                      oSize.width * scaleFinal,
                      oSize.height * scaleFinal);
}

- (UIImage*)subImageWithRect:(CGRect)rect backgroundColor:(UIColor *)color {
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height);
    
    //clip to the bounds of the image context
    //not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, drawRect.size.width, drawRect.size.height));
    
    //add background color
    [color set];

    CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    //draw image
    [self drawInRect:drawRect];
    
    //grab image
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return subImage;
}

- (UIImage *)rotatedImage:(CGAffineTransform)trans {
    // Calculate Destination Size
    //CGAffineTransform t = trans;//CGAffineTransformMakeRotation(rotation);
    float angle = atan2(trans.b, trans.a);
    CGRect sizeRect = (CGRect) {.size = self.size};
    CGRect destRect = CGRectApplyAffineTransform(sizeRect, trans);
    CGSize destinationSize = destRect.size;
    
    // Draw image
    UIGraphicsBeginImageContext(destinationSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, destinationSize.width / 2.0f, destinationSize.height / 2.0f);
    CGContextRotateCTM(context, angle);
    [self drawInRect:CGRectMake(-self.size.width / 2.0f, -self.size.height / 2.0f, self.size.width, self.size.height)];
    
    // Save image
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)decodedImageToSize:(CGSize)finalSize fill:(BOOL)fill {

    CGRect rect = [UIImage rectFromOriginSize:self.size toDesiredSize:finalSize fill:fill];
    
    if (rect.size.width == 0 || rect.size.height == 0) {
        return nil;
    } else {
        CGImageRef imageRef = self.CGImage;
        
        //jpg file, some kind of jpg file not supported
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     finalSize.width,
                                                     finalSize.height,
                                                     8,
                                                     rect.size.width * 4,
                                                     colorSpace,
                                                     (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(colorSpace);
        if (context) {
            CGContextDrawImage(context, rect, imageRef);
            CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef
                                                                    scale:self.scale
                                                              orientation:self.imageOrientation];
            CGImageRelease(decompressedImageRef);
            return [decompressedImage autorelease];
        } else {
            CGContextRelease(context);
        }
        
        //png file
        if (rect.size.width != 0 && rect.size.height != 0) {
            UIGraphicsBeginImageContext(rect.size);
        } else if (finalSize.width != 0 && finalSize.height != 0) {
            UIGraphicsBeginImageContext(finalSize);
        }
        //CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextDrawImage(context, rect, imageRef); may upside down
        [self drawInRect:rect];
        UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return imageCopy;
    }
    
}

@end
