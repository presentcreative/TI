// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ChipmunkBody;
@class ChipmunkShape;

@interface ALeaves : APhysicsEngineBasedAnimation <UIGestureRecognizerDelegate>
{   
   ChipmunkBody*  fLeaf1Body;
   ChipmunkShape* fLeaf1Shape;   
   
   ChipmunkBody*  fLeaf2Body;
   ChipmunkShape* fLeaf2Shape; 
   
   ChipmunkBody*  fLeaf3Body;
   ChipmunkShape* fLeaf3Shape; 
}

@property (nonatomic, retain) ChipmunkBody*  leaf1Body;
@property (nonatomic, retain) ChipmunkShape* leaf1Shape;

@property (nonatomic, retain) ChipmunkBody*  leaf2Body;
@property (nonatomic, retain) ChipmunkShape* leaf2Shape;

@property (nonatomic, retain) ChipmunkBody*  leaf3Body;
@property (nonatomic, retain) ChipmunkShape* leaf3Shape;

@property (readonly) UIImageView* leaf1ImageView;
@property (readonly) UIImageView* leaf2ImageView;
@property (readonly) UIImageView* leaf3ImageView;

@end
