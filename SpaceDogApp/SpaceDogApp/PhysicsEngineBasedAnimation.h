// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@class ChipmunkSpace;

@interface APhysicsEngineBasedAnimation : APageBasedAnimation <UIAccelerometerDelegate>
{
   ChipmunkSpace* fPhysicsSpace;
   
   BOOL fAnimating;
   
   // pretty simplistic here: we're only supporting sound effects for 
   // object-object collisions and object-wall collision
   NSString* fObjectObjectCollisionSoundEffect;
   BOOL fHasObjectObjectCollisionSoundEffect;
   
   NSString* fObjectWallCollisionSoundEffect;
   BOOL fHasObjectWallCollisionSoundEffect;
    
    CGFloat fPrevX;
    CGFloat fPrevY;
    CGFloat fPrevZ;

}

@property (nonatomic, retain) ChipmunkSpace* physicsSpace;
@property (assign, getter = isAnimating) BOOL animating;
@property (copy) NSString* objectObjectCollisionSoundEffect;
@property (assign) BOOL hasObjectObjectCollisionSoundEffect;
@property (copy) NSString* objectWallCollisionSoundEffect;
@property (assign) BOOL hasObjectWallCollisionSoundEffect;

@property (readonly) CGPoint gravityVector;
@property (readonly) CGFloat globalDamping;

@property (assign) CGFloat prevX;
@property (assign) CGFloat prevY;
@property (assign) CGFloat prevZ;


-(void)SetupPhysics;
-(void)StartPhysics;
-(void)StopPhysics;
-(void)AnimatePhysics;

-(void)InitializeCollisionDetection;
-(void)AcknowledgeObjectObjectCollision;
-(void)AcknowledgeObjectObjectCollisionWithVolume:(CGFloat)volume;
-(void)AcknowledgeObjectWallCollision;
-(void)AcknowledgeObjectWallCollisionWithVolume:(CGFloat)volume;

// miscellaneous config
#define kDefaultGlobalDamping 0.75f

// identifies objects and walls w.r.t. collision detection
#define kObject @"object"
#define kWall   @"wall"

// 
@property (readonly) BOOL gravityFollowsAccelerometer;

#define kGravityVectorPortrait            CGPointMake(-500.0f, 0.0f)     // portrait orientation, Home button down
#define kGravityVectorPortraitUpsideDown  CGPointMake(500.0f, 0.0f)    // portrait orientation, Home button up
#define kGravityVectorLandscapeLeft       CGPointMake(0.0f, -500.0f)    // landscape orientation, Home button right
#define kGravityVectorLandscapeRight      CGPointMake(0.0f, 500.0f)     // landscape orientation, Home button left
#define kDefaultGravityVector             kGravityVectorLandscapeRight

@end
