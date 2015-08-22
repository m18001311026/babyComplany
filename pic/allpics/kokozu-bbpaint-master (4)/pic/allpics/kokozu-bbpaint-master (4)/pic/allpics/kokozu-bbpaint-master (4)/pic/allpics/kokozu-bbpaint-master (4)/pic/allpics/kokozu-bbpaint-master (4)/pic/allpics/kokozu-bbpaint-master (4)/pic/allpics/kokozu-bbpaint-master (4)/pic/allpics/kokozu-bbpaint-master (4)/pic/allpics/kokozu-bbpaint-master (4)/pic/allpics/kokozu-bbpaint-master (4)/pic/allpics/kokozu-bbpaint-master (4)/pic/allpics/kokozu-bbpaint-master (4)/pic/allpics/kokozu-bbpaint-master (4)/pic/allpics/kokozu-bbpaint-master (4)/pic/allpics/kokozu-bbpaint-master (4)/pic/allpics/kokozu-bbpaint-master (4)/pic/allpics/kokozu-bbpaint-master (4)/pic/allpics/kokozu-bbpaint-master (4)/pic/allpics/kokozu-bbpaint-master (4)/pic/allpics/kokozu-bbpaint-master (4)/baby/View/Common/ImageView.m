//
//  ImageView.m
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView

- (void)dealloc {
    self.imagePath = nil;
    [indicator release];
    
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (indicator) {
        indicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);        
    }
    if (imageUrl) {
        imageUrl.frame = CGRectMake(0, 0, frame.size.width, 30);
    }
}

- (id)init {
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        indicator = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.hidesWhenStopped = YES;
        [self addSubview:indicator];
        
//        imageUrl = [[UILabel alloc] init];
//        imageUrl.backgroundColor = [UIColor clearColor];
//        imageUrl.textColor = [Shared bbYellow];
//        imageUrl.font = [UIFont systemFontOfSize:11];
//        [self addSubview:imageUrl];
//        [imageUrl release];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [self init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;

        indicator = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.hidesWhenStopped = YES;
        indicator.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:indicator];
        
//        imageUrl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
//        imageUrl.backgroundColor = [UIColor clearColor];
//        imageUrl.textColor = [Shared bbYellow];
//        imageUrl.numberOfLines = 0;
//        imageUrl.font = [UIFont systemFontOfSize:11];
//        [self addSubview:imageUrl];
//        [imageUrl release];
    }
    return self;
}

- (void)setImagePath:(NSString *)imagePath {
    [self setImagePath:imagePath done:nil];
}

- (void)setImagePath:(NSString *)imagePath done:(void (^)())block {
    if (_imagePath != imagePath) {
        [_imagePath release];
        _imagePath = [imagePath retain];
        
        self.image = nil;
        
        //NSLog(@"set image path : %@", imagePath);
        
        if (_imagePath) {
            self.image = [IMG getImageFromMem:_imagePath];
            if (!self.image) {
                [indicator startAnimating];
                [IMG getImage:_imagePath callback:^(NSString *url, UIImage *image) {
                    if ([_imagePath isEqualToString:url]) {
                        //NSLog(@"%@，%@", NSStringFromCGRect(self.frame), image);
                        
                        if (image) {
                            @try {
                                self.image = image;
                                if (block) {
                                    block();
                                }
                            }
                            @catch (NSException *exception) {
                                
                            }
                            @finally {
                                
                            }
                        } else {
                            self.image = nil;
                            self.imagePath = nil;
                            NSLog(@"----download failed:%@", self.imagePath);
                            
                            if (block) {
                                block();
                            }
                        }
                        [indicator stopAnimating];
                        
                        //                        if (!image) {
                        //                            [UI showAlert:@"failed"];
                        //                        }
                    }
                }];
            }
        }
    } else if (!self.image && _imagePath) {
        if (_imagePath) {
            self.image = [IMG getImageFromMem:_imagePath];
            if (!self.image) {
                [indicator startAnimating];
                [IMG getImage:_imagePath callback:^(NSString *url, UIImage *image) {
                    if ([_imagePath isEqualToString:url]) {
                        //NSLog(@"%@，%@", NSStringFromCGRect(self.frame), image);
                        self.image = image;
                        if (block) {
                            block();
                        }
                        [indicator stopAnimating];
                    }
                }];
            }
        }
    } else if (self.image && !_imagePath) {
        self.image = nil;
        if (block) {
            block();
        }
    }
    
    imageUrl.text = imagePath;
}

@end
