// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ASoundEffect;
@class ChipmunkBody;
@class ChipmunkShape;

@interface ALantern : APhysicsEngineBasedAnimation
{
   CALayer* fLayer;
   NSString* fSoundEffect;
   CGFloat fLastAngle;
   
   ChipmunkBody*  fLanternBody;
   ChipmunkShape* fLanternShape;
   
   CGPoint fAnchorPoint;
}

@property (nonatomic, retain) CALayer* layer;
@property (assign) CGFloat lastAngle;
@property (copy) NSString* soundEffect;

@end
