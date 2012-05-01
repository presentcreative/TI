// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "CAKeyframeAnimation+Parametric.h"

#define kTimeSteps 100

@implementation CAKeyframeAnimation (Parametric)

+(id)animationWithKeyPath:(NSString*)path 
                 function:(KeyframeParametricBlock)block 
                fromValue:(double)fromValue 
                  toValue:(double)toValue
{
   CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:path];
   
   NSUInteger steps = kTimeSteps;
   
   NSMutableArray* values = [NSMutableArray arrayWithCapacity:steps];
   
   double time = 0.0l;
   double timeStep = 1.0 / (double)(steps-1);
   
   // calculate the value at each step
   for (NSUInteger i = 0; i < steps; i++)
   {
      double value = fromValue + (block(time) * (toValue - fromValue));
      
      [values addObject:[NSNumber numberWithDouble:value]];
       
      time += timeStep;
   }
   
   // linear animation between keyframes, i.e. equal time steps
   animation.calculationMode = kCAAnimationLinear;
   
   animation.values = values;
   
   return animation;
}

@end
