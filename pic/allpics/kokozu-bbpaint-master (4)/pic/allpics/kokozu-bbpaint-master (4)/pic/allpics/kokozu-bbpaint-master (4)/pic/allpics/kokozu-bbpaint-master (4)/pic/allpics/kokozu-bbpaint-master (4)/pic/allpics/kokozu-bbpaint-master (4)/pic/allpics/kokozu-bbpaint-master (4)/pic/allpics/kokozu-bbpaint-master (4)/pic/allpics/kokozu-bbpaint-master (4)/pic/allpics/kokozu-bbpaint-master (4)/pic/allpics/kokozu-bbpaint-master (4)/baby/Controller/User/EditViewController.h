//
//  ResetPasswordViewController.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"

@interface EditViewController : BBViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *infoTable;
    UITextField *nickName, *intro, *password;
}

@end
