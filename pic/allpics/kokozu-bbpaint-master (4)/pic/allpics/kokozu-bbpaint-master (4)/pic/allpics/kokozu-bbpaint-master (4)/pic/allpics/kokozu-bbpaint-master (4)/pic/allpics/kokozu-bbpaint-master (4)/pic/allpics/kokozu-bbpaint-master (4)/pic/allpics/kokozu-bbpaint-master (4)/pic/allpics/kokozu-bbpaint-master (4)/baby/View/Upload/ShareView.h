//
//  ShareView.h
//  baby
//
//  Created by zhang da on 14-5-9.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareBtn;

@interface ShareView : UIView {
    
    UILabel *info;
    ShareBtn *weixin, *weibo, *qweibo, *qzone;
    
}

- (bool)enableWeixin;
- (bool)enableWeibo;
- (bool)enableQweibo;
- (bool)enableQzone;

@end
