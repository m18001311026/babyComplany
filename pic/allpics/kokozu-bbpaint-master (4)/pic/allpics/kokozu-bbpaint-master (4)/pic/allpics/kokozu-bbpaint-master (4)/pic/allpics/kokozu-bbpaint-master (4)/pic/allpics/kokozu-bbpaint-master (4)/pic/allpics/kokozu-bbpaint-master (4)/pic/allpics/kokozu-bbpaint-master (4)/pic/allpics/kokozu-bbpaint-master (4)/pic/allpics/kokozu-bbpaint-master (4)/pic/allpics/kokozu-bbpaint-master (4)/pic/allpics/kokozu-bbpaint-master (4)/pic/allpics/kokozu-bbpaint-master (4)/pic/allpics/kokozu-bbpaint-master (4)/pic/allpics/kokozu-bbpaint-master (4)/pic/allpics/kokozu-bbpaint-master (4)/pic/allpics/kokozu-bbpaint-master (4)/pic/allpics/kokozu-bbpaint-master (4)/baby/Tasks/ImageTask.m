//
//  ImageTask.m
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ImageTask.h"

@implementation ImageTask

- (id)initGetImage:(NSString *)url {
    self = [super initWithUrl:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] method:GET];
    if (self) {
        self.rawData = YES;
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                UIImage *image = [UIImage imageWithData:userInfo];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image", url, @"url", nil];
                [self doLogicCallBack:YES info:dict];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
