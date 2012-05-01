// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "HelpDescriptor.h"


@implementation AHelpDescriptor

@synthesize type=fType;
@synthesize arrowDirection=fArrowDirection;
@synthesize frame=fFrame;

-(void)dealloc
{
   Release(fType);
   Release(fArrowDirection);
   
   [super dealloc];
}

-(id)init
{
   if (self = [super init])
   {
      self.type = @"";
      self.arrowDirection = @"LEFT";
      self.frame = CGRectZero;
   }
   
   return self;
}


-(BOOL)isSwipeDescriptor
{
   return [kSwipeDescriptor isEqualToString:self.type];
}

-(BOOL)isShakeDescriptor
{
   return [kShakeDescriptor isEqualToString:self.type];
}

-(BOOL)isShakeAndRotateDescriptor
{
   return [kShakeAndRotateDescriptor isEqualToString:self.type];
}

-(BOOL)isTapDescriptor
{
   return [kTapDescriptor isEqualToString:self.type];
}

-(BOOL)isRotateDescriptor
{
   return [kRotateDescriptor isEqualToString:self.type];
}

-(BOOL)isSwipeUp
{
   BOOL result = NO;
   
   if (self.isSwipeDescriptor && [kSwipeUp isEqualToString:self.arrowDirection])
   {
      result = YES;
   }
   
   return result;
}

-(BOOL)isSwipeDown
{
   BOOL result = NO;
   
   if (self.isSwipeDescriptor && [kSwipeDown isEqualToString:self.arrowDirection])
   {
      result = YES;
   }
   
   return result;
}

-(BOOL)isSwipeLeft
{
   BOOL result = NO;
   
   if (self.isSwipeDescriptor && [kSwipeLeft isEqualToString:self.arrowDirection])
   {
      result = YES;
   }
   
   return result;
}

-(BOOL)isSwipeRight
{
   BOOL result = NO;
   
   if (self.isSwipeDescriptor && [kSwipeRight isEqualToString:self.arrowDirection])
   {
      result = YES;
   }
   
   return result;
}

@end
