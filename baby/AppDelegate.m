//
//  AppDelegate.m
//  baby
//
//  Created by zhang da on 14-2-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "WelcomeViewController.h"
#import "Shared.h"
#import "ConfManager.h"
#import <ShareSDK/ShareSDK.h>
#import "SplashViewController.h"
#include "Appdate.h"



AppDelegate *delegate;
NavigationControl *ctr;

#define USER_DEFAULT_SAVE [[NSUserDefaults standardUserDefaults] synchronize]
#define SPLASH_VER [[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_VER"]
#define SPLASH_VER_WRITE(ver) [[NSUserDefaults standardUserDefaults] setValue:ver forKey:@"SPLASH_VER"]

@implementation AppDelegate

- (void)dealloc {
    self.window = nil;
    [super dealloc];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = [[UIViewController alloc] autorelease];
    self.window.rootViewController.view.hidden = YES;
    [Shared init];
    
    if (iOSNotSupport) {
        [UI showAlert:@"iOS版本过低，无法保证软件正常运行，请及时升级"];
    }
    
    ctr = [[NavigationControl alloc] initWithHolder:self.window];
    
    HomeViewController *rootCtr = [[HomeViewController alloc] init];//WithFrame:CGRectMake(0, 20, 320, screentContentHeight)];
    [ctr pushViewController:rootCtr animation:ViewSwitchAnimationNone];
    [rootCtr release];
    

    
    NSString *urlStr = @"https://itunes.apple.com/lookup?id=1022761408";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:req delegate:self];

    
    
    NSString *version = [ConfManager getCurrentVersion];

    if (![SPLASH_VER isEqualToString:version]) {
        SplashViewController *sCtr = [[SplashViewController alloc] init];
        [ctr pushViewController:sCtr animation:ViewSwitchAnimationNone];
        [sCtr release];
        
        SPLASH_VER_WRITE(version);
        USER_DEFAULT_SAVE;
    }
    //https://itunes.apple.com/cn/app/id1022761408?mt=8
    
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
   
    NSError *error;
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *appInfo = (NSDictionary*)json ;

    NSString * version = [[[appInfo objectForKey:@"results"] objectAtIndex:0] objectForKey:@"version"];
     NSString *version1 = [ConfManager getCurrentVersion];

    
    if ([self updateFlagWithAPPversion:version1 AndSerVersion:version]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"升级提示" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }

    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1022761408"]];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(BOOL)updateFlagWithAPPversion:(NSString *)appVersion AndSerVersion:(NSString*)serVersion{
    
    NSArray * SerVersionArray = [serVersion componentsSeparatedByString:@"."];
    NSArray * AppVersionArray = [appVersion componentsSeparatedByString:@"."];
    
    if ([AppVersionArray[0] integerValue]>=[SerVersionArray[0] integerValue]) {
        if([AppVersionArray[0] integerValue] == [SerVersionArray[0] integerValue]){
            if ([AppVersionArray[1] integerValue]>=[SerVersionArray[1] integerValue]) {
                if([AppVersionArray[1] integerValue]==[SerVersionArray[1] integerValue]){
                    if([AppVersionArray[2] integerValue]>=[SerVersionArray[2] integerValue]){
                        //不升级
                        return NO;
                    }else{
                        //升级
                        return YES;
                    }
                }else{
                    //不升级
                    return NO;
                }
            }else{
                //升级
                return YES;
            }
        }else{
            //不升级
            return NO;
        }
    }else{
        //升级
        return YES;
    }
    
}






@end
