// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "CustomAnimationImpl.h"

@interface ASpringAnimation : ACustomAnimationImpl
{
   CGFloat fMaximumExtension;
   CGFloat fSpringTension;
}

@property (assign) CGFloat maximumExtension;
@property (assign) CGFloat springTension;

@end
