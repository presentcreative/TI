// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@class APositionAnimation;

@interface ASmollet : APageBasedAnimation
{
   CALayer* fSmolletLayer;
   APositionAnimation* fHatLayerAnimation;
   
   CGFloat fxDelta;
   CGFloat fyDelta;
   CGFloat fDuration;
   
   CGPoint fOriginalPosition;
}

@property (nonatomic, retain) CALayer* smolletLayer;
@property (nonatomic, retain) APositionAnimation* hatLayerAnimation;
@property (assign) CGFloat xDelta;
@property (assign) CGFloat yDelta;
@property (assign) CGFloat duration;
@property (assign) CGPoint originalPosition;

@end
