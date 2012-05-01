// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ChipmunkBody;
@class ChipmunkShape;

@interface AVines : APhysicsEngineBasedAnimation <UIGestureRecognizerDelegate>
{
   ChipmunkBody*  fLeftVineBody;
   ChipmunkShape* fLeftVineShape;
   ChipmunkBody*  fRightVineBody;
   ChipmunkShape* fRightVineShape;
   
   CGRect         fLeftVineSwipeableFrame;
   CGRect         fRightVineSwipeableFrme;
}

@property (nonatomic, retain) ChipmunkBody* leftVineBody;
@property (nonatomic, retain) ChipmunkShape* leftVineShape;
@property (nonatomic, retain) ChipmunkBody* rightVineBody;
@property (nonatomic, retain) ChipmunkShape* rightVineShape;

@property (assign) CGRect leftVineSwipeableFrame;
@property (assign) CGRect rightVineSwipeableFrame;

@property (readonly) UIImageView* leftVineImageView;
@property (readonly) UIImageView* rightVineImageView;

@end
