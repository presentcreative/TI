// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ASoundEffect;
@class ChipmunkBody;
@class ChipmunkShape;

@interface ACups : APhysicsEngineBasedAnimation
{
   NSString* fSoundEffect;
   
   CGFloat fLeftCupLastAngle;
   CGFloat fRightCupLastAngle;
   
   ChipmunkBody*  fLeftCupBody;
   ChipmunkShape* fLeftCupShape;
   
   ChipmunkBody*  fRightCupBody;
   ChipmunkShape* fRightCupShape;
   
   CGPoint fLeftCupAnchorPoint;
   CGPoint fRightCupAnchorPoint;
}

@property (readonly) UIImageView* leftCupView;
@property (readonly) UIImageView* rightCupView;
@property (assign) CGFloat leftCupLastAngle;
@property (assign) CGFloat rightCupLastAngle;
@property (copy) NSString* soundEffect;

@end
