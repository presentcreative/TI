// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation AUtilities

+(void)SetAnchorPoint:(CGPoint)anchorPoint ForView:(UIView*)view
{
   view.layer.anchorPoint = anchorPoint;
   
   CGPoint correctedPosition = CGPointMake(view.layer.position.x + view.layer.bounds.size.width * (view.layer.anchorPoint.x - 0.5),
                                           view.layer.position.y + view.layer.bounds.size.height * (view.layer.anchorPoint.y -0.5));
   
   view.layer.position = correctedPosition;
}

@end
