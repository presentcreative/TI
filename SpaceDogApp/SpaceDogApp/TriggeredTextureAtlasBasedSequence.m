// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "TriggeredTextureAtlasBasedSequence.h"
#import "ImageSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Trigger.h"

@implementation ATriggeredTextureAtlasBasedSequence

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   [super BaseInitWithElement:element RenderOnView:view];
      
   ATrigger* theTrigger = nil;
   
   if (element.hasTriggers)
   {
      for (NSDictionary* triggerSpec in element.triggers)
      {
         theTrigger = [[ATrigger alloc] initWithTriggerSpec:triggerSpec ForAnimation:self OnView:view];
         [theTrigger release];
      }
   }
   else if (element.hasTrigger)
   {
      theTrigger = [[ATrigger alloc] initWithTriggerSpec:element.trigger ForAnimation:self OnView:view];
      [theTrigger release];
   }
}

#pragma mark ACustomAnimation protocol
#pragma mark ACustomAnimation protocol
-(void)Trigger
{
   if ([self CalculateNextSequence])
   {
      [self TransitionSequence];
   }   
}

-(void)Trigger:(NSNotification*)notification
{
   [self Trigger];   
}

-(void)TriggerWithSpec:(NSDictionary*)triggerSpec
{
   // the triggerSpec contains the sequence index of the sequence to which to
   // force transition
   NSNumber* nextSequence = [triggerSpec objectForKey:@"NEXT_SEQUENCE"];
   
   if (nil != nextSequence)
   {
      self.sequenceInPlay = [nextSequence unsignedIntegerValue];
      [self TransitionSequence];
   }   
}

@end
