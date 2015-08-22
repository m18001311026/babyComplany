#import <UIKit/UIKit.h>
#import "AVCamCaptureManager.h"

@class AVCamView, AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

typedef void ( ^PhotoPickedCallback ) (UIImage *image);

@interface AVCamView: UIView <AVCamCaptureManagerDelegate> {
    CALayer *activeFrame;
    UIView *previewView;
    bool _enableCapture;
}

@property (nonatomic, retain) AVCamCaptureManager *captureManager;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, copy) PhotoPickedCallback callback;

- (void)captureImage:(bool)save callback:(PhotoPickedCallback)callback;
- (void)toggleCamera;
- (void)toggleFlash;

- (AVCaptureFlashMode)flashMode;
- (void)setFlashMode:(AVCaptureFlashMode)mode;

- (AVCaptureDevicePosition)cameraPosition;
- (int)cameraCount;

@end