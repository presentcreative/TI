// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@interface ASunset : APageBasedAnimation
{
   NSMutableArray* fPirateSequences;
      
   CALayer* fForegroundLayer;
   CALayer* fSunLayer;
   CGPoint  fOriginalSunPosition;
   CALayer* fBlackLayer;
   CALayer* fTheEndLayer;
   NSTimer* fTheEndTimer;
   
   OALAudioTrack* fClosingTheme;
   NSTimer* fClosingThemeTimer;
}

@property (nonatomic, retain) NSMutableArray* pirateSequences;

@property (nonatomic, retain) CALayer* foregroundLayer;
@property (nonatomic, retain) CALayer* sunLayer;
@property (assign) CGPoint originalSunPosition;
@property (nonatomic, retain) CALayer* blackLayer;
@property (nonatomic, retain) CALayer* theEndLayer;
@property (nonatomic, retain) NSTimer* theEndTimer;

@property (nonatomic, retain) OALAudioTrack* closingTheme;
@property (nonatomic, retain) NSTimer* closingThemeTimer;

@end
