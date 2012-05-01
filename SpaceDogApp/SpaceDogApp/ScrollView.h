// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <UIKit/UIKit.h>

@interface AScrollView : UIScrollView <UIGestureRecognizerDelegate>
{
   CGRect fLeftScrollRegion;
   CGRect fRightScrollRegion;
}

@property (assign) CGRect leftScrollRegion;
@property (assign) CGRect rightScrollRegion;

@end
