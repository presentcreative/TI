// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"
#import "OrderedDictionary.h"

@interface AAnimationSequence : APageBasedAnimation
{
   CALayer* fLayer;
   NSUInteger fCurrentAnimationIndex;
   BOOL fSequenceInProgress;
   BOOL fRespectSequenceInProgress;
   NSString* fInPlayNotification;
   NSUInteger fInPlayNotificationIndex;
   OrderedDictionary* fSequenceNotifications;
}

@property (nonatomic, retain) CALayer* layer;
@property (assign) NSUInteger currentAnimationIndex;
@property (assign) BOOL sequenceInProgress;
@property (assign) BOOL respectSequenceInProgress;
@property (copy) NSString* inPlayNotification;
@property (assign) NSUInteger inPlayNotificationIndex;
@property (nonatomic, retain) OrderedDictionary* sequenceNotifications;

@end
