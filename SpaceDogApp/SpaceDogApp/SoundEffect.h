// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"
#import "OALAudioTrack.h"

@interface ASoundEffect : APageBasedAnimation 
{
   NSString* fAssetId;
   NSString* fResourceName;
   CGFloat fDuration;
   CGFloat fDelay;
   NSDate* fLastPlayed;
   
   OALAudioTrack* fAudioTrack;
}

@property (copy) NSString* assetId;
@property (copy) NSString* resourceName;
@property (assign) CGFloat duration;
@property (assign) CGFloat delay;
@property (nonatomic, retain) NSDate* lastPlayed;
@property (nonatomic, retain) OALAudioTrack* audioTrack;

@end
