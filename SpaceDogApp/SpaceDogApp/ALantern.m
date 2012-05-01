// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ALantern.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "OALSimpleAudio.h"
#import "ObjectiveChipmunk.h"
#import "Trigger.h"
#import "BookView.h"


#define kPhysicsTimeInterval .03f
#define kPhysicsGravityVector CGPointMake(0.0,500.0)
#define kPhysicsGlobalDamping 0.75f
#define kLanternMass 30.0f

@interface ALantern (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

@end

@implementation ALantern

@synthesize layer=fLayer;
@synthesize soundEffect=fSoundEffect;
@synthesize lastAngle=fLastAngle;

-(BOOL)gravityFollowsDeviceOrientation
{
   return NO;
}

-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Lantern physics engine.");
      return;      
   }
   
   [super SetupPhysics];
      
   CGFloat lanternWidth = self.layer.frame.size.width;
   CGFloat lanternHeight = self.layer.frame.size.height;
   
   // Create the chunk of mass that represents the sign
   fLanternBody =  [[ChipmunkBody alloc] initWithMass:kLanternMass andMoment:cpMomentForBox(kLanternMass, lanternWidth, lanternHeight)];
   
   // Set its center of gravity.
   fLanternBody.pos = CGPointMake(lanternWidth/2.0f, lanternHeight/2.0f);
   
   // Give it a shape
   fLanternShape = [ChipmunkPolyShape boxWithBody:fLanternBody width:lanternWidth height:lanternHeight];
   
   // Bind these to the space
   [fPhysicsSpace addBody:fLanternBody];
   [fPhysicsSpace addShape:fLanternShape];
   
   // Bind the corner to a single fixed point
   CGPoint pivotPoint = CGPointMake(fAnchorPoint.x, fAnchorPoint.y);   
   ChipmunkPivotJoint* pivotJoint = [ChipmunkPivotJoint pivotJointWithBodyA:fPhysicsSpace.staticBody bodyB:fLanternBody pivot:pivotPoint];
   [fPhysicsSpace addConstraint:pivotJoint];
   
}

-(void)StopPhysics
{
   [super StopPhysics];
   
   Release(fLanternBody);
   fLanternBody = nil;
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
   //      fLanternBody.pos.x, fLanternBody.pos.y, fLanternBody.angle );
   
   // Create rotation transform
   CGFloat angle = fLanternBody.angle;
   
   //NSLog(@"rotating %f degrees (%f radians)", RADIANS_TO_DEGREES(angle), angle);
   
   CATransform3D rotation = CATransform3DMakeRotation(angle, 0, 0, 1);
   
   self.layer.transform = rotation;
   
   if ((self.lastAngle < 0.0f && angle > 0.0f) ||
       (self.lastAngle > 0.0f && angle < 0.0f ))
   {
      [[OALSimpleAudio sharedInstance] playEffect:self.soundEffect volume:0.2f pitch:1.0f pan:0.0f loop:NO];
   }
   
   self.lastAngle = angle;
}

-(void)dealloc
{   
   self.layer.delegate = nil;
   if (self.layer.superlayer)
   {
      [self.layer removeFromSuperlayer];
   }
   
   if (![@"" isEqualToString:fSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fSoundEffect];
   }
   Release(fSoundEffect);   
   
   Release(fLayer);

   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.lastAngle = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.layer = aLayer;
   [aLayer release];
   
   self.layer.frame = element.frame;
   
   // the lantern swings on one hinge, therefore its anchorPoint and position must be changed from the default
   fAnchorPoint = element.anchorPoint;
   CGFloat anchorPointX = 0.0f<self.layer.bounds.size.width?fAnchorPoint.x/self.layer.bounds.size.width:0.0f;
   CGFloat anchorPointY = 0.0f<self.layer.bounds.size.height?fAnchorPoint.y/self.layer.bounds.size.height:0.0f;
   
   self.layer.anchorPoint = CGPointMake(anchorPointX, anchorPointY);
   
   CGPoint correctedPosition = CGPointMake(self.layer.position.x + self.layer.bounds.size.width * (self.layer.anchorPoint.x - 0.5),
                                           self.layer.position.y + self.layer.bounds.size.height * (self.layer.anchorPoint.y -0.5));
   
   self.layer.position = correctedPosition;
   
   
   // now, set the image of the sign
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:element.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", element.resource);
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.layer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:self.layer];
   
   // add the SoundEffect
   self.soundEffect = element.lanternSoundEffect;

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
   
   CGPoint adjustedGravity = cpvrotate(kPhysicsGravityVector, cpvforangle(DEGREES_TO_RADIANS(tiltAngle)));
   
   //NSLog(@"Tilt: %0.2f gravity.X: %0.2f, gravity.Y: %0.2f",
   // tiltAngle, adjustedGravity.x, adjustedGravity.y);
   
   fPhysicsSpace.gravity = adjustedGravity;
}

@end
