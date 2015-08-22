//
//  GalleryCell.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "HorizonPictureCell.h"
#import "ImageView.h"
#import "Picture.h"


@interface HorizonPictureCell()

@end



@implementation HorizonPictureCell

- (void)dealloc {
    self.picturePath = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        
        pictureView = [[ImageView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
        pictureView.backgroundColor = [UIColor whiteColor];
        pictureView.clipsToBounds = YES;
        pictureView.userInteractionEnabled = YES;
        pictureView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:pictureView];
        [pictureView release];
    }
    return self;
}

- (void)updateLayout {
    pictureView.imagePath = self.picturePath;
}

@end
