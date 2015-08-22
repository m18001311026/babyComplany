//
//  WelcomeViewController.m
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UIButtonExtra.h"
#import "RegisterViewController.h"
#import "ResetPasswordViewController.h"
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import "ShareManager.h"

#import "UserTask.h"
#import "TaskQueue.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

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

    self.view.backgroundColor = [Shared bbGray];
   // [self setViewTitle:@"登录"];
    
    bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 44)];
    [self.view addSubview:bg];
    bg.userInteractionEnabled = YES;
    bg.image = [UIImage imageNamed:@"loginbg.jpg"];
    [bg release];
    
    UIView *blur = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, bg.frame.size.height - 40)];
    blur.backgroundColor = [UIColor whiteColor];
    blur.alpha = 0.6;
    [bg addSubview:blur];
    blur.layer.cornerRadius = 5;
    [blur release];
    
    float posY = largeScreen? 80: 35;
    
    UIView *userNameBg = [[UIView alloc] initWithFrame:CGRectMake(50, posY, 220, 34)];
    userNameBg.backgroundColor = [UIColor whiteColor];
    userNameBg.layer.cornerRadius = 2;
    [bg addSubview:userNameBg];
    [userNameBg release];
    
    userName = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, 200, 30)];
    userName.font = [UIFont systemFontOfSize:18];
    userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    userName.placeholder = @"用户名";
    userName.keyboardType = UIKeyboardTypeNamePhonePad;
    userName.delegate = self;
    userName.textColor = [UIColor grayColor];
    [userNameBg addSubview:userName];
    [userName release];
    
    posY += userNameBg.frame.size.height;
    posY += 10;
    
    UIView *passwordBg = [[UIView alloc] initWithFrame:CGRectMake(50, posY, 220, 34)];
    passwordBg.backgroundColor = [UIColor whiteColor];
    passwordBg.layer.cornerRadius = 2;
    [bg addSubview:passwordBg];
    [passwordBg release];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, 200, 30)];
    password.font = [UIFont systemFontOfSize:18];
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    password.placeholder = @"密码";
    password.secureTextEntry = YES;
    password.delegate = self;
    password.textColor = [UIColor grayColor];
    [passwordBg addSubview:password];
    [password release];
    
    posY += passwordBg.frame.size.height;
    //posY += 5;
    
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.frame = CGRectMake(16, posY, 120, 40);
    [forgetBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetBtn setBackgroundColor:[UIColor clearColor]];
    [forgetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgetBtn setTitleColor:[Shared bbGray] forState:UIControlStateHighlighted];
    forgetBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [forgetBtn addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:forgetBtn];
    
    posY += forgetBtn.frame.size.height;
    //posY += 5;
    
    UIButton *loginBtn = [UIButton simpleButton:@"登录" y:posY];
    loginBtn.frame = CGRectMake(50, posY, 220, 34);
    loginBtn.backgroundColor = [UIColor clearColor];
    [loginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    loginBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    loginBtn.layer.borderWidth = 2;
    loginBtn.layer.cornerRadius = 4;
    [loginBtn addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:loginBtn];

    posY += loginBtn.frame.size.height;

    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(200, posY-loginBtn.frame.size.height-forgetBtn.frame.size.height, 100, 40);
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setBackgroundColor:[UIColor clearColor]];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn setTitleColor:[Shared bbGray] forState:UIControlStateHighlighted];
    registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [registerBtn addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:registerBtn];
    
    posY += registerBtn.frame.size.height;
    posY += 20;
    
    //3rd party login
    UIButton *weiboBtn = [UIButton simpleButton:@"" y:posY];
    weiboBtn.frame = CGRectMake(50, 292, 60, 60);
    NSLog(@"=========11111111%f",posY);
    
    weiboBtn.backgroundColor = [UIColor clearColor];
    [weiboBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
   // weiboBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
   // weiboBtn.layer.borderWidth = 2;
    weiboBtn.layer.cornerRadius = 4;
    [weiboBtn setImage:[UIImage imageNamed:@"sinaweibo.png"] forState:UIControlStateNormal];
    [weiboBtn addTarget:self action:@selector(weiboLogin) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:weiboBtn];
    
    UIButton *weixinBtn = [UIButton simpleButton:@"" y:posY + 44];
    weixinBtn.frame = CGRectMake(50+20+60, 292, 60, 60);
    weixinBtn.backgroundColor = [UIColor clearColor];
    [weixinBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //weixinBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
   // weixinBtn.layer.borderWidth = 2;
    weixinBtn.layer.cornerRadius = 4;
    [weixinBtn setImage:[UIImage imageNamed:@"weixin.png"] forState:UIControlStateNormal];
    [weixinBtn addTarget:self action:@selector(weixinLogin) forControlEvents:UIControlEventTouchUpInside];
    
    
    [bg addSubview:weixinBtn];
    
    UIButton *qqBtn = [UIButton simpleButton:@"" y:posY + 88];
    qqBtn.frame = CGRectMake(50+160, 292, 60, 60);
    qqBtn.backgroundColor = [UIColor clearColor];
    [qqBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  //  qqBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
  //  qqBtn.layer.borderWidth = 2;
    qqBtn.layer.cornerRadius = 4;
    [qqBtn setImage:[UIImage imageNamed:@"qq.png"] forState:UIControlStateNormal];
    [qqBtn addTarget:self action:@selector(qqLogin) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:qqBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [blur addGestureRecognizer:tap];
    [tap release];
    
    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma mark utility
- (void)back {
    [ctr popViewControllerAnimated:YES];
}

- (void)dismissKeyboard {
    if ([userName isFirstResponder] || [password isFirstResponder]) {
        [userName resignFirstResponder];
        [password resignFirstResponder];
    }
}


#pragma mark ui event
- (void)weiboLogin {
    [ShareManager me];
    
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeSinaWeibo
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
                                       //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
                                       associateHandler (user.uid, user, user);

                                       UserTask *task = [[UserTask alloc] initLogin:user.nickname password:nil thirdId:user.uid];
                                       task.logicCallbackBlock = ^(bool succeeded, id userInfo){
                                           if (succeeded) {
                                               [UI showAlert:@"登录成功"];
                                               
                                               if (![[NSUserDefaults standardUserDefaults] valueForKey:@"login"]) {
                                                   [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"login"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   
                                                   [ctr popToRootViewControllerWithAnimation:NO];
                                               } else {
                                                   [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationSwipeL2R];
                                               }
                                           } else {
                                               [UI showAlert:@"登陆失败，请检查网络环境或者帐号密码"];
                                           }
                                       };
                                       [TaskQueue addTaskToQueue:task];
                                       [task release];
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    if (state == SSDKResponseStateSuccess){
                                    }
                                }];
    
}

- (void)weixinLogin {
    [ShareManager me];
    
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeWechat
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       associateHandler (user.uid, user, user);

                                       UserTask *task = [[UserTask alloc] initLogin:user.nickname password:nil thirdId:user.uid];
                                       task.logicCallbackBlock = ^(bool succeeded, id userInfo){
                                           if (succeeded) {
                                               [UI showAlert:@"登录成功"];
                                               
                                               if (![[NSUserDefaults standardUserDefaults] valueForKey:@"login"]) {
                                                   [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"login"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   
                                                   [ctr popToRootViewControllerWithAnimation:NO];
                                               } else {
                                                   [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationSwipeL2R];
                                               }
                                           } else {
                                               [UI showAlert:@"登陆失败，请检查网络环境或者帐号密码"];
                                           }
                                       };
                                       [TaskQueue addTaskToQueue:task];
                                       [task release];
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    if (state == SSDKResponseStateSuccess){
                                    }
                                }];
}

- (void)qqLogin {
    [ShareManager me];
    
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeQQ
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       associateHandler (user.uid, user, user);
                                       
                                       UserTask *task = [[UserTask alloc] initLogin:user.nickname password:nil thirdId:user.uid];
                                       task.logicCallbackBlock = ^(bool succeeded, id userInfo){
                                           if (succeeded) {
                                               [UI showAlert:@"登录成功"];
                                               
                                               if (![[NSUserDefaults standardUserDefaults] valueForKey:@"login"]) {
                                                   [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"login"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   
                                                   [ctr popToRootViewControllerWithAnimation:NO];
                                               } else {
                                                   [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationSwipeL2R];
                                               }
                                           } else {
                                               [UI showAlert:@"登陆失败，请检查网络环境或者帐号密码"];
                                           }
                                       };
                                       [TaskQueue addTaskToQueue:task];
                                       [task release];
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    if (state == SSDKResponseStateSuccess){
                                    }
                                }];
}

- (void)doLogin {
    [self dismissKeyboard];
    
//#warning to be removed
//    [ctr popToRootViewControllerWithAnimation:NO];
//    return;
    
    if ([password.text length] < 6) {
        [UI showAlert:@"密码至少为6位"];
        return;
    }
    
    UserTask *task = [[UserTask alloc] initLogin:userName.text password:password.text thirdId:nil];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo){
        if (succeeded) {
            [UI showAlert:@"登录成功"];
            
            if (![[NSUserDefaults standardUserDefaults] valueForKey:@"login"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"login"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [ctr popToRootViewControllerWithAnimation:NO];
            } else {
                [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationSwipeL2R];
            }
        } else {
            [UI showAlert:@"登陆失败，请检查网络环境或者帐号密码"];
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

- (void)doRegister {
    [self dismissKeyboard];

    RegisterViewController *regVC = [[RegisterViewController alloc] init];
    [ctr pushViewController:regVC animation:ViewSwitchAnimationSwipeR2L];
    [regVC release];
}

- (void)resetPassword {
    [self dismissKeyboard];

    ResetPasswordViewController *restVC = [[ResetPasswordViewController alloc] init];
    [ctr pushViewController:restVC animation:ViewSwitchAnimationSwipeR2L];
    [restVC release];
}


#pragma mark uitextfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == userName) {
        [password becomeFirstResponder];
    } else {
        [self dismissKeyboard];
    }
    return YES;
}

@end
