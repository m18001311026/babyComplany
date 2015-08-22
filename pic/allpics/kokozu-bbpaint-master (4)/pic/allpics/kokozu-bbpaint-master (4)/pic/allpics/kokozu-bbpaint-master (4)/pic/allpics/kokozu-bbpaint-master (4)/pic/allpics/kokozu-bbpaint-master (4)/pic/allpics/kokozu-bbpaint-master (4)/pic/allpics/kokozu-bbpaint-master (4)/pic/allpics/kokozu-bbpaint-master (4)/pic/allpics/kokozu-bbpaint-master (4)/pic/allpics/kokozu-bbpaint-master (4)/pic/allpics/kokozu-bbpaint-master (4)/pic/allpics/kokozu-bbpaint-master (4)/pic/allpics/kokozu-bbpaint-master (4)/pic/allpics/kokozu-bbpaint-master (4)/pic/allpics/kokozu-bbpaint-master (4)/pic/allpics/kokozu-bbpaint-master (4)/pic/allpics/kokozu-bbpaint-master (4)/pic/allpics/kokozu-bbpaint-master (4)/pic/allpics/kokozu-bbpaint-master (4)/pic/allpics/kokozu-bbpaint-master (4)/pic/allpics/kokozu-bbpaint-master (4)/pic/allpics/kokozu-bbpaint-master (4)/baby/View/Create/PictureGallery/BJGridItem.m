//
//  BJGridItem.m
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BJGridItem.h"


@interface BJGridItem()

@property (nonatomic, retain) UIButton *deleteButton;
@property (nonatomic, retain) UIButton *button;

@end


@implementation BJGridItem

- (void)dealloc {
    self.deleteButton = nil;
    self.button = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
              image:(UIImage *)image
            atIndex:(NSInteger)aIndex
           editable:(BOOL)removable {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.isEditing = NO;
        self.index = aIndex;
        self.isRemovable = removable;
        
        //place a clickable button on top of everything
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.button.layer.borderColor = [UIColor grayColor].CGColor;
        self.button.layer.borderWidth = 1;
        self.button.imageView.clipsToBounds = YES;
        [self.button setFrame:self.bounds];
        if (image) {
            //[self.button setBackgroundImage:image forState:UIControlStateNormal];
            [self.button setImage:image forState:UIControlStateNormal];
        }
        [self.button setBackgroundColor:[UIColor clearColor]];
        [self.button setTitle:title forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
        longPress.minimumPressDuration = 0.2f;
        [self addGestureRecognizer:longPress];
        [longPress release];
        
        if (self.isRemovable) {
            self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.deleteButton setFrame:CGRectMake(0, 0, 20, 20)];
            [self.deleteButton setImage:[UIImage imageNamed:@"deletbutton.png"] forState:UIControlStateNormal];
            self.deleteButton.backgroundColor = [UIColor clearColor];
            [self.deleteButton addTarget:self action:@selector(removeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.deleteButton setHidden:YES];
            [self addSubview:self.deleteButton];
        }
    }
    return self;
}


#pragma mark - UI actions
- (UIImage *)image {
//    return [self.button backgroundImageForState:UIControlStateNormal];
    return [self.button imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
//    [self.button setBackgroundImage:image forState:UIControlStateNormal];
    [self.button setImage:image forState:UIControlStateNormal];
}

- (void)clickItem:(id)sender {
    [self.delegate gridItemDidClicked:self];
}

- (void)pressedLong:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            point = [gestureRecognizer locationInView:self];
            [self.delegate gridItemDidEnterEditingMode:self];
            //放大这个item
            [self setAlpha:1.0];
            NSLog(@"press long began");
            break;
        case UIGestureRecognizerStateEnded:
            point = [gestureRecognizer locationInView:self];
            [self.delegate gridItemDidEndMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];
            //变回原来大小
            [self setAlpha:0.5f];
            NSLog(@"press long ended");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"press long failed");
            break;
        case UIGestureRecognizerStateChanged:
            //移动
            [self.delegate gridItemDidMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];
            NSLog(@"press long changed");
            break;
        default:
            NSLog(@"press long else");
            break;
    }
    
    //CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
}

- (void)removeButtonClicked:(id)sender {
    [self.delegate gridItemDidDeleted:self atIndex:self.index];
}


#pragma mark - Custom Methods
- (void)enableEditing {
    
    if (self.isEditing == YES)
        return;
    
    // put item in editing mode
    self.isEditing = YES;
    
    // make the remove button visible
    [self.deleteButton setHidden:NO];
    [self.button setEnabled:NO];
    // start the wiggling animation
//    CGFloat rotation = 0.03;
    
//    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
//    shake.duration = 0.13;
//    shake.autoreverses = YES;
//    shake.repeatCount  = MAXFLOAT;
//    shake.removedOnCompletion = NO;
//    shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-rotation, 0.0 ,0.0 ,1.0)];
//    shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
//    
//    [self.layer addAnimation:shake forKey:@"shakeAnimation"];
    
    // inform the springboard that the menu items are now editable so that the springboard
    // will place a done button on the navigationbar 
    //[(SESpringBoard *)self.delegate enableEditingMode];
    
}

- (void)disableEditing {
//    [self.layer removeAnimationForKey:@"shakeAnimation"];
    [self.deleteButton setHidden:YES];
    [self.button setEnabled:YES];
    self.isEditing = NO;
}


//# pragma mark - Overriding UiView Methods
- (void)removeFromSuperviewAnimated {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
        [self setFrame:CGRectMake(self.frame.origin.x+50, self.frame.origin.y+50, 0, 0)];
        [self.deleteButton setFrame:CGRectMake(0, 0, 0, 0)];
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

@end
