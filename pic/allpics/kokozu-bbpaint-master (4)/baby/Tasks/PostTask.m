//
//  PostTask.m
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "PostTask.h"
#import "ConfManager.h"
#import "Session.h"
#import "MemContainer.h"
#import "Picture.h"

@implementation PostTask

- (void)dealloc {

    [super dealloc];
}

- (id)initNewGallery:(NSArray *)pictures
             content:(NSString *)content
               voice:(NSData *)voice
              length:(int)voiceLength
                  re:(long)originalGalleryId {
    
    if (!pictures) {
        return nil;
    }
    
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/publish/add.do", SERVERURL]
                       method:POST
                      session:[[ConfManager me] getSession].session];
    
    if (self) {
        if (originalGalleryId) {
            [self addParameter:@"newProductionId"
                         value:[NSString stringWithFormat:@"%ld", originalGalleryId]];
        }
        if (voice && voiceLength > 0) {
            [self addParameter:@"productionVoice" value:voice fileName:@"voice.mp3"];
            [self addParameter:@"productionVoiceLength" value:[NSString stringWithFormat:@"%d", voiceLength]];
        }
        if (content) {
            [self addParameter:@"productionText" value:content];
        }
        for (UIImage *picture in pictures) {
            [self addParameter:@"productionPictue"
                         value:UIImageJPEGRepresentation(picture, 1.0)
                      fileName:@"image.jpg"];
        }
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                [self doLogicCallBack:YES info:nil];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initNewGCommentForGallery:(long)galleryId
                        replyTo:(NSString *)replyTo
                          voice:(NSData *)voice
                         length:(int)voiceLength
                        content:(NSString *)content {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/production/comment.do", SERVERURL]
                       method:POST
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"productionId" value:[NSString stringWithFormat:@"%ld", galleryId]];
        if (voice && voiceLength > 0) {
            [self addParameter:@"commentVoice" value:voice fileName:@"voice.mp3"];
            [self addParameter:@"commentVoiceLength" value:[NSString stringWithFormat:@"%d", voiceLength]];
        }
        if (content) {
            [self addParameter:@"commentText" value:content];
        }
        if (replyTo) {
            [self addParameter:@"replyTo" value:replyTo];
        }
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                [self doLogicCallBack:YES info:dict];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
