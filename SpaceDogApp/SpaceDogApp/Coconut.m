// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Coconut.h"
#import "ObjectiveChipmunk.h"
#import "NSDictionary+ElementAndPropertyValues.h"

#define kPhysicsTimeInterval .03f
#define kCoconutMass 300.0f

#define kCoconut1ImageViewTag 201
#define kCoconut2ImageViewTag 202
#define kCoconut3ImageViewTag 203

@interface ACoconut (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

@end


@implementation ACoconut

@synthesize coconut1Body=fCoconut1Body;
@synthesize coconut1Shape=fCoconut1Shape;
@synthesize coconut2Body=fCoconut2Body;
@synthesize coconut2Shape=fCoconut2Shape;
@synthesize coconut3Body=fCoconut3Body;
@synthesize coconut3Shape=fCoconut3Shape;

-(UIImageView*)coconut1ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoconut1ImageViewTag];
}

-(UIImageView*)coconut2ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoconut2ImageViewTag];
}

-(UIImageView*)coconut3ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoconut3ImageViewTag];
}

-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Coconut physics engine.");
      return;      
   }
   
   [super SetupPhysics];

   // create some "walls" for the coconuts to bounce off of
   [self.physicsSpace addBounds:self.containerView.bounds 
                      thickness:300.0f 
                     elasticity:1.0f 
                       friction:1.0f 
                         layers:CP_ALL_LAYERS 
                          group:CP_NO_GROUP 
                  collisionType:kWall];
            
   CGFloat coconutWidth = self.coconut1ImageView.frame.size.width;
   CGFloat coconutHeight = self.coconut1ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the coconuts
   ChipmunkBody* body = nil;
   ChipmunkShape* shape = nil;
   
   // coconut 1
   body = [[ChipmunkBody alloc] initWithMass:kCoconutMass andMoment:cpMomentForBox(kCoconutMass, coconutWidth, coconutHeight)];
   self.coconut1Body = body;
   [body release];
   
   // Set its initial position.
   self.coconut1Body.pos = self.coconut1ImageView.center;
   self.coconut1Body.force = cpvzero;

   // Bind these to the space
   [self.physicsSpace addBody:self.coconut1Body];
   
   // Give it a shape
   shape = [[ChipmunkPolyShape alloc] initBoxWithBody:self.coconut1Body width:coconutWidth height:coconutHeight];
   self.coconut1Shape = shape;
   [shape release];
   
   self.coconut1Shape.elasticity = .5;
   self.coconut1Shape.friction = .5;
   
   [self.physicsSpace addShape:self.coconut1Shape];
   
   // coconut 2
   body = [[ChipmunkBody alloc] initWithMass:kCoconutMass andMoment:cpMomentForBox(kCoconutMass, coconutWidth, coconutHeight)];
   self.coconut2Body = body;
   [body release];
   
   // Set its initial position.
   self.coconut2Body.pos = self.coconut2ImageView.center;
   self.coconut2Body.force = cpvzero;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.coconut2Body];
   
   // Give it a shape
   shape = [[ChipmunkPolyShape alloc] initBoxWithBody:self.coconut2Body width:coconutWidth height:coconutHeight];
   self.coconut2Shape = shape;
   [shape release];
   
   self.coconut2Shape.elasticity = .5;
   self.coconut2Shape.friction = .5;
   
   [self.physicsSpace addShape:self.coconut2Shape];
   
   // coconut 3
   body = [[ChipmunkBody alloc] initWithMass:kCoconutMass andMoment:cpMomentForBox(kCoconutMass, coconutWidth, coconutHeight)];
   self.coconut3Body = body;
   [body release];
   
   // Set its initial position.
   self.coconut3Body.pos = self.coconut3ImageView.center;
   self.coconut3Body.force = cpvzero;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.coconut3Body];
   
   // Give it a shape
   shape = [[ChipmunkPolyShape alloc] initBoxWithBody:self.coconut3Body width:coconutWidth height:coconutHeight];
   self.coconut3Shape = shape;
   [shape release];
   
   self.coconut3Shape.elasticity = .5;
   self.coconut3Shape.friction = .5;
   
   [self.physicsSpace addShape:self.coconut3Shape];
   
   // add a collision handler so that we can play some sound effects at appropriate times
   [self InitializeCollisionDetection];
}

-(void)StopPhysics
{   
   [super StopPhysics];
   
   Release(fCoconut1Body);
   fCoconut1Body = nil;
   
   Release(fCoconut1Shape);
   fCoconut1Shape = nil;
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
   self.coconut1ImageView.center = self.coconut1Body.pos;
   self.coconut1ImageView.transform = CGAffineTransformMakeRotation(self.coconut1Body.angle);
   
   self.coconut2ImageView.center = self.coconut2Body.pos;
   self.coconut2ImageView.transform = CGAffineTransformMakeRotation(self.coconut2Body.angle);
   
   self.coconut3ImageView.center = self.coconut3Body.pos;
   self.coconut3ImageView.transform = CGAffineTransformMakeRotation(self.coconut3Body.angle);
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
         
   // now, set the image of the coconut
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:element.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", element.resource);
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   
   NSDictionary* layerSpec = nil;
   UIImageView* coconutImageView = nil;
   
   // coconut 1
   layerSpec = element.coconut1Layer;
   
   coconutImageView = [[UIImageView alloc] initWithImage:image];
   coconutImageView.frame = layerSpec.frame;
   coconutImageView.tag = kCoconut1ImageViewTag;
   [self.containerView addSubview:coconutImageView];
   [coconutImageView release];
   
   // coconut 2
   layerSpec = element.coconut2Layer;
   
   coconutImageView = [[UIImageView alloc] initWithImage:image];
   coconutImageView.frame = layerSpec.frame;
   coconutImageView.tag = kCoconut2ImageViewTag;
   [self.containerView addSubview:coconutImageView];
   [coconutImageView release];
   
   // coconut 3
   layerSpec = element.coconut3Layer;
   
   coconutImageView = [[UIImageView alloc] initWithImage:image];
   coconutImageView.frame = layerSpec.frame;
   coconutImageView.tag = kCoconut3ImageViewTag;
   [self.containerView addSubview:coconutImageView];
   [coconutImageView release];
   
   [image release];
   
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
   
   CGPoint touchLocation = [recognizer locationInView:self.containerView];
   CGPoint offset = CGPointZero;
   
   if (CGRectContainsPoint(self.coconut1ImageView.frame, touchLocation))
   {
      offset = [recognizer locationInView:self.coconut1ImageView];
      
      [self.coconut1Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
      
   }
      
   if (CGRectContainsPoint(self.coconut2ImageView.frame, touchLocation)) 
   {
      offset = [recognizer locationInView:self.coconut2ImageView];
      
      [self.coconut2Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
   }
       
   if (CGRectContainsPoint(self.coconut3ImageView.frame, touchLocation))
   {
      offset = [recognizer locationInView:self.coconut3ImageView]; 
      
      [self.coconut3Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
   }

   [panRecognizer setTranslation:CGPointZero inView:self.containerView];
}

#pragma mark UIGestureRecognizerDelegate protocol
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
   
   // is the user interacting with one of the pottery shards?
   CGPoint touchLocation = [panRecognizer locationInView:self.containerView];
   
   if (CGRectContainsPoint(self.coconut1ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.coconut2ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.coconut3ImageView.frame, touchLocation))
   {
      result = YES;
   }
   
   return result;
}

@end
