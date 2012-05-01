// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "CALayer+CustomAnimation.h"


@implementation CALayer (CustomAnimation)

-(BOOL)animationsPaused
{
   // climb the layer hierarchy, if required
   CALayer* uberLayer = self;
   
   while (nil != uberLayer.superlayer)
   {
      uberLayer = uberLayer.superlayer;
   }
   
   return 0.0f == uberLayer.speed;
}

@end
