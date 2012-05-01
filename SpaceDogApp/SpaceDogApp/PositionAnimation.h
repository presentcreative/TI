// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "CustomAnimationImpl.h"

@interface APositionAnimation : ACustomAnimationImpl
{
   CGPoint fOriginalPosition;
   CGFloat fXDelta;
   CGFloat fYDelta;
   BOOL    fUpdateToFinalPosition;
}

@property (assign) CGPoint originalPosition;
@property (assign) CGFloat xDelta;
@property (assign) CGFloat yDelta;
@property (assign) BOOL updateToFinalPosition;

@end
