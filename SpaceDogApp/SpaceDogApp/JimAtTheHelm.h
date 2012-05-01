// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomAnimation.h"
#import "PageBasedAnimation.h"

typedef enum
{
   Starbord,
   Port
} Turn;

@class ATrigger;

@interface AJimAtTheHelm : APageBasedAnimation
{
   CALayer* fWheelLayer;
   CALayer* fRopeCWLayer;
   CALayer* fRopeCCWLayer;
   CALayer* fSailPortLayer;
   CALayer* fSailStarbordLayer;
      
   CGFloat fYMovement;
   CGFloat fYMovementThreshold;
   
   CGRect fWheelLeftRegion;
   CGRect fWheelRightRegion;
   
   Turn fCurrentTurn;
   CGFloat fLastRotationAngle;
}

@property (nonatomic, retain) CALayer* wheelLayer;
@property (nonatomic, retain) CALayer* ropeCWLayer;
@property (nonatomic, retain) CALayer* ropeCCWLayer;
@property (nonatomic, retain) CALayer* sailPortLayer;
@property (nonatomic, retain) CALayer* sailStarbordLayer;

@property (assign) CGFloat yMovement;
@property (assign) CGFloat yMovementThreshold;

@property (assign) CGRect wheelLeftRegion;
@property (assign) CGRect wheelRightRegion;

@property (assign) Turn currentTurn;
@property (assign) CGFloat lastRotationAngle;

@end
