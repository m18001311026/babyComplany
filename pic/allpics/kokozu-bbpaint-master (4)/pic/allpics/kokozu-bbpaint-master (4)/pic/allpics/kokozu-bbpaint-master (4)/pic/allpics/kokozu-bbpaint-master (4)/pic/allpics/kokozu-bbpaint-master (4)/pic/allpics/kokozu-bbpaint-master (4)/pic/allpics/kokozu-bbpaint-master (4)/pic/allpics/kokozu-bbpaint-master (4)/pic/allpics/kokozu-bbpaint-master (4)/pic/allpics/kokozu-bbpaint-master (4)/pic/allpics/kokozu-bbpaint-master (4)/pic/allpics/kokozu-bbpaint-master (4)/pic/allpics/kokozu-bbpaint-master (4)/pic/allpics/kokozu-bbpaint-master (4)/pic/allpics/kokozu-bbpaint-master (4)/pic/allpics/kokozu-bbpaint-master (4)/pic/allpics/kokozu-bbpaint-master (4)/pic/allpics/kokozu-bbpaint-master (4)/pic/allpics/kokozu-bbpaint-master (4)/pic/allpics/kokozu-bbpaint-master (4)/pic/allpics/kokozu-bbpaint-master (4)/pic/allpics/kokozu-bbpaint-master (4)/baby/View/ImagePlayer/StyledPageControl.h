//
//  PageControl.h
//  PageControlDemo
//
/**
 * Created by honcheng on 5/14/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com> http://twitter.com/honcheng
 * @copyright	2011	Muh Hon Cheng
 * 
 */

#import <UIKit/UIKit.h>

typedef enum
{
    PageControlStyleDefault = 0,
    PageControlStyleStrokedCircle = 1,
    PageControlStylePressed1 = 2,
    PageControlStylePressed2 = 3,
    PageControlStyleWithPageNumber = 4
} PageControlStyle;

@interface StyledPageControl : UIControl {
    NSInteger _currentPage, _numberOfPages;
    BOOL hidesForSinglePage;
    UIColor *coreNormalColor, *coreSelectedColor;
    UIColor *strokeNormalColor, *strokeSelectedColor;
    PageControlStyle _pageControlStyle;
    NSInteger _strokeWidth, diameter, gapWidth;
}

@property (nonatomic, strong) UIColor *coreNormalColor, *coreSelectedColor;
@property (nonatomic, strong) UIColor *strokeNormalColor, *strokeSelectedColor;
@property (nonatomic, assign) NSInteger _currentPage, _numberOfPages;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) PageControlStyle _pageControlStyle;
@property (nonatomic, assign) NSInteger _strokeWidth, diameter, gapWidth;

- (void)setCurrentPage:(NSInteger)page;
- (NSInteger)currentPage;
- (void)setNumberOfPages:(NSInteger)numOfPages;
- (NSInteger)numberOfPages;
- (PageControlStyle)pageControlStyle;
- (void)setPageControlStyle:(PageControlStyle)style;

@end
