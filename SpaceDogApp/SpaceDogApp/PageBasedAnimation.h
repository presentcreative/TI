// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomAnimation.h"
#import "SpaceDogAppViewController.h"

@class ATrigger;

@interface APageBasedAnimation : NSObject <ACustomAnimation>
{
   NSString* fAnimationId;
   NSString* fPropertyId;
   UIView*   fContainerView;
   
   NSMutableArray* fAnimations;  // well, sub-animations actually...
   NSMutableDictionary* fAnimationsByName;
    BOOL fWaitForTrigger;
}

@property (copy) NSString* propertyId;
@property (assign) UIView* containerView; // weak reference, here!
@property (nonatomic, retain) NSMutableArray* animations;
@property (nonatomic, retain) NSMutableDictionary* animationsByName;
@property (readonly) BOOL waitForTrigger;

@property (readonly) ATrigger* tiltTrigger;
@property (readonly) ATrigger* shakeTrigger;

@property (readonly) SpaceDogAppViewController* mainViewController;

-(void)BaseInit;
-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view;

@end
