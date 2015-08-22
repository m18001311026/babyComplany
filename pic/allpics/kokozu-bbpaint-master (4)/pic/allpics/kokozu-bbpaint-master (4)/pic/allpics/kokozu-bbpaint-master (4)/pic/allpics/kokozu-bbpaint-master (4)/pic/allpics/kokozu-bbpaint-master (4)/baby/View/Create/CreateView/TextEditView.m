//
//  TextEditView.m
//  baby
//
//  Created by zhang da on 15/7/1.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "TextEditView.h"
#import "KZColorPicker.h"

#define PICKER_HEIGHT 270
#define BAR_HEIGHT 44
#define DEFAULT_IBGFRAME CGRectMake(0, screentContentHeight - BAR_HEIGHT, 320, BAR_HEIGHT)
#define PICKER_IBGFRAME CGRectMake(0, screentContentHeight - BAR_HEIGHT - PICKER_HEIGHT, 320, BAR_HEIGHT)

@interface TextEditView() {
    UIView *inputBgView, *pickerBgView;
    UITextView *inputView;
    KZColorPicker *colorPicker;
    UIPickerView *fontSizePicker;
    UIButton *colorBtn, *sizeBtn;
}

//@property (nonatomic, assign) int fontSize;
//@property (nonatomic, retain) UIColor *color;

@end


@implementation TextEditView


- (void)dealloc {
    [self removeKeyboardNotifications];

    [colorPicker release]; colorPicker = nil;
    [inputView release]; inputView = nil;
    [pickerBgView release];

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:.6 alpha:.4];
        
        UIControl *singleTap = [[UIControl alloc] initWithFrame:self.bounds];
        [singleTap addTarget:self
                      action:@selector(singleTap)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:singleTap];
        [singleTap release];
        
        inputBgView = [[UIView alloc] initWithFrame:DEFAULT_IBGFRAME];
        inputBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:inputBgView];
        [inputBgView release];
        
        colorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        colorBtn.frame = CGRectMake(5, 7, 30, 30);
        [colorBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [colorBtn setTitle:@"颜色" forState:UIControlStateNormal];
        colorBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        colorBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        colorBtn.layer.borderWidth = 1;
        colorBtn.layer.masksToBounds = YES;
        colorBtn.layer.cornerRadius = 15;
        [colorBtn addTarget:self action:@selector(toggleColorPicker) forControlEvents:UIControlEventTouchUpInside];
        [inputBgView addSubview:colorBtn];
        
        sizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sizeBtn.frame = CGRectMake(40, 7, 30, 30);
        [sizeBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [sizeBtn setTitle:@"字号" forState:UIControlStateNormal];
        sizeBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        sizeBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        sizeBtn.layer.borderWidth = 1;
        sizeBtn.layer.masksToBounds = YES;
        sizeBtn.layer.cornerRadius = 15;
        [sizeBtn addTarget:self action:@selector(toggleFontSizePicker) forControlEvents:UIControlEventTouchUpInside];
        [inputBgView addSubview:sizeBtn];
        
        inputView = [[UITextView alloc] initWithFrame:CGRectMake(75, 5, 205, 34)];
        inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        inputView.layer.borderWidth = 1;
        inputView.returnKeyType = UIReturnKeyDone;
        inputView.delegate = self;
        inputView.editable = YES;
        [inputBgView addSubview:inputView];
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        okBtn.frame = CGRectMake(285, 7, 30, 30);
        [okBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [okBtn setTitle:@"√" forState:UIControlStateNormal];
        okBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        okBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        okBtn.layer.borderWidth = 1;
        okBtn.layer.masksToBounds = YES;
        okBtn.layer.cornerRadius = 15;
        [okBtn addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
        [inputBgView addSubview:okBtn];
        
        [self registerKeyboardNotifications];

    }
    return self;
}

- (void)pickerChanged:(KZColorPicker *)cp {
    inputView.textColor = cp.selectedColor;
    //[delegate defaultColorController:self didChangeColor:cp.selectedColor];
}


#pragma ui event
- (void)beginEdit {
    [inputView becomeFirstResponder];
}

- (void)singleTap {
    [self hideColorPicker];
    [self hideFontSizePicker];
    [inputView resignFirstResponder];
}

- (void)toggleFontSizePicker {
    if (![pickerBgView superview]) {
        [inputView resignFirstResponder];
        [self hideColorPicker];
        [self showFontSizePicker];
    } else {
        [self hideFontSizePicker];
    }
}

- (void)showFontSizePicker {
    [inputView resignFirstResponder];

    if (!fontSizePicker) {
        pickerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, screentContentHeight - PICKER_HEIGHT, 320, PICKER_HEIGHT)];
        pickerBgView.backgroundColor = [UIColor whiteColor];
        
        fontSizePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, PICKER_HEIGHT)];
        fontSizePicker.delegate = self;
        fontSizePicker.dataSource = self;
        fontSizePicker.backgroundColor = [UIColor clearColor];
        [pickerBgView addSubview:fontSizePicker];
        [fontSizePicker release];
    }
    
    if (![pickerBgView superview]) {
        inputBgView.frame = PICKER_IBGFRAME;
        [self addSubview:pickerBgView];
    }
}

- (void)hideFontSizePicker {
    if ([fontSizePicker superview]) {
        inputBgView.frame = DEFAULT_IBGFRAME;
        [pickerBgView removeFromSuperview];
    }
}

- (void)toggleColorPicker {
    if (![colorPicker superview]) {
        [inputView resignFirstResponder];
        [self hideFontSizePicker];
        [self showColorPicker];
    } else {
        [self hideColorPicker];
    }
}

- (void)showColorPicker {
    [inputView resignFirstResponder];

    if (!colorPicker) {
        colorPicker = [[KZColorPicker alloc] initWithFrame:
                       CGRectMake(0, screentContentHeight - PICKER_HEIGHT, 320, PICKER_HEIGHT)];
        colorPicker.selectedColor = [UIColor whiteColor];
        colorPicker.oldColor = [UIColor whiteColor];
        [colorPicker addTarget:self
                        action:@selector(pickerChanged:)
              forControlEvents:UIControlEventValueChanged];
    }
    
    if (![colorPicker superview]) {
        inputBgView.frame = PICKER_IBGFRAME;
        [self addSubview:colorPicker];
    }
}

- (void)hideColorPicker {
    if ([colorPicker superview]) {
        inputBgView.frame = PICKER_IBGFRAME;
        [colorPicker removeFromSuperview];
    }
}

- (void)showSizeSlider {
    
}

- (void)donePressed {
    [inputView resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textDidEndEdit:fontSize:color:)]) {
        [self.delegate textDidEndEdit:inputView.text
                             fontSize:[inputView.font pointSize]
                                color:inputView.textColor];
    }
}

- (void)setText:(NSString *)text andColor:(UIColor *)color andSize:(int)size {
    inputView.text = text;
    inputView.textColor = color;
    inputView.font = [UIFont systemFontOfSize:size];
}


#pragma mark keyboard
- (void)registerKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)removeKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
//    if (![inputView isFirstResponder]) {
//        return;
//    }

    NSDictionary* info = [notification userInfo];
    CGRect endFrame = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float keyboardHeight = endFrame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        inputBgView.frame = CGRectMake(0, screentContentHeight - BAR_HEIGHT - keyboardHeight, 320, BAR_HEIGHT);
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.3 animations:^{
        inputBgView.frame = DEFAULT_IBGFRAME;
    }];
}


#pragma mark uitextview delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self hideColorPicker];
    [self hideFontSizePicker];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self donePressed];
        return NO;
    }
    return YES;
}


#pragma mark uipickerview delegate and datasource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 3;
    } else {
        return 10;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 44;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", (int)row + (component == 0? 1: 0)];
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0); // attributed title is favored if both methods are implemented
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger fontSize = ([pickerView selectedRowInComponent:0] + 1)*10
                    + [pickerView selectedRowInComponent:1];
    inputView.font = [UIFont systemFontOfSize:fontSize];
}


@end
