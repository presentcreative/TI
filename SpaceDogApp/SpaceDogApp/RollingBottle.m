// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "RollingBottle.h"
#import "TriggeredTextureAtlasBasedSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "NSTimer+Blocks.h"
#import "OALSimpleAudio.h"

#define kLeftTiltThreshold     80.0f   // degrees
#define kRightTiltThreshold   100.0f   // degrees

#define kMaxFrames             30

#define kRollThreshold         10      // frames

#define kSoundEffectDuration    1.5f   // seconds


@implementation ARollingBottle

@synthesize rollingSequences=fRollingSequences;
@synthesize previousTilt=fPreviousTilt;
@synthesize lastImageSequenceIndex=fLastImageSequenceIndex;
@synthesize l2RSoundEffect=fL2RSoundEffect;
@synthesize r2LSoundEffect=fR2LSoundEffect;
@synthesize soundEffectPlaying=fSoundEffectPlaying;
@synthesize rollDirection=fRollDirection;

-(void)dealloc
{      
   if (![@"" isEqualToString:fL2RSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fL2RSoundEffect];
   }
   Release(fL2RSoundEffect);
   
   if (![@"" isEqualToString:fR2LSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fR2LSoundEffect];
   }
   Release(fR2LSoundEffect);
   
   Release(fRollingSequences);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.previousTilt = kNoTilt;
   self.lastImageSequenceIndex = kMaxFrames/2;   // assume equidistant from LJS' legs
   self.l2RSoundEffect = @"";
   self.r2LSoundEffect = @"";
   self.soundEffectPlaying = NO;
   self.rollDirection = Stationary;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = element.rollingSequences;
   
   ATextureAtlasBasedSequence* tSequence = nil;
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:layerSpec 
                RenderOnView:nil];
   
   self.rollingSequences = tSequence;
   [tSequence release];
   [view.layer addSublayer:self.rollingSequences.layer];
   
   // set the bottle to its initial position
   [self.rollingSequences AnimateFromIndex:kMaxFrames/2 ToIndex:kMaxFrames/2];
   
   // add the SoundEffects   
   self.l2RSoundEffect = layerSpec.l2RSoundEffect;
   
   if (![@"" isEqualToString:self.l2RSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.l2RSoundEffect];
   }
   
   self.r2LSoundEffect = layerSpec.r2LSoundEffect;
   
   if (![@"" isEqualToString:self.r2LSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.r2LSoundEffect];
   }
}

#pragma mark ACustomAnimation protocol
-(void)HandleTilt:(NSDictionary*)tiltInfo
{   
   float tiltAngle = [(NSNumber*)[tiltInfo objectForKey:@"tiltAngle"] floatValue];
   
   // convert the tiltAngle to an image sequence index
   NSUInteger newImageSequenceIndex = 1;
   
   if (tiltAngle <= kLeftTiltThreshold)
   {
      newImageSequenceIndex = 1;
   }
   else if (tiltAngle >= kRightTiltThreshold)
   {
      newImageSequenceIndex = kMaxFrames;
   }
   else
   {
      newImageSequenceIndex = (tiltAngle - kLeftTiltThreshold)/((kRightTiltThreshold-kLeftTiltThreshold)/kMaxFrames);
      
      if (0 == newImageSequenceIndex)
      {
         newImageSequenceIndex = 1;
      }
   }
   
   //NSLog(@"tiltAngle = %f, imageSequenceIndex = %d", tiltAngle, newImageSequenceIndex);
   
   if (newImageSequenceIndex == self.lastImageSequenceIndex)
   {
      // nothing to do!
      self.rollDirection = Stationary;
      
      return;
   }
   
   // run the animation from the current index to the newly calculated index
   [self.rollingSequences AnimateFromIndex:self.lastImageSequenceIndex ToIndex:newImageSequenceIndex];
   
   // figure out if a sound effect should be played
   RollDirection oldRollDirection = self.rollDirection;
   
   self.rollDirection = (newImageSequenceIndex < self.lastImageSequenceIndex)?Right2Left:Left2Right;
   
   if ((oldRollDirection != self.rollDirection) && !self.soundEffectPlaying)
   {
      NSString* soundEffectToPlay = Left2Right == self.rollDirection?self.l2RSoundEffect:self.r2LSoundEffect;
      
      [[OALSimpleAudio sharedInstance] playEffect:soundEffectToPlay];
      
      self.soundEffectPlaying = YES;
      
      [NSTimer scheduledTimerWithTimeInterval:kSoundEffectDuration block:^{self.soundEffectPlaying = NO;} repeats:NO];
   }
            
   self.lastImageSequenceIndex = newImageSequenceIndex;
}

-(void)Start:(BOOL)triggered
{
   [super Start:triggered];
   
   ATrigger* tiltTrigger = self.tiltTrigger;
   
   if (nil != tiltTrigger)
   {
      ATrigger* tiltTrigger = self.tiltTrigger;
               
      [tiltTrigger BecomeAccelerometerDelegate];
   }
}

-(void)Stop
{
   [self.rollingSequences Stop];
   
   ATrigger* tiltTrigger = self.tiltTrigger;
   
   if (nil != tiltTrigger)
   {      
      [tiltTrigger BecomeFreeOfAccelerometer];
   }
}

@end
