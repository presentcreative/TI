// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "BobbingPainter.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Trigger.h"
#import "TextureAtlasBasedSequence.h"
#import "PositionAnimation.h"

@implementation ABobbingPainter

@synthesize bobbingShipLayer=fBobbingShipLayer;
@synthesize painterAnimation=fPainterAnimation;
@synthesize bobbingShipAnimation=fBobbingShipAnimation;

-(void)dealloc
{
   self.bobbingShipLayer.delegate = nil;
   if (self.bobbingShipLayer.superlayer)
   {
      [self.bobbingShipLayer removeFromSuperlayer];
   }
   Release(fBobbingShipLayer);
      
   Release(fBobbingShipAnimation);
   Release(fPainterAnimation);
   
   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
      
   ////////////////////////////////////////////////////////////////////////////////
   // the bobbing ship   
   layerSpec = element.bobbingShipLayer;
 
   APositionAnimation* bobbingShipAnim = (APositionAnimation*)[[APositionAnimation alloc] 
                                                            initWithElement:layerSpec 
                                                            RenderOnView:nil];
   
   self.bobbingShipLayer = bobbingShipAnim.layer;
   [view.layer addSublayer:self.bobbingShipLayer];
   self.bobbingShipAnimation = bobbingShipAnim;
   [bobbingShipAnim release];
   

   // now add the painter animation to the layer
   ATextureAtlasBasedSequence* tSequence = nil;
      
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                                             initWithElement:layerSpec.painterAnimation 
                                             RenderOnView:nil];
   
   self.painterAnimation = tSequence;
   [self.bobbingShipLayer addSublayer:tSequence.layer];
   [tSequence release];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self.bobbingShipAnimation Start:NO];
   [self.painterAnimation Start:NO];
}

-(void)Stop
{
   [super Stop];
   [self.painterAnimation Stop];
   [self.bobbingShipAnimation Stop];
   
   [self.bobbingShipLayer removeAllAnimations];
}


@end
