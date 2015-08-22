//
//  BUPOViewController.m
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import "BUPOView.h"


#define NUM_OF_COLS 4
#define NUM_OF_ROWS 3
#define ITEM_PER_PAGE 8
#define MAX_ITEMS 9
#define SPACE 10
#define GRID_HEIGHT 68
#define GRID_WIDTH 68
#define unValidIndex  -1


@interface BUPOView (private)

-(NSInteger)indexOfLocation:(CGPoint)location;
-(CGPoint)orginPointOfIndex:(NSInteger)index;
-(void) exchangeItem:(NSInteger)oldIndex withposition:(NSInteger)newIndex;

@end


@implementation BUPOView

#pragma mark - View lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        page = 0;
        isEditing = NO;
        gridItems = [[NSMutableArray alloc] initWithCapacity:0];
        
        UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        self.scrollview = scrollview;
        [self addSubview:scrollview];
        scrollview.delegate = self;
        [scrollview setPagingEnabled:YES];
        [scrollview release];
        
        addbutton = [[BJGridItem alloc] initWithFrame:CGRectMake(SPACE, SPACE, GRID_WIDTH, GRID_HEIGHT)
                                                title:@"+"
                                                image:[UIImage imageNamed:@""]
                                              atIndex:0
                                             editable:NO];
        addbutton.delegate = self;
        [scrollview addSubview:addbutton];
        [gridItems addObject:addbutton];
        [addbutton release];
        
        singletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singletap setNumberOfTapsRequired:1];
        singletap.delegate = self;
        [scrollview addGestureRecognizer:singletap];
        [singletap release];
        
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.scrollview = nil;
    [gridItems release];
    
    [super dealloc];
}


#pragma mark-- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.frame;
    frame.origin.x = preFrame.origin.x + (preX - scrollView.contentOffset.x)/10;
    if (frame.origin.x <= 0 && frame.origin.x > scrollView.frame.size.width - frame.size.width ) {
        self.frame = frame;
    }
    NSLog(@"offset:%f",(scrollView.contentOffset.x - preX));
    NSLog(@"origin.x:%f",frame.origin.x);
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    preX = scrollView.contentOffset.x;
    preFrame = self.frame;
    NSLog(@"prex:%f",preX);
}

- (void)resetAddButton {
    long addIndex = addbutton.index;
    long finalIndex = gridItems.count - 1;
    if (addIndex != finalIndex) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect addFrame = addbutton.frame;
            CGRect lastFrame = ((BJGridItem *)[gridItems lastObject]).frame;
            ((BJGridItem *)[gridItems lastObject]).frame = addFrame;
            addbutton.frame = lastFrame;
            [self exchangeItem:addIndex withposition:finalIndex];
        }];
    }
}

- (void)addImage:(UIImage *)image {
    CGRect frame = CGRectMake(SPACE, SPACE, GRID_WIDTH, GRID_HEIGHT);
    long n = [gridItems count];
    long row = (n-1) / NUM_OF_COLS;
    long col = (n-1) % NUM_OF_COLS;
    long curpage = (n-1) / ITEM_PER_PAGE;
    row = row % 3;
    if (n >= MAX_ITEMS) {
        NSLog(@"不能创建更多页面");
    } else {
        frame.origin.x = frame.origin.x + frame.size.width * col + SPACE * col + self.scrollview.frame.size.width * curpage;
        frame.origin.y = frame.origin.y + frame.size.height * row + SPACE * row;
        
        BJGridItem *gridItem = [[BJGridItem alloc] initWithFrame:frame
                                                           title:[NSString stringWithFormat:@"%ld",n-1]
                                                           image:image
                                                         atIndex:n-1
                                                        editable:YES];
        //gridItem.tag = tag;
        [gridItem setAlpha:0.5];
        gridItem.delegate = self;
        [self.scrollview addSubview:gridItem];
        [gridItems insertObject:gridItem atIndex:n-1];
        [gridItem release];

        //move the add button
        row = n / NUM_OF_COLS;
        col = n % NUM_OF_COLS;
        curpage = n / ITEM_PER_PAGE;
        row = row % 3;
        frame = CGRectMake(SPACE, SPACE, GRID_WIDTH, GRID_HEIGHT);
        frame.origin.x = frame.origin.x + frame.size.width * col + SPACE * col + self.scrollview.frame.size.width * curpage;
        frame.origin.y = frame.origin.y + frame.size.height * row + SPACE * row;
        NSLog(@"add button col:%ld, row:%ld, page:%ld", col, row, curpage);
//        [self.scrollview setContentSize:CGSizeMake(
//                                              self.scrollview.frame.size.width * (curpage + 1),
//                                              self.scrollview.frame.size.height)];
//        [self.scrollview scrollRectToVisible:CGRectMake(
//                                            self.scrollview.frame.size.width * curpage,
//                                            self.scrollview.frame.origin.y,
//                                            self.scrollview.frame.size.width,
//                                            self.scrollview.frame.size.height) animated:NO];
        [UIView animateWithDuration:0.2f animations:^{
            [addbutton setFrame:frame];
        }];
        addbutton.index += 1;
    }
}

- (void)setImage:(UIImage *)image forIndex:(NSInteger)index {
    for (BJGridItem *item in gridItems) {
        if (item.index == index) {
            [item setImage:image];
        }
    }
}

- (NSArray *)images {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (BJGridItem *item in gridItems) {
        if (item != addbutton) {
            [images addObject:item.image];
        }
    }
    return [images autorelease];
}


#pragma mark-- BJGridItemDelegate
- (void)gridItemDidClicked:(BJGridItem *)gridItem {
    NSLog(@"grid at index %ld did clicked", (long)gridItem.index);
    if (gridItem == addbutton) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(addButtonTouched)]) {
            [self.delegate addButtonTouched];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(touchedAtImage:index:)]) {
            [self.delegate touchedAtImage:gridItem.image index:gridItem.index];
        }
    }
}

- (void)gridItemDidDeleted:(BJGridItem *)gridItem atIndex:(NSInteger)index {
    NSLog(@"grid at index %ld did deleted",(long)gridItem.index);
    BJGridItem *item = [gridItems objectAtIndex:index];

    [gridItems removeObjectAtIndex:index];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect lastFrame = item.frame;
        [item removeFromSuperviewAnimated];

        CGRect curFrame;
        for (long i = index; i < [gridItems count]; i++) {
            BJGridItem *temp = [gridItems objectAtIndex:i];
            curFrame = temp.frame;
            [temp setFrame:lastFrame];
            lastFrame = curFrame;
            [temp setIndex:i];
        }
        
        //[addbutton setFrame:lastFrame];
    }];
}

- (void)gridItemDidEnterEditingMode:(BJGridItem *)gridItem {
    for (BJGridItem *item in gridItems) {
        [item enableEditing];
    }
    //[addbutton enableEditing];
    isEditing = YES;
}

- (void)quitEditMode {
    if (isEditing) {
        for (BJGridItem *item in gridItems) {
            [item disableEditing];
        }
        [addbutton disableEditing];
    }
    isEditing = NO;
}

- (void)gridItemDidMoved:(BJGridItem *)gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    CGPoint _point = [recognizer locationInView:self.scrollview];
    NSInteger toIndex = [self indexOfLocation:_point];
    
    CGRect frame = gridItem.frame;
    //CGPoint pointInView = [recognizer locationInView:self];
    frame.origin.x = _point.x - point.x;
    frame.origin.y = _point.y - point.y;
    gridItem.frame = frame;
    DLog(@"gridItemframe:%f,%f", frame.origin.x, frame.origin.y);
    DLog(@"move to point(%f,%f)", point.x, point.y);
    
    NSInteger fromIndex = gridItem.index;
    DLog(@"fromIndex:%ld toIndex:%ld",(long)fromIndex, (long)toIndex);
    
    if (toIndex != unValidIndex && toIndex != fromIndex) {
        BJGridItem *moveItem = [gridItems objectAtIndex:toIndex];
        [self.scrollview sendSubviewToBack:moveItem];
        [UIView animateWithDuration:0.2 animations:^{
            CGPoint origin = [self orginPointOfIndex:fromIndex];
            //NSLog(@"origin:%f,%f",origin.x,origin.y);
            moveItem.frame = CGRectMake(origin.x, origin.y, moveItem.frame.size.width, moveItem.frame.size.height); 
        }];
        [self exchangeItem:fromIndex withposition:toIndex];
        //移动
    }
    //翻页
//    if (pointInView.x >= self.scrollview.frame.size.width - MAX_ITEMS) {
//        [self.scrollview scrollRectToVisible:CGRectMake(
//                                                        self.scrollview.contentOffset.x + self.scrollview.frame.size.width,
//                                                        0,
//                                                        self.scrollview.frame.size.width,
//                                                        self.scrollview.frame.size.height) animated:YES];
//    } else if (pointInView.x < MAX_ITEMS) {
//        [self.scrollview scrollRectToVisible:CGRectMake(
//                                                        self.scrollview.contentOffset.x - self.scrollview.frame.size.width,
//                                                        0,
//                                                        self.scrollview.frame.size.width,
//                                                        self.scrollview.frame.size.height) animated:YES];
//    }
    [self quitEditMode];
}

- (void)gridItemDidEndMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*) recognizer {
    CGPoint _point = [recognizer locationInView:self.scrollview];
    NSInteger toIndex = [self indexOfLocation:_point];
    
    if (toIndex == unValidIndex) {
        toIndex = gridItem.index;
    }
    CGPoint origin = [self orginPointOfIndex:toIndex];
    [UIView animateWithDuration:0.2 animations:^{
        gridItem.frame = CGRectMake(origin.x, origin.y, gridItem.frame.size.width, gridItem.frame.size.height);
    }];
    
    NSLog(@"gridItem index:%ld", (long)gridItem.index);
    
    [self resetAddButton];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (isEditing) {
        for (BJGridItem *item in gridItems) {
            [item disableEditing];
        }
        [addbutton disableEditing];
    }
    isEditing = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(touch.view != self.scrollview) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark-- private
- (NSInteger)indexOfLocation:(CGPoint)location {
    NSInteger index;
    NSInteger _page = location.x / self.scrollview.frame.size.width;
    NSInteger row =  location.y / (GRID_HEIGHT + SPACE);
    NSInteger col = (location.x - _page * self.scrollview.frame.size.width) / (GRID_WIDTH + SPACE);
    if (row >= NUM_OF_ROWS || col >= NUM_OF_COLS) {
        return  unValidIndex;
    }
    index = ITEM_PER_PAGE * _page + row * NUM_OF_COLS + col;
    if (index >= [gridItems count]) {
        return  unValidIndex;
    }
    
    return index;
}

- (CGPoint)orginPointOfIndex:(NSInteger)index {
    CGPoint point = CGPointZero;
    if (index > [gridItems count] || index < 0) {
        return point;
    }else{
        NSInteger _page = index / ITEM_PER_PAGE;
        NSInteger row = (index - _page * ITEM_PER_PAGE) / NUM_OF_COLS;
        NSInteger col = (index - _page * ITEM_PER_PAGE) % NUM_OF_COLS;
        
        point.x = _page * self.scrollview.frame.size.width + col * GRID_WIDTH + (col +1) * SPACE;
        point.y = row * GRID_HEIGHT + (row + 1) * SPACE;
        return  point;
    }
}

- (void)exchangeItem:(NSInteger)oldIndex withposition:(NSInteger)newIndex {
    ((BJGridItem *)[gridItems objectAtIndex:oldIndex]).index = newIndex;
    ((BJGridItem *)[gridItems objectAtIndex:newIndex]).index = oldIndex;
    [gridItems exchangeObjectAtIndex:oldIndex withObjectAtIndex:newIndex];
}


@end


