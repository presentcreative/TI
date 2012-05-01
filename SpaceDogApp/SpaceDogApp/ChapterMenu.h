// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface AChapterMenu : APageBasedAnimation 
{   
   CGRect  fScrollToggleHotspot;
   CGFloat fScrollTopMinY;
   CGFloat fScrollTopMaxY;
      
   NSUInteger fSelectedChapter;
}

@property (assign) CGRect scrollToggleHotspot;
@property (assign) CGFloat scrollTopMinY;
@property (assign) CGFloat scrollTopMaxY;

@property (readonly) UIImageView* scrollTop;
@property (readonly) UIImageView* scrollBottom;
@property (readonly) UIImageView* scrollBack;

@property (readonly) UIScrollView* scroller;

@property (assign) NSUInteger selectedChapter;

@end
