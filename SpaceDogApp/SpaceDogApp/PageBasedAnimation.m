// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Trigger.h"
#import "SpaceDogAppAppDelegate.h"

@implementation APageBasedAnimation

@synthesize propertyId=fPropertyId;
@synthesize containerView=fContainerView;
@synthesize animations=fAnimations;
@synthesize animationsByName=fAnimationsByName;
@synthesize animationId=fAnimationId;
@synthesize waitForTrigger=fWaitForTrigger;

-(void)dealloc
{
   Release(fPropertyId);
   Release(fAnimationId);
   Release(fAnimations);
   Release(fAnimationsByName);

   [super dealloc];
}

-(SpaceDogAppViewController*)mainViewController
{
   SpaceDogAppAppDelegate* appDelegate = (SpaceDogAppAppDelegate*)[[UIApplication sharedApplication] delegate];
   
   return (SpaceDogAppViewController*)appDelegate.viewController;
}

-(void)BaseInit
{
   fAnimations = [[NSMutableArray alloc] initWithCapacity:10];   
   fAnimationsByName = [[NSMutableDictionary alloc] initWithCapacity:10];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   self.propertyId = element.propertyId;
   self.containerView = view;
   
   if ([view isKindOfClass:[ABookView class]])
   {
      [(ABookView*)view RegisterAsset:self WithKey:self.propertyId];
   }
   
   ATrigger* theTrigger = nil;
   
   if (element.hasTriggers)
   {
      for (NSDictionary* triggerSpec in element.triggers)
      {
         theTrigger = [[ATrigger alloc] initWithTriggerSpec:triggerSpec ForAnimation:self OnView:view];
         [theTrigger release];
      }
   }
   else if (element.hasTrigger)
   {
      theTrigger = [[ATrigger alloc] initWithTriggerSpec:element.trigger ForAnimation:self OnView:view];
      [theTrigger release];
   }

    fWaitForTrigger = element.waitForTrigger;

}

-(ATrigger*)tiltTrigger
{
   ATrigger* result = nil;
   
   for (ATrigger* trigger in ((ABookView*)self.containerView).triggersOnView)
   {
      if (trigger.isTiltTrigger && self == trigger.animation)
      {
         result = trigger;
         
         break;
      }
   }
   
   return result;
}

-(ATrigger*)shakeTrigger
{
   ATrigger* result = nil;
   
   for (ATrigger* trigger in ((ABookView*)self.containerView).triggersOnView)
   {
      if (trigger.isShakeTrigger && self == trigger.animation)
      {
         result = trigger;
         
         break;
      }
   }
   
   return result;
}

-(id<ACustomAnimation>)initWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
   return self;
}

-(void)Start:(BOOL)triggered
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol
}

-(void)Stop
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol 
}

-(void)DisplayLinkDidTick:(CADisplayLink *)displayLink
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol
}

-(void)TriggerWithSpec:(NSDictionary*)triggerSpec
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(IBAction)HandleGesture:(UIGestureRecognizer*)recognizer
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(void)HandleTilt:(NSDictionary*)tiltInfo
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.   
}

-(void)NotificationReceived:(NSNotification*)notification
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(void)MotionUpdated:(CMDeviceMotion*)deviceMotion
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.   
}


#pragma mark ACustomAnimation protocol
-(id)initWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   if (self = [super init])
   {
      [self BaseInit];
      
      [self BaseInitWithElement:element RenderOnView:view];
   }
   
   return self;
}

-(void)Trigger
{
   [self Start:YES];
}

// Many page-based animations start and stop when the page on which they're
// resident becomes visible or invisible, respectively
-(void)Trigger:(NSNotification*)notification
{   
}

@end
