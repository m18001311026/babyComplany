//
//  BackgroundTextView.h
//  baby
//
//  Created by zhang da on 15/7/15.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundTextView : UIView {
    UIImageView *bg;
}

@property (nonatomic, retain, readonly) UITextView *textView;

@end
