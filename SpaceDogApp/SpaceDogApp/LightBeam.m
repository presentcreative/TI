// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "LightBeam.h"
#import "ParticleEffect.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@implementation ALightBeam

@synthesize lightBeamAnimation=fLightBeamAnimation;
@synthesize beamLayer=fBeamLayer;

-(void)dealloc
{
   Release(fLightBeamAnimation);
   
   self.beamLayer.delegate = nil;
   if (self.beamLayer.superlayer)
   {
      [self.beamLayer removeFromSuperlayer];
   }
   Release(fBeamLayer);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   
   layerSpec = element.particleAnimation;
   
   AParticleEffect* particleEffect = [[AParticleEffect alloc] initWithElement:layerSpec RenderOnView:nil];
   self.lightBeamAnimation = particleEffect;
   [particleEffect release];
   
   [view.layer addSublayer:self.lightBeamAnimation.particleLayer];
   
   if (0.0f != layerSpec.rotation)
   {
      // rotate the layer
      self.lightBeamAnimation.particleLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(layerSpec.rotation), 0.0f, 0.0f, 1.0f);
   }
   
   // use the static light beam image as a veil, to soften the particle effect a bit
   layerSpec = element.beamLayer;
   
   CALayer* layer = [[CALayer alloc] init];
   layer.frame = layerSpec.frame;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [layer release];
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [layer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:layer];
   [layer release];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self.lightBeamAnimation Start:triggered];
}

-(void)Stop
{
   [self.lightBeamAnimation Stop];
}

-(void)DisplayLinkDidTick:(CADisplayLink*)displayLink
{
   [self.lightBeamAnimation DisplayLinkDidTick:displayLink];
}

@end
