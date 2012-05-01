// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Spyglass.h"
#import "SpyglassSegment.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@implementation ASpyglass

@synthesize lastDriverPosition = fLastDriverPosition;

-(void)ProcessElementSegments:(NSDictionary*)element
{
   if (nil == self.layer)
   {
      CALayer* aLayer = [[CALayer alloc] init];
      self.layer = aLayer;
      [aLayer release];
   }
   
   for (NSDictionary* segmentSpec in element.segments)
   {
      ASpyglassSegment* imageSegment = [ASpyglassSegment imageSegmentFromSegmentSpec:segmentSpec];
      
      [self.imageSegments addObject:imageSegment];
      
      [self.layer addSublayer:imageSegment.layer];
   }
}

#pragma mark ACustomAnimation protocol
-(void)Stop
{
   
}

// retrieve the latest results recorded by the pan gesture recognizer and
// translate the position on the movable layers of the image
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{
   [super HandleGesture:sender];
   
   UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;

   CGFloat deltaX = ((CGPoint)[recognizer translationInView:self.imageView]).x;
   
   //NSLog(@"deltaX = %f", deltaX);

   [CATransaction begin];

   // disabling actions makes the animation of the layers smoother
   [CATransaction setDisableActions:YES];

   ASpyglassSegment* imageSegment = nil;

   imageSegment = [self.imageSegments objectAtIndex:2];
   
   //NSLog(@"segment 3 x = %f", imageSegment.layer.position.x);

   self.lastDriverPosition = [imageSegment MoveDeltaX:deltaX];

   imageSegment = [self.imageSegments objectAtIndex:1];
   
   //NSLog(@"segment 2 x = %f", imageSegment.layer.position.x);

   [imageSegment MoveDeltaX:deltaX DependingOn:self.lastDriverPosition];

   [CATransaction commit];

   [recognizer setTranslation:CGPointZero inView:self.imageView];
}

@end
