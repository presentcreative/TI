// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ACane.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "ObjectiveChipmunk.h"

#define kPhysicsTimeInterval .03f
#define kPhysicsGravityVector CGPointMake(0.0,500.0)
#define kCaneMass 300.0f
#define kCaneForceScale 10.0f

#define kCaneViewTag 300

@interface ACane (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

-(UIImageView*)caneView;

-(void)StartCaneSpinning;

@end

@implementation ACane

-(UIImageView*)caneView
{
   return (UIImageView*)[self.containerView viewWithTag:kCaneViewTag];
}

-(CGPoint)gravityVector
{
   return CGPointMake(0.0f, 0.0f);
}


-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Sign physics engine.");
      return;      
   }
   
   [super SetupPhysics];

   // Override the default gravity vector
    fPhysicsSpace.gravity = kPhysicsGravityVector;
      
   [fPhysicsSpace addBounds:self.containerView.bounds 
                      thickness:300.0f 
                     elasticity:1.0f 
                       friction:1.0f 
                         layers:CP_ALL_LAYERS 
                          group:CP_NO_GROUP 
                  collisionType:kWall];
   
   CGRect caneFrame = self.caneView.frame;
   
   CGFloat caneWidth = caneFrame.size.width;;
   CGFloat caneHeight = caneFrame.size.height;
   
   // Create the chunk of mass that represents the cane
   fCaneBody =  [[ChipmunkBody alloc] initWithMass:kCaneMass andMoment:cpMomentForBox(kCaneMass, caneWidth, caneHeight)];
   
   // Set its initial position.
   //fCaneBody.pos = CGPointMake(caneWidth/2.0f, caneHeight/2.0f); 
   fCaneBody.pos = self.caneView.center;
   
   // Give it a shape
   fCaneShape = [[ChipmunkPolyShape alloc] initBoxWithBody:fCaneBody width:caneWidth height:caneHeight];
   fCaneShape.elasticity = .5;
   fCaneShape.friction = .5;
   
   // Bind these to the space
   [fPhysicsSpace addBody:fCaneBody];
   [fPhysicsSpace addShape:fCaneShape];
   
   // add a collision handler so that we can play some sound effects at appropriate times
   [self InitializeCollisionDetection];
}

-(void)StopPhysics
{   
   [super StopPhysics];
   
   Release(fCaneBody);
   fCaneBody = nil;
   
   Release(fCaneShape);
   fCaneShape = nil;
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
   //NSLog( @"Chipmunk cane pos/angle: (%.02f %.02f) @ %.02f", 
   //      fCaneBody.pos.x, fCaneBody.pos.y, fCaneBody.angle );
   
   // translate/rotate the cane according to the simulation
   self.caneView.center = fCaneBody.pos;
   self.caneView.transform = CGAffineTransformMakeRotation(fCaneBody.angle);
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
      
   // set the image of the cane
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:element.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", element.resource);
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   UIImageView* caneView = [[UIImageView alloc] initWithImage:image];
   [image release];
   
   CGRect caneFrame = element.frame;
   caneView.frame = caneFrame;
   caneView.tag = kCaneViewTag;
      
   [self.containerView addSubview:caneView];
   [caneView release];

   
   // attach a gesture recognizer so that we can accept input from the user
   UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
   recognizer.delegate = self;
   recognizer.minimumNumberOfTouches = 1;
   recognizer.maximumNumberOfTouches = 1;
   
   [self.containerView addGestureRecognizer:recognizer];
   [recognizer release];
}

-(void)StartCaneSpinning
{
   [fCaneBody applyImpulse:CGPointMake(-2000.0f, 12000.0f) offset:CGPointMake(self.caneView.frame.size.width/2.0f, self.caneView.frame.size.height/2.0f)];   
}

#pragma mark -
#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [super Start:triggered];
   
   [self StartCaneSpinning];
}

-(void)HandleGesture:(UIGestureRecognizer *)recognizer
{
   if (!self.isAnimating)
   {
      //Nothing to do if physics isn't running here
      return;
   }
   
   if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]])
   {
      UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)recognizer;
      
      CGPoint force = [panRecognizer velocityInView:self.containerView];
      
      CGPoint offset = [panRecognizer locationInView:self.caneView];
                  
      [fCaneBody applyImpulse:CGPointMake(force.x*kCaneForceScale, force.y*kCaneForceScale) offset:offset];
      
      //NSLog(@"applied impulse of %@ at offset %@", NSStringFromCGPoint(force), NSStringFromCGPoint(offset));
      
      [panRecognizer setTranslation:CGPointZero inView:self.containerView];
   }
}

#pragma mark UIGestureRecognizerDelegate protocol
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
   
   // is the user interacting with Pew's cane?
   CGPoint touchLocation = [panRecognizer locationInView:self.containerView];
   
   if (CGRectContainsPoint(self.caneView.frame, touchLocation))
   {
      result = YES;
   }
   
   return result;
}

@end
