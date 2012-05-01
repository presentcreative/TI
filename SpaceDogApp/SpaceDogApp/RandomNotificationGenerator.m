// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "RandomNotificationGenerator.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Trigger.h"
#import "Constants.h"

@interface ARandomNotificationGenerator (Private)
-(void)IssueNotification:(NSTimer*)timer;
-(CGFloat)FireInterval;
@end


@implementation ARandomNotificationGenerator

@synthesize animationId=fAnimationId;
@synthesize assetId=fAssetId;
@synthesize notificationNameBase=fNotificationNameBase;
@synthesize suffixes=fSuffixes;
@synthesize notifications=fNotifications;
@synthesize minDelay=fMinDelay;
@synthesize maxDelay=fMaxDelay;
@synthesize notificationTimer=fNotificationTimer;
@synthesize triggers=fTriggers;

-(void)dealloc
{
   // Unregister ourself with these triggers
   for (ATrigger* trigger in fTriggers)
   {      
      if (self == trigger.animation)
      {
         trigger.animation = nil;
      }
   }

   Release(fNotificationNameBase);
   Release(fSuffixes);
   Release(fTriggers);
   Release(fNotifications);
   Release(fNotificationTimer);
   Release(fAnimationId);
   
   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   // mandatory properties
   self.assetId = element.propertyId;
   self.minDelay = element.minDelay;
   self.maxDelay = element.maxDelay;
   
   self.notificationNameBase = element.notificationNameBase;
   self.suffixes = element.suffixes;
   
   // create the notifications to be issued
   if (0 == [self.suffixes count])
   {
      [self.notifications addObject:self.notificationNameBase];
   }
   else 
   {
      for (NSString* suffix in self.suffixes)
      {
         [self.notifications addObject:[NSString stringWithFormat:@"%@%@", self.notificationNameBase, suffix]];
      }
   }

   if (nil != view && [view isKindOfClass:[ABookView class]])
   {
      [(ABookView*)view RegisterAsset:self WithKey:self.assetId];
   }
   
   // it's assumed that sound effects are triggered in some manner
   ATrigger* theTrigger = nil;
   
   if (element.hasTriggers)
   {
      for (NSDictionary* triggerSpec in element.triggers)
      {
         theTrigger = [[ATrigger alloc] initWithTriggerSpec:triggerSpec ForAnimation:self OnView:view];
         [self.triggers addObject:theTrigger];
         [theTrigger release];
      }
   }
   else if (element.hasTrigger)
   {
      theTrigger = [[ATrigger alloc] initWithTriggerSpec:element.trigger ForAnimation:self OnView:view];
      [self.triggers addObject:theTrigger];
      [theTrigger release];
   }
}

-(CGFloat)FireInterval
{
   CGFloat result = 0.0f;
   
   // answer an interval based on the specified min and max delay values
   if (0.0f != self.minDelay || 0.0f != self.maxDelay)
   {
      result = ((self.maxDelay-self.minDelay)*(float)arc4random()/ARC4RANDOM_MAX) + self.minDelay;
   }
   
   return result;
}

-(void)IssueNotification:(NSTimer*)timer
{
   // first, determine which notification to issue
   int notificationIndex = arc4random()%[self.notifications count];
      
   [[NSNotificationCenter defaultCenter]
    postNotificationName:[self.notifications objectAtIndex:notificationIndex] object:nil];
   
   // now determine when the next notification should be issued
   [self.notificationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:[self FireInterval]]];
}

#pragma mark ACustomAnimation protocol
-(id)initWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   if (self = [super init])
   { 
      self.notificationNameBase = @"";
      self.suffixes = [NSArray array];
      self.notifications = [NSMutableArray array];
      self.minDelay = 0.0f;
      self.maxDelay = 0.0f;
      self.triggers = [NSMutableArray array];
      
      [self BaseInitWithElement:element RenderOnView:view];
   }
   
   return self;
}

// Notifications are received when the page on which the receiver is to play
// either becomes visible or is hidden
-(void)Trigger:(NSNotification*)notification
{
}

-(void)Start:(BOOL)triggered
{
   [self Stop];
   
   CGFloat fireInterval = [self FireInterval];
   
   self.notificationTimer = [NSTimer timerWithTimeInterval:fireInterval
                                                    target:self 
                                                  selector:@selector(IssueNotification:)
                                                  userInfo:nil
                                                   repeats:YES];
   
   [[NSRunLoop currentRunLoop] addTimer:self.notificationTimer forMode:NSDefaultRunLoopMode];
}

-(void)Stop
{
   if (nil != self.notificationTimer)
   {
      [self.notificationTimer invalidate];
   }
}

-(void)DisplayLinkDidTick:(CADisplayLink *)displayLink
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol
}


-(id<ACustomAnimation>)initWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   // NO-OP implementation to satisfy ACustomAnimation protocol.
   return self;
}

-(void)Trigger
{
   // NO-OP implementation to satisfy ACustomAnimation protocol.   
}

-(void)TriggerWithSpec:(NSDictionary*)triggerSpec
{
   // NO-OP implementation to satisfy ACustomAnimation protocol.   
}

-(IBAction)HandleGesture:(UIGestureRecognizer*)recognizer
{
   // NO-OP implementation to satisfy ACustomAnimation protocol.   
}

-(void)HandleTilt:(NSDictionary*)tiltInfo
{
   // NO-OP implementation to satisfy ACustomAnimation protocol.   
}

-(void)NotificationReceived:(NSNotification*)notification
{
   // NO-OP implementation to satisfy ACustomAnimation protocol.   
}

-(void)MotionUpdated:(CMDeviceMotion*)deviceMotion
{
   // NO-OP implementation to satisfy ACustomAnimation protocol.   
}


@end
