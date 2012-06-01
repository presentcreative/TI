// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Seagull.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TextureAtlasBasedSequence.h"
#import "Constants.h"
#import "BookView.h"

@interface ASeagull (Private)
-(CABasicAnimation*)ChangeOpacityFrom:(CGFloat)startValue To:(CGFloat)endValue Over:(CGFloat)duration;
@end


@implementation ASeagull

@synthesize seagullLayer=fSeagullLayer;
@synthesize seagullLayerFrame=fSeagullLayerFrame;
@synthesize seagullLayerPathPoints=fSeagullLayerPathPoints;
@synthesize seagullLayerAnimationDuration=fSeagullLayerAnimationDuration;
@synthesize seagullFadeThreshold=fSeagullFadeThreshold;

-(void)dealloc
{
   self.seagullLayer.delegate = nil;
   if (self.seagullLayer.superlayer)
   {
      [self.seagullLayer removeFromSuperlayer];
   }
   Release(fSeagullLayer);
   
   Release(fSeagullLayerPathPoints);
      
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
      
   self.seagullLayerFrame = CGRectZero;
   self.seagullLayerPathPoints = [NSArray array];
   self.seagullLayerAnimationDuration = 0.0f;
   self.seagullFadeThreshold = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
      
   ATextureAtlasBasedSequence* tSequence = nil;
   
   ////////////////////////////////////////////////////////////////////////////////
   // the seagull animation itself
   
   layerSpec = element.seagullLayer;
   
   self.seagullLayerFrame = layerSpec.frame;
   self.seagullFadeThreshold = layerSpec.fadeThreshold;
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.seagullLayer 
                RenderOnView:nil];
   
   [self.animations addObject:tSequence];
   self.seagullLayer = tSequence.layer;
   self.seagullLayer.opacity = 0.0f;
   [view.layer addSublayer:self.seagullLayer];
   [tSequence release]; 
   
   self.seagullLayerPathPoints = layerSpec.pathPoints;
   self.seagullLayerAnimationDuration = layerSpec.duration;
}

-(CAKeyframeAnimation*)AnimationOfLayer:(CALayer*)layer OverPath:(NSArray*)pathPoints ForDuration:(CGFloat)duration WithIdentifier:(NSString*)identifier
{
   CAKeyframeAnimation* pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
   [pathAnimation setValue:identifier forKey:@"animationId"];
   pathAnimation.duration = duration;
   pathAnimation.calculationMode = kCAAnimationPaced;
   
   CGPoint initialPosition = layer.position;
   
   CGMutablePathRef layerPath = CGPathCreateMutable();
   CGPathMoveToPoint(layerPath, NULL, initialPosition.x, initialPosition.y);
   
   for (NSValue* pointValue in pathPoints)
   {
      CGPoint pathPoint = [pointValue CGPointValue];
      CGPathAddLineToPoint(layerPath, NULL, pathPoint.x, pathPoint.y);
   }
   
   pathAnimation.path = layerPath;
   CGPathRelease(layerPath);
      
   return pathAnimation;
}

-(CABasicAnimation*)ChangeOpacityFrom:(CGFloat)startValue To:(CGFloat)endValue Over:(CGFloat)duration
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"opacity"];
      
   result.duration = duration;  
   
   result.fromValue = [NSNumber numberWithFloat:startValue];
   result.toValue = [NSNumber numberWithFloat:endValue];
   
   return result;
}

-(void)FadeBeforeHittingTheWall:(NSTimer*)timer
{
   [CATransaction begin];
   
   self.seagullLayer.opacity = 0.0f;
   [self.seagullLayer addAnimation:[self ChangeOpacityFrom:1.0f To:0.0f Over:0.5f] forKey:@"opacity"];
   
   [CATransaction commit];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
    if (!triggered && self.waitForTrigger)
        return;
        
   [self Stop];
   
   // start a timer to handle a fade of the seagullLayer before the seagull
   // runs into the "wall", i.e. the side of the page
   [NSTimer scheduledTimerWithTimeInterval:self.seagullLayerAnimationDuration-self.seagullFadeThreshold
                                    target:self
                                  selector:@selector(FadeBeforeHittingTheWall:)
                                  userInfo:nil
                                   repeats:NO];
   
   // fire up the seagull...
   for (id<ACustomAnimation>animation in self.animations)
   {
      [animation Start:triggered];
   }
   
   [CATransaction begin];
   
   self.seagullLayer.opacity = 1.0f;
   [self.seagullLayer addAnimation:[self ChangeOpacityFrom:0.0f To:1.0f Over:1.50f] forKey:@"opacity"];
      
   CAAnimation* anim = [self 
                        AnimationOfLayer:self.seagullLayer 
                        OverPath:self.seagullLayerPathPoints 
                        ForDuration:self.seagullLayerAnimationDuration
                        WithIdentifier:@"seagull"];

   self.seagullLayer.position = [(NSValue*)[self.seagullLayerPathPoints lastObject] CGPointValue];
   [self.seagullLayer addAnimation:anim forKey:@"position"];
   
   [CATransaction commit];
}

-(void)Stop
{
   [super Stop];
   [self.seagullLayer removeAllAnimations];
   self.seagullLayer.frame = self.seagullLayerFrame;
}


@end
