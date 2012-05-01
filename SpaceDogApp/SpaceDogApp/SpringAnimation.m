// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "SpringAnimation.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@implementation ASpringAnimation

@synthesize maximumExtension=fMaximumExtension;
@synthesize springTension=fSpringTension;

-(void)BaseInit
{
   [super BaseInit];
   
   self.maximumExtension = 1.0f;
   self.springTension = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.maximumExtension = element.maximumExtension;
   self.springTension = element.springTension;
}

-(CAAnimation*)animation
{
   CAKeyframeAnimation* result = (CAKeyframeAnimation*)[CAKeyframeAnimation animationWithKeyPath:self.keyPath];
   
   result.duration = self.duration;
      
   // calculate values and timings
   NSMutableArray* values = [NSMutableArray array];
   NSMutableArray* timings = [NSMutableArray array];
   
   CGFloat maxExtension = self.maximumExtension;
   CGFloat heightAtRest = self.layer.position.y;
   
   while (1.0f < maxExtension)
   {
      CGFloat bounceTop = heightAtRest + maxExtension;
      
      // go up...
      [values addObject:[NSNumber numberWithFloat:bounceTop]];
      [timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
      
      // and down...
      [values addObject:[NSNumber numberWithFloat:heightAtRest]];
      [timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
      
      maxExtension *= self.springTension;
   }
   
   result.values = values;
   result.timingFunctions = timings;
   
   // presence of a non-nil delegate property overrides presence of a completionNotification value
   if (nil != self.delegate)
   {
      result.delegate = self.delegate;
   }
   else 
   {
      // is the receiver required to issue any notifications when it completes?
      if (![@"" isEqualToString:self.completionNotification])
      {
         // make the receiver the delegate of the animation so that it can issue
         // a notification at the animation's completion
         result.delegate = self;
      }      
   }
   
   return result;
}

@end
