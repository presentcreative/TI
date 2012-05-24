// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Eyes.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TextureAtlasBasedSequence.h"


@implementation AEyes

@synthesize socketLayer=fSocketLayer;
@synthesize eyesLayer=fEyesLayer;

@synthesize minX=fMinX;
@synthesize maxX=fMaxX;
@synthesize minY=fMinY;
@synthesize maxY=fMaxY;

-(void)dealloc
{ 
   self.socketLayer.delegate = nil;
   if (self.socketLayer.superlayer)
   {
      [self.socketLayer removeFromSuperlayer];
   }
   Release(fSocketLayer);
   
   self.eyesLayer.delegate = nil;
   if (self.eyesLayer.superlayer)
   {
      [self.eyesLayer removeFromSuperlayer];
   }
   Release(fEyesLayer);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.minX = 0.0f;
   self.maxX = 0.0f;
   self.minY = 0.0f;
   self.maxY = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.minX = element.minX;
   self.maxX = element.maxX;
   self.minY = element.minY;
   self.maxY = element.maxY;
   
   NSDictionary* layerSpec = nil;
   CALayer* layer;
   NSString* imagePath = nil;
   UIImage* image = nil;
   
   // build the scene in this order (back to front):
   // eye sockets, eyes
   
   ////////////////////////////////////////////////////////////////////////////////
   // socketLayer
   layerSpec = element.socketLayer;
   
   layer = [[CALayer alloc] init];
   layer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [layer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [layer setContents:(id)image.CGImage]; 
   [image release];
   [view.layer addSublayer:layer];
   [layer release];
   
   self.socketLayer = layer;
   
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // eyes
   layerSpec = element.eyesLayer;
   
   layer = [[CALayer alloc] init];
   layer.frame = layerSpec.frame;
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      [layer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [layer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:layer];
   [layer release];
   
   self.eyesLayer = layer;
}

-(CGPoint)MoveDeltaXY:(CGPoint)newPosition
{ 
   // scale the deltaXY value to get smoother movement of the eyes   
  // CGFloat fingerRangeX = 30.0f;
   //CGFloat fingerRangeY = 20.0f;
    
   //CGPoint currentPosition = self.eyesLayer.position;
   
  // CGPoint newPosition = CGPointMake(currentPosition.x+deltaXY.x/fingerRangeX, currentPosition.y+deltaXY.y///fingerRangeY);
    
    
    // clamp to min/max specified for this segment
    if (newPosition.y <= self.minY)
    {
        newPosition.y = self.minY;
    }
    else if (newPosition.y >= self.maxY)
    {
        newPosition.y = self.maxY;
    }
    
    if (newPosition.x <= self.minX)
    {
        newPosition.x = self.minX;
    }
    else if (newPosition.x >= self.maxX)
    {
        newPosition.x = self.maxX;
    }

    //CGFloat eyeRatio = (self.maxY - self.minY) / (self.maxX - self.minX);
    //CGFloat aspectRatio = 768/1024;
    
    
   // CGFloat pointRatio = (newPosition.y - currentPosition.y) / (newPosition.x - currentPosition.x);
   // CGFloat absPointRatio = fabs(pointRatio);
    
/*    if (absPointRatio < eyeRatio) { 
        if (newPosition.x <= self.minX)
        {
            newPosition.x = self.minX;
            newPosition.y = centerY - (centerX - self.minX)*pointRatio;
        }
        else if (newPosition.x >= self.maxX)
        {
            newPosition.x = self.maxX;
            newPosition.y = centerY + (centerX - self.minX)*pointRatio;
        }
    }else //y is maxed out, only adjust x.
    {
        if (newPosition.y <= self.minY)
        {
            newPosition.y = self.minY;
            newPosition.x = centerX - (centerY - self.minY)/pointRatio;
        }
        else if (newPosition.y >= self.maxY)
        {
            newPosition.y = self.maxY;
            newPosition.x = centerX + (centerY - self.minY)/pointRatio;
        }
     }*/
    
     
   self.eyesLayer.position = newPosition;
   
   return newPosition;
}

#pragma mark ACustomAnimation protocol

   
    
- (CGPoint)CalculateEyePosition:(CGPoint)location
{
    int centerY =(self.maxY + self.minY)/2;
    int centerX =(self.maxX + self.minX)/2;
    
    CGFloat xFactor;
    if (location.x < centerX)    //centerX > 1024/2)
        xFactor = (centerX - self.minX)/centerX;
    else {
        xFactor = (centerX - self.minX)/(1024 - centerX);
    }
    CGFloat yFactor;
    if (location.y < centerY)//centerY > 768/2)
        yFactor = (centerY - self.minY)/centerY;
    else {
        yFactor = (centerY - self.minY)/(768 - centerY);
    }
    
    //newPosition.x = centerX + (location.x - centerX)*xFactor;
    //newPosition.y = centerY + (location.y - centerY)*yFactor;
    
    //CGPoint oldPosition = self.eyesLayer.position;
    CGPoint newPosition;
    newPosition.x = centerX + (location.x - centerX)*xFactor;// - oldPosition.x;
    newPosition.y = centerY + (location.y - centerY)*yFactor;// - oldPosition.y;
    
    return newPosition;
    
}

-(void)TriggerWithRecognizer:(UIGestureRecognizer*)sender
{
/*    UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
    CGPoint newPosition = [recognizer locationInView:self.containerView];
    
    // clamp to min/max specified for this segment
    if (newPosition.y <= self.minY)
    {
        newPosition.y = self.minY;
    }
    else if (newPosition.y >= self.maxY)
    {
        newPosition.y = self.maxY;
    }
    
    if (newPosition.x <= self.minX)
    {
        newPosition.x = self.minX;
    }
    else if (newPosition.x >= self.maxX)
    {
        newPosition.x = self.maxX;
    }
    
    self.eyesLayer.position = newPosition;*/
    // the reader is attempting to move the eyes   
    UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
    
    CGPoint newPosition;// = (CGPoint)[recognizer translationInView:self.containerView];
    CGPoint location = [recognizer locationInView:self.containerView];
    newPosition = [self CalculateEyePosition:location];
    
    [CATransaction begin];
    
    // disabling actions makes the animation of the layers smoother
    [CATransaction setDisableActions:YES];
    
    [self MoveDeltaXY:newPosition];
    
    [CATransaction commit];
    
    [recognizer setTranslation:CGPointZero inView:self.containerView];
    
} 

// retrieve the latest results recorded by the pan gesture recognizer and
// translate the position on the movable layer of the image
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{
   // the reader is attempting to move the eyes   
   UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
   
    CGPoint newPosition;// = (CGPoint)[recognizer translationInView:self.containerView];
    CGPoint location = [recognizer locationInView:self.containerView];
   newPosition = [self CalculateEyePosition:location];
    
   [CATransaction begin];
   
   // disabling actions makes the animation of the layers smoother
   [CATransaction setDisableActions:YES];
   
   [self MoveDeltaXY:newPosition];
   
   [CATransaction commit];
   
   [recognizer setTranslation:CGPointZero inView:self.containerView];
}

-(void)Start:(BOOL)triggered
{

}

-(void)Stop
{
   [self.socketLayer removeAllAnimations];
   [self.eyesLayer removeAllAnimations];
}

@end
