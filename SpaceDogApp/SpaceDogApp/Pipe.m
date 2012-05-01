// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Pipe.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TextureAtlasBasedSequence.h"

#define kSmokeAnimation @"smokeAnimation"

@implementation APipe

@synthesize pipeLayer=fPipeLayer;

-(void)dealloc
{
   self.pipeLayer.delegate = nil;
   if (self.pipeLayer.superlayer)
   {
      [self.pipeLayer removeFromSuperlayer];
   }
   Release(fPipeLayer);
      
   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];

   NSDictionary* layerSpec = nil;
   CALayer* layer;
   NSString* imagePath = nil;
   UIImage* image = nil;
      
   ////////////////////////////////////////////////////////////////////////////////
   // pipe
   layerSpec = element.pipeLayer;
      
   layer = [[CALayer alloc] init];
   layer.zPosition = 0;
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
   
   self.pipeLayer = layer;
   
   // The smoke animation resides on its own layer
   layerSpec = element.smokeLayer;
   ATextureAtlasBasedSequence* tSequence = [[ATextureAtlasBasedSequence alloc] 
                                            initWithElement:layerSpec 
                                            RenderOnView:nil];
   [view.layer addSublayer:tSequence.layer];
   [self.animationsByName setObject:tSequence forKey:kSmokeAnimation];
   [tSequence release];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [(id<ACustomAnimation>)[self.animationsByName objectForKey:kSmokeAnimation] Start:NO];
}

-(void)Stop
{
   [self.pipeLayer removeAllAnimations];
}

@end
