// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PageBasedAnimation.h"
#import "OrderedDictionary.h"

@interface AWindows : APageBasedAnimation
{
   NSString* fFrameKeyTemplate;
   NSDictionary* fWindowCoordinates;
   OrderedDictionary* fWindowLocations;
   NSMutableArray* fLayersByWindowIndex;
}

@property (copy) NSString* frameKeyTemplate;
@property (nonatomic, retain) NSDictionary* windowCoordinates;
@property (nonatomic, retain) OrderedDictionary* windowLocations;
@property (nonatomic, retain) NSMutableArray* layersByWindowIndex;

@end
