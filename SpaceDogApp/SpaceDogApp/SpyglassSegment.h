// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "ImageSegment.h"

@interface ASpyglassSegment : AImageSegment
{
   CGFloat fMinX;
   CGFloat fMaxX;
   
   CGFloat fCollapseStartX;
   CGFloat fExtensionStartX;
   
   CGFloat fLastDriverPosition;
   
   NSString* fCloseSound;
   CGFloat fCloseTriggerX;
   BOOL fCloseSoundTriggered;
   
   NSString* fOpenSound;
   CGFloat fOpenTriggerX;
   BOOL fOpenSoundTriggered;
}

@property (assign) CGFloat minX;
@property (assign) CGFloat maxX;
@property (assign) CGFloat collapseStartX;
@property (assign) CGFloat extensionStartX;
@property (assign) CGFloat lastDriverPosition;

@property (copy) NSString* openSound;
@property (assign) CGFloat openTriggerX;
@property (assign) BOOL openSoundTriggered;

@property (copy) NSString* closeSound;
@property (assign) CGFloat closeTriggerX;
@property (assign) BOOL closeSoundTriggered;

+(ASpyglassSegment*)imageSegmentFromSegmentSpec:(NSDictionary*)segmentSpec;

-(CGFloat)MoveDeltaX:(CGFloat)deltaX;
-(void)MoveDeltaX:(CGFloat)deltaX DependingOn:(CGFloat)driverPosition;

@end
