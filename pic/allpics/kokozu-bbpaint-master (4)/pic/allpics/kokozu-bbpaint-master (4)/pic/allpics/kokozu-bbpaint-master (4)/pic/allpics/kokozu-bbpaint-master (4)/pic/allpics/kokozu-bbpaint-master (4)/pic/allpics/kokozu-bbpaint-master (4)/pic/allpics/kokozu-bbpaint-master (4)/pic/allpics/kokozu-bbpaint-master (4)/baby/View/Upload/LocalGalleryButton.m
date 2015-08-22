//
//  LocalGalleryButton.m
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "LocalGalleryButton.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageExtra.h"

@implementation LocalGalleryButton

- (void)dealloc {
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Initialization code
        loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        loadingView.hidesWhenStopped = YES;
        loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [self addSubview:loadingView];
        [loadingView startAnimating];
        [loadingView release];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [UIImage readLocalLatestPicture:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        [self setImage:image forState:UIControlStateNormal];
                    } else {
                        [self setTitle:@"相册" forState:UIControlStateNormal];
                        self.titleLabel.font = [UIFont systemFontOfSize:12];
                    }
                    [loadingView stopAnimating];
                });
            }];
        });

        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.cornerRadius = 2;
        self.layer.borderWidth = 1;
        self.layer.masksToBounds = YES;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


@end
