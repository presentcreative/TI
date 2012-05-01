// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ChipmunkBody;
@class ChipmunkShape;

@interface ACoins : APhysicsEngineBasedAnimation <UIGestureRecognizerDelegate>
{
   ChipmunkBody*  fCoin1Body;
   ChipmunkShape* fCoin1Shape;
   
   ChipmunkBody*  fCoin2Body;
   ChipmunkShape* fCoin2Shape;
   
   ChipmunkBody*  fCoin3Body;
   ChipmunkShape* fCoin3Shape;
   
   ChipmunkBody*  fCoin4Body;
   ChipmunkShape* fCoin4Shape;
   
   ChipmunkBody*  fCoin5Body;
   ChipmunkShape* fCoin5Shape;
}

@property (nonatomic, retain) NSTimer* physicsTimer;
@property (nonatomic, retain) ChipmunkBody* coin1Body;
@property (nonatomic, retain) ChipmunkShape* coin1Shape;
@property (nonatomic, retain) ChipmunkBody* coin2Body;
@property (nonatomic, retain) ChipmunkShape* coin2Shape;
@property (nonatomic, retain) ChipmunkBody* coin3Body;
@property (nonatomic, retain) ChipmunkShape* coin3Shape;
@property (nonatomic, retain) ChipmunkBody* coin4Body;
@property (nonatomic, retain) ChipmunkShape* coin4Shape;
@property (nonatomic, retain) ChipmunkBody* coin5Body;
@property (nonatomic, retain) ChipmunkShape* coin5Shape;

@property (readonly) UIImageView* coin1ImageView;
@property (readonly) UIImageView* coin2ImageView;
@property (readonly) UIImageView* coin3ImageView;
@property (readonly) UIImageView* coin4ImageView;
@property (readonly) UIImageView* coin5ImageView;

@end
