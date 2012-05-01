// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

// AAssetReference
// Asset reference container class

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"
#import "CustomAnimation.h"

#define kDelayTypeNone     @"NONE"
#define kDelayTypeFixed    @"FIXED"
#define kDelayTypeVariable @"VARIABLE"

#define kDelayDefault         2.0f // 2 seconds
#define kVariableDelayMinimum 1.0f // 1 second
#define kVariableDelayMaximum 3.0f // 3 seconds

@class CAAnimation;

@interface AAssetReference : NSObject 
{
   NSUInteger fElementIndex;
   NSDictionary* fElement;
   UIImageView* fImgView;
   NSUInteger fActivePropertyIndex;
   CALayer* fLayer;
   OrderedDictionary* fSequencedAnimations;
   NSString* fDelayType;
   CGFloat fDelayMinimum;
   CGFloat fDelayMaximum;
   BOOL fIsConcurrent;
   NSString* fAnimationGroup;
   CAAnimation* fStandaloneAnimation;
   id<ACustomAnimation> fCustomAnimation;
   NSString* fPostAnimationNotification;
}

@property (nonatomic,retain) NSDictionary* fElement;
@property (nonatomic,retain) UIImageView* fImgView;
@property (nonatomic) NSUInteger fActivePropertyIndex;
@property (nonatomic,retain) CALayer* fLayer;
@property (nonatomic,retain) OrderedDictionary* fSequencedAnimations;
@property (copy) NSString* fDelayType;
@property (assign) CGFloat fDelayMinimum;
@property (assign) CGFloat fDelayMaximum;
@property (assign) CGFloat fFixedDelay;
@property (assign) BOOL fIsConcurrent;
@property (copy) NSString* fAnimationGroup;
@property (nonatomic, retain) CAAnimation* fStandaloneAnimation;
@property (nonatomic, retain) id<ACustomAnimation> fCustomAnimation;
@property (copy) NSString* fPostAnimationNotification;

-(id)initWithIndex:(NSUInteger)index AndElement:(NSDictionary*)element AndImgView:(UIImageView*)imgView;
-(id)initWithIndex:(NSUInteger)index AndElement:(NSDictionary*)element AndLayer:(CALayer*)layer;
-(id)initWithIndex:(NSUInteger)index AndElement:(NSDictionary*)element AndCustomAnimation:(id<ACustomAnimation>)customAnimation;

-(void)RunNextSequencedAnimation;
-(void)RunTriggeredAnimation;

@end
