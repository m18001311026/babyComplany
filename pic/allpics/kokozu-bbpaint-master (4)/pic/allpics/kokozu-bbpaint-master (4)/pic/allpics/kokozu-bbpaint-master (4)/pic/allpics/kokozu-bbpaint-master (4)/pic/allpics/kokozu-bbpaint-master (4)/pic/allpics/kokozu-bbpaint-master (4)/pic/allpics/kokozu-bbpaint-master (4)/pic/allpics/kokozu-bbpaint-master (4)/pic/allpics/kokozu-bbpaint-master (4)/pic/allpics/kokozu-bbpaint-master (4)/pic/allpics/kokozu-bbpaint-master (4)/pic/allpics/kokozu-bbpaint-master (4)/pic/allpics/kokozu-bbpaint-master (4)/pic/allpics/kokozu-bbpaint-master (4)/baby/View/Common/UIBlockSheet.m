//
//  UIBlockSheet.m
//  baby
//
//  Created by zhang da on 14-6-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UIBlockSheet.h"

@implementation UIBlockSheet

- (id)initWithTitle:(NSString *) title {
    self = [super init];
    if (self) {
        /* Initialize the sheet */
        _sheet = [[UIActionSheet alloc] initWithTitle: title delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles: nil];
        
        /* Initialize button -> block array */
        _blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    _sheet.delegate = nil;
    [_sheet release];
    
    [_blocks release];
    
    [super dealloc];
}


- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block {
    [self addButtonWithTitle: title block: block];
    _sheet.cancelButtonIndex = _sheet.numberOfButtons - 1;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    [_blocks addObject: [[block copy] autorelease]];
    [_sheet addButtonWithTitle: title];
}

- (void)showInView:(UIView *)view {
    [_sheet showInView: view];
    
    /* Ensure that the delegate (that's us) survives until the sheet is dismissed */
    [self retain];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    /* Run the button's block */
    if (buttonIndex >= 0 && buttonIndex < [_blocks count]) {
        void (^b)() = [_blocks objectAtIndex: buttonIndex];
        b();
    }
    
    /* Sheet to be dismissed, drop our self reference */
    [self release];
}

@end
