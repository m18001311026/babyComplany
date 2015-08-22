//
//  CreateViewController.m
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "CreateViewController.h"
#import "UIButtonExtra.h"

#import "MaterialView.h"
#import "ImageView.h"
#import "BackgroundTextView.h"

#import "MaterialTask.h"
#import "TaskQueue.h"

#import "Material.h"

@interface CreateViewController () {
    UIView *_menuBar;
    MaterialView *_materialZone;
    UIView *_operationZone;
    WhiteBoardView *_whiteBoard;
    CategoryView *_categoryView;
    TextEditView *_textEditView;
}

@property (nonatomic, assign) BackgroundTextView *bubbleView;
@property (nonatomic, assign) long categoryId;

@end


@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    self.delegate = nil;
    
    [_menuBar release]; _menuBar = nil;
    [_operationZone release]; _operationZone = nil;
    [_materialZone release]; _materialZone = nil;
    [_whiteBoard release]; _whiteBoard = nil;
    [_categoryView release]; _categoryView = nil;
    [_textEditView release]; _textEditView = nil;

    [super dealloc];
}

- (id)initWithDelegate:(id<CreateViewControllerDelegate>)delegate
            background:(UIImage *)image
                 index:(NSInteger)index {
    self = [super init];
    if (self) {
        // Custom initialization
        _delegate = delegate;
        _index = index;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        bbTopbar.backgroundColor = [Shared bbGray];
        bbTopbar.layer.shadowColor = [UIColor grayColor].CGColor;
        bbTopbar.layer.shadowOffset = CGSizeMake(0, 1);
        bbTopbar.layer.shadowOpacity = 1;
        
        UIButton *backBtn = [UIButton buttonWithCustomStyle:CustomButtonStyleBack2];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        backBtn.frame=CGRectMake(15, 7, 24, 33);
        [bbTopbar addSubview:backBtn];
        
        UIButton *doneBtn = [UIButton simpleButton:@"" y:2];
        doneBtn.frame = CGRectMake(270, 4, 24, 36);
        [doneBtn setImage:[UIImage imageNamed:@"finish.png"] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(createGallery) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:doneBtn];

        _whiteBoard = [[WhiteBoardView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - 88)
                                                 background:image];
        _whiteBoard.delegate = self;
        [self.view addSubview:_whiteBoard];
        
        [bbTopbar addSubview:[self getOperationZone]];
        [self.view addSubview:[self getMaterialZone]];
        
        _categoryView = [[CategoryView alloc] initWithFrame:CGRectMake(0, 40, 320, 364)];
        _categoryView.center = CGPointMake(160, (screentContentHeight)/2);
        _categoryView.delegate = self;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)getOperationZone {
    if (!_operationZone) {
        _operationZone = [[UIView alloc] initWithFrame:CGRectMake(44, 4, 226, 36)];
        _operationZone.backgroundColor = [UIColor clearColor];

        int posX = 0;
        
//        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        menuBtn.frame = CGRectMake(posX, 0, 50, 36);
//        menuBtn.backgroundColor = [UIColor lightGrayColor];
//        [menuBtn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
//        [menuBtn setTitle:@"菜单" forState:UIControlStateNormal];
//        [_operationZone addSubview:menuBtn];
//        
//        posX += 50;
        posX += 30;
        
        UIButton *categoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        categoryBtn.frame = CGRectMake(posX, 0, 24, 36);
        [categoryBtn addTarget:self action:@selector(showCategory) forControlEvents:UIControlEventTouchUpInside];
        [categoryBtn setTitle:@"素材" forState:UIControlStateNormal];
        [categoryBtn setImage:[UIImage imageNamed:@"picture.png"] forState:UIControlStateNormal];
        
        categoryBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_operationZone addSubview:categoryBtn];

        posX += 35;
        posX += 10+3;
        
        UIButton *textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        textBtn.frame = CGRectMake(posX, 0, 24, 36);
        [textBtn addTarget:self action:@selector(addText) forControlEvents:UIControlEventTouchUpInside];
        [textBtn setImage:[UIImage imageNamed:@"title.png"] forState:UIControlStateNormal];
        [_operationZone addSubview:textBtn];
        
        posX += 35+3;
        posX += 10;
        
        UIButton *upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        upBtn.frame = CGRectMake(posX, 0, 22, 36);
        [upBtn addTarget:self action:@selector(upLayer) forControlEvents:UIControlEventTouchUpInside];
        [upBtn setImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        [_operationZone addSubview:upBtn];
        
        posX += 35;
        posX += 10;
        
        UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        downBtn.frame = CGRectMake(posX, 0, 22, 36);
        [downBtn addTarget:self action:@selector(downLayer) forControlEvents:UIControlEventTouchUpInside];
        [downBtn setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
        [_operationZone addSubview:downBtn];
    }
    return _operationZone;
}

- (UIView *)getMaterialZone {
    if (!_materialZone) {
        _materialZone = [[MaterialView alloc] initWithFrame:CGRectMake(0, screentContentHeight - 45, 320, 46)];
        _materialZone.backgroundColor = [UIColor whiteColor];
        _materialZone.delegate = self;
        _materialZone.layer.shadowColor = [UIColor grayColor].CGColor;
        _materialZone.layer.shadowOffset = CGSizeMake(0, -1);
        _materialZone.layer.shadowOpacity = 1;
    }
    return _materialZone;
}

- (UIView *)getMenuBar {
    return nil;
}


#pragma ui event - common
- (void)back {
    [self.delegate newImageAdd:nil from:self originalIndex:0];
    [ctr popViewControllerAnimated:YES];
}

- (void)createGallery {
    if (![_whiteBoard hasView]) {
        [UI showAlert:@"请添加内容"];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(newImageAdd:from:originalIndex:)]) {
        [UIView animateWithDuration:1 animations:^{
            [_whiteBoard hideControl];
        } completion:^(BOOL finished) {
            [self.delegate newImageAdd:[_whiteBoard layoutImage] from:self originalIndex:self.index];
            [ctr popViewControllerAnimated:YES];
        }];
    }
}

- (void)showMenu {

}


#pragma ui event - menu
- (void)showCategory {
    if ([_categoryView superview]) {
        [_categoryView removeFromSuperview];
    } else {
        [self.view addSubview:_categoryView];
    }
}

- (void)addText {
    BackgroundTextView *bubbleView = [[BackgroundTextView alloc] init];
    bubbleView.frame = CGRectMake(0, 0, 300, 300);
    bubbleView.textView.text = @"";
    bubbleView.textView.userInteractionEnabled = NO;
    bubbleView.textView.font = [UIFont systemFontOfSize:12];
    [_whiteBoard addView:bubbleView];
    [bubbleView release];
}

- (void)upLayer {
    [_whiteBoard upSticker];
}

- (void)downLayer {
    [_whiteBoard downSticker];
}


#pragma mark category view
- (void)categoryTouched:(long)categoryId {
    if (self.categoryId != categoryId) {
        self.categoryId = categoryId;
        _materialZone.categoryId = categoryId;
        [_materialZone loadMaterials];
    }
    [_categoryView removeFromSuperview];
}


#pragma ui event - operation
//whiteboard view deleagte
- (void)stickerMoreTouched:(UIView *)contentView {
    if (![contentView isKindOfClass:[BackgroundTextView class]]) {
        return;
    }
    
    self.bubbleView = (BackgroundTextView *)contentView;
    
    if (!_textEditView) {
        _textEditView = [[TextEditView alloc] initWithFrame:CGRectMake(0, 0, 320, screentContentHeight)];
        _textEditView.delegate = self;
        _textEditView.layer.shadowColor = [UIColor grayColor].CGColor;
        _textEditView.layer.shadowOffset = CGSizeMake(0, -1);
        _textEditView.layer.shadowOpacity = 1;
    }
    
    [_textEditView setText:self.bubbleView.textView.text
                  andColor:self.bubbleView.textView.textColor
                   andSize:[self.bubbleView.textView.font pointSize]];
    [self.view addSubview:_textEditView];
    [_textEditView beginEdit];
}


#pragma ui event - material
- (void)selectMaterial:(long)materialId atIndex:(NSInteger)index {
    Material *m = [Material getMaterialWithId:materialId];
    if (m) {
        UIImage *image = [IMG getImageFromDisk:m.fodderPicture];
        if (image) {
            ImageView *imageView = [[ImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width/2, image.size.height/2)];
            [imageView setImage:image];
            [_whiteBoard addView:imageView];
            [imageView release];
        } else {
            ImageView *imageView = [[ImageView alloc] initWithFrame:CGRectZero];
            [imageView setImagePath:m.fodderPicture];
            [_whiteBoard addView:imageView];
            [imageView release];
        }
    }
}


#pragma text edit view delegate
- (void)textDidChange:(NSString *)newString {

}

- (void)textDidEndEdit:(NSString *)finalString fontSize:(int)size color:(UIColor *)color {
    self.bubbleView.textView.textColor = color;
    self.bubbleView.textView.text = finalString;
    self.bubbleView.textView.font = [UIFont systemFontOfSize:size];
    
    [_textEditView removeFromSuperview];
    
    self.bubbleView = nil;
}

@end
