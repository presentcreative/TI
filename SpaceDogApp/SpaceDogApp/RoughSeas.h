// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@class APositionAnimation;

@interface ARoughSeas : APageBasedAnimation
{
   CALayer* fBorderLayer;
   CALayer* fShipLayer;
   CALayer* fSeaLayer;
   
   APositionAnimation* fSeaLayerAnimation;
   
}

@property (nonatomic, retain) CALayer* borderLayer;
@property (nonatomic, retain) CALayer* shipLayer;
@property (nonatomic, retain) CALayer* seaLayer;

@property (nonatomic, retain) APositionAnimation* seaLayerAnimation;

@end
