// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <QuartzCore/QuartzCore.h>

typedef double (^KeyframeParametricBlock)(double);

@interface CAKeyframeAnimation (Parametric)

+(id)animationWithKeyPath:(NSString*)path
                 function:(KeyframeParametricBlock)block
                fromValue:(double)fromValue
                  toValue:(double)toValue;

@end
