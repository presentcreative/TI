// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@interface AWhaleSpray : APageBasedAnimation
{
   CALayer* fLayer;
   CGFloat fFinalWidth;
   CGFloat fFinalHeight;
   BOOL fAnimationInProgress;
}

@property (nonatomic, retain) CALayer* layer;
@property (assign) CGFloat finalWidth;
@property (assign) CGFloat finalHeight;
@property (assign, getter = isAnimationInProgress) BOOL animationInProgress;

@end
