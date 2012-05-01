// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "SoundEffect.h"
#import "OALAudioTrack.h"

@interface AAmbientSound : ASoundEffect
{
   NSInteger fNumLoops;
   CGFloat fFadeInDuration;
   CGFloat fFadeInGain;
   CGFloat fFadeOutDuration;
   CGFloat fFadeOutGain;
   CGFloat fMaxDuration;
}

@property (assign) NSInteger numLoops;
@property (assign) CGFloat fadeInDuration;
@property (assign) CGFloat fadeInGain;
@property (assign) CGFloat fadeOutDuration;
@property (assign) CGFloat fadeOutGain;
@property (assign) CGFloat maxDuration;

-(void)DeadStop;
-(void)FadeTo:(CGFloat)someGain;

@end
