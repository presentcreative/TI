// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@class ATriggeredSoundEffect;

@interface AShipSailsAndPully : APageBasedAnimation
{
   //NSMutableArray* fSailSequences;
   
   CALayer*  fHookLayer;
    CGFloat   fMinY;
    CGFloat   fMaxY;
  /*   CALayer*  fCenterFrontLayer;
   CALayer*  fCenterMiddleLayer;
   CALayer*  fCenterRearLayer;
   CALayer*  fTopFrontLayer;
   CALayer*  fTopMiddleLayer;
   CALayer*  fTopRearLayer;
      
    CGFloat   fFurlThreshold;
   CGFloat   fUnfurlThreshold;
   
   BOOL      fUnfurled;
   
   ATriggeredSoundEffect* fUnfurlSoundEffect;
   ATriggeredSoundEffect* fFurlSoundEffect;*/
}

//@property (nonatomic, retain) NSMutableArray* sailSequences;

@property (nonatomic, retain) CALayer* hookLayer;
/*@property (nonatomic, retain) CALayer* centerFrontLayer;
@property (nonatomic, retain) CALayer* centerMiddleLayer;
@property (nonatomic, retain) CALayer* centerRearLayer;
@property (nonatomic, retain) CALayer* topFrontLayer;
@property (nonatomic, retain) CALayer* topMiddleLayer;
@property (nonatomic, retain) CALayer* topRearLayer;
*/
@property (assign) CGFloat minY;
@property (assign) CGFloat maxY;
//@property (assign) CGFloat furlThreshold;
//@property (assign) CGFloat unfurlThreshold;

//@property (assign, getter=isUnfurled) BOOL unfurled;

//@property (nonatomic, retain) ATriggeredSoundEffect* unfurlSoundEffect;
//@property (nonatomic, retain) ATriggeredSoundEffect* furlSoundEffect;

@end
