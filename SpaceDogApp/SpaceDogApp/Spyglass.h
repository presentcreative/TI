// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "SegmentedImage.h"

@interface ASpyglass : ASegmentedImage
{
   CGFloat fLastDriverPosition;
}

@property (assign) CGFloat lastDriverPosition;

@end
