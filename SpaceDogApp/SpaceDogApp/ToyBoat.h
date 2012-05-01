// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@class ATriggeredSpringAnimation;

@interface AToyBoat : APageBasedAnimation
{
   CALayer*  fIslandLayer;
   CALayer*  fBoatLayer;
   CALayer*  fWaterLayer;
   
   CGFloat   fMinX;
   CGFloat   fMaxX;
   CGFloat   fMinY;
   CGFloat   fMaxY;
   
   BOOL      fBoatIsSwipeable;
   ATriggeredSpringAnimation* fSpringAnimation;
   
   NSString* fSoundEffect;
}

@property (nonatomic, retain) CALayer* islandLayer;
@property (nonatomic, retain) CALayer* boatLayer;
@property (nonatomic, retain) CALayer* waterLayer;

@property (assign) CGFloat minX;
@property (assign) CGFloat maxX;
@property (assign) CGFloat minY;
@property (assign) CGFloat maxY;

@property (assign) BOOL boatIsSwipeable;
@property (nonatomic, retain) ATriggeredSpringAnimation* springAnimation;

@property (copy) NSString* soundEffect;

@end
