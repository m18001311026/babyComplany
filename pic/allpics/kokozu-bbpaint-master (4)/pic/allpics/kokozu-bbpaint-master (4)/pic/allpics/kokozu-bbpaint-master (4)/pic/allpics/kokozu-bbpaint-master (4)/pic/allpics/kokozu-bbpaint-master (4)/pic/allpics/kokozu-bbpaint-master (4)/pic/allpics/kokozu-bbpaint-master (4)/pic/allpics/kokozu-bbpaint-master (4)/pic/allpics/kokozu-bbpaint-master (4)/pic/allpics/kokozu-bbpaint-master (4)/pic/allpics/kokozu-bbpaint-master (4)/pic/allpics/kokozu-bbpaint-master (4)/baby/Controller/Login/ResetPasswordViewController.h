//
//  ResetPasswordViewController.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"

@interface ResetPasswordViewController : BBViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *passwordTable;
    UITextField *userName, *validcode, *password;
    UIButton *validCodeBtn;
}

@end
