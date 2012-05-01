// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "SoundEffect.h"
#import "Trigger.h"
#import "BookView.h"
#import "ObjectAL.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "NSTimer+Blocks.h"

@interface ASoundEffect (Private)
-(void)PlayEffect;
@end

@implementation ASoundEffect

@synthesize resourceName = fResourceName;
@synthesize duration=fDuration;
@synthesize delay=fDelay;
@synthesize lastPlayed=fLastPlayed;
@synthesize assetId = fAssetId;
@synthesize audioTrack=fAudioTrack;

-(void)dealloc
{   
   if (nil != self.audioTrack)
   {
      [self.audioTrack clear];
   }
   Release(fAudioTrack);
   
   Release(fAssetId);
   Release(fResourceName);
   Release(fLastPlayed);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.lastPlayed = nil;
   self.duration = 1.0f;
   self.delay = 0.0f;
   
   // keep the pressure off the autorelease pool
   OALAudioTrack* theTrack = [[OALAudioTrack alloc] init];
   self.audioTrack = theTrack;
   [theTrack release];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{ 
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.assetId = element.propertyId;
   
   if (element.hasDuration)
   {
      self.duration = element.duration;
   }
   
   if (element.hasDelay)
   {
      self.delay = element.delay;
   }
      
   if (nil != element.resource)
   {
      self.resourceName = element.resource;
   }
}

-(void)PlayEffect
{
   // play the effect immediately
   [self.audioTrack playFile:self.resourceName];
   
   // update the time at which the playing occurred
   self.lastPlayed = [NSDate date];
}

#pragma mark ACustomAnimation protocol

-(void)Start:(BOOL)triggered
{
   if (nil == self.lastPlayed || (self.duration < fabs([self.lastPlayed timeIntervalSinceNow])))
   {
      if (0.0f == self.delay)
      {
         [self PlayEffect];
      }
      else
      {
         // play after some delay
       [NSTimer scheduledTimerWithTimeInterval:self.delay
                                         block:^{[self PlayEffect];} 
                                       repeats:NO];
      }
   }
}

-(void)Stop
{
   [self.audioTrack stop];   
}

@end
