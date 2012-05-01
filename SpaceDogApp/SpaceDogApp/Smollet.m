// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Smollet.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TextureAtlasBasedSequence.h"
#import "TriggeredTextureAtlasBasedSequence.h"
#import "PositionAnimation.h"

#define kSmolletAnimation           @"smolletAnimation"
#define kSmolletSwordGleamAnimation @"smolletSwordGleamAnimation"

#define kSmolletAnimationCompetionNotification @"CH21_SMOLLET_SWORD_DRAWN"

@interface ASmollet (Private)
-(void)MoveSmollet;
@end

@implementation ASmollet

@synthesize smolletLayer=fSmolletLayer;
@synthesize hatLayerAnimation=fHatLayerAnimation;
@synthesize xDelta=fxDelta;
@synthesize yDelta=fyDelta;
@synthesize duration=fDuration;
@synthesize originalPosition=fOriginalPosition;

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   self.smolletLayer.delegate = nil;
   if (self.smolletLayer.superlayer)
   {
      [self.smolletLayer removeFromSuperlayer];
   }
   Release(fSmolletLayer);
      
   Release(fHatLayerAnimation);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   fxDelta = 0.0f;
   fyDelta = 0.0f;
   fDuration= 0.0f;
   fOriginalPosition = CGPointZero;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   ATextureAtlasBasedSequence* tSequence = nil;
   
   layerSpec = element.smolletLayer;
   
   self.xDelta = layerSpec.xDelta;
   self.yDelta = layerSpec.yDelta;
   self.duration = layerSpec.duration;
   
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
   
   ////////////////////////////////////////////////////////////////////////////////
   // the animation of Smollet drawing his sword  
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                                             initWithElement:layerSpec.swordAnimation    
                                             RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:kSmolletAnimation];
   [layer addSublayer:tSequence.layer];
   [tSequence release];
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // the animation of the gleam on Smollet's sword  
   tSequence = (ATriggeredTextureAtlasBasedSequence*)[[ATriggeredTextureAtlasBasedSequence alloc] 
                                                      initWithElement:layerSpec.swordGleam   
                                                      RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:kSmolletSwordGleamAnimation];
   [layer addSublayer:tSequence.layer];
   [tSequence release];
   
   [view.layer addSublayer:layer];
   self.smolletLayer = layer;
   [layer release];
   
   self.originalPosition = self.smolletLayer.position;
      
   ////////////////////////////////////////////////////////////////////////////////
   // Smollet's hat is on its own layer   
   APositionAnimation* hatAnimation = (APositionAnimation*)[[APositionAnimation alloc] 
                                                            initWithElement:element.hatLayer 
                                                            RenderOnView:nil];
   
   self.hatLayerAnimation = hatAnimation;
   [view.layer addSublayer:hatAnimation.layer];
   [hatAnimation release];
   
   // register for the notification sent by the sword animation when it completes
   [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(SwordDrawn:) 
    name:kSmolletAnimationCompetionNotification 
    object:nil];
}

-(void)MoveSmollet
{
   CGPoint initialPosition = self.smolletLayer.position;
   CGPoint finalPosition = CGPointMake(initialPosition.x+self.xDelta, initialPosition.y+self.yDelta);
   
   CABasicAnimation* positionAnimation = [[CABasicAnimation alloc] init];
   positionAnimation.keyPath = @"position";
   positionAnimation.fromValue = [NSValue valueWithCGPoint:initialPosition];
   positionAnimation.toValue = [NSValue valueWithCGPoint:finalPosition];
   positionAnimation.duration = self.duration;
   
   [CATransaction begin];
   
   self.smolletLayer.position = finalPosition;
   
   [self.smolletLayer addAnimation:positionAnimation forKey:@"position"];
   
   [CATransaction commit];
   
   [positionAnimation release];
}

-(void)SwordDrawn:(NSNotification*)notification
{
   // trigger the gleam on Smollet's drawn sword
   [[self.animationsByName objectForKey:kSmolletSwordGleamAnimation] Start:NO];
   [[self.animationsByName objectForKey:kSmolletSwordGleamAnimation] Trigger];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self.hatLayerAnimation Start:triggered];
   [[self.animationsByName objectForKey:kSmolletAnimation] Start:triggered];
   
   // start the position animation on the smolletLayer
   [self MoveSmollet];
}

-(void)Stop
{
   [self.hatLayerAnimation Stop];
   [[self.animationsByName objectForKey:kSmolletSwordGleamAnimation] Stop];
   [[self.animationsByName objectForKey:kSmolletAnimation] Stop];
   self.smolletLayer.position = self.originalPosition;
}

@end
