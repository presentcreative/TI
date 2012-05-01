// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface ASeagull : APageBasedAnimation
{         
   CALayer* fSeagullLayer;
   CGRect   fSeagullLayerFrame;
   NSArray* fSeagullLayerPathPoints;
   CGFloat  fSeagullLayerAnimationDuration;
   CGFloat  fSeagullFadeThreshold;
}

@property (nonatomic, retain) CALayer* seagullLayer;
@property (assign) CGRect seagullLayerFrame;
@property (nonatomic, retain) NSArray* seagullLayerPathPoints;
@property (assign) CGFloat seagullLayerAnimationDuration;
@property (assign) CGFloat seagullFadeThreshold;

@end

