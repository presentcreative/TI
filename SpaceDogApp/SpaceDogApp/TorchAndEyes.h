// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@class ATriggeredTextureAtlasBasedSequence;
@class AAmbientSound;

@interface ATorchAndEyes : APageBasedAnimation
{
   CALayer* fTorchBackgroundLayer;
   CALayer* fTorchLayer;
   CALayer* fDarknessLayer;
   NSTimer* fFlickerTimer;
   NSMutableArray* fEyeSequences;
   ATriggeredTextureAtlasBasedSequence* fTorchSequences;
   BOOL fTorchBurning;
   AAmbientSound* fTorchSound;
}

@property (nonatomic, retain) CALayer* torchBackgroundLayer;
@property (nonatomic, retain) CALayer* torchLayer;
@property (nonatomic, retain) CALayer* darknessLayer;
@property (nonatomic, retain) NSTimer* flickerTimer;
@property (nonatomic, retain) NSMutableArray* eyeSequences;
@property (nonatomic, retain) ATriggeredTextureAtlasBasedSequence* torchSequences;
@property (assign) BOOL torchBurning;
@property (nonatomic, retain) AAmbientSound* torchSound;

@end
