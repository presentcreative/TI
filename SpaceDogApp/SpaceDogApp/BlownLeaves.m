// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "BlownLeaves.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TextureAtlasBasedSequence.h"
#import "Constants.h"
#import "BookView.h"

#define kLeaf1 @"leaf1"
#define kLeaf2 @"leaf2"
#define kLeaf3 @"leaf3"

@interface ABlownLeaves (Private)
-(CABasicAnimation*)ChangeOpacityFrom:(CGFloat)startValue To:(CGFloat)endValue Over:(CGFloat)duration;
@end

@implementation ABlownLeaves

@synthesize leaf1Layer=fLeaf1Layer;
@synthesize leaf1Frame=fLeaf1Frame;
@synthesize leaf1PathPoints=fLeaf1PathPoints;
@synthesize leaf1AnimationDuration=fLeaf1AnimationDuration;
@synthesize leaf1FadeThreshold=fLeaf1FadeThreshold;

@synthesize leaf2Layer=fLeaf2Layer;
@synthesize leaf2Frame=fLeaf2Frame;
@synthesize leaf2PathPoints=fLeaf2PathPoints;
@synthesize leaf2AnimationDuration=fLeaf2AnimationDuration;
@synthesize leaf2FadeThreshold=fLeaf2FadeThreshold;

@synthesize leaf3Layer=fLeaf3Layer;
@synthesize leaf3Frame=fLeaf3Frame;
@synthesize leaf3PathPoints=fLeaf3PathPoints;
@synthesize leaf3AnimationDuration=fLeaf3AnimationDuration;
@synthesize leaf3FadeThreshold=fLeaf3FadeThreshold;

-(void)dealloc
{
   self.leaf1Layer.delegate = nil;
   if (self.leaf1Layer.superlayer)
   {
      [self.leaf1Layer removeFromSuperlayer];
   }
   Release(fLeaf1Layer);
   
   Release(fLeaf1PathPoints);
   
   self.leaf2Layer.delegate = nil;
   if (self.leaf2Layer.superlayer)
   {
      [self.leaf2Layer removeFromSuperlayer];
   }
   Release(fLeaf2Layer);
   
   Release(fLeaf2PathPoints);
   
   self.leaf3Layer.delegate = nil;
   if (self.leaf3Layer.superlayer)
   {
      [self.leaf3Layer removeFromSuperlayer];
   }
   Release(fLeaf3Layer);
   
   Release(fLeaf3PathPoints);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.leaf1Frame = CGRectZero;
   self.leaf1PathPoints = [NSArray array];
   self.leaf1AnimationDuration = 0.0f;
   self.leaf1FadeThreshold = 0.0f;
   
   self.leaf2Frame = CGRectZero;
   self.leaf2PathPoints = [NSArray array];
   self.leaf2AnimationDuration = 0.0f;
   self.leaf2FadeThreshold = 0.0f;
   
   self.leaf3Frame = CGRectZero;
   self.leaf3PathPoints = [NSArray array];
   self.leaf3AnimationDuration = 0.0f;
   self.leaf3FadeThreshold = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   
   ////////////////////////////////////////////////////////////////////////////////
   // leaf1
   
   layerSpec = element.leaf1Layer;
   
   self.leaf1Frame = layerSpec.frame;
   
   CALayer* layer = [[CALayer alloc] init];
   layer.frame = self.leaf1Frame;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      [layer release];
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [layer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:layer]; 
   self.leaf1Layer = layer;
   [layer release];
   
   self.leaf1FadeThreshold = layerSpec.fadeThreshold;
   
   self.leaf1PathPoints = layerSpec.pathPoints;
   self.leaf1AnimationDuration = layerSpec.duration;
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // leaf2
   
   layerSpec = element.leaf2Layer;
   
   self.leaf2Frame = layerSpec.frame;
   
   layer = [[CALayer alloc] init];
   layer.frame = self.leaf2Frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      [layer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [layer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:layer]; 
   self.leaf2Layer = layer;
   [layer release];
   
   self.leaf2FadeThreshold = layerSpec.fadeThreshold;
   
   self.leaf2PathPoints = layerSpec.pathPoints;
   self.leaf2AnimationDuration = layerSpec.duration;
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // leaf3
   
   layerSpec = element.leaf3Layer;
   
   self.leaf3Frame = layerSpec.frame;
   
   layer = [[CALayer alloc] init];
   layer.frame = self.leaf3Frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", layerSpec.resource);
      
      [layer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [layer setContents:(id)image.CGImage];
   [image release];
   
   [view.layer addSublayer:layer]; 
   self.leaf3Layer = layer;
   [layer release];
   
   self.leaf3FadeThreshold = layerSpec.fadeThreshold;
   
   self.leaf3PathPoints = layerSpec.pathPoints;
   self.leaf3AnimationDuration = layerSpec.duration;
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
   CALayer* layerToFade = nil;
   
   NSString* layerName = [timer.userInfo objectForKey:@"layerName"];
   
   if ([kLeaf1 isEqualToString:layerName])
   {
      layerToFade = self.leaf1Layer;
   }
   else if ([kLeaf2 isEqualToString:layerName])
   {
      layerToFade = self.leaf2Layer;
   }
   else if ([kLeaf3 isEqualToString:layerName])
   {
      layerToFade = self.leaf3Layer;
   }
   
   if (nil == layerToFade)
   {
      return;
   }
   
   
   [CATransaction begin];
   
   layerToFade.opacity = 0.0f;
   [layerToFade addAnimation:[self ChangeOpacityFrom:1.0f To:0.0f Over:0.5f] forKey:@"opacity"];
   
   [CATransaction commit];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self Stop];
   
   // start a timer to handle a fade of the seagullLayer before the seagull
   // runs into the "wall", i.e. the side of the page
   [NSTimer scheduledTimerWithTimeInterval:self.leaf1AnimationDuration-self.leaf1FadeThreshold
                                    target:self
                                  selector:@selector(FadeBeforeHittingTheWall:)
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:kLeaf1, @"layerName", nil]
                                   repeats:NO];
   
   [NSTimer scheduledTimerWithTimeInterval:self.leaf2AnimationDuration-self.leaf2FadeThreshold
                                    target:self
                                  selector:@selector(FadeBeforeHittingTheWall:)
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:kLeaf2, @"layerName", nil]
                                   repeats:NO];
   
   [NSTimer scheduledTimerWithTimeInterval:self.leaf3AnimationDuration-self.leaf3FadeThreshold
                                    target:self
                                  selector:@selector(FadeBeforeHittingTheWall:)
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:kLeaf3, @"layerName", nil]
                                   repeats:NO];
   
   // fire up the seagull...
   for (id<ACustomAnimation>animation in self.animations)
   {
      [animation Start:triggered];
   }
   
   [CATransaction begin];
   
   self.leaf1Layer.opacity = 1.0f;
   [self.leaf1Layer addAnimation:[self ChangeOpacityFrom:0.0f To:1.0f Over:1.50f] forKey:@"opacity"];
   
   CAAnimation* anim = [self 
                        AnimationOfLayer:self.leaf1Layer 
                        OverPath:self.leaf1PathPoints 
                        ForDuration:self.leaf1AnimationDuration
                        WithIdentifier:@"leaf1"];
   
   self.leaf1Layer.position = [(NSValue*)[self.leaf1PathPoints lastObject] CGPointValue];
   [self.leaf1Layer addAnimation:anim forKey:@"position"];
   
   
   self.leaf2Layer.opacity = 1.0f;
   [self.leaf2Layer addAnimation:[self ChangeOpacityFrom:0.0f To:1.0f Over:1.50f] forKey:@"opacity"];
   
   anim = [self 
           AnimationOfLayer:self.leaf2Layer 
           OverPath:self.leaf2PathPoints 
           ForDuration:self.leaf2AnimationDuration
           WithIdentifier:@"leaf2"];
   
   self.leaf2Layer.position = [(NSValue*)[self.leaf2PathPoints lastObject] CGPointValue];
   [self.leaf2Layer addAnimation:anim forKey:@"position"];
   
   
   self.leaf3Layer.opacity = 1.0f;
   [self.leaf3Layer addAnimation:[self ChangeOpacityFrom:0.0f To:1.0f Over:1.50f] forKey:@"opacity"];
   
   anim = [self 
           AnimationOfLayer:self.leaf3Layer 
           OverPath:self.leaf3PathPoints 
           ForDuration:self.leaf3AnimationDuration
           WithIdentifier:@"leaf3"];
   
   self.leaf3Layer.position = [(NSValue*)[self.leaf3PathPoints lastObject] CGPointValue];
   [self.leaf3Layer addAnimation:anim forKey:@"position"];
   
   [CATransaction commit];
}

-(void)Stop
{
   [super Stop];
   
   [self.leaf1Layer removeAllAnimations];
   self.leaf1Layer.frame = self.leaf1Frame;
   
   [self.leaf2Layer removeAllAnimations];
   self.leaf2Layer.frame = self.leaf2Frame;
   
   [self.leaf3Layer removeAllAnimations];
   self.leaf3Layer.frame = self.leaf3Frame;
}

@end
