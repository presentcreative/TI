// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "SimplePropertyAnimation.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Constants.h"

@implementation ASimplePropertyAnimation

@synthesize fromValue = fFromValue;
@synthesize toValue = fToValue;
@synthesize updateToFinalValue=fUpdateToFinalValue;

-(void)dealloc
{
   Release(fFromValue);
   Release(fToValue);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.fromValue = [NSNumber numberWithUnsignedInteger:0];
   self.toValue = [NSNumber numberWithUnsignedInteger:0];
   self.updateToFinalValue = YES;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   [super BaseInitWithElement:element RenderOnLayer:layer];
   
   // from- and to- values can vary depending on the property being animated
   if ([@"bounds" isEqualToString:element.keyPath])
   {      
      // from- and to- values in the .plist are specified as Strings
      self.fromValue = [NSValue valueWithCGRect:CGRectFromString(element.fromValueString)];
      self.toValue = [NSValue valueWithCGRect:CGRectFromString(element.toValueString)];
   }
   else 
   {
      // assume NSNumbers
      self.fromValue = element.fromValue;
      self.toValue = element.toValue;
   }
   
   self.updateToFinalValue = element.updateToFinalValue;
}

-(void)BaseInitWithElement:(NSDictionary *)element RenderOnView:(UIView *)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   if (self.autoStart)
   {
      // ADPSIMPLE ???
     // [self Start];
   }
}

-(CAAnimation*)animation
{
   CABasicAnimation* result = (CABasicAnimation*)[super animation];
   
   result.removedOnCompletion = YES;
   result.fillMode = kCAFillModeRemoved;
   
   result.fromValue = self.fromValue;
   result.toValue = self.toValue;
   
   [result setValue:@"simplePropertyAnimation" forKey:@"animationId"];
   
   return result;
}

-(void)StartAnimation
{      
   [CATransaction begin];
   
   if (self.updateToFinalValue)
   {
      [self.layer setValue:self.toValue forKey:self.keyPath];
   }
   
   [self.layer addAnimation:[self animation] forKey:self.keyPath];
   
   [CATransaction commit];
}

#pragma mark -
#pragma ACustomAnimation protocol

-(void)Stop
{
   [super Stop];
   [CATransaction begin];
   [CATransaction setDisableActions:YES];
   
   [self.layer setValue:self.fromValue forKey:self.keyPath];
   
   [CATransaction commit];
}

@end
