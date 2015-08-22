//
//  RegisterViewController.h
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"
#import "SimpleSegment.h"

@interface RegisterViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SimpleSegmentDelegate> {
    UITableView *registerTable;
    
    UITextField *nickName, *phone, *validcode, *password, *repeatPassword;
    UIButton *validCodeBtn;
}

@end
