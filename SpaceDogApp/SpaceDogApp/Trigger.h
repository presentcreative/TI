// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "CustomAnimation.h"

typedef enum
{
   kNoTilt,
   kTiltingLeft,
   kTiltingRight
} TiltDirection;

typedef enum
{
   kDirectionalChange,
   kAlways
} TiltNotificationEvent;

@interface ATrigger : NSObject <UIGestureRecognizerDelegate, UIAccelerometerDelegate>
{
   id<ACustomAnimation> fAnimation;
   
   NSString* fType;
   
   NSMutableArray* fRegions;
   
   NSString* fInitiationNotification;
   NSInteger fInitiationNotificationValue;
   
   BOOL fToggle;
   
   NSString* fTriggerMethod;
   BOOL fAllowsConcurrentTrigger;
   
   BOOL fGated;
   NSString* fEnablingNotification;
   NSString* fDisablingNotification;
   BOOL fEnabled;
   
   CGFloat fAccelerometerSampleRate;
   
   CGFloat fShakeThreshold;
   UIAcceleration* fLastAcceleration;
   BOOL fShakeStarted;

   CGFloat fTriggerAngle;
   TiltDirection fTiltDirection;
   TiltNotificationEvent fTiltNotificationEvent;
   
   CGFloat fPrevX;
   CGFloat fPrevY;
   CGFloat fPrevZ;
   
   NSTimer* fTimer;
   CGFloat fInterval;
   BOOL fRepeats;
   
   BOOL fActivated;
   BOOL fBecomeAccelerometerDelegateOnActivation;
}

@property (assign) id<ACustomAnimation> animation; // N.B. weak reference
@property (copy) NSString* type;
@property (nonatomic, retain) NSMutableArray* regions;
@property (copy) NSString* initiationNotification;
@property (assign) NSInteger initiationNotificationValue;
@property (assign, getter=isToggle) BOOL toggle;
@property (copy) NSString* triggerMethod;
@property (assign) BOOL allowsConcurrentTrigger;
@property (nonatomic, retain) UIAcceleration* lastAcceleration;
@property (assign) CGFloat accelerometerSampleRate;
@property (assign) CGFloat shakeThreshold;
@property (assign, getter=hasShakeStarted) BOOL shakeStarted;
@property (assign) TiltDirection tiltDirection;
@property (assign) TiltNotificationEvent tiltNotificationEvent;
@property (assign) CGFloat triggerAngle;

@property (assign, getter = isGated) BOOL gated;
@property (copy) NSString* enablingNotification;
@property (copy) NSString* disablingNotification;
@property (assign, getter = isEnabled) BOOL enabled;

// TRUE: the trigger is ready to fire; FALSE: it won't
@property (assign, getter = isActivated) BOOL activated;

// TRUE: receiver becomes the accelerometer delegate upon being activated; FALSE: it won't
// N.B. if TRUE, receiver will remove itself as the accelerometer's delegate when the
//      the receiver is de-activated
@property (assign) BOOL becomesAccelerometerDelegateOnActivation;

@property (nonatomic, retain) NSTimer* timer;
@property (assign) CGFloat interval;
@property (assign) BOOL repeats;

@property (readonly) BOOL isShakeTrigger;
@property (readonly) BOOL isTiltTrigger;

@property (assign) CGFloat prevX;
@property (assign) CGFloat prevY;
@property (assign) CGFloat prevZ;

-(ATrigger*)initWithTriggerSpec:(NSDictionary*)triggerSpec ForAnimation:(id<ACustomAnimation>)animation OnView:(UIView*)view;

-(void)NotificationReceived:(NSNotification*)notification;

// force the receiver to become the accelerometer's delegate
-(void)BecomeAccelerometerDelegate;

// free the receiver from being the accelerometer's delegate
-(void)BecomeFreeOfAccelerometer;

@end
