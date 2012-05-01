// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ChipmunkBody;
@class ChipmunkShape;

@class ASoundEffect;
@class ATrigger;

@interface ASign : APhysicsEngineBasedAnimation
{
   CALayer* fLayer;

   ASoundEffect* fSoundEffect;

   ATrigger* fTiltTrigger;
   ATrigger* fShakeTrigger;

   ChipmunkBody*  fSignBody;
   ChipmunkShape* fSignShape;
}

@property (nonatomic, retain) CALayer* layer;
@property (nonatomic, retain) ASoundEffect* soundEffect;
@property (nonatomic, retain) ATrigger* tiltTrigger;
@property (nonatomic, retain) ATrigger* shakeTrigger;

@end

