// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface AWarAtSea : APageBasedAnimation
{
   CALayer* fBoatLayer;
   CALayer* fWavesLayer;
    
    CGFloat bobFactor;
    CGFloat rockFactor;
    bool isRocking;
}

@property (nonatomic, retain) CALayer* boatLayer;
@property (nonatomic, retain) CALayer* wavesLayer;

@end
