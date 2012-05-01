// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "SpyglassSegment.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "OALSimpleAudio.h"

@implementation ASpyglassSegment

@synthesize minX = fMinX;
@synthesize maxX = fMaxX;
@synthesize collapseStartX = fCollapseStartX;
@synthesize extensionStartX = fExtensionStartX;
@synthesize lastDriverPosition = fLastDriverPosition;
@synthesize closeSound=fCloseSound;
@synthesize closeSoundTriggered=fCloseSoundTriggered;
@synthesize closeTriggerX=fCloseTriggerX;
@synthesize openSound=fOpenSound;
@synthesize openSoundTriggered=fOpenSoundTriggered;
@synthesize openTriggerX=fOpenTriggerX;

+(ASpyglassSegment*)imageSegmentFromSegmentSpec:(NSDictionary*)segmentSpec
{
   ASpyglassSegment* result = [[[ASpyglassSegment alloc] init] autorelease];
   
   // load and place the image segments, one to a layer  
   for (int i = 0; i <= segmentSpec.numSegments; i++)
   {
      NSString* assetPath = [[NSBundle mainBundle] pathForResource:segmentSpec.resource ofType:nil];
      
      if (![[NSFileManager defaultManager] fileExistsAtPath:assetPath])
      {
         ALog(@"Image segment file missing: %@", assetPath);
      }
      else
      {    
         CALayer* aLayer = [[CALayer alloc] init];
         result.layer = aLayer;
         [aLayer release];
         
         CGRect frame = segmentSpec.frame;
         
         result.layer.frame = frame;
         
         result.minX = frame.origin.x;
         result.maxX = frame.origin.x;
         
         result.closeTriggerX = segmentSpec.closeTriggerX;
         result.openTriggerX = segmentSpec.openTriggerX;
                  
         if (![@"" isEqualToString:segmentSpec.closeSound])
         {
            result.closeSound = segmentSpec.closeSound;
            
            [[OALSimpleAudio sharedInstance] preloadEffect:result.closeSound];
         }
         
         if (![@"" isEqualToString:segmentSpec.openSound])
         {
            result.openSound = segmentSpec.openSound;
            
            [[OALSimpleAudio sharedInstance] preloadEffect:result.openSound];
         }
         
         if (segmentSpec.hasMinX)
         {
            result.minX = segmentSpec.minX;
         }
         
         if (segmentSpec.hasMaxX)
         {
            result.maxX = segmentSpec.maxX;
         }
         
         if (segmentSpec.hasCollapseStartX)
         {
            result.collapseStartX = segmentSpec.collapseStartX;
         }
         
         if (segmentSpec.hasExtensionStartX)
         {
            result.extensionStartX = segmentSpec.extensionStartX;
         }
         
         UIImage* image = [[UIImage alloc] initWithContentsOfFile:assetPath];
         [result.layer setContents:(id)image.CGImage];
         [image release];
      }         
   }
   
   return result;   
} 

-(void)dealloc
{
   if (![@"" isEqualToString:self.closeSound])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:self.closeSound];
   }
   
   if (![@"" isEqualToString:self.openSound])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:self.openSound];
   }
   
   Release(fCloseSound);
   Release(fOpenSound);
   
   [super dealloc];
}

-(id)init
{
   if (self = [super init])
   {
      self.minX = 0.0;
      self.maxX = 0.0;
      self.collapseStartX = 0.0;
      self.extensionStartX = 0.0;
      self.lastDriverPosition = 0.0;
      self.closeSound = @"";
      self.closeSoundTriggered = NO;
      self.closeTriggerX = 0.0f;
      self.openSound = @"";
      self.openSoundTriggered = NO;
      self.openTriggerX = 1000.0f;
   }
   
   return self;
}

-(CGFloat)MoveDeltaX:(CGFloat)deltaX
{    
   CGPoint currentPosition = self.layer.position;
   
   CGFloat newX = currentPosition.x + deltaX;
   
   // clamp to min/max specified for this segment
   if (newX <= self.minX)
   {
      newX = self.minX;
   }
   else if (newX >= self.maxX)
   {
      newX = self.maxX;
   }
      
   currentPosition.x = newX;
   
   self.layer.position = currentPosition;
   
   if (0.0f == deltaX)
   {
      // no movement, just get out
      return newX;
   }
   
   BOOL movingLeft = deltaX<0.0f;
   
   if (movingLeft)
   {
      if (self.layer.position.x <= self.closeTriggerX)
      {
         if (!self.closeSoundTriggered)
         {
            if (![@"" isEqualToString:self.closeSound])
            {
               [[OALSimpleAudio sharedInstance] playEffect:self.closeSound];
            }
            
            self.closeSoundTriggered = YES;
            
            self.openSoundTriggered = NO;
         }
      }
   }
   else
   {
      if (self.layer.position.x >= self.openTriggerX)
      {
         if (!self.openSoundTriggered)
         {
            if (![@"" isEqualToString:self.openSound])
            {
               [[OALSimpleAudio sharedInstance] playEffect:self.openSound];
            }
            
            self.openSoundTriggered = YES;
            
            self.closeSoundTriggered = NO;
         }
      }
   }
   
   return newX;
}

-(void)MoveDeltaX:(CGFloat)deltaX DependingOn:(CGFloat)driverPosition
{
   // if there's no change in position, just exit
   if (driverPosition == self.lastDriverPosition)
   {
      return;
   }
   
   // the first time through, just initialize lastDriverPosition
   if (driverPosition != 0.0 && self.lastDriverPosition == 0.0)
   {
      self.lastDriverPosition = driverPosition;
      
      return;
   }
   
   // moving left?
   if (driverPosition < self.lastDriverPosition)
   {      
      if (driverPosition <= self.collapseStartX)
      {
         // move this segment
         [self MoveDeltaX:deltaX];
      }
   }
   
   // moving right?
   else if (driverPosition > self.lastDriverPosition)
   {      
      if (driverPosition >= self.extensionStartX)
      {
         [self MoveDeltaX:deltaX];
      }
   }
   
   self.lastDriverPosition = driverPosition;
}

@end
