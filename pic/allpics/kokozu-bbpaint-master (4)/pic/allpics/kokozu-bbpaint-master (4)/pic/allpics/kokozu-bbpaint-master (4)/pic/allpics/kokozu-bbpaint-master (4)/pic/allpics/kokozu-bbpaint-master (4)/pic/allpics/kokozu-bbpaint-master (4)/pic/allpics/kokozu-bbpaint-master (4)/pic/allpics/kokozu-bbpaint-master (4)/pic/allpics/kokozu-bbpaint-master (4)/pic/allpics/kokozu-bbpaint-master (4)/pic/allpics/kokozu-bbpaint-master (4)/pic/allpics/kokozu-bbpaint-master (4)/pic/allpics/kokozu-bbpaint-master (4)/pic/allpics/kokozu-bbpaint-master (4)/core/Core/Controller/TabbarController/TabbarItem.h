//
//  TabbarItem.h
//  Aimeili
//
//  Created by zhang da on 12-8-7.
//  Copyright (c) 2012年 kokozu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabbarItem;

@protocol TabbarItemDelegate <NSObject>

- (void)tabbarItem:(TabbarItem *)item touchedAtIndex:(int)idx;

@end



@interface TabbarItem : UIControl {
    UIImageView *imageView;
    UILabel *titleLabel;
    UITextField *badgeField;
}

@property (nonatomic, assign) BOOL activated;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) id<TabbarItemDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
        normalImage:(NSString *)norName
  hightlightedImage:(NSString *)hltName
        normalColor:(UIColor *)norColor
  hightlightedColor:(UIColor *)hltColor
              index:(int)idx;
- (void)setBadge:(NSString *)badge;

@end
