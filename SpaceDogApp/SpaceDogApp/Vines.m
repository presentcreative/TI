// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Vines.h"
#import "NSDictionary+ElementAndPropertyValues.h"

#import "ObjectiveChipmunk.h"

#define kSwayTimeInterval  3.0f
#define kPhysicsTimeInterval 0.03f
#define kVineMass 100.0f

#define kLeftVineImageTag  201
#define kRightVineImageTag 202

#define kVineForceUpperBound 20
#define kVineForceScale      500

#define kVineFrameExtension   80.0f // points

@interface AVines (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

-(void)SwayVines;

@end


@implementation AVines

@synthesize leftVineBody=fLeftVineBody;
@synthesize leftVineShape=fLeftVineShape;
@synthesize rightVineBody=fRightVineBody;
@synthesize rightVineShape=fRightVineShape;
@synthesize leftVineSwipeableFrame=fLeftVineSwipeableFrame;
@synthesize rightVineSwipeableFrame=fRightVineSwipeableFrme;

-(UIImageView*)leftVineImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kLeftVineImageTag];
}

-(UIImageView*)rightVineImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kRightVineImageTag];
}

-(BOOL)gravityFollowsDeviceOrientation
{
   return NO;
}

-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Sign physics engine.");
      return;      
   }
   
   [super SetupPhysics];
   
   CGFloat vineWidth = 0.0f;
   CGFloat vineHeight = 0.0f;
   
   // left vine
   vineWidth = self.leftVineImageView.frame.size.width;
   vineHeight = self.leftVineImageView.frame.size.height;
      
   // Create the chunk of mass that represents the vine
   fLeftVineBody = [[ChipmunkBody alloc] initWithMass:kVineMass andMoment:cpMomentForBox(kVineMass, vineWidth, vineHeight)];
   
   // Set its initial position.  
   fLeftVineBody.pos = self.leftVineImageView.center;
   
   // Give it a shape
   fLeftVineShape = [[ChipmunkPolyShape alloc] initBoxWithBody:fLeftVineBody width:vineWidth height:vineHeight];
   
   // Bind these to the space
   [fPhysicsSpace addBody:fLeftVineBody];
   [fPhysicsSpace addShape:fLeftVineShape];
   
   // Bind the top to a single fixed point
   // Establish a pivot point at the x-center/y-top
   CGPoint pivotPoint = 
      CGPointMake(fLeftVineBody.pos.x,
                  fLeftVineBody.pos.y - vineHeight/2.0);

   ChipmunkPivotJoint* pivotJoint = [[ChipmunkPivotJoint alloc] initWithBodyA:fPhysicsSpace.staticBody bodyB:fLeftVineBody pivot:pivotPoint];
   [fPhysicsSpace addConstraint:pivotJoint];
   [pivotJoint release];
   
   // right vine
   vineWidth = self.rightVineImageView.frame.size.width;
   vineHeight = self.rightVineImageView.frame.size.height;
   
   // Create the chunk of mass that represents the vine
   fRightVineBody = [[ChipmunkBody alloc] initWithMass:kVineMass andMoment:cpMomentForBox(kVineMass, vineWidth, vineHeight)];
   
   // Set its initial position.   
   fRightVineBody.pos = self.rightVineImageView.center;
   
   // Give it a shape
   fRightVineShape = [[ChipmunkPolyShape alloc] initBoxWithBody:fRightVineBody width:vineWidth height:vineHeight];
   
   // Bind these to the space
   [fPhysicsSpace addBody:fRightVineBody];
   [fPhysicsSpace addShape:fRightVineShape];
   
   // Bind the top to a single fixed point
   // Establish a pivot point at the x-center/y-top
   pivotPoint = 
      CGPointMake(fRightVineBody.pos.x,
                  fRightVineBody.pos.y - vineHeight/2.0);

   pivotJoint = [[ChipmunkPivotJoint alloc] initWithBodyA:fPhysicsSpace.staticBody bodyB:fRightVineBody pivot:pivotPoint];   
   [fPhysicsSpace addConstraint:pivotJoint];
   [pivotJoint release];
}

-(void)StartPhysics
{
   [super StartPhysics];
   
   [self SwayVines];
}

-(void)StopPhysics
{   
   [super StopPhysics];
   
   Release(fLeftVineBody);
   fLeftVineBody = nil;
   
   Release(fLeftVineShape);
   fLeftVineShape = nil;
   
   Release(fRightVineBody);
   fRightVineBody = nil;
   
   Release(fRightVineShape);
   fRightVineShape = nil;
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
   self.leftVineImageView.center = self.leftVineBody.pos;
   self.leftVineImageView.transform = CGAffineTransformMakeRotation(self.leftVineBody.angle);

   self.rightVineImageView.center = self.rightVineBody.pos;
   self.rightVineImageView.transform = CGAffineTransformMakeRotation(self.rightVineBody.angle);
}

-(void)SwayVines
{
   CGFloat leftVineForce = arc4random_uniform(kVineForceUpperBound)*kVineForceScale;
   CGFloat rightVineForce = arc4random_uniform(kVineForceUpperBound)*kVineForceScale;
   
   // apply an initial impulse of random magnitude to each vine in order to make them sway
   [self.leftVineBody applyImpulse:CGPointMake(leftVineForce, 0.0f) offset:cpvzero];
   
   [self.rightVineBody applyImpulse:CGPointMake(rightVineForce, 0.0f) offset:cpvzero];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.leftVineSwipeableFrame = CGRectZero;
   self.rightVineSwipeableFrame = CGRectZero;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* vineSpec = nil;
   NSString* imagePath = nil;
   UIImageView* vineImage = nil;
   UIImage* image = nil;
   
   // left vine
   vineSpec = element.leftVine;
   
   imagePath = [[NSBundle mainBundle] pathForResource:vineSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", vineSpec.resource);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   vineImage = [[UIImageView alloc] initWithImage:image];
   [image release];
   vineImage.tag = kLeftVineImageTag;
   vineImage.frame = vineSpec.frame;
   
   // expand the vine's frame to make it a little easier to swipe
   CGRect leftVineSwipeableFrame = vineSpec.frame;
   leftVineSwipeableFrame.origin.x = leftVineSwipeableFrame.origin.x - (kVineFrameExtension/2.0f);
   leftVineSwipeableFrame.size.width = leftVineSwipeableFrame.size.width + kVineFrameExtension;
   leftVineSwipeableFrame.size.height = leftVineSwipeableFrame.size.height + kVineFrameExtension;
   self.leftVineSwipeableFrame = leftVineSwipeableFrame;
      
   // the vine swings from its top, therefore its layer's anchorPoint and its center must be changed from the default
   CGPoint anchorPoint = vineSpec.anchorPoint;
   CGFloat anchorPointX = 0.0f<vineImage.layer.bounds.size.width?anchorPoint.x/vineImage.layer.bounds.size.width:0.0f;
   CGFloat anchorPointY = 0.0f<vineImage.layer.bounds.size.height?anchorPoint.y/vineImage.layer.bounds.size.height:0.0f;
   
   vineImage.layer.anchorPoint = CGPointMake(anchorPointX, anchorPointY);
   
   CGPoint correctedPosition = CGPointMake(vineImage.layer.position.x + vineImage.layer.bounds.size.width * (vineImage.layer.anchorPoint.x - 0.5),
                                           vineImage.layer.position.y + vineImage.layer.bounds.size.height * (vineImage.layer.anchorPoint.y - 0.5));
   
   vineImage.center = correctedPosition;
   
   [self.containerView addSubview:vineImage];
   [vineImage release];
   
   
   // right vine
   vineSpec = element.rightVine;
   
   imagePath = [[NSBundle mainBundle] pathForResource:vineSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", vineSpec.resource);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   vineImage = [[UIImageView alloc] initWithImage:image];
   [image release];
   vineImage.tag = kRightVineImageTag;
   vineImage.frame = vineSpec.frame;
   
   CGRect rightVineSwipeableFrame = vineSpec.frame;
   rightVineSwipeableFrame.origin.x = rightVineSwipeableFrame.origin.x - (kVineFrameExtension/2.0f);
   rightVineSwipeableFrame.size.width = rightVineSwipeableFrame.size.width + kVineFrameExtension;
   rightVineSwipeableFrame.size.height = rightVineSwipeableFrame.size.height + kVineFrameExtension;
   self.rightVineSwipeableFrame = rightVineSwipeableFrame;
   
   // the vine swings from its top, therefore its layer's anchorPoint and its center must be changed from the default
   anchorPoint = vineSpec.anchorPoint;
   anchorPointX = 0.0f<vineImage.layer.bounds.size.width?anchorPoint.x/vineImage.layer.bounds.size.width:0.0f;
   anchorPointY = 0.0f<vineImage.layer.bounds.size.height?anchorPoint.y/vineImage.layer.bounds.size.height:0.0f;
   
   vineImage.layer.anchorPoint = CGPointMake(anchorPointX, anchorPointY);
   
   correctedPosition = CGPointMake(vineImage.layer.position.x + vineImage.layer.bounds.size.width * (vineImage.layer.anchorPoint.x - 0.5),
                                           vineImage.layer.position.y + vineImage.layer.bounds.size.height * (vineImage.layer.anchorPoint.y - 0.5));
   
   vineImage.center = correctedPosition;
   
   [self.containerView addSubview:vineImage];
   [vineImage release];
   
   // Add a gesture recognizer to handle the swipes
   UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
   panRecognizer.delegate = self;
   panRecognizer.minimumNumberOfTouches = 1;
   panRecognizer.maximumNumberOfTouches = 1;
   
   [self.containerView addGestureRecognizer:panRecognizer];
   [panRecognizer release];
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
   
   if (CGRectContainsPoint(self.leftVineSwipeableFrame, location))
   {
      //NSLog(@"applying impulse to left vine, force = %f,%f", force.x, force.y);
      
      [self.leftVineBody applyImpulse:CGPointMake(force.x, force.y) offset:cpvzero];
   }
   
   if (CGRectContainsPoint(self.rightVineSwipeableFrame, location))
   {
      //NSLog(@"applying impulse to right vine, force = %f,%f", force.x, force.y);
      
      [self.rightVineBody applyImpulse:CGPointMake(force.x, force.y) offset:cpvzero];
   }
   
   [panRecognizer setTranslation:CGPointZero inView:self.containerView];
}

#pragma mark UIGestureRecognizerDelegate protocol
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
   
   // is the user interacting with one of the vines?
   CGPoint touchLocation = [panRecognizer locationInView:self.containerView];
   
   CGRect leftVineFrame = self.leftVineSwipeableFrame;
   CGRect rightVineFrame = self.rightVineSwipeableFrame;
   
   if (CGRectContainsPoint(leftVineFrame, touchLocation)    ||
       CGRectContainsPoint(rightVineFrame, touchLocation))
   {
      result = YES;
   }
   
   return result;
}

@end
