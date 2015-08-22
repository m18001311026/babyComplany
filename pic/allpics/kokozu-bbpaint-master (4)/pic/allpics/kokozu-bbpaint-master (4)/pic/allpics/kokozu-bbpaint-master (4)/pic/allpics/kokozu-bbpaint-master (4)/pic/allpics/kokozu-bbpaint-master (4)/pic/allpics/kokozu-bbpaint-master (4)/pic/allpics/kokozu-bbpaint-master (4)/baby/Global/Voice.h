//
//  Media
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void ( ^VoiceDone )(NSString *url, NSData *voice);

@interface Voice : NSObject

+ (void)getVoice:(NSString *)url callback:(VoiceDone)callback;
+ (void)getVoiceFromDisk:(NSString *)url callback:(VoiceDone)callback;
+ (void)getVoiceFromNetwork:(NSString *)url callback:(VoiceDone)callback;

/*
 保存某个url的图片，会根据图片的大小自动判断是否存入缓存
 */
+ (void)saveVoice:(NSData *)voice withUrl:(NSString *)url sync:(bool)sync;

@end
