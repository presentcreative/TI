// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "SimplePropertyAnimation.h"

@interface ASimplePropertyToggle : ASimplePropertyAnimation
{
   BOOL fStartWithFromValue;
   CGFloat fReverseDelay;
   BOOL fAutoReverseInProgress;
}

@property (assign) BOOL startWithFromValue;
@property (assign) CGFloat reverseDelay;
@property (assign) BOOL autoReverseInProgress;

@end
