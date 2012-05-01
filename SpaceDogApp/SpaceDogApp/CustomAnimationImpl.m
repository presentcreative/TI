// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "CustomAnimationImpl.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "ZRotation.h"
#import "Trigger.h"

@interface ACustomAnimationImpl (Private)
-(void)BaseStart:(NSTimer*)timer;
-(void)StartAnimation;
@end


@implementation ACustomAnimationImpl

@synthesize keyPath = fKeyPath;
@synthesize duration = fDuration;
@synthesize delay = fDelay;
@synthesize sequenceId = fSequenceId;
@synthesize repeatType = fRepeatType;
@synthesize numRepeats = fNumRepeats;
@synthesize resourceBase = fResourceBase;
@synthesize resource = fResource;
@synthesize frame = fFrame;
@synthesize layer = fLayer;
@synthesize autoReverse = fAutoReverse;
@synthesize timingFunctionName = fTimingFunctionName;
@synthesize completionNotification = fCompletionNotification;
@synthesize autoStart = fAutoStart;
@synthesize soundEffect = fSoundEffect;
@synthesize oneShot = fOneShot;
@synthesize fireCount = fFireCount;
@synthesize animationId=fAnimationId;
@synthesize delegate=fDelegate;

+(Class)layerClass
{
   return [CALayer class];
}

-(void)dealloc
{
   self.layer.delegate = nil;
   if (self.layer.superlayer)
   {
      [self.layer removeFromSuperlayer];
   }
   Release(fLayer);
   Release(fAnimationId);
   Release(fKeyPath);
   Release(fRepeatType);
   Release(fSequenceId);
   Release(fResourceBase);
   Release(fResource);
   Release(fTimingFunctionName);
   Release(fCompletionNotification);
   Release(fSoundEffect);

   [super dealloc];
}

-(void)BaseInit
{
   self.keyPath = @"";
   self.duration = 0.0f;
   self.delay = 0.0f;
   self.sequenceId = @"";
   self.repeatType = @"NONE";
   self.numRepeats = 0;
   self.resourceBase = @"";
   self.resource = @"";
   self.frame = CGRectZero;
   self.layer = nil;
   self.autoReverse = NO;
   self.timingFunctionName = @"";
   self.completionNotification = @"";
   self.autoStart = NO;
   self.oneShot = NO;
   self.fireCount = 0;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   CALayer* layer = [[[self class] layerClass] layer];
   
   [self BaseInitWithElement:element RenderOnLayer:layer];
   
   // it's assumed that sound effects are triggered in some manner
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
      
   if ([view isKindOfClass:[ABookView class]])
   {
      [(ABookView*)view RegisterAsset:self WithKey:self.sequenceId];
   }
   
   // assume subAnimations...
   for (NSDictionary* subAnimationSpec in element.subAnimations)
   {
      // Each animation will run on its own layer
      id customAnimationClass = NSClassFromString(subAnimationSpec.customClass);
      
      if ([customAnimationClass instancesRespondToSelector:@selector(initWithElement:RenderOnLayer:)])
      {
         id<ACustomAnimation> customAnimation = [[customAnimationClass alloc] initWithElement:subAnimationSpec RenderOnLayer:layer];
         
         DLog(@"");
         
         if ([view isKindOfClass:[ABookView class]])
         {
            [(ABookView*)view RegisterAsset:customAnimation WithKey:self.sequenceId];
         }
         
         [(NSObject*)customAnimation release];
      }
   }
   
   [view.layer addSublayer:layer];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   self.layer = layer;
   
   // mandatory specs
   self.sequenceId = element.propertyId;
      
   self.frame = element.frame;
   
   self.layer.frame = self.frame;
   
   self.keyPath = element.keyPath;
   
   // optional specs or defaulted specs
   self.autoStart = element.autoStart;
   self.autoReverse = element.autoReverse;
   
   self.oneShot = element.oneShot;
   
   if (element.isResourceBaseBased)
   {
      self.resourceBase = element.resourceBase;
   }
   else if (element.isResourceBased)
   {
      self.resource = element.resource;
   }
   
   if (element.hasDuration)
   {
      self.duration = element.duration;
   }
   
   if (element.hasDelay)
   {
      self.delay = element.delay;
   }
   
   if (element.hasNumRepeats)
   {
      self.numRepeats = element.numRepeats;
   }
   
   if (element.hasRepeatType)
   {
      self.repeatType = element.repeatType;
   }
   
   if (element.hasInitialAlpha)
   {
      self.layer.opacity = element.initialAlpha;
   }
   
   if (element.hasTimingFunctionName)
   {
      self.timingFunctionName = element.timingFunctionName;
   }
   
   if (element.hasPostAnimationNotification)
   {
      self.completionNotification = element.postAnimationNotification;
   }
         
   // load the asset...
   NSString* resourceName = @"";
   
   if (![@"" isEqualToString:self.resourceBase])
   {
      resourceName = self.resourceBase;
   }
   else 
   {
      resourceName = self.resource;
   }
   
   if (![@"" isEqualToString:resourceName])
   {
      NSString* assetPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:nil];
      
      if ([[NSFileManager defaultManager] fileExistsAtPath:assetPath])
      {
         UIImage* image = [[UIImage alloc] initWithContentsOfFile:assetPath];
         [layer setContents:(id)image.CGImage];
         [image release];
      }
   }
   
   // is there a sound effect associated with this animation?
   if (element.hasSoundEffect)
   {
      Class soundEffectClass = NSClassFromString(element.soundEffect.customClass);
      id<ACustomAnimation> sound = [[soundEffectClass alloc] initWithElement:element.soundEffect RenderOnView:nil];
      self.soundEffect = sound;
      [(NSObject*)sound release];
   }
}

-(Class)animationClass
{
   return [CABasicAnimation class];
}

-(CAAnimation*)animation
{
   CAAnimation* result = [[self animationClass] animationWithKeyPath:self.keyPath];
      
   result.duration = self.duration;
   
   if ([@"CONTINUOUS" isEqualToString:self.repeatType])
   {
      result.repeatCount = NSUIntegerMax;
      result.autoreverses = YES;
   }
   else 
   {
      result.autoreverses = self.autoReverse;
      result.repeatCount = self.numRepeats;
   }

   
   NSString* timingFunctionId;
   
   if ([@"Linear" isEqualToString:self.timingFunctionName])
   {
      timingFunctionId = kCAMediaTimingFunctionLinear;
   }
   else if ([@"EaseIn" isEqualToString:self.timingFunctionName])
   {
      timingFunctionId = kCAMediaTimingFunctionEaseIn;
   }
   else if ([@"EaseOut" isEqualToString:self.timingFunctionName])
   {
      timingFunctionId = kCAMediaTimingFunctionEaseOut;
   }
   else if ([@"EaseInEaseOut" isEqualToString:self.timingFunctionName])
   {
      timingFunctionId = kCAMediaTimingFunctionEaseInEaseOut;
   }
   else 
   {
      timingFunctionId = kCAMediaTimingFunctionDefault;
   }
   
   result.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionId];
   
   // presence of a non-nil delegate property overrides presence of a completionNotification value
   if (nil != self.delegate)
   {
      result.delegate = self.delegate;
   }
   else 
   {
      // is the receiver required to issue any notifications when it completes?
      if (![@"" isEqualToString:self.completionNotification])
      {
         // make the receiver the delegate of the animation so that it can issue
         // a notification at the animation's completion
         result.delegate = self;
      }      
   }
      
   return result;
}

-(NSString*)animationKey
{
   return self.sequenceId;
}

-(void)BaseStart:(NSTimer*)timer
{
   if (nil != timer)
   {
      if ([timer isValid])
      {
         // TODO: determine constant or variable delay and set new timeInterval
         //       accordingly
      }
   }
   
   [self StartAnimation];
   
   if (nil != self.soundEffect)
   {
      [self.soundEffect Start:NO];
   }
}

-(void)StartAnimation
{
   [self.layer addAnimation:self.animation forKey:self.animationKey];   
}

#pragma mark -
#pragma mark ACustomAnimation protocol

-(id<ACustomAnimation>)initWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   if (self = [super init])
   {
      [self BaseInit];
      [self BaseInitWithElement:element RenderOnView:view];
   }
   
   return self;
}

-(id<ACustomAnimation>)initWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   if (self = [super init])
   {
      [self BaseInit];
      [self BaseInitWithElement:element RenderOnLayer:layer];
   }
   
   return self;
}

-(void)Start:(BOOL)triggered
{
   if (self.isOneShot && 0 < self.fireCount)
   {
      return;
   }
      
   if (0.0f != self.delay)
   {
      [NSTimer scheduledTimerWithTimeInterval:self.delay
                                       target:self
                                     selector:@selector(BaseStart:)
                                     userInfo:nil
                                      repeats:NO];
   }
   else
   {
      [self BaseStart:nil];
   }
   
   self.fireCount = self.fireCount + 1;
}

-(void)Stop
{   
   [self.layer removeAllAnimations];
}

-(void)DisplayLinkDidTick:(CADisplayLink *)displayLink
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol
}


-(void)Trigger
{
   [self Start:YES];
}

-(void)Trigger:(NSNotification*)notification
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.   
}


-(void)TriggerWithSpec:(NSDictionary*)triggerSpec
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(IBAction)HandleGesture:(UIGestureRecognizer*)recognizer
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(void)HandleTilt:(NSDictionary*)tiltInfo
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.   
}

-(void)NotificationReceived:(NSNotification*)notification
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(void)MotionUpdated:(CMDeviceMotion*)deviceMotion
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.   
}

#pragma mark -
#pragma mark CAAnimation delegate protocol
-(void)animationDidStop:(CABasicAnimation*)anim finished:(BOOL)animationFinished
{
   if (animationFinished)
   {      
      // notify any interested parties that this animatiion has completed
      if (![@"" isEqualToString:self.completionNotification])
      {
         [[NSNotificationCenter defaultCenter]
          postNotificationName:self.completionNotification
          object:nil];
      }
   }
}

@end
