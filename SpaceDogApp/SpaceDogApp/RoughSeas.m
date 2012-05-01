// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "RoughSeas.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Trigger.h"
#import "TextureAtlasBasedSequence.h"
#import "PositionAnimation.h"

@implementation ARoughSeas

@synthesize borderLayer=fBorderLayer;
@synthesize shipLayer=fShipLayer;
@synthesize seaLayer=fSeaLayer;

@synthesize seaLayerAnimation=fSeaLayerAnimation;

-(void)dealloc
{
   self.borderLayer.delegate = nil;
   if (self.borderLayer.superlayer)
   {
      [self.borderLayer removeFromSuperlayer];
   }
   Release(fBorderLayer);
   
   self.shipLayer.delegate = nil;
   if (self.shipLayer.superlayer)
   {
      [self.shipLayer removeFromSuperlayer];
   }
   Release(fShipLayer);
   
   self.seaLayer.delegate = nil;
   if (self.seaLayer.superlayer)
   {
      [self.seaLayer removeFromSuperlayer];
   }
   Release(fSeaLayer);
   
   Release(fSeaLayerAnimation);
   
   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
      
   NSDictionary* layerSpec = nil;
   CALayer* layer = nil;
   NSString* imagePath = nil;
   UIImage* image = nil;
   
   // first, create the layers on which everything else sits
   
   ////////////////////////////////////////////////////////////////////////////////
   // the stationary ship   
   layerSpec = element.shipLayer;
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
   
   self.shipLayer = layer;

   ////////////////////////////////////////////////////////////////////////////////
   // the heaving sea
   // the sea layer moves up and down the y-axis
   layerSpec = element.seaLayer;
   
   APositionAnimation* seaLayerAnim = (APositionAnimation*)[[APositionAnimation alloc] 
                                       initWithElement:layerSpec 
                                       RenderOnView:nil];
   
   self.seaLayer = seaLayerAnim.layer;
   [view.layer addSublayer:self.seaLayer];
   self.seaLayerAnimation = seaLayerAnim;
   [seaLayerAnim release];
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // masking border
   layerSpec = element.borderLayer;
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
   
   self.borderLayer = layer;
   

   // now add animations to the layers
   ATextureAtlasBasedSequence* tSequence = nil;
   
   ////////////////////////////////////////////////////////////////////////////////
   // flickering light
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.flickeringLightLayer 
                RenderOnView:nil];
   
   [self.animations addObject:tSequence];
   [self.shipLayer addSublayer:tSequence.layer];
   [tSequence release];
   
   ////////////////////////////////////////////////////////////////////////////////
   // choppy wave 1
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.choppyWave1Layer 
                RenderOnView:nil];
   
   [self.animations addObject:tSequence];
   [self.seaLayer addSublayer:tSequence.layer];
   [tSequence release];
   
   ////////////////////////////////////////////////////////////////////////////////
   // choppy wave 2
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.choppyWave2Layer 
                RenderOnView:nil];
   
   [self.animations addObject:tSequence];
   [self.seaLayer addSublayer:tSequence.layer];
   [tSequence release];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self.seaLayerAnimation Start:triggered];
   
   for (id<ACustomAnimation>animation in self.animations)
   {
      [animation Start:triggered];
   }
}

-(void)Stop
{
   [self.seaLayerAnimation Stop];
   
   [self.borderLayer removeAllAnimations];
   [self.shipLayer removeAllAnimations];
   [self.seaLayer removeAllAnimations];
}


@end
