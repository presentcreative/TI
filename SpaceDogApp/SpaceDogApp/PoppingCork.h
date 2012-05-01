// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@interface APoppingCork : APageBasedAnimation
{
   BOOL fAnimationFired;
}

@property (assign, getter = hasAnimationFired) BOOL animationFired;

@end
