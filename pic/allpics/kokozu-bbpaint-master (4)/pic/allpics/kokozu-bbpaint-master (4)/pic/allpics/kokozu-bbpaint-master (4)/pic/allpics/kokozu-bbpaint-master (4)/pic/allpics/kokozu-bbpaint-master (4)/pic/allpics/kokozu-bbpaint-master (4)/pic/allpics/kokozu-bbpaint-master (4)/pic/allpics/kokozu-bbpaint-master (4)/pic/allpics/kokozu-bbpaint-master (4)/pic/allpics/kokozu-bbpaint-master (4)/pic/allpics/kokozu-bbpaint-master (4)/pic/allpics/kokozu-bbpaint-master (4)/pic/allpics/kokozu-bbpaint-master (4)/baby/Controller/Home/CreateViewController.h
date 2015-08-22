//
//  CreateViewController.h
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "BBViewController.h"
#import "MaterialView.h"
#import "WhiteBoardView.h"
#import "TextEditView.h"
#import "CategoryView.h"


@class CreateViewController;

@protocol CreateViewControllerDelegate <NSObject>

- (void)newImageAdd:(UIImage *)image from:(CreateViewController *)ctr originalIndex:(NSInteger)index;

@end


@interface CreateViewController : BBViewController
<MaterialViewDelegate, WhiteBoardViewDelegate, TextEditViewDelegate, CategoryViewDelegate>

@property (nonatomic, assign) id<CreateViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger index;

- (id)initWithDelegate:(id<CreateViewControllerDelegate>)delegate
            background:(UIImage *)image
                 index:(NSInteger)index;

@end
