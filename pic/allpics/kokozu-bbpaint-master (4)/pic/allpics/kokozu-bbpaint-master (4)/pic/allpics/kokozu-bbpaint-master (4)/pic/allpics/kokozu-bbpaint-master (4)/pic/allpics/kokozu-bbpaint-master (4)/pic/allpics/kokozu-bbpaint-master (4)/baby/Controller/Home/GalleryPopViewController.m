//
//  HomeViewController.m
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "WelcomeViewController.h"
#import "GalleryPopViewController.h"
#import "GalleryDetailViewController.h"
#import "UserViewController.h"
#import "UIButtonExtra.h"
#import "ConfManager.h"
#import "TabbarController.h"
//#import "ShareManager.h"

#import "CommentCell.h"
#import "ThumbCell.h"

#import "GalleryTask.h"
#import "PostTask.h"
#import "TaskQueue.h"

#import "Gallery.h"
#import "Picture.h"
#import "AudioPlayer.h"
#import "MemContainer.h"


#define PAGESIZE 5
#define COL_CNT 2

#define INDEX_LIKE -1
#define INDEX_COMMENT 0
#define INDEX_RE 1

#define EDITVIEW_HEIGHT 60


@interface GalleryPopViewController ()

@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) long playingCommentId;

@end


@implementation GalleryPopViewController

- (void)dealloc {
    [likes release];
    [comments release];
    [res release];

    [super dealloc];
}

- (id)initWithGallery:(long)galleryId {
    self = [super init];
    if (self) {
        // Custom initialization
        self.galleryId = galleryId;
        
        self.view.backgroundColor = [UIColor whiteColor];

        
        contentType = [[SimpleSegment alloc] initWithFrame:CGRectMake(70, 7, 180, 29)
                                                    titles:@[@"评论", @"转发"] //@"赞",
                                               borderWidth:1];
        contentType.selectedTextColor = [UIColor blackColor];
        contentType.selectedBackgoundColor = [UIColor colorWithWhite:0.8 alpha:1];
        contentType.normalTextColor = [UIColor grayColor];
        contentType.normalBackgroundColor = [UIColor whiteColor];
        contentType.borderColor = [UIColor lightGrayColor];
        contentType.delegate = self;
        contentType.backgroundColor = [UIColor lightGrayColor];
        contentType.layer.cornerRadius = 13;
        [contentType updateLayout];
        [bbTopbar addSubview:contentType];
        [contentType release];
        
        holderTable = [[PullTableView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 44 -EDITVIEW_HEIGHT)
                                                      style:UITableViewStylePlain];
        holderTable.pullDelegate = self;
        holderTable.delegate = self;
        holderTable.dataSource = self;
        holderTable.pullBackgroundColor = [UIColor clearColor];
        [holderTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:holderTable];
        [holderTable release];
        
        bbTopbar.backgroundColor = [UIColor whiteColor];
        bbTopbar.layer.shadowColor = [UIColor grayColor].CGColor;
        bbTopbar.layer.shadowOffset = CGSizeMake(0, 1);
        bbTopbar.layer.shadowOpacity = 1;
        
        editView = [[EditView alloc] initWithFrame:CGRectMake(0, screentContentHeight - EDITVIEW_HEIGHT, 320, EDITVIEW_HEIGHT)];
        editView.delegate = self;
        editView.editMode = TextMode;
        editView.layer.shadowColor = [UIColor grayColor].CGColor;
        editView.layer.shadowOffset = CGSizeMake(0, -1);
        editView.layer.shadowOpacity = 1;
        [self.view addSubview:editView];
        [editView release];
        
        UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:back];
        
        likes = [[NSMutableArray alloc] initWithCapacity:0];
        comments = [[NSMutableArray alloc] initWithCapacity:0];
        res = [[NSMutableArray alloc] initWithCapacity:0];

        currentPage = 1;
        [self loadContent];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma ui event
- (void)segmentSelected:(NSInteger)index {
    editView.hidden = (index != INDEX_COMMENT);
    holderTable.frame = CGRectMake(0,
                                   44,
                                   320,
                                   screentContentHeight - 44 - (index==INDEX_COMMENT? EDITVIEW_HEIGHT: 0));
    currentPage = 1;
    holderTable.isRefreshing = YES;
    [holderTable showPlaceHolder:@"加载中"];
    [self loadContent];
}

- (void)back {
    [ctr popViewControllerAnimated:YES];
}

- (void)loadContent {
    
    if (contentType.selectedIndex == INDEX_LIKE ) {
        //likes
        GalleryTask *task = [[GalleryTask alloc] initGalleryList:YES
                                                            page:currentPage
                                                           count:PAGESIZE];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (currentPage == 1) {
                [likes removeAllObjects];
            }
            
            if (succeeded) {
                [likes addObjectsFromArray:(NSArray *)userInfo];
                if ([((NSArray *)userInfo) count] < PAGESIZE) {
                    holderTable.hasMore = NO;
                } else {
                    holderTable.hasMore = YES;
                }
            }
            
            if (contentType.selectedIndex == INDEX_LIKE ) {
                [holderTable reloadData];
            }
            [holderTable stopLoading];

            //[self loadGalleryDetail];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    } else if (contentType.selectedIndex == INDEX_COMMENT) {
        //comments
        GalleryTask *task = [[GalleryTask alloc] initGCommentList:self.galleryId
                                                             page:currentPage
                                                            count:PAGESIZE];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (currentPage == 1) {
                [comments removeAllObjects];
            }
            
            if (succeeded) {
                [comments addObjectsFromArray:(NSArray *)userInfo];
                if ([((NSArray *)userInfo) count] < PAGESIZE) {
                    holderTable.hasMore = NO;
                } else {
                    holderTable.hasMore = YES;
                }
            }
            
            if (contentType.selectedIndex == INDEX_COMMENT ) {
                [holderTable showPlaceHolder:comments.count? nil: @"暂时没有评论"];
                [holderTable reloadData];
            }
            [holderTable stopLoading];

            //[self loadGalleryDetail];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    } else if (contentType.selectedIndex == INDEX_RE ){
        //res
        GalleryTask *task = [[GalleryTask alloc] initReGalleryList:self.galleryId
                                                              page:currentPage
                                                             count:PAGESIZE];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (currentPage == 1) {
                [res removeAllObjects];
            }
            
            if (succeeded) {
                [res addObjectsFromArray:(NSArray *)userInfo];
                if ([((NSArray *)userInfo) count] < PAGESIZE) {
                    holderTable.hasMore = NO;
                } else {
                    holderTable.hasMore = YES;
                }
            }
            
            if (contentType.selectedIndex == INDEX_RE ) {
                [holderTable showPlaceHolder:res.count? nil: @"暂时没有转发"];
                [holderTable reloadData];
            }
            [holderTable stopLoading];
            
            //[self loadGalleryDetail];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    }

}


#pragma table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (contentType.selectedIndex == INDEX_LIKE ) {
        //likes
        return likes.count;
    } else if (contentType.selectedIndex == INDEX_COMMENT ) {
        //comments
        return comments.count;
    } else if (contentType.selectedIndex == INDEX_RE ) {
        //res
        return res.count/COL_CNT + (res.count%COL_CNT>0? 1: 0);
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (contentType.selectedIndex == INDEX_LIKE ) {
        //likes
        static NSString *cellId = @"likecell";
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[[UserCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:cellId] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        cell.userId = 0;
        [cell updateLayout];
        return cell;
    } else if (contentType.selectedIndex == INDEX_COMMENT ) {
        //comments
        static NSString *cellId = @"commentcell";
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellId] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        long cId = [[comments objectAtIndex:indexPath.row] longValue];
        cell.commentId = cId;
        if (cell.commentId == self.playingCommentId) {
            cell.loadingVoice = YES;
        } else {
            cell.loadingVoice = NO;
        }
        [cell updateLayout];
        return cell;
    } else if (contentType.selectedIndex == INDEX_RE ){
        //res
        static NSString *cellId = @"recell";
        ThumbCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[[ThumbCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellId
                                              colCnt:COL_CNT] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        
        for (int i = 0; i < COL_CNT; i++) {
            cell.row = indexPath.row;
            if (indexPath.row*COL_CNT + i < res.count) {
                long gId = [[res objectAtIndex:indexPath.row*COL_CNT + i] longValue];
                //Gallery *g = [Gallery getGalleryWithId:gId];
                [cell setImagePath:[Picture coverForGallery:gId] atCol:i];
            } else {
                [cell setImagePath:nil atCol:i];
            }
        }
        return cell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (contentType.selectedIndex == INDEX_LIKE ) {
        //likes
        return 74;
    } else if (contentType.selectedIndex == INDEX_COMMENT ) {
        //comments
        long cId = [[comments objectAtIndex:indexPath.row] longValue];
        return [CommentCell height:cId];
    } else if (contentType.selectedIndex == INDEX_RE ){
        //res
        return 320.0f/COL_CNT;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)loadGalleryDetail {

}


#pragma mark pull table view delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    currentPage = 1;
    [self loadContent];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    currentPage ++;
    [self loadContent];
}


#pragma mark editview delegate
- (void)newVoice:(NSData *)mp3 length:(int)length {
    if (![ConfManager me].sessionId) {
        WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
        [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
        [welVC release];
        return;
    }
    
    if (length >= 1) {
        PostTask *task = [[PostTask alloc] initNewGCommentForGallery:self.galleryId
                                                             replyTo:nil
                                                               voice:mp3
                                                              length:length
                                                             content:nil];
        [UI showIndicator];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                [self loadContent];
            }
            [UI hideIndicator];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    } else {
        [UI showAlert:@"评论时长不足1s"];
    }
}

- (void)newText:(NSString *)text {
    if (![ConfManager me].sessionId) {
        WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
        [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
        [welVC release];
        return;
    }
    
    if (text.length) {
        PostTask *task = [[PostTask alloc] initNewGCommentForGallery:self.galleryId
                                                             replyTo:nil
                                                               voice:nil
                                                              length:0
                                                             content:text];
        [UI showIndicator];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                [self loadContent];
                [editView resetText];
            }
            [UI hideIndicator];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    }
}


#pragma UserInfoViewDelegate
- (void)showUserDetail:(long)userId {

    UserViewController *uCtr = [[UserViewController alloc] initWithUser:userId];
    [ctr pushViewController:uCtr animation:ViewSwitchAnimationBounce];
    [uCtr release];
    
}


#pragma CommentViewDelegate
- (void)startPlayVoice {
    Gallery *g = [Gallery getGalleryWithId:self.galleryId];
    if (g.introVoice) {
        [Voice getVoice:g.introVoice
               callback:^(NSString *url, NSData *voice) {
                   if ([url isEqualToString:g.introVoice] && voice) {
                       [AudioPlayer startPlayData:voice finished:^{
                           self.galleryId = 0;
                           [holderTable reloadData];
                       }];
                   } else {
                       [holderTable reloadData];
                   }
               }];
    }
}

- (void)stopPlayVoice {
    [AudioPlayer stopPlay];
}

- (void)playVoiceForGallery:(long)galleryId {
//    
//    [self stopPlayVoice];
//    self.galleryId = galleryId;
//    if (self.galleryId) {
//        [self startPlayVoice];
//    }
//    
//    [galleryTable reloadData];
}


#pragma comment cell delegate
- (void)playVoice:(CommentCell *)cell url:(NSString *)voicePath {
    [AudioPlayer stopPlay];
        
    if (self.playingCommentId != cell.commentId) {
        [Voice getVoice:voicePath
               callback:^(NSString *url, NSData *voice) {
                   if ([url isEqualToString:voicePath] && voice) {
                       [AudioPlayer startPlayData:voice finished:^{
                           self.playingCommentId = -1;
                           [holderTable reloadData];
                       }];
                   } else {
                       self.playingCommentId = -1;
                       [holderTable reloadData];
                   }
               }];
        self.playingCommentId = cell.commentId;
    } else {
        self.playingCommentId = -1;
    }
    
    [holderTable reloadData];

}

- (void)deleteComment:(long)commentId {
    GalleryTask *task = [[GalleryTask alloc] initDeleteComment:commentId];
    [UI showIndicator];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        if (succeeded) {
            [self loadContent];
        }
        [UI hideIndicator];
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}


#pragma ThumbCellDelegate
- (void)galleryTouchedAtRow:(NSInteger)row andCol:(NSInteger)col {
    NSInteger index = row*COL_CNT + col;
    if (index < res.count) {
        long galleryId = [[res objectAtIndex:index] longValue];
        
        GalleryDetailViewController *gVC = [[GalleryDetailViewController alloc] initWithGalleryId:galleryId];
        [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
        [gVC release];
    }

}


@end
