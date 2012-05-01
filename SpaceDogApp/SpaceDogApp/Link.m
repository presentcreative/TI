// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Link.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@implementation ALink

@synthesize address=fAddress;

-(void)dealloc
{
   Release(fAddress);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.address = @"";
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.address = element.address;
}

-(void)Trigger
{
   NSURL* url = [NSURL URLWithString:self.address];
   
   [[UIApplication sharedApplication] openURL:url];   
}

@end
