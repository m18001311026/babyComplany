//
//  HomeViewController.m
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "HomeViewController.h"
#import "WelcomeViewController.h"
#import "GalleryPopViewController.h"
#import "CreateViewController.h"
#import "GalleryDetailViewController.h"
#import "NewGalleryViewController.h"
#import "UserViewController.h"
#import "SlideViewController.h"

#import "UIButtonExtra.h"
#import "ConfManager.h"
#import "TabbarController.h"
#import "ShareManager.h"

#import "GalleryTask.h"
#import "TaskQueue.h"

#import "Gallery.h"
#import "Picture.h"
#import "AudioPlayer.h"
#import "MemContainer.h"

#define PAGESIZE 5


@interface HomeViewController ()

@property (nonatomic, assign) long galleryId;

@end


@implementation HomeViewController

- (void)dealloc {
    [galleries release];
    [galleryType release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];

        galleryType = [[SimpleSegment alloc] initWithFrame:CGRectMake(100, 7, 120, 29)
                                                    titles:@[@"热门", @"经典"]
                                               borderWidth:1];
        galleryType.selectedBackgoundColor = [Shared bbOrange];
        galleryType.normalTextColor = [UIColor grayColor];
        galleryType.normalBackgroundColor = [UIColor whiteColor];
        galleryType.borderColor = [UIColor whiteColor];
        galleryType.delegate = self;
        galleryType.backgroundColor = [UIColor whiteColor];
        galleryType.layer.cornerRadius = 13;
        [galleryType updateLayout];
        [bbTopbar addSubview:galleryType];
    //    galleryType.backgroundColor=[UIColor colorWithRed:238/255.0 green:152/255.0 blue:0/255.0 alpha:1];
        

        galleryTable = [[PullTableView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 44)
                                                      style:UITableViewStylePlain];
        galleryTable.pullDelegate = self;
        galleryTable.delegate = self;
        galleryTable.dataSource = self;
        galleryTable.pullBackgroundColor = [UIColor clearColor];
      //  galleryTable.separatorStyle=1;
        [galleryTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:galleryTable];
        [galleryTable release];
        
        bbTopbar.backgroundColor = [Shared bbOrange];
    //    bbTopbar.layer.shadowColor = [UIColor grayColor].CGColor;
    //    bbTopbar.layer.shadowOffset = CGSizeMake(0, 1);
    //    bbTopbar.layer.shadowOpacity = 1;
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(135, screentContentHeight - 60, 50, 50);
        addBtn.layer.cornerRadius = 25;
        addBtn.layer.masksToBounds = YES;
        addBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        addBtn.layer.borderWidth = 3;
        [addBtn addTarget:self action:@selector(createGallery) forControlEvents:UIControlEventTouchUpInside];
        [addBtn setImage:[UIImage imageNamed:@"creatBtn.png"] forState:UIControlStateNormal];
        addBtn.alpha=0.9;
        [self.view addSubview:addBtn];
        
        galleries = [[NSMutableArray alloc] initWithCapacity:0];
        currentPage = 1;
        [self loadGallery];
        
        UIButton *me = [UIButton buttonWithType:UIButtonTypeCustom];
        me.frame = CGRectMake(10, 7, 30, 30);
        me.layer.cornerRadius = 15;
        me.layer.masksToBounds = YES;
        me.layer.borderColor = [UIColor orangeColor].CGColor;
        me.layer.borderWidth = 1;
        [me setImage:[UIImage imageNamed:@"my.png"] forState:UIControlStateNormal];
        [me setTitleColor:[UIColor colorWithRed:236/225.0 green:151/225.0 blue:32/225.0 alpha:1.0] forState:UIControlStateNormal];
        [me addTarget:self action:@selector(showAccount) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:me];
        
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

- (void)segmentSelected:(NSInteger)index {
    currentPage = 1;
    galleryTable.isRefreshing = YES;
    [self loadGallery];
}

- (void)loadGallery {
    GalleryTask *task = [[GalleryTask alloc] initGalleryList:galleryType.selectedIndex == 1
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
        
//        [self loadGalleryDetail];
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

- (void)createGallery {
    if (![ConfManager me].sessionId) {
        WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
        [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
        [welVC release];
        return;
    }
    
    NewGalleryViewController *cCtr = [[NewGalleryViewController alloc] initWithGallery:0];
    [ctr pushViewController:cCtr animation:ViewSwitchAnimationNone];
    [cCtr release];
    
    CreateViewController *createCtr = [[CreateViewController alloc] initWithDelegate:cCtr
                                                                     background:nil
                                                                          index:-1];
    [ctr pushViewController:createCtr animation:ViewSwitchAnimationBounce];
}


#pragma table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return galleries.count;
}

- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SimpleGalleryCell *gCell = (SimpleGalleryCell *)cell;
 //   NSLog(@"config: %d", indexPath.row);
    
    if (galleries.count > indexPath.row) {
        long galleryId = [[galleries objectAtIndex:indexPath.row] longValue];
        if (gCell.galleryId != galleryId) {
            gCell.galleryId = galleryId;
        }
        gCell.isPlaying = (galleryId == self.galleryId);
        [gCell updateLayout];
    }
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
    if (galleries.count > indexPath.row) {
        long galleryId = [[galleries objectAtIndex:indexPath.row] longValue];
        return [SimpleGalleryCell cellHeight:galleryId];
    }
    return 375;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger galleryId = [[galleries objectAtIndex:indexPath.row] longValue];
    
    GalleryPopViewController *gVC = [[GalleryPopViewController alloc] initWithGallery:galleryId];
    [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
    [gVC release];
}


#pragma mark pull table view delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    currentPage = 1;
    [self loadGallery];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    currentPage ++;
    [self loadGallery];
}


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


//#pragma VoiceViewDelegate
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


#pragma mark simple gallery cell delegate
- (void)deleteGallery:(long)galleryId {
    GalleryTask *task = [[GalleryTask alloc] initDeleteGallery:galleryId];
    task.logicCallbackBlock = ^(bool successful, id userInfo) {
        if (successful) {
            [galleries removeObject:@(galleryId)];
            [galleryTable reloadData];
            [UI showAlert:@"删除成功"];
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

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
    GalleryDetailViewController *gVC = [[GalleryDetailViewController alloc] initWithGalleryId:galleryId];
    [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
    [gVC release];
}

- (void)showAllRe:(long)galleryId {
    GalleryPopViewController *gVC = [[GalleryPopViewController alloc] initWithGallery:galleryId];
    [ctr pushViewController:gVC animation:ViewSwitchAnimationBounce];
    [gVC release];
}

@end
