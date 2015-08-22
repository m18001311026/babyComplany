//
//  ResetPasswordViewController.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "UIButtonExtra.h"

#import "UserTask.h"
#import "TaskQueue.h"
#import "BBExp.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

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
    
    [self setViewTitle:@"重置密码"];
    bbTopbar.backgroundColor = [Shared bbGray];
    
    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];
    
    passwordTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 134)
                                              style:UITableViewStylePlain];
    if ([passwordTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [passwordTable setSeparatorInset:UIEdgeInsetsZero];
    }
    passwordTable.delegate = self;
    passwordTable.dataSource = self;
    passwordTable.scrollEnabled = NO;
    [self.view addSubview:passwordTable];
    [passwordTable release];
    
    UIButton *loginBtn = [UIButton simpleButton:@"确定" y:194];
    [loginBtn setBackgroundColor:[UIColor orangeColor]];
    [loginBtn addTarget:self action:@selector(doReset) forControlEvents:UIControlEventTouchUpInside];
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
    
    if (indexPath.row == 0) {
        //user name
        title.text = @"手机";
        userName = field;
    } else if (indexPath.row == 1) {
        //user password
        title.text = @"验证码";
        
        field.frame = CGRectMake(75, 5, 140, 34);
        validcode = field;
        
        validCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        validCodeBtn.frame = CGRectMake(220, 7, 80, 30);
        [validCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [validCodeBtn setBackgroundColor:[Shared bbOrange]];
        [validCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [validCodeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        validCodeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [validCodeBtn addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
        [validCodeBtn.layer setCornerRadius:2.0];
        [cell addSubview:validCodeBtn];

    } else {
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
- (void)doReset {
    if ([password.text length] < 6) {
        [UI showAlert:@"密码至少为6位"];
        return;
    }
    
    if ([validcode.text length] <  6) {
        [UI showAlert:@"验证码为6位"];
        return;
    }
    
    UserTask *task = [[UserTask alloc] initResetPassword:userName.text verifiCode:validcode.text];
    task.logicCallbackBlock = ^(bool successful, id userInfo) {
        if (successful) {
            UserTask *setPTask = [[UserTask alloc] initSetPassword:password.text];
            setPTask.logicCallbackBlock = ^(bool successful, id userInfo) {
                if (successful) {
                    [UI showAlert:@"修改密码成功，请重新登陆"];
                    [self back];
                }
            };
            [TaskQueue addTaskToQueue:setPTask];
            [setPTask release];
        } else {
            [UI showAlert:@"重置密码失败"];
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

- (void)resetPassword {
    if ([userName.text length] != 11) {
        [UI showAlert:@"错误的手机号"];
        return;
    }
    
    UserTask *task = [[UserTask alloc] initGetVerifiCode:userName.text type:1];
    task.logicCallbackBlock = ^(bool successful, id userInfo) {
        if (successful) {
            [UI showAlert:@"发送成功"];
        } else {
            [UI showAlert:((BBExp *)userInfo).msg];
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

- (void)back {
    [ctr popViewControllerAnimated:YES];
}

@end
