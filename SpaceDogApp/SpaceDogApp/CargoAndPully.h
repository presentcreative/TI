// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface ACargoAndPully : APageBasedAnimation
{
   UIImageView* fCargoView;
   
   CGFloat   fMinY;
   CGFloat   fMaxY;
   
   NSString* fCargoDownSoundEffect;
   NSString* fCargoUpSoundEffect;
   BOOL fSoundPlaying;
}

@property (nonatomic, retain) UIImageView* cargoView;
@property (assign) CGFloat minY;
@property (assign) CGFloat maxY;
@property (copy) NSString* cargoDownSoundEffect;
@property (copy) NSString* cargoUpSoundEffect;
@property (assign, getter = isSoundPlaying) BOOL soundPlaying;

@end
