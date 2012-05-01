// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "SegmentedImage.h"
#import "ImageSegment.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Trigger.h"
#import "BookView.h"

@interface ASegmentedImage (Private)

-(void)ProcessElementSegments:(NSDictionary*)element;

@end

@implementation ASegmentedImage (Private)

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   // process the SEGMENTEDIMAGE element in order to set up the various 
   // image segments
   
   if (!element.hasSegments)
   {
      return;
   }
   
   self.imageSegments = [NSMutableArray arrayWithCapacity:[element.segments count]];
               
   UIView* containerView = nil;
   
   // do these images need to reside on their own view, i.e. a view that's subordinate
   // to the view received by this method?
   if (element.isOnView)
   {
      CGRect viewFrame = element.frame;
      
      containerView = [[UIView alloc] initWithFrame:viewFrame];
      
      self.imageView = containerView;
      [containerView release];
      
      containerView = self.imageView;
      
      [view addSubview:containerView];
   }
   else 
   {
      containerView = view;
   }
   
   // set up some place for the segments to live
   [self ProcessElementSegments:element];
   
   if ([view isKindOfClass:[ABookView class]])
   {
      [(ABookView*)view RegisterAsset:self WithKey:element.propertyId];
   }
      
   // register any triggers
   if (element.hasTrigger)
   {
      ATrigger* theTrigger = [[ATrigger alloc] initWithTriggerSpec:element.trigger ForAnimation:self OnView:view];
      self.trigger = theTrigger;
      [theTrigger release];
   }
   
   if (nil != self.layer)
   {
      [containerView.layer addSublayer:self.layer];
   }      
}

-(void)ProcessElementSegments:(NSDictionary*)element
{
   // do nothing, by default
}

@end


@implementation ASegmentedImage

@synthesize imageView = fImageView;
@synthesize layer = fLayer;
@synthesize imageSegments = fImageSegments;
@synthesize trigger = fTrigger;

-(void)dealloc
{
   self.layer.delegate = nil;
   if (self.layer.superlayer)
   {
      [self.layer removeFromSuperlayer];
   }
   Release(fLayer);

   // Unregister ourself with this trigger
   if (self == fTrigger.animation)
   {
      fTrigger.animation = nil;
   }

   Release(fImageSegments);
   Release(fImageView);
   Release(fTrigger);
   
   [super dealloc];
}


#pragma mark ACustomAnimation protocol
-(id)initWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   if (self = [super init])
   {
      [self BaseInitWithElement:element RenderOnView:view];
   }
   
   return self;
}

-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{
   // implemented by subclass
}

@end
