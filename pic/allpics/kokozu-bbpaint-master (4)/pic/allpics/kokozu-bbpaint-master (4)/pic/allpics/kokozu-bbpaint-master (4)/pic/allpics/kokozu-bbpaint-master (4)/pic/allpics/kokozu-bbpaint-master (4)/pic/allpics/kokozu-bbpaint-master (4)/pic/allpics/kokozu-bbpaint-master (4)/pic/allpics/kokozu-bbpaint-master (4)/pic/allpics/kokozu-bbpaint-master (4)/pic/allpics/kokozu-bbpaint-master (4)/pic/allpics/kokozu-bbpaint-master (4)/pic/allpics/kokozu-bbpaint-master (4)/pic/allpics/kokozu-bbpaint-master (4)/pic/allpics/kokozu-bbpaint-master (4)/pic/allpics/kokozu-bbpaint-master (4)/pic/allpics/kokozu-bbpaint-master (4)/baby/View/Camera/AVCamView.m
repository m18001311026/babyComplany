#import "AVCamView.h"
#import "AVCamCaptureManager.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>


#define PIC_QUATITY AVCaptureSessionPresetHigh //AVCaptureSessionPresetPhoto

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface AVCamView (InternalMethods)

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;

- (void)showFocusFrameAtPoint:(CGPoint)point;
- (void)hideFocusFrame;

@end


@implementation AVCamView

- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode {
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode"];

    self.callback = nil;
    self.captureManager = nil;
    self.captureVideoPreviewLayer = nil;
    
    [self hideFocusFrame];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _enableCapture = YES;
        self.backgroundColor = [UIColor blackColor];

        AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] initWithSessionPreset:PIC_QUATITY
                                                                           cameraPosition:AVCaptureDevicePositionBack];
        self.captureManager = manager;
        self.captureManager.delegate = self;
        [manager release];
        
        // Create video preview layer and add it to the UI
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureManager.session];
        //BOOL orientationSupported;
        if ([previewLayer respondsToSelector:@selector(connection)]) {
            //orientationSupported = previewLayer.connection.isVideoOrientationSupported;
            [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        } else {
            //orientationSupported = previewLayer.isOrientationSupported;
            [previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        }
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//AVLayerVideoGravityResizeAspect;
        self.captureVideoPreviewLayer = previewLayer;
        [previewLayer release];
        
        activeFrame = nil;
        
        previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:previewView];
        [previewView release];
        
        CALayer *viewLayer = [previewView layer];
        //[viewLayer setMasksToBounds:YES];
        [viewLayer insertSublayer:self.captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        self.captureVideoPreviewLayer.frame = previewView.bounds;
        
        // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] session] startRunning];
        });
        
        // Add a double tap gesture to reset the focus mode to continuous auto focus
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tapToContinouslyAutoFocus:)];
        [doubleTap setNumberOfTapsRequired:2];
        [previewView addGestureRecognizer:doubleTap];
        [doubleTap release];
        
        // Add a single tap gesture to focus on the point tapped, then lock focus
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tapToAutoFocus:)];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [singleTap setNumberOfTapsRequired:1];
        [previewView addGestureRecognizer:singleTap];
        [singleTap release];

        
        [self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];

    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == AVCamFocusModeObserverContext) {
        AVCaptureFocusMode mode = (AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        // Update the focus UI overlay string when the focus mode changes
        NSLog(@"focus: %@", [self stringForFocusMode:mode]);
        if (mode == AVCaptureFocusModeLocked) {
            [self hideFocusFrame];
        }
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark button Actions
- (void)toggleCamera {
    // Toggle between cameras when there is more than one
    if ( self.captureManager.inputCamera.position == AVCaptureDevicePositionBack ) {
        [self.captureManager changeCamera:AVCaptureDevicePositionFront withPreset:PIC_QUATITY];
    } else {
        [self.captureManager changeCamera:AVCaptureDevicePositionBack withPreset:PIC_QUATITY];
        //[self.captureManager changeCamera:AVCaptureDevicePositionBack withPreset:AVCaptureSessionPreset1280x720];
    }
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (AVCaptureDevicePosition)cameraPosition {
    return self.captureManager.inputCamera.position;
}

- (void)toggleFlash {
    if ([self.captureManager.inputCamera hasFlash]) {
        AVCaptureFlashMode mode = AVCaptureFlashModeAuto;
        switch (self.captureManager.inputCamera.flashMode) {
            case AVCaptureFlashModeAuto:
                mode = AVCaptureFlashModeOn;
                break;
            case AVCaptureFlashModeOn:
                mode = AVCaptureFlashModeOff;
                break;
            case AVCaptureFlashModeOff:
                mode = AVCaptureFlashModeAuto;
                break;
        }
        [self.captureManager changeFlashModel:mode];
    }
}

- (AVCaptureFlashMode)flashMode {
    return self.captureManager.inputCamera.flashMode;
}

- (void)setFlashMode:(AVCaptureFlashMode)mode {
    [self.captureManager changeFlashModel:mode];
}

- (int)cameraCount {
    return (int)[self.captureManager cameraCount];
}

- (void)captureImage:(bool)save callback:(PhotoPickedCallback)callback {
    // Capture a still image
    if (_enableCapture) {
        _enableCapture = NO;
        
        self.callback = callback;
        
        [[self captureManager] captureStillImage:save];
        
        // Flash the screen white and fade it out to give UI feedback that a still image was taken
        UIView *flashView = [[UIView alloc] initWithFrame:previewView.frame];
        [flashView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:flashView];
        
        [UIView animateWithDuration:.4f
                         animations:^{
                             [flashView setAlpha:0.f];
                         }
                         completion:^(BOOL finished){
                             [flashView removeFromSuperview];
                             [flashView release];
                         }
         ];
    }
}

@end


@implementation AVCamView (InternalMethods)

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = previewView.frame.size;
    
    
    BOOL videoMirrored;
    if ([self.captureVideoPreviewLayer respondsToSelector:@selector(connection)]) {
        videoMirrored = self.captureVideoPreviewLayer.connection.isVideoMirrored;
    } else {
        videoMirrored = self.captureVideoPreviewLayer.isMirrored;
    }
    
    if (videoMirrored) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }

    if ( [[self.captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;

                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[self.captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[self.captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)showFocusFrameAtPoint:(CGPoint)point {    
    CALayer *focusFrame = [CALayer layer];
	[activeFrame removeFromSuperlayer];
	focusFrame.bounds = CGRectMake(0, 0, 70, 70);
	focusFrame.position = CGPointMake(point.x, point.y);
	
	CGFloat border_rgba[] = { 0.9, 0.9, 1.0, 1.0 };
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef borderColor = CGColorCreate(colorSpace, border_rgba);
	focusFrame.borderColor = borderColor;
	focusFrame.borderWidth = 1.5;
	focusFrame.shadowColor = [[UIColor blueColor] CGColor];
	focusFrame.shadowOffset = CGSizeMake(0, 0);
	focusFrame.shadowOpacity = 1.0;
	CGColorRelease(borderColor);
	CGColorSpaceRelease(colorSpace);
	
	CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
	flash.duration = 0.2;
    flash.repeatCount = 999;
	flash.autoreverses = YES;
    flash.fromValue = [NSNumber numberWithFloat:1.0];
    flash.toValue = [NSNumber numberWithFloat:0.0];
	[focusFrame addAnimation:flash forKey:@"opacity"];
	
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.duration = 0.2;
    scale.repeatCount = 1;
    scale.fromValue = [NSNumber numberWithFloat:1.5];
    scale.toValue = [NSNumber numberWithFloat:1.0];
	[focusFrame addAnimation:scale forKey:@"transform.scale"];
	
	[previewView.layer addSublayer:focusFrame];
	activeFrame = focusFrame;
}

- (void)hideFocusFrame {
    [activeFrame removeAllAnimations];
    [activeFrame removeFromSuperlayer];
    activeFrame = nil;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapPoint = [gestureRecognizer locationInView:self];
    
    if ([[[self.captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [self.captureManager autoFocusAtPoint:convertedFocusPoint];
        
        [self showFocusFrameAtPoint:tapPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer {
    if ([[[self.captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        [self.captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
    }
}

- (UIImage*)subImageFrom:(UIImage *)image withRect:(CGRect)rect backgroundColor:(UIColor *)color {
    
    if (rect.size.height == 0 || rect.size.width == 0) {
        return nil;
    }
    
    CGSize oSize = image.size;
    CGSize dSize = rect.size;
    
    float scaleW = oSize.width / dSize.width * 1.0;
    float scaleH = oSize.height / dSize.height * 1.0;
    float scaleFinal = MIN(scaleW, scaleH);
    
    CGRect final = CGRectMake(
                      (oSize.width - dSize.width * scaleFinal) / 2,
                      (oSize.height - dSize.height * scaleFinal) / 2,
                      dSize.width * scaleFinal,
                      dSize.height * scaleFinal);

    
    UIGraphicsBeginImageContext(final.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-final.origin.x, -final.origin.y, image.size.width, image.size.height);
    
    //clip to the bounds of the image context
    //not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, drawRect.size.width, drawRect.size.height));
    
    //add background color
    [color set];
    
    CGContextFillRect(context, CGRectMake(0, 0, final.size.width, final.size.height));
    
    //draw image
    [image drawInRect:drawRect];
    
    //grab image
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return subImage;
}


@end


@implementation AVCamView (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error {
    _enableCapture = YES;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}

- (void)captureManager:(AVCamCaptureManager *)captureManager didCaptureImage:(UIImage *)image {
    if (self.callback) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            //resize image
            UIImage *final = [self subImageFrom:image withRect:self.frame backgroundColor:[UIColor blackColor]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _enableCapture = YES;
                self.callback(final);
                self.callback = nil;
            });
        });
    }
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager {

}

@end
