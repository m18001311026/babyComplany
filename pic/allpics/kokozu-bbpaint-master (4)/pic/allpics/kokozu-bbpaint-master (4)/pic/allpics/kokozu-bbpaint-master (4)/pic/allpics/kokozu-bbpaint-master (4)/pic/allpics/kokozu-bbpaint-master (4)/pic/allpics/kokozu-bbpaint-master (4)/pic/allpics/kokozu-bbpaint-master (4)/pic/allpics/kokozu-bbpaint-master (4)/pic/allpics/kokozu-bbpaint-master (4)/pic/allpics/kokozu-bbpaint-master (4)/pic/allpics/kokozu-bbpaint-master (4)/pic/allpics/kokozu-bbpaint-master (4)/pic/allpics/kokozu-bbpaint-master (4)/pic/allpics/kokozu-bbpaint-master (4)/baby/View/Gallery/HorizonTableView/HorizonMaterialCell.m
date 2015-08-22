//
//  GalleryCell.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "HorizonMaterialCell.h"
#import "ImageView.h"
#import "Picture.h"


@interface HorizonMaterialCell()

@end



@implementation HorizonMaterialCell

- (void)dealloc {
    self.picturePath = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        
        pictureView = [[ImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width - 4, frame.size.height - 4)];
        pictureView.backgroundColor = [UIColor whiteColor];
        pictureView.clipsToBounds = YES;
        pictureView.userInteractionEnabled = YES;
        //pictureView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:pictureView];
        [pictureView release];
    }
    return self;
}

- (void)updateLayout {
    pictureView.imagePath = self.picturePath;
}

@end
