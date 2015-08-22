//
//  IMG.h
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void ( ^ImageDone )(NSString *url, UIImage *image);

@interface IMG : NSObject

+ (void)getImage:(NSString *)url callback:(ImageDone)callback;

+ (UIImage *)getImageFromMem:(NSString *)url;
+ (UIImage *)getImageFromDisk:(NSString *)url;
+ (void)getImageFromDisk:(NSString *)url callback:(ImageDone)callback;
+ (void)getImageFromNetwork:(NSString *)url callback:(ImageDone)callback;

/*
 保存某个url的图片，会根据图片的大小自动判断是否存入缓存
 */
+ (void)saveImage:(UIImage *)image withUrl:(NSString *)url sync:(bool)sync;
+ (void)resetCache;

@end
