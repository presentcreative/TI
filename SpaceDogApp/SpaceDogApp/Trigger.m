// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Trigger.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "NSArray+PropertyValues.h"
#import "BookView.h"
#import "Constants.h"
#import "DelegateDistributor.h"

#define kDownSwipe   @"DOWN"
#define kLeftSwipe   @"LEFT"
#define kRightSwipe  @"RIGHT"
#define kUpSwipe     @"UP"

@implementation ATrigger

@synthesize animation = fAnimation;
@synthesize type = fType;
@synthesize regions = fRegions;
@synthesize initiationNotification = fInitiationNotification;
@synthesize initiationNotificationValue = fInitiationNotificationValue;
@synthesize toggle = fToggle;
@synthesize triggerMethod = fTriggerMethod;
@synthesize allowsConcurrentTrigger = fAllowsConcurrentTrigger;
@synthesize accelerometerSampleRate = fAccelerometerSampleRate;
@synthesize shakeThreshold = fShakeThreshold;
@synthesize lastAcceleration = fLastAcceleration;
@synthesize shakeStarted = fShakeStarted;
@synthesize triggerAngle = fTriggerAngle;
@synthesize tiltDirection = fTiltDirection;
@synthesize tiltNotificationEvent=fTiltNotificationEvent;
@synthesize prevX=fPrevX;
@synthesize prevY=fPrevY;
@synthesize prevZ=fPrevZ;
@synthesize timer=fTimer;
@synthesize interval=fInterval;
@synthesize repeats=fRepeats;
@synthesize gated=fGated;
@synthesize enablingNotification=fEnablingNotification;
@synthesize disablingNotification=fDisablingNotification;
@synthesize enabled=fEnabled;
@synthesize becomesAccelerometerDelegateOnActivation=fBecomeAccelerometerDelegateOnActivation;

-(ATrigger*)initWithTriggerSpec:(NSDictionary*)triggerSpec ForAnimation:(id<ACustomAnimation>)animation OnView:(UIView*)view
{
   if (self = [self init])
   {
      //DLog(@"creating Trigger (%p) for page no. %d", result, ((ABookView*)view).pageNumber);
      
      self.animation = animation;
      
      // all triggers have to have a type...
      self.type = triggerSpec.type;
      
      // does the trigger toggle the effect of the animation?
      if (triggerSpec.hasToggleProperty)
      {
         self.toggle = triggerSpec.toggle;
      }
      
      self.allowsConcurrentTrigger = triggerSpec.allowsConcurrentTrigger;
      
      // should the animation be triggered using some non-default method?
      if (triggerSpec.hasTriggerMethod)
      {
         self.triggerMethod = triggerSpec.triggerMethod;
      }
      
      // is the trigger to be gated, i.e. only active under certain conditions?
      if (triggerSpec.hasGatedProperty)
      {
         self.gated = triggerSpec.gated;
         self.enablingNotification = triggerSpec.enablingNotification;
         self.disablingNotification = triggerSpec.disablingNotification;
         self.enabled = NO;
         
         // register the receiver to receive the Notifications
         [[NSNotificationCenter defaultCenter]
          addObserver:self 
          selector:@selector(EnablingNotificationReceived:)
          name:self.enablingNotification
          object:nil];
         
         [[NSNotificationCenter defaultCenter]
          addObserver:self 
          selector:@selector(DisablingNotificationReceived:)
          name:self.disablingNotification
          object:nil];
      }
      
      if ([@"NOTIFICATION" isEqualToString:self.type])
      {
         self.initiationNotification = triggerSpec.name;
         self.initiationNotificationValue = triggerSpec.dataValue;
         
         // register the receiver to receive the Notification
         [[NSNotificationCenter defaultCenter]
          addObserver:self 
          selector:@selector(NotificationReceived:)
          name:self.initiationNotification
          object:nil];
      }
      else if ([@"TOUCH" isEqualToString:self.type])
      {
         // touch triggers need to have defined one or more activation regions
         for (NSArray* region in triggerSpec.regions)
         {
            [self.regions addObject:[NSValue valueWithCGRect:[region asCGRect]]];
         }
         
         // touches are detected by UITapGestureRecognizers
         UITapGestureRecognizer* touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleTouch:)];
         touchRecognizer.delegate = self;
         touchRecognizer.cancelsTouchesInView = NO;
         touchRecognizer.numberOfTapsRequired = 1;
         touchRecognizer.numberOfTouchesRequired = 1;
         
         view.userInteractionEnabled = YES;
         [view addGestureRecognizer:touchRecognizer];
         
         //DLog(@"creating UITapGestureRecognizer %p (delegate is ATrigger %p)", touchRecognizer, result);
         
         [touchRecognizer release];
      }
      else if ([@"PAN" isEqualToString:self.type])
      {
         // touch triggers need to have defined one or more activation regions
         for (NSArray* region in triggerSpec.regions)
         {
            [self.regions addObject:[NSValue valueWithCGRect:[region asCGRect]]];
         }
         
         UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandleGesture:)];
         panRecognizer.delegate = self;
         panRecognizer.cancelsTouchesInView = YES;
         
         panRecognizer.minimumNumberOfTouches = triggerSpec.minTouches;
         panRecognizer.maximumNumberOfTouches = triggerSpec.maxTouches;
         
         [view addGestureRecognizer:panRecognizer];
         [panRecognizer release];          
      }
      else if ([@"SWIPE" isEqualToString:self.type])
      {
         // swipe triggers need to have defined one or more activation regions
         for (NSArray* region in triggerSpec.regions)
         {
            [self.regions addObject:[NSValue valueWithCGRect:[region asCGRect]]];
         }
         
         UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleSwipe:)];
         swipeRecognizer.delegate = self;
         swipeRecognizer.cancelsTouchesInView = YES;
         
         swipeRecognizer.numberOfTouchesRequired = triggerSpec.numberOfTouchesRequired;
         
         if ([kDownSwipe isEqualToString:triggerSpec.swipeDirection])
         {
            swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
         }
         else if ([kLeftSwipe isEqualToString:triggerSpec.swipeDirection])
         {
            swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
         }
         else if ([kRightSwipe isEqualToString:triggerSpec.swipeDirection])
         {
            swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
         }
         else if ([kUpSwipe isEqualToString:triggerSpec.swipeDirection])
         {
            swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
         }
         else
         {
            NSAssert(YES, @"Unknown direction provided to SWIPE trigger: %@", triggerSpec.swipeDirection);
         }
                  
         [view addGestureRecognizer:swipeRecognizer];
         [swipeRecognizer release];          
      }
      else if ([@"SHAKE" isEqualToString:self.type])
      {
         // the shakeThreshold shouldn't be too sensitive...
         self.shakeThreshold = triggerSpec.shakeThreshold;
         
         // the sampleRate shouldn't be more frequent than necessary...
         self.accelerometerSampleRate = triggerSpec.accelerometerSampleRate;
         
         // auto delegate accelerometer?
         self.becomesAccelerometerDelegateOnActivation = triggerSpec.autoBecomeAccelerometerDelegate;
      }
      else if ([@"TILT" isEqualToString:self.type])
      {
         self.triggerAngle = triggerSpec.triggerAngle;
         
         // the sampleRate shouldn't be more frequent than necessary...
         self.accelerometerSampleRate = triggerSpec.accelerometerSampleRate;
         
         // what triggers a tilt notification?
         NSString* tiltNotificationName = triggerSpec.tiltNotificationEvent;
         
         if ([@"DIRECTIONAL_CHANGE" isEqualToString:tiltNotificationName])
         {
            self.tiltNotificationEvent = kDirectionalChange;
         }
         else if ([@"ALWAYS" isEqualToString:tiltNotificationName])
         {
            self.tiltNotificationEvent = kAlways;
         }
         
         self.becomesAccelerometerDelegateOnActivation = triggerSpec.autoBecomeAccelerometerDelegate;
      }
      else if ([@"TIMER" isEqualToString:self.type])
      {
         self.interval = triggerSpec.interval;
         self.repeats = triggerSpec.repeats;
         
         self.timer = [NSTimer timerWithTimeInterval:self.interval 
                                                target:self 
                                              selector:@selector(HandleTimer:) 
                                              userInfo:nil 
                                               repeats:self.repeats];
         
         // ensure that the timer is started on the main thread - if it's not,
         // it'll never fire :))
         [self performSelectorOnMainThread:@selector(StartTriggerTimer:) withObject:nil waitUntilDone:YES];
      }
      else 
      {
         ALog(@"unknown trigger type: %@", triggerSpec.type);
      }
      
      if ([view isKindOfClass:[ABookView class]])
      {
         ABookView* bookView = (ABookView*)view;
         [bookView.triggersOnView addObject:self];
      }
   }
   
   return self;
}

-(id)init
{
   if (self = [super init])
   {
      self.animation = nil;
      self.type = @"";
      self.regions = [NSMutableArray array];
      self.initiationNotification = @"";
      self.initiationNotificationValue = -1;
      self.toggle = NO;
      self.triggerMethod = @"";
      self.allowsConcurrentTrigger = NO;
      self.lastAcceleration = nil;
      self.shakeStarted = NO;
      self.tiltDirection = kNoTilt;
      self.tiltNotificationEvent = kDirectionalChange;
      self.triggerAngle = 0.0f;
      self.prevX = 0.0f;
      self.prevY = 0.0f;
      self.prevZ = 0.0f;
      self.gated = NO;
      self.enablingNotification = @"";
      self.disablingNotification = @"";
      self.enabled = YES;
      self.activated = NO;
      self.becomesAccelerometerDelegateOnActivation = NO;
   }
   
   return self;
}

-(void)dealloc
{
   if (![@"" isEqualToString:self.initiationNotification])
   {
      [[NSNotificationCenter defaultCenter] removeObserver:self];
   }
   
   if (self.isGated)
   {
      [[NSNotificationCenter defaultCenter] removeObserver:self];
   }
   
   if (self.isShakeTrigger || self.isTiltTrigger)
   {
      [UIAccelerometer sharedAccelerometer].delegate = nil;
   }
   
   if (nil != self.timer)
   {
      [self.timer invalidate];
      Release(fTimer);
   }
      
   Release(fType);
   Release(fRegions);
   Release(fInitiationNotification);
   Release(fTriggerMethod);
   Release(fLastAcceleration);
   Release(fEnablingNotification);
   Release(fDisablingNotification);
   
   //NSLog(@"ATrigger deallocated");
   
   [super dealloc];
}

-(BOOL)activated
{
   return fActivated;
}

-(void)setActivated:(BOOL)activated
{
   fActivated = activated;
   
   if (self.becomesAccelerometerDelegateOnActivation)
   {
      if (fActivated)
      {
         [self BecomeAccelerometerDelegate];
      }
      else
      {
         [self BecomeFreeOfAccelerometer];
      }
   }
}

-(BOOL)isActivated
{
   return fActivated;
}

-(void)BecomeAccelerometerDelegate
{
   [[ADelegateDistributor sharedDelegateDistributor] AddAccelerometerDelegate:self];
}

-(void)BecomeFreeOfAccelerometer
{
   [[ADelegateDistributor sharedDelegateDistributor] RemoveAccelerometerDelegate:self];
}

-(void)StartTriggerTimer:(id)someParameterObject
{
   [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

-(BOOL)isShakeTrigger
{
   return [@"SHAKE" isEqualToString:self.type];
}

-(BOOL)isTiltTrigger
{
   return [@"TILT" isEqualToString:self.type];
}

-(void)NotificationReceived:(NSNotification*)notification
{
   if (!self.isActivated)
   {
      // Only process this notification if the trigger
      //  has been activated.
      return;
   }
   NSDictionary* userInfo = [notification userInfo];
   
   if (nil != userInfo)
   {
      NSInteger dataValue = userInfo.dataValue;
      
      if (dataValue != self.initiationNotificationValue)
      {
         return;
      }
   }
   
   if (![@"" isEqualToString:self.triggerMethod])
   {
      [(NSObject*)self.animation performSelector:NSSelectorFromString(self.triggerMethod)];
   }
   else if ([(NSObject*)self.animation respondsToSelector:@selector(Trigger:)])
   {
      [self.animation Trigger:notification];
   }
   else 
   {
      [self.animation Trigger];
   }
}

-(void)EnablingNotificationReceived:(NSNotification*)notification
{
   self.enabled = YES;
}

-(void)DisablingNotificationReceived:(NSNotification*)notification
{
   self.enabled = NO;
}

-(void)HandleTouch:(UIGestureRecognizer*)recognizer
{
   if (!self.isActivated)
   {
      // Only process this notification if the trigger
      //  has been activated.
      return;
   }
   
   // TODO: 'gated' is only implemented for TOUCH triggers, at the moment
   if (self.isGated)
   {
      if (!self.isEnabled)
      {
         return;
      }
   }
   
   if ([(NSObject*)self.animation respondsToSelector:@selector(TriggerWithRecognizer:)])
   {
      [self.animation TriggerWithRecognizer:recognizer];
   }
   else
   {
      [self.animation Trigger];
   }
}

-(void)HandleGesture:(UIGestureRecognizer*)recognizer
{
   if (!self.isActivated)
   {
      // Only process this notification if the trigger
      //  has been activated.
      return;
   }
   
   [self.animation HandleGesture:recognizer];
}

-(void)HandleSwipe:(UIGestureRecognizer*)recognizer
{
   if (!self.isActivated)
   {
      // Only process this notification if the trigger
      //  has been activated.
      return;
   }
   
   [self.animation Trigger];
}

-(BOOL)DeviceIsShaking:(UIAcceleration*)accelData
{   
   double deltaX = fabs(self.lastAcceleration.x - accelData.x);
   double deltaY = fabs(self.lastAcceleration.y - accelData.y);
   double deltaZ = fabs(self.lastAcceleration.z - accelData.z);
   
   return 
   (deltaX > self.shakeThreshold && deltaY > self.shakeThreshold) ||
   (deltaX > self.shakeThreshold && deltaZ > self.shakeThreshold) ||
   (deltaY > self.shakeThreshold && deltaZ > self.shakeThreshold);
}

-(void)HandleShake:(UIAcceleration*)acceleration
{
   if (!self.isActivated)
   {
      // Only process this notification if the trigger
      //  has been activated.
      return;
   }
   if (nil != self.lastAcceleration)
   {
      if (!self.hasShakeStarted && [self DeviceIsShaking:acceleration])
      {
         self.shakeStarted = YES;
      }
      else if (self.hasShakeStarted && ![self DeviceIsShaking:acceleration])
      {
         self.shakeStarted = NO;
      }
      else if (self.hasShakeStarted && [self DeviceIsShaking:acceleration])
      {
         [self.animation Trigger];
      }
   }
   else
   {
      self.lastAcceleration = acceleration;   
   }
}

-(void)HandleTilt:(UIAcceleration*)acceleration
{   
   if (!self.isActivated)
   {
      // Only process this notification if the trigger
      //  has been activated.
      return;
   }
   if (0.0f == self.prevX && 0.0f == self.prevY && 0.0f == self.prevZ)
   {
      self.prevX = acceleration.x;
      self.prevY = acceleration.y;
      self.prevZ = acceleration.z;
      
      return;
   }
   
   // apply a low-pass filter to the incoming acceleration data
   self.prevX = acceleration.x * kFilterFactor + self.prevX * (1.0 - kFilterFactor);
   self.prevY = acceleration.y * kFilterFactor + self.prevY * (1.0 - kFilterFactor);
   self.prevZ = acceleration.z * kFilterFactor + self.prevZ * (1.0 - kFilterFactor);
   
   float R = sqrt(pow(self.prevX,2)+pow(self.prevY,2)+pow(self.prevZ,2));
   
   // float aRx = acos(self.prevX/R);
   // float aRz = acos(self.prevZ/R);   
   
   float aRy = acos(self.prevY/R);
   
   float deviceTiltAngle = RADIANS_TO_DEGREES(aRy);
      
   TiltDirection localTilt = kNoTilt;
   

   UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
   
   AccelerationData ad;
   
   ad.x = acceleration.x;
   ad.y = acceleration.y;
   ad.z = acceleration.z;
   
   // if currentOrientation == UIInterfaceOrientationLandscapeRight (Home button on the right),
   // then angles DECREASE in value as the device is moved CCW around the y axis, INCREASE in value
   // as the device is moved CW around the y axis.
   
   if (UIInterfaceOrientationLandscapeRight==currentOrientation)
   {
      //NSLog(@"home button RIGHT, tilt angle = %f", deviceTiltAngle);
      // Home button on right
      if (deviceTiltAngle < 90.0f)
      {
         localTilt = kTiltingLeft;
      }
      else if (deviceTiltAngle > 90.0f)
      {
         localTilt = kTiltingRight;
      }
      else 
      {
         localTilt = kNoTilt;
      }
   }
   else if (UIInterfaceOrientationLandscapeLeft==currentOrientation)
   {
      //NSLog(@"home button LEFT, tilt angle = %f", deviceTiltAngle);
      // Home button on left
      if (deviceTiltAngle < 90.0f)
      {
         localTilt = kTiltingRight;
      }
      else if (deviceTiltAngle > 90.0f)
      {
         localTilt = kTiltingLeft;
      }
      else 
      {
         localTilt = kNoTilt;
      }
      deviceTiltAngle = 180.0f - deviceTiltAngle;
   }
   
   switch (self.tiltNotificationEvent)
   {
      case kDirectionalChange:
      {
         if (self.tiltDirection != localTilt)
         {
            self.tiltDirection = localTilt;
            
            [self.animation HandleTilt:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:deviceTiltAngle], 
                                        @"tiltAngle", 
                                        [NSNumber numberWithInt:self.tiltDirection], 
                                        @"tiltDirection", 
                                        [NSValue value:&ad withObjCType:@encode(AccelerationData)],
                                        @"accelerationData",
                                        nil]];
         }         
      }
      break;
         
      case kAlways:
      {
         self.tiltDirection = localTilt;
         
         [self.animation HandleTilt:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:deviceTiltAngle], 
                                     @"tiltAngle", 
                                     [NSNumber numberWithInt:self.tiltDirection], 
                                     @"tiltDirection", 
                                     [NSValue value:&ad withObjCType:@encode(AccelerationData)],
                                     @"accelerationData",
                                     nil]];         
      }
      break;
         
      default:
      {
         ALog(@"*** Error - unknown tiltNotificationEvent value: %d", self.tiltNotificationEvent);
      }
      break;
   }
}

-(void)HandleTimer:(NSTimer*)aTimer
{
   if (!self.isActivated)
   {
      // Only process this notification if the trigger
      //  has been activated.
      return;
   }
   [self.animation Trigger];
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
      
   if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]    ||
       [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]    ||
       [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
   {
      CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
      
      for (NSValue* regionValue in self.regions)
      {
         CGRect region = [regionValue CGRectValue];
         
         if (CGRectContainsPoint(region, touchLocation))
         {
            result = YES;
         }
      }      
   }

   return result;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer2
{
   return self.allowsConcurrentTrigger;
}

#pragma mark UIAccelerometer delegate
-(void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{         
   if (self.isShakeTrigger)
   {
      [self HandleShake:acceleration];
   }
   else if (self.isTiltTrigger)
   {
      [self HandleTilt:acceleration];
   }
}

@end
