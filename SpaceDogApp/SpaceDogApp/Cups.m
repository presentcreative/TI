// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Cups.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "OALSimpleAudio.h"
#import "ObjectiveChipmunk.h"
#import "Trigger.h"
#import "Utilities.h"

#define kLeftCupMass    100.0f
#define kRightCupMass   180.0f
#define kOffsetAngle    30
#define kAngularOffset  DEGREES_TO_RADIANS(kOffsetAngle)

#define kLeftCupInitialAngle  DEGREES_TO_RADIANS(kOffsetAngle)
#define kRightCupInitialAngle DEGREES_TO_RADIANS(kOffsetAngle)

#define kLeftCupViewTag   200
#define kRightCupViewTag  201

@interface ACups (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

@end

@implementation ACups

@synthesize leftCupLastAngle=fLeftCupLastAngle;
@synthesize rightCupLastAngle=fRightCupLastAngle;
@synthesize soundEffect=fSoundEffect;

-(UIImageView*)leftCupView
{
   return (UIImageView*)[self.containerView viewWithTag:kLeftCupViewTag];
}

-(UIImageView*)rightCupView
{
   return (UIImageView*)[self.containerView viewWithTag:kRightCupViewTag];
}

-(BOOL)gravityFollowsAccelerometer
{
    return YES;//NO; wpm
}

-(CGFloat)globalDamping
{
   return 0.80f;
}

-(CGFloat)ImpactThresholdLow
{
   return 100.0f;
}

-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Cups physics engine.");
      return;      
   }
   
   [super SetupPhysics];
   
   CGFloat cupWidth = 0.0f;
   CGFloat cupHeight = 0.0f;
   
   // left cup
   cupWidth = self.leftCupView.frame.size.width;
   cupHeight = self.leftCupView.frame.size.height;
   
   // Create the chunk of mass that represents the left cup
   fLeftCupBody =  [[ChipmunkBody alloc] initWithMass:kLeftCupMass andMoment:cpMomentForBox(kLeftCupMass, cupWidth, cupHeight)];
   
   // Set its initial position...
   fLeftCupBody.pos = self.leftCupView.center; 
   
   
   // Give it a shape
   fLeftCupShape = [ChipmunkPolyShape boxWithBody:fLeftCupBody width:cupWidth height:cupHeight];
   
   // Bind these to the space
   [fPhysicsSpace addBody:fLeftCupBody];
   [fPhysicsSpace addShape:fLeftCupShape];
   
   // Bind the cup's handle to a single fixed point
   //CGPoint pivotPoint = CGPointMake(fLeftCupAnchorPoint.x, fLeftCupAnchorPoint.y);   
   CGPoint pivotPoint = CGPointMake(fLeftCupBody.pos.x, 0);
   ChipmunkPivotJoint* pivotJoint = [ChipmunkPivotJoint pivotJointWithBodyA:fPhysicsSpace.staticBody bodyB:fLeftCupBody pivot:pivotPoint];
   [fPhysicsSpace addConstraint:pivotJoint];


   // right cup
   cupWidth = self.rightCupView.frame.size.width;
   cupHeight = self.rightCupView.frame.size.height;
   
   // Create the chunk of mass that represents the right cup
   fRightCupBody =  [[ChipmunkBody alloc] initWithMass:kRightCupMass andMoment:cpMomentForBox(kRightCupMass, cupWidth, cupHeight)];
   
   // Set its initial position.
   fRightCupBody.pos = self.rightCupView.center; //CGPointMake(cupWidth/2.0f, cupHeight/2.0f);
   
   
   // Give it a shape
   fRightCupShape = [ChipmunkPolyShape boxWithBody:fRightCupBody width:cupWidth height:cupHeight];
   
   // Bind these to the space
   [fPhysicsSpace addBody:fRightCupBody];
   [fPhysicsSpace addShape:fRightCupShape];
   
   // Bind the cup's handle to a single fixed point
   //pivotPoint = CGPointMake(fRightCupAnchorPoint.x, fRightCupAnchorPoint.y);  
   pivotPoint = CGPointMake(fRightCupBody.pos.x, 0.0);
   pivotJoint = [ChipmunkPivotJoint pivotJointWithBodyA:fPhysicsSpace.staticBody bodyB:fRightCupBody pivot:pivotPoint];
   [fPhysicsSpace addConstraint:pivotJoint];
   
   // add a collision handler so that we can play some sound effects at appropriate times
   [self InitializeCollisionDetection];
}

-(void)StopPhysics
{
   [super StopPhysics];
   
   Release(fLeftCupBody);
   fLeftCupBody = nil;
   
   Release(fRightCupBody);
   fRightCupBody = nil;
}

-(void)DisplayLinkDidTick:(CADisplayLink *)displayLink
{
   if (self.isAnimating)
   {
      [fPhysicsSpace step:displayLink.duration];
      
      [self AnimatePhysics];
   }
}

-(void)AnimatePhysics
{   
   //NSLog( @"Chipmunk sign pos/angle: (%.02f %.02f) @ %.02f", 
   //      fcupBody.pos.x, fcupBody.pos.y, fcupBody.angle );
   
   CGFloat angle = 0.0f;
   
   // left cup
   angle = fLeftCupBody.angle;
   
   //NSLog(@"left cup angle = %f", angle);
   
   self.leftCupView.transform = CGAffineTransformMakeRotation(angle);
   
//   if ((self.leftCupLastAngle < 0.0f && angle > 0.0f) ||
//       (self.leftCupLastAngle > 0.0f && angle < 0.0f ))
//   {
//      if (![@"" isEqualToString:self.soundEffect])
//      {
//         [[OALSimpleAudio sharedInstance] playEffect:self.soundEffect volume:0.1f pitch:1.0f pan:0.0f loop:NO];
//      }
//   }
   
   self.leftCupLastAngle = angle;
   
   // right cup
   angle = fRightCupBody.angle;
   
   //NSLog(@"right cup angle = %f", angle);
   
   self.rightCupView.transform = CGAffineTransformMakeRotation(angle);
   
//   if ((self.rightCupLastAngle < 0.0f && angle > 0.0f) ||
//       (self.rightCupLastAngle > 0.0f && angle < 0.0f ))
//   {
//      if (![@"" isEqualToString:self.soundEffect])
//      {   
//         [[OALSimpleAudio sharedInstance] playEffect:self.soundEffect volume:0.1f pitch:1.0f pan:0.0f loop:NO];
//      }
//   }
   
   self.rightCupLastAngle = angle;
}

-(void)dealloc
{      
   if (![@"" isEqualToString:fSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fSoundEffect];
   }
   Release(fSoundEffect);   
      
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.leftCupLastAngle = 0.0f;
   self.rightCupLastAngle = 0.0f;
   self.soundEffect = @"";
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   UIImageView* cupView = nil;

   // left cup
   layerSpec = element.leftCupLayer;
   
   cupView = [[UIImageView alloc] init];
   cupView.tag = kLeftCupViewTag;
   cupView.frame = layerSpec.frame;
   
   // the cup swings on its handle, therefore its anchorPoint and position must be changed from the default
   fLeftCupAnchorPoint = layerSpec.anchorPoint;
   CGFloat anchorPointX = fLeftCupAnchorPoint.x/cupView.bounds.size.width;
   CGFloat anchorPointY = fLeftCupAnchorPoint.y/cupView.bounds.size.height;
   
   // now, set the image of the cup
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", element.resource);
      
      [cupView release];
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   cupView.image = image;
   [image release];
      
   // establish an initial orientation for the cup
   //cupView.transform = CGAffineTransformRotate(cupView.transform, kLeftCupInitialAngle);
   
   [AUtilities SetAnchorPoint:CGPointMake(anchorPointX, anchorPointY) ForView:cupView];
   
   [self.containerView addSubview:cupView];
   [cupView release];
   
   
   // right cup
   layerSpec = element.rightCupLayer;
   
   cupView = [[UIImageView alloc] init];
   cupView.tag = kRightCupViewTag;
   cupView.frame = layerSpec.frame;
   
   // the cup swings on one hinge, therefore its anchorPoint and position must be changed from the default
   fRightCupAnchorPoint = layerSpec.anchorPoint;
   anchorPointX = fRightCupAnchorPoint.x/cupView.bounds.size.width;
   anchorPointY = fRightCupAnchorPoint.y/cupView.bounds.size.height;
   
   [AUtilities SetAnchorPoint:CGPointMake(anchorPointX, anchorPointY) ForView:cupView];
         
   // now, set the image of the cup
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", element.resource);
      
      [cupView release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   cupView.image = image;
   [image release];
   
   // establish an initial orientation for the cup
   //cupView.transform = CGAffineTransformRotate(cupView.transform, kRightCupInitialAngle);
         
   [self.containerView addSubview:cupView];
   [cupView release];
   

   // add the SoundEffect
   self.soundEffect = element.cupSoundEffect;
   
   if (![@"" isEqualToString:self.soundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.soundEffect];
   }
}

#pragma mark -
#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   if (!self.isAnimating)
   {
      ATrigger* tiltTrigger = self.tiltTrigger;
      
      if (nil != tiltTrigger)
      {
         [tiltTrigger BecomeAccelerometerDelegate];
      }
   }
   
   [super Start:triggered];
}

-(void)Stop
{
   ATrigger* tiltTrigger = self.tiltTrigger;
   
   if (nil != tiltTrigger)
   {
      [tiltTrigger BecomeFreeOfAccelerometer];
   }
   
   [super Stop];
}

-(void)HandleTilt:(NSDictionary*)tiltInfo
{
   if (!self.isAnimating)
   {
      return;
   }
   
   CGFloat tiltAngle = 90 - [(NSNumber*)[tiltInfo objectForKey:@"tiltAngle"] floatValue];
   
   CGPoint adjustedGravity = cpvrotate(cpv(0.0f,500.0f), cpvforangle(DEGREES_TO_RADIANS(tiltAngle)));
      
   fPhysicsSpace.gravity = adjustedGravity;
}

@end
