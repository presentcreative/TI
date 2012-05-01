// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ShipSailsAndPully.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Trigger.h"
#import "BookView.h"
#import  "TextureAtlasBasedSequence.h"
#import "TriggeredSoundEffect.h"

@interface AShipSailsAndPully (Private)
-(CGFloat)MoveDeltaY:(CGFloat)deltaY;
-(void)UnfurlTheSails;
-(void)FurlTheSails;
@end

@implementation AShipSailsAndPully

@synthesize sailSequences = fSailSequences;

@synthesize hookLayer=fHookLayer;
@synthesize centerFrontLayer=fCenterFronLayer;
@synthesize centerMiddleLayer=fCenterMiddleLayer;
@synthesize centerRearLayer=fCenterRearLayer;
@synthesize topFrontLayer=fTopFrontLayer;
@synthesize topMiddleLayer=fTopMiddleLayer;
@synthesize topRearLayer=fTopRearLayer;

@synthesize minY=fMinY;
@synthesize maxY=fMaxY;
@synthesize furlThreshold=fFurlThreshold;
@synthesize unfurlThreshold=fUnfurlThreshold;

@synthesize unfurled=fUnfurled;

@synthesize furlSoundEffect=fFurlSoundEffect;
@synthesize unfurlSoundEffect=fUnfurlSoundEffect;

-(void)dealloc
{   
   Release(fSailSequences);
   
   self.hookLayer.delegate = nil;
   if (self.hookLayer.superlayer)
   {
      [self.hookLayer removeFromSuperlayer];
   }
   Release(fHookLayer);
   
   self.centerFrontLayer.delegate = nil;
   if (self.centerFrontLayer.superlayer)
   {
      [self.centerFrontLayer removeFromSuperlayer];
   }
   Release(fCenterFrontLayer);
   
   self.centerMiddleLayer.delegate = nil;
   if (self.centerMiddleLayer.superlayer)
   {
      [self.centerMiddleLayer removeFromSuperlayer];
   }
   Release(fCenterMiddleLayer);
   
   self.centerRearLayer.delegate = nil;
   if (self.centerRearLayer.superlayer)
   {
      [self.centerRearLayer removeFromSuperlayer];
   }
   Release(fCenterRearLayer);
   
   self.topFrontLayer.delegate = nil;
   if (self.topFrontLayer.superlayer)
   {
      [self.topFrontLayer removeFromSuperlayer];
   }
   Release(fTopFrontLayer);
   
   self.topMiddleLayer.delegate = nil;
   if (self.topMiddleLayer.superlayer)
   {
      [self.topMiddleLayer removeFromSuperlayer];
   }
   Release(fTopMiddleLayer);
   
   self.topRearLayer.delegate = nil;
   if (self.topRearLayer.superlayer)
   {
      [self.topRearLayer removeFromSuperlayer];
   }
   Release(fTopRearLayer);
   
   Release(fUnfurlSoundEffect);
   Release(fFurlSoundEffect);
      
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.sailSequences = [NSMutableArray array];
   self.minY = 0.0f;
   self.maxY = 0.0f;
   self.furlThreshold = 0.0f;
   self.unfurlThreshold = 0.0f;
   self.unfurled = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.furlThreshold = element.furlThreshold;
   self.unfurlThreshold = element.unfurlThreshold;
      
   NSDictionary* layerSpec = nil;
   NSString* imagePath = nil;
   ATextureAtlasBasedSequence* sailSequence = nil;
   UIImage* image = nil;
   
   // build the scene in this order:
   // rear sails, middle sails, front sails, hook
   
   ////////////////////////////////////////////////////////////////////////////////
   // rear sails
   layerSpec = element.bottomRearSail;

   CALayer* bottomRearSailLayer = [[CALayer alloc] init];
   bottomRearSailLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [bottomRearSailLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [bottomRearSailLayer setContents:(id)image.CGImage];
   [image release];
   [view.layer addSublayer:bottomRearSailLayer];
   [bottomRearSailLayer release];
   
   // center rear
   layerSpec = element.centerRearLayer;

   sailSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:layerSpec RenderOnView:nil];
   
   [self.sailSequences addObject:sailSequence];
   
   [view.layer addSublayer:sailSequence.layer];
   [sailSequence release];

   // top rear
   layerSpec = element.topRearLayer;
   
   sailSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:layerSpec RenderOnView:nil];
   
   [self.sailSequences addObject:sailSequence];
   
   [view.layer addSublayer:sailSequence.layer];
   [sailSequence release];
   
   ////////////////////////////////////////////////////////////////////////////////
   // middle sails
   layerSpec = element.bottomMiddleSail;
   
   CALayer* bottomMiddleSailLayer = [[CALayer alloc] init];
   bottomMiddleSailLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [bottomMiddleSailLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [bottomMiddleSailLayer setContents:(id)image.CGImage]; 
   [image release];
   [view.layer addSublayer:bottomMiddleSailLayer]; 
   [bottomMiddleSailLayer release];
   
   // center middle
   layerSpec = element.centerMiddleLayer;
   
   sailSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:layerSpec RenderOnView:nil];
   
   [self.sailSequences addObject:sailSequence];
   
   [view.layer addSublayer:sailSequence.layer];
   [sailSequence release];
   
   
   // top middle
   layerSpec = element.topMiddleLayer;
   
   sailSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:layerSpec RenderOnView:nil];
   
   [self.sailSequences addObject:sailSequence];
   
   [view.layer addSublayer:sailSequence.layer];
   [sailSequence release];
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // front sales
   layerSpec = element.bottomFrontSail;
   
   CALayer* bottomFrontSailLayer = [[CALayer alloc] init];
   bottomFrontSailLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [bottomFrontSailLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [bottomFrontSailLayer setContents:(id)image.CGImage];
   [image release];
   [view.layer addSublayer:bottomFrontSailLayer]; 
   [bottomFrontSailLayer release];
   
   // center front
   layerSpec = element.centerFrontLayer;
   
   sailSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:layerSpec RenderOnView:nil];
   
   [self.sailSequences addObject:sailSequence];
   
   [view.layer addSublayer:sailSequence.layer];
   [sailSequence release];
   
   
   // top front
   layerSpec = element.topFrontLayer;
   
   sailSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:layerSpec RenderOnView:nil];
   
   [self.sailSequences addObject:sailSequence];
   
   [view.layer addSublayer:sailSequence.layer];
   [sailSequence release];
   
   
   // hook
   layerSpec = element.hookLayer;
   
   self.minY = layerSpec.minY;
   self.maxY = layerSpec.maxY;
   
   CALayer* hookLayer = [[CALayer alloc] init];
   self.hookLayer = hookLayer;
   [hookLayer release];
   
   self.hookLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.hookLayer setContents:(id)image.CGImage]; 
   [image release];
   [view.layer addSublayer:self.hookLayer]; 
   
   // finally, add the sound effects
   ATriggeredSoundEffect* soundEffect = nil;
   
   soundEffect = [[ATriggeredSoundEffect alloc] initWithElement:element.unfurlSoundEffect RenderOnView:view];
   self.unfurlSoundEffect = soundEffect;
   [soundEffect release];
   
   soundEffect = [[ATriggeredSoundEffect alloc] initWithElement:element.furlSoundEffect RenderOnView:view];
   self.furlSoundEffect = soundEffect;
   [soundEffect release];
}

-(CGFloat)MoveDeltaY:(CGFloat)deltaY
{    
   CGPoint currentPosition = self.hookLayer.position;
   
   CGFloat newY = currentPosition.y + deltaY;
   
   // clamp to min/max specified for this segment
   if (newY <= self.minY)
   {
      newY = self.minY;
   }
   else if (newY >= self.maxY)
   {
      newY = self.maxY;
   }
   
   currentPosition.y = newY;
   
   self.hookLayer.position = currentPosition;
   
   return newY;
}

-(void)UnfurlTheSails
{
   if (self.isUnfurled)
   {
      return;
   }
   
   [self.unfurlSoundEffect Trigger];
   
   // unfurling the sails involves running the animation for each sail forwards
   for (ATextureAtlasBasedSequence* sailSequence in self.sailSequences)
   {
      [sailSequence AnimateSequence:1 Forward:YES];
   }
   
   self.unfurled = YES;
}

-(void)FurlTheSails
{
   if (!self.isUnfurled)
   {
      return;
   }
   
   [self.furlSoundEffect Trigger];
   
   // furling the sails involves running the animation for each sail backwards
   for (ATextureAtlasBasedSequence* sailSequence in self.sailSequences)
   {
      [sailSequence AnimateSequence:1 Forward:NO];
   }
   
   self.unfurled = NO;
}

#pragma mark ACustomAnimation protocol
// retrieve the latest results recorded by the pan gesture recognizer and
// translate the position on the movable layer of the image
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{
   UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
   
   CGFloat deltaY = ((CGPoint)[recognizer translationInView:self.containerView]).y;
   
   [CATransaction begin];
   
   // disabling actions makes the animation of the layers smoother
   [CATransaction setDisableActions:YES];
   
   [self MoveDeltaY:deltaY];
   
   [CATransaction commit];
   
   [recognizer setTranslation:CGPointZero inView:self.containerView];
   
   // time to furl or unfurl the sails?
   CGPoint currentPosition = self.hookLayer.position;
   
   if (currentPosition.y >= self.unfurlThreshold)
   {
      [self UnfurlTheSails];
   }
   else if (currentPosition.y < self.furlThreshold)
   {
      [self FurlTheSails];
   }
}

-(void)Stop
{
   for (ATextureAtlasBasedSequence* sailSequence in self.sailSequences)
   {
      [sailSequence Stop];
   }
}

@end
