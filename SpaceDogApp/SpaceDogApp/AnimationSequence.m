// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "AnimationSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@interface AAnimationSequence (Private)
-(void)RunNextAnimation;
-(NSString*)GenerateUuidString;
@end


@implementation AAnimationSequence

@synthesize currentAnimationIndex = fCurrentAnimationIndex;
@synthesize layer = fLayer;
@synthesize sequenceInProgress = fSequenceInProgress;
@synthesize respectSequenceInProgress = fRespectSequenceInProgress;
@synthesize inPlayNotification = fInPlayNotification;
@synthesize inPlayNotificationIndex = fInPlayNotificationIndex;
@synthesize sequenceNotifications=fSequenceNotifications;

-(void)dealloc
{
   self.layer.delegate = nil;
   
   if (nil != self.layer.superlayer)
   {
      [self.layer removeFromSuperlayer];
   }
   
   for (NSString* notificationName in [self.sequenceNotifications allKeys])
   {
      [[NSNotificationCenter defaultCenter]
       removeObserver:self 
       name:notificationName 
       object:nil];
   }
    [fLayer release];//Release(fLayer);
   
    [fInPlayNotification release];//Release(fInPlayNotification);
    [fSequenceNotifications release];//Release(fSequenceNotifications);
   
   NSLog(@"AAnimationSequence deallocated");
   
   [super dealloc];
}


-(void)BaseInit 
{
   [super BaseInit];
   
   self.currentAnimationIndex = 0;
   self.sequenceInProgress = NO;
   self.respectSequenceInProgress = YES;
   self.inPlayNotification = @"";
   self.inPlayNotificationIndex = NSUIntegerMax;
   
   OrderedDictionary* sn = [[OrderedDictionary alloc] init];
   self.sequenceNotifications = sn;
   [sn release];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.inPlayNotification = element.inPlayNotification;
   self.inPlayNotificationIndex = element.inPlayNotificationIndex;
   self.respectSequenceInProgress = element.respectSequenceInProgress;
   
   // create a layer to operated upon by the receiver:
   CALayer* aLayer = [[CALayer alloc] init];
   self.layer = aLayer;
   [aLayer release];
   
   NSString* uniqueNotificationPrefix = [self GenerateUuidString];
   NSUInteger sequencePosition = 0;
   
   // now initialize the animations to be applied, sequentially, to the receiver's layer
   for (NSDictionary* animationSpec in element.animations)
   {
      Class customAnimationClass = NSClassFromString(animationSpec.customClass);
      
      // supply a completionNotification for the animation and then register the receiver
      // to listen for it. If a CustomAnimation can't accept a completionNotification then
      // the receiver won't work and so this animatino cannot be built...
      if (![customAnimationClass instancesRespondToSelector:@selector(setCompletionNotification:)])
      {
         ALog(@"*** Error AAnimationSequence instance cannot be built because class %@ will not have a 'completionNotification' property",
              [customAnimationClass description]);
         
         return;
      }
            
      NSObject<ACustomAnimation>* customAnimation = [[customAnimationClass alloc] initWithElement:animationSpec RenderOnLayer:self.layer];
   
      NSString* completionNotification = [NSString stringWithFormat:@"%@_%d", uniqueNotificationPrefix, sequencePosition];
      [customAnimation setCompletionNotification:completionNotification];
      
      // now register for that notfication
      [[NSNotificationCenter defaultCenter]
       addObserver:self 
       selector:@selector(RunNextAnimation:) 
       name:completionNotification 
       object:nil];
      
      [self.sequenceNotifications insertObject:customAnimation forKey:completionNotification atIndex:sequencePosition];      
      [(NSObject*)customAnimation release];    
      
      sequencePosition++;
   }
   
   // finally, size and fill the layer with content
   self.layer.frame = element.frame;
   
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

-(void)RunNextAnimation:(NSNotification*)notification
{
   if (self.currentAnimationIndex == self.inPlayNotificationIndex)
   {
      [[NSNotificationCenter defaultCenter]
       postNotificationName:self.inPlayNotification 
       object:nil];
   }
   
   [self RunNextAnimation];
}

-(void)RunNextAnimation
{   
   if (self.currentAnimationIndex < [self.sequenceNotifications count])
   {      
      NSString* animationKey = [self.sequenceNotifications keyAtIndex:self.currentAnimationIndex];
      
      [(id<ACustomAnimation>)[self.sequenceNotifications objectForKey:animationKey] Start:NO];
      
      self.currentAnimationIndex = self.currentAnimationIndex + 1;
   }
   else 
   {    
      [self.layer removeAllAnimations];
      
      self.sequenceInProgress = NO;
   }
}

// return a new autoreleased UUID string
-(NSString*)GenerateUuidString
{
   // create a new UUID which you own
   CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
   
   // create a new CFStringRef (toll-free bridged to NSString)
   // that you own
   NSString* uuidString = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
   
   // transfer ownership of the string
   // to the autorelease pool
   [uuidString autorelease];
   
   // release the UUID
   CFRelease(uuid);
   
   return uuidString;
}

#pragma mark -
#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self.layer removeAllAnimations];
   
   self.sequenceInProgress = YES;
   
   [self RunNextAnimation];
}

-(void)Stop
{
   [super Stop];
   
   [self.layer removeAllAnimations];
}

-(void)Trigger
{
   if (self.respectSequenceInProgress && self.sequenceInProgress)
   {
      return;
   }
   
   self.currentAnimationIndex = 0;
   
   [super Trigger];
}

@end
