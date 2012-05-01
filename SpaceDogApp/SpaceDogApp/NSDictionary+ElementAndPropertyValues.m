// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "NSDictionary+ElementAndPropertyValues.h"
#import "NSArray+PropertyValues.h"

@implementation NSDictionary (ElementAndPropertyValues)

-(NSArray*)elements
{
   return (NSArray*)[self valueForKey:@"elements"];
}

-(BOOL)isOnLayer
{
   BOOL result = NO;
   
   NSNumber* onLayerNumber = (NSNumber*)[self valueForKey:@"onLayer"];
   
   if (nil != onLayerNumber)
   {
      result = [onLayerNumber boolValue];
   }
   
   return result;
}

-(BOOL)isOnView
{
   BOOL result = NO;
   
   NSNumber* onViewNumber = (NSNumber*)[self valueForKey:@"onView"];
   
   if (nil != onViewNumber)
   {
      result = [onViewNumber boolValue];
   }
   
   return result;
}

-(BOOL)isPDFBased
{
   BOOL result = YES;
   
   NSNumber* pdfBasedNumber = (NSNumber*)[self valueForKey:@"pdfBased"];
   
   if (nil != pdfBasedNumber)
   {
      result = [pdfBasedNumber boolValue];
   }   
   
   return result;
}

-(NSArray*)pages
{
   return (NSArray*)[self valueForKey:@"pages"];
}

-(NSUInteger)numPages
{
   NSUInteger result = 0;
   
   NSNumber* numPagesNumber = [self objectForKey:@"numPages"];
   
   if (nil != numPagesNumber)
   {
      result = [numPagesNumber unsignedIntegerValue];
   }
   
   return result;
}

-(NSInteger)pageNumber
{
   NSInteger result = -1;
   
   NSNumber* pageNumberNumber = [self valueForKey:@"page"];
   
   if (nil != pageNumberNumber)
   {
      result = [pageNumberNumber integerValue];
   }
   
   return result;
}

-(BOOL)big
{
   BOOL result = NO;
   
   NSNumber* isBigNumber = [self valueForKey:@"big"];
   
   if (nil != isBigNumber)
   {
      result = [isBigNumber boolValue];
   }
   
   return result;
}

-(NSString*)type
{
   return (NSString*)[self valueForKey:@"type"];
}

-(NSArray*)types
{
   return (NSArray*)[self valueForKey:@"types"];
}

-(NSString*)assetType
{
   return (NSString*)[self valueForKey:@"assetType"];
}

-(NSArray*)propertyList
{
   return (NSArray*)[self valueForKey:@"propertyList"];
}

-(NSDictionary*)trigger
{
   return [self valueForKey:@"trigger"];
}

-(NSArray*)triggers
{
   return (NSArray*)[self valueForKey:@"triggers"];
}

-(NSInteger)dataValue
{
   NSInteger result = -1;
   
   NSNumber* dataValueNumber = [self valueForKey:@"dataValue"];
   
   if (nil != dataValueNumber)
   {
      result = [dataValueNumber integerValue];
   }
   
   return result;
}

-(BOOL)hasTrigger
{
   return nil != self.trigger;
}

-(BOOL)hasTriggers
{
   return nil != self.triggers;
}

-(BOOL)hasTriggerMethod
{
   return nil != [self valueForKey:@"triggerMethod"];
}

-(NSString*)triggerMethod
{
   NSString* result = @"";
   
   if (self.hasTriggerMethod)
   {
      result = [self valueForKey:@"triggerMethod"];
   }
   
   return result;
}

-(BOOL)allowsConcurrentTrigger
{
   BOOL result = NO;
   
   NSNumber* concurrentTriggerNumber = (NSNumber*)[self valueForKey:@"allowsConcurrentTrigger"];
   
   if (nil != concurrentTriggerNumber)
   {
      result = [concurrentTriggerNumber boolValue];
   }
   
   return result;
}

-(BOOL)hasShakeTrigger
{
   BOOL result = NO;
   
   if (self.hasAnimations)
   {
      for (NSDictionary* animationSpec in self.animations)
      {
         if (animationSpec.hasTrigger)
         {
            if ([@"SHAKE" isEqualToString:animationSpec.trigger.type])
            {
               result = YES;
               
               break;
            }
         }
      }
   }
      
   return result;
}

-(NSArray*)shakeTriggeredAnimations
{
   NSIndexSet* indexesOfAnimationsWithShakeTriggers = [self.animations indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL* stop) {
      
      NSDictionary* animationSpec = (NSDictionary*)obj;
      
      BOOL result = NO;
      
      if (animationSpec.hasTrigger)
      {
         if ([@"SHAKE" isEqualToString:animationSpec.trigger.type])
         {
            result = YES;
         }
      }
      
      return result;
   }];
   
   return [self.animations objectsAtIndexes:indexesOfAnimationsWithShakeTriggers];
}

-(CGFloat)shakeThreshold
{
   CGFloat result = 0.5f;  // this is a safe default
   
   NSNumber* thresholdNumber = [self valueForKey:@"shakeThreshold"];
   
   if (nil != thresholdNumber)
   {
      result = [thresholdNumber floatValue];
   }
   
   return result;
}

-(BOOL)hasTiltTrigger
{
   BOOL result = NO;
   
   if (self.hasTrigger)
   {
      NSDictionary* triggerSpec = self.trigger;
      
      NSString* triggerType = (NSString*)[triggerSpec valueForKey:@"type"];
      
      if (nil != triggerType && [@"TILT" isEqualToString:triggerType])
      {
         result = YES;
      }
   }
   
   return result;
}

-(CGFloat)triggerAngle
{
   CGFloat result = 0.0f;
   
   NSNumber* triggerAngleNumber = [self valueForKey:@"triggerAngle"];
   
   if (nil != triggerAngleNumber)
   {
      result = [triggerAngleNumber floatValue];
   }
   
   return result;
}

-(NSUInteger)numberOfTouchesRequired
{
   NSUInteger result = 1;
   
   NSNumber* numberOfTouchesNumber = [self valueForKey:@"numberOfTouchesRequired"];
   
   if (nil != numberOfTouchesNumber)
   {
      result = [numberOfTouchesNumber unsignedIntegerValue];
   }
   
   return result;
}

-(NSString*)swipeDirection
{
   NSString* result = @"DOWN";
   
   if (nil != [self valueForKey:@"swipeDirection"])
   {
      result = [self valueForKey:@"swipeDirection"];
   }
   
   return result;
}

-(NSString*)tiltNotificationEvent
{
   NSString* result = @"DIRECTIONAL_CHANGE";
   
   if (nil != [self valueForKey:@"tiltNotificationEvent"])
   {
      result = (NSString*)[self valueForKey:@"tiltNotificationEvent"];
   }
   
   return result;
}

-(NSString*)animationType
{
   NSString* result = @"SEQUENTIAL";
   
   if (nil != [self valueForKey:@"animationType"])
   {
      result = [self valueForKey:@"animationType"];
   }
   
   return result;
}

-(NSString*)animationGroup
{
   return [self valueForKey:@"animationGroup"];
}

-(BOOL)hasSequences
{
   return nil != self.sequences;
}

-(NSArray*)sequences
{
   return (NSArray*)[self valueForKey:@"sequences"];
}

-(int)numFrames
{
   int result = 0;
   
   NSNumber* numFramesNumber = (NSNumber*)[self valueForKey:@"numFrames"];
   
   if (nil != numFramesNumber)
   {
      result = [numFramesNumber intValue];
   }
   
   return result;
}

-(NSArray*)regions
{
   return (NSArray*)[self valueForKey:@"regions"];
}

-(BOOL)hasRepeatType
{
   return nil != [self valueForKey:@"repeatType"];
}

-(NSString*)repeatType
{
   NSString* result = @"NONE";
   
   if (self.hasRepeatType)
   {
      result = (NSString*)[self valueForKey:@"repeatType"];
   }
   
   return result;
}

-(BOOL)hasNumRepeats
{
   return nil != [self valueForKey:@"numRepeats"];
}

-(NSUInteger)numRepeats
{
   NSUInteger result = 0;
   
   NSNumber* numRepeatsNumber = (NSNumber*)[self valueForKey:@"numRepeats"];
   
   if (nil != numRepeatsNumber)
   {
      result = [numRepeatsNumber integerValue];
   }
   
   return result;
}

-(NSUInteger)numImages
{
   NSUInteger result = 0;
   
   NSNumber* numImagesNumber = (NSNumber*)[self valueForKey:@"numImages"];
   
   if (nil != numImagesNumber)
   {
      result = [numImagesNumber unsignedIntegerValue];
   }
   
   return result;
}

-(BOOL)hasSegments
{
   return nil != self.segments;
}

-(NSArray*)segments
{
   return (NSArray*)[self valueForKey:@"segments"];
}

-(int)numSegments
{
   int result = 0;
   
   if (self.hasSegments)
   {
      result = [self.segments count];
   }
   
   return result;
}

-(BOOL)isSequenced
{
   BOOL result = NO;
   
   NSNumber* isSequencedNumber = (NSNumber*)[self valueForKey:@"isSequenced"];
   
   if (nil != isSequencedNumber)
   {
      result = [isSequencedNumber boolValue];
   }
   
   return result;
}

-(NSString*)propertyId
{
   return [self valueForKey:@"id"];
}

-(BOOL)hasAnimationGroup
{
   return nil != [self objectForKey:@"animationGroup"];
}

-(BOOL)hasAnchorPoint
{
   return nil != [self valueForKey:@"anchorPoint"];
}

-(CGPoint)anchorPoint
{
   CGPoint result = CGPointZero;
   
   if (self.hasAnchorPoint)
   {
      id anchorPointEncoding = [self valueForKey:@"anchorPoint"];
      
      if ([anchorPointEncoding isKindOfClass:[NSArray class]])
      {
         result = [(NSArray*)anchorPointEncoding asCGPoint];
      }
      else // assume an NSString...
      {
         result = CGPointFromString((NSString*)anchorPointEncoding);
      }
   }
   
   return result;
}

-(BOOL)isResourceBased
{
   return nil != [self objectForKey:@"resource"];
}

-(NSString*)resource
{
   return (NSString*)[self valueForKey:@"resource"];
}

-(BOOL)isResourceBaseBased
{
   return nil != [self objectForKey:@"resourceBase"];
}

-(NSString*)resourceBase
{
   return (NSString*)[self valueForKey:@"resourceBase"];
}

-(NSArray*)resources
{
   return (NSArray*)[self valueForKey:@"resources"];
}

-(BOOL)hasFrame
{
   return nil != [self valueForKey:@"frame"];
}

-(CGRect)frame
{
   CGRect result = CGRectZero;
   
   if (self.hasFrame)
   {
      result = [(NSArray*)[self valueForKey:@"frame"] asCGRect];
   }
   
   return result;
}

-(BOOL)hasBounds
{
   return nil != [self valueForKey:@"bounds"];
}

-(CGRect)bounds
{
   CGRect result = CGRectZero;
   
   if (self.hasBounds)
   {
      result = [(NSArray*)[self valueForKey:@"bounds"] asCGRect];
   }
   
   return result;
}

-(NSString*)scrollMode
{
   NSString* result = @"kCAScrollNone";
   
   if (nil != [self valueForKey:@"scrollMode"])
   {
      result = (NSString*)[self valueForKey:@"scrollMode"];
   }
   
   return result;
}

-(CGFloat)scrollIncrement
{
   CGFloat result = 0.0f;
   
   NSNumber* scrollIncrementNumber = [self valueForKey:@"scrollIncrement"];
   
   if (nil != scrollIncrementNumber)
   {
      result = [scrollIncrementNumber floatValue];
   }
   
   return result;
}

-(CGFloat)updatePeriod
{
   CGFloat result = 0.0f;
   
   NSNumber* updatePeriodNumber = [self valueForKey:@"updatePeriod"];
   
   if (nil != updatePeriodNumber)
   {
      result = [updatePeriodNumber floatValue];
   }
   
   return result;
}

-(BOOL)hasViewFrame
{
   return nil != [self valueForKey:@"viewFrame"];
}

-(CGRect)viewFrame
{
   CGRect result = CGRectZero;
   
   if (self.hasViewFrame)
   {
      result = [(NSArray*)[self valueForKey:@"viewFrame"] asCGRect];
   }
   
   return result;
}

-(BOOL)hasInitialAlpha
{
   return nil != [self valueForKey:@"initialAlpha"];
}

-(CGFloat)initialAlpha
{
   CGFloat result = 1.0;
   
   if (nil != [self valueForKey:@"initialAlpha"])
   {
      result = [(NSNumber*)[self valueForKey:@"initialAlpha"] floatValue];
   }
   
   return result;
}

-(CGFloat)startAlpha
{
   CGFloat result = 1.0;
   
   if (nil != [self valueForKey:@"startAlpha"])
   {
      result = [(NSNumber*)[self valueForKey:@"startAlpha"] floatValue];
   }
   
   return result;
}

-(CGFloat)endAlpha
{
   CGFloat result = 1.0;
   
   if (nil != [self valueForKey:@"endAlpha"])
   {
      result = [(NSNumber*)[self valueForKey:@"endAlpha"] floatValue];
   }
   
   return result;
}

-(BOOL)hasDuration
{
   return nil != [self valueForKey:@"duration"];
}

-(CGFloat)duration
{
   CGFloat result = 0.0;
   
   if (nil != [self valueForKey:@"duration"])
   {
      result = [(NSNumber*)[self valueForKey:@"duration"] floatValue];
   }
   
   return result;
}

-(CGFloat)repeatDelay
{
   CGFloat result = 0.0;
   
   if (nil != [self valueForKey:@"repeatDelay"])
   {
      result = [(NSNumber*)[self valueForKey:@"repeatDelay"] floatValue];
   }
   
   return result;
}

-(CGFloat)repeatDelayMin
{
   CGFloat result = 0.0;
   
   if (nil != [self valueForKey:@"repeatDelayMin"])
   {
      result = [(NSNumber*)[self valueForKey:@"repeatDelayMin"] floatValue];
   }
   
   return result;
}

-(CGFloat)repeatDelayMax
{
   CGFloat result = 0.0;
   
   if (nil != [self valueForKey:@"repeatDelayMax"])
   {
      result = [(NSNumber*)[self valueForKey:@"repeatDelayMax"] floatValue];
   }
   
   return result;
}

-(BOOL)hasAutoReverse
{
   return nil != [self valueForKey:@"autoReverse"];
}

-(BOOL)autoReverse
{
   BOOL result = NO;
   
   NSNumber* autoReverseNumber = [self valueForKey:@"autoReverse"];
   
   if (nil != autoReverseNumber)
   {
      result = [autoReverseNumber boolValue];
   }
   
   return result;
}

-(CGFloat)reverseDelay
{
   CGFloat result = 0.0;
   
   if (nil != [self valueForKey:@"reverseDelay"])
   {
      result = [(NSNumber*)[self valueForKey:@"reverseDelay"] floatValue];
   }
   
   return result;
}

-(BOOL)hasTimingFunctionName
{
   return nil != [self valueForKey:@"timingFunctionName"];
}

-(NSString*)timingFunctionName
{
   NSString* result = @"";
   
   if (self.hasTimingFunctionName)
   {
      result = [self valueForKey:@"timingFunctionName"];
   }
   
   return result;
}

-(BOOL)hasContentsGravity
{
   return nil != [self valueForKey:@"contentsGravity"];
}

-(NSString*)contentsGravity
{
   return (NSString*)[self valueForKey:@"contentsGravity"];
}

-(BOOL)hasTransitions
{
   return nil != self.transitions;
}

-(NSArray*)transitions
{
   return (NSArray*)[self valueForKey:@"transitionsFrom"];
}

-(BOOL)isCustomAnimation
{
   return (nil != [self valueForKey:@"animationType"] && [@"CUSTOM" isEqualToString:[self valueForKey:@"animationType"]]);
}

-(NSString*)animationClass
{
   return [self valueForKey:@"animationClass"];
}

-(BOOL)isClassBased
{
   return nil != [self objectForKey:@"customClass"];
}

-(NSString*)customClass
{
   return [self valueForKey:@"customClass"];
}

-(NSDictionary*)creationSpec
{
   return (NSDictionary*)[self valueForKey:@"creationSpec"];
}

-(NSString*)createdBy
{
   return (NSString*)[self valueForKey:@"createdBy"];
}

-(BOOL)hasSoundEffect
{
   return nil != self.soundEffect;
}

-(NSDictionary*)soundEffect
{
   return (NSDictionary*)[self valueForKey:@"soundEffect"];
}

-(NSUInteger)minTouches
{
   NSUInteger result = 0;
   
   if (nil != [self valueForKey:@"minTouches"])
   {
      result = [(NSNumber*)[self valueForKey:@"minTouches"] unsignedIntegerValue];
   }
   
   return result;
}

-(NSUInteger)maxTouches
{
   NSUInteger result = 0;
   
   if (nil != [self valueForKey:@"maxTouches"])
   {
      result = [(NSNumber*)[self valueForKey:@"maxTouches"] unsignedIntegerValue];
   }
   
   return result;   
}

-(BOOL)hasPostAnimationNotification
{
   return nil != [self valueForKey:@"postAnimationNotification"];
}

-(NSString*)postAnimationNotification
{
   return (NSString*)[self valueForKey:@"postAnimationNotification"];
}

-(NSArray*)notifications
{
   return (NSArray*)[self valueForKey:@"notifications"];
}

-(NSString*)state
{
   NSString* result = (NSString*)[self valueForKey:@"state"];
   
   if (nil == result)
   {
      result = @"";
   }
   
   return result;
}

-(NSArray*)subAnimations
{
   if (nil != [self valueForKey:@"subAnimations"])
   {
      return (NSArray*)[self valueForKey:@"subAnimations"];
   }
   else 
   {
      return [NSArray array];
   }
}

-(CGFloat)startAngle
{
   CGFloat result = 0.0f;
   
   NSNumber* startAngleNumber = (NSNumber*)[self valueForKey:@"startAngle"];
   
   if (nil != startAngleNumber)
   {
      result = [startAngleNumber floatValue];
   }
   
   return result;
}

-(CGFloat)endAngle
{
   CGFloat result = 0.0f;
   
   NSNumber* endAngleNumber = (NSNumber*)[self valueForKey:@"endAngle"];
   
   if (nil != endAngleNumber)
   {
      result = [endAngleNumber floatValue];
   }
   
   return result;
}

-(BOOL)hasDelay
{
   return nil != [self valueForKey:@"delay"];
}

-(CGFloat)delay
{
   CGFloat result = 0.0f;
   
   NSNumber* delayNumber = (NSNumber*)[self valueForKey:@"delay"];
   
   if (nil != delayNumber)
   {
      result = [delayNumber floatValue];
   }
   
   return result;
}

-(BOOL)hasViewBasedAssets
{
   return nil != [self valueForKey:@"hasViewBasedAssets"];
}

-(BOOL)hasName
{
   return nil != [self valueForKey:@"name"];
}

-(NSString*)name
{
   NSString* result = [self valueForKey:@"name"];
   
   if (nil == result)
   {
      result = @"";
   }
   
   return result;
}

-(BOOL)hasToggleProperty
{
   return nil != [self valueForKey:@"isToggle"];
}

-(BOOL)toggle
{
   BOOL result = NO;
   
   NSNumber* togglePropertyNumber = [self valueForKey:@"isToggle"];
   
   if (nil != togglePropertyNumber)
   {
      result = [togglePropertyNumber boolValue];
   }
   
   return result;
}

-(NSArray*)resourceNames
{
   NSArray* result = (NSArray*)[self valueForKey:@"resourceNames"];
   
   if (nil == result)
   {
      result = [NSArray array];
   }
   
   return result;
}

#pragma mark Animation-specific properties
-(NSDictionary*)animationProperties
{
   return (NSDictionary*)[self valueForKey:@"animationProperties"];
}

-(NSString*)keyPath
{
   return (NSString*)[self valueForKey:@"keyPath"];
}

-(CGFloat)xDelta
{
   CGFloat result = 0.0f;
   
   NSNumber* deltaNumber = (NSNumber*)[self valueForKey:@"xDelta"];
   
   if (nil != deltaNumber)
   {
      result = [deltaNumber floatValue];
   }
   
   return result;
}

-(CGFloat)yDelta
{
   CGFloat result = 0.0f;
   
   NSNumber* deltaNumber = (NSNumber*)[self valueForKey:@"yDelta"];
   
   if (nil != deltaNumber)
   {
      result = [deltaNumber floatValue];
   }
   
   return result;
}

-(BOOL)updateToFinalPosition
{
   BOOL result = YES;
   
   NSNumber* updateNumber = [self valueForKey:@"updateToFinalPosition"];
   
   if (nil != updateNumber)
   {
      result = [updateNumber boolValue];
   }
   
   return result;
}

-(BOOL)updateToFinalValue
{
   BOOL result = YES;
   
   NSNumber* updateNumber = [self valueForKey:@"updateToFinalValue"];
   
   if (nil != updateNumber)
   {
      result = [updateNumber boolValue];
   }
   
   return result;
}

-(CGFloat)maximumExtension
{
   CGFloat result = 0.0f;
   
   NSNumber* maximumExtensionNumber = [self valueForKey:@"maximumExtension"];
   
   if (nil != maximumExtensionNumber)
   {
      result = [maximumExtensionNumber floatValue];
   }
   
   return result;
}

-(CGFloat)springTension
{
   CGFloat result = 0.0f;
   
   NSNumber* springTensionNumber = [self valueForKey:@"springTension"];
   
   if (nil != springTensionNumber)
   {
      result = [springTensionNumber floatValue];
   }
   
   return result;
}

#pragma mark PositionSensitivePendulum properties
-(double)omega
{
   double result = 0.0;
   
   NSNumber* resultNumber = (NSNumber*)[self valueForKey:@"omega"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber doubleValue];
   }
   
   return result;
}

-(double)zeta
{
   double result = 0.0;
   
   NSNumber* resultNumber = (NSNumber*)[self valueForKey:@"zeta"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber doubleValue];
   }
   
   return result;
}

-(double)startValueDouble
{
   double result = 0.0;
   
   NSNumber* resultNumber = (NSNumber*)[self valueForKey:@"startValue"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber doubleValue];
   }
   
   return result;
}

-(double)endValueDouble
{
   double result = 0.0;
   
   NSNumber* resultNumber = (NSNumber*)[self valueForKey:@"endValue"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber doubleValue];
   }
   
   return result;
}

-(NSUInteger)steps
{
   NSUInteger result = 0;
   
   NSNumber* stepsNumber = (NSNumber*)[self valueForKey:@"steps"];
   
   if (nil != stepsNumber)
   {
      result = [stepsNumber unsignedIntegerValue];
   }
   
   return result;
}

-(BOOL)hasAnimations
{
   return nil != self.animations;
}

-(NSArray*)animations
{
   return (NSArray*)[self valueForKey:@"animations"];
}

-(BOOL)hasMinX
{
   return nil != [self valueForKey:@"minX"];
}

-(CGFloat)minX
{
   CGFloat result = 0.0;
   
   if (self.hasMinX)
   {
      result = [(NSNumber*)[self valueForKey:@"minX"] floatValue];
   }
   
   return result;
}

-(BOOL)hasMinY
{
   return nil != [self valueForKey:@"minY"];
}

-(CGFloat)minY
{
   CGFloat result = 0.0;
   
   if (self.hasMinY)
   {
      result = [(NSNumber*)[self valueForKey:@"minY"] floatValue];
   }
   
   return result;
}

-(BOOL)hasCollapseStartX
{
   return nil != [self valueForKey:@"collapseStartX"];
}

-(CGFloat)collapseStartX
{
   CGFloat result = 0.0;
   
   if (self.hasCollapseStartX)
   {
      result = [(NSNumber*)[self valueForKey:@"collapseStartX"] floatValue];
   }
   
   return result;   
}

-(BOOL)hasMaxX
{
   return nil != [self valueForKey:@"maxX"];
}

-(CGFloat)maxX
{
   CGFloat result = 0.0;
   
   if (self.hasMaxX)
   {
      result = [(NSNumber*)[self valueForKey:@"maxX"] floatValue];
   }
   
   return result;
}

-(BOOL)hasMaxY
{
   return nil != [self valueForKey:@"maxY"];
}

-(CGFloat)maxY
{
   CGFloat result = 0.0;
   
   if (self.hasMaxY)
   {
      result = [(NSNumber*)[self valueForKey:@"maxY"] floatValue];
   }
   
   return result;
}

-(BOOL)hasExtensionStartX
{
   return nil != [self valueForKey:@"extensionStartX"];
}

-(CGFloat)extensionStartX
{
   CGFloat result = 0.0;
   
   if (self.hasExtensionStartX)
   {
      result = [(NSNumber*)[self valueForKey:@"extensionStartX"] floatValue];
   }
   
   return result;   
}

-(NSString*)closeSound
{
   return nil==[self valueForKey:@"closeSound"]?@"":[self valueForKey:@"closeSound"];
}

-(NSString*)openSound
{
   return nil==[self valueForKey:@"openSound"]?@"":[self valueForKey:@"openSound"]; 
}

-(CGFloat)closeTriggerX
{
   CGFloat result = 0.0;
   
   if (nil != [self valueForKey:@"closeTriggerX"])
   {
      result = [(NSNumber*)[self valueForKey:@"closeTriggerX"] floatValue];
   }
   
   return result;
}

-(CGFloat)openTriggerX
{
   CGFloat result = 0.0;
   
   if (nil != [self valueForKey:@"openTriggerX"])
   {
      result = [(NSNumber*)[self valueForKey:@"openTriggerX"] floatValue];
   }
   
   return result;
}

// ChapterMenu-specific properties
-(NSString*)scrollTopResource
{
   return (NSString*)[self valueForKey:@"scrollTopResource"];
}

-(CGRect)scrollTopFrame
{
   return [[self valueForKey:@"scrollTopFrame"] asCGRect];
}

-(NSString*)scrollBottomResource
{
   return (NSString*)[self valueForKey:@"scrollBottomResource"];
}

-(CGRect)scrollBottomFrame
{
   return [[self valueForKey:@"scrollBottomFrame"] asCGRect];
}

-(NSString*)scrollBackResource
{
   return (NSString*)[self valueForKey:@"scrollBackResource"];
}

-(CGRect)scrollBackFrame
{
   return [[self valueForKey:@"scrollBackFrame"] asCGRect];
}

-(CGFloat)scrollBackInitialHeight
{
   return (CGFloat)[(NSNumber*)[self valueForKey:@"scrollBackInitialHeight"] floatValue];
}

-(CGRect)scrollToggleHotspot
{
   return [[self valueForKey:@"scrollToggleHotspot"] asCGRect];
}

-(CGFloat)scrollTopMinY
{
   CGFloat result = 0.0f;
   
   NSNumber* resultNumber = [self valueForKey:@"scrollTopMinY"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber floatValue];
   }
   
   return result;
}

-(CGFloat)scrollTopMaxY
{
   CGFloat result = 0.0f;
   
   NSNumber* resultNumber = [self valueForKey:@"scrollTopMaxY"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber floatValue];
   }
   
   return result;
}

-(CGRect)scrollerFrame
{
   return [(NSArray*)[self valueForKey:@"scrollerFrame"] asCGRect];
}

-(CGFloat)dragMinX
{
   CGFloat result = 0.0f;
   
   NSNumber* resultNumber = [self valueForKey:@"dragMinX"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber floatValue];
   }
   
   return result;
}

-(CGFloat)dragMaxX
{
   CGFloat result = 0.0f;
   
   NSNumber* resultNumber = [self valueForKey:@"dragMaxX"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber floatValue];
   }
   
   return result;
}

-(CGRect)hotspot
{
   return [[self valueForKey:@"hotspot"] asCGRect];
}

-(NSArray*)helpDescriptors
{
   NSArray* result = nil;
   
   if (nil != [self valueForKey:@"helpDescriptors"])
   {
      result = [self valueForKey:@"helpDescriptors"];
   }
   else 
   {
      result = [NSArray array];
   }
   
   return result;
}

-(BOOL)autoStart
{
   BOOL result = NO;
   
   NSNumber* autoStartNumber = [self valueForKey:@"autoStart"];
   
   if (nil != autoStartNumber)
   {
      result = [autoStartNumber boolValue];
   }
   
   return result;
}

-(NSString*)arrowDirection
{
   NSString* result = @"LEFT";
   
   if (nil != [self valueForKey:@"arrowDirection"])
   {
      result = (NSString*)[self valueForKey:@"arrowDirection"];
   }
   
   return result;
}

-(BOOL)respectSequenceInProgress
{
   BOOL result = YES;
   
   NSNumber* respectSequenceInProgressNumber = (NSNumber*)[self valueForKey:@"respectSequenceInProgress"];
   
   if (nil != respectSequenceInProgressNumber)
   {
      result = [respectSequenceInProgressNumber boolValue];
   }
   
   return result;
}

-(BOOL)stepTriggerRequired
{
   BOOL result = NO;
   
   NSNumber* stepTriggerRequiredNumber = (NSNumber*)[self valueForKey:@"stepTriggerRequired"];
   
   if (nil != stepTriggerRequiredNumber)
   {
      result = [stepTriggerRequiredNumber boolValue];
   }
   
   return result;
}

-(BOOL)autoResetToBase
{
   BOOL result = NO;
   
   NSNumber* autoResetToBaseNumber = (NSNumber*)[self valueForKey:@"autoResetToBase"];
   
   if (nil != autoResetToBaseNumber)
   {
      result = [autoResetToBaseNumber boolValue];
   }
   
   return result;
}

// TopCloud-specific properties
-(CGFloat)stepMin
{
   CGFloat result = 0.0f;
   
   NSNumber* resultNumber = [self valueForKey:@"stepMin"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber floatValue];
   }
   
   return result;   
}

-(CGFloat)stepMax
{
   CGFloat result = 0.0f;
   
   NSNumber* resultNumber = [self valueForKey:@"stepMax"];
   
   if (nil != resultNumber)
   {
      result = [resultNumber floatValue];
   }
   
   return result;   
}

// MultipleImageSequence-specific properties
-(BOOL)hasPropertyEffects
{
   return nil != [self valueForKey:@"propertyEffects"];
}

-(NSArray*)propertyEffects
{
   return (NSArray*)[self valueForKey:@"propertyEffects"];
}

-(NSArray*)effects
{
   return (NSArray*)[self valueForKey:@"effects"];
}

-(NSNumber*)index 
{
   return (NSNumber*)[self valueForKey:@"index"];
}

-(NSString*)offset 
{
   return (NSString*)[self valueForKey:@"offset"];
}

-(NSString*)property
{
   return (NSString*)[self valueForKey:@"property"];
}

-(NSNumber*)fromValue
{
   return (NSNumber*)[self valueForKey:@"fromValue"];
}

-(NSString*)fromValueString
{
   return (NSString*)[self valueForKey:@"fromValue"];
}

-(NSNumber*)toValue
{
   return (NSNumber*)[self valueForKey:@"toValue"];
}

-(NSString*)toValueString
{
   return (NSString*)[self valueForKey:@"toValue"];
}

-(BOOL)oneShot
{
   BOOL result = NO;
   
   NSNumber* oneShotNumber = [self valueForKey:@"oneShot"];
   
   if (nil != oneShotNumber)
   {
      result = [oneShotNumber boolValue];
   }
   
   return result;
}

-(BOOL)hasPostExecutionNotification
{
   return nil != [self valueForKey:@"postExecutionNotification"];
}

-(NSString*)postExecutionNotification
{
   NSString* result = @"";
   
   if (self.hasPostExecutionNotification)
   {
      result = (NSString*)[self valueForKey:@"postExecutionNotification"];
   }
   
   return result;
}

-(NSString*)completionNotification
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"completionNotification"])
   {
      result = (NSString*)[self valueForKey:@"completionNotification"];
   }
   
   return result;   
}

-(NSString*)inPlayNotification
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"inPlayNotification"])
   {
      result = (NSString*)[self valueForKey:@"inPlayNotification"];
   }
   
   return result;
}

-(NSUInteger)inPlayNotificationIndex
{
   NSUInteger result = NSUIntegerMax;
   
   NSNumber* inPlayNotificationIndexNumber = [self valueForKey:@"inPlayNotificationIndex"];
   
   if (nil != inPlayNotificationIndexNumber)
   {
      result = [inPlayNotificationIndexNumber unsignedIntegerValue];
   }
   
   return result;
}

-(NSString*)imageIndices
{
   NSString* result = @"{0,0}";
   
   if (nil != [self valueForKey:@"imageIndices"])
   {
      result = [self valueForKey:@"imageIndices"];
   }
   
   return result;
}

// AmbientSound-specific properties
-(NSInteger)numLoops
{
   NSInteger result = 0;
   
   NSNumber* numLoopsNumber = (NSNumber*)[self valueForKey:@"numLoops"];
   
   if (nil != numLoopsNumber)
   {
      result = [numLoopsNumber integerValue];
   }
   
   return result;
}

-(CGFloat)fadeInDuration
{
   CGFloat result = 1.0f;
   
   NSNumber* fadeInDurationNumber = (NSNumber*)[self valueForKey:@"fadeInDuration"];
   
   if (nil != fadeInDurationNumber)
   {
      result = [fadeInDurationNumber floatValue];
   }
   
   return result; 
}

-(CGFloat)fadeInGain
{
   CGFloat result = 1.0f;
   
   NSNumber* fadeInGainNumber = (NSNumber*)[self valueForKey:@"fadeInGain"];
   
   if (nil != fadeInGainNumber)
   {
      result = [fadeInGainNumber floatValue];
   }
   
   return result;   
}

-(CGFloat)fadeOutDuration
{
   CGFloat result = 1.0f;
   
   NSNumber* fadeOutDurationNumber = (NSNumber*)[self valueForKey:@"fadeOutDuration"];
   
   if (nil != fadeOutDurationNumber)
   {
      result = [fadeOutDurationNumber floatValue];
   }
   
   return result;   
}

-(CGFloat)fadeOutGain
{
   CGFloat result = 0.0f;
   
   NSNumber* fadeOutGainNumber = (NSNumber*)[self valueForKey:@"fadeOutGain"];
   
   if (nil != fadeOutGainNumber)
   {
      result = [fadeOutGainNumber floatValue];
   }
   
   return result;   
}

-(CGFloat)maxDuration
{
   CGFloat result = CGFLOAT_MAX;
   
   NSNumber* maxDurationNumber = (NSNumber*)[self valueForKey:@"maxDuration"];
   
   if (nil != maxDurationNumber)
   {
      result = [maxDurationNumber floatValue];
   }
   
   return result;   
}

-(BOOL)preload
{
   BOOL result = YES;
   
   NSNumber* preloadNumber = (NSNumber*)[self valueForKey:@"preload"];
   
   if (nil != preloadNumber)
   {
      result = [preloadNumber boolValue];
   }
   
   return result;
}

-(BOOL)preloadAsync
{
   BOOL result = YES;
   
   NSNumber* preloadAsyncNumber = (NSNumber*)[self valueForKey:@"preloadAsync"];
   
   if (nil != preloadAsyncNumber)
   {
      result = [preloadAsyncNumber boolValue];
   }
   
   return result;   
}

-(BOOL)playAsync
{
   BOOL result = NO;
   
   NSNumber* playAsyncNumber = (NSNumber*)[self valueForKey:@"playAsync"];
   
   if (nil != playAsyncNumber)
   {
      result = [playAsyncNumber boolValue];
   }
   
   return result;   
}

-(CGFloat)accelerometerSampleRate
{
   CGFloat result = 60.0f;
   
   NSNumber* sampleRateNumber = [self valueForKey:@"accelerometerSampleRate"];
   
   if (nil != sampleRateNumber)
   {
      result = [sampleRateNumber floatValue];
   }
   
   return result;
}

-(BOOL)unpatterned
{
   BOOL result = NO;
   
   NSNumber* unpatternedNumber = [self valueForKey:@"unpatterned"];
   
   if (nil != unpatternedNumber)
   {
      result = [unpatternedNumber boolValue];
   }
   
   return result;
}

-(NSUInteger)initialFrame
{
   NSUInteger result = 0;
   
   NSNumber* initialFrameNumber = [self valueForKey:@"initialFrame"];
   
   if (nil != initialFrameNumber)
   {
      result = [initialFrameNumber unsignedIntegerValue];
   }   
   
   return result;
}

// TorchAndEyes-specific properties
-(NSDictionary*)torchLayer
{
   return (NSDictionary*)[self valueForKey:@"torchLayer"];
}

-(NSDictionary*)darknessLayer
{
   return (NSDictionary*)[self valueForKey:@"darknessLayer"];
}

-(NSString*)backgroundImage
{
   return (NSString*)[self valueForKey:@"backgroundImage"];
}

-(NSUInteger)eyePairs
{
   NSUInteger result = 0;
   
   NSNumber* eyePairsNumber = [self valueForKey:@"eyePairs"];
   
   if (nil != eyePairsNumber)
   {
      result = [eyePairsNumber unsignedIntegerValue];
   }
   
   return result;
}

-(NSDictionary*)eyePairSpecForIndex:(NSUInteger)index
{
   NSString* specKey = [NSString stringWithFormat:@"eyes%d", index];
   
   return (NSDictionary*)[self valueForKey:specKey];
}

-(NSDictionary*)torchSpec
{
   return (NSDictionary*)[self valueForKey:@"torch"];
}

-(NSDictionary*)torchSoundEffect
{
   return (NSDictionary*)[self valueForKey:@"torchSoundEffect"];
}

// LockAndKey-specific properties
-(NSDictionary*)leftLockLayer
{
   return (NSDictionary*)[self valueForKey:@"leftLockLayer"];
}

-(NSDictionary*)innerLockLayer
{
   return (NSDictionary*)[self valueForKey:@"innerLockLayer"];
}

-(NSDictionary*)rightLockLayer
{
   return (NSDictionary*)[self valueForKey:@"rightLockLayer"];
}

-(NSDictionary*)keyLayer
{
   return (NSDictionary*)[self valueForKey:@"keyLayer"];
}

-(NSDictionary*)barLayer
{
   return (NSDictionary*)[self valueForKey:@"barLayer"];
}

-(CGFloat)lockThreshold
{
   CGFloat result = 0.0f;
   
   NSNumber* thresholdNumber = (NSNumber*)[self valueForKey:@"lockThreshold"];
   
   if (nil != thresholdNumber)
   {
      result = [thresholdNumber floatValue];
   }
   
   return result;
}

-(CGFloat)unlockThreshold
{
   CGFloat result = 0.0f;
   
   NSNumber* thresholdNumber = (NSNumber*)[self valueForKey:@"unlockThreshold"];
   
   if (nil != thresholdNumber)
   {
      result = [thresholdNumber floatValue];
   }
   
   return result;   
}

-(NSString*)unlockSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"unlockSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"unlockSoundEffect"];
   }
   
   return result;
}

-(NSString*)lockSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"lockSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"lockSoundEffect"];
   }
   
   return result;
}

// ShipSailsAndPully-specific properties
-(NSDictionary*)bottomFrontSail
{
   return (NSDictionary*)[self valueForKey:@"bottomFrontSail"];
}

-(NSDictionary*)bottomMiddleSail
{
   return (NSDictionary*)[self valueForKey:@"bottomMiddleSail"];
}

-(NSDictionary*)bottomRearSail
{
   return (NSDictionary*)[self valueForKey:@"bottomRearSail"];
}

-(NSDictionary*)hookLayer
{
   return (NSDictionary*)[self valueForKey:@"hookLayer"];
}

-(NSDictionary*)centerFrontLayer
{
   return (NSDictionary*)[self valueForKey:@"centerFrontLayer"];
}

-(NSDictionary*)centerMiddleLayer
{
   return (NSDictionary*)[self valueForKey:@"centerMiddleLayer"];
}

-(NSDictionary*)centerRearLayer
{
   return (NSDictionary*)[self valueForKey:@"centerRearLayer"];
}

-(NSDictionary*)topFrontLayer
{
   return (NSDictionary*)[self valueForKey:@"topFrontLayer"];
}

-(NSDictionary*)topMiddleLayer
{
   return (NSDictionary*)[self valueForKey:@"topMiddleLayer"];
}

-(NSDictionary*)topRearLayer
{
   return (NSDictionary*)[self valueForKey:@"topRearLayer"];
}

-(CGFloat)furlThreshold
{
   CGFloat result = 0.0f;
   
   NSNumber* thresholdNumber = (NSNumber*)[self valueForKey:@"furlThreshold"];
   
   if (nil != thresholdNumber)
   {
      result = [thresholdNumber floatValue];
   }
   
   return result;
}

-(CGFloat)unfurlThreshold
{
   CGFloat result = 0.0f;
   
   NSNumber* thresholdNumber = (NSNumber*)[self valueForKey:@"unfurlThreshold"];
   
   if (nil != thresholdNumber)
   {
      result = [thresholdNumber floatValue];
   }
   
   return result;
}

-(NSDictionary*)unfurlSoundEffect
{
   return (NSDictionary*)[self valueForKey:@"unfurlSoundEffect"];
}

-(NSDictionary*)furlSoundEffect
{
   return (NSDictionary*)[self valueForKey:@"furlSoundEffect"];
}

// ToyBoat-specific properties
-(NSDictionary*)islandLayer
{
   return (NSDictionary*)[self valueForKey:@"islandLayer"];
}

-(NSDictionary*)boatLayer
{
   return (NSDictionary*)[self valueForKey:@"boatLayer"];
}

-(NSDictionary*)waterLayer
{
   return (NSDictionary*)[self valueForKey:@"waterLayer"];
}

-(NSDictionary*)springAnimation
{
   return (NSDictionary*)[self valueForKey:@"springAnimation"];
}

-(NSString*)shipPlunkSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"shipPlunkSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"shipPlunkSoundEffect"];
   }
   
   return result;
}

// RandomNotificationGenerator properties
-(NSString*)notificationNameBase
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"notificationNameBase"])
   {
      result = (NSString*)[self valueForKey:@"notificationNameBase"];
   }
   
   return result;
}

-(NSArray*)suffixes
{
   NSArray* result = nil;
   
   if (nil != [self valueForKey:@"suffixes"])
   {
      result = (NSArray*)[self valueForKey:@"suffixes"];
   }
   else 
   {
      result = [NSArray array];
   }
   
   return result;
}

-(CGFloat)minDelay
{
   CGFloat result = 0.0f;
   
   NSNumber* delayNumber = (NSNumber*)[self valueForKey:@"minDelay"];
   
   if (nil != delayNumber)
   {
      result = [delayNumber floatValue];
   }
   
   return result;
}

-(CGFloat)maxDelay
{
   CGFloat result = 0.0f;
   
   NSNumber* delayNumber = (NSNumber*)[self valueForKey:@"maxDelay"];
   
   if (nil != delayNumber)
   {
      result = [delayNumber floatValue];
   }
   
   return result;   
}

-(NSDictionary*)skyLayer
{
   return (NSDictionary*)[self valueForKey:@"skyLayer"];
}

-(NSDictionary*)sunLayer
{
   return (NSDictionary*)[self valueForKey:@"sunLayer"];
}

-(NSDictionary*)foregroundLayer
{
   return (NSDictionary*)[self valueForKey:@"foregroundLayer"];
}

-(NSDictionary*)blackLayer
{
   return (NSDictionary*)[self valueForKey:@"blackLayer"];
}

-(NSDictionary*)theEndLayer
{
   return (NSDictionary*)[self valueForKey:@"theEndLayer"];
}

-(NSArray*)pirates
{
   return (NSArray*)[self valueForKey:@"pirates"];
}

// Ben Gunn Eyes-spot properties
-(NSDictionary*)socketLayer
{
   return (NSDictionary*)[self valueForKey:@"socketLayer"];
}

-(NSDictionary*)eyesLayer
{
   return (NSDictionary*)[self valueForKey:@"eyesLayer"];
}

// Compass-spot properties
-(NSDictionary*)compassLayer
{
   return (NSDictionary*)[self valueForKey:@"compassLayer"];
}

-(NSDictionary*)needleLayer
{
   return (NSDictionary*)[self valueForKey:@"needleLayer"];
}

// Pipe-spot properties
-(NSDictionary*)pipeLayer
{
   return (NSDictionary*)[self valueForKey:@"pipeLayer"];
}

-(NSDictionary*)tobaccoLayer
{
   return (NSDictionary*)[self valueForKey:@"tobaccoLayer"];
}

-(NSDictionary*)flameLayer
{
   return (NSDictionary*)[self valueForKey:@"flameLayer"];
}

-(NSDictionary*)smokeLayer
{
   return (NSDictionary*)[self valueForKey:@"smokeLayer"];
}

-(CGRect)dropZone
{
   CGRect result = CGRectZero;
   
   if (nil != [self valueForKey:@"dropZone"])
   {
      result = [(NSArray*)[self valueForKey:@"dropZone"] asCGRect];
   }
   
   return result;
}

// JimAtTheHelm properties
-(NSDictionary*)wheelLayer
{
   return (NSDictionary*)[self valueForKey:@"wheelLayer"];
}

-(NSDictionary*)helmLayer
{
   return (NSDictionary*)[self valueForKey:@"helmLayer"];
}

-(NSDictionary*)sailPortLayer
{
   return (NSDictionary*)[self valueForKey:@"sailPortLayer"];
}

-(NSDictionary*)sailStarbordLayer
{
   return (NSDictionary*)[self valueForKey:@"sailStarbordLayer"];
}

-(NSDictionary*)ropeStaticLayer
{
   return (NSDictionary*)[self valueForKey:@"ropeStaticLayer"];
}

-(NSDictionary*)ropeCWLayer
{
   return (NSDictionary*)[self valueForKey:@"ropeCWLayer"];
}

-(NSDictionary*)ropeCCWLayer
{
   return (NSDictionary*)[self valueForKey:@"ropeCCWLayer"];
}

-(CGFloat)yMovementThreshold
{
   CGFloat result = CGFLOAT_MAX;
   
   NSNumber* thresholdNumber = [self valueForKey:@"yMovementThreshold"];
   
   if (nil != thresholdNumber)
   {
      result = [thresholdNumber floatValue];
   }
   
   return result;
}

-(NSString*)wheelSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"wheelSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"wheelSoundEffect"];
   }
               
   return result;
}

// RumBottle-specific properties
-(NSDictionary*)sloshingSequence1
{
   return (NSDictionary*)[self valueForKey:@"sloshingSequence1"];
}

-(NSDictionary*)sloshingSequence2
{
   return (NSDictionary*)[self valueForKey:@"sloshingSequence2"];
}

-(NSString*)rumBottleSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"rumBottleSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"rumBottleSoundEffect"];
   }
   
   return result;
}

// RollingBottle-specific properties
-(NSDictionary*)rollingSequences
{
   return (NSDictionary*)[self valueForKey:@"rollingSequences"];
}

-(NSString*)singleTurnSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"singleTurnSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"singleTurnSoundEffect"];
   }
   
   return result;
}

-(NSString*)l2RSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"l2RSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"l2RSoundEffect"];
   }
   
   return result;
}

-(NSString*)r2LSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"r2LSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"r2LSoundEffect"];
   }
   
   return result;
}

// Cups properties
-(NSDictionary*)leftCupLayer
{
   return (NSDictionary*)[self valueForKey:@"leftCupLayer"];
}

-(NSDictionary*)rightCupLayer
{
   return (NSDictionary*)[self valueForKey:@"rightCupLayer"];
}

-(NSString*)cupSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"cupSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"cupSoundEffect"];
   }
   
   return result;
}

// RoughSeas properties
-(NSDictionary*)borderLayer
{
   return (NSDictionary*)[self valueForKey:@"borderLayer"];
}

-(NSDictionary*)shipLayer
{
   return (NSDictionary*)[self valueForKey:@"shipLayer"];
}

-(NSDictionary*)seaLayer
{
   return (NSDictionary*)[self valueForKey:@"seaLayer"];
}

-(NSDictionary*)flickeringLightLayer
{
   return (NSDictionary*)[self valueForKey:@"flickeringLightLayer"];
}

-(NSDictionary*)choppyWave1Layer
{
   return (NSDictionary*)[self valueForKey:@"choppyWave1Layer"];
}

-(NSDictionary*)choppyWave2Layer
{
   return (NSDictionary*)[self valueForKey:@"choppyWave2Layer"];
}

// CreditsPage properties
-(NSDictionary*)chimneySmokeLayer
{
   return (NSDictionary*)[self valueForKey:@"chimneySmokeLayer"];
}

-(NSDictionary*)creditsLayer
{
   return (NSDictionary*)[self valueForKey:@"creditsLayer"];
}

-(NSArray*)creditSpecs
{
   return (NSArray*)[self valueForKey:@"creditSpecs"];
}

-(CGFloat)timeOffset
{
   CGFloat result = 0.0f;
   
   NSNumber* timeOffsetNumber = (NSNumber*)[self valueForKey:@"timeOffset"];
   
   if (nil != timeOffsetNumber)
   {
      result = [timeOffsetNumber floatValue];
   }
   
   return result;
}

-(CGFloat)animationDuration
{
   CGFloat result = 0.0f;
   
   NSNumber* durationNumber = (NSNumber*)[self valueForKey:@"animationDuration"];
   
   if (nil != durationNumber)
   {
      result = [durationNumber floatValue];
   }
   
   return result;
}

-(CGFloat)scrollDuration
{
   CGFloat result = 0.0f;
   
   NSNumber* durationNumber = (NSNumber*)[self valueForKey:@"scrollDuration"];
   
   if (nil != durationNumber)
   {
      result = [durationNumber floatValue];
   }
   
   return result;
}

-(CGFloat)displayDuration
{
   CGFloat result = 0.0f;
   
   NSNumber* durationNumber = (NSNumber*)[self valueForKey:@"displayDuration"];
   
   if (nil != durationNumber)
   {
      result = [durationNumber floatValue];
   }
   
   return result;
}

-(NSDictionary*)skipIntroButton
{
   return (NSDictionary*)[self valueForKey:@"skipIntroButton"];
}

-(NSDictionary*)beginBookButton
{
   return (NSDictionary*)[self valueForKey:@"beginBookButton"];
}

-(NSString*)bottomImageResource
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"bottomImageResource"])
   {
      result = [self valueForKey:@"bottomImageResource"];
   }
   
   return result;
}

-(NSString*)topImageResource
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"topImageResource"])
   {
      result = [self valueForKey:@"topImageResource"];
   }
   
   return result;
}

-(NSDictionary*)blackDog1Layer
{
   return (NSDictionary*)[self valueForKey:@"blackDog1Layer"];
}

-(NSDictionary*)porter1Layer
{
   return (NSDictionary*)[self valueForKey:@"porter1Layer"];
}

-(NSDictionary*)blackDog2Layer
{
   return (NSDictionary*)[self valueForKey:@"blackDog2Layer"];
}

-(NSDictionary*)porter2Layer
{
   return (NSDictionary*)[self valueForKey:@"porter2Layer"];
}

-(NSDictionary*)blackDogAndPorter1Layer
{
   return (NSDictionary*)[self valueForKey:@"blackDogAndPorter1Layer"];
}

-(NSDictionary*)blackDogAndPorter2Layer
{
   return (NSDictionary*)[self valueForKey:@"blackDogAndPorter2Layer"];
}

-(NSDictionary*)tree1Layer
{
   return (NSDictionary*)[self valueForKey:@"tree1Layer"];
}

-(NSDictionary*)trees2Layer
{
   return (NSDictionary*)[self valueForKey:@"trees2Layer"];
}

-(NSArray*)pathPoints
{
   NSMutableArray* result = nil;
   
   if (nil != [self valueForKey:@"pathPoints"])
   {
      NSArray* specArray = (NSArray*)[self valueForKey:@"pathPoints"];
      
      result = [NSMutableArray arrayWithCapacity:[specArray count]];
      
      for (NSString* pointString in specArray)
      {
         [result addObject:[NSValue valueWithCGPoint:CGPointFromString(pointString)]];
      }
   }
   
   return result;
}

-(CGPoint)finalPosition
{
   CGPoint result = CGPointZero;
   
   if (nil != [self valueForKey:@"finalPosition"])
   {
      result = CGPointFromString([self valueForKey:@"finalPosition"]);
   }
   
   return result;
}

// ASeagull properties
-(NSDictionary*)seagullLayer
{
   return (NSDictionary*)[self valueForKey:@"seagullLayer"];
}

-(CGFloat)fadeThreshold
{
   CGFloat result = 0.0f;
   
   NSNumber* fadeThresholdNumber = [self valueForKey:@"fadeThreshold"];
   if (nil != fadeThresholdNumber)
   {
      result = [fadeThresholdNumber floatValue];
   }
   
   return result;
}

// AGoldSwipe properties
-(NSDictionary*)swipe1Layer
{
   return (NSDictionary*)[self valueForKey:@"swipe1Layer"];
}

-(NSDictionary*)swipe2Layer
{
   return (NSDictionary*)[self valueForKey:@"swipe2Layer"];
}

// ALink properties
-(NSString*)address
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"address"])
   {
      result = (NSString*)[self valueForKey:@"address"];
   }
   
   return result;
}

// Trigger properties
-(CGFloat)interval
{
   CGFloat result = 0.0f;
   
   NSNumber* intervalNumber = (NSNumber*)[self valueForKey:@"interval"];
   
   if (nil != intervalNumber)
   {
      result = [intervalNumber floatValue];
   }
   
   return result;
}

-(BOOL)repeats
{
   BOOL result = NO;
   
   NSNumber* repeatsNumber = (NSNumber*)[self valueForKey:@"repeats"];
   
   if (nil != repeatsNumber)
   {
      result = [repeatsNumber boolValue];
   }
   
   return result;
}

-(BOOL)hasGatedProperty
{
   return nil != [self valueForKey:@"gated"];
}

-(BOOL)gated
{
   BOOL result = NO;
   
   NSNumber* gatedNumber = (NSNumber*)[self valueForKey:@"gated"];
   
   if (nil != gatedNumber)
   {
      result = [gatedNumber boolValue];
   }
   
   return result;
}

-(NSString*)enablingNotification
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"enablingNotification"])
   {
      result = (NSString*)[self valueForKey:@"enablingNotification"];
   }
   
   return result;
}

-(NSString*)disablingNotification
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"disablingNotification"])
   {
      result = (NSString*)[self valueForKey:@"disablingNotification"];
   }
   
   return result;
}

-(BOOL)autoBecomeAccelerometerDelegate
{
   BOOL result = NO;
   
   NSNumber* autoBecomeNumber = [self valueForKey:@"autoBecomeAccelerometerDelegate"];
   
   if (nil != autoBecomeNumber)
   {
      result = [autoBecomeNumber boolValue];
   }
   
   return result;
}

// ACargoAndPully properties
-(NSDictionary*)cargoView
{
   return (NSDictionary*)[self valueForKey:@"cargoView"];
}

-(NSString*)cargoDownSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"cargoDownSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"cargoDownSoundEffect"];
   }
   
   return result;
}

-(NSString*)cargoUpSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"cargoUpSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"cargoUpSoundEffect"];
   }
   
   return result;   
}

// AVines properties
-(NSDictionary*)leftVine
{
   return (NSDictionary*)[self valueForKey:@"leftVine"];
}

-(NSDictionary*)rightVine
{
   return (NSDictionary*)[self valueForKey:@"rightVine"];
}

// ABoatAndStuff properties
-(NSDictionary*)stuffLayer
{
   return (NSDictionary*)[self valueForKey:@"stuffLayer"];
}

// AWarAtSea properties
-(NSDictionary*)backgroundLayer
{
   return (NSDictionary*)[self valueForKey:@"backgroundLayer"];
}

-(NSDictionary*)wavesLayer
{
   return (NSDictionary*)[self valueForKey:@"wavesLayer"];
}

-(NSDictionary*)smolletAnimation
{
   return (NSDictionary*)[self valueForKey:@"smolletAnimation"];
}

-(NSDictionary*)rifleHammerAnimation
{
   return (NSDictionary*)[self valueForKey:@"rifleHammerAnimation"];
}

-(NSDictionary*)muzzleFlashAnimation
{
   return (NSDictionary*)[self valueForKey:@"muzzleFlashAnimation"];
}

-(NSDictionary*)muzzleSmokeAnimation
{
   return (NSDictionary*)[self valueForKey:@"muzzleSmokeAnimation"];
}

// ACoins properties
-(NSDictionary*)coin1
{
   return (NSDictionary*)[self valueForKey:@"coin1"];
}

-(NSDictionary*)coin2
{
   return (NSDictionary*)[self valueForKey:@"coin2"];
}

-(NSDictionary*)coin3
{
   return (NSDictionary*)[self valueForKey:@"coin3"];
}

-(NSDictionary*)coin4
{
   return (NSDictionary*)[self valueForKey:@"coin4"];
}

-(NSDictionary*)coin5
{
   return (NSDictionary*)[self valueForKey:@"coin5"];
}

// ABobbingPainter properties
-(NSDictionary*)bobbingShipLayer
{
   return (NSDictionary*)[self valueForKey:@"bobbingShipLayer"];
}

-(NSDictionary*)painterAnimation
{
   return (NSDictionary*)[self valueForKey:@"painterAnimation"];   
}

// AWindows properties
-(NSArray*)windowSpecs
{
   return (NSArray*)[self valueForKey:@"windowSpecs"];
}

-(NSString*)windowCoordinates
{
   return (NSString*)[self valueForKey:@"windowCoordinates"];
}

-(NSString*)frameKeyTemplate
{
   return (NSString*)[self valueForKey:@"frameKeyTemplate"];
}

// ASmollet properties
-(NSDictionary*)smolletLayer
{
   return (NSDictionary*)[self valueForKey:@"smolletLayer"];
}

-(NSDictionary*)swordAnimation
{
   return (NSDictionary*)[self valueForKey:@"swordAnimation"];
}

-(NSDictionary*)swordGleam
{
   return (NSDictionary*)[self valueForKey:@"swordGleam"];
}

-(NSDictionary*)hatLayer
{
   return (NSDictionary*)[self valueForKey:@"hatLayer"];
}

// TurnSpec properties
-(NSArray*)turnSpecs
{
   NSArray* result = nil;
   
   if (nil != [self valueForKey:@"turnSpecs"])
   {
      result = [self valueForKey:@"turnSpecs"];
   }
   else
   {
      result = [NSArray array];
   }
   
   return result;
}

-(CGFloat)startTime
{
   CGFloat result = 0.0f;
   
   NSNumber* startTimeNumber = [self valueForKey:@"startTime"];
   
   if (nil != startTimeNumber)
   {
      result = [startTimeNumber floatValue];
   }
   
   return result;
}

-(NSString*)layerName
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"layerName"])
   {
      result = (NSString*)[self valueForKey:@"layerName"];
   }
   
   return result;
}

-(CGFloat)rotation
{
   CGFloat result = 0.0f;
   
   NSNumber* rotationNumber = [self valueForKey:@"rotation"];
   
   if (nil != rotationNumber)
   {
      result = [rotationNumber floatValue];
   }
   
   return result;   
}

// Coconut properties
-(NSDictionary*)coconut1Layer
{
   return (NSDictionary*)[self valueForKey:@"coconut1Layer"];
}

-(NSDictionary*)coconut2Layer
{
   return (NSDictionary*)[self valueForKey:@"coconut2Layer"];
}

-(NSDictionary*)coconut3Layer
{
   return (NSDictionary*)[self valueForKey:@"coconut3Layer"];
}

// ABlownLeaves properties
-(NSDictionary*)leaf1Layer
{
   return (NSDictionary*)[self valueForKey:@"leaf1Layer"];
}

-(NSDictionary*)leaf2Layer
{
   return (NSDictionary*)[self valueForKey:@"leaf2Layer"];
}

-(NSDictionary*)leaf3Layer
{
   return (NSDictionary*)[self valueForKey:@"leaf3Layer"];
}


// ALightBeam properties
-(NSDictionary*)particleAnimation
{
   return (NSDictionary*)[self valueForKey:@"particleAnimation"];
}

-(NSDictionary*)beamLayer
{
   return (NSDictionary*)[self valueForKey:@"beamLayer"];
}

// APoppingCork properties
-(NSDictionary*)bottleLayer
{
   return (NSDictionary*)[self valueForKey:@"bottleLayer"];
}

-(NSDictionary*)corkAnimation
{
   return (NSDictionary*)[self valueForKey:@"corkAnimation"];
}

// Physics Engine related properties
-(NSString*)objectObjectCollisionSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"objectObjectCollisionSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"objectObjectCollisionSoundEffect"];
   }
   
   return result;
}

-(NSString*)objectWallCollisionSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"objectWallCollisionSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"objectWallCollisionSoundEffect"];
   }
   
   return result;
}

// Lantern related properties
-(NSString*)lanternSoundEffect
{
   NSString* result = @"";
   
   if (nil != [self valueForKey:@"lanternSoundEffect"])
   {
      result = (NSString*)[self valueForKey:@"lanternSoundEffect"];
   }
   
   return result;
}

@end
