// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomAnimation.h"

@class ATrigger;

@interface ACustomAnimationImpl : NSObject <ACustomAnimation>
{
   NSString* fAnimationId;
   NSString* fKeyPath;
   CGFloat fDuration;
   CGFloat fDelay;
   NSString* fSequenceId;
   NSString* fRepeatType;
   NSUInteger fNumRepeats;
   NSString* fResourceBase;
   NSString* fResource;
   CGRect fFrame;
   CALayer* fLayer;
   BOOL fAutoReverse;
   NSString* fTimingFunctionName;
   NSString* fCompletionNotification;
   BOOL fAutoStart;
   id<ACustomAnimation> fSoundEffect;
   BOOL fOneShot;
   NSUInteger fFireCount;
   id fDelegate;
}

@property (copy) NSString* keyPath;
@property (assign) CGFloat duration;
@property (assign) CGFloat delay;
@property (copy) NSString* sequenceId;
@property (nonatomic, retain) NSString* repeatType;
@property (assign) NSUInteger numRepeats;
@property (copy) NSString* resourceBase;
@property (copy) NSString* resource;
@property (assign) CGRect frame;
@property (nonatomic, retain) CALayer* layer;
@property (assign) BOOL autoReverse;
@property (copy) NSString* timingFunctionName;
@property (copy) NSString* completionNotification;
@property (assign) BOOL autoStart;
@property (nonatomic, retain) id<ACustomAnimation> soundEffect;
@property (assign, getter=isOneShot) BOOL oneShot;
@property (assign) NSUInteger fireCount;
@property (assign) id delegate;

@property (readonly) CAAnimation* animation;
@property (readonly) NSString* animationKey;

-(void)BaseInit;
-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view;
-(void)BaseInitWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer;

@end
