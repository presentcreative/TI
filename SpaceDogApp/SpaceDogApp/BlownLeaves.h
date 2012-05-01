// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"

@interface ABlownLeaves : APageBasedAnimation
{         
   CALayer* fLeaf1Layer;
   CGRect   fLeaf1Frame;
   NSArray* fLeaf1PathPoints;
   CGFloat  fLeaf1AnimationDuration;
   CGFloat  fLeaf1FadeThreshold;
   
   CALayer* fLeaf2Layer;
   CGRect   fLeaf2Frame;
   NSArray* fLeaf2PathPoints;
   CGFloat  fLeaf2AnimationDuration;
   CGFloat  fLeaf2FadeThreshold;
   
   CALayer* fLeaf3Layer;
   CGRect   fLeaf3Frame;
   NSArray* fLeaf3PathPoints;
   CGFloat  fLeaf3AnimationDuration;
   CGFloat  fLeaf3FadeThreshold;
}

@property (nonatomic, retain) CALayer* leaf1Layer;
@property (assign) CGRect leaf1Frame;
@property (nonatomic, retain) NSArray* leaf1PathPoints;
@property (assign) CGFloat leaf1AnimationDuration;
@property (assign) CGFloat leaf1FadeThreshold;

@property (nonatomic, retain) CALayer* leaf2Layer;
@property (assign) CGRect leaf2Frame;
@property (nonatomic, retain) NSArray* leaf2PathPoints;
@property (assign) CGFloat leaf2AnimationDuration;
@property (assign) CGFloat leaf2FadeThreshold;

@property (nonatomic, retain) CALayer* leaf3Layer;
@property (assign) CGRect leaf3Frame;
@property (nonatomic, retain) NSArray* leaf3PathPoints;
@property (assign) CGFloat leaf3AnimationDuration;
@property (assign) CGFloat leaf3FadeThreshold;

@end
