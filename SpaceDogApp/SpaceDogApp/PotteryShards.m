// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PotteryShards.h"
#import "ObjectiveChipmunk.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import <objc/runtime.h>

#define kPhysicsTimeInterval .03f
#define kPhysicsGravityVector CGPointMake(0.0,500.0)
#define kPhysicsGlobalDamping 0.75f
#define kShardMass 300.0f
#define kMaxShards 9
#define kShardViewBaseTag 200

#define kPotteryShardForceScale 100.0f


@interface APotteryShards (Private)

-(void)SetupPhysics;

-(void)StartPhysics;
-(void)StopPhysics;

-(void)TickPhysics;
-(void)AnimatePhysics;

@end

@implementation APotteryShards

@synthesize shardBodies=fShardBodies;
@synthesize shardShapes=fShardShapes;

-(UIImageView*)ShardViewAtIndex:(NSUInteger)shardIndex
{
   return (UIImageView*)[self.containerView viewWithTag:kShardViewBaseTag+shardIndex];
}

-(void)SetupPhysics
{
   if (nil != fPhysicsSpace)
   {
      NSAssert(nil == fPhysicsSpace, @"Unexpected reconfiguration of PotteryShards physics engine.");
      return;      
   }
   
   [super SetupPhysics];
      
   // continue with the never-ending quest to relieve pressure on the autorelease pool...
   NSMutableArray* bodiesAndShapes = nil;
   
   bodiesAndShapes = [[NSMutableArray alloc] initWithCapacity:kMaxShards];
   self.shardBodies = bodiesAndShapes;
   [bodiesAndShapes release];
   
   bodiesAndShapes = [[NSMutableArray alloc] initWithCapacity:kMaxShards];
   self.shardShapes = bodiesAndShapes;
   [bodiesAndShapes release];
   
   ChipmunkBody* shardBody = nil;
   ChipmunkShape* shardShape = nil;
   
   for (NSUInteger i = 0; i < kMaxShards; i++)
   {
      UIImageView* shardView = [self ShardViewAtIndex:i];
      
      CGFloat shardX = shardView.frame.origin.x;
      CGFloat shardY = shardView.frame.origin.y;
      
      CGFloat shardWidth = shardView.frame.size.width;
      CGFloat shardHeight = shardView.frame.size.height;
      
      // Create the chunk of mass that represents the shard
      shardBody = [[ChipmunkBody alloc] initWithMass:kShardMass andMoment:cpMomentForBox(kShardMass, shardWidth, shardHeight)];
      
      // Set its initial position.
      shardBody.pos = CGPointMake(shardX + shardWidth/2.0f, 
                                  shardY + shardHeight/2.0f);
      
      shardBody.force = cpvzero;
      
      // Give it a shape
      shardShape = [[ChipmunkPolyShape alloc] initBoxWithBody:shardBody width:shardWidth height:shardHeight];
      shardShape.elasticity = .5;
      shardShape.friction = .5;
      
      // Bind these to the space
      [fPhysicsSpace addBody:shardBody];      
      [fPhysicsSpace addShape:shardShape];
      
      [self.shardBodies addObject:shardBody];
      [shardBody release];
      
      [self.shardShapes addObject:shardShape]; 
      [shardShape release];
   }
      
   // pottery shard movement is restricted to just the floor area
   [fPhysicsSpace addBounds:CGRectMake(0.0f, 420.0f, 1024.0f, 308.0f) 
                      thickness:300.0f 
                     elasticity:1.0f 
                       friction:1.0f 
                         layers:CP_ALL_LAYERS 
                          group:CP_NO_GROUP 
                  collisionType:kWall];
   
   // Note that collision detection should only be enabled AFTER bounds are
   // added to the space...
   [self InitializeCollisionDetection];
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
   // animate per physics
   for (NSUInteger i = 0; i < kMaxShards; i++)
   {
      UIImageView* shardView = [self ShardViewAtIndex:i];
      ChipmunkBody* shardBody = [self.shardBodies objectAtIndex:i];
      
      shardView.center = shardBody.pos;
      shardView.transform = CGAffineTransformMakeRotation(shardBody.angle);
   }
}

-(void)dealloc
{   
   Release(fShardBodies);
   Release(fShardShapes);

   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
      
   NSString* imagePath = nil;
   
   // create and populate each of the individual shards
   int shardCount = 0;
   
   for (NSDictionary* shardDescriptor in element.resources)
   {
      imagePath = [[NSBundle mainBundle] pathForResource:shardDescriptor.resource ofType:nil];
      
      if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
      {
         ALog(@"Image file missing: %@", shardDescriptor.resource);
         
         return;
      }
      
      UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
      UIImageView* shardView = [[UIImageView alloc] initWithImage:image];
      [image release];
      shardView.tag = kShardViewBaseTag+shardCount;
      shardView.frame = shardDescriptor.frame;
      [self.containerView addSubview:shardView];
      [shardView release];
      
      shardCount++;
   }
      
   // attach a gesture recognizer so that we can accept input from the user
   UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(HandleGesture:)];
   recognizer.delegate = self;
   recognizer.minimumNumberOfTouches = 1;
   recognizer.maximumNumberOfTouches = 1;
   
   [self.containerView addGestureRecognizer:recognizer];
   [recognizer release];
}

-(CGFloat)ImpactThresholdLow
{
   return 100.0f;
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
      
   for (NSUInteger i = 0; i < kMaxShards; i++)
   {
      UIImageView* shardView = [self ShardViewAtIndex:i];
      ChipmunkBody* shardBody = [self.shardBodies objectAtIndex:i];
      
      if (CGRectContainsPoint(shardView.frame, location))
      {
         //NSLog(@"applying impulse, force = %f,%f", force.x, force.y);
         
         CGPoint offset = [recognizer locationInView:shardView];

         [shardBody applyImpulse:CGPointMake(force.x*kPotteryShardForceScale, force.y*kPotteryShardForceScale) offset:offset];
      }
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
   
   for (NSUInteger i = 0; i < kMaxShards; i++)
   {
      UIImageView* shardView = [self ShardViewAtIndex:i];
      
      if (CGRectContainsPoint(shardView.frame, touchLocation))
      {
         result = YES;
         
         break;
      }
   }
   
   return result;
}

@end
