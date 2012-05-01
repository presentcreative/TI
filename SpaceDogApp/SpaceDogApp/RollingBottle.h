// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"
#import "Trigger.h"

typedef enum
{
   Stationary,
   Left2Right,
   Right2Left
} RollDirection;

@class ATextureAtlasBasedSequence;

@interface ARollingBottle : APageBasedAnimation
{
   ATextureAtlasBasedSequence* fRollingSequences;
      
   TiltDirection fPreviousTilt;
   NSUInteger fLastImageSequenceIndex;
   
   NSString* fL2RSoundEffect;
   NSString* fR2LSoundEffect;
   BOOL fSoundEffectPlaying;
   
   RollDirection fRollDirection;
}

@property (nonatomic, retain) ATextureAtlasBasedSequence* rollingSequences;
@property (assign) TiltDirection previousTilt;
@property (assign) NSUInteger lastImageSequenceIndex;
@property (copy) NSString* l2RSoundEffect;
@property (copy) NSString* r2LSoundEffect;
@property (assign) BOOL soundEffectPlaying;
@property (assign) RollDirection rollDirection;

@end
