//
//  ContactShareViewController.m
//  baby
//
//  Created by zhang da on 14-6-19.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ContactShareViewController.h"
#import "UIButtonExtra.h"
#import "AddressBookManager.h"
#import "User.h"
#import "ShareTask.h"
#import "TaskQueue.h"
#import "UIBlockSheet.h"
//#import <ShareSDK/ShareSDK.h>
//#import "ShareManager.h"

@interface ContactShareViewController ()

@end

@implementation ContactShareViewController

- (void)dealloc {
    self.contacts = nil;
    self.map = nil;
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [Shared bbRealWhite];
        
        inviteTable = [[PullTableView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 44)
                                                   style:UITableViewStylePlain];
        inviteTable.delegate = self;
        inviteTable.dataSource = self;
        inviteTable.pullDelegate = self;
        inviteTable.backgroundColor = [Shared bbRealWhite];
        inviteTable.pullBackgroundColor = [Shared bbRealWhite];
        if ([inviteTable respondsToSelector:@selector(setSeparatorInset:)]) {
            [inviteTable setSeparatorInset:UIEdgeInsetsZero];
        }
        inviteTable.hasMore = NO;
        [inviteTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        inviteTable.separatorColor = [Shared bbLightGray];
        [self.view addSubview:inviteTable];
        [inviteTable release];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Custom initialization
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setViewTitle:@"通讯录"];
    bbTopbar.backgroundColor = [Shared bbGray];
    
    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (userFlags.initAppear) {
        [[AddressBookManager me] fetchContacts:^(bool succeeded, NSArray *contacts) {
            if (succeeded) {
                NSMutableString *ms = [[NSMutableString alloc] initWithCapacity:0];
                for (Contact *c in contacts) {
                    if (c.phone) {
                        [ms appendFormat:@"%@,", c.phone];
                    }
                }
                
                self.contacts = contacts;
                [inviteTable reloadData];

                ShareTask *task = [[ShareTask alloc] initContactMatch:ms];
                [ms release];
                task.logicCallbackBlock = ^(bool successful, id userInfo) {
                    if (successful) {
                        self.map = userInfo;
                        [inviteTable reloadData];
                    }
                };
                [TaskQueue addTaskToQueue:task];
                [task release];
                [inviteTable showPlaceHolder:nil];

            } else {
                [inviteTable showPlaceHolder:@"您还没有分享您的通讯录，请分享通讯录邀请好友"];
            }
        }];
    }
}


#pragma mark ui event
- (void)back {
    [ctr popViewControllerAnimated:YES];
}


#pragma table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"morecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if (self.contacts.count > indexPath.row) {
        Contact *c = [self.contacts objectAtIndex:indexPath.row];
        

        cell.textLabel.text = c.name;

        if ([self.map objectForKey:c.phone]) {
            cell.detailTextLabel.textColor = [Shared bbGray];
            cell.detailTextLabel.text = @"已加入宝贝计画";
        } else {
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.detailTextLabel.text = @"邀请";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Contact *c = [self.contacts objectAtIndex:indexPath.row];
    if (![self.map objectForKey:c.phone]) {
//        UIBlockSheet *sheet = [[UIBlockSheet alloc] initWithTitle:@"请选择分享方式"];
//        [sheet addButtonWithTitle:@"微信" block: ^{
//            [[ShareManager me] inviteFrom:ShareTypeWeixiSession
//                                  content:@"快来加入宝贝计画吧！"
//                                    title:@"宝贝计画APP"
//                                    image:[UIImage imageNamed:@"icon_120"]
//                                  pageUrl:HOMEPAGE];
//        }];
//        
//        [sheet addButtonWithTitle: @"微博" block: ^{
//            [[ShareManager me] inviteFrom:ShareTypeSinaWeibo
//                                  content:@"快来加入宝贝计画吧！"
//                                    title:@"宝贝计画APP"
//                                    image:[UIImage imageNamed:@"icon_120"]
//                                  pageUrl:HOMEPAGE];
//        }];
//        
//        [sheet addButtonWithTitle: @"QQ" block: ^{
//            [[ShareManager me] inviteFrom:ShareTypeQQ
//                                  content:@"快来加入宝贝计画吧！"
//                                    title:@"宝贝计画APP"
//                                    image:[UIImage imageNamed:@"icon_120"]
//                                  pageUrl:HOMEPAGE];
//        }];
//        
//        [sheet addButtonWithTitle: @"短信" block: ^{
//            if ([MFMessageComposeViewController canSendText]) {
//                
//                MFMessageComposeViewController *mCtr = [[MFMessageComposeViewController alloc] init];
//                mCtr.messageComposeDelegate = self;
//                mCtr.recipients = @[c.phone];
//                mCtr.body = @"快来加入宝贝计画吧！";
//                [self presentViewController:mCtr animated:YES completion:nil];
//                [mCtr release];
//            }
//        }];
//        
//        [sheet setCancelButtonWithTitle: @"取消" block: ^{}];
//        [sheet showInView:self.view];
//        [sheet release];
    }
}

#pragma mark MFMessageComposeViewController 代理方法
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
//    //0 取消  1是成功 2是失败
    NSLog(@"~~~%d",result);
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark pull table view delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    [pullTableView stopLoading];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {

}

@end
