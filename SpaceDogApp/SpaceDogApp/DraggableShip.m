// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <QuartzCore/QuartzCore.h>
#import "DraggableShip.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Constants.h"
#import "UIImage+Fixes.h"

// the function that describes the ship's motion over the waves
#define NEW_Y_FOR_X_IN_RECT(X, RECT_HEIGHT) ((RECT_HEIGHT/14) * sin(((int)(X*2) % 360) * M_PI/180))

#define kShipLayerMovementCheckInterval   0.4f  // seconds

@implementation ADraggableShip

@synthesize dragMinX = fDragMinX;
@synthesize dragMaxX = fDragMaxX;
@synthesize lastX = fLastX;
@synthesize originalFrame = fOriginalFrame;
@synthesize initialYOffset = fInitialYOffset;
@synthesize shipIsBobbing = fShipIsBobbing;
@synthesize shipLayer = fShipLayer;
@synthesize lastMovementTimestamp = fLastMovementTimestamp;
@synthesize bobbingTimer = fBobbingTimer;

-(void)dealloc
{
   if (nil != self.shipLayer)
   {
      self.shipLayer.delegate = nil;
      
      if (nil != self.shipLayer.superlayer)
      {
         [self.shipLayer removeFromSuperlayer];
      }
   }
   
   if (nil != self.bobbingTimer)
   {
      [self.bobbingTimer invalidate];
      self.bobbingTimer = nil;
   }
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.dragMinX = 0.0f;
   self.dragMaxX = 0.0f;
   self.lastX = 0.0f;
   self.originalFrame = CGRectZero;
   self.initialYOffset = 0.0f; 
   self.shipIsBobbing = NO;
   self.lastMovementTimestamp = [NSDate date];
   self.bobbingTimer = nil;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   // load miscellaneous parameters
   self.dragMinX = element.dragMinX;
   self.dragMaxX = element.dragMaxX;
        
   self.originalFrame = element.frame;
   
   self.initialYOffset = NEW_Y_FOR_X_IN_RECT(self.originalFrame.origin.x, self.originalFrame.size.height);
   
   CGRect frame = self.originalFrame;
   
   frame.origin.y = frame.origin.y + self.initialYOffset;

   self.lastX = frame.origin.x;
   
   // the receiver handles gestures in the view itself, for better user experience
   UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] 
                                            initWithTarget:self 
                                            action:@selector(HandleGesture:)];
   panRecognizer.minimumNumberOfTouches = 1;
   panRecognizer.maximumNumberOfTouches = 1;
   panRecognizer.delegate = self;
   [self.containerView addGestureRecognizer:panRecognizer];
   [panRecognizer release];
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.shipLayer = aLayer;
   [aLayer release];
   
   self.shipLayer.frame = element.frame;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:element.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.shipLayer setContents:(id)image.CGImage];
   [image release];
      
   [view.layer addSublayer:self.shipLayer];   
}

-(void)BobTheShip
{
   CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
   animation.delegate = self;
   animation.duration = 1.0f;
   animation.repeatCount = NSUIntegerMax;
   animation.autoreverses = YES;
   animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
   
   CGPoint shipLayerPosition = self.shipLayer.position;
   
   NSValue* currentPositionValue = [NSValue valueWithCGPoint:shipLayerPosition];
   NSValue* newPositionValue = [NSValue valueWithCGPoint:CGPointMake(shipLayerPosition.x, shipLayerPosition.y+10.0f)];
   
   animation.fromValue = currentPositionValue;
   animation.toValue = newPositionValue;
   
   [self.shipLayer addAnimation:animation forKey:@"position"];
   self.shipIsBobbing = YES;
}

-(void)CheckForShipMovement:(NSTimer*)timer
{      
   // has the boat moved recently?   
   if (fabs([self.lastMovementTimestamp timeIntervalSinceNow]) > kShipLayerMovementCheckInterval)
   {
      // yep, resume bobbing
      if (!self.shipIsBobbing)
      {
         [self BobTheShip];
      }
   }
   else 
   {
      // nope, reset the fire date
      [self.bobbingTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kShipLayerMovementCheckInterval]];
   }
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self BobTheShip];
}

// Handle the pan gesture in order to move the ship across the map
-(void)HandleGesture:(UIGestureRecognizer*)recognizer
{
   // the reader is attempting to move the ship - kill the bobbing animation 
   [self.shipLayer removeAllAnimations];
   self.shipIsBobbing = NO;

   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)recognizer;
   
   // what horizontal distance did the user's finger move?
   CGFloat deltaX = ((CGPoint)[panRecognizer translationInView:self.containerView]).x;
   
   CGFloat newX = 0.0f;
         
   // calculate a new X for the ship's frame, clamping it at its min/max X, if necessary 
   CGRect shipFrame = self.shipLayer.frame;
   
   if ((shipFrame.origin.x + deltaX >= self.dragMinX) && (shipFrame.origin.x + deltaX <= self.dragMaxX))
   {
      newX = deltaX;
   }
   
   // update to the new, actual X value
   self.lastX += newX;
   
   // for the new actual X value, calculate a new Y value
   CGFloat deltaY = NEW_Y_FOR_X_IN_RECT(self.lastX, shipFrame.size.height);
   
   // apply the new X and Y values to the ship's frame
   CGRect origFrame = self.originalFrame;
   CGRect newFrame = self.originalFrame;
   
   newFrame.origin.x = self.lastX;
   newFrame.origin.y = origFrame.origin.y + deltaY;
   
   //DLog(@"X = %f, deltaY = %f, Y = %f", newFrame.origin.x, deltaY, newFrame.origin.y);
   
   // finally, move the ship
   [CATransaction begin];
   [CATransaction setDisableActions:YES];
   
   self.shipLayer.frame = newFrame;
   
   [CATransaction commit];
               
   // update the pan recognizer so that the next event received is with
   // respect to the current pan position
   [panRecognizer setTranslation:CGPointZero inView:self.containerView]; 
   
   // note the time at which the last movement occurred
   self.lastMovementTimestamp = [NSDate date];
   
   // start/reset a timer so that if the boat hasn't moved in awhile, we can re-start
   // the bobbing animation
   if (nil == self.bobbingTimer)
   {
      self.bobbingTimer = [NSTimer timerWithTimeInterval:kShipLayerMovementCheckInterval 
                                                  target:self 
                                                selector:@selector(CheckForShipMovement:) 
                                                userInfo:nil 
                                                 repeats:YES];
      
      [[NSRunLoop currentRunLoop] addTimer:self.bobbingTimer forMode:NSDefaultRunLoopMode];
   }
   else 
   {
      [self.bobbingTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kShipLayerMovementCheckInterval]];
   }
}

#pragma mark -
#pragma CAAnimationDelegate protocol
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
   if (flag)
   {
      // set the current position of the layer so that there's no noticable jumping
      // around of the layer
      [CATransaction begin];
      [CATransaction setDisableActions:YES];
      
      self.shipLayer.position = ((CALayer*)[self.shipLayer presentationLayer]).position;
      
      [CATransaction commit];
   }
}

#pragma mark UIGestureRecognizerDelegate protocol
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
   
   if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
   {
      CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
      
      CGRect shipFrame = self.shipLayer.frame;
      
      if (CGRectContainsPoint(shipFrame, touchLocation))
      {
         result = YES;
      }
   }
   
   return result;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
   return YES;
}

@end
