//
//  WelcomeViewController.h
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"

@interface WelcomeViewController : BBViewController <UITextFieldDelegate> {
    UITextField *userName, *password;
    UIImageView *bg;
}

@end
