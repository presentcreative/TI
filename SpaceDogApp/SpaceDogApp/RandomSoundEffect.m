// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <math.h>
#import "ObjectAL.h"
#import "RandomSoundEffect.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@implementation ARandomSoundEffect

@synthesize resourceNames = fResourceNames;

-(void)dealloc
{
   Release(fResourceNames);
   
   [super dealloc];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{ 
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.resourceNames = [NSMutableArray array];
   
   for (NSString* resourceName in element.resourceNames)
   {
      [self.resourceNames addObject:resourceName];
   }
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   if (nil == self.lastPlayed || (self.duration < fabs([self.lastPlayed timeIntervalSinceNow])))
   {
      // randomly determine the index of the sound effect to play
      NSInteger resourceIndex = arc4random() % [self.resourceNames count];
      
      [self.audioTrack playFile:[self.resourceNames objectAtIndex:resourceIndex]];
   }
   
   self.lastPlayed = [NSDate date];
}

@end
