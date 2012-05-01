// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PoppingCork.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Trigger.h"
#import "TriggeredTextureAtlasBasedSequence.h"

#define kCorkAnimationKey  @"corkAnimation"

@implementation APoppingCork

@synthesize animationFired=fAnimationFired;

-(void)BaseInit
{
   [super BaseInit];
   
   self.animationFired = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   NSString* imagePath = nil;
   UIImage* image = nil;
   CALayer* layer = nil;
      
   ////////////////////////////////////////////////////////////////////////////////
   // bottle bottom
   layerSpec = element.bottleLayer;
   
   layer = [[CALayer alloc] init];
   layer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [layer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [layer setContents:(id)image.CGImage]; 
   [image release];
   [view.layer addSublayer:layer];
   [layer release];
   

   ////////////////////////////////////////////////////////////////////////////////
   // popping cork animation
   layerSpec = element.corkAnimation;
   
   ATriggeredTextureAtlasBasedSequence* tSequence = [[ATriggeredTextureAtlasBasedSequence alloc] 
                                                     initWithElement:layerSpec 
                                                     RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:kCorkAnimationKey];
   [view.layer addSublayer:tSequence.layer];
   [tSequence release];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [super Start:triggered];
   
   ATrigger* shakeTrigger = self.shakeTrigger;
   
   if (nil != shakeTrigger)
   {
      [shakeTrigger BecomeAccelerometerDelegate];
   }
   
   [[self.animationsByName objectForKey:kCorkAnimationKey] Start:NO];
}

-(void)Stop
{
   [super Stop];
   
   ATrigger* shakeTrigger = self.shakeTrigger;
   
   if (nil != shakeTrigger)
   {
      [shakeTrigger BecomeFreeOfAccelerometer];
   }
   
   [[self.animationsByName objectForKey:kCorkAnimationKey] PositionOnBaseSequence];
   
   self.animationFired = NO;
}

-(void)Trigger
{
   if (!self.hasAnimationFired)
   {
      [[self.animationsByName objectForKey:kCorkAnimationKey] Trigger];
      
      self.animationFired = YES;
   }
}

@end
