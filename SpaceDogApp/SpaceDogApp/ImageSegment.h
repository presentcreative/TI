// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface AImageSegment : NSObject 
{
   CALayer* fLayer;
   UIView* fView;
}

@property (nonatomic, retain) CALayer* layer;
@property (nonatomic, retain) UIView* view;

@property (readonly) BOOL isOnLayer;
@property (readonly) BOOL isOnView;

@end
