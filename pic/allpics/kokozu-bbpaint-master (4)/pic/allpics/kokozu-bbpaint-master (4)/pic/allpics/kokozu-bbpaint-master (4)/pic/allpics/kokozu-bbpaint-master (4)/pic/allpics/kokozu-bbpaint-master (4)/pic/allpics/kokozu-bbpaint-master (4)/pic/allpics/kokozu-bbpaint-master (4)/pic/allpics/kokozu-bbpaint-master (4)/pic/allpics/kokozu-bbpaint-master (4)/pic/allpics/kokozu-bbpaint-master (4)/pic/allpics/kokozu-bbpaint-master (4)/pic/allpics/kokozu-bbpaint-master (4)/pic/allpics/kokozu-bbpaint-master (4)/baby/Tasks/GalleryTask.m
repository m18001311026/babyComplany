//
//  GalleryTask.m
//  baby
//
//  Created by zhang da on 14-3-16.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "GalleryTask.h"
#import "Gallery.h"
#import "Picture.h"
#import "User.h"
#import "GComment.h"
#import "MemContainer.h"
#import "ConfManager.h"
#import "NSDictionaryExtra.h"

#import "Session.h"

#import "GalleryTask.h"
#import "TaskQueue.h"

@implementation GalleryTask

- (void)dealloc {
    
    [super dealloc];
}

- (void)parseGalleryDict:(NSDictionary *)galleryDict galleryIds:(NSMutableArray *)galleryIds {
    NSDictionary *userDict = [galleryDict objForKey:@"users"];
    [[MemContainer me] instanceFromDict:userDict clazz:[User class]];

    NSArray *pictureList = [galleryDict objForKey:@"pictureList"];
    for (NSDictionary *pictureDict in pictureList) {
        [[MemContainer me] instanceFromDict:pictureDict clazz:[Picture class]];
    }
    
    NSArray *commentList = [galleryDict objForKey:@"commentList"];
    if ((NSNull *)commentList != [NSNull null]) {
        for (NSDictionary *commDict in commentList) {
            NSDictionary *userDict = [commDict objForKey:@"users"];
            [[MemContainer me] instanceFromDict:userDict clazz:[User class]];
            
            [[MemContainer me] instanceFromDict:commDict clazz:[GComment class]];
        }
    }
    
    Gallery *g = (Gallery *)[[MemContainer me] instanceFromDict:galleryDict clazz:[Gallery class]];
    
    if ([[ConfManager me] getSession].session ) {
        if ((NSNull *)[galleryDict objForKey:@"isShare"] != [NSNull null]) {
            g.faved = [[galleryDict objForKey:@"isShare"] boolValue];
        }
        
        NSArray *likeList = [galleryDict objForKey:@"likesList"];
        if ((NSNull *)likeList == [NSNull null]
            || !likeList.count
            || [likeList objectAtIndex:0] == [NSNull null]) {
            g.liked = @(NO);
        } else {
            g.liked = @(YES);
        }
    } else {
        g.liked = nil;
    }
    
    [galleryIds addObject:@(g._id)];
}

- (id)initGalleryList:(bool)classic page:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/home/init.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        if (classic) {
            [self addParameter:@"productionClassic" value:@"1"];
        }
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];

        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSArray *galleries = [userInfo objForKey:@"production"];
                
                if (galleries && galleries.count > 0) {
                    NSMutableArray *galleryIds = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *galleryDict in galleries) {
                        [self parseGalleryDict:galleryDict galleryIds:galleryIds];
                        NSArray *reList = [galleryDict objForKey:@"forwardList"];
                        if ((NSNull *)reList != [NSNull null]) {
                            for (NSDictionary *reDict in reList) {
                                NSDictionary *reGDict = [reDict objForKey:@"newProduction"];
                                NSDictionary *userDict = [reGDict objForKey:@"users"];
                                [[MemContainer me] instanceFromDict:userDict clazz:[User class]];
                                
                                long previousId = [[reDict objForKey:@"oldProductionId"] longValue];
                                Gallery *g = (Gallery *)[[MemContainer me] instanceFromDict:reGDict clazz:[Gallery class]];
                                g.previousId = previousId;
                            }
                        }
                    }
                    [self doLogicCallBack:YES info:[galleryIds autorelease]];
                } else {
                    [self doLogicCallBack:YES info:dict];
                }
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initReGalleryList:(long)galleryId page:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/home/findForward.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"productionId" value:[NSString stringWithFormat:@"%ld", galleryId]];
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSArray *galleries = [dict objForKey:@"forward"];
                
                if (galleries && galleries.count > 0) {
                    NSMutableArray *galleryIds = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *reDict in galleries) {
                        NSDictionary *galleryDict = [reDict objForKey:@"newProduction"];
                        [self parseGalleryDict:galleryDict galleryIds:galleryIds];
                    }
                    [self doLogicCallBack:YES info:[galleryIds autorelease]];
                } else {
                    [self doLogicCallBack:YES info:nil];
                }
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;

}

- (id)initUserGalleryList:(long)userId page:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/user/findUserProduction.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"userId" value:[NSString stringWithFormat:@"%ld", userId]];
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSArray *galleries = [dict objForKey:@"production"];
                
                if (galleries && galleries.count > 0) {
                    NSMutableArray *galleryIds = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *galleryDict in galleries) {                        
                        [self parseGalleryDict:galleryDict galleryIds:galleryIds];
                    }
                    [self doLogicCallBack:YES info:[galleryIds autorelease]];
                } else {
                    [self doLogicCallBack:YES info:nil];
                }
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initLikeGalleryListAtPage:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/user/findEnshrine.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSArray *galleries = [dict objForKey:@"production"];
                
                if (galleries && (NSNull *)galleries != [NSNull null] && galleries.count > 0) {
                    NSMutableArray *galleryIds = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *galleryDict in galleries) {
                        [self parseGalleryDict:galleryDict galleryIds:galleryIds];
                    }
                    [self doLogicCallBack:YES info:[galleryIds autorelease]];
                } else {
                    [self doLogicCallBack:YES info:nil];
                }
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initDeleteGallery:(long)galleryId {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/production/delProduction.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"productionId" value:[NSString stringWithFormat:@"%ld", galleryId]];
        
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

- (id)initGCommentList:(long)galleryId page:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/home/findProductionByOne.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"productionId" value:[NSString stringWithFormat:@"%ld", galleryId]];
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                
                NSArray *commentList = nil;
                NSMutableArray *commentIds = [[NSMutableArray alloc] init];

                if (page == 1) {
                    NSDictionary *galleryDict = [dict objForKey:@"production"];
                    commentList = [galleryDict objForKey:@"commentList"];
                } else {
                    commentList = [dict objForKey:@"comment"];
                }

                if ((NSNull *)commentList != [NSNull null]) {
                    for (NSDictionary *commDict in commentList) {
                        NSDictionary *userDict = [commDict objForKey:@"users"];
                        [[MemContainer me] instanceFromDict:userDict clazz:[User class]];
                        
                        GComment *comment = (GComment *)[[MemContainer me] instanceFromDict:commDict clazz:[GComment class]];
                        [commentIds addObject:@(comment._id)];
                    }
                }
                
                [self doLogicCallBack:YES info:[commentIds autorelease]];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;

}

- (id)initGalleryDetail:(long)galleryId {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/home/findProductionByOne.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"productionId" value:[NSString stringWithFormat:@"%ld", galleryId]];
        [self addParameter:@"pageNow" value:@"1"];

        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSDictionary *galleryDict = [dict objForKey:@"production"];
                [self parseGalleryDict:galleryDict galleryIds:nil];
                [self doLogicCallBack:YES info:@{@"galleryId": @(galleryId)}];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initDeleteComment:(long)commentId {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/production/delComment.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"commentId" value:[NSString stringWithFormat:@"%ld", commentId]];
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

- (id)initLikeGallery:(long)galleryId relation:(bool)relation {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/production/like.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"productionId" value:[NSString stringWithFormat:@"%ld", galleryId]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                Gallery *g = [Gallery getGalleryWithId:galleryId];
                if (relation) {
                    g.likeCnt = g.likeCnt + 1;
                    g.liked = @(YES);
                } else {
                    g.likeCnt = MAX(g.likeCnt - 1, 0);
                    g.liked = @(NO);
                }
                [self doLogicCallBack:YES info:userInfo];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initFavGallery:(long)galleryId relation:(bool)relation {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/production/enshrine.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"productionId" value:[NSString stringWithFormat:@"%ld", galleryId]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                Gallery *g = [Gallery getGalleryWithId:galleryId];
                g.faved = relation;
                [self doLogicCallBack:YES info:userInfo];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
