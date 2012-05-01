// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "CustomAnimationImpl.h"

@interface AZRotation : ACustomAnimationImpl
{
   CGFloat fStartAngle;    // degrees
   CGFloat fEndAngle;      // degrees
   CGPoint fAnchorPoint;
}

@property (assign) CGFloat startAngle;
@property (assign) CGFloat endAngle;
@property (assign) CGPoint anchorPoint;

@end
