//
//  HomeViewController.m
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "GalleryDetailViewController.h"
#import "WelcomeViewController.h"
#import "GalleryPopViewController.h"
#import "NewGalleryViewController.h"
#import "UserViewController.h"
#import "SlideViewController.h"

#import "UIButtonExtra.h"
#import "ConfManager.h"
#import "TabbarController.h"

#import "GalleryTask.h"
#import "TaskQueue.h"

#import "User.h"
#import "Gallery.h"
#import "Picture.h"
#import "AudioPlayer.h"
#import "MemContainer.h"
#import "UIBlockSheet.h"
#import "ShareManager.h"

#define PAGESIZE 5


@interface GalleryDetailViewController ()

@property (nonatomic, assign) long galleryId;

@end


@implementation GalleryDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (id)initWithGalleryId:(long)galleryId {
    self = [super init];
    if (self) {
        // Custom initialization
        _galleryId = galleryId;
        
        self.view.backgroundColor = [UIColor whiteColor];

        galleryTable = [[PullTableView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 44)
                                                      style:UITableViewStylePlain];
        galleryTable.pullDelegate = self;
        galleryTable.delegate = self;
        galleryTable.dataSource = self;
        galleryTable.hasMore = NO;
        galleryTable.pullBackgroundColor = [UIColor clearColor];
        [galleryTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:galleryTable];
        [galleryTable release];
        
        //[self setViewTitle:@"宝贝计画"];
        bbTopbar.backgroundColor = [Shared bbGray];
        bbTopbar.layer.shadowColor = [UIColor grayColor].CGColor;
        bbTopbar.layer.shadowOffset = CGSizeMake(0, 1);
        bbTopbar.layer.shadowOpacity = 1;
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(260, 9, 50, 30);
        deleteBtn.hidden = YES;
        [deleteBtn setTitle:@"删 除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor colorWithRed:236/225.0 green:151/225.0 blue:32/225.0 alpha:1.0] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteGallery) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:deleteBtn];
        
        [self loadGallery];
        
        UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:back];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGalleryAdd) name:NOTIFY_NEWGALLERYADD object:nil];

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
- (void)back {
    [ctr popViewControllerAnimated:YES];
}

- (void)deleteGallery {
    UIBlockSheet *sheet = [[UIBlockSheet alloc] initWithTitle:@"删除作品？"];
    [sheet addButtonWithTitle:@"删除" block: ^{
        [UI showIndicator];
            
        GalleryTask *task = [[GalleryTask alloc] initDeleteGallery:self.galleryId];
        task.logicCallbackBlock = ^(bool successful, id userinfo) {
            [UI hideIndicator];
            if (successful) {
                [self back];
            }
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
        
    }];
    [sheet setCancelButtonWithTitle: @"取消" block: ^{}];
    [sheet showInView:self.view];
    [sheet release];
}

- (void)showAccount {
    if ([ConfManager me].userId) {
        UserViewController *uCtr = [[UserViewController alloc] initWithUser:[ConfManager me].userId];
        [ctr pushViewController:uCtr animation:ViewSwitchAnimationBounce];
        [uCtr release];
    } else {
        WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
        [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
        [welVC release];
    }
}

- (void)loadGallery {
    GalleryTask *task = [[GalleryTask alloc] initGalleryDetail:self.galleryId];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        Gallery *g = [Gallery getGalleryWithId:self.galleryId];
        User *u = [User getUserWithId:g.userId];
        deleteBtn.hidden = ([ConfManager me].userId != u._id);
        
        [galleryTable reloadData];
        [galleryTable stopLoading];
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}


#pragma table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SimpleGalleryCell *gCell = (SimpleGalleryCell *)cell;
    NSLog(@"config: %ld", (long)indexPath.row);
    gCell.galleryId = self.galleryId;
    //gCell.isPlaying = (galleryId == self.galleryId);
    [gCell updateLayout];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"gallerycell";
    SimpleGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[SimpleGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellId] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.funcDelegate = self;
        cell.delegate = self;
    }
    [self configCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SimpleGalleryCell cellHeight:self.galleryId];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GalleryPopViewController *gVC = [[GalleryPopViewController alloc] initWithGallery:self.galleryId];
    [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
    [gVC release];
}


#pragma mark pull table view delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    [self loadGallery];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {}


#pragma UserInfoViewDelegate
- (void)showUserDetail:(long)userId {

    UserViewController *uCtr = [[UserViewController alloc] initWithUser:userId];
    [ctr pushViewController:uCtr animation:ViewSwitchAnimationBounce];
    [uCtr release];
    
}


#pragma CommentViewDelegate
- (bool)commentView:(CommentView*)view shouldStartPlay:(long)commentId {
    return YES;
}

- (void)startPlayVoice {
    Gallery *g = [Gallery getGalleryWithId:self.galleryId];
    if (g.introVoice) {
        [Voice getVoice:g.introVoice
               callback:^(NSString *url, NSData *voice) {
                   if ([url isEqualToString:g.introVoice] && voice) {
                       [AudioPlayer startPlayData:voice finished:^{
                           self.galleryId = 0;
                           [galleryTable reloadData];
                       }];
                   } else {
                       [galleryTable reloadData];
                   }
               }];
    }

}

- (void)stopPlayVoice {
    [AudioPlayer stopPlay];
}


#pragma mark simple gallery cell delegate
- (void)reGallery:(long)galleryId {
    if (![ConfManager me].sessionId) {
        WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
        [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
        [welVC release];
        return;
    }
    
    NewGalleryViewController *cCtr = [[NewGalleryViewController alloc] initWithGallery:galleryId];
    [ctr pushViewController:cCtr animation:ViewSwitchAnimationBounce];
    [cCtr release];
}

- (void)tappedAtImage:(long)galleryId {
    SlideViewController *s = [[SlideViewController alloc] initWithGallery:galleryId];
    [ctr pushViewController:s animation:ViewSwitchAnimationBounce];
    [s release];
}

- (void)shareGallery:(long)galleryId {
    Gallery *g = [Gallery getGalleryWithId:galleryId];
    if (g) {
        [IMG getImage:[Picture coverForGallery:galleryId]
             callback:^(NSString *url, UIImage *image) {
                 [[ShareManager me] showShareMenuWithTitle:@"变变变分享"
                                                   content:[NSString stringWithFormat:
                                                            @"有趣的作品分享 http://115.28.136.139:8090/CreationApp/share/find.do?productionId=%ld&pageNow=1", galleryId]
                                                     image:image
                                                   pageUrl:[NSString stringWithFormat:
                                                            @"http://115.28.136.139:8090/CreationApp/share/find.do?productionId=%ld&pageNow=1", galleryId]
                                                  soundUrl:nil];
             }];
    }
}


#pragma mark notification
- (void)newGalleryAdd {
    [self loadGallery];
}


#pragma mark review delegate
- (void)showRe:(long)galleryId {
    if (galleryId != self.galleryId) {
        GalleryDetailViewController *gVC = [[GalleryDetailViewController alloc] initWithGalleryId:galleryId];
        [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
        [gVC release];
    }
}

- (void)showAllRe:(long)galleryId {
    GalleryPopViewController *gVC = [[GalleryPopViewController alloc] initWithGallery:galleryId];
    [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
    [gVC release];
}


@end
