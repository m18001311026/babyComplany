//
//  RegisterViewController.m
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIButtonExtra.h"

#import "UserTask.h"
#import "TaskQueue.h"
#import "BBExp.h"


@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)dealloc {

    [nickName release];
    [phone release];
    [validcode release];
    [password release];
    [repeatPassword release];

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
    
    [self setViewTitle:@"注册"];
    bbTopbar.backgroundColor = [Shared bbGray];
    
    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];
    
    registerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 44)
                                                 style:UITableViewStylePlain];
    if ([registerTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [registerTable setSeparatorInset:UIEdgeInsetsZero];
    }
    registerTable.delegate = self;
    registerTable.dataSource = self;
    registerTable.scrollEnabled = YES;
    [self.view addSubview:registerTable];
    [registerTable release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.cancelsTouchesInView = NO;
    [registerTable addGestureRecognizer:tap];
    [tap release];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    footer.backgroundColor = [UIColor clearColor];
    registerTable.tableFooterView = footer;
    [footer release];

    UIButton *loginBtn = [UIButton simpleButton:@"注册" y:screentContentHeight - 50];
    loginBtn.backgroundColor = [UIColor orangeColor];
    [loginBtn addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.frame = CGRectMake(20, 10, 280, 40);
    [footer addSubview:loginBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma table view section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return 2;
    }
}

- (UITextField *)getField {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(80, 5, 230, 34)];
    field.font = [UIFont systemFontOfSize:16];
    field.delegate = self;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.textColor = [UIColor grayColor];
    return [field autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:nil] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 65, 34)];
    title.font = [UIFont systemFontOfSize:16];
    title.textColor = [UIColor lightGrayColor];
    [cell addSubview:title];
    [title release];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            title.text = @"昵称";
            if (!nickName) {
                nickName = [[self getField] retain];
            }
            [cell addSubview:nickName];
        } else if (indexPath.row == 1) {
            title.text = @"密码";
            
            if (!password) {
                password = [[self getField] retain];
                password.secureTextEntry = YES;
            }
            [cell addSubview:password];
        } else if (indexPath.row == 2) {
            title.text = @"重复密码";
            
            if (!repeatPassword) {
                repeatPassword = [[self getField] retain];
                repeatPassword.secureTextEntry = YES;
            }
            [cell addSubview:repeatPassword];
        }
    } else {
        if (indexPath.row == 0) {
            //user name
            title.text = @"手机";
            if (!phone) {
                phone = [[self getField] retain];
            }
            [cell addSubview:phone];
        } else if (indexPath.row == 1) {
            //user password
            title.text = @"验证码";
            
            if (!validcode) {
                validcode = [[self getField] retain];
                validcode.frame = CGRectMake(75, 5, 140, 34);
            }
            [cell addSubview:validcode];
            
            validCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            validCodeBtn.frame = CGRectMake(220, 7, 80, 30);
            [validCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            [validCodeBtn setBackgroundColor:[Shared bbOrange]];
            [validCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [validCodeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            [validCodeBtn addTarget:self action:@selector(getVerfiCode) forControlEvents:UIControlEventTouchUpInside];
            validCodeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            [validCodeBtn.layer setCornerRadius:2.0];
            [cell addSubview:validCodeBtn];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {

    }
}


#pragma mark ui event
- (void)back {
    [ctr popViewControllerAnimated:YES];
}

- (void)dismissKeyboard {
    [phone resignFirstResponder];
    [validcode resignFirstResponder];
    [password resignFirstResponder];
    [repeatPassword resignFirstResponder];
    [nickName resignFirstResponder];

    registerTable.contentInset = UIEdgeInsetsZero;
}

- (void)tap:(UITapGestureRecognizer *)tap {
    [self dismissKeyboard];
}

- (void)doRegister {
    [self dismissKeyboard];
    
    if ([phone.text length] != 11) {
        [UI showAlert:@"错误的手机号"];
        return;
    }
    
    if ([password.text length] < 6) {
        [UI showAlert:@"密码至少为6位"];
        return;
    }
    
    [UI showIndicator];
    
    UserTask *task = [[UserTask alloc] initRegister:phone.text
                                           nickname:nickName.text
                                           password:password.text
                                         verifiCode:validcode.text
                                            thirdId:nil];
    task.logicCallbackBlock = ^(bool successful, id userInfo) {
        if (successful) {
            [UI hideIndicator];
            [UI showAlert:@"恭喜你，注册成功"];
            [ctr popViewControllerAnimated:YES];
        } else {
            [UI hideIndicator];
            [UI showAlert:((BBExp *)userInfo).msg];
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

- (void)getVerfiCode {
    if ([phone.text length] != 11) {
        [UI showAlert:@"错误的手机号"];
        return;
    }
    
    UserTask *task = [[UserTask alloc] initGetVerifiCode:phone.text type:0];
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


#pragma mark uitextfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    registerTable.contentInset = UIEdgeInsetsMake(0, 0, 240, 0);
    if (textField == nickName) {

    } else if (textField == password) {
    
    } else if (textField == repeatPassword) {

    } else if (textField == phone) {

    } else if (textField == validcode) {
        [registerTable setContentOffset:CGPointMake(0, 100) animated:YES];
    } else {
        [self dismissKeyboard];
        [registerTable setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == nickName) {
        [password becomeFirstResponder];
    } else if (textField == password) {
        [repeatPassword becomeFirstResponder];
    } else if (textField == repeatPassword) {
        [phone becomeFirstResponder];
    } else if (textField == phone) {
        [validcode becomeFirstResponder];
    } else if (textField == validcode) {
        [self dismissKeyboard];
    } else {
        [self dismissKeyboard];
    }
    return YES;
}


@end
