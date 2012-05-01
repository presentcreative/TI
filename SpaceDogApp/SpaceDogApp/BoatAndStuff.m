// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "BoatAndStuff.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TriggeredSoundEffect.h"

#define kBobAnimationId    @"bobAnimation"
#define kStuffAnimationId  @"stuffAnimation"

@interface ABoatAndStuff (Private)
-(void)BuildStuffLayer;
@end

@implementation ABoatAndStuff

@synthesize stuffLayer=fStuffLayer;
@synthesize stuffLayerFrame=fStuffLayerFrame;
@synthesize stuffLayerPosition=fStuffLayerPosition;
@synthesize stuffLayerResource=fStuffLayerResource;
@synthesize boatLayer=fBoatLayer;
@synthesize soundEffect=fSoundEffect;
@synthesize yDelta=fYDelta;
@synthesize animationFired=fAnimationFired;
@synthesize stuffIsDraggable=fStuffIsDraggable;

-(void)dealloc
{   
   [fStuffLayer release];
   [fStuffLayerResource release];
   [fBoatLayer release];
   [(NSObject*)fSoundEffect release];
   
   [super dealloc];
}

-(void)BaseInit 
{
   [super BaseInit];
   
   self.yDelta = 0.0f;
   self.stuffLayerFrame = CGRectZero;
   self.stuffLayerPosition = CGPointZero;
   self.stuffLayerResource = @"";
   self.animationFired = NO;
   self.stuffIsDraggable = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   // load the sound effect
   id<ACustomAnimation> theSoundEffect = [[ATriggeredSoundEffect alloc] initWithElement:element.soundEffect RenderOnView:view];
   self.soundEffect = theSoundEffect;
   [(NSObject*)theSoundEffect release];
      
   NSDictionary* layerSpec = nil;
   NSString* imagePath = nil;
   UIImage* image = nil;
   
   // build the scene in this order:
   // stuff, boat, water
   
   ////////////////////////////////////////////////////////////////////////////////
   // stuff
   layerSpec = element.stuffLayer;
   self.stuffLayerFrame = layerSpec.frame;
   self.yDelta = layerSpec.yDelta;
   self.stuffLayerResource = layerSpec.resource;
   [self BuildStuffLayer];
   
   [self.containerView.layer addSublayer:self.stuffLayer];
   
   // boat
   layerSpec = element.boatLayer;
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.boatLayer = aLayer;
   [aLayer release];
   
   self.boatLayer.zPosition = 1;
   self.boatLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.boatLayer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:self.boatLayer];
   
   
   // water
   layerSpec = element.waterLayer;
   
   // we're not keeping a reference to the waterLayer as it's unnecessary to do so
   CALayer* waterLayer = [[CALayer alloc] init];;
   waterLayer.zPosition = 2;
   waterLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [waterLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [waterLayer setContents:(id)image.CGImage];  
   [image release];
   
   [view.layer addSublayer:waterLayer];
   [waterLayer release];
   
   // finally, add a gesture recognizer that will allow the reader to drag the stuff back to
   // its starting position
   UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
   panRecognizer.delegate = self;
   panRecognizer.minimumNumberOfTouches = 1;
   panRecognizer.maximumNumberOfTouches = 1;
   panRecognizer.cancelsTouchesInView = YES;
   
   [self.containerView addGestureRecognizer:panRecognizer];
   [panRecognizer release];
}

-(void)BuildStuffLayer
{
   if (nil != self.stuffLayer)
   {
      [self.stuffLayer removeFromSuperlayer];
   }
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.stuffLayer = aLayer;
   [aLayer release];
   
   self.stuffLayer.frame = self.stuffLayerFrame;
   self.stuffLayer.zPosition = 0;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:self.stuffLayerResource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.stuffLayer setContents:(id)image.CGImage]; 
   [image release];
}

// The stuff dropping animation
-(CABasicAnimation*)StuffAnimation
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"position"];
   [result setValue:@"stuffAnimation" forKey:@"animationKey"];
   result.delegate = self;
   
   result.removedOnCompletion = YES;
   result.fillMode = kCAFillModeRemoved;
   
   result.duration = 0.4f;
   
   result.repeatCount = 0;
   result.autoreverses = NO;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
      
   return result;
}

// The boat bobbing animation
-(CABasicAnimation*)BobAnimation
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"position"];
   
   [result setValue:kBobAnimationId forKey:@"animationId"];
   
   result.delegate = self;
   
   result.removedOnCompletion = YES;
   result.fillMode = kCAFillModeRemoved;
   
   result.duration = 0.8f;
   
   result.repeatCount = 0;
   result.autoreverses = YES;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      
   return result;
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   if (!triggered)
   {
      return;
   }
   
   if (self.animationFired)
   {
      return;
   }
   
   // save the original position of the stuff layer
   self.stuffLayerPosition = self.stuffLayer.position;
   
   CABasicAnimation* theAnimation = [self StuffAnimation];
   
   [theAnimation setValue:kStuffAnimationId forKey:@"animationId"];
   
   CGPoint stuffLayerPosition = self.stuffLayer.position;
   CGPoint newStuffLayerPosition = CGPointMake(stuffLayerPosition.x, stuffLayerPosition.y+self.yDelta);
   
   NSValue* currentPositionValue = [NSValue valueWithCGPoint:stuffLayerPosition];
   NSValue* newPositionValue = [NSValue valueWithCGPoint:newStuffLayerPosition];
   
   theAnimation.fromValue = currentPositionValue;
   theAnimation.toValue = newPositionValue;   
   
   [CATransaction begin];
   
   self.stuffLayer.position = newStuffLayerPosition;
   [self.stuffLayer addAnimation:theAnimation forKey:@"position"];
   
   [CATransaction commit];
   
   self.animationFired = YES;
}

-(void)Stop
{
   [super Stop];
   
   [self.stuffLayer removeAllAnimations];
   [self.boatLayer removeAllAnimations];
   
   self.stuffLayer.position = self.stuffLayerPosition;
   self.stuffIsDraggable = NO;   
   self.animationFired = NO;
}

-(void)HandleGesture:(UIGestureRecognizer*)recognizer
{
   if (!self.stuffIsDraggable)
   {
      return;
   }
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)recognizer;
   
   CGPoint deltaXY = [panRecognizer translationInView:self.containerView];
   
   // only interested in the (upward) y component of the motion
   if (0.0f > deltaXY.y)
   {
      CGFloat maxYDistanceToMove = MAX(self.stuffLayer.position.y - self.stuffLayerPosition.y, 0.0f);
      
      if (0.0f == maxYDistanceToMove)
      {
         // we're done
         self.stuffIsDraggable = NO;
         self.animationFired = NO;
         
         return;
      }
                  
      CGFloat yDistanceToMove = maxYDistanceToMove;
      
      if (fabs(deltaXY.y) <= maxYDistanceToMove)
      {
         yDistanceToMove = fabs(deltaXY.y);
      }
      
      [CATransaction begin];
      [CATransaction setDisableActions:YES];
      
      self.stuffLayer.position = CGPointMake(self.stuffLayerPosition.x, self.stuffLayer.position.y-yDistanceToMove);
      
      [CATransaction commit];
   }
   
   [panRecognizer setTranslation:CGPointZero inView:self.containerView];
}

#pragma mark -
#pragma mark CAAnimation delegate protocol
-(void)animationDidStop:(CABasicAnimation*)anim finished:(BOOL)animationFinished
{
   NSString* animationId = [anim valueForKey:@"animationId"];
   
   if (animationFinished)
   {
      if ([kStuffAnimationId isEqualToString:animationId])
      {
         // apply the bob animation to both the stuff and the boat
         CABasicAnimation* bobStuffAnimation = [self BobAnimation];
         
         CGPoint currentLayerPosition = CGPointZero;
         CGPoint newStuffLayerPosition = CGPointZero;
         CGPoint newBoatLayerPosition = CGPointZero;
         
         currentLayerPosition = self.stuffLayer.position;
         newStuffLayerPosition = CGPointMake(currentLayerPosition.x, currentLayerPosition.y+30.0f);
         
         NSValue* currentPositionValue = [NSValue valueWithCGPoint:currentLayerPosition];
         NSValue* newPositionValue = [NSValue valueWithCGPoint:newStuffLayerPosition];
         
         bobStuffAnimation.fromValue = currentPositionValue;
         bobStuffAnimation.toValue = newPositionValue;
         
         
         CABasicAnimation* bobBoatAnimation = [self BobAnimation];
         
         currentLayerPosition = self.boatLayer.position;
         newBoatLayerPosition = CGPointMake(currentLayerPosition.x, currentLayerPosition.y+30.0f);
         
         currentPositionValue = [NSValue valueWithCGPoint:currentLayerPosition];
         newPositionValue = [NSValue valueWithCGPoint:newBoatLayerPosition];
         
         bobBoatAnimation.fromValue = currentPositionValue;
         bobBoatAnimation.toValue = newPositionValue;
         
         // finally, run the animations together
         [CATransaction begin];
         
         [self.soundEffect Trigger];
         
         [self.stuffLayer addAnimation:bobStuffAnimation forKey:@"position"];
         
         [self.boatLayer addAnimation:bobBoatAnimation forKey:@"position"];
         
         [CATransaction commit];
      }
      else if ([kBobAnimationId isEqualToString:animationId])
      {
         self.stuffIsDraggable = YES;
      }
   }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate protocol
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
   // the gesture recognizer is only engaged if the "stuff" is currently draggable
   if (!self.stuffIsDraggable)
   {
      return NO;
   }
   
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
   
   CGPoint touchLocation = [panRecognizer locationInView:self.containerView];
   
   if (CGRectContainsPoint(self.stuffLayer.frame, touchLocation))
   {
      return YES;
   }
   
   return NO;
}

@end
