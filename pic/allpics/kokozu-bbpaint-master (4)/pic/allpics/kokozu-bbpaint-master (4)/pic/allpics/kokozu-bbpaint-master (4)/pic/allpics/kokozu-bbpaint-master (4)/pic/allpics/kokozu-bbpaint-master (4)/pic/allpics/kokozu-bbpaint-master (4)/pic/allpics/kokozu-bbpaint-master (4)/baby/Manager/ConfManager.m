//
//  ConfManager.m
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ConfManager.h"
#import "Session.h"

#define SERVER_VER [[[NSUserDefaults standardUserDefaults] valueForKey:@"SERVER_VER"] floatValue]
#define SERVER_VER_WRITE(ver) [[NSUserDefaults standardUserDefaults] setValue:@(ver) forKey:@"SERVER_VER"]

#define USER_DEFAULT_SAVE [[NSUserDefaults standardUserDefaults] synchronize]


@interface ConfManager () {
    float _serverVesion;
}

@end


@implementation ConfManager

static ConfManager *_me = nil;

#define SESSION_KEY @"bb.config.session"

+ (ConfManager *)me {
    if (!_me) {
        @synchronized([ConfManager class]) {
            if (!_me) {
                NSLog(@"config manager init");
                _me = [[ConfManager alloc] init];
            }
        }
    }
    return _me;
}

- (id)init {
    self = [super init];
    if (self) {
        _serverVesion = SERVER_VER;
    }
    return self;
}

- (void)setSession:(Session *)session {
    [[NSUserDefaults standardUserDefaults] setObject:[session exportData] forKey:SESSION_KEY];
    USER_DEFAULT_SAVE;
}

- (Session *)getSession {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SESSION_KEY];
    if (dict) {
        Session *session = (Session *)[Session instanceFromDict:dict];
        if (![session expired]) {
            return session;
        }
    }
    return nil;
}

- (NSString *)sessionId {
    return self.getSession.session;
}

- (long)userId {
    return [self getSession].userId;
}

- (void)updateServerVesion:(float)version andReviewStatus:(bool)inReview {
    _serverVesion = version;
    SERVER_VER_WRITE(version);
    USER_DEFAULT_SAVE;
}

- (float)serverVersion {
    return _serverVesion;
}

+ (NSString *)getCurrentVersion {
	NSDictionary *softwareInfo = [[NSDictionary alloc] initWithContentsOfFile:
								  [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Info.plist"]];
    NSString *version = [[softwareInfo objectForKey:@"CFBundleShortVersionString"] retain];
    [softwareInfo release];

    return [version autorelease];
}

@end
