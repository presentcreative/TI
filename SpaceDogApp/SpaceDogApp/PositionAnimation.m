// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PositionAnimation.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@implementation APositionAnimation

@synthesize originalPosition=fOriginalPosition;
@synthesize xDelta=fXDelta;
@synthesize yDelta=fYDelta;
@synthesize updateToFinalPosition=fUpdateToFinalPosition;

-(void)BaseInit
{
   [super BaseInit];
   
   self.keyPath = @"position";
   self.originalPosition = CGPointZero;
   self.xDelta = 0.0f;
   self.yDelta = 0.0f;
   self.updateToFinalPosition = YES;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   [super BaseInitWithElement:element RenderOnLayer:layer];
   
   self.originalPosition = self.layer.position;
   self.xDelta = element.xDelta;
   self.yDelta = element.yDelta;
   self.updateToFinalPosition = element.updateToFinalPosition;
}

-(CAAnimation*)animation
{
   CABasicAnimation* result = (CABasicAnimation*)[super animation];
   
   result.removedOnCompletion = YES;
   result.fillMode = kCAFillModeRemoved;
      
   [result setValue:@"positionAnimation" forKey:@"animationId"];
   
   return result;
}

-(void)setKeyPath:(NSString*)propertyKey
{
   // ignored
}

-(void)StartAnimation
{
   CABasicAnimation* theAnimation = (CABasicAnimation*)[self animation];

   CGPoint currentPosition = self.layer.position;
   CGPoint newPosition = CGPointMake(currentPosition.x+self.xDelta, currentPosition.y+self.yDelta);
   
   theAnimation.fromValue = [NSValue valueWithCGPoint:currentPosition];
   theAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
   
   [CATransaction begin];
   
   if (self.updateToFinalPosition)
   {
      self.layer.position = newPosition;
   }
   
   [self.layer addAnimation:theAnimation forKey:self.keyPath];
   
   [CATransaction commit];
}

-(NSString*)keyPath
{
   return @"position";
}

#pragma mark ACustomAnimation protocol

-(void)Stop
{
   [super Stop];
   
   if (self.updateToFinalPosition)
   {
      // reset to original position
      self.layer.position = self.originalPosition;
   }
}

@end
