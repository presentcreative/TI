// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Compass.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Trigger.h"

@implementation ACompass

@synthesize compassLayer=fCompassLayer;
@synthesize needleLayer=fNeedleLayer;

-(void)dealloc
{      
   self.compassLayer.delegate = nil;
   if (self.compassLayer.superlayer)
   {
      [self.compassLayer removeFromSuperlayer];
   }  
   Release(fCompassLayer);
   
   self.needleLayer.delegate = nil;
   if (self.needleLayer.superlayer)
   {
      [self.needleLayer removeFromSuperlayer];
   }  
   Release(fNeedleLayer);

   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
      
   NSDictionary* layerSpec = nil;
   CALayer* layer;
   NSString* imagePath = nil;
   UIImage* image = nil;
   
   // build the scene in this order (back to front):
   // compass, needle
   
   ////////////////////////////////////////////////////////////////////////////////
   // compassLayer
   layerSpec = element.compassLayer;
   
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
   
   self.compassLayer = layer;
   
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // needle
   layerSpec = element.needleLayer;
   
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
   
   self.needleLayer = layer;
   self.needleLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180), 0.0f, 0.0f, 1.0f);
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [super Start:triggered];
   
   ATrigger* tiltTrigger = self.tiltTrigger;
   
   if (nil != tiltTrigger)
   {
      [tiltTrigger BecomeAccelerometerDelegate];
   }
}

-(void)Stop
{
   ATrigger* tiltTrigger = self.tiltTrigger;
   
   if (nil != tiltTrigger)
   {
      [tiltTrigger BecomeFreeOfAccelerometer];
   }
   
   [self.compassLayer removeAllAnimations];
   [self.needleLayer removeAllAnimations];
}

-(void)HandleTilt:(NSDictionary*)tiltInfo
{
   CGFloat tiltAngle = [(NSNumber*)[tiltInfo objectForKey:@"tiltAngle"] floatValue];
   
   // 180 degrees of motion around the device's y axis will map to 360 degrees of rotation of the compass needle
   CATransform3D rotation = CATransform3DMakeRotation(DEGREES_TO_RADIANS(tiltAngle*2.0f), 0.0f, 0.0f, 1.0);
   
   [CATransaction begin];
   
   // disabling actions makes the animation of the layers smoother
   [CATransaction setDisableActions:YES];
   
   self.needleLayer.transform = rotation;
   
   [CATransaction commit];    
}

@end
