// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PhysicsEngineBasedAnimation.h"

@class ChipmunkBody;
@class ChipmunkShape;

@interface APotteryShards : APhysicsEngineBasedAnimation <UIGestureRecognizerDelegate>
{
   NSMutableArray* fShardBodies;
   NSMutableArray* fShardShapes;
}

@property (nonatomic, retain) NSMutableArray* shardBodies;
@property (nonatomic, retain) NSMutableArray* shardShapes;

@end
