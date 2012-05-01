// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "TorchAndEyes.h"
#import "TextureAtlasBasedSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Constants.h"
#import "TriggeredTextureAtlasBasedSequence.h"
#import "AmbientSound.h"

#define kMaxOpacity  1.0f
#define kMinOpacity  0.7f
#define kOpacityDifference kMaxOpacity-kMinOpacity

@interface ATorchAndEyes (Private)
-(void)ExtinguishTorch;
-(void)IgniteTorch;
-(void)StartFlickerTimer;
-(void)StopFlickerTimer;
-(void)FlickerTimer:(NSTimer*)flickerTimer;
@end


@implementation ATorchAndEyes

@synthesize torchLayer = fTorchLayer;
@synthesize torchBackgroundLayer = fTorchBackgroundLayer;
@synthesize darknessLayer = fDarknessLayer;
@synthesize flickerTimer = fFlickerTimer;
@synthesize eyeSequences = fEyeSequences;
@synthesize torchSequences = fTorchSequences;
@synthesize torchBurning = fTorchBurning;
@synthesize torchSound=fTorchSound;

-(void)dealloc
{
   self.torchBackgroundLayer.delegate = nil;
   if (self.torchBackgroundLayer.superlayer)
   {
      [self.torchBackgroundLayer removeFromSuperlayer];
   } 
   Release(fTorchBackgroundLayer);
   
   self.torchLayer.delegate = nil;
   if (self.torchLayer.superlayer)
   {
      [self.torchLayer removeFromSuperlayer];
   } 
   Release(fTorchLayer);
   
   self.darknessLayer.delegate = nil;
   if (self.darknessLayer.superlayer)
   {
      [self.darknessLayer removeFromSuperlayer];
   } 
   Release(fDarknessLayer);
   
   Release(fFlickerTimer);
   Release(fEyeSequences);
   Release(fTorchSequences);
   Release(fTorchSound);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.eyeSequences = [NSMutableArray array];
   self.torchBurning = YES;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   CALayer* aLayer = nil;
   UIImage* image = nil;
      
   // setup the 'torch layer' (initially visible)
   layerSpec = element.torchLayer;
   
   aLayer = [[CALayer alloc] init];
   self.torchLayer = aLayer;
   [aLayer release];
   
   self.torchLayer.frame = CGRectMake(0.0f, 0.0f, kPageWidth, kPageHeight);
   
   aLayer = [[CALayer alloc] init];
   self.torchBackgroundLayer = aLayer;
   [aLayer release];
   
   self.torchBackgroundLayer.frame = layerSpec.frame;
   
   NSString* torchImagePath = [[NSBundle mainBundle] pathForResource:layerSpec.backgroundImage ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:torchImagePath])
   {
      ALog(@"Torch background image file missing: %@", torchImagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:torchImagePath];
   [self.torchBackgroundLayer setContents:(id)image.CGImage];
   [image release];
   
   [self.torchLayer addSublayer:self.torchBackgroundLayer];
   
   // disable implicit animations of opacity changes on the torch background layer
   NSMutableDictionary* disabledAnimations = [[NSMutableDictionary alloc]
                                              initWithObjectsAndKeys:[NSNull null], @"opacity", nil];
   self.torchBackgroundLayer.actions = disabledAnimations;
   [disabledAnimations release];
   
   // set up the 'flicker timer', i.e. the timer that drives changes in the
   // torch background layer opacity
   [self StartFlickerTimer];
      
   // add the torch burning sequences
   ATriggeredTextureAtlasBasedSequence* tSequence = (ATriggeredTextureAtlasBasedSequence*)[[ATriggeredTextureAtlasBasedSequence alloc] 
                                                         initWithElement:layerSpec.torchSpec 
                                                         RenderOnView:nil];
   self.torchSequences = tSequence;   
   [self.torchLayer addSublayer:tSequence.layer];
   [tSequence release];
   
   [view.layer addSublayer:self.torchLayer];
   
   // get the torch sound up and running
   AAmbientSound* torchSound = [[AAmbientSound alloc] initWithElement:layerSpec.torchSoundEffect RenderOnView:view];
   self.torchSound = torchSound;
   [torchSound release];
   
   
   // now, setup the 'darkness layer'   
   layerSpec = element.darknessLayer;

   aLayer = [[CALayer alloc] init];
   self.darknessLayer = aLayer;
   [aLayer release];
   
   self.darknessLayer.frame = layerSpec.frame;
   self.darknessLayer.opacity = 0.0;
   
   // the background is just black
   NSString* backgoundImagePath = [[NSBundle mainBundle] pathForResource:layerSpec.backgroundImage ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:backgoundImagePath])
   {
      ALog(@"Background image file missing: %@", backgoundImagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:backgoundImagePath];
   [self.darknessLayer setContents:(id)image.CGImage]; 
   [image release];
   
   
   for (int i = 1; i <= layerSpec.eyePairs; i++)
   {
      NSDictionary* eyePairSpec = [layerSpec eyePairSpecForIndex:i];
      
      if (nil == eyePairSpec)
      {
         continue;
      }
      
      ATextureAtlasBasedSequence* eyeSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:eyePairSpec RenderOnView:nil];
      
      [self.eyeSequences addObject:eyeSequence];
      
      [self.darknessLayer addSublayer:eyeSequence.layer];
      [eyeSequence release];
   }
      
   [view.layer addSublayer:self.darknessLayer];
}

-(void)ExtinguishTorch
{
   // run the 'torch off' sequence while at the same time increasing the opacity
   // of the 'darkness layer'
   [CATransaction begin];
   [CATransaction setAnimationDuration:1.4f];
   
   self.darknessLayer.opacity = 1.0;
   
   [self.torchSequences TriggerWithSpec:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:1] forKey:@"NEXT_SEQUENCE"]];
   
   [CATransaction commit];
   
   [self StopFlickerTimer];
   
   [self.torchSound FadeTo:0.0f];
   
   // notify anyone who cares that it's now dark
   [[NSNotificationCenter defaultCenter]
    postNotificationName:@"CH27_ITS_DARK"
    object:nil];
}

-(void)IgniteTorch
{
   [self StartFlickerTimer];
   
   // run the 'torch on' sequence while at the same time decreasing the opacity
   // of the 'darkness layer'
   [CATransaction begin];
   [CATransaction setAnimationDuration:1.7f];
   
   self.darknessLayer.opacity = 0.0;
   
   [self.torchSequences TriggerWithSpec:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:2] forKey:@"NEXT_SEQUENCE"]];

   [CATransaction commit];
   
   [self.torchSound FadeTo:1.0f];
   
   // notify anyone who cares that it's now light
   [[NSNotificationCenter defaultCenter]
    postNotificationName:@"CH27_ITS_LIGHT"
    object:nil];
}

-(void)StartFlickerTimer
{
   self.flickerTimer = [NSTimer timerWithTimeInterval:0.1f 
                                               target:self 
                                             selector:@selector(FlickerTime:) 
                                             userInfo:nil 
                                              repeats:YES];
   
   [[NSRunLoop currentRunLoop] addTimer:self.flickerTimer forMode:NSDefaultRunLoopMode];
}

-(void)StopFlickerTimer
{
   [self.flickerTimer invalidate];
   self.flickerTimer = nil;
}

-(void)FlickerTime:(NSTimer*)flickerTimer
{
   // vary the opacity of the torchBackgroundLayer between some minimum and
   // maximum value
   float newOpacity = ((kOpacityDifference)*(float)arc4random()/ARC4RANDOM_MAX)+kMinOpacity;
   
   self.torchBackgroundLayer.opacity = newOpacity;
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   // prime the animations
   for (id<ACustomAnimation>animation in self.eyeSequences)
   {
      [animation Start:NO];
   }
   
   [self.torchSequences Start:NO];
   [self.torchSound Start:NO];
   [self.torchSound FadeTo:1.0f];
}

-(void)Trigger
{
   // toggle to the next state
   if (self.torchBurning)
   {
      [self ExtinguishTorch];
   }
   else 
   {
      [self IgniteTorch];
   }
   
   self.torchBurning = !self.torchBurning;
}

-(void)Stop
{
   [self.torchBackgroundLayer removeAllAnimations];
   [self.torchLayer removeAllAnimations];
   [self.darknessLayer removeAllAnimations];  
}

@end
