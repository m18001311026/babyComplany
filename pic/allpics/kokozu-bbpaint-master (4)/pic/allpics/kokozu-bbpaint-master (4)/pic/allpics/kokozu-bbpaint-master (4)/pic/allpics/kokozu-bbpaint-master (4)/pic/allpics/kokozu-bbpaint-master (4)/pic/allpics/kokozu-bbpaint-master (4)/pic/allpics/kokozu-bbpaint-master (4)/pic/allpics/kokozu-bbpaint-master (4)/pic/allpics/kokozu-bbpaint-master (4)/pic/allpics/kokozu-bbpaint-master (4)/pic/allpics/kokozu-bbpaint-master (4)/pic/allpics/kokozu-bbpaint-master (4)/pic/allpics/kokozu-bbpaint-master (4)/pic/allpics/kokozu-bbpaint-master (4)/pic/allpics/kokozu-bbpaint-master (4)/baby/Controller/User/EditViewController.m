//
//  ResetPasswordViewController.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "EditViewController.h"
#import "UIButtonExtra.h"

#import "UserTask.h"
#import "TaskQueue.h"
#import "BBExp.h"
#import "User.h"
#import "ConfManager.h"

@interface EditViewController ()

@end

@implementation EditViewController

- (void)dealloc {
    [super dealloc];
    
}

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setViewTitle:@"修改信息"];
    bbTopbar.backgroundColor = [Shared bbGray];
    
    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 44*4)
                                              style:UITableViewStylePlain];
    if ([infoTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [infoTable setSeparatorInset:UIEdgeInsetsZero];
    }
    infoTable.delegate = self;
    infoTable.dataSource = self;
    infoTable.scrollEnabled = NO;
    [self.view addSubview:infoTable];
    [infoTable release];
    
    UIButton *loginBtn = [UIButton simpleButton:@"确定" y:44*4 + 30];
    [loginBtn setBackgroundColor:[UIColor orangeColor]];
    [loginBtn addTarget:self action:@selector(editUser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@""] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 60, 34)];
    title.font = [UIFont systemFontOfSize:18];
    title.textColor = [UIColor lightGrayColor];
    [cell addSubview:title];
    [title release];
    
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(75, 5, 240, 34)];
    field.font = [UIFont systemFontOfSize:18];
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.textColor = [UIColor grayColor];
    [cell addSubview:field];
    [field release];
    
    User *u = [User getUserWithId:[ConfManager me].userId];
    if (indexPath.row == 0) {
        title.text = @"昵称";
        field.text = u.userNickname;
        field.textColor = [UIColor colorWithWhite:.8 alpha:1];
        field.enabled = NO;
        nickName = field;
    } else if (indexPath.row == 1) {
        title.text = @"简介";
        field.text = u.userIntro;
        intro = field;
    } else if (indexPath.row == 2) {
        title.text = @"新密码";
        field.secureTextEntry = YES;
        password = field;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


#pragma mark ui event
- (void)editUser {
    
    if ([password.text length]) {
        if ([password.text length] < 6) {
            [UI showAlert:@"密码至少为6位"];
            return;
        }
        
        UserTask *setPTask = [[UserTask alloc] initSetPassword:password.text];
        setPTask.logicCallbackBlock = ^(bool successful, id userInfo) {
            if (successful) {
                [UI showAlert:@"修改密码成功"];
                [self back];
            } else {
                [UI showAlert:@"修改密码失败"];
            }
        };
        [TaskQueue addTaskToQueue:setPTask];
        [setPTask release];
    }

    if (intro.text.length) {
        UserTask *task = [[UserTask alloc] initEditIntro:intro.text
                                                  avatar:nil
                                              background:nil];
        task.logicCallbackBlock = ^(bool successful, id userInfo) {
            if (successful) {
                [self back];
            } else {
                [UI showAlert:@"修改介绍失败"];
            }
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    }
    
}

- (void)back {
    [ctr popViewControllerAnimated:YES];
}

@end
