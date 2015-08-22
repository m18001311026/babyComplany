//
//  ShareManager.m
//  baby
//
//  Created by zhang da on 14-5-1.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ShareManager.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import "WXApi.h"
#import "UIDeviceExtra.h"

@implementation ShareManager {
    
}

static ShareManager *_me = nil;

+ (ShareManager *)me {
    if (!_me) {
        @synchronized([ShareManager class]) {
            if (!_me) {
                NSLog(@"share manager init");
                _me = [[ShareManager alloc] init];
            }
        }
    }
    return _me;
}

- (void)dealloc {
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        [ShareSDK registerApp:@"1b15372c2920"
              activePlatforms:@[
                                @(SSDKPlatformTypeSinaWeibo),
                                @(SSDKPlatformTypeWechat),
                                //@(SSDKPlatformTypeTencentWeibo),
                                @(SSDKPlatformTypeQQ)
                                ]
                     onImport:^(SSDKPlatformType platformType) {
                         switch (platformType) {
                             case SSDKPlatformTypeWechat:
                                 [ShareSDKConnector connectWeChat:[WXApi class]];
                                 break;
                             case SSDKPlatformTypeQQ:
                                 [ShareSDKConnector connectQQ:[QQApiInterface class]
                                            tencentOAuthClass:[TencentOAuth class]];
                                 break;
                             default:
                                 break;
                         }
                     }
              onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                  switch (platformType) {
                      case SSDKPlatformTypeSinaWeibo:
                          [appInfo SSDKSetupSinaWeiboByAppKey:@"229660951"
                                                    appSecret:@"bc53d921c84705cde0af815f3b85b3c3"
                                                  redirectUri:@"http://www.children-sketchbook.com"
                                                     authType:SSDKAuthTypeBoth];
                          break;
                      case SSDKPlatformTypeWechat:
                          [appInfo SSDKSetupWeChatByAppId:@"wx9d920249e0c353a7"
                                                appSecret:@"62c5111f0b009eb9d1d72a93d1277beb"];
                          break;
//                      case SSDKPlatformTypeTencentWeibo:
//                          [appInfo SSDKSetupTencentWeiboByAppKey:@"801504129"
//                                                       appSecret:@"dc8e3760d87d2855afaf1236a87f1943"
//                                                     redirectUri:HOMEPAGE];
//                          break;
                      case SSDKPlatformTypeQQ:
                          [appInfo SSDKSetupQQByAppId:@"1104721797"
                                               appKey:@"OXPib1yAvbUozMJj"
                                             authType:SSDKAuthTypeBoth];
                          break;
                      default:
                          break;
                  }
              }];
    }
    return self;
}

- (void)showShareMenuWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(UIImage *)image
                       pageUrl:(NSString *)pageUrl
                      soundUrl:(NSString *)soundUrl {
    if (image) {
        NSMutableDictionary *shareParams = [[NSMutableDictionary alloc] init];
        [shareParams SSDKSetupShareParamsByText:content
                                         images:@[image]
                                            url:[NSURL URLWithString:pageUrl]
                                          title:title
                                           type:SSDKContentTypeImage];
        
        //1.1、QQ空间不支持SSDKContentTypeImage这种类型，所以需要定制下。
        [shareParams SSDKSetupQQParamsByText:content
                                       title:title
                                         url:[NSURL URLWithString:pageUrl]
                                  thumbImage:nil
                                       image:image
                                        type:SSDKContentTypeWebPage
                          forPlatformSubType:SSDKPlatformSubTypeQZone];
        
        [shareParams SSDKSetupQQParamsByText:content
                                       title:title
                                         url:[NSURL URLWithString:pageUrl]
                                  thumbImage:nil
                                       image:image
                                        type:SSDKContentTypeWebPage
                          forPlatformSubType:SSDKPlatformSubTypeQQFriend];
        
        [shareParams SSDKSetupWeChatParamsByText:content
                                           title:title
                                             url:[NSURL URLWithString:pageUrl]
                                      thumbImage:nil
                                           image:image
                                    musicFileURL:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil
                                            type:SSDKContentTypeWebPage
                              forPlatformSubType:SSDKPlatformSubTypeWechatSession];
        
        [shareParams SSDKSetupWeChatParamsByText:content
                                           title:title
                                             url:[NSURL URLWithString:pageUrl]
                                      thumbImage:nil
                                           image:image
                                    musicFileURL:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil
                                            type:SSDKContentTypeWebPage
                              forPlatformSubType:SSDKPlatformSubTypeWechatFav];
        
        [shareParams SSDKSetupWeChatParamsByText:content
                                           title:title
                                             url:[NSURL URLWithString:pageUrl]
                                      thumbImage:nil
                                           image:image
                                    musicFileURL:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil
                                            type:SSDKContentTypeWebPage
                              forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
        
        //2、分享
        [ShareSDK showShareActionSheet:delegate.window.rootViewController.view
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       switch (state) {
                           case SSDKResponseStateBegin: {
                               break;
                           }
                           case SSDKResponseStateSuccess: {
                               [UI showAlert:@"分享成功"];
                               break;
                           }
                           case SSDKResponseStateFail: {
                               [UI showAlert:@"分享失败"];
                               break;
                           }
                           case SSDKResponseStateCancel: {
                               [UI showAlert:@"分享取消"];
                               break;
                           }
                           default:
                               break;
                       }
                       
                       if (state != SSDKResponseStateBegin) {

                       }
                   }];
        [shareParams autorelease];
    }
}

- (void)showShareMenuWithTitle:(NSString *)title
                       content:(NSString *)content
                      imageUrl:(NSString *)imageUrl
                       pageUrl:(NSString *)pageUrl
                      soundUrl:(NSString *)soundUrl {
    if (imageUrl) {
        [IMG getImage:imageUrl callback:^(NSString *url, UIImage *image) {
            [self showShareMenuWithTitle:title
                                 content:content
                                   image:image
                                 pageUrl:pageUrl
                                soundUrl:soundUrl];
        }];
    }
}

@end

