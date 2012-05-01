// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@class ATextureAtlasBasedSequence;

@interface AGoldSwipe : APageBasedAnimation 
{
   ATextureAtlasBasedSequence* fSwipe1Sequence;
   ATextureAtlasBasedSequence* fSwipe2Sequence;
   SEL fSequenceToPlay;
   BOOL fSequenceInPlay;
}

@property (nonatomic, retain) ATextureAtlasBasedSequence* swipe1Sequence;
@property (nonatomic, retain) ATextureAtlasBasedSequence* swipe2Sequence;
@property (assign) SEL sequenceToPlay;
@property (assign) BOOL sequenceInPlay;

@end
