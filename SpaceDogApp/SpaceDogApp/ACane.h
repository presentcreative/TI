// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ASoundEffect;
@class ChipmunkBody;
@class ChipmunkShape;

@interface ACane : APhysicsEngineBasedAnimation <UIGestureRecognizerDelegate>
{   
   ChipmunkBody*  fCaneBody;
   ChipmunkShape* fCaneShape;
}

@property (readonly) UIImageView* caneView;

@end
