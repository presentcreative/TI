// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "TriggeredPositionAnimation.h"

@implementation ATriggeredPositionAnimation

-(void)Start:(BOOL)triggered
{
   if (triggered)
   {
      [super Start:triggered];
   }
}

-(void)Stop
{
   [super Stop];
   
   self.fireCount = 0;
}

@end
