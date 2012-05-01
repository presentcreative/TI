// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "CustomAnimation.h"

@interface ARandomNotificationGenerator : NSObject <ACustomAnimation>
{
   NSString* fAnimationId;
   NSString* fAssetId;
   NSString* fNotificationNameBase;
   NSArray*  fSuffixes;
   NSMutableArray* fNotifications;
   CGFloat   fMinDelay;
   CGFloat   fMaxDelay;
   NSTimer*  fNotificationTimer;
   
   NSMutableArray* fTriggers;
}

@property (copy) NSString* assetId;
@property (copy) NSString* notificationNameBase;
@property (nonatomic, retain) NSArray* suffixes;
@property (nonatomic, retain) NSMutableArray* notifications;
@property (assign) CGFloat minDelay;
@property (assign) CGFloat maxDelay;
@property (nonatomic, retain) NSTimer* notificationTimer;
@property (nonatomic, retain) NSMutableArray* triggers;

@end
