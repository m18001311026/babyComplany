//
//  PhotoDetailViewController.m
//  phonebook
//
//  Created by da zhang on 11-3-15.
//  Copyright 2011 wozai llc. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "Constants.h"

#define kAutoHideInterval 3.0
#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@interface PhotoDetailViewController ()
- (void)centerImage;
- (void)refreshScrollView:(UIImage *)theImg;
@end



@implementation PhotoDetailViewController

@synthesize imageScrollView;
@synthesize imageURL;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {    
	[imageURL release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomStyle:CustomBarButtonItemStyleCancel
//                                                                  target:self 
//                                                                  action:@selector(cancelView)];
//    self.navigationItem.leftBarButtonItem = item;
//    [item release];
//	
//	UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" 
//                                                                 target:self
//                                                                 action:@selector(savePicture)];
//	self.navigationItem.rightBarButtonItem = saveItem;
//	[saveItem release];
	
	imageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
	[imageScrollView setDelegate:self];
    [imageScrollView setBouncesZoom:YES];
    [self.view addSubview:imageScrollView];
    [imageScrollView release];

	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	[imageView setTag:ZOOM_VIEW_TAG];
    [imageView setUserInteractionEnabled:YES];
    [imageView setUserInteractionEnabled:YES];
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:singleTap];
	[singleTap release];
    
    [imageScrollView setContentSize:imageView.frame.size];
    [imageScrollView addSubview:imageView];
    [imageView release];
    
    loaded = YES;
    
//	if (theImg == [[ImageEngine sharedImageEngine] getLoadingImage:ImageSizeLarge]) {
//		loaded = NO;
//		theImg = nil;
//		[appDelegate showIndicatorWithTitle:@"加载中"
//                                   animated:YES
//                                 fullScreen:NO
//                               overKeyboard:NO
//                                andAutoHide:NO]; 
//	} else {
//        if (theImg) {
//            [self refreshScrollView:theImg];
//        }
//    }
}
 
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (loaded) {
//        [self performSelector:@selector(hideNavigationBar) withObject:nil afterDelay:kAutoHideInterval];
    }
    [self hideNavigationBar];

}


#pragma mark utility
- (void)hideNavigationBar {
	[self.navigationController setNavigationBarHidden:YES animated:YES]; 
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationBar) object:nil];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now 
//	if (!loaded) 
//        return;
	if ([self.navigationController isNavigationBarHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
        [self performSelector:@selector(hideNavigationBar) withObject:nil afterDelay:kAutoHideInterval];
	}
}

- (void)handleImageReadyNotification:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSString *path = [dict objectForKey:@"path"];
    if ( [path isEqualToString:imageURL] ) {
        UIImage *theImg = [dict objectForKey:@"image"];
        [self refreshScrollView:theImg];
    }
	loaded = YES;
    //[appDelegate hideIndicator];
    [self performSelector:@selector(hideNavigationBar) withObject:nil afterDelay:kAutoHideInterval];
}

- (void)savePicture {
	UIImageView *imgv = (UIImageView *)[imageScrollView viewWithTag:ZOOM_VIEW_TAG];
	if (imgv.image) {
		UIImageWriteToSavedPhotosAlbum(imgv.image, nil, nil, nil);
//		[appDelegate showIndicatorWithTitle:@"保存成功"
//                                   animated:NO
//                                 fullScreen:NO
//                               overKeyboard:NO
//                                andAutoHide:YES]; 
	}
}

- (void)refreshScrollView:(UIImage *)theImg {
	UIImageView *imageView = (UIImageView *)[imageScrollView viewWithTag:ZOOM_VIEW_TAG];
	CGRect rect = imageView.frame;
	rect.size.width = theImg.size.width;
	rect.size.height = theImg.size.height-1;
	imageView.frame = rect;
	imageView.image = theImg;
	[imageScrollView setContentSize:imageView.frame.size];	
	
	float minimumScale = imageScrollView.frame.size.width  / imageView.frame.size.width;
	if (imageScrollView.frame.size.height  / imageView.frame.size.height < minimumScale) {
		minimumScale = imageScrollView.frame.size.height  / imageView.frame.size.height;
	}
	
	if (minimumScale > 1) {
		[imageScrollView setMaximumZoomScale:minimumScale];
		minimumScale = 1;
	} else {
		[imageScrollView setMaximumZoomScale:1.5];
	}
	
	[imageScrollView setMinimumZoomScale:minimumScale];
    [imageScrollView setZoomScale:minimumScale];
	
	[self centerImage];
}

- (void)cancelView {
    //[appDelegate hideIndicator];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationBar) object:nil];
    //[appDelegate popViewControllerAnimated:YES];

}


#pragma mark scrollview
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    float newScale = scale > imageScrollView.maximumZoomScale? imageScrollView.maximumZoomScale: scale;
    CGRect zoomRect;
    
    zoomRect.size.height = [imageScrollView frame].size.height / newScale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / newScale;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [imageScrollView viewWithTag:ZOOM_VIEW_TAG];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	[self centerImage];
}

- (void)centerImage {
	CGFloat offsetX = (imageScrollView.bounds.size.width > imageScrollView.contentSize.width)? 
	(imageScrollView.bounds.size.width - imageScrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (imageScrollView.bounds.size.height > imageScrollView.contentSize.height)? 
	(imageScrollView.bounds.size.height - imageScrollView.contentSize.height) * 0.5 : 0.0;
    
	UIImageView *img = (UIImageView *)[imageScrollView viewWithTag:ZOOM_VIEW_TAG]; 
	img.center = CGPointMake(imageScrollView.contentSize.width * 0.5 + offsetX, 
							 imageScrollView.contentSize.height * 0.5 + offsetY);
}

@end
