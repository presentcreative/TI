// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "RumBottle.h"
#import "TriggeredTextureAtlasBasedSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "OALSimpleAudio.h"

#define kLeftTiltThreshold     30.0f   // degrees
#define kRightTiltThreshold   150.0f   // degrees

#define kSloshThreshold        10      // frames
#define kFrameCheckInterval     0.25f   // seconds
#define kNumberOfFramesKey    @"numberOfFrames"
#define kMaxFrames             40

@interface ARumBottle (Private)
-(void)CheckFrameChanges:(NSTimer*)timer;
@end

@implementation ARumBottle

@synthesize sloshingSequence1=fSloshingSequence1;
@synthesize sequence1Layer=fSequence1Layer;
//@synthesize sloshingSequence2=fSloshingSequence2;
//@synthesize sequence2Layer=fSequence2Layer;
@synthesize previousTilt=fPreviousTilt;
@synthesize sequence1LastImageSequenceIndex=fSequence1LastImageSequenceIndex;
//@synthesize sequence2LastImageSequenceIndex=fSequence2LastImageSequenceIndex;
@synthesize soundEffect=fSoundEffect;
@synthesize frameChanges=fFrameChanges;
@synthesize sloshTimer=fSloshTimer;
@synthesize lastValidOrientation=fLastValidOrientation;

-(void)dealloc
{
   if (nil != fSloshTimer)
   {
      [fSloshTimer invalidate];
   }
   Release(fSloshTimer);
   
   if (![@"" isEqualToString:fSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fSoundEffect];
   }
   Release(fSoundEffect);
   
   if (nil != self.sequence1Layer)
   {
      self.sequence1Layer.delegate = nil;
      
      if (nil != self.sequence1Layer.superlayer)
      {
         [self.sequence1Layer removeFromSuperlayer];
      }
   }
    
   Release(self.sequence1Layer);
   
/*   if (nil != self.sloshingSequence1)
   {
       
   }   */
   Release(fSloshingSequence1);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.previousTilt = kNoTilt;
   self.sequence1LastImageSequenceIndex = kMaxFrames/2;   // assume level to start with
  // self.sequence2LastImageSequenceIndex = kMaxFrames/2;
   self.soundEffect = @"";
   self.frameChanges = 0;
   self.lastValidOrientation = UIDeviceOrientationLandscapeRight;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   ATextureAtlasBasedSequence* tSequence = nil;
     
   // the "level" sloshing sequence
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.sloshingSequence1 
                RenderOnView:nil];
   
   self.sloshingSequence1 = tSequence;
   [tSequence release];
   
   self.sequence1Layer = self.sloshingSequence1.layer;
   [view.layer addSublayer:self.sequence1Layer];

   
   // the "upside down" sloshing sequence
/*   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                                             initWithElement:element.sloshingSequence2 
                                             RenderOnView:nil];*/
   
 //  self.sloshingSequence2 = tSequence;
 //  [tSequence release];
   
   // need to hide the "upside down" layer
//   self.sequence2Layer = self.sloshingSequence2.layer;
   
//   [view.layer addSublayer:self.sequence2Layer];

   
   self.soundEffect = element.rumBottleSoundEffect;
   
   if (![@"" isEqualToString:fSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.soundEffect];
   }
   
/*   UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
   
   if (currentOrientation == UIDeviceOrientationLandscapeRight ||
       currentOrientation == UIDeviceOrientationLandscapeLeft)
   {
      self.lastValidOrientation = currentOrientation;
      
      // set the layer visible initially based on the current device orientation
      if (currentOrientation == UIDeviceOrientationLandscapeLeft)
      {
//         self.sequence2Layer.opacity = 1.0f;
         self.sequence1Layer.opacity = 0.0f;
      }
      else
      {
////         self.sequence2Layer.opacity = 0.0f;
         self.sequence1Layer.opacity = 1.0f;      
      }
   }
   else
   {
      // just assume UIDeviceOrientationLandscapeRight
      self.lastValidOrientation = UIDeviceOrientationLandscapeRight;
      
 //     self.sequence2Layer.opacity = 0.0f;
      self.sequence1Layer.opacity = 1.0f;
   }*/
}

-(void)CheckFrameChanges:(NSTimer *)timer
{
   NSMutableDictionary* userInfo = timer.userInfo;
   
   NSUInteger frameChangesAtLastCheck = [[userInfo objectForKey:kNumberOfFramesKey] unsignedIntegerValue];
         
   NSInteger netFrameChanges = self.frameChanges - frameChangesAtLastCheck;
   
   if (kSloshThreshold <= netFrameChanges)
   {
      [[OALSimpleAudio sharedInstance] playEffect:self.soundEffect];
   }
   
   [userInfo setObject:[NSNumber numberWithUnsignedInteger:self.frameChanges] forKey:kNumberOfFramesKey];
}

-(void)DeviceOrientationChanged:(NSNotification*)notification
{  
   UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
   
   DLog(@"current orientation = %d", currentOrientation);
   
   if (currentOrientation != UIDeviceOrientationLandscapeRight &&
       currentOrientation != UIDeviceOrientationLandscapeLeft)
   {
      return;
   }
      
   // has orientation really changed?
   if (currentOrientation == self.lastValidOrientation)
   {
      return;
   }
   
   self.lastValidOrientation = currentOrientation;
      
   [CATransaction begin];
   [CATransaction setAnimationDuration:0.5f];
   
   if (currentOrientation == UIDeviceOrientationLandscapeLeft)
   {
      DLog(@"UPSIDE DOWN");
//      self.sequence2Layer.opacity = 1.0f;
      self.sequence1Layer.opacity = 0.0f;
   }
   else
   {
      DLog(@"RIGHTSIDE UP");
      self.sequence1Layer.opacity = 1.0f;
//      self.sequence2Layer.opacity = 0.0f;      
   }
   
   [CATransaction commit];
}

#pragma mark ACustomAnimation protocol
-(void)HandleTilt:(NSDictionary*)tiltInfo
{   
   float tiltAngle = [(NSNumber*)[tiltInfo objectForKey:@"tiltAngle"] floatValue];
   
   // convert the tiltAngle to an image sequence index
   NSUInteger newImageSequence1Index = 30;
   
   if (tiltAngle <= kLeftTiltThreshold)
   {
      newImageSequence1Index = kMaxFrames-1;
      //NSLog(@"Max Image %u", newImageSequence1Index);   
   }
   else if (tiltAngle >= kRightTiltThreshold)
   {
      newImageSequence1Index = 1;
      // NSLog(@"Max Image %u", newImageSequence1Index);        
   }
   else
   {
      newImageSequence1Index = kMaxFrames - (tiltAngle - kLeftTiltThreshold)/((kRightTiltThreshold-kLeftTiltThreshold)/kMaxFrames )+1;
      //NSLog(@"Image %u", newImageSequence1Index);
       if (newImageSequence1Index < 1)
           newImageSequence1Index = 1;
       if (newImageSequence1Index > kMaxFrames-1)
           newImageSequence1Index = kMaxFrames-1;

   }
   
   //NSLog(@"tiltAngle = %f, imageSequenceIndex = %d", tiltAngle, newImageSequenceIndex);
   
   if (newImageSequence1Index == self.sequence1LastImageSequenceIndex)
   {
      // nothing to do!
      return;
   }
   // NSLog(@"Image %u", newImageSequence1Index);
   
   // run the animation from the current index to the newly calculated index
   [self.sloshingSequence1 AnimateFromIndex:self.sequence1LastImageSequenceIndex ToIndex:newImageSequence1Index];
   //[self.sloshingSequence2 AnimateFromIndex:self.sequence2LastImageSequenceIndex //ToIndex:newImageSequence2Index];
   
//   NSLog(@"Sequence 1: animating from %d to %d", self.sequence1LastImageSequenceIndex, newImageSequence1Index);
//   NSLog(@"Sequence 2: animating from %d to %d", self.sequence2LastImageSequenceIndex, newImageSequence2Index);
   
   NSInteger netChange = abs(newImageSequence1Index-self.sequence1LastImageSequenceIndex);

   self.frameChanges = self.frameChanges + netChange;
   
   self.sequence1LastImageSequenceIndex = newImageSequence1Index;
   //self.sequence2LastImageSequenceIndex = newImageSequence2Index;
}

-(void)Start:(BOOL)triggered
{
   [self.sloshingSequence1 Start:NO];
//   [self.sloshingSequence2 Start:NO];
   
   ATrigger* tiltTrigger = self.tiltTrigger;
   
   if (nil != tiltTrigger)
   {
      NSTimer* sloshTimer = [NSTimer timerWithTimeInterval:kFrameCheckInterval 
                                                    target:self 
                                                  selector:@selector(CheckFrameChanges:) 
                                                  userInfo:[NSMutableDictionary 
                                                            dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:0], 
                                                            kNumberOfFramesKey, 
                                                            nil] 
                                                   repeats:YES];
      self.sloshTimer = sloshTimer;
      
      [[NSRunLoop currentRunLoop] addTimer:self.sloshTimer forMode:NSDefaultRunLoopMode];
      
      [tiltTrigger BecomeAccelerometerDelegate];
   }
   
   // start device orientation notifications and register for same
/*   [[NSNotificationCenter defaultCenter] 
    addObserver:self 
    selector:@selector(DeviceOrientationChanged:) 
    name:UIDeviceOrientationDidChangeNotification 
    object:nil];
   
   //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];*/
   
   [super Start:triggered];
}

-(void)Stop
{
   [super Stop];
   
  // [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
   
   [self.sloshingSequence1 Stop];
//   [self.sloshingSequence2 Stop];
   
   ATrigger* tiltTrigger = self.tiltTrigger;
   
   if (nil != tiltTrigger)
   {
      if (nil != self.sloshTimer)
      {
         [self.sloshTimer invalidate];
         self.sloshTimer = nil;
      }
      
      [tiltTrigger BecomeFreeOfAccelerometer];
   }
}

@end
