/*
     File: AVCamCaptureManager.m
 Abstract: Uses the AVCapture classes to capture video and still images.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamCaptureManager.h"
#import "AVCamUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define unlockOrientation 1

#pragma mark -
@interface AVCamCaptureManager (RunningSupportMethods)

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;

@end


#pragma mark -
@implementation AVCamCaptureManager

@synthesize session;
@synthesize orientation;
@synthesize videoInput;
@synthesize stillImageOutput;
@synthesize backgroundRecordingID;
@synthesize delegate;


- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:AVCaptureDeviceWasDisconnectedNotification object:nil];
    [nc removeObserver:self name:AVCaptureDeviceWasConnectedNotification object:nil];
    
    [motionManager stopAccelerometerUpdates];
    motionManager = nil;
    
    [self.session stopRunning];
    self.session = nil;
    self.inputCamera = nil;
    
    [videoInput release];
    [stillImageOutput release];
    
    [super dealloc];
}

- (id)init {
    self = [self initWithSessionPreset:AVCaptureSessionPresetPhoto
                        cameraPosition:AVCaptureDevicePositionBack];
    if (self) {
        
    }
    return self;
}

- (id)initWithSessionPreset:(NSString *)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition {

    self = [super init];
    
    if (self) {        
        orientation = AVCaptureVideoOrientationPortrait;
        
        self.inputCamera = [self cameraWithPosition:cameraPosition];
        [self changeFlashModel:AVCaptureFlashModeAuto];
        [self changeTorchModel:AVCaptureTorchModeAuto];
        
        
        // Init the device inputs
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.inputCamera error:nil];
        self.videoInput = newVideoInput;
        [newVideoInput release];
        
        // Setup the still image file output
        AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [newStillImageOutput setOutputSettings:[NSDictionary dictionaryWithObjectsAndKeys:
                                                AVVideoCodecJPEG, AVVideoCodecKey,
                                                nil]];
        self.stillImageOutput = newStillImageOutput;
        [newStillImageOutput release];
        
        
        // Create session (use default AVCaptureSessionPresetHigh)
        AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
        [newCaptureSession beginConfiguration];
        newCaptureSession.sessionPreset = sessionPreset;
        // Add inputs and output to the capture session
        if (self.videoInput && [newCaptureSession canAddInput:self.videoInput]) {
            [newCaptureSession addInput:self.videoInput];
        }
        if (self.stillImageOutput && [newCaptureSession canAddOutput:self.stillImageOutput]) {
            [newCaptureSession addOutput:self.stillImageOutput];
        }
        [newCaptureSession commitConfiguration];
        self.session = newCaptureSession;
        [newCaptureSession release];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(deviceDisconnected:)
                   name:AVCaptureDeviceWasDisconnectedNotification
                 object:nil];
        [nc addObserver:self selector:@selector(deviceConnected:)
                   name:AVCaptureDeviceWasConnectedNotification
                 object:nil];

#if unlockOrientation
        motionManager = [[CMMotionManager alloc] init];
        motionManager.accelerometerUpdateInterval = 1/60.0;
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMAccelerometerData *data, NSError *error) {
                                                //NSLog(@"x:= %f y:= %f z:= %f", data.acceleration.x, data.acceleration.y, data.acceleration.z);
                                                // Get the current device angle
                                                float xx = -data.acceleration.x;
                                                float yy = data.acceleration.y;
                                                float angle = atan2(yy, xx);
                                                
                                                // Read my blog for more details on the angles. It should be obvious that you
                                                // could fire a custom shouldAutorotateToInterfaceOrientation-event here.
                                                if(angle >= -2.25 && angle <= -0.25) {
                                                    if(orientation != AVCaptureVideoOrientationPortrait) {
                                                        orientation = AVCaptureVideoOrientationPortrait;
                                                    }
                                                } else if(angle >= -1.75 && angle <= 0.75) {
                                                    if(orientation != AVCaptureVideoOrientationLandscapeRight) {
                                                        orientation = AVCaptureVideoOrientationLandscapeRight;
                                                    }
                                                } else if(angle >= 0.75 && angle <= 2.25) {
                                                    if(orientation != AVCaptureVideoOrientationPortraitUpsideDown) {
                                                        orientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                                    }
                                                } else if(angle <= -2.25 || angle >= 2.25) {
                                                    if(orientation != AVCaptureVideoOrientationLandscapeLeft) {
                                                        orientation = AVCaptureVideoOrientationLandscapeLeft;
                                                    }
                                                }
                                                
        }];
#endif
    }
    
    return self;
}


#pragma mark - running support
- (void)deviceDisconnected:(NSNotification *)notification {
    AVCaptureDevice *device = [notification object];
    
    if ([device hasMediaType:AVMediaTypeVideo]) {
        [session removeInput:self.videoInput];
        self.videoInput = nil;
    }
    
    if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
        [delegate captureManagerDeviceConfigurationChanged:self];
    }
}

- (void)deviceConnected:(NSNotification *)notification {
    AVCaptureDevice *device = [notification object];
    
    BOOL sessionHasDeviceWithMatchingMediaType = NO;
    NSString *deviceMediaType = nil;
    if ([device hasMediaType:AVMediaTypeAudio])
        deviceMediaType = AVMediaTypeAudio;
    else if ([device hasMediaType:AVMediaTypeVideo])
        deviceMediaType = AVMediaTypeVideo;
    
    if (deviceMediaType != nil) {
        for (AVCaptureDeviceInput *input in [session inputs]) {
            if ([[input device] hasMediaType:deviceMediaType]) {
                sessionHasDeviceWithMatchingMediaType = YES;
                break;
            }
        }
        
        if (!sessionHasDeviceWithMatchingMediaType) {
            NSError	*error;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if ([session canAddInput:input])
                [session addInput:input];
        }
    }
    
    if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
        [delegate captureManagerDeviceConfigurationChanged:self];
    }
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark - camera basic service
- (void)captureStillImage:(bool)saveToLocal {
    AVCaptureConnection *stillImageConnection = [AVCamUtilities connectionWithMediaType:AVMediaTypeVideo
                                                                        fromConnections:[[self stillImageOutput] connections]];
    if ([stillImageConnection isVideoOrientationSupported])
        [stillImageConnection setVideoOrientation:orientation];
    
    [self.stillImageOutput
     captureStillImageAsynchronouslyFromConnection:stillImageConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         
         if (imageDataSampleBuffer != NULL) {

             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];

             if (saveToLocal) {
                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                 [library writeImageToSavedPhotosAlbum:[image CGImage]
                                           orientation:(ALAssetOrientation)[image imageOrientation]
                                       completionBlock:^(NSURL *assetURL, NSError *error) {
                                           
                                       }];
                 [library release];
             }

             if ([[self delegate] respondsToSelector:@selector(captureManager:didCaptureImage:)]) {
                 [[self delegate] captureManager:self didCaptureImage:image];
             }
             
             [image release];
         } else {
             if (error) {
                 if ([self.delegate respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                     [self.delegate captureManager:self didFailWithError:error];
                 }
             }
         }
     }];
}

- (BOOL)changeCamera:(AVCaptureDevicePosition)camPostion withPreset:(NSString *)sessionPreset {
    
    BOOL success = NO;

    if ([self cameraCount] > 1) {
        AVCaptureDevice *device = [self cameraWithPosition:camPostion];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
        
        if (newVideoInput) {
            [self.session beginConfiguration];
            
            /*
             change preset after change input, or will get error when change back to front with high preset
             */
            [self.session removeInput:self.videoInput];
            self.session.sessionPreset = sessionPreset;
            
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                self.inputCamera = device;
                self.videoInput = newVideoInput;
                success = YES;
            } else {
                [self.session addInput:self.videoInput];
            }
            
            [self.session commitConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:nil];
            }
        }
        
        [newVideoInput release];
        
    }
    return success;
}

- (BOOL)changeFlashModel:(AVCaptureFlashMode)flashMode {
    BOOL success = NO;

    if ([self.inputCamera hasFlash]) {
        if ([self.inputCamera lockForConfiguration:nil]) {
            if ([self.inputCamera isFlashModeSupported:flashMode]) {
                [self.inputCamera setFlashMode:flashMode];
                success = YES;
            }
            [self.inputCamera  unlockForConfiguration];
        }
    }
    
    return success;
}

- (BOOL)changeTorchModel:(AVCaptureTorchMode)torchMode {
    BOOL success = NO;

    if ([self.inputCamera hasTorch]) {
        if ([self.inputCamera lockForConfiguration:nil]) {
            if ([self.inputCamera isTorchModeSupported:torchMode]) {
                [self.inputCamera setTorchMode:torchMode];
            }
            [self.inputCamera unlockForConfiguration];
        }
    }
    
    return success;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void)autoFocusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }        
    }
}

// Switch to continuous auto focus mode at the specified point
- (void)continuousFocusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [[self videoInput] device];
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
}



@end




