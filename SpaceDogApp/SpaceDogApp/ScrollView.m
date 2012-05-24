// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ScrollView.h"
#import "Constants.h"

@implementation AScrollView

@synthesize leftScrollRegion=fLeftScrollRegion;
@synthesize rightScrollRegion=fRightScrollRegion;

#pragma mark -
#pragma mark UIScrollViewDelegate protocol


-(void)SwipeTimeoutEnded:(NSTimer*)timer
{
    fSwipeTimeout = NO;
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
    
    if(fSwipeTimeout)
        return result;
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
   
   // only allow a scroll if the gesture occurred in either the left of the right
   // "scroll region". Note that the location of the swipe has to be adjusted
   // to account for the current contentOffset of the scrollView
   CGPoint panLocation = [panRecognizer locationInView:self];
   
   NSUInteger pageNumber = self.contentOffset.x / kPageWidth;
   
   panLocation.x = panLocation.x - pageNumber * kPageWidth;
   
   if (CGRectContainsPoint(self.leftScrollRegion, panLocation)    ||
       CGRectContainsPoint(self.rightScrollRegion, panLocation))
   {
      result = YES;
       [NSTimer scheduledTimerWithTimeInterval:0.3 
                                        target:self 
                                      selector:@selector(SwipeTimeoutEnded:) 
                                      userInfo:nil 
                                       repeats:NO];
       fSwipeTimeout = YES;
   }
    
 
   
   return result;
}

@end
