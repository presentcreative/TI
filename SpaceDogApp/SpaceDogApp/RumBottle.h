// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"
#import "Trigger.h"

@class ATextureAtlasBasedSequence;

@interface ARumBottle : APageBasedAnimation
{
   ATextureAtlasBasedSequence* fSloshingSequence1;
   CALayer* fSequence1Layer;
   
   //ATextureAtlasBasedSequence* fSloshingSequence2;
   //CALayer* fSequence2Layer;
      
   TiltDirection fPreviousTilt;
   NSUInteger fSequence1LastImageSequenceIndex;
   //NSUInteger fSequence2LastImageSequenceIndex;
   
   NSString* fSoundEffect;
   NSUInteger fFrameChanges;
   NSTimer* fSloshTimer;
   
   UIDeviceOrientation fLastValidOrientation;
}

@property (nonatomic, retain) ATextureAtlasBasedSequence* sloshingSequence1;
@property (nonatomic, retain) CALayer* sequence1Layer;
//@property (nonatomic, retain) ATextureAtlasBasedSequence* sloshingSequence2;
//@property (nonatomic, retain) CALayer* sequence2Layer;
@property (assign) TiltDirection previousTilt;
@property (assign) NSUInteger sequence1LastImageSequenceIndex;
//@property (assign) NSUInteger sequence2LastImageSequenceIndex;
@property (copy) NSString* soundEffect;
@property (assign) NSUInteger frameChanges;
@property (nonatomic, retain) NSTimer* sloshTimer;
@property (assign) UIDeviceOrientation lastValidOrientation;

-(void)HandleTilt:(NSDictionary*)tiltInfo;

@end
