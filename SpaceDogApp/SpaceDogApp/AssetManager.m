// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

// AAssetManager
// NSObject subclass that manages dynamic content rendering

#include <stdlib.h>
#include <objc/objc.h>
#include <math.h>

#import <AVFoundation/AVFoundation.h>
#import "AssetManager.h"
#import "AssetReference.h"
#import "AssetPageReferences.h"
#import "NSArray+PropertyValues.h"
#import "OrderedDictionary.h"
#import "ObjectAL.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "MotionManager.h"
#import "CustomAnimation.h"
#import "BookManager.h"

#define kDeviceIsShaking      0.5
#define kDeviceIsNotShaking   0.2

@interface AAssetManager (Private)
-(NSDictionary*)GetPageDescriptorForPage:(NSInteger)requestedPageNumber;
-(NSString*)GetAssetPathForElement:(NSDictionary*)element;
-(AAssetReference*)GetAssetRefForElement:(NSDictionary*)element;
-(AAssetReference*)GetAssetRefForElementOnCurrentPage:(NSDictionary*)element;
-(NSArray*)GetElementsOnCurrentPage;
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender;
-(void)RegisterPropertyTrigger:(NSDictionary*)property ForAnimationView:animationView InView:(UIView*)view;
-(UIImageView*)RenderStaticElement:(NSDictionary*)element AndInView:(UIView*)view;
-(void)RenderAnimationFramesProperty:(NSDictionary*)property AndAsset:(NSString*)assetName AndInView:(UIView*)view;
-(void)RenderAnimationPosition:(NSDictionary*)property AndAsset:assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward;
-(void)RenderAnimationSize:(NSDictionary*)property AndAsset:assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward;
-(void)RenderAnimationAlpha:(NSDictionary*)property AndAsset:assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward;
-(void)RenderAnimationProperty:(NSDictionary*)property AndAsset:assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward;
-(void)RenderAnimationForElement:(NSDictionary*)element AndInView:(UIView*)view;
-(void)RenderAudioForElement:(NSDictionary*)element InView:(UIView*)view;
//-(void)QueueAnimationPropery:(NSDictionary*)property InAssetRef:(AAssetReference*)assetRef;
-(void)ProcessAnimationPropertyQueueForAssetRef:(AAssetReference*)assetRef;
-(void)ExecuteAction:(NSDictionary *)property;

-(void)RenderLayerAnimationForElement:(NSDictionary*)element InView:(UIView*)view;
-(void)RenderCustomLayerAnimationForElement:(NSDictionary*)element InView:(UIView*)view;
-(CAAnimation*)RenderAnimationProperty:(NSDictionary*)property ForAsset:(AAssetReference*)assetRef;
-(CALayer*)RenderStaticElementOnLayer:(NSDictionary*)element InView:(UIView*)view;
-(void)SetAnchorPoint:(CGPoint)anchorPoint ForLayer:(CALayer*)layer;
-(void)RenderAnimationGeometry:(NSDictionary*)element OnLayer:(CALayer*)layer;
-(void)ExecuteAnimationWithKey:(id)nextAnimationKey PrecededBy:(CAAnimation*)animation;

-(void)RenderCustomAnimation:(NSDictionary*)animationSpec ForAsset:(AAssetReference *)assetRef;
-(void)RenderAudioElement:(NSDictionary*)element InView:(UIView*)view;
-(void)RenderAudioProperty:(NSDictionary*)propertyDescriptor;

-(void)monitorDeviceAttitude:(NSTimer*)theTimer;
-(void)monitorDeviceShake:(NSTimer*)theTimer;
-(BOOL)deviceIsShaking:(CMAcceleration)accelData shakeThreshold:(double)threshold;
@end

@implementation AAssetManager (Private)

-(NSDictionary*)GetCurrentPageDescriptor
{
   NSArray* pages = (NSArray*)[self.assets valueForKey:@"pages"];
   
   for (NSDictionary* page in pages)
   {
      NSNumber* pageNumber = (NSNumber*)[page valueForKey:@"page"];
      if ([pageNumber intValue] == self.currentPage)
      {
         return page;
      }
   }
   return nil;
}

-(NSDictionary*)GetPageDescriptorForPage:(NSInteger)requestedPageNumber
{
   NSArray* pages = (NSArray*)[self.assets valueForKey:@"pages"];
   
   for (NSDictionary* page in pages)
   {
      NSNumber* pageNumber = (NSNumber*)[page valueForKey:@"page"];
      if (requestedPageNumber == [pageNumber intValue])
      {
         return page;
      }
   }
   return nil;   
}

-(AAssetPageReferences*)AssetPageReferencesForPage:(NSUInteger)page
{
   for (AAssetPageReferences* ref in fAssetPageReferences)
   {
      if (ref.fPage == page)
      {
         return ref;
      }
   }
   return nil;
}
          
-(AAssetReference*)AddAssetReferenceWithElement:(NSDictionary*)element AndImgView:(UIImageView*)animationView
{
   AAssetReference* result = nil;
   
   NSDictionary* currentPage = [self GetCurrentPageDescriptor];
   
   AAssetPageReferences* assetPageReferences = [self AssetPageReferencesForPage:self.currentPage];
   if ((currentPage) && (![assetPageReferences AssetReferenceForElement:element]))
   {      
      NSArray* elements = (NSArray*)[currentPage valueForKey:@"elements"];
      
      AAssetReference* assetRef = [[[AAssetReference alloc] initWithIndex:[elements indexOfObject:element] AndElement:element AndImgView:animationView] autorelease];
      [assetPageReferences.fPageAssetReferences addObject:assetRef];
      
      result = assetRef;
      //[assetRef release];
   }
   
   return result;
}

-(NSString*)GetAssetPathForElement:(NSDictionary*)element
{
   NSString* assetName = (NSString*)[element valueForKey:@"resource"];
   return [[NSBundle mainBundle] pathForResource:assetName ofType:nil];
}

-(AAssetReference*)GetAssetRefForProperty:(NSDictionary*)property
{
   for(AAssetPageReferences* pageRefs in fAssetPageReferences)
   {
      AAssetReference* assetRef = [pageRefs AssetReferenceForProperty:property];
      if (assetRef)
      {
         return assetRef;
      }
   }
   return nil;
}

-(AAssetReference*)GetAssetRefForElement:(NSDictionary*)element
{
   for(AAssetPageReferences* pageRefs in fAssetPageReferences)
   {
      AAssetReference* assetRef = [pageRefs AssetReferenceForElement:element];
      
      if (nil != assetRef)
      {
         return assetRef;
      }
   }
   return nil;
}

-(AAssetReference*)GetAssetRefForElementOnCurrentPage:(NSDictionary*)element
{
   AAssetPageReferences* assetPageRefs = [self AssetPageReferencesForPage:self.currentPage];
   
   return [assetPageRefs AssetReferenceForElement:element];
}

-(NSArray*)GetElementsOnCurrentPage
{
   NSArray* pages = (NSArray*)[self.assets valueForKey:@"pages"];
   
   NSDictionary* currentPage = nil;
   for (NSDictionary* page in pages)
   {
      NSNumber* pageNumber = (NSNumber*)[page valueForKey:@"page"];
      if ([pageNumber intValue] == self.currentPage)
      {
         currentPage = page;
         break;
      }
   }

   if (!currentPage)
   {
      return nil;
   }
   else
   {
      return (NSArray*)[currentPage valueForKey:@"elements"];
   }
}

- (IBAction)HandleGesture:(UIGestureRecognizer*)sender 
{
	UITapGestureRecognizer* tapRecognizer = (UITapGestureRecognizer*)sender;
   CGPoint location = [tapRecognizer locationInView:tapRecognizer.view];
   NSArray* elements = [self GetElementsOnCurrentPage];
   for (NSDictionary* element in elements)
   {
      NSArray* propertyList = element.propertyList;
      NSDictionary* property = nil;
      NSDictionary* trigger = nil; 
      
      // if the triggerable animation is on a layer, then determining which
      // animation to invoke is different than if the animation is UIView-based
      BOOL onLayer = element.isOnLayer;
      
      NSString* animationType = element.animationType;
      
      if (onLayer)
      {
         // identify the animation in context
         AAssetReference* assetRef = [self GetAssetRefForElement:element];
         
         if (nil != assetRef)
         {
            // element-level triggers override property-level triggers
            if (element.hasTrigger)
            {
               trigger = element.trigger;
            }
            else 
            {
               if (nil != propertyList)
               {
                  property = (NSDictionary*)[propertyList objectAtIndex:assetRef.fActivePropertyIndex];
                  
                  trigger = property.trigger;                  
               }
               else 
               {
                  continue;
               }
            }
         }
         else 
         {
            return;
         }
      }
      else // old school - not on layer
      {
         property = (NSDictionary*)[propertyList objectAtIndex:0];
         trigger = property.trigger;         
      }
      
      NSString* type = trigger.type;
      
      if ([type isEqualToString:@"TOUCH"] || [type isEqualToString:@"PAN"])
      {
         for (NSArray* region in trigger.regions)
         {
            NSNumber* originX = [region objectAtIndex:0];
            NSNumber* originY = [region objectAtIndex:1];
            NSNumber* width = [region objectAtIndex:2];
            NSNumber* height = [region objectAtIndex:3];
            
            CGRect rect = CGRectMake([originX intValue], [originY intValue], [width intValue], [height intValue]);
            
            //DLog(@"touch/pan location - x: %f, y: %f", location.x, location.y);
            
            if (CGRectContainsPoint(rect, location))
            {
               AAssetPageReferences* assetPageRefs = [self AssetPageReferencesForPage:self.currentPage];
               AAssetReference* assetRef = [assetPageRefs AssetReferenceForElement:element];

               NSString* type = property.type;
               
               if (onLayer)
               {
                  if ([@"TRIGGERED" isEqualToString:animationType])
                  {
                     // run the animation specified by the 'activePropertyIndex'...
                     [assetRef RunTriggeredAnimation];
                  }
                  else if ([@"SEQUENTIAL" isEqualToString:animationType])
                  {
                     // run the animation specified by the 'activePropertyIndex'...
                     [assetRef RunNextSequencedAnimation];
                  }
                  else if ([@"CONCURRENT" isEqualToString:animationType])
                  {
                     // arrange to run the element's animations concurrently
                     AAssetPageReferences* assetPageReferences = [self AssetPageReferencesForAssetRef:assetRef];
                     
                     if (nil != assetPageReferences && ![@"" isEqualToString:assetRef.fAnimationGroup])
                     {
                        [assetPageReferences RunConcurrentAnimationsInGroup:assetRef.fAnimationGroup];
                     }
                     
                     // if there's an audio component to the properties of this animation
                     // run it/them now
                     // TODO: figure out how to run audio and animations concurrently
                     if ([type isEqualToString:@"AUDIO"])
                     {
                        [self RenderAudioProperty:property];
                     }
                  }
                  else if ([@"CUSTOM" isEqualToString:animationType])
                  {
                     id<ACustomAnimation> customAnimation = assetRef.fCustomAnimation;
                     
                     if (nil != customAnimation && [[(NSObject*)customAnimation class] instancesRespondToSelector:@selector(HandleGesture:)])
                     {
                        [customAnimation HandleGesture:sender];
                     }
                  }
               }
               else if ([type isEqualToString:@"STATIC"])
               {
                  [self RenderStaticElement:element AndInView:(UIImageView*)tapRecognizer.view];
               }
               else if ([type isEqualToString:@"AUDIO"])
               {
                  [self RenderAudioElement:element InView:(UIImageView*)tapRecognizer.view];
               }
               else
               {
                  [self RenderAnimationProperty:property AndAsset:[self GetAssetPathForElement:element] AndAnimationView:assetRef.fImgView AndIsForward:YES];
               }
            }
         }
      }
   }
   
   // delegates, if they exist, get the last shot at a gesture
   if (nil != self.delegate)
   {
      if ([((NSObject*)self.delegate) respondsToSelector:@selector(assetManager:didReceiveGesture:)])
      {
         [self.delegate assetManager:self didReceiveGesture:sender];
      }
   }
}

- (void)monitorDeviceAttitude:(NSTimer*)theTimer 
{
   CMAcceleration accelData = [AMotionManager sharedMotionManager].cmMotionManager.accelerometerData.acceleration; 
   float R =  sqrt(pow(accelData.x,2)+pow(accelData.y,2)+pow(accelData.z,2));
   float aRx = /*acos*/(accelData.x/R);//*180/M_PI;
   float aRy = /*acos*/(accelData.y/R);//*180/M_PI;
//   float aRz = /*acos*/(accelData.z/R);//*180/M_PI;
   
   /*
   if (signbit(aRy) != 0)
   {
      aRx *= -1.0;
   }
   */
/*
   float roll = atanf(aRy / aRx) - M_PI/2.0;
   if (signbit(accelData.y) != 0)
   {
      roll *= -1.0;
   }
*/
   float roll = atanf(aRy / aRx);// - M_PI/2.0;
   if (signbit(accelData.y) != 0)
   {
      //roll *= -1.0;
   }

   //NSLog(@"monitorDeviceAttitude: aX= %f, aY= %f, aZ=%f", accelData.x, accelData.y, accelData.z);
   //NSLog(@"monitorDeviceAttitude: aX= %f, aY= %f, aZ= %f, roll= %f", aRx, aRy, aRz, roll);

   if (fabs(roll) > kTiltActionThresholdRadians)
   {
      // has tilt changed?
      if (roll<0)
      {
         if (fTiltLeft)
         {
            return;
         }
         fTiltLeft = YES;
         fTiltRight = NO;
      }
      else
      {
         if (fTiltRight)
         {
            return;
         }
         fTiltLeft = NO;
         fTiltRight = YES;
      }
      
      NSArray* elements = [self GetElementsOnCurrentPage];
      for (NSDictionary* element in elements)
      {
         if (element.hasTrigger)
         {
            NSArray* propertyList = (NSArray*)[element valueForKey:@"propertyList"];
            NSDictionary* property = (NSDictionary*)[propertyList objectAtIndex:0];
            NSDictionary* trigger = (NSDictionary*)[property valueForKey:@"trigger"];
            
            NSString* type = (NSString*)[trigger valueForKey:@"type"];
            
            if ([type isEqualToString:@"TILT"])
            {
               AAssetPageReferences* assetPageRefs = [self AssetPageReferencesForPage:self.currentPage];
               AAssetReference* assetRef = [assetPageRefs AssetReferenceForElement:element];
               
               [self RenderAnimationProperty:property AndAsset:[self GetAssetPathForElement:element] AndAnimationView:assetRef.fImgView AndIsForward:(roll < 0)];
            } 
         }
      }
   }
}


- (void)monitorDeviceShake:(NSTimer*)theTimer 
{
   CMAcceleration accelData = [AMotionManager sharedMotionManager].cmMotionManager.accelerometerData.acceleration; 

   if (nil != self.lastAcceleration)
   {
      if (!self.shakeStarted && [self deviceIsShaking:accelData shakeThreshold:kDeviceIsShaking])
      {
         self.shakeStarted = YES;
         
         NSArray* elements = [self GetElementsOnCurrentPage];
         
         for (NSDictionary* element in elements)
         {            
            if (element.hasShakeTrigger)
            {
               AAssetReference* assetRef = [self GetAssetRefForElementOnCurrentPage:element];
               
               for (NSDictionary* shakeTriggeredAnimation in element.shakeTriggeredAnimations)
               {
                  if ([@"CUSTOM" isEqualToString:shakeTriggeredAnimation.animationType])
                  {
                     [self RenderCustomAnimation:shakeTriggeredAnimation ForAsset:assetRef];   
                  }
                  else 
                  {
                     if (element.isOnLayer)
                     {
                        [self RenderLayerAnimationForElement:element InView:assetRef.fImgView];   
                     }
                     else 
                     {
                        [self RenderAnimationForElement:element AndInView:assetRef.fImgView];
                     }
                  }
               }
            }
         }
      }
      else if (self.shakeStarted && ![self deviceIsShaking:accelData shakeThreshold:kDeviceIsNotShaking])
      {
         self.shakeStarted = NO;
      }
   }
   
   self.lastAcceleration = [AMotionManager sharedMotionManager].cmMotionManager.accelerometerData;
}

-(BOOL)deviceIsShaking:(CMAcceleration)accelData shakeThreshold:(double)threshold
{
   CMAcceleration lastAcceleration = self.lastAcceleration.acceleration;
   
   double deltaX = fabs(lastAcceleration.x - accelData.x);
   double deltaY = fabs(lastAcceleration.y - accelData.y);
   double deltaZ = fabs(lastAcceleration.z - accelData.z);
   
   return 
      (deltaX > threshold && deltaY > threshold) ||
      (deltaX > threshold && deltaZ > threshold) ||
      (deltaY > threshold && deltaZ > threshold);
}

- (void)TriggerAnimationAfterDelay:(NSTimer*)theTimer 
{
   NSArray* elements = [self GetElementsOnCurrentPage];
   for (NSDictionary* element in elements)
   {
      NSArray* propertyList = element.propertyList;
      NSDictionary* property = (NSDictionary*)[propertyList objectAtIndex:0];
      NSDictionary* trigger = property.trigger;
      
      NSString* type = trigger.type;
      
      if ([type isEqualToString:@"DELAY"])
      {
         AAssetReference* assetRef = [self GetAssetRefForElementOnCurrentPage:element];
         
         [self RenderAnimationProperty:property AndAsset:[self GetAssetPathForElement:element] AndAnimationView:assetRef.fImgView AndIsForward:YES];
      }
   }
}

/*
-(void)RenderCompletionTriggeredAnimationForElementWithProperty:(NSDictionary*)property AndAnimationView:(UIImageView*)animationView
{
   NSArray* elements = [self GetElementsOnCurrentPage];
   NSDictionary* currentPageDesc = [self GetCurrentPageDescriptor];
   
   if (currentPageDesc)
   {
      NSArray* elements = (NSArray*)[currentPageDesc valueForKey:@"elements"];
      for (NSDictionary* element in elements)
      {
         NSArray* propertyList = (NSArray*)[element valueForKey:@"propertyList"];
         for (NSDictionary* property in propertyList)
         {
            NSDictionary* trigger = (NSDictionary*)[property valueForKey:@"trigger"];
            NSString* type = (NSString*)[trigger valueForKey:@"type"];
            
            if ([type isEqualToString:@"COMPLETION"])
            {
            }
         }
      }
   }
}
*/

-(void)RegisterPropertyTrigger:(NSDictionary*)property ForAnimationView:animationView InView:(UIView*)view
{
   NSDictionary* trigger = property.trigger;
   NSString* type = trigger.type;
   
   if ([type isEqualToString:@"TOUCH"])
   {
      UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
      tapRecognizer.cancelsTouchesInView = NO;
      [view addGestureRecognizer:tapRecognizer];
      [tapRecognizer release];	
   }
   else if ([type isEqualToString:@"TILT"])
   {
      // start motion manager monitoring
      [[AMotionManager sharedMotionManager].cmMotionManager startAccelerometerUpdates];
      [NSTimer scheduledTimerWithTimeInterval:0.20
                                       target:self
                                     selector:@selector(monitorDeviceAttitude:)
                                     userInfo:nil
                                      repeats:YES];   
   }
   else if ([type isEqualToString:@"DELAY"])
   {
      [NSTimer scheduledTimerWithTimeInterval:trigger.duration
                                       target:self
                                     selector:@selector(TriggerAnimationAfterDelay:)
                                     userInfo:nil
                                      repeats:NO];   
   }
   else if ([type isEqualToString:@"SHAKE"])
   {
      // start motion manager monitoring - we're assuming here that calling
      // startAccelerometerUpdates multiple times on the CMMotionManager has
      // no negative effects
      if (nil == self.shakeTimer)
      {
         [[AMotionManager sharedMotionManager].cmMotionManager startAccelerometerUpdates];
         self.shakeTimer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                            target:self
                                                          selector:@selector(monitorDeviceShake:)
                                                          userInfo:nil
                                                           repeats:YES]; 
      }
   }
}

-(void)RegisterAnimationTrigger:(NSDictionary*)animationSpec InView:(UIView*)view
{
   // Only animations that have a 'createdBy' value of TRIGGER are registered
   // here.
   NSDictionary* creationSpec = animationSpec.creationSpec;
   
   if (nil != creationSpec && nil != creationSpec.createdBy)
   {
      if ([@"TRIGGER" isEqualToString:creationSpec.createdBy])
      {
         NSDictionary* triggerSpec = animationSpec.trigger;
         
         if (nil != triggerSpec)
         {
            [self RegisterTrigger:triggerSpec InView:view];
         }
      }
   }
}

-(void)RenderAnimationFramesProperty:(NSDictionary*)property AndAsset:(NSString*)assetName AndInView:(UIView*)view
{
   NSLog(@"RenderAnimationFramesProperty: %@", [property description]);
   
   UIImageView* imgView = nil;
   NSNumber* numFrames = (NSNumber*)[property valueForKey:@"numFrames"];
   NSMutableArray* animationImages = [NSMutableArray arrayWithCapacity:0];
   NSString* framesPath = [assetName stringByDeletingPathExtension];
   NSString* framesExt = [assetName pathExtension];
   for (int i=1; i<=[numFrames intValue]; i++)
   {
      NSString* frameFilePath = [NSString stringWithFormat:@"%@%04d.%@", framesPath, i, framesExt];
      NSString* assetPath = [[NSBundle mainBundle] pathForResource:frameFilePath ofType:nil];

      if (![[NSFileManager defaultManager] fileExistsAtPath:assetPath])
      {
         NSLog(@"Animation frame file missing: %@", assetPath);
      }
      else
      {
         if (!imgView)
         {
            imgView = [[[UIImageView alloc ]initWithImage:[UIImage imageWithContentsOfFile:assetPath]] autorelease];
         }
                                          
         UIImage* frameImg = [UIImage imageWithContentsOfFile:assetPath];
         [animationImages addObject:frameImg];
      }
   }   
   
   CGRect frame = imgView.frame;
   
   if (property.hasFrame)
   {
      frame = property.frame;
   }
   else 
   {
      NSArray* startPos;
      NSArray* initialPos = (NSArray*)[property valueForKey:@"initialPos"];
      if (initialPos && ((NSObject*)initialPos != [NSNull null]))
      {
         startPos = initialPos;
      }
      else
      {
         startPos = (NSArray*)[property valueForKey:@"startPos"];
      }
      
      NSNumber* startPosXNum = (NSNumber*)[startPos objectAtIndex:0];
      NSNumber* startPosYNum = (NSNumber*)[startPos objectAtIndex:1];
      frame.origin.x = (CGFloat)[startPosXNum floatValue];
      frame.origin.y = (CGFloat)[startPosYNum floatValue];
   }
   
   imgView.frame = frame;

   [view addSubview:imgView];
   imgView.animationImages = [NSArray arrayWithArray:animationImages];
   
   if (property.hasDuration)
   {
      imgView.animationDuration = property.duration;
   }
   
   [imgView startAnimating];
}

-(void)RenderAnimationGeometry:(NSDictionary*)element OnLayer:(CALayer*)layer
{
   // TODO: assume BOUNDS for now, but could be any of the geometry-related properties
   // animation is explicit 
   
   // if element has propertyList count > 1, assume keyframe animation (for now)
   NSArray* propertyList = (NSArray*)[element objectForKey:@"propertyList"];
   
   if (2 <= [propertyList count])
   {
      // keyframe animation 
      
      NSMutableArray* keyframeValues = [NSMutableArray arrayWithCapacity:[propertyList count]];
      NSMutableArray* keyframeTimes = [NSMutableArray arrayWithCapacity:[propertyList count]];
      
      // assume linear pacing (unless otherwise specified)
      for (NSDictionary* keyframeSpec in propertyList)
      {
         // each item contains specs for a keyframe
         CGSize boundsSize = [(NSArray*)[keyframeSpec objectForKey:@"boundsSize"] asCGSize];
         [keyframeValues addObject:[NSValue valueWithCGSize:boundsSize]];
         
         NSNumber* keyTime = (NSNumber*)[keyframeSpec objectForKey:@"keyTime"];
         [keyframeTimes addObject:keyTime];
      }
      
      CAKeyframeAnimation* keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size"];
      keyframeAnimation.duration = [(NSNumber*)[element objectForKey:@"duration"] floatValue];
      keyframeAnimation.values = keyframeValues;
      keyframeAnimation.keyTimes = keyframeTimes; 
      keyframeAnimation.repeatCount = 10000;
      
      [layer addAnimation:keyframeAnimation forKey:@"animateSize"];
   }
   else 
   {
      // basic animation
      NSDictionary* property = (NSDictionary*)[propertyList objectAtIndex:0];
      
      CGRect startBounds = layer.bounds;
      CGRect endBounds = startBounds;
      
      NSArray* endBoundsValues = (NSArray*)[property objectForKey:@"endBounds"];
      endBounds.size = [endBoundsValues asCGSize];
      
      NSNumber* duration = (NSNumber*)[property objectForKey:@"duration"];
      
      // TODO: other properties of interest can be extracted here...
      
      CABasicAnimation* basicAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
      basicAnimation.duration = [duration floatValue];
      basicAnimation.fromValue = [NSValue valueWithCGRect:startBounds];
      basicAnimation.toValue = [NSValue valueWithCGRect:endBounds];
      
      [layer addAnimation:basicAnimation forKey:@"animateBounds"];
   }
}

-(void)RenderAnimationPosition:(NSDictionary*)property AndAsset:(NSString*)assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward
{
   NSArray* endPos;
   CGRect frame = animationView.frame;
   if (isForward)
   {
      endPos = (NSArray*)[property valueForKey:@"endValues"];
   }
   else
   {
      endPos = (NSArray*)[property valueForKey:@"startPos"];
   }
   NSNumber* endPosXNum = (NSNumber*)[endPos objectAtIndex:0];
   NSNumber* endPosYNum = (NSNumber*)[endPos objectAtIndex:1];
   frame.origin.x = (CGFloat)[endPosXNum floatValue];
   frame.origin.y = (CGFloat)[endPosYNum floatValue];
   
   CGFloat duration = 0.0;
   NSNumber* durationNum = (NSNumber*)[property valueForKey:@"duration"];
   if ((NSObject*)durationNum != [NSNull null])
   {
      duration = [durationNum floatValue];
   }
   
   CGFloat delay = 0.0;
   NSNumber* delayNum = (NSNumber*)[property valueForKey:@"delay"];
   if ((NSObject*)delayNum != [NSNull null])
   {
      delay = [delayNum floatValue];
   }
   
   UIViewAnimationOptions animationOptions = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
   NSString* repeats = (NSString*)[property valueForKey:@"repeatType"];
   if (repeats && ((NSObject*)repeats != [NSNull null]))
   {
      if ([repeats isEqualToString:@"CONTINUOUS"])
      {
         animationOptions |= UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse;
      }
   }
   
   [UIView animateWithDuration: duration
                         delay: delay
                       options: animationOptions
                     animations: ^{animationView.frame = frame;}
                    completion:^(BOOL finished){
                       /*NSLog(@"animation completed - finished? %@", finished?@"YES":@"NO");*/}];
}

-(void)RenderAnimationSize:(NSDictionary*)property AndAsset:(NSString*)assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward
{
   NSArray* startValues;
   NSArray* endValues;
   
   CGRect frame = animationView.frame;
   
   startValues = (NSArray*)[property valueForKey:@"initialPos"];
   
   // set the image to its inital size right now...
   frame.size = [startValues asCGSize];
   animationView.frame = frame;
   
   endValues = (NSArray*)[property valueForKey:@"endValues"];
      
   frame.size = [endValues asCGSize];
   
   CGFloat duration = 0.0;
   NSNumber* durationNum = (NSNumber*)[property valueForKey:@"duration"];
   if ((NSObject*)durationNum != [NSNull null])
   {
      duration = [durationNum floatValue];
   }
   
   CGFloat delay = 0.0;
   NSNumber* delayNum = (NSNumber*)[property valueForKey:@"delay"];
   if ((NSObject*)delayNum != [NSNull null])
   {
      delay = [delayNum floatValue];
   }
   
   UIViewAnimationOptions animationOptions = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
   NSString* repeats = (NSString*)[property valueForKey:@"repeatType"];
   if (repeats && ((NSObject*)repeats != [NSNull null]))
   {
      if ([repeats isEqualToString:@"CONTINUOUS"])
      {
         animationOptions |= UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse;
      }
   }
   
   AAssetReference* assetRef = [self GetAssetRefForProperty:property];
   
   [UIView animateWithDuration: duration
                         delay: delay
                       options: animationOptions
                    animations: ^{animationView.frame = frame;}
                    completion:^(BOOL finished){[self ProcessAnimationPropertyQueueForAssetRef:assetRef];}];
}


-(CAAnimation*)RenderAnimationSize:(NSDictionary*)property ForAsset:(AAssetReference*)assetRef
{
   NSArray* initialSize;
   NSArray* finalSize;
      
   initialSize = (NSArray*)[property valueForKey:@"initialSize"];
   finalSize = (NSArray*)[property valueForKey:@"finalSize"];
      
   CGFloat duration = 0.0;
   NSNumber* durationNum = (NSNumber*)[property valueForKey:@"duration"];
   if ((NSObject*)durationNum != [NSNull null])
   {
      duration = [durationNum floatValue];
   }
   
   CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
   animation.fromValue = [NSValue valueWithCGSize:[initialSize asCGSize]];
   animation.toValue = [NSValue valueWithCGSize:[finalSize asCGSize]];
   animation.duration = duration;

   [animation setValue:@"bounds.size" forKey:@"property"];
   [animation setValue:animation.fromValue forKey:@"resetValue"];

   return animation;
}

-(CAAnimation*)RenderAnimationPosition:(NSDictionary*)property ForAsset:(AAssetReference*)assetRef
{
   CGPoint initialPosition;
   CGPoint finalPosition;
   
   initialPosition = [(NSArray*)[property valueForKey:@"initialPosition"] asCGPoint];
   finalPosition = [(NSArray*)[property valueForKey:@"finalPosition"] asCGPoint];
   
   CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
   animation.fromValue = [NSValue valueWithCGPoint:initialPosition];
   animation.toValue = [NSValue valueWithCGPoint:finalPosition];
   animation.duration = property.duration;
   
   [animation setValue:@"position" forKey:@"property"];
   
   return animation;
}


-(void)RenderAnimationRotation:(NSDictionary*)property AndAsset:(NSString*)assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward
{
   CGFloat delay = 0.0;
   NSNumber* delayNum = (NSNumber*)[property valueForKey:@"delay"];
   if ((NSObject*)delayNum != [NSNull null])
   {
      delay = [delayNum floatValue];
   }
   
   CGFloat duration = 0.0;
   NSNumber* durationNum = (NSNumber*)[property valueForKey:@"duration"];
   if ((NSObject*)durationNum != [NSNull null])
   {
      duration = [durationNum floatValue];
   }
   
   CGFloat rotation = 0.0;
   NSNumber* rotationNum = (NSNumber*)[property valueForKey:@"rotation"];
   if ((NSObject*)rotationNum != [NSNull null])
   {
      rotation = [rotationNum floatValue];
   }
   
//   CGAffineTransform transformTranslate1 = CGAffineTransformTranslate (CGAffineTransformIdentity, -animationView.frame.size.width / 2.0, -animationView.frame.size.height / 2.0);
   CGAffineTransform transformRotate = CGAffineTransformRotate (CGAffineTransformIdentity, rotation * M_PI/180.0);
//   CGAffineTransform transformRotateTranslate = CGAffineTransformTranslate (transformRotate, animationView.frame.size.width / 2.0, -animationView.frame.size.height / 2.0);

   UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
   NSString* repeats = (NSString*)[property valueForKey:@"repeatType"];
   if (repeats && ((NSObject*)repeats != [NSNull null]))
   {
      if ([repeats isEqualToString:@"CONTINUOUS"])
      {
         animationOptions |= UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse;
      }
   }
   
   [UIView animateWithDuration: duration
                         delay: delay
                       options: animationOptions
                    animations: ^{animationView.transform = transformRotate;}
                    completion:nil];
}

-(void)RenderAnimationAlpha:(NSDictionary*)property AndAsset:assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward
{   
   CGFloat endValue = 1.0;
   NSNumber* endNum = (NSNumber*)[property valueForKey:@"endValue"];
   if ((NSObject*)endNum != [NSNull null])
   {
      endValue = [endNum floatValue];
   }
   
   CGFloat initialValue = 0.0;
   NSNumber* initalNum = (NSNumber*)[property valueForKey:@"initialValue"];
   if ((NSObject*)initalNum != [NSNull null])
   {
      initialValue = [initalNum floatValue];
   }
   
   CGFloat duration = 0.0;
   NSNumber* durationNum = (NSNumber*)[property valueForKey:@"duration"];
   if ((NSObject*)durationNum != [NSNull null])
   {
      duration = [durationNum floatValue];
   }
   
   CGFloat delay = 0.0;
   NSNumber* delayNum = (NSNumber*)[property valueForKey:@"delay"];
   if ((NSObject*)delayNum != [NSNull null])
   {
      delay = [delayNum floatValue];
   }
   
   UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
   NSString* repeats = (NSString*)[property valueForKey:@"repeatType"];
   if (repeats && ((NSObject*)repeats != [NSNull null]))
   {
      if ([repeats isEqualToString:@"CONTINUOUS"])
      {
         animationOptions |= UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse;
      }
   }
   animationView.alpha = initialValue;
   
 //  AAssetPageReferences* assetPageReferences = [self AssetPageReferencesForPage:self.currentPage];
 //  AAssetReference* assetRef = [assetPageReferences AssetReferenceForProperty:property];
   AAssetReference* assetRef = [self GetAssetRefForProperty:property];

   [UIView animateWithDuration: duration
                         delay: delay
                       options: animationOptions
                    animations: ^{animationView.alpha = endValue;}
                    completion: ^(BOOL finished){[self ProcessAnimationPropertyQueueForAssetRef:assetRef];}
                     /*
                     {
                       [UIView animateWithDuration: duration/2.0
                                             delay: 0.0
                                           options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                                        animations: ^{animationView.alpha = 0.0;}
                                        completion:nil];
                    }*/
    ];

/*
   [UIView animateWithDuration: duration/2.0
                         delay: 0.0
                       options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                    animations: ^{animationView.alpha = 1.0;}
                    completion:^(BOOL finished)
    {
       [self RenderCompletionTriggeredAnimationForElementWithProperty:property AndAnimationView:animationView];
    }
    ];
*/
}



-(CAAnimation*)RenderAnimationAlpha:(NSDictionary*)property ForAsset:(AAssetReference*)assetRef
{
   NSNumber* startValue = [NSNumber numberWithFloat:1.0];
   NSNumber* startNum = (NSNumber*)[property valueForKey:@"startValue"];
   if ((NSObject*)startNum != [NSNull null])
   {
      startValue = startNum;
   }   
   
   NSNumber* endValue = [NSNumber numberWithFloat:1.0];
   NSNumber* endNum = (NSNumber*)[property valueForKey:@"endValue"];
   if ((NSObject*)endNum != [NSNull null])
   {
      endValue = endNum;
   }
   
   NSNumber* initialValue = [NSNumber numberWithFloat:0.0];
   NSNumber* initalNum = (NSNumber*)[property valueForKey:@"initialValue"];
   if ((NSObject*)initalNum != [NSNull null])
   {
      initialValue = initalNum;
   }
   
   CGFloat duration = 0.0;
   NSNumber* durationNum = (NSNumber*)[property valueForKey:@"duration"];
   if ((NSObject*)durationNum != [NSNull null])
   {
      duration = [durationNum floatValue];
   }
   
   CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
   animation.fromValue = startValue;
   animation.toValue = endValue;
   animation.duration = duration;
   
   // set values that should be applied to the layer before this
   // animation runs
   [animation setValue:@"opacity" forKey:@"property"];
   [animation setValue:initialValue forKey:@"resetValue"];
   
   return animation;
}




-(void)RenderAnimationProperty:(NSDictionary*)property AndAsset:assetPath AndAnimationView:(UIImageView*)animationView AndIsForward:(BOOL)isForward
{
   NSString* type = (NSString*)[property valueForKey:@"type"];
   
   animationView.hidden = NO;

   if ([type isEqualToString:@"POS"])
   {
      [self RenderAnimationPosition:property AndAsset:assetPath AndAnimationView:animationView AndIsForward:isForward];
   }
   else if ([type isEqualToString:@"SIZE"])
   {
      [self RenderAnimationSize:property AndAsset:assetPath AndAnimationView:animationView AndIsForward:isForward];
   }
   else if ([type isEqualToString:@"ROTATION"])
   {
      [self RenderAnimationRotation:property AndAsset:assetPath AndAnimationView:animationView AndIsForward:YES];
   }
   else if ([type isEqualToString:@"ALPHA"])
   {
      [self RenderAnimationAlpha:property AndAsset:assetPath AndAnimationView:animationView AndIsForward:YES];
   }
   else if ([type isEqualToString:@"ACTION"])
   {
      [self ExecuteAction:property];
   }
}


-(CAAnimation*)RenderAnimationProperty:(NSDictionary*)property ForAsset:(AAssetReference*)assetRef
{
   CAAnimation* result = nil;
   
   NSString* type = (NSString*)[property valueForKey:@"type"];
   
   if ([type isEqualToString:@"SIZE"])
   {
      result = [self RenderAnimationSize:property ForAsset:assetRef];
   }
   else if ([type isEqualToString:@"ALPHA"])
   {
      result = [self RenderAnimationAlpha:property ForAsset:assetRef];
   }
   else if ([type isEqualToString:@"POSITION"])
   {
      result = [self RenderAnimationPosition:property ForAsset:assetRef];
   }
   
   return result;
}

-(CALayer*)RenderStaticElementOnLayer:(NSDictionary*)element InView:(UIView*)view
{
   //DLog(@"RenderStaticElementOnLayer:InView: %@", [element description]);
   
   NSString* assetName = element.resource;
   NSString* assetPath = [[NSBundle mainBundle] pathForResource:assetName ofType:nil];
   
   UIImage* imageToAnimate = [UIImage imageWithContentsOfFile:assetPath];
      
   CALayer* elementLayer = [CALayer layer];
   elementLayer.backgroundColor = [[UIColor clearColor] CGColor];
   elementLayer.contents = (id)[imageToAnimate CGImage];
      
   elementLayer.frame = element.frame;
   elementLayer.masksToBounds = NO;
   
   // by default, elements are completely opaque, but a different value can
   // be specified, if desired   
   elementLayer.opacity = element.initialAlpha;
   
   // has a contentsGravity style been specified?
   if (element.hasContentsGravity)
   {
      elementLayer.contentsGravity = element.contentsGravity;
   }
   
   [view.layer addSublayer:elementLayer];
   
   if (element.hasAnchorPoint)
   {
      [self SetAnchorPoint:element.anchorPoint ForLayer:elementLayer]; 
   }
   
   return elementLayer;
}

-(UIImageView*)RenderStaticElement:(NSDictionary*)element AndInView:(UIView*)view
{
   //DLog(@"RenderStaticElement: %@", [element description]);
   
   NSString* assetName = (NSString*)[element valueForKey:@"resource"];
   NSString* assetPath = [[NSBundle mainBundle] pathForResource:assetName ofType:nil];
   
   UIImageView* animationView = [[UIImageView alloc ]initWithImage:[UIImage imageWithContentsOfFile:assetPath]];

   NSArray* propertyList = (NSArray*)[element valueForKey:@"propertyList"];
   NSDictionary* property = (NSDictionary*)[propertyList objectAtIndex:0];

   CGRect frame = animationView.frame;
   
   NSArray* startPos;
   NSArray* initialPos = (NSArray*)[property valueForKey:@"initialPos"];
   if (initialPos && ((NSObject*)initialPos != [NSNull null]))
   {
      startPos = initialPos;
   }
   else
   {
      startPos = (NSArray*)[property valueForKey:@"startPos"];
   }
   
   // by default, all static elements are visible
   BOOL visible = YES;
   
   NSNumber* visibleNumber = (NSNumber*)[property valueForKey:@"visible"];
   if (nil != visibleNumber)
   {
      visible = [visibleNumber boolValue];
   }
   
   animationView.hidden = !visible;
   
   // is this ststic element triggerable in some way?
   NSDictionary* trigger = (NSDictionary*)[property valueForKey:@"trigger"];
   if (nil != trigger)
   {
      [self RegisterPropertyTrigger:property ForAnimationView:animationView InView:view];     
   }
   
   NSNumber* startPosXNum = (NSNumber*)[startPos objectAtIndex:0];
   NSNumber* startPosYNum = (NSNumber*)[startPos objectAtIndex:1];
   frame.origin.x = (CGFloat)[startPosXNum floatValue];
   frame.origin.y = (CGFloat)[startPosYNum floatValue];
   animationView.frame = frame;

   [view addSubview:animationView];
   [animationView release];

   return animationView;
}

// The incoming anchorPoint value is specified in the layer's coordinate system, so
// it must be transformed to a unit coordinate system value appropriate for that
// layer. The position property is corrected to have its usual value
-(void)SetAnchorPoint:(CGPoint)anchorPoint ForLayer:(CALayer*)layer
{
   CGFloat anchorPointX = 0.0f<layer.bounds.size.width?anchorPoint.x/layer.bounds.size.width:0.0f;
   CGFloat anchorPointY = 0.0f<layer.bounds.size.height?anchorPoint.y/layer.bounds.size.height:0.0f;
   
   CGPoint finalAnchorPoint = CGPointMake(anchorPointX, anchorPointY);
   
   layer.anchorPoint = finalAnchorPoint;
   
   CGPoint correctedPosition = CGPointMake(layer.position.x + layer.bounds.size.width * (layer.anchorPoint.x - 0.5),
                                           layer.position.y + layer.bounds.size.height * (layer.anchorPoint.y -0.5));
   
   layer.position = correctedPosition;
}

-(void)RenderAudioElement:(NSDictionary*)element InView:(UIView*)view
{
   NSLog(@"RenderAudioElement: %@", [element description]);
   
   NSString* assetName = (NSString*)[element valueForKey:@"resource"];
   
   [[OALSimpleAudio sharedInstance] playEffect:assetName];
}

-(void)RenderAudioProperty:(NSDictionary*)propertyDescriptor
{
   //DLog(@"RenderAudioProperty: %@", [propertyDescriptor description]);
   
   NSString* assetName = (NSString*)[propertyDescriptor valueForKey:@"resource"];
   
   [[OALSimpleAudio sharedInstance] playEffect:assetName];
}

-(void)RenderAnimationForElement:(NSDictionary*)element AndInView:(UIView*)view
{
   //DLog(@"RenderAnimationForElement: %@", [element description]);
   
   NSString* assetName = (NSString*)[element valueForKey:@"resource"];
   NSString* assetPath = [[NSBundle mainBundle] pathForResource:assetName ofType:nil];
      
   NSArray* propertyList = (NSArray*)[element valueForKey:@"propertyList"];
   
   for (NSDictionary* property in propertyList)
   {
      NSString* type = (NSString*)[element valueForKey:@"type"];
      
      NSDictionary* trigger = (NSDictionary*)[property valueForKey:@"trigger"];
      
      UIImageView* animationView = nil;
      
      if (trigger && ((NSObject*)trigger != [NSNull null]))
      {
         NSString* triggerType = (NSString*)[trigger valueForKey:@"type"];
                  
         if (![triggerType isEqualToString:@"COMPLETION"])
         {
            // render upon trigger
            NSNumber* visibleNum = (NSNumber*)[trigger valueForKey:@"visible"];
            
            animationView = [self RenderStaticElement:element AndInView:view];

            if (visibleNum)
            {
               if (![visibleNum boolValue])
               {
                  animationView.hidden = YES;
               }
            }
            
            [self AddAssetReferenceWithElement:element AndImgView:animationView];
            [self RegisterPropertyTrigger:property ForAnimationView:animationView InView:view];
         }
      }
      else if (([type isEqualToString:kAnimationType]) || ([type isEqualToString:kAnimationFramesType]))
      {         
         if ([type isEqualToString:kAnimationFramesType])
         {
            [self RenderAnimationFramesProperty:property AndAsset:assetName AndInView:view];
            [self AddAssetReferenceWithElement:element AndImgView:animationView];
         }
         else
         {
            NSString* propertyType = (NSString*)[element valueForKey:@"propertyType"];
            
            if (nil != propertyType && [propertyType isEqualToString:@"GEOMETRY"])
            {
               CALayer* elementLayer = [self RenderStaticElementOnLayer:element InView:view];
               [self AddAssetReferenceWithElement:element AndLayer:elementLayer];
               [self RenderAnimationGeometry:element OnLayer:elementLayer];
            }
            else 
            {
               animationView = [self RenderStaticElement:element AndInView:view];
               [self AddAssetReferenceWithElement:element AndImgView:animationView];
               [self RenderAnimationProperty:property AndAsset:assetPath AndAnimationView:animationView AndIsForward:YES];
            }
         }
      }
      else if ([type isEqualToString:kAudioType])
      {
         // play audio
      }
      else
      {
         //NSAssert(NO, @"RenderAnimationForElement: Unknown type %@", type);
      }
   }
}

-(void)RenderAudioForElement:(NSDictionary*)element InView:(UIView*)view
{
   //DLog(@"RenderAudioForElement: %@", [element description]);
   
   NSString* assetName = (NSString*)[element valueForKey:@"resource"];
   
   NSArray* propertyList = (NSArray*)[element valueForKey:@"propertyList"];
   
   for (NSDictionary* property in propertyList)
   {
      NSDictionary* trigger = (NSDictionary*)[property valueForKey:@"trigger"];
            
      if (nil != trigger)
      {
         NSString* triggerType = (NSString*)[trigger valueForKey:@"type"];
         BOOL isSoundEffect = NO;
         
         NSNumber* isSoundEffectNumber = (NSNumber*)[element valueForKey:@"isSoundEffect"];
         if (nil != isSoundEffectNumber)
         {
            isSoundEffect = [isSoundEffectNumber boolValue];
         }
         
         if ([triggerType isEqualToString:@"TOUCH"])
         {
            // play upon trigger            
            [self AddAssetReferenceWithElement:element AndImgView:nil];
            [self RegisterPropertyTrigger:property ForAnimationView:nil InView:view];
            
            if (isSoundEffect)
            {
               [[OALSimpleAudio sharedInstance] preloadEffect:assetName];   
            }
         }
      }
   }
}

-(void)RenderLayerAnimationForElement:(NSDictionary*)element InView:(UIView*)view
{
   //DLog(@"RenderLayerAnimationForElement: %@", [element description]);
   
   NSString* repeatType = element.repeatType;    
   NSArray*  propertyList = element.propertyList;
   
   BOOL isSequenced = element.isSequenced;
   
   NSString* elementId = element.propertyId;
   
   if ([@"whalespray" isEqualToString:elementId])
   {
      NSLog(@"%@", elementId);
   }
   
   CALayer* layer = [self RenderStaticElementOnLayer:element InView:view];
   
   [view.layer addSublayer:layer];
   
   AAssetReference* assetRef = [self AddAssetReferenceWithElement:element AndLayer:layer];
   
   NSString* propertyId = nil;
   
   for (int i = 0; i < [propertyList count]; i++)
   {
      NSDictionary* property = (NSDictionary*)[propertyList objectAtIndex:i];
      
      propertyId = property.propertyId;
            
      CAAnimation* animation = [self RenderAnimationProperty:property ForAsset:assetRef];
      animation.delegate = self;
      animation.fillMode = kCAFillModeForwards;
      animation.removedOnCompletion = NO;
      animation.autoreverses = property.autoReverse;
      
      // take advantage of CAAnimation's KVCness to add some metadata
      [animation setValue:propertyId forKey:@"propertyId"];
      [animation setValue:assetRef forKey:@"assetRef"];
      [animation setValue:repeatType forKey:@"repeatType"];
      [animation setValue:(isSequenced?@"SEQUENCED":@"ONESHOT") forKey:@"sequenceType"];
      
      if (isSequenced)
      {
         [assetRef.fSequencedAnimations insertObject:animation forKey:propertyId atIndex:i];
      }
      else 
      {
         // oneshot/standalone
         assetRef.fStandaloneAnimation = animation;
         
         if (element.hasAnimationGroup)
         {
            NSLog(@"adding animation for group: %@", element.animationGroup);
            assetRef.fAnimationGroup = element.animationGroup;
         }
      }
      
      // is this animation triggerable in some way?
      NSDictionary* trigger = property.trigger;
      if (nil != trigger)
      {
         [self RegisterPropertyTrigger:property ForAnimationView:nil InView:view];      
      }
   }
   
   if (isSequenced)
   {
      // repeatType == CONTINUOUS means that all the ANIMATIONS defined by the individual
      // properties in the propertyList are to run continuously
      if ([repeatType isEqualToString:@"CONTINUOUS"])
      {
         // add the first animation in the sequence to the layer so that it starts running
         NSEnumerator* keyEnumerator = [assetRef.fSequencedAnimations keyEnumerator];
         
         while (propertyId = [keyEnumerator nextObject])
         {
            CAAnimation* animation = [assetRef.fSequencedAnimations objectForKey:propertyId];
            
            [layer setValue:((CABasicAnimation*)animation).toValue forKey:[animation valueForKey:@"property"]];
            [layer addAnimation:animation forKey:[animation valueForKey:@"property"]];
            
            break;
         }
      }
   }
   else 
   {
      if ([repeatType isEqualToString:@"CONTINUOUS"])
      {
         CAAnimation* animation = (CAAnimation*)assetRef.fStandaloneAnimation;
         
         // no need for a delegate
         animation.delegate = nil;
         animation.repeatCount = MAXFLOAT;
         
         // fire up the animation
         [layer addAnimation:animation forKey:[animation valueForKey:@"property"]];
      }
   }
   
   // is the entire animation triggered by one or more events?
   if (element.hasTrigger)
   {
      [self RegisterElementTriggers:element InView:view];
   }
   
   // does the element specify any post-animation notifications?
   if (nil != element.postAnimationNotification)
   {
      assetRef.fPostAnimationNotification = element.postAnimationNotification;
   }
}

-(void)RenderCustomLayerAnimationForElement:(NSDictionary*)element InView:(UIView*)view
{
   //DLog(@"RenderCustomeLayerAnimationForElement: %@", [element description]);
   
   if ([@"ATiltFollower" isEqualToString:element.animationClass])
   {
      DLog(@"ATiltFollower");
   }
   
   CALayer* layer = [self RenderStaticElementOnLayer:element InView:view];
   
   [view.layer addSublayer:layer];
   
   AAssetReference* assetRef = [self AddAssetReferenceWithElement:element AndLayer:layer];
   
   // determine which custom animation class to instantiate
   id customAnimationClass = objc_lookUpClass([element.animationClass cStringUsingEncoding:[NSString defaultCStringEncoding]]);
   id<ACustomAnimation> customAnimation = [[customAnimationClass alloc] InitWithAnimationSpec:element AssetRef:assetRef AndAssetManager:self];  
         
   assetRef.fCustomAnimation = customAnimation;
   
   if (element.hasTrigger)
   {
      [self RegisterElementTriggers:element InView:view];
   }
}

-(void)RenderCustomAnimation:(NSDictionary*)animationSpec ForAsset:(AAssetReference*)assetRef
{
   //DLog(@"RenderCustomAnimation:ForAsset %@", [animationSpec description]);
      
   // determine which custom animation class to instantiate
   id customAnimationClass = objc_lookUpClass([animationSpec.animationClass cStringUsingEncoding:[NSString defaultCStringEncoding]]);
   id<ACustomAnimation> customAnimation = [[customAnimationClass alloc] InitWithAnimationSpec:animationSpec AssetRef:assetRef AndAssetManager:self];  
   
   assetRef.fCustomAnimation = customAnimation;
   
   CAAnimation* animation = (CAAnimation*)customAnimation;
   
   [assetRef.fLayer addAnimation:animation forKey:[animation valueForKey:@"propertyId"]];
}

#pragma mark -
#pragma mark CAAnimation delegate protocol
-(void)animationDidStart:(CAAnimation*)animation
{
//   NSString* propertyId = [animation valueForKey:@"propertyId"];
//   NSLog(@"animation started: %@", propertyId);      
}

-(void)animationDidStop:(CAAnimation*)animation finished:(BOOL)flag
{
   NSString* propertyId = [animation valueForKey:@"propertyId"];
   AAssetReference* assetRef = [animation valueForKey:@"assetRef"];
   
   //NSLog(@"animation stopped: %@", propertyId);
            
   // determine which, if any, animation is next in the sequence and start it
   NSUInteger animationPosition = [assetRef.fSequencedAnimations indexForKey:propertyId];
   
   if (NSNotFound == animationPosition)
   {
      return;
   }
   
   NSUInteger indexOfNextAnimation = (++animationPosition) % [assetRef.fSequencedAnimations count];
   id nextAnimationKey = [assetRef.fSequencedAnimations keyAtIndex:indexOfNextAnimation];
   
   NSString* repeatType = (NSString*)[animation valueForKey:@"repeatType"];
   NSString* sequenceType = (NSString*)[animation valueForKey:@"sequenceType"];
   
   if ([@"CONTINUOUS" isEqualToString:repeatType])
   {
      // if the sequence is about to restart, check to see if a delay
      // is to occur between iterations of the sequence
      if (0 == indexOfNextAnimation)
      {
         if (![assetRef.fDelayType isEqualToString:kDelayTypeNone])
         {
            if ([assetRef.fDelayType isEqualToString:kDelayTypeFixed])
            {
               [NSTimer scheduledTimerWithTimeInterval:assetRef.fFixedDelay
                                                target:self
                                              selector:@selector(resumeAnimationSequence:)
                                              userInfo:[NSDictionary 
                                                        dictionaryWithObjectsAndKeys:animation, @"lastAnimation", 
                                                        nextAnimationKey, @"nextAnimationKey", 
                                                        nil]
                                               repeats:NO];
               return;
            }
            else if ([assetRef.fDelayType isEqualToString:kDelayTypeVariable])
            {
               CGFloat minimumDelay = assetRef.fDelayMinimum;
               CGFloat maximumDelay = assetRef.fDelayMaximum;
               
               CGFloat thisDelay = (CGFloat)(arc4random() % (int)maximumDelay);
               
               if (thisDelay < minimumDelay)
               {
                  thisDelay = minimumDelay;
               }
               else if (thisDelay > maximumDelay)
               {
                  thisDelay = maximumDelay;
               }
               
               //NSLog(@"whaleSpray delay: %f", thisDelay);
               
               [NSTimer scheduledTimerWithTimeInterval:thisDelay
                                                target:self
                                              selector:@selector(resumeAnimationSequence:)
                                              userInfo:[NSDictionary 
                                                        dictionaryWithObjectsAndKeys:animation, @"lastAnimation", 
                                                        nextAnimationKey, @"nextAnimationKey", 
                                                        nil]
                                               repeats:NO];
               return;            
               
            }
         }
      }
      
      [self ExecuteAnimationWithKey:nextAnimationKey PrecededBy:animation];
   }
   else // not a continuous animation
   {
      // before starting the next animation, lock in the value animated-to
      NSString* justAnimatedProperty = [animation valueForKey:@"property"];
      
      // !!! need to refactor this to make it generic !!!
      if ([@"bounds.size" isEqualToString:justAnimatedProperty])
      {
         CGRect layerBounds = assetRef.fLayer.bounds;
         
         //NSLog(@"size before (stopped): %f, %f", layerBounds.size.width, layerBounds.size.height);
         
         NSValue* layerSizeValue = ((CABasicAnimation*)animation).toValue;
         CGSize newSize = [layerSizeValue CGSizeValue];
         layerBounds.size = newSize;
         assetRef.fLayer.bounds = layerBounds;
         
         //NSLog(@"size after (stopped): %f, %f", layerBounds.size.width, layerBounds.size.height);
      }
      else if ([@"opacity" isEqualToString:justAnimatedProperty])
      {         
         NSNumber* finalOpacityNumber = ((CABasicAnimation*)animation).toValue;
         
         assetRef.fLayer.opacity = [finalOpacityNumber floatValue];     
      }
      
      // if the animation is sequenced, just update the index to specify the next
      // animation in the sequence (but don't trigger it now, of course)
      if ([@"SEQUENCED" isEqualToString:sequenceType])
      {
         assetRef.fActivePropertyIndex = indexOfNextAnimation;
      }
   }
}

-(void)resumeAnimationSequence:(NSTimer*)delayTimer
{
   NSDictionary* userInfo = [delayTimer userInfo];
   
   id nextAnimationKey = [userInfo objectForKey:@"nextAnimationKey"];
   CAAnimation* animation = [userInfo objectForKey:@"lastAnimation"];

   [self ExecuteAnimationWithKey:nextAnimationKey PrecededBy:animation];
   
   [delayTimer invalidate];
}

-(void)ExecuteAnimationWithKey:(id)nextAnimationKey PrecededBy:(CAAnimation*)animation
{
   AAssetReference* assetRef = (AAssetReference*)[animation valueForKey:@"assetRef"];
   
   CAAnimation* nextAnimation = [assetRef.fSequencedAnimations objectForKey:nextAnimationKey];
   
   // before starting the next animation, lock in the value animated-to
   NSString* justAnimatedProperty = [animation valueForKey:@"property"];
   
   // !!! need to refactor this to make it generic !!!
   if ([@"bounds.size" isEqualToString:justAnimatedProperty])
   {
      CGRect layerBounds = assetRef.fLayer.bounds;
      
      //NSLog(@"size before (stopped): %f, %f", layerBounds.size.width, layerBounds.size.height);
      
      NSValue* layerSizeValue = ((CABasicAnimation*)animation).toValue;
      CGSize newSize = [layerSizeValue CGSizeValue];
      layerBounds.size = newSize;
      assetRef.fLayer.bounds = layerBounds;
      
      //NSLog(@"size after (stopped): %f, %f", layerBounds.size.width, layerBounds.size.height);
   }
   else if ([@"opacity" isEqualToString:justAnimatedProperty])
   {
      CGRect layerBounds = assetRef.fLayer.bounds;
      
      //NSLog(@"size before (stopped): %f, %f", layerBounds.size.width, layerBounds.size.height);
      
      NSValue* layerSizeValue = ((CABasicAnimation*)nextAnimation).fromValue;
      CGSize newSize = [layerSizeValue CGSizeValue];
      layerBounds.size = newSize;
      assetRef.fLayer.bounds = layerBounds;
      
      //NSLog(@"size after (stopped): %f, %f", layerBounds.size.width, layerBounds.size.height);      
   }
   
   // start the next animation
   [assetRef.fLayer addAnimation:nextAnimation forKey:[nextAnimation valueForKey:@"property"]];
   
   // remove the previous animation (now that its value has been locked-in, above)
   [assetRef.fLayer removeAnimationForKey:[animation valueForKey:@"property"]];   
}

#pragma mark -
-(void)ProcessAnimationPropertyQueueForAssetRef:(AAssetReference*)assetRef
{
   NSDictionary* element = assetRef.fElement;
   
   NSString* assetName = (NSString*)[element valueForKey:@"resource"];
   NSString* assetPath = [[NSBundle mainBundle] pathForResource:assetName ofType:nil];
   
   NSArray* propertyList = (NSArray*)[element valueForKey:@"propertyList"];
   
   for (NSDictionary* property in propertyList)
   {
      NSDictionary* trigger = (NSDictionary*)[property valueForKey:@"trigger"];
      
      if (trigger && ((NSObject*)trigger != [NSNull null]))
      {
         NSString* type = (NSString*)[trigger valueForKey:@"type"];
         if ([type isEqualToString:@"COMPLETION"])
         {                        
            NSNumber* dependsOn = (NSNumber*)[trigger valueForKey:@"dependsOn"];
            if ((NSObject*)dependsOn != [NSNull null])
            {
               if (assetRef.fActivePropertyIndex == [dependsOn intValue])
               {
                  assetRef.fActivePropertyIndex++;
                  [self RenderAnimationProperty:property AndAsset:assetPath AndAnimationView:assetRef.fImgView AndIsForward:YES];
                  return;
               }
               else if ([propertyList indexOfObject:property] == ([propertyList count]-1) )
               {
                  /*
                  NSNumber* onCompletion = (NSNumber*)[trigger valueForKey:@"onCompletion"];
                  if (onCompletion && ((NSObject*)onCompletion != [NSNull null]))
                  {
                     assetRef.fActivePropertyIndex = [onCompletion intValue];
                     [self RenderAnimationProperty:[propertyList objectAtIndex:[onCompletion intValue]] AndAsset:assetPath AndAnimationView:assetRef.fImgView AndIsForward:YES];
                     return;
                  }
                  else
                  */
                  {
                     assetRef.fActivePropertyIndex = 0;
                  }
               }
            }
         }
      }
   }
}

// ACTIONs can be triggered at the completion of an animation element
-(void)ExecuteAction:(NSDictionary*)property
{
   // for now, the receiver of an Action is either 'self' or some
   // property of self
   id receiver = nil;
   
   NSString* receiverProperty = [property objectForKey:@"property"];
   NSString* methodName = [property objectForKey:@"action"];
   
   SEL methodSelector = NSSelectorFromString(methodName);
   
   if (nil != receiverProperty)
   {
      SEL receiverSelector = NSSelectorFromString(receiverProperty);
      
      receiver = [self performSelector:receiverSelector];
   }
   
   [receiver performSelector:methodSelector];
}

@end

@implementation AAssetManager

@synthesize chapterNumber = fChapterNumber;
@synthesize currentPage = fCurrentPage;
@synthesize assets = fAssets;
@synthesize assetPageReferences = fAssetPageReferences;
@synthesize controller = fController;
@synthesize delegate = fDelegate;
@synthesize tiltTimer = fTiltTimer;
@synthesize lastAcceleration = fLastAcceleration;
@synthesize shakeTimer = fShakeTimer;
@synthesize shakeStarted = fShakeStarted;

+(AAssetManager*)AssetManagerFromData:(NSData*)assetManagerData
{
   return (AAssetManager*)[NSKeyedUnarchiver unarchiveObjectWithData:assetManagerData];
}

-(id)initWithAssetsURL:(NSURL*)assetsURL
{
   self = [super init];
   
   if (self)
   {
      self.chapterNumber = 0;
      self.currentPage = 0;
      
      NSDictionary* assetsDict = [[NSDictionary alloc] initWithContentsOfURL:assetsURL];
      self.assets = assetsDict;
      [assetsDict release];
      
      self.assetPageReferences = [NSMutableArray array];
      self.tiltTimer = nil;
      self.shakeTimer = nil;
      self.lastAcceleration = nil;
      self.shakeStarted = NO;
   }
   
   return self;
}

-(NSUInteger)numPages
{
   return [self.assets.pages count];
}

-(NSUInteger)numLayoutPages
{
   return [[ABookManager sharedBookManager] NumberOfPagesInChapter:self.chapterNumber];
}

#pragma mark RenderAssetsForPage
-(void)RenderAssetsForPage:(NSUInteger)pageNum AndInView:(UIView*)view
{
   self.currentPage = pageNum;
   NSDictionary* currentPageDesc = [self GetCurrentPageDescriptor];

   AAssetPageReferences* assetPageRefs = [self AssetPageReferencesForPage:self.currentPage];

   if (assetPageRefs)
   {
      if (currentPageDesc)
      {
         NSArray* elements = (NSArray*)[currentPageDesc valueForKey:@"elements"];
         for (NSDictionary* element in elements)
         {
            AAssetReference* assetRef = nil;
            
            for (NSDictionary* property in element.propertyList)
            {
               NSDictionary* trigger = property.trigger;
               
               if (nil != trigger)
               {
                  NSString* type = trigger.type;
                  
                  if ([type isEqualToString:@"VISIBLE"])
                  {
                     assetRef = [assetPageRefs AssetReferenceForElement:element];
                     assetRef.fActivePropertyIndex = 0;

                     [self RenderAnimationProperty:property AndAsset:nil AndAnimationView:assetRef.fImgView AndIsForward:YES];
                  }
                  else if ([type isEqualToString:@"COMPLETION"])
                  {
                     [self RenderAnimationProperty:property AndAsset:[self GetAssetPathForElement:element] AndAnimationView:assetRef.fImgView AndIsForward:YES];   
                  }
               }
            }
         }
      }
   }
   else if (currentPageDesc)
   {
      AAssetPageReferences* apr = [[AAssetPageReferences alloc] initWithPage:self.currentPage];
      [self.assetPageReferences addObject:apr];
      [apr release];
            
      for (NSDictionary* element in currentPageDesc.elements)
      {
         BOOL onLayer = element.isOnLayer;
         
         NSString* type = element.type;
         
         if ([type isEqualToString:kImageType])
         {
            if (onLayer)
            {
               CALayer* layer = [self RenderStaticElementOnLayer:element InView:view]; 
               
               if (nil == layer)
               {
                  ALog(@"creation of element on layer failed - element: %@", [element description]);
                  
                  continue;
               }  
               
               [self AddAssetReferenceWithElement:element AndLayer:layer];
               
               for (NSDictionary* animationSpec in element.animations)
               {
                  [self RegisterAnimationTrigger:animationSpec InView:view];
               }
            }
         }
         else if ([type isEqualToString:kStaticType]) // !!! kStaticType will go away, eventually
         {
            if (onLayer)
            {
               CALayer* layer = [self RenderStaticElementOnLayer:element InView:view]; 
               
               if (nil != layer)
               {
                  [self AddAssetReferenceWithElement:element AndLayer:layer];
               }
            }
            else 
            {
               UIImageView* animationView = [self RenderStaticElement:element AndInView:view];
               [self AddAssetReferenceWithElement:element AndImgView:animationView];
            }
         }
         else if (([type isEqualToString:kAnimationType]) || ([type isEqualToString:kAnimationFramesType]))
         {
            if (onLayer)
            {
               // custom or standard animation?
               if (element.isCustomAnimation)
               {
                  [self RenderCustomLayerAnimationForElement:element InView:view];
               }
               else 
               {
                  [self RenderLayerAnimationForElement:element InView:view];
               }
            }
            else 
            {
               [self RenderAnimationForElement:element AndInView:view];   
            }
         }
         else if ([type isEqualToString:kAudioType])
         {
            [self RenderAudioForElement:element InView:view];
         }
         else
         {
            // assume a custom animation that
            // encapsulates all the setup and registration activities
            id customAnimationClass = NSClassFromString(element.customClass);
            
            // Currently, there are custom animations that expect to be view-based, in which case they will not
            // respond to initWithElement:AndAssetManager:InView:
            if ([customAnimationClass instancesRespondToSelector:@selector(initWithElement:AndAssetManager:InView:)])
            {
               id<ACustomAnimation> customAnimation = [[customAnimationClass alloc] initWithElement:element AndAssetManager:self InView:view];
               [self AddAssetReferenceWithElement:element AndCustomAnimation:customAnimation];
               [customAnimation release];
            }
            else
            {
               id<ACustomAnimation> customAnimation = [[customAnimationClass alloc] initWithElement:element RenderOnView:view];
               [customAnimation release];
            }
         }
      }
   }
}

-(BOOL)isPageIndexable:(NSInteger)pageNumber
{
   BOOL result = YES;
   
   NSDictionary* pageDescriptor = [self GetPageDescriptorForPage:pageNumber];
   
   if (nil != pageDescriptor)
   {
      // the very presence of the 'notIndexed' property in the plist means that the
      // associated page is NOT to be indexed
      NSNumber* isIndexedNumber = (NSNumber*)[pageDescriptor objectForKey:@"notIndexed"];
      
      if (nil != isIndexedNumber)
      {
         result = NO;
      }
   }
   
   return result;
}

-(AAssetPageReferences*)AssetPageReferencesForAssetRef:(AAssetReference*)assetRef
{
   AAssetPageReferences* (^findAssetRef) (AAssetReference* assetRef) = ^(AAssetReference* assetRef){
      
      AAssetPageReferences* result = nil;
      
      for (AAssetPageReferences* aPageRef in self.assetPageReferences)
      {
         if ([aPageRef.fPageAssetReferences containsObject:assetRef])
         {
            result = aPageRef;
            break;
         }
      }
      
      return result;
   };
   
   return findAssetRef(assetRef);
}

-(AAssetReference*)AddAssetReferenceWithElement:(NSDictionary*)element AndLayer:(CALayer*)layer
{
   AAssetReference* result = nil;
   
   NSDictionary* currentPage = [self GetCurrentPageDescriptor];
   
   AAssetPageReferences* assetPageReferences = [self AssetPageReferencesForPage:self.currentPage];
   if ((currentPage) && (![assetPageReferences AssetReferenceForElement:element]))
   {      
      NSArray* elements = (NSArray*)[currentPage valueForKey:@"elements"];
      
      AAssetReference* assetRef = [[AAssetReference alloc] initWithIndex:[elements indexOfObject:element] AndElement:element AndLayer:layer];
      
      [assetPageReferences.fPageAssetReferences addObject:assetRef];
      
      result = assetRef;
      [assetRef release];
   }   
   
   return result;
}

-(AAssetReference*)AddAssetReferenceWithElement:(NSDictionary*)element AndCustomAnimation:(id<ACustomAnimation>)customAnimation
{
   AAssetReference* result = nil;
   
   NSDictionary* currentPage = [self GetCurrentPageDescriptor];
   
   AAssetPageReferences* assetPageReferences = [self AssetPageReferencesForPage:self.currentPage];
   
   if ((currentPage) && (![assetPageReferences AssetReferenceForElement:element]))
   {      
      NSArray* elements = (NSArray*)[currentPage valueForKey:@"elements"];
      
      AAssetReference* assetRef = [[AAssetReference alloc] initWithIndex:[elements indexOfObject:element] AndElement:element AndCustomAnimation:customAnimation];
      
      [assetPageReferences.fPageAssetReferences addObject:assetRef];
      
      result = assetRef;
      [assetRef release];
   }   
   
   return result;   
}

-(void)RegisterElementTriggers:(NSDictionary*)element InView:(UIView*)view
{
   NSDictionary* elementLevelTrigger = element.trigger;
   
   if (nil == elementLevelTrigger)
   {
      return;
   }
   
   [self RegisterTrigger:elementLevelTrigger InView:view];
}

-(void)RegisterTrigger:(NSDictionary*)triggerSpec InView:(UIView*)view
{
   NSString* triggerType = triggerSpec.type;
   
   if ([triggerType isEqualToString:@"TOUCH"])
   {
      view.userInteractionEnabled = YES;
      
      UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
      tapRecognizer.cancelsTouchesInView = NO;
      tapRecognizer.numberOfTapsRequired = 1;
      tapRecognizer.numberOfTouchesRequired = 1;
      [view addGestureRecognizer:tapRecognizer];
      [tapRecognizer release];	
   }
   else if ([triggerType isEqualToString:@"TILT"])
   {
      // start motion manager monitoring
      [[AMotionManager sharedMotionManager].cmMotionManager startAccelerometerUpdates];
      self.tiltTimer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                        target:self
                                                      selector:@selector(monitorDeviceAttitude:)
                                                      userInfo:nil
                                                       repeats:YES];   
   }
   else if ([triggerType isEqualToString:@"DELAY"])
   {
      NSNumber* duration = (NSNumber*)[triggerSpec valueForKey:@"duration"];
      [NSTimer scheduledTimerWithTimeInterval:[duration floatValue]
                                       target:self
                                     selector:@selector(TriggerAnimationAfterDelay:)
                                     userInfo:nil
                                      repeats:NO];   
   }
   else if ([triggerType isEqualToString:@"SHAKE"])
   {
      // start motion manager monitoring - we're assuming here that calling
      // startAccelerometerUpdates multiple times on the CMMotionManager has
      // no negative effects
      if (nil == self.shakeTimer)
      {
         [[AMotionManager sharedMotionManager].cmMotionManager startAccelerometerUpdates];
         self.shakeTimer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                            target:self
                                                          selector:@selector(monitorDeviceShake:)
                                                          userInfo:nil
                                                           repeats:YES]; 
      }      
   } 
   else if ([triggerType isEqualToString:@"PAN"])
   {
      UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
      panRecognizer.cancelsTouchesInView = YES;
      
      panRecognizer.minimumNumberOfTouches = triggerSpec.minTouches;
      panRecognizer.maximumNumberOfTouches = triggerSpec.maxTouches;
      
      [view addGestureRecognizer:panRecognizer];
      [panRecognizer release];      
   }
}

-(void)dealloc
{
   //DLog(@"deallocating AssetManager %p, retainCount = %d", self, [self retainCount]);
   
   [fAssets release];
   //DLog(@"released fAssets - retainCount = %d", [fAssets retainCount]);
   
   
   [fAssetPageReferences release];   
   [fController release];

   if (nil != fTiltTimer)
   {
      [fTiltTimer invalidate];
      [fTiltTimer release];
      fTiltTimer = nil;      
   }

   if (nil != fShakeTimer)
   {
      [fShakeTimer invalidate];
      [fShakeTimer release];
      fShakeTimer = nil;      
   }

   [super dealloc];
}

-(id)retain
{
   id retainedSelf = [super retain];
   
   NSUInteger count = [self retainCount];
   
   if (2 < count)
   {
      //DLog(@"retaining AAssetManager %p, retainCount = %d", self, [self retainCount]);
   }
   
   return retainedSelf;
}

@end
