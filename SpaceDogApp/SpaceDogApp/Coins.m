// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Coins.h"
#import "ObjectiveChipmunk.h"
#import "NSDictionary+ElementAndPropertyValues.h"

#define kPhysicsTimeInterval 0.03f
#define kCoinMass 150.0f

#define kCoin1ImageViewTag 201
#define kCoin2ImageViewTag 202
#define kCoin3ImageViewTag 203
#define kCoin4ImageViewTag 204
#define kCoin5ImageViewTag 205

@interface ACoins (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

@end


@implementation ACoins

@synthesize physicsTimer=fPhysicsTimer;
@synthesize coin1Body=fCoin1Body;
@synthesize coin1Shape=fCoin1Shape;
@synthesize coin2Body=fCoin2Body;
@synthesize coin2Shape=fCoin2Shape;
@synthesize coin3Body=fCoin3Body;
@synthesize coin3Shape=fCoin3Shape;
@synthesize coin4Body=fCoin4Body;
@synthesize coin4Shape=fCoin4Shape;
@synthesize coin5Body=fCoin5Body;
@synthesize coin5Shape=fCoin5Shape;

-(UIImageView*)coin1ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoin1ImageViewTag];
}

-(UIImageView*)coin2ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoin2ImageViewTag];
}

-(UIImageView*)coin3ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoin3ImageViewTag];
}

-(UIImageView*)coin4ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoin4ImageViewTag];
}

-(UIImageView*)coin5ImageView
{
   return (UIImageView*)[self.containerView viewWithTag:kCoin5ImageViewTag];
}

-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of Coconut physics engine.");
      return;      
   }
   
   [super SetupPhysics];
      
   [self.physicsSpace addBounds:self.containerView.bounds 
                      thickness:300.0f 
                     elasticity:1.0f 
                       friction:1.0f 
                         layers:CP_ALL_LAYERS 
                          group:CP_NO_GROUP 
                  collisionType:kWall];
      
   CGFloat coinWidth = 0.0f;
   CGFloat coinHeight = 0.0f;
   
   // coin 1
   coinWidth = self.coin1ImageView.frame.size.width;
   coinHeight = self.coin1ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the coconut
   self.coin1Body = [ChipmunkBody bodyWithMass:kCoinMass 
                                       andMoment:cpMomentForBox(kCoinMass, coinWidth, coinHeight)];
   
   // Set its initial position.
   self.coin1Body.pos = self.coin1ImageView.center;
   self.coin1Body.force = cpvzero;
   
   // Give it a shape
   self.coin1Shape = [ChipmunkPolyShape boxWithBody:self.coin1Body width:coinWidth height:coinHeight];
   self.coin1Shape.elasticity = .5;
   self.coin1Shape.friction = .5;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.coin1Body];
   [self.physicsSpace addShape:self.coin1Shape];
   
   
   // coin 2
   coinWidth = self.coin2ImageView.frame.size.width;
   coinHeight = self.coin2ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the coconut
   self.coin2Body = [ChipmunkBody bodyWithMass:kCoinMass 
                                     andMoment:cpMomentForBox(kCoinMass, coinWidth, coinHeight)];
   
   // Set its initial position.
   self.coin2Body.pos = self.coin2ImageView.center;
   self.coin2Body.force = cpvzero;
   
   // Give it a shape (autoreleased?)
   self.coin2Shape = [ChipmunkPolyShape boxWithBody:self.coin2Body width:coinWidth height:coinHeight];
   self.coin2Shape.elasticity = .5;
   self.coin2Shape.friction = .5;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.coin2Body];
   [self.physicsSpace addShape:self.coin2Shape];  
   
   
   // coin 3
   coinWidth = self.coin3ImageView.frame.size.width;
   coinHeight = self.coin3ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the coconut
   self.coin3Body = [ChipmunkBody bodyWithMass:kCoinMass 
                                     andMoment:cpMomentForBox(kCoinMass, coinWidth, coinHeight)];
   
   // Set its initial position.
   self.coin3Body.pos = self.coin3ImageView.center;
   self.coin3Body.force = cpvzero;
   
   // Give it a shape (autoreleased?)
   self.coin3Shape = [ChipmunkPolyShape boxWithBody:self.coin3Body width:coinWidth height:coinHeight];
   self.coin3Shape.elasticity = .5;
   self.coin3Shape.friction = .5;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.coin3Body];
   [self.physicsSpace addShape:self.coin3Shape];
   
   
   // coin 4
   coinWidth = self.coin4ImageView.frame.size.width;
   coinHeight = self.coin4ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the coconut
   self.coin4Body = [ChipmunkBody bodyWithMass:kCoinMass 
                                     andMoment:cpMomentForBox(kCoinMass, coinWidth, coinHeight)];
   
   // Set its initial position.
   self.coin4Body.pos = self.coin4ImageView.center;
   self.coin4Body.force = cpvzero;
   
   // Give it a shape (autoreleased?)
   self.coin4Shape = [ChipmunkPolyShape boxWithBody:self.coin4Body width:coinWidth height:coinHeight];
   self.coin4Shape.elasticity = .5;
   self.coin4Shape.friction = .5;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.coin4Body];
   [self.physicsSpace addShape:self.coin4Shape];
   
   
   // coin 5
   coinWidth = self.coin5ImageView.frame.size.width;
   coinHeight = self.coin5ImageView.frame.size.height;
   
   // Create the chunk of mass that represents the coconut
   self.coin5Body = [ChipmunkBody bodyWithMass:kCoinMass 
                                     andMoment:cpMomentForBox(kCoinMass, coinWidth, coinHeight)];
   
   // Set its initial position.
   self.coin5Body.pos = self.coin5ImageView.center;
   self.coin5Body.force = cpvzero;
   
   // Give it a shape (autoreleased?)
   self.coin5Shape = [ChipmunkPolyShape boxWithBody:self.coin5Body width:coinWidth height:coinHeight];
   self.coin5Shape.elasticity = .5;
   self.coin5Shape.friction = .5;
   
   // Bind these to the space
   [self.physicsSpace addBody:self.coin5Body];
   [self.physicsSpace addShape:self.coin5Shape];
   
   // add a collision handler so that we can play some sound effects at appropriate times
   [self InitializeCollisionDetection];
}

-(void)StopPhysics
{   
   [super StopPhysics];
   
   Release(fCoin1Body);
   fCoin1Body = nil;
   Release(fCoin1Shape);
   fCoin1Shape = nil;

   Release(fCoin2Body);
   fCoin2Body = nil;
   Release(fCoin2Shape);
   fCoin2Shape = nil;
   
   Release(fCoin3Body);
   fCoin3Body = nil;
   Release(fCoin3Shape);
   fCoin3Shape = nil;
   
   Release(fCoin4Body);
   fCoin4Body = nil;
   Release(fCoin4Shape);
   fCoin4Shape = nil;
   
   Release(fCoin5Body);
   fCoin5Body = nil;
   Release(fCoin5Shape);
   fCoin5Shape = nil;
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
   self.coin1ImageView.center = self.coin1Body.pos;
   self.coin1ImageView.transform = CGAffineTransformMakeRotation(self.coin1Body.angle);

   self.coin2ImageView.center = self.coin2Body.pos;
   self.coin2ImageView.transform = CGAffineTransformMakeRotation(self.coin2Body.angle);
   
   self.coin3ImageView.center = self.coin3Body.pos;
   self.coin3ImageView.transform = CGAffineTransformMakeRotation(self.coin3Body.angle);
   
   self.coin4ImageView.center = self.coin4Body.pos;
   self.coin4ImageView.transform = CGAffineTransformMakeRotation(self.coin4Body.angle);
   
   self.coin5ImageView.center = self.coin5Body.pos;
   self.coin5ImageView.transform = CGAffineTransformMakeRotation(self.coin5Body.angle);
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
   
   UIImage* image = nil;
   UIImageView* coinImageView = nil;
   NSDictionary* layerSpec = nil;
   
   // coin 1
   layerSpec = element.coin1;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   coinImageView = [[UIImageView alloc] initWithImage:image];
   [image release];
   coinImageView.frame = layerSpec.frame;
   coinImageView.tag = kCoin1ImageViewTag;
   [self.containerView addSubview:coinImageView];
   [coinImageView release];
   
   
   // coin 2
   layerSpec = element.coin2;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      return;
   }
      
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   coinImageView = [[UIImageView alloc] initWithImage:image];
   [image release];
   coinImageView.frame = layerSpec.frame;
   coinImageView.tag = kCoin2ImageViewTag;
   [self.containerView addSubview:coinImageView];
   [coinImageView release];   
   
   
   // coin 3
   layerSpec = element.coin3;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   coinImageView = [[UIImageView alloc] initWithImage:image];
   [image release];
   coinImageView.frame = layerSpec.frame;
   coinImageView.tag = kCoin3ImageViewTag;
   [self.containerView addSubview:coinImageView];
   [coinImageView release];
   
   
   // coin 4
   layerSpec = element.coin4;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   coinImageView = [[UIImageView alloc] initWithImage:image];
   [image release];
   coinImageView.frame = layerSpec.frame;
   coinImageView.tag = kCoin4ImageViewTag;
   [self.containerView addSubview:coinImageView];
   [coinImageView release];
   
   
   // coin 5
   layerSpec = element.coin5;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   coinImageView = [[UIImageView alloc] initWithImage:image];
   [image release];
   coinImageView.frame = layerSpec.frame;
   coinImageView.tag = kCoin5ImageViewTag;
   [self.containerView addSubview:coinImageView];
   [coinImageView release];
   
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
   
   if (CGRectContainsPoint(self.coin1ImageView.frame, location))
   {      
      offset = [recognizer locationInView:self.coin1ImageView];
      
      [self.coin1Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
   }
   
   if (CGRectContainsPoint(self.coin2ImageView.frame, location))
   {
      offset = [recognizer locationInView:self.coin2ImageView];
      
      [self.coin2Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
   }
   
   if (CGRectContainsPoint(self.coin3ImageView.frame, location))
   {
      offset = [recognizer locationInView:self.coin3ImageView];
      
      [self.coin3Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
   }
   
   if (CGRectContainsPoint(self.coin4ImageView.frame, location))
   {
      offset = [recognizer locationInView:self.coin4ImageView];
      
      [self.coin4Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
   }
   
   if (CGRectContainsPoint(self.coin5ImageView.frame, location))
   {
      offset = [recognizer locationInView:self.coin5ImageView];
      
      [self.coin5Body applyImpulse:CGPointMake(force.x*100.0f, force.y*100.0f) offset:offset];
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
   
   if (CGRectContainsPoint(self.coin1ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.coin2ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.coin3ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.coin4ImageView.frame, touchLocation) ||
       CGRectContainsPoint(self.coin5ImageView.frame, touchLocation))
   {
      result = YES;
   }
   
   return result;
}

@end
