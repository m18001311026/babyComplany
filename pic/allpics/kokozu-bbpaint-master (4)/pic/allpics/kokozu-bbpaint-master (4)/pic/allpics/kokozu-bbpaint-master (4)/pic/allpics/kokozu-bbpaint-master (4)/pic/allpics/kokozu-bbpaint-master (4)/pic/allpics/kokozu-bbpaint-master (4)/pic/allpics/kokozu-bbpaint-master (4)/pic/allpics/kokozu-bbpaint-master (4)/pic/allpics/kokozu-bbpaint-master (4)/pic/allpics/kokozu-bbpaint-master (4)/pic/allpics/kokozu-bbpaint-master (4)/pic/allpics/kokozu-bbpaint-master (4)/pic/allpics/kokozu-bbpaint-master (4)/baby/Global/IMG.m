//
//  IMG.m
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "IMG.h"
#import "Constants.h"
#import "NSStringExtra.h"

#import "ImageTask.h"
#import "TaskQueue.h"


static NSMutableDictionary *cache;

@implementation IMG

+ (void)createDirection {
    NSString *imgPath = [NSTemporaryDirectory() stringByAppendingString:IMAGE_CACHE_FOLDER];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imgPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imgPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
}

+ (void)resetCache {
    NSString *imgPath = [NSTemporaryDirectory() stringByAppendingString:IMAGE_CACHE_FOLDER];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:imgPath
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:nil];
}

+ (NSString *)imageDiskDir:(NSString *)url {
    NSString *fUrl = [url URLEncodedString];
    return [NSTemporaryDirectory() stringByAppendingFormat:@"%@/%@", IMAGE_CACHE_FOLDER, fUrl];
}

+ (void)getImage:(NSString *)url callback:(ImageDone)callback {
    UIImage *image = [self getImageFromMem:url];
    if (!image) {
        [self getImageFromDisk:url callback:^(NSString *rUrl, UIImage *image) {
            if (image) {
                if (callback) {
                    callback(url, image);
                }
            } else {
                [self getImageFromNetwork:url callback:^(NSString *rUrl, UIImage *image) {
                    if (callback) {
                        callback(url, image);
                    }
                }];
            }
        }];
    } else {
        callback(url, image);
    }
}

+ (UIImage *)getImageFromMem:(NSString *)url {
    if (cache && cache.count) {
        NSString *fUrl = [url URLEncodedString];
        return [cache objectForKey:fUrl];
    }
    return nil;
}

+ (UIImage *)getImageFromDisk:(NSString *)url {
    UIImage *image = [[[UIImage alloc] initWithContentsOfFile:[self imageDiskDir:url]] autorelease];
    [self saveImageToMem:image withUrl:url];
    return image;
}

+ (void)getImageFromDisk:(NSString *)url callback:(ImageDone)callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *img = [[[UIImage alloc] initWithContentsOfFile:[self imageDiskDir:url]] autorelease];
        [self saveImageToMem:img withUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(url, img);
            }
        });
    });
}

+ (void)getImageFromNetwork:(NSString *)url callback:(ImageDone)callback {
    ImageTask *task = [[ImageTask alloc] initGetImage:url];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        if (succeeded) {
            UIImage *img = (UIImage *)[userInfo objectForKey:@"image"];
            [self saveImage:img withUrl:url sync:NO];
            if (callback) {
                callback(url, img);
            }
        } else {
            if (callback) {
                callback(url, nil);
            }
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

+ (void)saveImageToMem:(UIImage *)image withUrl:(NSString *)url {
    if (image.size.width*image.size.height < IMAGE_SIZE_THREADHOLD) {
        if (cache.count < IMAGE_CAHCE_MAX) {
            @synchronized([IMG class]) {
                [cache removeAllObjects];
            }
        }
        NSString *fUrl = [url URLEncodedString];
        if (image) {
            @synchronized([IMG class]) {
                [cache setObject:image forKey:fUrl];
            }
        } else {
            NSLog(@"image is null: %@", fUrl);
        }
    }
}

+ (void)saveImage:(UIImage *)image withUrl:(NSString *)url sync:(bool)sync {
    if (!cache) {
        @synchronized([IMG class]) {
            if (!cache) {
                cache = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
        }
    }
    
    NSString *imgPath = [self imageDiskDir:url];
    if (sync) {
        if ( ![UIImagePNGRepresentation(image) writeToFile:imgPath options:NSAtomicWrite error:nil] ) {
            NSLog(@"save error");
            [self createDirection];
        }
    } else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            if ( ![UIImagePNGRepresentation(image) writeToFile:imgPath options:NSAtomicWrite error:nil] ) {
                NSLog(@"save error");
                [self createDirection];
            }
        });
    }
    [self saveImageToMem:image withUrl:url];
}

@end
