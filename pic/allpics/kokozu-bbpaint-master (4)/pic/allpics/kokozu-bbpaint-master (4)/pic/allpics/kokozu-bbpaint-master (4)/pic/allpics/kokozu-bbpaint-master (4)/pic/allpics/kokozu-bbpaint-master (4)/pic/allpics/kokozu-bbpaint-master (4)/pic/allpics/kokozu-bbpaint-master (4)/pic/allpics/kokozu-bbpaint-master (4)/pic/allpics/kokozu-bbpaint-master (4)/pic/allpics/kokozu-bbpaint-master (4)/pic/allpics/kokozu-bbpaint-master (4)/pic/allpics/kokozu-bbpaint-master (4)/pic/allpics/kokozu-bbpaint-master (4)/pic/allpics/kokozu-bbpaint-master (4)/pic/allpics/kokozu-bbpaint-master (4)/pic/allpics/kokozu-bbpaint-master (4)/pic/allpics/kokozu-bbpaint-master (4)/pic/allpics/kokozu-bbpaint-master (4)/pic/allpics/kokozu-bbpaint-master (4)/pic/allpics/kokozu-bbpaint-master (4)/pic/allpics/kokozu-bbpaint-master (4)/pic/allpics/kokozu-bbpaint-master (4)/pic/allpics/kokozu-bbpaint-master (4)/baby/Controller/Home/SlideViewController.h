//
//  HomeViewController.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "HorizonTableView.h"
#import "BBViewController.h"
#import "HorizonPictureCell.h"

@interface SlideViewController : BBViewController <HorizonTableViewDatasource, HorizonTableViewDelegate> {
    
    int currentPage;
    HorizonTableView *galleryTable;
    NSMutableArray *pictures;
    
    UILabel *source, *re;
    
}

- (id)initWithGallery:(long)galleryId;

@end
