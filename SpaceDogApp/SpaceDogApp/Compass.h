// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface ACompass : APageBasedAnimation
{
   CALayer*  fCompassLayer;
   CALayer*  fNeedleLayer;
}

@property (nonatomic, retain) CALayer* compassLayer;
@property (nonatomic, retain) CALayer* needleLayer;

@end
