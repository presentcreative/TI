// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Sign.h"
#import "SoundEffect.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "ObjectiveChipmunk.h"
#import "Trigger.h"

#define kPhysicsTimeInterval .03f
#define kPhysicsGravityVector CGPointMake(0.0,1000.0) //CGPointMake(0.0,500.0)
#define kSignMass 1.0f //90.0f  wpm reuced weight

@interface ASign (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

-(BOOL)AnimationInProgress;

-(void)BuildTiltTrigger;
-(void)BuildShakeTrigger;
-(NSDictionary*)TiltTriggerSpec;
-(NSDictionary*)ShakeTriggerSpec;

@end

@implementation ASign

@synthesize layer = fLayer;
@synthesize soundEffect=fSoundEffect;
@synthesize tiltTrigger=fTiltTrigger;
@synthesize shakeTrigger=fShakeTrigger;

-(CGFloat)globalDamping
{
   return 0.50f;
}

/*-(BOOL)gravityFollowsAccelerometer
{
   // doesn't make sense for the sign to have 'down' be anything but the bottom
   // of the screen in the app's default orientation.
   return YES;
}*/

-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Sign physics engine.");
      return;      
   }
   
   [super SetupPhysics];
   
   CGFloat signWidth = self.layer.frame.size.width;
   CGFloat signHeight = self.layer.frame.size.height;
   
   // Create the chunk of mass that represents the sign
   fSignBody =  [[ChipmunkBody alloc] initWithMass:kSignMass andMoment:cpMomentForBox(kSignMass, signWidth, signHeight)];
   
   // Set its center of gravity.
   fSignBody.pos = CGPointMake(signWidth/2.0f, signHeight/2.0f);

   // Give it a shape
   fSignShape = [ChipmunkPolyShape boxWithBody:fSignBody width:signWidth height:signHeight];
   
   // Bind these to the space
   [fPhysicsSpace addBody:fSignBody];
   [fPhysicsSpace addShape:fSignShape];

   // Bind the corner to a single fixed point
   CGPoint pivotPoint = CGPointMake(0.5f, 0.5f);   
   ChipmunkPivotJoint* pivotJoint = [ChipmunkPivotJoint pivotJointWithBodyA:fPhysicsSpace.staticBody bodyB:fSignBody pivot:pivotPoint];
   [fPhysicsSpace addConstraint:pivotJoint];
   
}

-(void)StopPhysics
{      
   [super StopPhysics];
   
   Release(fSignBody);
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
   //      fSignBody.pos.x, fSignBody.pos.y, fSignBody.angle );
   
   // Create and apply rotation transform
   self.layer.transform = CATransform3DMakeRotation(fSignBody.angle, 0, 0, 1);
}

-(void)dealloc
{   
   self.layer.delegate = nil;
   if (self.layer.superlayer)
   {
      [self.layer removeFromSuperlayer];
   }
   
   Release(fLayer);
   Release(fSoundEffect);
   Release(fTiltTrigger);
   Release(fShakeTrigger);

   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.layer = aLayer;
   [aLayer release];
   
   self.layer.frame = element.frame;
      
   // the sign swings on one hinge, therefore its anchorPoint and position must be changed from the default
   CGPoint anchorPoint = element.anchorPoint;
   CGFloat anchorPointX = 0.0f<self.layer.bounds.size.width?anchorPoint.x/self.layer.bounds.size.width:0.0f;
   CGFloat anchorPointY = 0.0f<self.layer.bounds.size.height?anchorPoint.y/self.layer.bounds.size.height:0.0f;
   
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
   ASoundEffect* se = (ASoundEffect*)[[ASoundEffect alloc] initWithElement:element.soundEffect RenderOnView:nil];
   self.soundEffect = se;
   [se release];   
   
   [self BuildTiltTrigger];
   [self BuildShakeTrigger];
}

-(NSDictionary*)TiltTriggerSpec
{
   return [NSDictionary dictionaryWithObjectsAndKeys:
           @"TILT", @"type", 
           @"ALWAYS", @"tiltNotificationEvent",
           [NSNumber numberWithBool:YES], @"allowsConcurrentTrigger",
           nil];
}

-(NSDictionary*)ShakeTriggerSpec
{
   return [NSDictionary dictionaryWithObjectsAndKeys:
           @"SHAKE", @"type",  
           nil];
}

-(void)BuildTiltTrigger
{
   ATrigger* tiltTrigger = [[ATrigger alloc] initWithTriggerSpec:[self TiltTriggerSpec] ForAnimation:self OnView:self.containerView];

   self.tiltTrigger = tiltTrigger;
   
   [tiltTrigger release];
}

-(void)BuildShakeTrigger
{
   ATrigger* shakeTrigger = [[ATrigger alloc] initWithTriggerSpec:[self ShakeTriggerSpec] ForAnimation:self OnView:self.containerView];
   
   self.shakeTrigger = shakeTrigger;
   
   [shakeTrigger release];
   
   [self.shakeTrigger BecomeAccelerometerDelegate];
}

#pragma mark -
#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   if (triggered)
   {
      if (!self.isAnimating)
      { 
         [self.shakeTrigger BecomeFreeOfAccelerometer];
         
         self.shakeTrigger = nil;
         
         [self.tiltTrigger BecomeAccelerometerDelegate];
         
         [self StartPhysics];
         
         [self.soundEffect Start:triggered];
         
         self.animating = YES;
      }
   }
   else
   {
      if (nil == self.shakeTrigger)
      {
         [self BuildShakeTrigger];
      }

      [self.shakeTrigger BecomeAccelerometerDelegate];
   }
}

-(void)Stop
{
   [super Stop];
   
   if (nil != self.tiltTrigger)
   {
      [self.tiltTrigger BecomeFreeOfAccelerometer];
   }
   
   if (nil != self.shakeTrigger)
   {
      [self.shakeTrigger BecomeFreeOfAccelerometer];
   }
   
   self.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
}

-(void)HandleTilt:(NSDictionary*)tiltInfo
{
   if (!self.isAnimating)
   {
      return;
   }
   
   CGFloat tiltAngle = 0.0f;
   CGFloat levelAngle = 90.0f; // tiltAngle when device is level
   
   int tiltDirection = [[tiltInfo objectForKey:@"tiltDirection"] intValue];
   CGFloat incomingAngle = [(NSNumber*)[tiltInfo objectForKey:@"tiltAngle"] floatValue];

   if (kTiltingLeft == tiltDirection)
   {
      if (incomingAngle < levelAngle) // HOME button on right
      {
         tiltAngle = levelAngle - incomingAngle;
      }
      else // HOME button on left
      {
         tiltAngle = incomingAngle - levelAngle;
      }
   }
   else if (kTiltingRight == tiltDirection)
   {
      if (incomingAngle < levelAngle) // HOME button on left
      {
         tiltAngle = incomingAngle - levelAngle;
      }
      else // HOME button on right
      {
         tiltAngle = levelAngle - incomingAngle;
      }
   }
   
   //NSLog(@"final tiltAngle = %f", tiltAngle);
   
   CGPoint adjustedGravity = cpvrotate(kPhysicsGravityVector, cpvforangle(DEGREES_TO_RADIANS(tiltAngle)));

   //NSLog(@"Tilt: %0.2f gravity.X: %0.2f, gravity.Y: %0.2f",
   //      tiltAngle, adjustedGravity.x, adjustedGravity.y);

   fPhysicsSpace.gravity = adjustedGravity;
}

@end
