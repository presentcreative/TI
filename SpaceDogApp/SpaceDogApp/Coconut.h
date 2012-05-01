// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ChipmunkBody;
@class ChipmunkShape;

@interface ACoconut : APhysicsEngineBasedAnimation <UIGestureRecognizerDelegate>
{
   ChipmunkBody*  fCoconut1Body;
   ChipmunkShape* fCoconut1Shape;
   
   ChipmunkBody*  fCoconut2Body;
   ChipmunkShape* fCoconut2Shape;
   
   ChipmunkBody*  fCoconut3Body;
   ChipmunkShape* fCoconut3Shape;
}

@property (nonatomic, retain) ChipmunkBody* coconut1Body;
@property (nonatomic, retain) ChipmunkShape* coconut1Shape;
@property (nonatomic, retain) ChipmunkBody* coconut2Body;
@property (nonatomic, retain) ChipmunkShape* coconut2Shape;
@property (nonatomic, retain) ChipmunkBody* coconut3Body;
@property (nonatomic, retain) ChipmunkShape* coconut3Shape;

@property (readonly) UIImageView* coconut1ImageView;
@property (readonly) UIImageView* coconut2ImageView;
@property (readonly) UIImageView* coconut3ImageView;

@end
