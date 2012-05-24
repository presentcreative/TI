// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "AmbientSound.h"
#import "Constants.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@interface AAmbientSound (Private)
-(void)MaxDurationElapsed:(NSTimer*)timer;
@end


@implementation AAmbientSound

@synthesize numLoops = fNumLoops;
@synthesize fadeInDuration = fFadeInDuration;
@synthesize fadeInGain = fFadeInGain;
@synthesize fadeOutDuration = fFadeOutDuration;
@synthesize fadeOutGain = fFadeOutGain;
@synthesize maxDuration = fMaxDuration;

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{ 
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.numLoops = element.numLoops;
   self.fadeInDuration = element.fadeInDuration;
   self.fadeInGain = element.fadeInGain;
   self.fadeOutDuration = element.fadeOutDuration;
   self.fadeOutGain = element.fadeOutGain;
   self.maxDuration = element.maxDuration;
}


-(void)TrackStopped:(OALAudioTrack*)stopper
{
   [stopper stop];
   [stopper clear];
   [self release]; //Counteract the retain in Stop
}

-(void)TrackStarted:(id)starter
{
   self.duration = self.audioTrack.duration;
   
   [self.audioTrack fadeTo:self.fadeInGain duration:self.fadeInDuration target:nil selector:nil];
   
   self.lastPlayed = [NSDate date];
   
   if (self.maxDuration < self.duration)
   {
      // Start a timer to stop the receiver early
      [NSTimer scheduledTimerWithTimeInterval:self.maxDuration 
                                       target:self 
                                     selector:@selector(MaxDurationElapsed:) 
                                     userInfo:nil 
                                      repeats:NO];
   }
   else
   {
      [self release];
   }
}

-(void)MaxDurationElapsed:(NSTimer*)timer
{
   if (0.0f < self.fadeOutDuration)
   {
      [self retain];
      
      [self.audioTrack fadeTo:self.fadeOutGain duration:self.fadeOutDuration target:self selector:@selector(TrackStopped:)];
   }
   else
   {
      [self Stop];
   
      [self release];
   }
}

-(void)DeadStop
{
   [self.audioTrack stop];
}

-(void)FadeTo:(CGFloat)someGain
{
   [self.audioTrack fadeTo:someGain duration:1.0f target:nil selector:nil];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{   
   if (nil == self.lastPlayed || self.duration < fabs([self.lastPlayed timeIntervalSinceNow]))
   {
      self.audioTrack = [OALAudioTrack track];

      self.audioTrack.gain = 0.0f;
      
      NSString* resourcePath = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:nil];
      
      // ensure we're around to receive the TrackStarted: callback
      [self retain]; 
      
      [self.audioTrack playFileAsync:resourcePath loops:self.numLoops target:self selector:@selector(TrackStarted:)];
   }
}

-(void)Stop
{
   //[super Stop];  wpm commented out to allow fade out.
   
   if (nil != self.lastPlayed)
   {
      [self retain]; //Ensure we're around when this ends
      
      [self.audioTrack fadeTo:self.fadeOutGain duration:self.fadeOutDuration target:self selector:@selector(TrackStopped:)];
   }
   self.lastPlayed = nil;
}

@end
