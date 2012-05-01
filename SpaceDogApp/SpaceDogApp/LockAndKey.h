// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@interface ALockAndKey : APageBasedAnimation 
{
   CALayer*  fKeyLayer;
   CALayer*  fLeftLockLayer;
   CALayer*  fInnerLockLayer;
   CALayer*  fRightLockLayer;
   CALayer*  fBarLayer;
   
   CGFloat   fMinX;
   CGFloat   fMaxX;
   CGFloat   fLockThreshold;
   CGFloat   fUnlockThreshold;
   
   BOOL      fLockOpen;
   
   NSString* fUnlockSoundEffect;
   NSString* fLockSoundEffect;
}

@property (nonatomic, retain) CALayer* keyLayer;
@property (nonatomic, retain) CALayer* leftLockLayer;
@property (nonatomic, retain) CALayer* innerLockLayer;
@property (nonatomic, retain) CALayer* rightLockLayer;
@property (nonatomic, retain) CALayer* barLayer;

@property (assign) CGFloat minX;
@property (assign) CGFloat maxX;
@property (assign) CGFloat lockThreshold;
@property (assign) CGFloat unlockThreshold;

@property (copy) NSString* unlockSoundEffect;
@property (copy) NSString* lockSoundEffect;

@property (assign, getter=isLockOpen) BOOL lockOpen;

@end
