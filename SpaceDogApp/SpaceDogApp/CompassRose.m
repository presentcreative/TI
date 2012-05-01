// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "CompassRose.h"
#import "Constants.h"

@implementation ACompassRose

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter]
    removeObserver:self];
   
   //NSLog(@"ACompassRose deallocated");
   
   [super dealloc];
}

#pragma mark -
#pragma mark ACustomAnimation
-(void)Trigger
{
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kNotificationCloseMap 
    object:nil];
}

@end
