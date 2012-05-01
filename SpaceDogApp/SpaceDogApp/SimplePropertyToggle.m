// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "SimplePropertyToggle.h"
#import "NSTimer+Blocks.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@interface ASimplePropertyToggle (Private)
-(void)CompleteAutoReverse;
@end


@implementation ASimplePropertyToggle

@synthesize startWithFromValue = fStartWithFromValue;
@synthesize reverseDelay = fReverseDelay;
@synthesize autoReverseInProgress = fAutoReverseInProgress;

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.startWithFromValue = YES;
   self.reverseDelay = 0.0f;
   self.autoReverseInProgress = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   [super BaseInitWithElement:element RenderOnLayer:layer];
   
   self.reverseDelay = element.reverseDelay;
}

-(CAAnimation*)animation
{
   CABasicAnimation* result = (CABasicAnimation*)[super animation];

   result.removedOnCompletion = YES;
   result.fillMode = kCAFillModeRemoved;
   
   [result setValue:@"simplePropertyToggle" forKey:@"animationId"];

   // ensure that the autoreverse value on the animation is always NO - this is
   // because, by definition, the receiver will reverse the effect of the animation
   // at some point of its choosing - it should not be done automatically by
   // Core Animation
   result.autoreverses = NO;
   
   return result;
}

-(void)StartAnimation
{
   CABasicAnimation* theAnimation = (CABasicAnimation*)[self animation];
   
   id fromValue = nil;
   id toValue = nil;

   if (self.startWithFromValue)
   {
      fromValue = self.fromValue;
      toValue = self.toValue;
   }
   else 
   {
      fromValue = self.toValue;
      toValue = self.fromValue;
   }
   
   theAnimation.fromValue = fromValue;
   theAnimation.toValue = toValue;
   
   [CATransaction begin];
   
   [self.layer setValue:toValue forKey:self.keyPath];
   [self.layer addAnimation:theAnimation forKey:self.keyPath];
   
   [CATransaction commit];
}

-(void)ForwardAnimationComplete:(NSNotification*)notification
{
   // remove the receiver as the observer of the Notification name, otherwise
   // we're into an infinite loop...
   [[NSNotificationCenter defaultCenter]
    removeObserver:self 
    name:[notification name] 
    object:nil];
   
   if (0.0f < self.reverseDelay)
   {
      [NSTimer scheduledTimerWithTimeInterval:self.reverseDelay block:^{
         [self CompleteAutoReverse];
      }
                                      repeats:NO];                
   }
   else 
   {
      [self CompleteAutoReverse];
   }
}

-(void)CompleteAutoReverse
{
   //[self.layer addAnimation:self.animation forKey:self.animationKey];
   [self StartAnimation];
   
   // make sure the next invocation goes in the opposite direction
   self.startWithFromValue = !self.startWithFromValue; 
   
   self.autoReverseInProgress = NO;   
}

#pragma mark -
#pragma mark ACustomAnimation protocol 
-(void)Start:(BOOL)triggered
{
   if (self.autoReverseInProgress)
   {
      // just get out!
      return;
   }
   
   // if autoReverse has been specified for this animation (possibly with a delay)
   // set that up first
   if (self.autoReverse)
   {
      // check to make sure all the necessary parameters have been specified
      // to allow for proper autoreversing
      if (![@"" isEqualToString:self.completionNotification])
      {
         [[NSNotificationCenter defaultCenter]
          addObserver:self
          selector:@selector(ForwardAnimationComplete:)
          name:self.completionNotification
          object:nil]; 
         
         self.autoReverseInProgress = YES;
      }
   }
   
   // trigger the animation
   [super Start:triggered];
   
   // assume, for now, that any sound effect only occurs on the 'forward' direction
   if (self.startWithFromValue && nil != self.soundEffect)
   {
      [self.soundEffect Start:YES];
   }
   
   // make sure the next invocation goes in the opposite direction
   self.startWithFromValue = !self.startWithFromValue;   
}

@end
