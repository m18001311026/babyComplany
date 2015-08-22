//
//  HomeViewController.m
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "SlideViewController.h"
#import "WelcomeViewController.h"
#import "GalleryPopViewController.h"
#import "NewGalleryViewController.h"
#import "UserViewController.h"
#import "UIButtonExtra.h"
#import "ConfManager.h"
#import "TabbarController.h"
//#import "ShareManager.h"

#import "GalleryTask.h"
#import "TaskQueue.h"

#import "Gallery.h"
#import "Picture.h"
#import "MemContainer.h"

#define PAGESIZE 5
#define CUR_PAGE_KEY @"_currentPage"

@interface SlideViewController ()

@property (nonatomic, assign) long galleryId;

@end


@implementation SlideViewController

- (void)dealloc {
    [pictures release];
    
    galleryTable.delegate = nil;
    galleryTable.dataSource = nil;
    
    [galleryTable removeObserver:self forKeyPath:CUR_PAGE_KEY];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (id)initWithGallery:(long)galleryId {
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];

        galleryTable = [[HorizonTableView alloc] initWithFrame:CGRectMake(0, 50 , 320, screentContentHeight - 100)];
        galleryTable.delegate = self;
        galleryTable.dataSource = self;
        galleryTable.backgroundColor = [UIColor blackColor];
        [self.view addSubview:galleryTable];
        [galleryTable release];

        [galleryTable addObserver:self
                       forKeyPath:CUR_PAGE_KEY
                          options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                          context:NULL];
        
        source = [[UILabel alloc] initWithFrame:CGRectMake(110, 14, 46, 18)];
        source.backgroundColor = [UIColor clearColor];
        source.font = [UIFont systemFontOfSize:16];
        source.text = @"原作";
        source.textColor = [UIColor orangeColor];
        source.textAlignment = NSTextAlignmentRight;
        [bbTopbar addSubview:source];
        [source release];
        
        re = [[UILabel alloc] initWithFrame:CGRectMake(164, 14, 48, 18)];
        re.backgroundColor = [UIColor clearColor];
        re.font = [UIFont systemFontOfSize:16];
        re.text = @"转发";
        re.textColor = [UIColor whiteColor];
        re.textAlignment = NSTextAlignmentLeft;
        [bbTopbar addSubview:re];
        [re release];
        
        bbTopbar.backgroundColor = [UIColor blackColor];
        
        self.galleryId = galleryId;
        
        pictures = [[NSMutableArray alloc] init];
        
        currentPage = 1;
        [self loadGallery];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGalleryAdd) name:NOTIFY_NEWGALLERYADD object:nil];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma ui event
- (void)back {
    [ctr popViewControllerAnimated:YES];
}

- (void)loadGallery {
    GalleryTask *task = [[GalleryTask alloc] initReGalleryList:self.galleryId
                                                          page:currentPage
                                                         count:PAGESIZE];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        if (currentPage == 1) {
            [pictures removeAllObjects];
            
            NSArray *pics = [Picture getPicturesForGallery:self.galleryId];
            [pictures addObjectsFromArray:pics];
        }
        
        if (succeeded) {
            NSArray *galleries = (NSArray *)userInfo;
            for (NSNumber *gId in galleries) {
                NSArray *gPictures = [Picture getPicturesForGallery:[gId longValue]];
                [pictures addObjectsFromArray:gPictures];
            }
            if ([((NSArray *)userInfo) count] < PAGESIZE) {
                galleryTable.hasMore = NO;
            } else {
                galleryTable.hasMore = YES;
            }
        }
 
        [galleryTable reloadData];
        [galleryTable stopLoading];
        
        //[self loadGalleryDetail];
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}


#pragma HorizonTableViewDelegate
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:CUR_PAGE_KEY]) {
        [UIView animateWithDuration:.1f animations:^{
            NSArray *pics = [Picture getPicturesForGallery:self.galleryId];
            if (galleryTable.currentPage <= pics.count) {
                source.textColor = [UIColor orangeColor];
                re.textColor = [UIColor whiteColor];
            } else {
                source.textColor = [UIColor whiteColor];
                re.textColor = [UIColor orangeColor];
            }
        }];
    }
}

- (int)rowWidthForHorizonTableView:(HorizonTableView *)tableView {
    return 320;
}

- (void)horizonTableView:(HorizonTableView *)tableView didSelectRowAtIndex:(NSInteger)index {
    [self back];
}

- (void)horizonTableView:(HorizonTableView *)tableView
    loadHeavyDataForCell:(UIView *)cell
                 atIndex:(NSInteger)index {
    
}


#pragma HorizonTableViewDatasource
- (NSInteger)numberOfRowsInHorizonTableView:(HorizonTableView *)tableView {
    return pictures.count;
}

- (UIView *)horizonTableView:(HorizonTableView *)tableView cellForRowAtIndex:(NSInteger)index {
    HorizonPictureCell *cell = [tableView dequeueReusableCell];
    if (!cell) {
        cell = [[[HorizonPictureCell alloc] initWithFrame:CGRectMake(0, 0, 320, galleryTable.frame.size.height)] autorelease];
    }
    Picture *p = [pictures objectAtIndex:index];
    cell.picturePath = p.imageBig;
    [cell updateLayout];
    return cell;
}


#pragma mark horizon table view delegate
- (void)horizonTableViewDidTriggerRefresh:(HorizonTableView *)pullTableView {
    currentPage = 1;
    [self loadGallery];
}

- (void)horizonTableViewDidTriggerLoadMore:(HorizonTableView *)pullTableView {
    currentPage ++;
    [self loadGallery];
}


#pragma UserInfoViewDelegate
- (void)showUserDetail:(long)userId {
    UserViewController *uCtr = [[UserViewController alloc] initWithUser:userId];
    [ctr pushViewController:uCtr animation:ViewSwitchAnimationBounce];
    [uCtr release];
}


#pragma mark notification
- (void)newGalleryAdd {
    [self loadGallery];
}


@end
