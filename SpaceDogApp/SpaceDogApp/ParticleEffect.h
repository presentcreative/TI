// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomAnimation.h"
#import "ESRenderer.h"

@interface AParticleEffect : NSObject <ACustomAnimation>
{
   NSString* fPropertyId;
   UIView* fContainerView;
   
   NSMutableArray* fTriggers;
   
   CAEAGLLayer* fParticleLayer;
   id<ESRenderer> fRenderer; 
   
   BOOL fAnimating;
   NSInteger fAnimationFrameInterval;
}

@property (copy) NSString* propertyId;
@property (nonatomic, retain) UIView* containerView;
@property (nonatomic, retain) NSMutableArray* triggers;
@property (nonatomic, retain) CAEAGLLayer* particleLayer;
@property (nonatomic, retain) id<ESRenderer> renderer;
@property (assign, getter = isAnimating) BOOL animating;
@property (assign) NSInteger animationFrameInterval;

@end
