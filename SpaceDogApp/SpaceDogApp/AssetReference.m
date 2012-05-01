// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

// AAssetReference
// Asset reference container class

#import <QuartzCore/QuartzCore.h>
#import "AssetReference.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@interface AAssetReference (Private)
-(void)initFromElement:(NSDictionary *)element;
@end



@implementation AAssetReference

@synthesize fElement;
@synthesize fImgView;
@synthesize fActivePropertyIndex;
@synthesize fLayer;
@synthesize fSequencedAnimations;
@synthesize fDelayType;
@synthesize fDelayMinimum;
@synthesize fDelayMaximum;
@synthesize fFixedDelay;
@synthesize fIsConcurrent;
@synthesize fAnimationGroup;
@synthesize fStandaloneAnimation;
@synthesize fCustomAnimation;
@synthesize fPostAnimationNotification;

-(id)initWithIndex:(NSUInteger)index AndElement:(NSDictionary*)element AndImgView:(UIImageView*)imgView
{
   self = [super init];
   if (self)
   {
      fElementIndex = index;
      self.fElement = element;
      self.fImgView = imgView;
      self.fActivePropertyIndex = 0;
      self.fLayer = nil;
      
      OrderedDictionary* sequencedAnimations = [[OrderedDictionary alloc] initWithCapacity:16];
      self.fSequencedAnimations = sequencedAnimations;
      [sequencedAnimations release];
      
      self.fDelayType = kDelayTypeNone;
      self.fDelayMinimum = 0.0f;
      self.fDelayMaximum = 0.0f;
      self.fIsConcurrent = NO;
      self.fAnimationGroup = @"";
      self.fStandaloneAnimation = nil;
      self.fCustomAnimation = nil;
      self.fPostAnimationNotification = @"";
      
      [self initFromElement:element];
   }
   return self;
}

-(id)initWithIndex:(NSUInteger)index AndElement:(NSDictionary*)element AndLayer:(CALayer*)layer
{
   self = [super init];
   if (self)
   {
      fElementIndex = index;
      self.fElement = element;
      self.fImgView = nil;
      self.fActivePropertyIndex = 0;
      self.fLayer = layer;
      
      OrderedDictionary* sequencedAnimations = [[OrderedDictionary alloc] initWithCapacity:16];
      self.fSequencedAnimations = sequencedAnimations;
      [sequencedAnimations release];
      
      self.fDelayType = kDelayTypeNone;
      self.fDelayMinimum = 0.0f;
      self.fDelayMaximum = 0.0f;
      self.fIsConcurrent = NO;
      self.fAnimationGroup = @"";
      self.fStandaloneAnimation = nil;
      self.fCustomAnimation = nil;
      self.fPostAnimationNotification = @"";
      
      [self initFromElement:element];
   }
   return self;
}

-(id)initWithIndex:(NSUInteger)index AndElement:(NSDictionary*)element AndCustomAnimation:(id<ACustomAnimation>)customAnimation
{
   self = [super init];
   if (self)
   {
      fElementIndex = index;
      self.fElement = element;
      self.fImgView = nil;
      self.fActivePropertyIndex = 0;
      self.fLayer = nil;
      
      OrderedDictionary* sequencedAnimations = [[OrderedDictionary alloc] initWithCapacity:16];
      self.fSequencedAnimations = sequencedAnimations;
      [sequencedAnimations release];
      
      self.fDelayType = kDelayTypeNone;
      self.fDelayMinimum = 0.0f;
      self.fDelayMaximum = 0.0f;
      self.fIsConcurrent = NO;
      self.fAnimationGroup = @"";
      self.fStandaloneAnimation = nil;
      self.fCustomAnimation = customAnimation;
      self.fPostAnimationNotification = @"";
      
      [self initFromElement:element];
   }
   return self;   
}

- (void)dealloc 
{
   if (fLayer.superlayer)
   {
      [fLayer removeFromSuperlayer];
   }

   [fElement release];
   [fImgView release];
   [fLayer release];
   [fSequencedAnimations release];
   [fDelayType release];
   [fAnimationGroup release];
   [fStandaloneAnimation release];
   [fPostAnimationNotification release];
   //[fCustomAnimation release];
   
   [super dealloc];
}

#pragma mark -
#pragma mark Properties
-(CGFloat)fFixedDelay
{
   return self.fDelayMinimum;
}

-(void)setFFixedDelay:(CGFloat)delay
{
   self.fDelayMinimum = delay;
}

-(void)RunNextSequencedAnimation
{
   id animationKey = [self.fSequencedAnimations keyAtIndex:self.fActivePropertyIndex];
   
   CAAnimation* animation = [self.fSequencedAnimations objectForKey:animationKey];
   
   if (nil != animation)
   {
      [self.fLayer addAnimation:animation forKey:[animation valueForKey:@"property"]];      
   }
}

-(void)RunTriggeredAnimation
{
   NSEnumerator* keyEnumerator = [self.fSequencedAnimations keyEnumerator];
   
   id animationKey;
   
   while ((animationKey = [keyEnumerator nextObject]))
   {
      CAAnimation* animation = [self.fSequencedAnimations objectForKey:animationKey];
      
      if (nil != animation)
      {
         [self.fLayer addAnimation:animation forKey:[animation valueForKey:@"property"]];      
      }
   }
   
   if (![@"" isEqualToString:self.fPostAnimationNotification])
   {
      [[NSNotificationCenter defaultCenter]
       postNotificationName:self.fPostAnimationNotification
       object:self];
   }
}

@end

@implementation AAssetReference (Private)

-(void)initFromElement:(NSDictionary*)element
{
   // init the delay related properties
   NSString* delayType = (NSString*)[element objectForKey:@"delayType"];
   
   if (nil == delayType)
   {
      // no delay specified - we're outta here...
      return;
   }
   
   if ([kDelayTypeNone isEqualToString:delayType])
   {
      // default delay specified
      self.fDelayType = kDelayTypeNone;
      self.fDelayMinimum = 0.0f;
      self.fDelayMaximum = 0.0f;
      
      return;
   }
   
   if ([kDelayTypeFixed isEqualToString:delayType])
   {
      self.fDelayType = kDelayTypeFixed;
      
      CGFloat fixedDelay = kDelayDefault;
      
      NSNumber* fixedDelayNumber = (NSNumber*)[element objectForKey:@"delay"];
      if (nil != fixedDelayNumber)
      {
         fixedDelay = [fixedDelayNumber floatValue];
      }
      
      self.fFixedDelay = fixedDelay;
      
      return;
   }
   
   if ([kDelayTypeVariable isEqualToString:delayType])
   {
      self.fDelayType = kDelayTypeVariable;
      
      CGFloat delayMinimum = kVariableDelayMinimum;
      CGFloat delayMaximum = kVariableDelayMaximum;
      
      NSNumber* variableDelayMiniumNumber = (NSNumber*)[element objectForKey:@"delayMinimum"];
      if (nil != variableDelayMiniumNumber)
      {
         delayMinimum = [variableDelayMiniumNumber floatValue];
      }
      
      self.fDelayMinimum = delayMinimum;
      
      NSNumber* variableDelayMaxiumNumber = (NSNumber*)[element objectForKey:@"delayMaximum"];
      if (nil != variableDelayMaxiumNumber)
      {
         delayMaximum = [variableDelayMaxiumNumber floatValue];
      }
      
      self.fDelayMaximum = delayMaximum; 
      
      return;
   }
   
   // are there any notifications to be issued after an animation is run?
   if (element.hasPostAnimationNotification)
   {
      self.fPostAnimationNotification = element.postAnimationNotification;
   }
}

@end
