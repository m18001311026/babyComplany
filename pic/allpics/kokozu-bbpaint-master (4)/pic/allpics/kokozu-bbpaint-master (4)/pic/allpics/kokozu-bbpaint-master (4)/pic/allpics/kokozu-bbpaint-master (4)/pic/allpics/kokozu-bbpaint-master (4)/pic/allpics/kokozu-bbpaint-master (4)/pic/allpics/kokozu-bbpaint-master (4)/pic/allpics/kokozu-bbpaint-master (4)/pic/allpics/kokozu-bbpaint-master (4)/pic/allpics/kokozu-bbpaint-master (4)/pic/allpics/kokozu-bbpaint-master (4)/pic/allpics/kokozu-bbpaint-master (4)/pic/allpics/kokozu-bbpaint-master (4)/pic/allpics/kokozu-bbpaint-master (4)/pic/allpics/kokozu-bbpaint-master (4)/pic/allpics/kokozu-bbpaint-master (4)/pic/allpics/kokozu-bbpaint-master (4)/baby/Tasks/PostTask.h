//
//  PostTask.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBNetworkTask.h"

@interface PostTask : BBNetworkTask

- (id)initNewGallery:(NSArray *)pictures
             content:(NSString *)content
               voice:(NSData *)voice
              length:(int)voiceLength
                  re:(long)originalGalleryId;

- (id)initNewGCommentForGallery:(long)galleryId
                        replyTo:(NSString *)replyTo
                          voice:(NSData *)voice
                         length:(int)voiceLength
                        content:(NSString *)content;

@end
