// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "TriggeredSimplePropertyToggle.h"

@implementation ATriggeredSimplePropertyToggle

-(void)Start:(BOOL)triggered
{
   if (triggered ||self.autoStart)
   {
      [super Start:triggered];
   }
}

@end
