// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@class APositionAnimation;
@class ATextureAtlasBasedSequence;

@interface ABobbingPainter : APageBasedAnimation
{
   CALayer* fBobbingShipLayer;

   ATextureAtlasBasedSequence* fPainterAnimation;
   APositionAnimation* fBobbingShipAnimation;
}

@property (nonatomic, retain) CALayer* bobbingShipLayer;

@property (nonatomic, retain) ATextureAtlasBasedSequence* painterAnimation;
@property (nonatomic, retain) APositionAnimation* bobbingShipAnimation;

@end
