// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Leaves.h"
#import "ObjectiveChipmunk.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import <objc/runtime.h>
#import "trigger.h"

#define kPhysicsTimeInterval 0.03f
#define kPhysicsGravityVector CGPointMake(0.0,500.0)
#define kMaxLeaves 3
#define kLeafImageBaseTag 201

#define kLeaf1Mass         40.0f
#define kLeaf2Mass         60.0f
#define kLeaf3Mass         70.0f

#define kLeaf1ForceScale   10.0f
#define kLeaf2ForceScale   15.0f
#define kLeaf3ForceScale   20.0f

@interface ALeaves (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;
-(void)BuildTiltTrigger;


@end

@implementation ALeaves

@synthesize leaf1Body=fLeaf1Body;
@synthesize leaf1Shape=fLeaf1Shape;

@synthesize leaf2Body=fLeaf2Body;
@synthesize leaf2Shape=fLeaf2Shape;

@synthesize leaf3Body=fLeaf3Body;
@synthesize leaf3Shape=fLeaf3Shape;

@synthesize tiltTrigger=fTiltTrigger;


-(UIImageView*)leaf1ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kLeafImageBaseTag];
}

-(UIImageView*)leaf2ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kLeafImageBaseTag+1];
}

-(UIImageView*)leaf3ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kLeafImageBaseTag+2];
}

-(CGFloat)globalDamping
{
    return .05;
}

-(BOOL)gravityFollowsAccelerometer
{
    return YES;
}


-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Leaves physics engine.");
      return;      
   }
   
   [super SetupPhysics];
   
   [self.physicsSpace addBounds:self.containerView.bounds 
                      thickness:300.0f 
                     elasticity:1.0f 
                       friction:1.0f 
                         layers:CP_ALL_LAYERS 
                          group:CP_NO_GROUP 
                  collisionType:@"collisionType"];
         
   // leaf 1
   CGFloat leafWidth = self.leaf1ImageView.frame.size.width;
   CGFloat leafHeight = self.leaf1ImageView.frame.size.height;
   
   ChipmunkBody* leafBody = nil;
   ChipmunkShape* leafShape = nil;
   
   // Create the chunk of mass that represents the leaf
   leafBody = [[ChipmunkBody alloc] initWithMass:kLeaf1Mass andMoment:cpMomentForBox(kLeaf1Mass, leafWidth, leafHeight)];
   self.leaf1Body = leafBody;
   [leafBody release];
   
   // Set its initial position.
   self.leaf1Body.pos = self.leaf1ImageView.center;
   self.leaf1Body.force = cpvzero;
   
   // Give it a shape
   leafShape = [[ChipmunkPolyShape alloc] initBoxWithBody:self.leaf1Body width:leafWidth height:leafHeight];
   self.leaf1Shape = leafShape;
   [leafShape release];
   
   self.leaf1Shape.elasticity = .5;
   self.leaf1Shape.friction = .05;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.leaf1Body];
   [self.physicsSpace addShape:self.leaf1Shape];
   
   
   // leaf 2
   leafWidth = self.leaf2ImageView.frame.size.width;
   leafHeight = self.leaf2ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the coconut
   leafBody = [[ChipmunkBody alloc] initWithMass:kLeaf2Mass andMoment:cpMomentForBox(kLeaf2Mass, leafWidth, leafHeight)];
   self.leaf2Body = leafBody;
   [leafBody release];
   
   // Set its initial position.
   self.leaf2Body.pos = self.leaf2ImageView.center;
   self.leaf2Body.force = cpvzero;
   
   // Give it a shape
   leafShape = [[ChipmunkPolyShape alloc] initBoxWithBody:self.leaf2Body width:leafWidth height:leafHeight];
   self.leaf2Shape = leafShape;
   [leafShape release];
   
   self.leaf2Shape.elasticity = .5;
   self.leaf2Shape.friction = .05;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.leaf2Body];
   [self.physicsSpace addShape:self.leaf2Shape];
   
   
   // leaf 3
   leafWidth = self.leaf3ImageView.frame.size.width;
   leafHeight = self.leaf3ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the 3rd leaf
   leafBody = [[ChipmunkBody alloc] initWithMass:kLeaf3Mass andMoment:cpMomentForBox(kLeaf3Mass, leafWidth, leafHeight)];
   self.leaf3Body = leafBody;
   [leafBody release];
   
   // Set its initial position.
   self.leaf3Body.pos = self.leaf3ImageView.center;
   self.leaf3Body.force = cpvzero;
   
   // Give it a shape
   leafShape = [[ChipmunkPolyShape alloc] initBoxWithBody:self.leaf3Body width:leafWidth height:leafHeight];
   self.leaf3Shape = leafShape;
   [leafShape release];
   
   self.leaf3Shape.elasticity = .5;
   self.leaf3Shape.friction = .05;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.leaf3Body];
   [self.physicsSpace addShape:self.leaf3Shape];
    
    [self BuildTiltTrigger];

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
   self.leaf1ImageView.center = self.leaf1Body.pos;
   self.leaf1ImageView.transform = CGAffineTransformMakeRotation(self.leaf1Body.angle);
   
   self.leaf2ImageView.center = self.leaf2Body.pos;
   self.leaf2ImageView.transform = CGAffineTransformMakeRotation(self.leaf2Body.angle);

   self.leaf3ImageView.center = self.leaf3Body.pos;
   self.leaf3ImageView.transform = CGAffineTransformMakeRotation(self.leaf3Body.angle);
}

-(void)dealloc
{   
   Release(fLeaf1Body);
   Release(fLeaf1Shape);
   Release(fLeaf2Body);
   Release(fLeaf2Shape);
   Release(fLeaf3Body);
   Release(fLeaf3Shape);
   Release(fTiltTrigger);
   
   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
      
   NSString* imagePath = nil;
   
   NSUInteger leafCount = 0;
   
   // create and populate each of the individual  leaf layers
   for (NSDictionary* leafDescriptor in element.resources)
   {
      // set the image of the sign
      imagePath = [[NSBundle mainBundle] pathForResource:leafDescriptor.resource ofType:nil];
      
      if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
      {
         ALog(@"Image file missing: %@", leafDescriptor.resource);
         
         return;
      }

      UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
      UIImageView* leafImageView = [[UIImageView alloc] initWithImage:image];
      [image release];
      leafImageView.frame = leafDescriptor.frame;
      leafImageView.tag = kLeafImageBaseTag+leafCount;
      
      [self.containerView addSubview:leafImageView];
      [leafImageView release];
      
      leafCount++;
   }
   
   // attach a gesture recognizer so that we can accept input from the user
   UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
   recognizer.delegate = self;
   recognizer.minimumNumberOfTouches = 1;
   recognizer.maximumNumberOfTouches = 1;
   
   [self.containerView addGestureRecognizer:recognizer];
   [recognizer release];
}

#pragma mark -
#pragma mark ACustomAnimation protocol
-(void)HandleGesture:(UIGestureRecognizer*)recognizer
{
   if (!self.isAnimating)
   {
      //Nothing to do if physics isn't running here
      return;
   }
   
   if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]])
   {
      return;
   }
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)recognizer;
   
   CGPoint force = [panRecognizer velocityInView:self.containerView];
   
   CGPoint location = [recognizer locationInView:self.containerView];
   
   CGPoint offset = CGPointZero;
   
   if (CGRectContainsPoint(self.leaf1ImageView.frame, location))
   {
      offset = [recognizer locationInView:self.leaf1ImageView];
      [self.leaf1Body applyImpulse:CGPointMake(force.x*kLeaf1ForceScale, force.y*kLeaf1ForceScale) offset:offset];
   }
   
   if (CGRectContainsPoint(self.leaf2ImageView.frame, location))
   {
      offset = [recognizer locationInView:self.leaf2ImageView];
      [self.leaf2Body applyImpulse:CGPointMake(force.x*kLeaf2ForceScale, force.y*kLeaf2ForceScale) offset:offset];
   }
   
   if (CGRectContainsPoint(self.leaf3ImageView.frame, location))
   {
      offset = [recognizer locationInView:self.leaf3ImageView];
      [self.leaf3Body applyImpulse:CGPointMake(force.x*kLeaf3ForceScale, force.y*kLeaf3ForceScale) offset:offset];
   }
   
   [panRecognizer setTranslation:CGPointZero inView:self.containerView];
}

-(NSDictionary*)TiltTriggerSpec
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"TILT", @"type", 
            @"ALWAYS", @"tiltNotificationEvent",
            [NSNumber numberWithBool:YES], @"allowsConcurrentTrigger",
            nil];
}

-(void)BuildTiltTrigger
{
    ATrigger* tiltTrigger = [[ATrigger alloc] initWithTriggerSpec:[self TiltTriggerSpec] ForAnimation:self OnView:self.containerView];
    
    self.tiltTrigger = tiltTrigger;
    
    [tiltTrigger release];
}

#pragma mark UIGestureRecognizerDelegate protocol
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
   
   // is the user interacting with one of the pottery shards?
   CGPoint touchLocation = [panRecognizer locationInView:self.containerView];
   
   if (CGRectContainsPoint(self.leaf1ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.leaf2ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.leaf3ImageView.frame, touchLocation))
   {
      result = YES;
   }
   
   return result;
}

#pragma mark -
#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
       
    [self.tiltTrigger BecomeAccelerometerDelegate];
    
    [super Start:triggered];
       
}

-(void)Stop
{
    [super Stop];
    
    if (nil != self.tiltTrigger)
    {
        [self.tiltTrigger BecomeFreeOfAccelerometer];
    }
    
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
