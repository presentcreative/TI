// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "TopCloud.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@interface ATopCloud (Private)
-(void)MoveLeft:(BOOL)left;
@end

@implementation ATopCloud (Private)

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter]
    removeObserver:self];
   
   fLayer.delegate = nil;
   
   if (nil != fLayer.superlayer)
   {
      [fLayer removeFromSuperlayer];
   }
   Release(fLayer);
   
   //NSLog(@"ATopCloud deallocated");
   [super dealloc];
}

-(void)BaseInit 
{
   [super BaseInit];
   
   self.minX = 0.0f;
   self.maxX = 0.0f;
   self.stepMin = 0.0f;
   self.stepMax = 0.0f;
   self.stepDuration = 0.0f;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   // load miscellaneous parameters
   self.minX = element.minX;
   self.maxX = element.maxX;
   
   self.stepMin = element.stepMin;
   self.stepMax = element.stepMax;
   
   self.stepDuration = element.duration;
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.layer = aLayer;
   [aLayer release];
   
   self.layer.frame = element.frame;
   self.layer.delegate = self;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:element.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.layer setContents:(id)image.CGImage]; 
   [image release];
      
   [view.layer addSublayer:self.layer];
}

-(void)MoveLeft:(BOOL)left
{
   // move some random distance between stepMin and stepMax
   double distance = self.stepMin + ((double)arc4random()/ARC4RANDOM_MAX * (self.stepMax - self.stepMin));
   
   CGPoint position = self.layer.position;
   
   CGFloat newX = left ? position.x - distance : position.x + distance;
   
   if (newX < self.minX)
   {
      newX = self.minX;
   }
   else if (newX > self.maxX)
   {
      newX = self.maxX;
   }
   
   // setting a new position on the layer managed by the receiver will cause the
   // actionForLayer:forKey: message to be sent to the receiver because the 
   // receiver has been set as the layer's delegate
   position.x = newX;
   
   [CATransaction begin];
   [CATransaction setAnimationDuration:self.stepDuration];
   [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
   
   self.layer.position = position;
   
   [CATransaction commit];
}
@end



@implementation ATopCloud

@synthesize layer = fLayer;
@synthesize minX = fMinX;
@synthesize maxX = fMaxX;
@synthesize stepMin = fStepMin;
@synthesize stepMax = fStepMax;
@synthesize stepDuration = fStepDuration;

-(void)Trigger:(NSNotification*)notification
{
   NSString* notificationName = notification.name;
   
   if ([@"leftCloudGodBreath" isEqualToString:notificationName])
   {
      [self MoveLeft:NO];
   }
   else if ([@"rightCloudGodBreath" isEqualToString:notificationName])
   {
      [self MoveLeft:YES];
   }
}

-(void)Stop
{
   if (nil != self.layer)
   {
      [self.layer removeAllAnimations];
   }
}

@end
