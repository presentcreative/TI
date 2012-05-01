// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface ATopCloud : APageBasedAnimation
{
   CALayer* fLayer;
   CGFloat fMinX;
   CGFloat fMaxX;
   CGFloat fStepMin;
   CGFloat fStepMax;
   CGFloat fStepDuration;
}

@property (nonatomic, retain) CALayer* layer;
@property (assign) CGFloat minX;
@property (assign) CGFloat maxX;

@property (assign) CGFloat stepMin;
@property (assign) CGFloat stepMax;
@property (assign) CGFloat stepDuration;

@end
