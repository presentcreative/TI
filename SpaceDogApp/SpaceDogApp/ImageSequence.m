// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ImageSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "NSString+PropertyValues.h"
#import "ObjectAL.h"

@implementation AImageSequence

@synthesize sequenceIndex = fSequenceIndex;
@synthesize baseSequence = fBaseSequence;
@synthesize soundEffect = fSoundEffect;
@synthesize numRepeats = fNumRepeats;
@synthesize duration = fDuration;
@synthesize repeatType = fRepeatType;
@synthesize repeatDelay = fRepeatDelay;
@synthesize repeatDelayMin = fRepeatDelayMin;
@synthesize repeatDelayMax = fRepeatDelayMax;
@synthesize autoreverses = fAutoreverses;
@synthesize timingFunctionName = fTimingFunctionName;
@synthesize transitions = fTransitions;
@synthesize sequenceCount = fSequenceCount;
@synthesize propertyEffects = fPropertyEffects;
@synthesize imageIndices = fImageIndices;
@synthesize postExecutionNotification = fPostExecutionNotification;
@synthesize unpatterned=fUnpatterned;
@synthesize initialFrame=fInitialFrame;
@synthesize hasToggleProperty=HasToggleProperty;

-(id)init
{
   if (self = [super init])
   {
      self.sequenceIndex = 0;
      self.baseSequence = NO;
      self.duration = 0.0;
      self.repeatType = FINITE;
      self.numRepeats = 0;
      self.repeatDelay = 0.0f;
      self.repeatDelayMin = 0.0f;
      self.repeatDelayMax = 0.0f;
      self.autoreverses = NO;
      self.timingFunctionName = @"";
      fNextImageIndex = 1;
      self.sequenceCount = 0;
      self.propertyEffects = [NSMutableDictionary dictionary];
      self.imageIndices = NSMakeRange(0, 0);
      self.soundEffect = nil;
      self.postExecutionNotification = @"";
      self.unpatterned = NO;
      self.initialFrame = 0;
   }
   
   return self;
}

-(void)dealloc
{   
   Release(fSoundEffect);
   Release(fTransitions);
   Release(fPropertyEffects);
   Release(fTimingFunctionName);
   Release(fPostExecutionNotification);
   
   [super dealloc];
}

-(AImageSequence*)initWithSequenceSpec:(NSDictionary*)sequenceSpec
{
   if (self = [self init])
   {
      self.imageIndices = NSRangeFromString(sequenceSpec.imageIndices);
      
      if (sequenceSpec.hasRepeatType)
      {
         if ([@"CONTINUOUS" isEqualToString:sequenceSpec.repeatType])
         {
            self.repeatType = CONTINUOUS;
            self.numRepeats = NSUIntegerMax;
         }
         else if ([@"CONTINUOUS_WITH_DELAY" isEqualToString:sequenceSpec.repeatType])
         {
            self.repeatType = CONTINUOUS_WITH_DELAY;
            self.numRepeats = 0;
            self.repeatDelay = sequenceSpec.repeatDelay;
         }
         else if ([@"CONTINUOUS_WITH_RANDOM_DELAY" isEqualToString:sequenceSpec.repeatType])
         {
            self.repeatType = CONTINUOUS_WITH_RANDOM_DELAY;
            self.numRepeats = 0;
            self.repeatDelayMin = sequenceSpec.repeatDelayMin;
            self.repeatDelayMax = sequenceSpec.repeatDelayMax;
         }
      }
      else 
      {
         self.repeatType = FINITE;
         self.numRepeats = sequenceSpec.numRepeats;
      }
      
       self.hasToggleProperty = sequenceSpec.hasToggleProperty; 
       
      self.duration = sequenceSpec.duration;
      
      if (sequenceSpec.hasAutoReverse)
      {
         self.autoreverses = sequenceSpec.autoReverse;
      }
      
      if (sequenceSpec.hasTimingFunctionName)
      {
         self.timingFunctionName = sequenceSpec.timingFunctionName;
      }
      
      // is there a sound effect associated with this sequence?
      if (sequenceSpec.hasSoundEffect)
      {
         Class soundEffectClass = NSClassFromString(sequenceSpec.soundEffect.customClass);
         id<ACustomAnimation> sound = [[soundEffectClass alloc] initWithElement:sequenceSpec.soundEffect RenderOnView:nil];
         self.soundEffect = sound;
         [(NSObject*)sound release];
      }
      
      if (sequenceSpec.hasPostExecutionNotification)
      {
         self.postExecutionNotification = sequenceSpec.postExecutionNotification;
      }
      
      // what sequence,frame pair precedes this sequence?
      self.transitions = [NSMutableArray arrayWithCapacity:[sequenceSpec.transitions count]];
      
      for (NSString* transitionString in sequenceSpec.transitions)
      {
         [self.transitions addObject:[transitionString asSequenceTransitionValue]];
      }
      
      if (sequenceSpec.hasPropertyEffects)
      {
         for (NSDictionary* propertyEffect in sequenceSpec.propertyEffects)
         {
            NSString* offset = propertyEffect.offset;
            
            NSMutableArray* effects = [self.propertyEffects objectForKey:offset];
            
            if (nil == effects)
            {
               effects = [NSMutableArray array];
               
               [self.propertyEffects setObject:effects forKey:offset];
            }
            
            [effects addObjectsFromArray:propertyEffect.effects];
         }
      }
      
      self.unpatterned = sequenceSpec.unpatterned;
      self.initialFrame = sequenceSpec.initialFrame;
   }
   
   return self;
}


-(BOOL)hasSoundEffect
{
   return nil != self.soundEffect;
}

-(NSUInteger)numFrames
{
   return self.imageIndices.length;
}

-(NSUInteger)firstImageIndex
{
   return self.imageIndices.location;
}

-(NSUInteger)nextImageIndex
{
   NSUInteger imageIndex = fNextImageIndex;
   
   fNextImageIndex = self.imageIndices.location + ((fNextImageIndex + 1) % self.imageIndices.length);
   
   return imageIndex;
}

-(NSArray*)preSequencePropertyEffects
{
   return [self.propertyEffects objectForKey:@"BEFORE"];
}

-(NSArray*)postSequencePropertyEffects
{
   return [self.propertyEffects objectForKey:@"AFTER"];
}

-(NSUInteger)frameLastDisplayed
{
   return fNextImageIndex - 1;
}

-(BOOL)needsTransition
{
   return (!self.baseSequence && self.numRepeats == 0 && self.frameLastDisplayed == self.imageIndices.length+self.imageIndices.length-1);
}

-(BOOL)isSingleImageSequence
{
   return 1 == self.imageIndices.length;
}

-(BOOL)isImageless
{   
   return 0 == self.imageIndices.length;   
}

-(BOOL)isFiniteRepeat
{
   return FINITE == self.repeatType;
}

-(BOOL)isContinuousRepeat
{
   return CONTINUOUS == self.repeatType;
}

-(BOOL)isContinuousWithDelayRepeat
{
   return CONTINUOUS_WITH_DELAY == self.repeatType;
}

-(BOOL)isContinuousWithRandomDelayRepeat
{
   return CONTINUOUS_WITH_RANDOM_DELAY == self.repeatType;
}

-(BOOL)hasPostExecutionNotification
{
   return ![@"" isEqualToString:self.postExecutionNotification];
}

-(CAAnimation*)reverseAnimation
{
   CABasicAnimation* result = (CABasicAnimation*)self.animation;
   
   // simply swap the from- and to- values...
   NSNumber* oldFromValue = result.fromValue;
   NSNumber* oldToValue = result.toValue;
   
   result.fromValue = oldToValue;
   result.toValue = oldFromValue;
   
   return result;
}

-(CAAnimation*)animation
{
   // Answer an animation based on the receiver's properties
   CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"imageIndex"];
   animation.fromValue = [NSNumber numberWithUnsignedInteger:self.imageIndices.location];
   animation.toValue = [NSNumber numberWithUnsignedInteger:(self.imageIndices.location+self.imageIndices.length)];
//   animation.fillMode = kCAFillModeForwards;
//   animation.removedOnCompletion = NO;
   animation.autoreverses = self.autoreverses;
   animation.duration = self.duration;
   animation.repeatCount = self.numRepeats;
   
   if (![@"" isEqualToString:self.timingFunctionName])
   {
      NSString* timingFunctionId;
      
      if ([@"Linear" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionLinear;
      }
      else if ([@"EaseIn" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionEaseIn;
      }
      else if ([@"EaseOut" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionEaseOut;
      }
      else if ([@"EaseInEaseOut" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionEaseInEaseOut;
      }
      else 
      {
         timingFunctionId = kCAMediaTimingFunctionDefault;
      }
      
      animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionId];
   }
   
   [animation setValue:self.animationKey forKey:@"animationKey"];

   return animation;
}

-(CAAnimation*)animationFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
   CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"imageIndex"];
   animation.fromValue = [NSNumber numberWithUnsignedInteger:fromIndex];
   animation.toValue = [NSNumber numberWithUnsignedInteger:toIndex];
//   animation.fillMode = kCAFillModeForwards;
//   animation.removedOnCompletion = NO;
   animation.autoreverses = self.autoreverses;
   animation.duration = self.duration;
   animation.repeatCount = self.numRepeats;
   
   if (![@"" isEqualToString:self.timingFunctionName])
   {
      NSString* timingFunctionId;
      
      if ([@"Linear" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionLinear;
      }
      else if ([@"EaseIn" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionEaseIn;
      }
      else if ([@"EaseOut" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionEaseOut;
      }
      else if ([@"EaseInEaseOut" isEqualToString:self.timingFunctionName])
      {
         timingFunctionId = kCAMediaTimingFunctionEaseInEaseOut;
      }
      else 
      {
         timingFunctionId = kCAMediaTimingFunctionDefault;
      }
      
      animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionId];
   }
      
   return animation;   
}


-(NSString*)animationKey
{
   return [NSString stringWithFormat:@"sequence_%d", self.sequenceIndex];
}

-(void)IssuePostExecutionNotification
{
   [[NSNotificationCenter defaultCenter]
    postNotificationName:self.postExecutionNotification
    object:nil];
}

@end
