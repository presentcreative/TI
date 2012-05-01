// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "WarAtSea.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TriggeredTextureAtlasBasedSequence.h"
#import "Trigger.h"

#define kSmolletAnimation     @"smolletAnimation"
#define kRifleHammerAnimation @"rifleHammerAnimation"
#define kMuzzleFlashAnimation @"muzzleFlashAnimation"
#define kMuzzleSmokeAnimation @"muzzleSmokeAnimation"

@interface AWarAtSea (Private)
-(void)ShotFired:(NSNotification*)notification;
-(CABasicAnimation*)BobTheBoatAnimation;
-(CABasicAnimation*)BobTheBoatSlowlyAnimation;
-(CABasicAnimation*)RockTheBoatAnimation;
@end


@implementation AWarAtSea

@synthesize boatLayer=fBoatLayer;
@synthesize wavesLayer=fWavesLayer;

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   self.boatLayer.delegate = nil;
   if (self.boatLayer.superlayer)
   {
      [self.boatLayer removeFromSuperlayer];
   }
   Release(fBoatLayer);
   
   self.wavesLayer.delegate = nil;
   if (self.wavesLayer.superlayer)
   {
      [self.wavesLayer removeFromSuperlayer];
   }   
   Release(fWavesLayer);
   
   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSString* imagePath = nil;
   NSDictionary* layerSpec = nil;
   CALayer* aLayer = nil;
   UIImage* image = nil;
   
   // background...
   layerSpec = element.backgroundLayer;
   
   aLayer = [[CALayer alloc] init];
   CALayer* backgroundLayer = aLayer;
   
   backgroundLayer.zPosition = 0;
   backgroundLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [aLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [backgroundLayer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:backgroundLayer];
   [aLayer release];
   
   // boat
   layerSpec = element.boatLayer;
   
   aLayer = [[CALayer alloc] init];
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
   
   // all the sub-animations take place on the boatLayer
   ATriggeredTextureAtlasBasedSequence* tSequence = nil;
   
   // Smollet
   tSequence = [[ATriggeredTextureAtlasBasedSequence alloc]
                initWithElement:layerSpec.smolletAnimation
                RenderOnView:view];
   
   [self.animationsByName setObject:tSequence forKey:kSmolletAnimation];
   [self.boatLayer addSublayer:tSequence.layer];
   [tSequence release]; 
   
   // rifle hammer
   tSequence = [[ATriggeredTextureAtlasBasedSequence alloc]
                initWithElement:layerSpec.rifleHammerAnimation
                RenderOnView:view];
   
   [self.animationsByName setObject:tSequence forKey:kRifleHammerAnimation];
   [self.boatLayer addSublayer:tSequence.layer];
   [tSequence release]; 
   
   // muzzle flash
   tSequence = [[ATriggeredTextureAtlasBasedSequence alloc]
                initWithElement:layerSpec.muzzleFlashAnimation
                RenderOnView:view];
   
   [self.animationsByName setObject:tSequence forKey:kMuzzleFlashAnimation];
   [self.boatLayer addSublayer:tSequence.layer];
   [tSequence release]; 
   
   // muzzle smoke
   tSequence = [[ATriggeredTextureAtlasBasedSequence alloc]
                initWithElement:layerSpec.muzzleSmokeAnimation
                RenderOnView:view];
   
   [self.animationsByName setObject:tSequence forKey:kMuzzleSmokeAnimation];
   [self.boatLayer addSublayer:tSequence.layer];
   [tSequence release]; 
   
   
   [view.layer addSublayer:self.boatLayer];
   
   // waves
   layerSpec = element.wavesLayer;
   
   aLayer = [[CALayer alloc] init];
   self.wavesLayer = aLayer;
   [aLayer release];
   
   self.wavesLayer.zPosition = 2;
   self.wavesLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.wavesLayer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:self.wavesLayer];
   
   // register for the muzzle flash notification - this will be the trigger for the animation
   // that makes the boat bob
   [[NSNotificationCenter defaultCenter]
    addObserver:self 
    selector:@selector(ShotFired:) 
    name:@"CH17_SHOT_FIRED" 
    object:nil];
}

-(void)ShotFired:(NSNotification*)notification
{
   [CATransaction begin];
   [self.boatLayer addAnimation:[self RockTheBoatAnimation] forKey:@"transform.rotation.z"];
   [self.boatLayer addAnimation:[self BobTheBoatAnimation] forKey:@"position"];
   [CATransaction commit];
}

-(CABasicAnimation*)RockTheBoatAnimation
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
   result.delegate = self;
   [result setValue:@"rockTheBoat" forKey:@"animationId"];
      
   result.duration = 1.0f;
   
   result.repeatCount = 4;
   result.autoreverses = YES;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
   
   result.fromValue = [NSNumber numberWithDouble:DEGREES_TO_RADIANS(0.0f)];
   result.toValue = [NSNumber numberWithDouble:DEGREES_TO_RADIANS(-10.0f)];
      
   return result;   
}

-(CABasicAnimation*)BobTheBoatAnimation
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"position"];
   result.delegate = self;
   [result setValue:@"bobTheBoat" forKey:@"animationId"];
      
   result.duration = 0.8f;
   
   result.repeatCount = 3;
   result.autoreverses = YES;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
   
   CGPoint layerPosition = self.boatLayer.position;
   
   NSValue* currentPositionValue = [NSValue valueWithCGPoint:layerPosition];
   NSValue* newPositionValue = [NSValue valueWithCGPoint:CGPointMake(layerPosition.x, layerPosition.y+30.0f)];
   
   result.fromValue = currentPositionValue;
   result.toValue = newPositionValue;
   
   return result;   
}

-(CABasicAnimation*)BobTheBoatSlowlyAnimation
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"position"];
   result.delegate = self;
   [result setValue:@"bobTheBoatSlowly" forKey:@"animationId"];
   
   result.duration = 1.0f;
   
   result.repeatCount = NSUIntegerMax;
   result.autoreverses = YES;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
   
   CGPoint layerPosition = self.boatLayer.position;
   
   NSValue* currentPositionValue = [NSValue valueWithCGPoint:layerPosition];
   NSValue* newPositionValue = [NSValue valueWithCGPoint:CGPointMake(layerPosition.x, layerPosition.y+10.0f)];
   
   result.fromValue = currentPositionValue;
   result.toValue = newPositionValue;
   
   return result;   
}

-(void)Start:(BOOL)triggered
{
   // start the boat bobbing slowly...
   [self.boatLayer addAnimation:[self BobTheBoatSlowlyAnimation] forKey:@"position"]; 
   
   // prime the triggered animations
   for (ATriggeredTextureAtlasBasedSequence* triggeredAnimation in [self.animationsByName allValues])
   {
      [(id<ACustomAnimation>)triggeredAnimation Start:NO];
   }
}

#pragma mark ACustomAnimation protocol
-(void)Trigger
{
   [(id<ACustomAnimation>)[self.animationsByName objectForKey:kSmolletAnimation] Trigger];
}

-(void)Stop
{
   [super Stop];
   
   // disable all triggers for all triggered animations
   for (ATriggeredTextureAtlasBasedSequence* triggeredAnimation in [self.animationsByName allValues])
   {
      [(id<ACustomAnimation>)triggeredAnimation Stop];
   }
   
   [self.boatLayer removeAllAnimations];
   [self.wavesLayer removeAllAnimations];
}

#pragma mark -
#pragma mark CAAnimationDelegate protocol
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
   NSString* animationId = [anim valueForKey:@"animationId"];
   
   if (flag)
   {
      if ([@"bobTheBoat" isEqualToString:animationId])
      {
         // start the boat bobbing slowly again
         [self.boatLayer addAnimation:[self BobTheBoatSlowlyAnimation] forKey:@"position"];         
      }
   }
}

@end
