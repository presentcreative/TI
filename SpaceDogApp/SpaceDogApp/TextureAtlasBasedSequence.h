// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"
#import "ImageSequenceLayer.h"
#import "ImageSequence.h"

@interface ATextureAtlasBasedSequence : APageBasedAnimation
{
   NSString* fSequenceId;
   NSString* fResourceBase;
   NSMutableArray* fImageSequences;
   NSUInteger fSequenceInPlay;
   SequenceTransition fLastCompletedSequence;
   NSUInteger fRepeatCount;
   CGFloat fDuration;
   CGFloat fDelay;
   
   AImageSequenceLayer* fLayer;
   CGRect fBaseFrame;
   NSDictionary* fTextureAtlas;   
   
   NSMutableArray* fEffectQueue;
   
   BOOL fStepTriggerRequired;
   BOOL fAutoResetToBase;
    BOOL fForward;
}

@property (nonatomic, retain) AImageSequenceLayer* layer;
@property (assign) CGRect baseFrame;
@property (copy) NSString* sequenceId;
@property (copy) NSString* resourceBase;
@property (nonatomic, retain) NSMutableArray* imageSequences;
@property (assign) NSUInteger sequenceInPlay;
@property (readonly) AImageSequence* currentSequence;
@property (assign) SequenceTransition lastCompletedSequence;

@property (assign) NSUInteger repeatCount;
@property (assign) CGFloat duration;
@property (assign) CGFloat delay;

@property (nonatomic, retain) NSMutableArray* effectQueue;
@property (assign, getter=isStepTriggerRequired) BOOL stepTriggerRequired;
@property (assign, getter=isAutoResetToBase) BOOL autoResetToBase;
@property (assign, getter=isForward) BOOL forward;
@property (assign, getter=hasSingleImageBaseSequence) BOOL singleImageBaseSequence;

@property (nonatomic, retain) NSDictionary* textureAtlas;

-(NSDictionary*)ImageSpecForImageIndex:(unsigned int)imageIndex;
-(CGRect)BoundsForImageAtIndex:(unsigned int)index;
-(CGRect)ContentsRectForImageAtIndex:(unsigned int)imageIndex;
-(CGPoint)PositionForImageAtIndex:(unsigned int)imageIndex;
-(void)ArrangeImageAtIndex:(unsigned int)imageIndex OnLayer:(CALayer*)imageLayer;

-(BOOL)CalculateNextSequence;
-(void)TransitionSequence;
-(void)ResetToBaseSequence;
-(CAAnimation*)AnimationFromSpec:(NSDictionary*)effectSpec;

-(void)ApplyPreSequenceEffects:(unsigned int)sequenceIndex;
-(void)ApplyPostSequenceEffects:(unsigned int)sequenceIndex;
-(void)ApplyPropertyEffects:(NSArray*)propertyEffects;
-(void)ApplyEffects:(NSArray*)effectsToApply :(BOOL)pre;
-(void)ApplyEffect:(NSDictionary*)effectSpec :(BOOL)pre;

-(void)AnimateSequence:(unsigned int)sequenceIndex;
-(void)AnimateSequence:(unsigned int)sequenceIndex Forward:(BOOL)animateForward;
-(void)AnimateFromIndex:(unsigned int)fromIndex ToIndex:(unsigned int)toIndex;
-(void)PositionOnBaseSequence;

@end
