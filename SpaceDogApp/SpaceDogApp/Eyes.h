// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "PageBasedAnimation.h"

@class ATrigger;

@interface AEyes : APageBasedAnimation
{
   
   CALayer*  fSocketLayer;
   CALayer*  fEyesLayer;
      
   CGFloat   fMinX;
   CGFloat   fMaxX;
   CGFloat   fMinY;
   CGFloat   fMaxY;
}

@property (nonatomic, retain) CALayer* socketLayer;
@property (nonatomic, retain) CALayer* eyesLayer;

@property (assign) CGFloat minX;
@property (assign) CGFloat maxX;
@property (assign) CGFloat minY;
@property (assign) CGFloat maxY;

@end
