// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

/**
 * This Treasure Map-resident ship image that can be dragged
 * back and forth by touch. Currently, it rides on a sine wave...
 */

@interface ADraggableShip : APageBasedAnimation <UIGestureRecognizerDelegate>
{
   CGFloat  fDragMinX;
   CGFloat  fDragMaxX;
   CGFloat  fLastX;
   CGRect   fOriginalFrame;
   CGFloat  fInitialYOffset; 
   
   CALayer* fShipLayer;
   BOOL     fShipIsBobbing;
   NSDate*  fLastMovementTimestamp;
   NSTimer* fBobbingTimer;
}

@property (assign) CGFloat dragMinX;
@property (assign) CGFloat dragMaxX;
@property (assign) CGFloat lastX;
@property (assign) CGRect originalFrame;
@property (assign) CGFloat initialYOffset;
@property (assign) BOOL shipIsBobbing;
@property (nonatomic, retain) CALayer* shipLayer;
@property (nonatomic, retain) NSDate* lastMovementTimestamp;
@property (nonatomic, retain) NSTimer* bobbingTimer;

@end
