// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ToyBoat.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TriggeredSpringAnimation.h"
#import "OALSimpleAudio.h"

#define kBoatLayerAnimationId             @"position"
#define kBoatLayerMovementCheckInterval   0.4f     // seconds
#define kSpringTriggerThreshold           500.0f   // points/second

#define kSpringMotionTerminatedNotification @"CH12_SPRING_MOTION_TERMINATED"

@interface AToyBoat (Private)
-(CABasicAnimation*)animation;
@end


@implementation AToyBoat

@synthesize islandLayer=fIslandLayer;
@synthesize waterLayer=fWaterLayer;
@synthesize boatLayer=fBoatLayer;

@synthesize minX=fMinX;
@synthesize maxX=fMaxX;
@synthesize minY=fMinY;
@synthesize maxY=fMaxY;

@synthesize springAnimation=fSpringAnimation;
@synthesize boatIsSwipeable = fBoatIsSwipeable;

@synthesize soundEffect=fSoundEffect;

-(void)dealloc
{ 
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   if (![@"" isEqualToString:fSoundEffect]) 
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fSoundEffect];
   }
   Release(fSoundEffect);
   
   Release(fSpringAnimation);
   
   self.islandLayer.delegate = nil;
   if (self.islandLayer.superlayer)
   {
      [self.islandLayer removeFromSuperlayer];
   }
   Release(fIslandLayer);
   
   self.boatLayer.delegate = nil;
   if (self.boatLayer.superlayer)
   {
      [self.boatLayer removeFromSuperlayer];
   }
   Release(fBoatLayer);
   
   self.waterLayer.delegate = nil;
   if (self.waterLayer.superlayer)
   {
      [self.waterLayer removeFromSuperlayer];
   }
   Release(fWaterLayer);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.minX = 0.0f;
   self.maxX = 0.0f;
   self.minY = 0.0f;
   self.maxY = 0.0f;
   
   self.boatIsSwipeable = NO;
   self.soundEffect = @"";
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.minX = element.minX;
   self.maxX = element.maxX;
   self.minY = element.minY;
   self.maxY = element.maxY;
   
   NSDictionary* layerSpec = nil;
   NSString* imagePath = nil;
   CALayer* aLayer = nil;
   UIImage* image = nil;
   
   // build the scene in this order:
   // island, water, boat
   
   ////////////////////////////////////////////////////////////////////////////////
   // island
   layerSpec = element.islandLayer;
   
   aLayer = [[CALayer alloc] init];
   self.islandLayer = aLayer;
   [aLayer release];
   
   self.islandLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.islandLayer setContents:(id)image.CGImage]; 
   [image release];
   [view.layer addSublayer:self.islandLayer];
      
   // water
   layerSpec = element.waterLayer;
   
   aLayer = [[CALayer alloc] init];
   self.waterLayer = aLayer;
   [aLayer release];
   
   self.waterLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.waterLayer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:self.waterLayer];
   
   
   // add a springy boat
   ATriggeredSpringAnimation* springyAnimation = [[ATriggeredSpringAnimation alloc] 
                                                  initWithElement:element.springAnimation 
                                                  RenderOnView:view];
   self.springAnimation = springyAnimation;
   [springyAnimation release];
   
   self.boatLayer = self.springAnimation.layer;
   
   self.boatIsSwipeable = YES;
   
   [view.layer addSublayer:self.boatLayer];
   
   // load the sound effect to be played when the ship is plunked
   self.soundEffect = element.shipPlunkSoundEffect;
   
   if (![@"" isEqualToString:self.soundEffect]) 
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.soundEffect];
   }
   
/*   // register for the notification that's issued by the springAnimation when
   // it completes
   [[NSNotificationCenter defaultCenter] 
    addObserver:self 
    selector:@selector(SpringMotionTerminated:) 
    name:kSpringMotionTerminatedNotification 
    object:nil];*/
}

-(CGPoint)MoveDeltaXY:(CGPoint)deltaXY
{    
   CGPoint currentPosition = self.boatLayer.position;
   
   CGPoint newPosition = CGPointMake(currentPosition.x+deltaXY.x, currentPosition.y+deltaXY.y);
   
   // clamp to min/max specified for this segment
   if (newPosition.y <= self.minY)
   {
      newPosition.y = self.minY;
   }
   else if (newPosition.y >= self.maxY)
   {
      newPosition.y = self.maxY;
   }
   
   if (newPosition.x <= self.minX)
   {
      newPosition.x = self.minX;
   }
   else if (newPosition.x >= self.maxX)
   {
      newPosition.x = self.maxX;
   }
   
   self.boatLayer.position = newPosition;
   
   return newPosition;
}

-(void)SpringMotionTerminated:(NSTimer*)timer
{
   self.boatIsSwipeable = YES;
}

#pragma mark ACustomAnimation protocol
// retrieve the latest results recorded by the pan gesture recognizer and
// translate the position on the movable layer of the image
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{
   // if the springAnimation is currently in progress, then don't allow
   // any translation of the layer
   if (!self.boatIsSwipeable)
   {
      return;
   }
    [NSTimer scheduledTimerWithTimeInterval:0.3 
                                     target:self 
                                   selector:@selector(SpringMotionTerminated:) 
                                   userInfo:nil 
                                    repeats:NO];
   
   UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
   
   CGPoint velocity = [recognizer velocityInView:self.containerView];
   
   if (velocity.y >= kSpringTriggerThreshold)
   {
      self.boatIsSwipeable = NO;
      
      [self.springAnimation Trigger];
      
      [[OALSimpleAudio sharedInstance] playEffect:self.soundEffect];
      
      [recognizer setTranslation:CGPointZero inView:self.containerView];
      
      return;
   }
   
//   CGPoint deltaXY = (CGPoint)[recognizer translationInView:self.containerView];
//   
//   [CATransaction begin];
//   
//   // disabling actions makes the animation of the layers smoother
//   [CATransaction setDisableActions:YES];
//   
//   [self MoveDeltaXY:deltaXY];
//   
//   [CATransaction commit];
   
   [recognizer setTranslation:CGPointZero inView:self.containerView];
}

-(void)Start:(BOOL)triggered
{
   self.boatIsSwipeable = YES;
}

-(void)Stop
{
   self.boatIsSwipeable = NO;
   
   [self.islandLayer removeAllAnimations];
   [self.boatLayer removeAllAnimations];
   [self.waterLayer removeAllAnimations];
}

@end
