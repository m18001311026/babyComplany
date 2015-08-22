//
//  ContactShareViewController.h
//  baby
//
//  Created by zhang da on 14-6-19.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "PullTableView.h"

@interface ContactShareViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate> {
    
    PullTableView *inviteTable;

}

@property (nonatomic, retain) NSArray *contacts;
@property (nonatomic, retain) NSDictionary *map;

@end
