// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

// AAssetManager
// NSObject subclass that manages dynamic content rendering

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
#import "AssetPageReferences.h"
#import "CustomAnimation.h"
#import "AssetManagerDelegate.h"

#define kImageType            @"IMAGE"
#define kImageSequenceType    @"IMAGESEQUENCE"
#define kSegmentedImageType   @"SEGMENTEDIMAGE"
#define kStaticType           @"STATIC"
#define kStaticImageType      @"STATICIMAGE"
#define kAnimationType        @"ANIMATION"
#define kAnimationFramesType  @"FRAMES"
#define kAudioType            @"AUDIO"
#define kEncapsulatedType     @"ENCAPSULATED"

#define kAnimationPropTypePos    @"POS"
#define kAnimationPropTypeAlpha  @"ALPHA"
#define kAnimationPropTypeStatic @"STATIC"
#define kAnimationPropTypeAction @"ACTION"

#define kTiltActionThresholdRadians (M_PI/10.0)

@interface AAssetManager : NSObject
{
   NSUInteger fChapterNumber;
   NSUInteger fCurrentPage;
   NSDictionary* fAssets;
   NSMutableArray* fAssetPageReferences;
   BOOL fTiltLeft;
   BOOL fTiltRight;
   UIViewController* fController;
   id<AAssetManagerDelegate> fDelegate;
   
   NSTimer* fTiltTimer;
   
   NSTimer* fShakeTimer;
   CMAccelerometerData* fLastAcceleration;
   BOOL fShakeStarted;
}

@property (assign) NSUInteger chapterNumber;
@property (assign) NSUInteger currentPage;
@property (nonatomic, retain) NSDictionary* assets;
@property (nonatomic, retain) NSMutableArray* assetPageReferences;

@property (nonatomic, retain) UIViewController* controller;
@property (nonatomic, assign) id<AAssetManagerDelegate> delegate;
@property (nonatomic, retain) NSTimer* tiltTimer;
@property (nonatomic, retain) CMAccelerometerData* lastAcceleration;
@property (nonatomic, retain) NSTimer* shakeTimer;
@property (assign) BOOL shakeStarted;

@property (readonly) NSUInteger numPages;
@property (readonly) NSUInteger numLayoutPages;

+(AAssetManager*)AssetManagerFromData:(NSData*)assetManagerData;

-(id)initWithAssetsURL:(NSURL*)assetsURL;
-(void)RenderAssetsForPage:(NSUInteger)pageNum AndInView:(UIView*)view;
-(BOOL)isPageIndexable:(NSInteger)pageNumber;
-(AAssetPageReferences*)AssetPageReferencesForAssetRef:(AAssetReference*)assetRef;
-(AAssetReference*)AddAssetReferenceWithElement:(NSDictionary*)element AndLayer:(CALayer*)layer;
-(AAssetReference*)AddAssetReferenceWithElement:(NSDictionary*)element AndCustomAnimation:(id<ACustomAnimation>)customAnimation;
-(void)RegisterTrigger:(NSDictionary*)triggerSpec InView:(UIView*)view;
-(void)RegisterElementTriggers:(NSDictionary*)element InView:(UIView*)view;

@end
