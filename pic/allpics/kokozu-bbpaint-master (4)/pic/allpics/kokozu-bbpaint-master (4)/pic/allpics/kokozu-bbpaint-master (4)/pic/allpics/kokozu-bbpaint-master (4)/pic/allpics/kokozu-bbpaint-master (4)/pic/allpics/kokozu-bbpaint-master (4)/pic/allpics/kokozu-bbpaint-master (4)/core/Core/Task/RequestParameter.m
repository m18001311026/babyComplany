//
//  RequestParameter.m
//  TestTaskQueue
//
//  Created by zhang da on 11-5-16.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#import "RequestParameter.h"
#import "NSStringExtra.h"

@implementation RequestParameter

- (id)initWithName:(NSString *)aName value:(NSString *)aValue enc:(NSStringEncoding)aEnc {
    self = [super init];
    if (self ) {
		self.name = aName;
		self.value = aValue;
        self.enc = aEnc;
        self.valueIsData = NO;
	}
    return self;
}

- (id)initWithName:(NSString *)aName data:(NSData *)aData fileName:(NSString *)aFileName {
    self = [super init];
    if (self ) {
		self.name = aName;
		self.value = aData;
        self.enc = NSUTF8StringEncoding;
        self.fileName = aFileName;
        self.valueIsData = YES;
	}
    return self;
}

- (void)dealloc {

    self.name = nil;
    self.value = nil;
    self.fileName = nil;
    self.enc = 0;

	[super dealloc];
}

- (NSString *)URLEncodedNameValuePair {
    return [NSString stringWithFormat:@"%@=%@",
            [[NSString stringWithFormat:@"%@", self.name] URLEncodedString],
            [self.value stringByAddingPercentEscapesUsingEncoding:self.enc] ];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@)%@ = %@",
            self.valueIsData? @"data": @"normal",
            self.name,
            self.valueIsData? self.fileName: self.value];
}

@end
