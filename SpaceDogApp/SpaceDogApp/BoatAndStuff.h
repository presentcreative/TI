// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface ABoatAndStuff : APageBasedAnimation <UIGestureRecognizerDelegate>
{
   CALayer*  fStuffLayer;
   CGRect    fStuffLayerFrame;
   CGPoint   fStuffLayerPosition;
   NSString* fStuffLayerResource;
   
   CALayer*  fBoatLayer;
   id<ACustomAnimation> fSoundEffect;
      
   CGFloat fYDelta;
   
   BOOL fAnimationFired;
   BOOL fStuffIsDraggable;
}

@property (nonatomic, retain) CALayer* stuffLayer;
@property (assign) CGRect stuffLayerFrame;
@property (copy) NSString* stuffLayerResource;
@property (assign) CGPoint stuffLayerPosition;
@property (nonatomic, retain) CALayer* boatLayer;
@property (nonatomic, retain) id<ACustomAnimation> soundEffect;

@property (assign) CGFloat yDelta;
@property (assign) BOOL animationFired;
@property (assign) BOOL stuffIsDraggable;

@end
