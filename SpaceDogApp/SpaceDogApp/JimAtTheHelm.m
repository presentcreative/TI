// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "JimAtTheHelm.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Trigger.h"
#import "TextureAtlasBasedSequence.h"
#import "TriggeredTextureAtlasBasedSequence.h"

#define kPortSailAnimation       @"portSailAnimation"
#define kStarbordSailAnimation   @"starbordSailAnimation"

#define kWheelEaseRotation 10    // degrees
#define kWheelEaseDuration 1.0f  // seconds

@interface AJimAtTheHelm (Private)
-(void)TurnToStarbord;
-(void)TurnToPort;
@end


@implementation AJimAtTheHelm

@synthesize wheelLayer=fWheelLayer;
@synthesize ropeCWLayer=fRopeCWLayer;
@synthesize ropeCCWLayer=fRopeCCWLayer;
@synthesize sailPortLayer=fSailPortLayer;
@synthesize sailStarbordLayer=fSailStarbordLayer;
@synthesize yMovement=fYMovement;
@synthesize yMovementThreshold=fYMovementThreshold;
@synthesize wheelLeftRegion=fWheelLeftRegion;
@synthesize wheelRightRegion=fWheelRightRegion;
@synthesize currentTurn=fCurrentTurn;
@synthesize lastRotationAngle=fLastRotationAngle;

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   self.wheelLayer.delegate = nil;
   if (self.wheelLayer.superlayer)
   {
      [self.wheelLayer removeFromSuperlayer];
   }   
   Release(fWheelLayer);
   
   self.ropeCWLayer.delegate = nil;
   if (self.ropeCWLayer.superlayer)
   {
      [self.ropeCWLayer removeFromSuperlayer];
   }
   Release(fRopeCWLayer);
   
   self.ropeCCWLayer.delegate = nil;
   if (self.ropeCCWLayer.superlayer)
   {
      [self.ropeCCWLayer removeFromSuperlayer];
   }
   Release(fRopeCCWLayer);
   
   self.sailPortLayer.delegate = nil;
   if (self.sailPortLayer.superlayer)
   {
      [self.sailPortLayer removeFromSuperlayer];
   }
   Release(fSailPortLayer);
   
   self.sailStarbordLayer.delegate = nil;
   if (self.sailStarbordLayer.superlayer)
   {
      [self.sailStarbordLayer removeFromSuperlayer];
   }
   Release(fSailStarbordLayer);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.currentTurn = Port;
   self.yMovementThreshold = CGFLOAT_MAX;
   self.yMovement = 0.0f;
   self.wheelLeftRegion = CGRectZero;
   self.wheelRightRegion = CGRectZero;
   self.lastRotationAngle = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
      
   self.yMovementThreshold = element.yMovementThreshold;
   
   ATextureAtlasBasedSequence* tSequence = nil;
   UIImage* image = nil;
   
   ////////////////////////////////////////////////////////////////////////////////
   // port sail
   
   tSequence = (ATriggeredTextureAtlasBasedSequence*)[[ATriggeredTextureAtlasBasedSequence alloc] 
                                                      initWithElement:element.sailPortLayer 
                                                      RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:kPortSailAnimation];
   self.sailPortLayer = tSequence.layer;
   self.sailPortLayer.opacity = 0.0f;
   [tSequence release];
   [view.layer addSublayer:self.sailPortLayer];
   
   [[NSNotificationCenter defaultCenter] 
    addObserver:self 
    selector:@selector(TurnToPortCompleted:) 
    name:@"CH24_TURN_TO_PORT_COMPLETED" 
    object:nil];
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // starbord sail 
   
   tSequence = (ATriggeredTextureAtlasBasedSequence*)[[ATriggeredTextureAtlasBasedSequence alloc] 
                                                      initWithElement:element.sailStarbordLayer 
                                                      RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:kStarbordSailAnimation];
   self.sailStarbordLayer = tSequence.layer;
   self.sailStarbordLayer.opacity = 1.0f;
   [tSequence release];
   [view.layer addSublayer:self.sailStarbordLayer];
   
   [[NSNotificationCenter defaultCenter] 
    addObserver:self 
    selector:@selector(TurnToStarbordCompleted:) 
    name:@"CH24_TURN_TO_STARBORD_COMPLETED" 
    object:nil];
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // rope cw

   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.ropeCWLayer 
                RenderOnView:nil];
   
   [self.animations addObject:tSequence];
   self.ropeCWLayer = tSequence.layer;
   self.ropeCWLayer.zPosition = 0;
   [tSequence release];
   [view.layer addSublayer:self.ropeCWLayer];   
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // rope ccw

   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.ropeCCWLayer 
                RenderOnView:nil];
   
   [self.animations addObject:tSequence];
   self.ropeCCWLayer = tSequence.layer;
   self.ropeCCWLayer.zPosition = 1;
   [tSequence release];
   [view.layer addSublayer:self.ropeCCWLayer];
   
   ////////////////////////////////////////////////////////////////////////////////
   // ship's wheel
   NSDictionary* layerSpec = element.wheelLayer;
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.wheelLayer = aLayer;
   [aLayer release];
   
   CGRect wheelFrame = layerSpec.frame;
   self.wheelLayer.frame = wheelFrame;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.wheelLayer setContents:(id)image.CGImage];
   [image release];
   [view.layer addSublayer:self.wheelLayer];
   
   // set up the left and right 'wheel regions'. These are used to determine whether
   // the reader is panning on the left hand side of the ship's wheel or the right hand
   // side of the ship's wheel
   self.wheelLeftRegion = CGRectMake(wheelFrame.origin.x, 
                                     wheelFrame.origin.y, 
                                     wheelFrame.size.width/2.0f, 
                                     wheelFrame.size.height);
   
   self.wheelRightRegion = CGRectMake(wheelFrame.origin.x + wheelFrame.size.width/2.0f, 
                                      wheelFrame.origin.y, 
                                      wheelFrame.size.width/2.0f, 
                                      wheelFrame.size.height);
   
   // ship's helm
   layerSpec = element.helmLayer;
   
   CALayer* helmLayer = [[CALayer alloc] init];
   
   helmLayer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [helmLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [helmLayer setContents:(id)image.CGImage]; 
   [view.layer addSublayer:helmLayer];
   [image release];
   [helmLayer release];
}

-(void)TurnToStarbord
{
   if (Starbord == self.currentTurn)
   {
      return;
   }
   
   [[self.animationsByName objectForKey:kStarbordSailAnimation] Trigger];
   
   self.ropeCCWLayer.zPosition = 1;
   self.ropeCWLayer.zPosition = 0;
   
   self.currentTurn = Starbord;
}

-(void)TurnToStarbordCompleted:(NSNotification*)notification
{   
   [CATransaction begin];
   [CATransaction setDisableActions:YES];
   
   self.sailPortLayer.opacity = 1.0f;
   self.sailStarbordLayer.opacity = 0.0f;
   
   [CATransaction commit];
   
   [[self.animationsByName objectForKey:kStarbordSailAnimation] PositionOnBaseSequence];
}

-(void)TurnToPort
{
   if (Port == self.currentTurn)
   {
      return;
   } 
      
   [[self.animationsByName objectForKey:kPortSailAnimation] Trigger];

   self.ropeCCWLayer.zPosition = 0;
   self.ropeCWLayer.zPosition = 1;
   
   self.currentTurn = Port;
}

-(void)TurnToPortCompleted:(NSNotification*)notification
{
   [CATransaction begin];
   [CATransaction setDisableActions:YES];

   self.sailStarbordLayer.opacity = 1.0f;
   self.sailPortLayer.opacity = 0.0f;
   
   [CATransaction commit];
   
   [[self.animationsByName objectForKey:kPortSailAnimation] PositionOnBaseSequence];
}

#pragma mark ACustomAnimation protocol
// retrieve the latest results recorded by the pan gesture recognizers and
// translate the position on the movable layer of the image
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{ 
   UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
   
   if (UIGestureRecognizerStateEnded == recognizer.state)
   {      
      [CATransaction begin];
      [CATransaction setDisableActions:NO];
      [CATransaction setAnimationDuration:kWheelEaseDuration];
      [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
      
      self.wheelLayer.transform = CATransform3DRotate(self.wheelLayer.transform, 
                                                      self.lastRotationAngle/1.5f, 
                                                      0.0f, 0.0f, 1.0f);
      
      [CATransaction commit];
   }
   
   CGPoint deltaXY = (CGPoint)[recognizer translationInView:self.containerView];
      
   // did the touch occur in the left or right half of the recognizer's region?
   CGFloat signModifier = 1.0f; // assume right hand side...
   
   if (CGRectContainsPoint(self.wheelLeftRegion, [sender locationInView:self.containerView]))
   {
      signModifier = -1.0f;
   }
   
   CGFloat yValue = deltaXY.y * signModifier;
   
   if (0.0f == self.yMovement)
   {
      self.yMovement = yValue;
      
      return;
   }
   
   self.yMovement = self.yMovement + yValue;
   
   //NSLog(@"total yMovement = %f", self.yMovement);
   
   // move the wheel
   // calculate the angular motion of the wheel (radians)
   CGFloat rotationAngle = atan(yValue/(self.wheelLayer.frame.size.width/2));
   
   [CATransaction begin];
   [CATransaction setDisableActions:YES];
   
   self.wheelLayer.transform = CATransform3DRotate(self.wheelLayer.transform, 
                                                   rotationAngle, 
                                                   0.0f, 0.0f, 1.0f);
      
   [CATransaction commit];
   
   self.lastRotationAngle = rotationAngle;
   
   // has the wheel moved far enough to change the tack of the ship?
   if (self.yMovementThreshold < fabs(self.yMovement))
   {
      // nope, just get out
      [recognizer setTranslation:CGPointZero inView:self.containerView];
      
      return;
   }
   
   // yes!
   [CATransaction begin];
   [CATransaction setDisableActions:YES];
      
   // is the wheel being spun CW or CCW (from Jim's point of view)?
   // if CW, deltaXY.y will be decreasing, otherwise deltaXY.y will be
   // increasing, thus wheel is being spun CCW
   if (0.0f > self.yMovement)
   {
      [self TurnToStarbord];
   }
   else 
   {
      [self TurnToPort];
   }
   
   [CATransaction commit];
   
   [recognizer setTranslation:CGPointZero inView:self.containerView];
}

-(void)Start:(BOOL)triggered
{
   for (id<ACustomAnimation>animation in self.animations)
   {
      [animation Start:YES];
   }
   
   for (id<ACustomAnimation>animation in [self.animationsByName allValues])
   {
      [animation Start:YES];
   }
}

-(void)Stop
{
   [self.wheelLayer removeAllAnimations];
   [self.ropeCWLayer removeAllAnimations];
   [self.ropeCCWLayer removeAllAnimations];
   [self.sailPortLayer removeAllAnimations];
   [self.sailStarbordLayer removeAllAnimations];  
}

@end
