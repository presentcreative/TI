// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@class OrderedDictionary;
@class AAmbientSound;
@class CALayer;

@interface ACreditsPage : APageBasedAnimation
{      
   CGFloat fScrollDuration;
   NSDate* fScrollStart;
   CGFloat fMaxScrollX;
   NSTimer* fScrollTimer;
   
   CGFloat fCreditAnimationDuration;
   NSUInteger fCreditDisplayIndex;
   NSTimer* fCreditDisplayTimer;
   
   CADisplayLink* fTurnTimer;
   NSMutableArray* fTurnSpecs;
   NSDate* fSequenceStart;
   
   OrderedDictionary* fCreditSpecsByTimeOffset;
   
   AAmbientSound* fCreditsSound;
   
   CALayer* fTopImageLayer;
   CALayer* fBottomImageLayer;
   
   BOOL fTopImageLayerAnimationFired;
   
   CALayer* fBlackDog1Layer;
   CGRect   fBlackDog1LayerFrame;
   NSArray* fBlackDog1LayerPathPoints;
   CGFloat fBlackDog1LayerAnimationDuration;
   
   CALayer* fPorter1Layer;
   NSArray* fPorter1LayerPathPoints;
   CGFloat fPorter1LayerAnimationDuration;
   
   CALayer* fBlackDog2Layer;
   NSArray* fBlackDog2LayerPathPoints;
   CGFloat fBlackDog2LayerAnimationDuration;
   
   CALayer* fPorter2Layer;
   NSArray* fPorter2LayerPathPoints;
   CGFloat fPorter2LayerAnimationDuration;
   
   CALayer* fBlackDogAndPorter1Layer;
   NSArray* fBlackDogAndPorter1LayerPathPoints;
   CGFloat fBlackDogAndPorter1LayerAnimationDuration;
   
   CALayer* fBlackDogAndPorter2Layer;
   NSArray* fBlackDogAndPorter2LayerPathPoints;
   CGFloat fBlackDogAndPorter2LayerAnimationDuration;
   
   CALayer* fTree1Layer;
   CALayer* fTrees2Layer;
}

@property (assign) CGFloat scrollDuration;
@property (nonatomic, retain) NSDate* scrollStart;
@property (assign) CGFloat maxScrollX;
@property (nonatomic, retain) NSTimer* scrollTimer;

@property (assign) CGFloat creditAnimationDuration;
@property (assign) NSUInteger creditDisplayIndex;
@property (nonatomic, retain) NSTimer* creditDisplayTimer;

@property (nonatomic, retain) CADisplayLink* turnTimer;
@property (nonatomic, retain) NSMutableArray* turnSpecs;
@property (nonatomic, retain) NSDate* sequenceStart;

@property (nonatomic, retain) OrderedDictionary* creditSpecsByTimeOffset;

@property (nonatomic, retain) AAmbientSound* creditsSound;

@property (nonatomic, retain) CALayer* topImageLayer;
@property (nonatomic, retain) CALayer* bottomImageLayer;

@property (assign) BOOL topImageLayerAnimationFired;

@property (nonatomic, retain) CALayer* blackDog1Layer;
@property (assign) CGRect blackDog1LayerFrame;
@property (nonatomic, retain) NSArray* blackDog1LayerPathPoints;
@property (assign) CGFloat blackDog1LayerAnimationDuration;

@property (nonatomic, retain) CALayer* porter1Layer;
@property (nonatomic, retain) NSArray* porter1LayerPathPoints;
@property (assign) CGFloat porter1LayerAnimationDuration;

@property (nonatomic, retain) CALayer* blackDog2Layer;
@property (nonatomic, retain) NSArray* blackDog2LayerPathPoints;
@property (assign) CGFloat blackDog2LayerAnimationDuration;

@property (nonatomic, retain) CALayer* porter2Layer;
@property (nonatomic, retain) NSArray* porter2LayerPathPoints;
@property (assign) CGFloat porter2LayerAnimationDuration;

@property (nonatomic, retain) CALayer* blackDogAndPorter1Layer;
@property (nonatomic, retain) NSArray* blackDogAndPorter1LayerPathPoints;
@property (assign) CGFloat blackDogAndPorter1LayerAnimationDuration;

@property (nonatomic, retain) CALayer* blackDogAndPorter2Layer;
@property (nonatomic, retain) NSArray* blackDogAndPorter2LayerPathPoints;
@property (assign) CGFloat blackDogAndPorter2LayerAnimationDuration;

@property (nonatomic, retain) CALayer* tree1Layer;
@property (nonatomic, retain) CALayer* trees2Layer;

@property (readonly) UIScrollView* scrollView;
@property (readonly) UIImageView* imageView;
@property (readonly) UIButton* skipIntroButton;
@property (readonly) UIButton* beginBookButton;

@end

// A simple data-carrier class for use within ACreditsPage...
@interface ATurnSpec : NSObject
{
@private
   CGFloat fStartTime;
   NSString* fLayerName;
   CGFloat fRotation;
   CGFloat fDuration;
}

@property (assign) CGFloat startTime;
@property (copy) NSString* layerName;
@property (assign) CGFloat rotation;
@property (assign) CGFloat duration;

-(ATurnSpec*)initWithSpec:(NSDictionary*)turnSpecDictionary;

@end

// Another simple data-carrier class for use within ACreditsPage...
@interface ACreditDisplaySpec : NSObject
{
@private
   CGFloat fDisplayDuration;
   CALayer* fCreditLayer;
}

@property (assign) CGFloat displayDuration;
@property (nonatomic, retain) CALayer* creditLayer;

@end
