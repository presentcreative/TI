// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Sunset.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TextureAtlasBasedSequence.h"
#import "Constants.h"

#define kSetTheSunDuration 60.0f
#define kGrowDarkDuration  40.0f
#define kShowTheEndDuration 1.5f
#define kTheEndDelay       10.0f
#define kThemeDelay        14.0f
#define kNotificationDelay 60.0f

@interface ASunset (Private)
-(CABasicAnimation*)AnimateTheSunFrom:(CGPoint)oldPosition To:(CGPoint)newPosition;
-(CABasicAnimation*)GrowDarkAnimation;
-(CABasicAnimation*)ShowTheEndAnimation;
-(void)PlayTheme:(NSTimer*)timer;
-(void)ShowTheEnd:(NSTimer*)timer;
-(void)SetTheSun;
@end


@implementation ASunset

@synthesize pirateSequences=fPirateSequences;

@synthesize foregroundLayer=fForegroundLayer;
@synthesize sunLayer=fSunLayer;
@synthesize originalSunPosition=fOriginalSunPosition;
@synthesize blackLayer=fBlackLayer;
@synthesize theEndLayer=fTheEndLayer;
@synthesize theEndTimer=fTheEndTimer;
@synthesize closingTheme=fClosingTheme;
@synthesize closingThemeTimer=fClosingThemeTimer;

-(void)dealloc
{   
   Release(fPirateSequences);
   
   self.foregroundLayer.delegate = nil;
   if (self.foregroundLayer.superlayer)
   {
      [self.foregroundLayer removeFromSuperlayer];
   }
   Release(fForegroundLayer);
   
   self.sunLayer.delegate = nil;
   if (self.sunLayer.superlayer)
   {
      [self.sunLayer removeFromSuperlayer];
   }
   Release(fSunLayer);
   
   self.blackLayer.delegate = nil;
   if (self.blackLayer.superlayer)
   {
      [self.blackLayer removeFromSuperlayer];
   }
   Release(fBlackLayer);
   
   self.theEndLayer.delegate = nil;
   if (self.theEndLayer.superlayer)
   {
      [self.theEndLayer removeFromSuperlayer];
   }
   Release(fTheEndLayer);
   
   if (nil != fClosingTheme)
   {
      [fClosingTheme clear];
   }
   Release(fClosingTheme);
   
   if (nil != fTheEndTimer)
   {
      [fTheEndTimer invalidate];
   }
   Release(fTheEndTimer);
   
   if (nil != fClosingThemeTimer)
   {
      [fClosingThemeTimer invalidate];
   }
   Release(fClosingThemeTimer);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.pirateSequences = [NSMutableArray array];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   CALayer* layer;
   NSString* imagePath = nil;
   ATextureAtlasBasedSequence* pirateSequence = nil;
   UIImage* image = nil;
   
   // build the scene in this order (back to front):
   // sun, foreground, pirates

   
   ////////////////////////////////////////////////////////////////////////////////
   // sun
   layerSpec = element.sunLayer;
   
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
   
   self.sunLayer = layer;
   self.originalSunPosition = self.sunLayer.position;
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // foreground
   layerSpec = element.foregroundLayer;
   
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
   
   self.foregroundLayer = layer;

   ////////////////////////////////////////////////////////////////////////////////
   // pirates
   for (NSDictionary* pirateSequenceSpec in element.pirates)
   {
      pirateSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] initWithElement:pirateSequenceSpec RenderOnView:nil];
      
      [self.pirateSequences addObject:pirateSequence];
      
      [view.layer addSublayer:pirateSequence.layer];
      [pirateSequence release];
   }
   
   ////////////////////////////////////////////////////////////////////////////////
   // black
   layerSpec = element.blackLayer;
   
   layer = [[CALayer alloc] init];
   layer.frame = layerSpec.frame;
   
   layer.opacity = 0.0f;
   
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
   
   self.blackLayer = layer;
   
   ////////////////////////////////////////////////////////////////////////////////
   // The End
   layerSpec = element.theEndLayer;
   
   layer = [[CALayer alloc] init];
   layer.frame = layerSpec.frame;
   
   layer.opacity = 0.0f;
   
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
   
   self.theEndLayer = layer;
}

-(void)SetTheSun
{   
   CGPoint sunLayerPosition = self.sunLayer.position;
   
   CGPoint newPosition = CGPointMake(sunLayerPosition.x,
                                     sunLayerPosition.y+self.sunLayer.frame.size.height*1.2f);
   
   CABasicAnimation* setTheSunAnimation = [self AnimateTheSunFrom:sunLayerPosition To:newPosition];
   
   [CATransaction begin];
   
   self.sunLayer.position = newPosition;
   [self.sunLayer addAnimation:setTheSunAnimation forKey:@"position"];
   
   // ... and grow dark...
   self.blackLayer.opacity = 1.0f;
   [self.blackLayer addAnimation:[self GrowDarkAnimation] forKey:@"opacity"];
   
   [CATransaction commit];
}

-(CABasicAnimation*)AnimateTheSunFrom:(CGPoint)oldPosition To:(CGPoint)newPosition
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"position"];
   
   result.duration = kSetTheSunDuration;
      
   result.repeatCount = 0;
   result.autoreverses = NO;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
      
   result.fromValue = [NSValue valueWithCGPoint:oldPosition];
   result.toValue = [NSValue valueWithCGPoint:newPosition];
   
   return result;
}

-(CABasicAnimation*)GrowDarkAnimation
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"opacity"];
      
   result.duration = kGrowDarkDuration;
   
   result.repeatCount = 0;
   result.autoreverses = NO;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
         
   result.fromValue = [NSNumber numberWithFloat:0.0f];
   result.toValue = [NSNumber numberWithFloat:1.0f];
   
   return result;
}

-(CABasicAnimation*)ShowTheEndAnimation
{
   CABasicAnimation* result = [CABasicAnimation animationWithKeyPath:@"opacity"];
   result.delegate = self;
      
   result.duration = kShowTheEndDuration;
   
   result.repeatCount = 0;
   result.autoreverses = NO;
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
   
   result.fromValue = [NSNumber numberWithFloat:0.0f];
   result.toValue = [NSNumber numberWithFloat:1.0f];
   
   return result;
}

-(void)PlayTheme:(NSTimer*)timer
{
   self.closingTheme = [OALAudioTrack track];
   
   [self.closingTheme playFile:@"TreasureIsland.m4a" loops:0];
}

-(void)ShowTheEnd:(NSTimer*)timer
{
   [CATransaction begin];
   
   self.theEndLayer.opacity = 1.0f;
   [self.theEndLayer addAnimation:[self ShowTheEndAnimation] forKey:@"opacity"];
   
   [CATransaction commit];
}

-(void)IssueNotification:(NSTimer*)timer
{
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kNotificationTheEnd
    object:nil];
}

-(void)ClosingThemeStopped:(id)stopper
{
   [self.closingTheme clear];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self Stop];
   
   // start up the pirates
   for (ATextureAtlasBasedSequence* pirateSequence in self.pirateSequences)
   {
      [pirateSequence Start:triggered];
   }
   
   // start the sunset itself
   [self SetTheSun];
      

   // start the timer that will show "The End" label
   self.theEndTimer = [NSTimer timerWithTimeInterval:kTheEndDelay 
                                              target:self 
                                            selector:@selector(ShowTheEnd:) 
                                            userInfo:nil 
                                             repeats:NO];
   
   [[NSRunLoop currentRunLoop] addTimer:self.theEndTimer forMode:NSDefaultRunLoopMode];
   
   // start the timer that will play the Treasure Island theme
   self.closingThemeTimer = [NSTimer timerWithTimeInterval:kThemeDelay 
                                                    target:self 
                                                  selector:@selector(PlayTheme:) 
                                                  userInfo:nil 
                                                   repeats:NO];
   
   [[NSRunLoop currentRunLoop] addTimer:self.closingThemeTimer forMode:NSDefaultRunLoopMode];
}

-(void)Stop
{
   [super Stop];
   [self.closingTheme fadeTo:0.0f duration:2.0f target:nil selector:nil];   

   [self.theEndTimer invalidate];
   self.theEndTimer = nil;
   
   [self.closingThemeTimer invalidate];
   self.closingThemeTimer = nil;
   
   [self.foregroundLayer removeAllAnimations];
   [self.sunLayer removeAllAnimations];
   [self.blackLayer removeAllAnimations];
   [self.theEndLayer removeAllAnimations];
   
   self.sunLayer.position = self.originalSunPosition;
   
   self.theEndLayer.opacity = 0.0f; 
   self.blackLayer.opacity = 0.0f;
}

@end
