// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomAnimation.h"
#import "PageBasedAnimation.h"

@class ATrigger;

@interface ASegmentedImage : APageBasedAnimation
{
   NSMutableArray* fImageSegments;
   UIView* fImageView;
   CALayer* fLayer;
   ATrigger* fTrigger;
}

@property (nonatomic, retain) NSMutableArray* imageSegments;
@property (nonatomic, retain) UIView* imageView;
@property (nonatomic, retain) CALayer* layer;
@property (nonatomic, retain) ATrigger* trigger;

-(IBAction)HandleGesture:(UIGestureRecognizer*)sender;

@end
