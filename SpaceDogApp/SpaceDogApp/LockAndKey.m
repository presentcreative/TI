// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "LockAndKey.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Trigger.h"
#import "OALSimpleAudio.h"

#define kLockOpenDistance  20.0f

@interface ALockAndKey (Private)
-(CGFloat)MoveDeltaX:(CGFloat)deltaX;
-(void)UnlockTheLock;
-(void)LockTheLock;
@end


@implementation ALockAndKey

@synthesize keyLayer = fKeyLayer;
@synthesize leftLockLayer = fLeftLockLayer;
@synthesize innerLockLayer = fInnerLockLayer;
@synthesize rightLockLayer = fRightLockLayer;
@synthesize barLayer = fBarLayer;
@synthesize minX = fMinX;
@synthesize maxX = fMaxX;
@synthesize lockThreshold = fLockThreshold;
@synthesize unlockThreshold = fUnlockThreshold;
@synthesize lockOpen = fLockOpen;
@synthesize unlockSoundEffect=fUnlockSoundEffect;
@synthesize lockSoundEffect=fLockSoundEffect;

-(void)dealloc
{
   self.keyLayer.delegate = nil;
   if (self.keyLayer.superlayer)
   {
      [self.keyLayer removeFromSuperlayer];
   }
   Release(fKeyLayer);
   
   self.leftLockLayer.delegate = nil;
   if (self.leftLockLayer.superlayer)
   {
      [self.leftLockLayer removeFromSuperlayer];
   }
   Release(fLeftLockLayer);
   
   self.innerLockLayer.delegate = nil;
   if (self.innerLockLayer.superlayer)
   {
      [self.innerLockLayer removeFromSuperlayer];
   }
   Release(fInnerLockLayer);
   
   self.rightLockLayer.delegate = nil;
   if (self.rightLockLayer.superlayer)
   {
      [self.rightLockLayer removeFromSuperlayer];
   }
   Release(fRightLockLayer);
   
   self.barLayer.delegate = nil;
   if (self.barLayer.superlayer)
   {
      [self.barLayer removeFromSuperlayer];
   }
   Release(fBarLayer);
   
   if (![@"" isEqualToString:fUnlockSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fUnlockSoundEffect];
   }
   Release(fUnlockSoundEffect);
   
   if (![@"" isEqualToString:fLockSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fLockSoundEffect];
   }
   Release(fLockSoundEffect);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.minX = 0.0f;
   self.maxX = 0.0f;
   self.lockThreshold = 0.0f;
   self.unlockThreshold = 0.0f;
   self.lockOpen = NO;
   self.lockSoundEffect = @"";
   self.unlockSoundEffect = @"";
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
      
   self.lockThreshold = element.lockThreshold;
   self.unlockThreshold = element.unlockThreshold;
   
   self.unlockSoundEffect = element.unlockSoundEffect;
   
   if (![@"" isEqualToString:self.unlockSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.unlockSoundEffect];
   }
   
   self.lockSoundEffect = element.lockSoundEffect;
   
   if (![@"" isEqualToString:self.lockSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.lockSoundEffect];
   }
      
   NSDictionary* layerSpec = nil;
   NSString* imagePath = nil;
   CALayer* aLayer = nil;
   UIImage* image = nil;
   
   // build the spot in this order:
   // bar, innerLock, leftLock, key, rightLock
   
   // bar
   layerSpec = element.barLayer;
   
   aLayer = [[CALayer alloc] init];
   self.barLayer = aLayer;
   [aLayer release];
   
   self.barLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Key image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.barLayer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:self.barLayer]; 
   
   // inner lock
   layerSpec = element.innerLockLayer;
   
   aLayer = [[CALayer alloc] init];
   self.innerLockLayer = aLayer;
   [aLayer release];
   
   self.innerLockLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.innerLockLayer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:self.innerLockLayer];
   
   // left lock
   layerSpec = element.leftLockLayer;

   aLayer = [[CALayer alloc] init];
   self.leftLockLayer = aLayer;
   [aLayer release];
   
   self.leftLockLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.leftLockLayer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:self.leftLockLayer];
      
   // key
   layerSpec = element.keyLayer;
   
   self.minX = layerSpec.minX;
   self.maxX = layerSpec.maxX;
   
   aLayer = [[CALayer alloc] init];
   self.keyLayer = aLayer;
   [aLayer release];
   
   self.keyLayer.frame = layerSpec.frame;
      
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Key image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.keyLayer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:self.keyLayer];
   
   
   // right lock
   layerSpec = element.rightLockLayer;
   
   aLayer = [[CALayer alloc] init];
   self.rightLockLayer = aLayer;
   [aLayer release];
   
   self.rightLockLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Key image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.rightLockLayer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:self.rightLockLayer]; 
}

-(CGFloat)MoveDeltaX:(CGFloat)deltaX
{    
   CGPoint currentPosition = self.keyLayer.position;
   
   CGFloat newX = currentPosition.x + deltaX;
   
   // clamp to min/max specified for this segment
   if (newX <= self.minX)
   {
      newX = self.minX;
   }
   else if (newX >= self.maxX)
   {
      newX = self.maxX;
   }
   
   currentPosition.x = newX;
   
   self.keyLayer.position = currentPosition;
   
   return newX;
}

-(void)UnlockTheLock
{
   if (self.isLockOpen)
   {
      return;
   }
   
   // translate the bar layer -ve y
   CGPoint currentPosition = self.barLayer.position;
   
   currentPosition.y = currentPosition.y - kLockOpenDistance;
   
   self.barLayer.position = currentPosition;
   
   self.lockOpen = YES;
   
   // make a sound, too
   if (![@"" isEqualToString:self.unlockSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] playEffect:self.unlockSoundEffect];
   }
}

-(void)LockTheLock
{
   if (!self.isLockOpen)
   {
      return;
   }
   
   // translate the bar layer +ve y
   CGPoint currentPosition = self.barLayer.position;
   
   currentPosition.y = currentPosition.y + kLockOpenDistance;
   
   self.barLayer.position = currentPosition;
   
   self.lockOpen = NO;
   
   // make a sound, too
   if (![@"" isEqualToString:self.lockSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] playEffect:self.lockSoundEffect];
   }
}

#pragma mark ACustomAnimation protocol
// retrieve the latest results recorded by the pan gesture recognizer and
// translate the position on the movable layer of the image
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{
   UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
   
   CGFloat deltaX = ((CGPoint)[recognizer translationInView:self.containerView]).x;
   
   [CATransaction begin];
   
   // disabling actions makes the animation of the layers smoother
   [CATransaction setDisableActions:YES];
   
   [self MoveDeltaX:deltaX];
   
   [CATransaction commit];
   
   [recognizer setTranslation:CGPointZero inView:self.containerView];
   
   // time to pop or reset the lock's bar?
   CGPoint currentPosition = self.keyLayer.position;
   
   if (currentPosition.x >= self.unlockThreshold)
   {
      [self UnlockTheLock];
   }
   else if (currentPosition.x < self.lockThreshold)
   {
      [self LockTheLock];
   }
}

@end
