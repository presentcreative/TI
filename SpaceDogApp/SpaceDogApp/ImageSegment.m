// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ImageSegment.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@implementation AImageSegment

@synthesize layer = fLayer;
@synthesize view = fView;

-(void)dealloc
{
   self.layer.delegate = nil;
   if (self.layer.superlayer)
   {
      [self.layer removeFromSuperlayer];
   }
   Release(fLayer);
   
   Release(fView);
   
   [super dealloc];
}

-(BOOL)isOnLayer
{
   return nil != self.layer;
}

-(BOOL)isOnView
{
   return nil != self.view;
}

@end
