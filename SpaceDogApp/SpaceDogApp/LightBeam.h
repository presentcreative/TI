// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@class AParticleEffect;

@interface ALightBeam : APageBasedAnimation
{
   AParticleEffect* fLightBeamAnimation;
   
   CALayer* fBeamLayer;
}

@property (nonatomic, retain) AParticleEffect* lightBeamAnimation;
@property (nonatomic, retain) CALayer* beamLayer;

@end
