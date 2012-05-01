// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ZRotation.h"
#import "BookView.h"
#import "NSDictionary+ElementAndPropertyValues.h"
/*
 CGAffineTransform transformRotate = CGAffineTransformRotate (CGAffineTransformIdentity, rotation * M_PI/180.0);
 
 UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
 
 [UIView animateWithDuration: duration
 delay: delay
 options: animationOptions
 animations: ^{animationView.transform = transformRotate;}
 completion:nil];
 
*/

@interface AZRotation (Private)
-(void)SetAnchorPointAndPosition;
@end


@implementation AZRotation

@synthesize startAngle = fStartAngle;
@synthesize endAngle = fEndAngle;
@synthesize anchorPoint = fAnchorPoint;

-(void)BaseInit
{
   [super BaseInit];
   
   self.anchorPoint = CGPointZero;
   self.startAngle = 0.0f;
   self.endAngle = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{ 
   [super BaseInitWithElement:element RenderOnLayer:layer];
   
   self.anchorPoint = element.anchorPoint;
   self.startAngle = element.startAngle;
   self.endAngle = element.endAngle;
      
   [self SetAnchorPointAndPosition];
}

-(CAAnimation*)animation
{
   CABasicAnimation* result = (CABasicAnimation*)[super animation];
      
   result.removedOnCompletion = YES;
   result.fillMode = kCAFillModeRemoved;
      
   [result setValue:@"zRotation" forKey:@"animationId"];
   
   return result;
}

-(NSString*)keyPath
{
   return @"transform.rotation.z";
}

-(void)SetAnchorPointAndPosition
{
   self.layer.anchorPoint = self.anchorPoint;
   
   CGPoint correctedPosition = CGPointMake(self.layer.position.x + self.layer.bounds.size.width * (self.layer.anchorPoint.x - 0.5),
                                           self.layer.position.y + self.layer.bounds.size.height * (self.layer.anchorPoint.y -0.5));
   
   self.layer.position = correctedPosition;
}

-(void)StartAnimation
{ 
   CABasicAnimation* theAnimation = (CABasicAnimation*)[self animation];
   
   NSNumber* fromValue = [NSNumber numberWithDouble:DEGREES_TO_RADIANS(self.startAngle)];
   NSNumber* toValue = [NSNumber numberWithDouble:DEGREES_TO_RADIANS(self.endAngle)];

   theAnimation.fromValue = fromValue;
   theAnimation.toValue = toValue;
   
   [CATransaction begin];
   
   [self.layer setValue:toValue forKey:self.keyPath];
   
   [self.layer addAnimation:theAnimation forKey:self.keyPath];
   
   [CATransaction commit];
}

#pragma mark -
#pragma mark ACustomAnimation protocol

@end
