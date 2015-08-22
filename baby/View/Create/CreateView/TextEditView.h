//
//  TextEditView.h
//  baby
//
//  Created by zhang da on 15/7/1.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TextEditViewDelegate <NSObject>

- (void)textDidChange:(NSString *)newString;
- (void)textDidEndEdit:(NSString *)finalString fontSize:(int)size color:(UIColor *)color;

@end


@interface TextEditView : UIView <UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) id<TextEditViewDelegate> delegate;

- (void)setText:(NSString *)text andColor:(UIColor *)color andSize:(int)size;
- (void)beginEdit;

@end
