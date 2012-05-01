// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"
#import "ObjectiveChipmunk.h"
#import "OALSimpleAudio.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@interface APhysicsEngineBasedAnimation (Private)
-(CGFloat)ImpactThresholdLow;
-(CGFloat)ImpactThresholdHigh;
@end

@implementation APhysicsEngineBasedAnimation

@synthesize physicsSpace=fPhysicsSpace;
@synthesize animating=fAnimating;
@synthesize objectObjectCollisionSoundEffect=fObjectObjectCollisionSoundEffect;
@synthesize hasObjectObjectCollisionSoundEffect=fHasObjectObjectCollisionSoundEffect;
@synthesize objectWallCollisionSoundEffect=fObjectWallCollisionSoundEffect;
@synthesize hasObjectWallCollisionSoundEffect=fHasObjectWallCollisionSoundEffect;

-(void)dealloc
{
   if (![@"" isEqualToString:fObjectObjectCollisionSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fObjectObjectCollisionSoundEffect];
   }
   Release(fObjectObjectCollisionSoundEffect);
   
   if (![@"" isEqualToString:fObjectWallCollisionSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fObjectWallCollisionSoundEffect];
   }
   Release(fObjectWallCollisionSoundEffect);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.animating = NO;
   self.objectObjectCollisionSoundEffect = @"";
   self.hasObjectObjectCollisionSoundEffect = NO;
   self.objectWallCollisionSoundEffect = @"";
   self.hasObjectWallCollisionSoundEffect = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.objectObjectCollisionSoundEffect = element.objectObjectCollisionSoundEffect;
   
   if (![@"" isEqualToString:fObjectObjectCollisionSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:fObjectObjectCollisionSoundEffect];
      
      self.hasObjectObjectCollisionSoundEffect = YES;
   }
   
   self.objectWallCollisionSoundEffect = element.objectWallCollisionSoundEffect;
   
   if (![@"" isEqualToString:fObjectWallCollisionSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:fObjectWallCollisionSoundEffect];
      
      self.hasObjectWallCollisionSoundEffect = YES;
   }
}

-(CGPoint)gravityVector
{
   return kDefaultGravityVector;
}

-(CGFloat)globalDamping
{
   return kDefaultGlobalDamping;
}

-(BOOL)gravityFollowsDeviceOrientation
{
   // most subclasses do, so we'll make YES the default
   return YES;
}

-(void)DeviceOrientationChanged:(NSNotification*)notification
{
   CGPoint gravityVector = CGPointZero;
   
   switch ([UIDevice currentDevice].orientation)
   {
      case UIDeviceOrientationPortrait:
         gravityVector = kGravityVectorPortrait;
         break;
         
      case UIDeviceOrientationPortraitUpsideDown:
         gravityVector = kGravityVectorPortraitUpsideDown;
         break;
         
      case UIDeviceOrientationLandscapeLeft:
         gravityVector = kGravityVectorLandscapeLeft;
         break;
         
      case UIDeviceOrientationLandscapeRight:
         gravityVector = kGravityVectorLandscapeRight;
         break;
         
      default:
         gravityVector = kDefaultGravityVector;
         break;
   }
   
   fPhysicsSpace.gravity = gravityVector;
}

-(void)SetupPhysics
{
   fPhysicsSpace = [[ChipmunkSpace alloc] init];
   
   // Apply simple damping; we don't want indefinite motion
   fPhysicsSpace.damping = [self globalDamping];
   
   // Apply gravity, so things fall.
   if (self.gravityFollowsDeviceOrientation)
   {
      [self DeviceOrientationChanged:nil];
   }
   else
   {
      self.physicsSpace.gravity = [self gravityVector];
   }
}

-(void)StartPhysics
{
   if (nil == fPhysicsSpace)
   {
      [self SetupPhysics];
   }
   
   if (self.gravityFollowsDeviceOrientation)
   {   
      // start device orientation notifications and register for same
      [[NSNotificationCenter defaultCenter] 
       addObserver:self 
       selector:@selector(DeviceOrientationChanged:) 
       name:UIDeviceOrientationDidChangeNotification 
       object:nil];
      
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
   }
   
   //[self AnimatePhysics];
}

-(void)StopPhysics
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
   
   Release(fPhysicsSpace);
   fPhysicsSpace = nil;
}

-(void)AnimatePhysics
{
   // implemented by subclass
}

-(void)AcknowledgeObjectObjectCollision
{
   [self AcknowledgeObjectObjectCollisionWithVolume:1.0f];
}

-(void)AcknowledgeObjectObjectCollisionWithVolume:(CGFloat)volume
{
   if (self.hasObjectObjectCollisionSoundEffect)
   {
      [[OALSimpleAudio sharedInstance] playEffect:self.objectObjectCollisionSoundEffect
                                           volume:volume 
                                            pitch:1.0f 
                                              pan:0.0f 
                                             loop:NO];
   }
}

-(void)AcknowledgeObjectWallCollision
{
   [self AcknowledgeObjectWallCollisionWithVolume:1.0f];
}

-(void)AcknowledgeObjectWallCollisionWithVolume:(CGFloat)volume
{
   if (self.hasObjectWallCollisionSoundEffect)
   {
      [[OALSimpleAudio sharedInstance] playEffect:self.objectWallCollisionSoundEffect
                                           volume:volume 
                                            pitch:1.0f 
                                              pan:0.0f 
                                             loop:NO];
   }   
}

// The "impact value" below which no sound will be triggered
-(CGFloat)ImpactThresholdLow
{
   return 50.0f;
}

// The "impact value" associated with the maximum volume with which a sound
// can be played
-(CGFloat)ImpactThresholdHigh
{
   return 1000.0f;
}

#pragma mark -
#pragma mark ACustomAnimation protocol

-(void)Start:(BOOL)triggered
{
   [super Start:triggered];
   
   if (!self.animating)
   {
      [self StartPhysics];
   }
   
   self.animating = YES;
}

-(void)Stop
{
   [super Stop];
   
   if (self.isAnimating)
   {
      [self StopPhysics];
   }
   
   self.animating = NO;
}

#pragma mark -
#pragma mark Chipmunk collision handling routines
-(void)InitializeCollisionDetection
{
   for (ChipmunkShape* shape in self.physicsSpace.shapes)
   {
      // shapes with a non-nil collisionType shouldn't be modified here...
      if (nil == shape.collisionType)
      {
         shape.collisionType = kObject;
      }
   }
   
   [self.physicsSpace setDefaultCollisionHandler:self 
                                           begin:@selector(CollisionBegin:Space:) 
                                        preSolve:@selector(CollisionPreSolve:Space:)
                                       postSolve:@selector(CollisionPostSolve:Space:) 
                                        separate:@selector(CollisionSeparate:Space:)];
}

-(BOOL)CollisionBegin:(cpArbiter*)arbiter Space:(ChipmunkSpace*)space
{   
   return YES;
}

-(BOOL)CollisionPreSolve:(cpArbiter*)arbiter Space:(ChipmunkSpace*)space
{
   return YES;
}

-(void)CollisionPostSolve:(cpArbiter*)arbiter Space:(ChipmunkSpace*)space
{
   if (!cpArbiterIsFirstContact(arbiter))
   {
      return;
   }
   
   // determine which shapes were involved in the collision
   CP_ARBITER_GET_SHAPES(arbiter, a, b);
   
   cpFloat impact = cpvlength(cpvadd(a->body->v, b->body->v));
   
   //NSLog(@"relative impact: %f", impact);
   
   // translate the impact to a volume
   CGFloat volume = 0.0f;
   
   if (impact <= [self ImpactThresholdLow])
   {
      volume = 0.0f;
   }
   else if (impact > [self ImpactThresholdHigh])
   {
      volume = 1.0f;
   }
   else
   {
      volume = impact / [self ImpactThresholdHigh];
   }
   
   if ([kObject isEqualToString:a->collision_type] &&
       [kObject isEqualToString:b->collision_type])
   {
      [self AcknowledgeObjectObjectCollisionWithVolume:volume];
   }
   else
   {
      [self AcknowledgeObjectWallCollisionWithVolume:volume];
   }    
}

-(void)CollisionSeparate:(cpArbiter*)arbiter Space:(ChipmunkSpace*)space
{
  
}

@end
