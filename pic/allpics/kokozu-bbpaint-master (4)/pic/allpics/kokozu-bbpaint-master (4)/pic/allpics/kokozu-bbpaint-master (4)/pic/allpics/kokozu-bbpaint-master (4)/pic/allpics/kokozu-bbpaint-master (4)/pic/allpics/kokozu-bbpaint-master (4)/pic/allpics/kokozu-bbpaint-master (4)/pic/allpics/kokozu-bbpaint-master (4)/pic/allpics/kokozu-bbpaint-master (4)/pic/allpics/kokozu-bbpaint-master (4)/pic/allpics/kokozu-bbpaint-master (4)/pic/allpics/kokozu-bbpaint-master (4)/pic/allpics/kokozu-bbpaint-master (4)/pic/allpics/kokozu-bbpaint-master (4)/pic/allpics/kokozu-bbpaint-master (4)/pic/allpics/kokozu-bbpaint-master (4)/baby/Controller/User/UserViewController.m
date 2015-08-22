//
//  UserViewController.m
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UserViewController.h"
#import "GalleryTask.h"
#import "NotificationTask.h"
#import "TaskQueue.h"
#import "ConfManager.h"
#import "Session.h"
//#import "ShareManager.h"
#import "Gallery.h"
#import "AudioPlayer.h"
#import "UserTask.h"
#import "Picture.h"
#import "User.h"
#import "UIButtonExtra.h"
#import "UIBlockSheet.h"
#import "GComment.h"
#import "EditViewController.h"
#import "GalleryDetailViewController.h"
#import "ImagePickerController.h"

#define TITLE 90900
#define DETAIL 89808
#define TIME 99999

#define PAGESIZE 12
#define COL_CNT 3

@interface UserViewController ()

@property (nonatomic, assign) long userId;
@property (nonatomic, assign) long playingCommentId;

@end


@implementation UserViewController

- (void)dealloc {
    [galleries release];
    [comments release];
    [contentType release];

    [super dealloc];
}

- (id)initWithUser:(long)userId {
    self = [super init];
    if (self) {
        _userId = userId;
        self.view.backgroundColor=[Shared bbRealWhite];
        galleryTable = [[PullTableView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 44)
                                                      style:UITableViewStylePlain];
        galleryTable.pullDelegate = self;
        galleryTable.delegate = self;
        galleryTable.dataSource = self;
        [galleryTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:galleryTable];
        galleryTable.pullBackgroundColor = [UIColor whiteColor];
        [galleryTable release];

        header = [[AccountView alloc] initWithFrame:CGRectMake(0, 0, 320, 220) forUser:userId];
        header.delegate = self;
        [galleryTable setTableHeaderView:header];
        [header updateLayout];
        [header release];
        
        if (self.userId == [ConfManager me].userId) {
            contentType = [[SimpleSegment alloc] initWithFrame:CGRectMake(5, 5, 310, 29)
                                                        titles:@[@"作品", @"收藏", @"消息"]
                                                   borderWidth:1];
            contentType.backgroundColor=[UIColor whiteColor];
            contentType.selectedTextColor = [UIColor whiteColor];
            contentType.selectedBackgoundColor = [UIColor colorWithRed:238/255.0 green:152/255.0 blue:0 alpha:1];
            contentType.normalTextColor = [UIColor blackColor];
            contentType.normalBackgroundColor = [UIColor whiteColor];
            contentType.borderColor = [UIColor orangeColor];
            contentType.delegate = self;
            contentType.layer.cornerRadius = 2;
            [contentType updateLayout];
            
            UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
            done.frame = CGRectMake(260, 9, 50, 30);
            [done setTitle:@"退出" forState:UIControlStateNormal];
            [done setTitleColor:[UIColor colorWithRed:236/225.0 green:151/225.0 blue:32/225.0 alpha:1.0] forState:UIControlStateNormal];
            [done addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
            [bbTopbar addSubview:done];
            
            [self setViewTitle:@"我"];
        } else {
            User *u = [User getUserWithId:userId];
            [self setViewTitle:(u.userNickname? u.userNickname: @"用户信息")];
        }
        
        UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [back setImage:[UIImage imageNamed:@"backWhiteBackground.png"] forState:UIControlStateNormal];
        [bbTopbar addSubview:back];
        
        galleries = [[NSMutableArray alloc] initWithCapacity:0];
        comments = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Custom initialization
    self.view.backgroundColor = [Shared bbWhite];
    currentPage = 1;
    [self loadContent];
    [self setViewTitle:@""];
    bbTopbar.backgroundColor = [Shared bbGray];
    bbTopbar.layer.shadowColor = [UIColor grayColor].CGColor;
    bbTopbar.layer.shadowOffset = CGSizeMake(0, 1);
    bbTopbar.layer.shadowOpacity = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma ui event
- (void)logout {
    
    UIBlockSheet *sheet = [[UIBlockSheet alloc] initWithTitle:@"确认退出登录？"];
    [sheet addButtonWithTitle:@"退出" block: ^{
        [[ConfManager me] setSession:nil];
        [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationFlipL];
    }];
    [sheet setCancelButtonWithTitle: @"取消" block: ^{}];
    [sheet showInView:self.view];
    [sheet release];

}

- (void)back {
    [ctr popViewControllerAnimated:YES];
}

- (void)editDetail {
    EditViewController *gVC = [[EditViewController alloc] init];
    [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
    [gVC release];
}

- (void)segmentSelected:(NSInteger)index {
    currentPage = 1;

    [self loadContent];
    [galleryTable reloadData];
}

- (void)loadContent {
//    if ([ConfigManager me].userId < 1) {
//        [UI showAlert:@"请先登录"];
//        [galleryTable stopLoading];
//        return;
//    }
    header.userId = self.userId;
    [header updateLayout];
    
    if (contentType.selectedIndex == 0) {
        //created galleries
        GalleryTask *task = [[GalleryTask alloc] initUserGalleryList:self.userId
                                                                page:currentPage
                                                               count:PAGESIZE];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (currentPage == 1) {
                [galleries removeAllObjects];
            }
            
            if (succeeded) {
                [galleries addObjectsFromArray:(NSArray *)userInfo];
                if ([((NSArray *)userInfo) count] < PAGESIZE) {
                    galleryTable.hasMore = NO;
                } else {
                    galleryTable.hasMore = YES;
                }
            }
            
            [galleryTable reloadData];
            [galleryTable stopLoading];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    } else if (contentType.selectedIndex == 1){
        //faved galleries
        GalleryTask *task = [[GalleryTask alloc] initLikeGalleryListAtPage:currentPage count:PAGESIZE];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (currentPage == 1) {
                [galleries removeAllObjects];
            }
            
            if (succeeded) {
                [galleries addObjectsFromArray:(NSArray *)userInfo];
                if ([((NSArray *)userInfo) count] < PAGESIZE) {
                    galleryTable.hasMore = NO;
                } else {
                    galleryTable.hasMore = YES;
                }
            }
            
            [galleryTable reloadData];
            [galleryTable stopLoading];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
        
    } else {
        //messages
        NotificationTask *task = [[NotificationTask alloc] initNotificationListAtPage:currentPage count:PAGESIZE];
        task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (currentPage == 1) {
                [comments removeAllObjects];
            }
            
            if (succeeded) {
                [comments addObjectsFromArray:(NSArray *)userInfo];
                if ([((NSArray *)userInfo) count] < PAGESIZE) {
                    galleryTable.hasMore = NO;
                } else {
                    galleryTable.hasMore = YES;
                }
            }
            
            [galleryTable reloadData];
            [galleryTable stopLoading];
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    }
}


#pragma table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (contentType.selectedIndex == 0 || contentType.selectedIndex == 1) {
        return galleries.count/COL_CNT + (galleries.count%COL_CNT>0? 1: 0);
    } else {
        return comments.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (contentType.selectedIndex == 0 || contentType.selectedIndex == 1) {
        //作品 收藏
        static NSString *cellId = @"gridgallerycell";
        GridGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[[GridGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:cellId
                                                    colCnt:COL_CNT] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.backgroundColor=[UIColor whiteColor];

        }
        for (int i = 0; i < COL_CNT; i++) {
            GridGalleryCell *gCell = (GridGalleryCell *)cell;
            gCell.row = indexPath.row;
            if (indexPath.row*COL_CNT + i < galleries.count) {
                NSLog(@"------%@", [galleries objectAtIndex:indexPath.row*COL_CNT + i]);
                long gId = [[galleries objectAtIndex:indexPath.row*COL_CNT + i] longValue];
                //Gallery *g = [Gallery getGalleryWithId:gId];
                [gCell setImagePath:[Picture coverForGallery:gId] atCol:i];
            } else {
                [gCell setImagePath:nil atCol:i];
            }
        }
        return cell;
    } else {
        //notification
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (contentType.selectedIndex == 0 || contentType.selectedIndex == 1) {
        return 320.0f/COL_CNT;
    } else {
        long cId = [[comments objectAtIndex:indexPath.row] longValue];
        return [CommentCell height:cId];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (contentType.selectedIndex == 2 && galleries.count > indexPath.row) {
        //message
        long cId = [[comments objectAtIndex:indexPath.row] longValue];
        GComment *g = [GComment getCommentWithId:cId];
        
        GalleryDetailViewController *gVC = [[GalleryDetailViewController alloc] initWithGalleryId:g.galleryId];
        [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
        [gVC release];
    } else {

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 31)];
    bg.backgroundColor = [UIColor whiteColor];
    [bg addSubview:contentType];
    return [bg autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.userId == [ConfManager me].userId) {
        return 39;
    }
    return 0;
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


#pragma comment cell delegate
- (void)playVoice:(CommentCell *)cell url:(NSString *)voicePath {
    [AudioPlayer stopPlay];
    
    if (self.playingCommentId != cell.commentId) {
        [Voice getVoice:voicePath
               callback:^(NSString *url, NSData *voice) {
                   if ([url isEqualToString:voicePath] && voice) {
                       [AudioPlayer startPlayData:voice finished:^{
                           self.playingCommentId = -1;
                           [galleryTable reloadData];
                       }];
                   } else {
                       self.playingCommentId = -1;
                       [galleryTable reloadData];
                   }
               }];
        self.playingCommentId = cell.commentId;
    } else {
        self.playingCommentId = -1;
    }
    
    [galleryTable reloadData];
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


#pragma mark grid gallery view cell
- (void)galleryTouchedAtRow:(NSInteger)row andCol:(NSInteger)col {
    if ((contentType.selectedIndex == 0 || contentType.selectedIndex == 1)
        && galleries.count > row*COL_CNT + col) {
        
        NSNumber *g = [galleries objectAtIndex:row*COL_CNT + col];
        
        GalleryDetailViewController *gVC = [[GalleryDetailViewController alloc] initWithGalleryId:[g longValue]];
        [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
        [gVC release];
    }
}


#pragma mark AccountViewDelegate
- (void)editUserHome {
    UIBlockSheet *sheet = [[UIBlockSheet alloc] initWithTitle:@"修改主页背景？"];
    [sheet addButtonWithTitle:@"修改" block: ^{
        ImagePickerController *imgPicker = [[ImagePickerController alloc] initWithCallback:^(UIImage *image) {
            [UI showIndicator];
            
            UserTask *task = [[UserTask alloc] initEditIntro:nil avatar:nil background:image];
            task.logicCallbackBlock = ^(bool successful, id userinfo) {
                [UI hideIndicator];
                if (successful) {
                    UserTask *task = [[UserTask alloc] initUserDetail:[ConfManager me].userId];
                    [TaskQueue addTaskToQueue:task];
                    [task release];
                    
                    [header setBgImage:image];
                }
            };
            [TaskQueue addTaskToQueue:task];
            [task release];
        } editable:YES];
        [ctr pushViewController:imgPicker animation:ViewSwitchAnimationSwipeR2L];
        [imgPicker release];
    }];
    [sheet setCancelButtonWithTitle: @"取消" block: ^{}];
    [sheet showInView:self.view];
    [sheet release];
}

- (void)editUserAvatar {
    UIBlockSheet *sheet = [[UIBlockSheet alloc] initWithTitle:@"修改用户头像？"];
    [sheet addButtonWithTitle:@"修改" block: ^{
        ImagePickerController *imgPicker = [[ImagePickerController alloc] initWithCallback:^(UIImage *image) {
            [UI showIndicator];
            
            UserTask *task = [[UserTask alloc] initEditIntro:nil avatar:image background:nil];
            task.logicCallbackBlock = ^(bool successful, id userinfo) {
                [UI hideIndicator];
                if (successful) {
                    UserTask *task = [[UserTask alloc] initUserDetail:[ConfManager me].userId];
                    [TaskQueue addTaskToQueue:task];
                    [task release];
                    
                    [header setAvatarImage:image];
                }
            };
            [TaskQueue addTaskToQueue:task];
            [task release];
        } editable:YES];
        [ctr pushViewController:imgPicker animation:ViewSwitchAnimationSwipeR2L];
        [imgPicker release];
    }];
    [sheet setCancelButtonWithTitle: @"取消" block: ^{}];
    [sheet showInView:self.view];
    [sheet release];
}

- (void)editUserDetail {
    EditViewController *eCtr = [[EditViewController alloc] init];
    [ctr pushViewController:eCtr animation:ViewSwitchAnimationBounce];
    [eCtr release];
}

@end
