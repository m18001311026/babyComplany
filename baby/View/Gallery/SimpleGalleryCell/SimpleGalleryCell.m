//
//  GalleryCell.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "SimpleGalleryCell.h"
#import "ImageView.h"
#import "UIImageButton.h"
#import "User.h"
#import "Gallery.h"
#import "Picture.h"
#import "GComment.h"
#import "ConfManager.h"
#import "Session.h"
#import "GalleryTask.h"
#import "TaskQueue.h"
#import "ImageDetailView.h"
#import "WelcomeViewController.h"


#define SCROLL_VIEW_HEIGHT 400
#define FUNC_BTN_HEIGHT 40
#define RE_VIEW_HEIGHT 50
#define LIKE_VIEW_HEIGHT 30

@interface SimpleGalleryCell()

@property (nonatomic, retain) Gallery *gallery;

@end



@implementation SimpleGalleryCell

- (void)dealloc {
    self.gallery = nil;
    self.funcDelegate = nil;
    self.delegate = nil;
    
    [pictureViews release];
    pictureViews = nil;
    
    [pictures release];
    pictures = nil;
    
    [commentView release];

    [super dealloc];
}

- (void)setGalleryId:(long)galleryId {
    if (_galleryId != galleryId) {
        _galleryId = galleryId;
        self.gallery = nil;
    }
    //voice.galleryId = galleryId;
}

- (void)setFuncDelegate:(id<UserInfoViewDelegate, CommentViewDelegate, ReViewDelegate>)funcDelegate {
    if (_funcDelegate != funcDelegate) {
        _funcDelegate = funcDelegate;
        
        user.delegate = self.funcDelegate;
        reView.delegate = self.funcDelegate;
        //commentView.
    }
}

- (void)setIsPlaying:(bool)isPlaying {
    if (_isPlaying != isPlaying) {
        _isPlaying = isPlaying;
        
        //voice.isPlaying = _isPlaying;
    }
}

- (Gallery *)gallery {
    //NSLog(@"call getter: %@, %d", _gallery, self.galleryId);
    if (!_gallery && self.galleryId > 0) {
        self.gallery = [Gallery getGalleryWithId:self.galleryId];
    }
    return _gallery;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.masksToBounds = YES;
    
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SCROLL_VIEW_HEIGHT + 40)];
        [self addSubview:bg];
        [bg release];
 
        galleryHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, 320, SCROLL_VIEW_HEIGHT - 6)];
        galleryHolder.pagingEnabled = YES;
        galleryHolder.alwaysBounceHorizontal = YES;
        galleryHolder.delegate = self;
        galleryHolder.showsHorizontalScrollIndicator = NO;
        galleryHolder.contentSize = CGSizeMake(320, SCROLL_VIEW_HEIGHT - 6);
        [self addSubview:galleryHolder];
        [galleryHolder release];
        
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 5)];
   //     line.backgroundColor = [UIColor colorWithRed:169/255.0 green:169/255.0 blue:169/255.0 alpha:169/255.0];
        
        line.backgroundColor=[Shared bbOrange];
        [self addSubview:line];
        [line release];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(scrollViewTapped:)];
        [galleryHolder addGestureRecognizer:tap];
        [tap release];
        
        paging = [[UIPageControl alloc] initWithFrame:CGRectMake(0, SCROLL_VIEW_HEIGHT - 20, 320, 20)];
        paging.hidesForSinglePage = YES;
        if ([paging respondsToSelector:@selector(setPageIndicatorTintColor:)]) {
            [paging setPageIndicatorTintColor:[UIColor lightGrayColor]];
            [paging setCurrentPageIndicatorTintColor:[UIColor orangeColor]];
        }
        paging.userInteractionEnabled = NO;
        [self addSubview:paging];
        [paging release];
        
        pictureViews = [[NSMutableArray alloc] init];
        pictures = [[NSMutableArray alloc] init];
        
        user = [[UserInfoView alloc] initWithFrame:CGRectMake(0, 10, 160, 65)];
        user.backgroundColor = [UIColor clearColor];
        [self addSubview:user];
        [user release];
        
        /*
         *func btn zone
         */
        //转发评论
        reBtn = [[UIImageButton alloc] initWithFrame:CGRectMake(4, SCROLL_VIEW_HEIGHT, 60, FUNC_BTN_HEIGHT)
                                               image:@"transPic.png"
                                         imageHeight:50
                                                text:@""
                                            fontSize:12];
        reBtn.textNormalColor = [UIColor grayColor];
        reBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        reBtn.layer.borderWidth = 1.0f;
        reBtn.layer.masksToBounds = NO;
        [reBtn addTarget:self action:@selector(reGallery) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:reBtn];
        [reBtn release];
        
        //赞
        likeBtn = [[UIImageButton alloc] initWithFrame:CGRectMake(67, SCROLL_VIEW_HEIGHT, 60, FUNC_BTN_HEIGHT)
                                                 image:@"like1.png"
                                           imageHeight:50
                                                  text:@""
                                              fontSize:12];
        likeBtn.textNormalColor = [UIColor grayColor];
        [likeBtn addTarget:self action:@selector(likeGallery) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:likeBtn];
        [likeBtn release];
        
        //收藏按钮
        favBtn = [[UIImageButton alloc] initWithFrame:CGRectMake(130, SCROLL_VIEW_HEIGHT, 60, FUNC_BTN_HEIGHT)
                                                image:@"collection.png"
                                          imageHeight:50
                                                 text:@""
                                             fontSize:12];
        favBtn.textNormalColor = [UIColor grayColor];
        [favBtn addTarget:self action:@selector(favGallery) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:favBtn];
        [favBtn release];
        
        //分享按钮
        shareBtn=[[UIImageButton alloc]initWithFrame:CGRectMake(193, SCROLL_VIEW_HEIGHT, 60, FUNC_BTN_HEIGHT)
                                               image:@"share.png"
                                         imageHeight:50
                                                text:@""
                                            fontSize:12];
        [shareBtn addTarget:self action:@selector(shareGallery) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareBtn];
        [shareBtn release];
        
        //评论
        commentBtn = [[UIImageButton alloc] initWithFrame:CGRectMake(256, SCROLL_VIEW_HEIGHT, 61, FUNC_BTN_HEIGHT)
                                                 image:@"comment.png"
                                           imageHeight:50
                                                  text:@""
                                              fontSize:12];
        commentBtn.userInteractionEnabled = NO;
        [self addSubview:commentBtn];
        [commentBtn release];
        
        reView = [[ReView alloc] initWithFrame:CGRectMake(10, SCROLL_VIEW_HEIGHT + FUNC_BTN_HEIGHT, 300, RE_VIEW_HEIGHT)];
        [self addSubview:reView];
        [reView release];
        
        UIImageView *likeIcon = [[UIImageView alloc] initWithFrame:
                    CGRectMake(10, SCROLL_VIEW_HEIGHT + FUNC_BTN_HEIGHT + RE_VIEW_HEIGHT + 3, 16, 20)];
        likeIcon.image=[UIImage imageNamed:@"like2.png"];
        likeIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:likeIcon];
        [likeIcon release];
        
        likeDetailLabel = [[UITextField alloc] initWithFrame:
                           CGRectMake(35, SCROLL_VIEW_HEIGHT + FUNC_BTN_HEIGHT + RE_VIEW_HEIGHT, 200, LIKE_VIEW_HEIGHT)];
        likeDetailLabel.textColor = [UIColor darkGrayColor];
        likeDetailLabel.backgroundColor = [UIColor clearColor];
        likeDetailLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        likeDetailLabel.text = @"赞";
        likeDetailLabel.userInteractionEnabled = NO;
        likeDetailLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:likeDetailLabel];
        [likeDetailLabel release];
        
        commentView = [[CommentView alloc] initWithFrame:
                       CGRectMake(10,
                                  SCROLL_VIEW_HEIGHT + FUNC_BTN_HEIGHT + RE_VIEW_HEIGHT + LIKE_VIEW_HEIGHT,
                                  300,
                                  40)];
        [self addSubview:commentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    [[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1] set];
    
    
    
    CGContextSetLineWidth(context, 2);
    
    CGContextMoveToPoint(context, 0, SCROLL_VIEW_HEIGHT - 1);
    CGContextAddLineToPoint(context, 320, SCROLL_VIEW_HEIGHT -1);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
//
//    CGContextMoveToPoint(context, 0, rect.size.height - 1);
//    CGContextAddLineToPoint(context, 320, rect.size.height - 1);
//    CGContextClosePath(context);
//    CGContextDrawPath(context, kCGPathFillStroke);
}

- (ImageView *)viewForReuse {
    ImageView *view = nil;
    for (ImageView *v in pictureViews) {
        if (![v superview]) {
            view = v;
            break;
        }
    }
    
    if (!view) {
        view = [[ImageView alloc] initWithFrame:CGRectMake(0, 0, 320, SCROLL_VIEW_HEIGHT)];
        view.clipsToBounds = YES;
        view.userInteractionEnabled = YES;
        //view.layer.borderColor=[UIColor blackColor].CGColor;
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.imagePath = nil;
        [pictureViews addObject:view];
        [view release];
    }
    return view;
}

- (void)updateScrollView {
    for (ImageView *v in pictureViews) {
        [v removeFromSuperview];
    }

    [pictures removeAllObjects];
    NSArray *gPictures = [Picture getPicturesForGallery:self.galleryId];
    [pictures addObjectsFromArray:gPictures];
    
    paging.numberOfPages = gPictures.count;

    for (int i = 0 ; i < pictures.count; i ++ ) {
        ImageView *view = [self viewForReuse];
        view.frame = CGRectMake(320*i, 0, 320, SCROLL_VIEW_HEIGHT - 6);
        [galleryHolder addSubview:view];
        
        Picture *pic = [pictures objectAtIndex:i];
        view.imagePath = pic? pic.imageBig: nil;
    }
    
    galleryHolder.scrollEnabled = (pictures.count != 1);
    galleryHolder.contentSize = CGSizeMake(320*pictures.count, SCROLL_VIEW_HEIGHT -6);
//    if (self.currentIndex < pictures.count) {
//        galleryHolder.contentOffset = CGPointMake(320*self.currentIndex, 0);        
//    }
}

- (void)likeGallery {
    if ([[ConfManager me] getSession]) {

        CallbackBlock likeBlock = ^(bool succeeded, id userInfo) {
            if (succeeded && self.gallery.liked) {
                GalleryTask * lkTask = [[GalleryTask alloc] initLikeGallery:self.galleryId
                                                                  relation:![self.gallery.liked boolValue]];
                lkTask.logicCallbackBlock = ^(bool succeeded, id userInfo) {
                    if (succeeded) {
                        likeDetailLabel.text = [NSString stringWithFormat:@"%ld 个赞", self.gallery.likeCnt];
                        [likeBtn setImage:[UIImage imageNamed:@"likeSelected.png"]];
                    } else {
                        
                    }
                };
                [TaskQueue addTaskToQueue:lkTask];
                [lkTask release];
            }
        };
        
        if (!self.gallery.liked) {
            GalleryTask *task = [[GalleryTask alloc] initGalleryDetail:self.galleryId];
            task.logicCallbackBlock = likeBlock;
            [TaskQueue addTaskToQueue:task];
            [task release];
        } else {
            if ([self.gallery.liked boolValue]) {
                [UI showAlert:@"已经赞过啦！"];
            } else {
                likeBlock(YES, nil);
            }
        }
    } else {
        WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
        [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
        [welVC release];
    }
}

- (void)reGallery {
    if (self.delegate && self.galleryId) {
        [self.delegate reGallery:self.galleryId];
    }
}

- (void)favGallery {
    if ([[ConfManager me] getSession]) {
        GalleryTask * lkTask = [[GalleryTask alloc] initFavGallery:self.galleryId
                                                          relation:!self.gallery.faved];
        lkTask.logicCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                [UI showAlert:self.gallery.faved? @"收藏成功": @"取消收藏"];
                [self updateLayout];
            }
        };
        [TaskQueue addTaskToQueue:lkTask];
        [lkTask release];
    } else {
        WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
        [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
        [welVC release];
    }
}

- (void)shareGallery {
    if (self.delegate
        && self.galleryId
        && [self.delegate respondsToSelector:@selector(shareGallery:)]) {
        [self.delegate shareGallery:self.galleryId];
    }
}

- (void)updateLayout {
    user.galleryId = self.galleryId;
    [user updateLayout];
    likeDetailLabel.text = [NSString stringWithFormat:@"%ld 个赞", self.gallery.likeCnt] ;
    
    if (self.gallery.faved) {
        [favBtn setImage:[UIImage imageNamed:@"collectionSelected.png"]];
    } else {
        [favBtn setImage:[UIImage imageNamed:@"collection.png"]];
    }
    if (self.gallery.liked && [self.gallery.liked boolValue]) {
        [likeBtn setImage:[UIImage imageNamed:@"likeSelected.png"]];
    } else {
        [likeBtn setImage:[UIImage imageNamed:@"like1.png"]];
    }
    
    NSArray *comments = [GComment getCommentsForGallery:self.galleryId];;
    if (comments.count) {
        commentView.galleryId = self.galleryId;
        [self addSubview:commentView];
    } else {
        [commentView removeFromSuperview];
    }
    reView.galleryId = self.galleryId;
    [self updateScrollView];
}

+ (float)cellHeight:(long)galleryId {
    NSArray *comments = [GComment getCommentsForGallery:galleryId];;
    float commentViewHeight = 0;
    if (comments.count) {
        NSMutableArray *commentIds = [[NSMutableArray alloc] init];
        for (GComment *comment in comments) {
            [commentIds addObject:@(comment._id)];
        }
        commentViewHeight = [CommentView viewHeight:commentIds];
        [commentIds release];
    }

    return SCROLL_VIEW_HEIGHT + FUNC_BTN_HEIGHT + RE_VIEW_HEIGHT + LIKE_VIEW_HEIGHT + commentViewHeight + 6;
}

- (void)scrollViewTapped:(UITapGestureRecognizer *)tap {
    NSLog(@"tapped");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tappedAtImage:)]) {
        [self.delegate tappedAtImage:self.galleryId];
    } else {
        ImageDetailView *detail = [[ImageDetailView alloc] initWithFrame:delegate.window.bounds];
        for (UIView *view in [galleryHolder subviews]) {
            if ([view isKindOfClass:[ImageView class]]) {
                int page = (int)((view.frame.origin.x / galleryHolder.bounds.size.width));
                if (page == paging.currentPage) {
                    Picture *pic = [pictures objectAtIndex:page];
                    [detail setImagePath:pic.imageBig];
                }
            }
        }
        
        [delegate.window addSubview:detail];
        [detail release];
    }
}


#pragma uiscorllview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.width > 320) {
        int newpage = (int)((galleryHolder.contentOffset.x / galleryHolder.bounds.size.width));
        if (paging.currentPage != newpage) {
            paging.currentPage = newpage;
        }
    }
}


@end
