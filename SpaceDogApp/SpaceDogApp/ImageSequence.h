// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageSequenceLayer.h"
#import "CustomAnimation.h"

typedef struct {
   int sequence;
   int frame;
} SequenceTransition;

typedef enum {
   FINITE,
   CONTINUOUS,
   CONTINUOUS_WITH_DELAY,
   CONTINUOUS_WITH_RANDOM_DELAY
} RepeatType;

@interface AImageSequence : NSObject 
{
   NSUInteger fSequenceIndex;
   id<ACustomAnimation> fSoundEffect;
   BOOL fBaseSequence;
   NSUInteger fNumRepeats;
   CGFloat fDuration;
   RepeatType fRepeatType;
   CGFloat fRepeatDelay;
   CGFloat fRepeatDelayMin;
   CGFloat fRepeatDelayMax;
   BOOL fAutoreverses;
   BOOL fHasToggleProperty;
   NSString* fTimingFunctionName;
   NSUInteger fNextImageIndex;
   NSMutableArray* fTransitions;
   NSUInteger fSequenceCount;
   NSMutableDictionary* fPropertyEffects;
   NSRange fImageIndices;
   NSString* fPostExecutionNotification;
   BOOL fUnpatterned;
   NSUInteger fInitialFrame;
}

@property (assign) NSUInteger sequenceIndex;
@property (nonatomic, retain) id<ACustomAnimation> soundEffect;
@property (readonly) BOOL hasSoundEffect;
@property (assign, getter=isBaseSequence) BOOL baseSequence;
@property (assign, getter=hasToggle) BOOL hasToggleProperty;
@property (assign) NSUInteger numRepeats;
@property (assign) CGFloat duration;
@property (assign) RepeatType repeatType;
@property (assign) CGFloat repeatDelay;
@property (assign) CGFloat repeatDelayMin;
@property (assign) CGFloat repeatDelayMax;
@property (assign) BOOL autoreverses;
@property (copy) NSString* timingFunctionName;
@property (nonatomic, retain) NSMutableArray* transitions;
@property (readonly) NSUInteger numFrames;
@property (readonly) NSUInteger nextImageIndex;
@property (readonly) NSUInteger frameLastDisplayed;
@property (readonly) BOOL needsTransition;
@property (assign) NSUInteger sequenceCount;
@property (nonatomic, retain) NSMutableDictionary* propertyEffects;
@property (copy) NSString* postExecutionNotification;
@property (assign, getter = isUnpatterned) BOOL unpatterned;
@property (assign) NSUInteger initialFrame;

@property (readonly) NSArray* preSequencePropertyEffects;
@property (readonly) NSArray* postSequencePropertyEffects;

@property (readonly) CAAnimation* animation;
@property (readonly) CAAnimation* reverseAnimation;
@property (readonly) NSString* animationKey;
@property (assign) NSRange imageIndices;
@property (readonly) NSUInteger firstImageIndex;

@property (readonly) BOOL isSingleImageSequence;
@property (readonly) BOOL isImageless;

@property (readonly) BOOL isFiniteRepeat;
@property (readonly) BOOL isContinuousRepeat;
@property (readonly) BOOL isContinuousWithDelayRepeat;
@property (readonly) BOOL isContinuousWithRandomDelayRepeat;

@property (readonly) BOOL hasPostExecutionNotification;

-(AImageSequence*)initWithSequenceSpec:(NSDictionary*)sequenceSpec;

-(CAAnimation*)animationFromIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;

-(void)IssuePostExecutionNotification;

@end
