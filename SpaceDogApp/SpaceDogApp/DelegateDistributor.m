// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "DelegateDistributor.h"

// supported services
#define kAccelerometerService @"accelerometer"


// misc
#define kAccelerometerSampleRate 30


static ADelegateDistributor* sSharedDelegateDistributor = nil;

@interface ADelegateDistributor (Private)
-(void)AddQueueForService:(NSString*)serviceName;
@end

@implementation ADelegateDistributor

+ (id)sharedDelegateDistributor
{
   @synchronized(self)
   {
      if (nil == sSharedDelegateDistributor)
      {
         sSharedDelegateDistributor = [[super allocWithZone:NULL] init];
         
         // *** add queues for supported services ***
         [sSharedDelegateDistributor AddQueueForService:kAccelerometerService];
      }
   }
   
   return sSharedDelegateDistributor;
}

+ (id)allocWithZone:(NSZone *)zone
{
   return [[self sharedDelegateDistributor] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
   return self;
}

- (id)retain 
{
   return self;
}

- (unsigned)retainCount 
{
   return UINT_MAX; //denotes an object that cannot be released
}

- (oneway void)release 
{
   // never release
}

- (id)autorelease 
{
   return self;
}

- (id)init 
{
    amAcceleratorDelegate = false;
   if ((self = [super init])) 
   {
      fDelegates = [[NSMutableDictionary alloc] initWithCapacity:8];
   }
   
   return self;
}

- (void)dealloc 
{
   // Should never be called, but just here for consistency, really.
   Release(fDelegates);
   
   [super dealloc];
}

#pragma mark -
#pragma mark ADelegateDistributor (Private)
-(void)AddQueueForService:(NSString *)serviceName
{
   [fDelegates setObject:[NSMutableArray arrayWithCapacity:8] forKey:serviceName];
}

-(void)BecomeAccelerometerDelegate
{
   UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
   accelerometer.updateInterval = 1.0f/(kAccelerometerSampleRate/2.0f);
   accelerometer.delegate = self;
}

-(void)BecomeFreeOfAccelerometer
{
   UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
   
   if (accelerometer.delegate == self)
   {
      accelerometer.delegate = nil;
   }
}

#pragma mark -
#pragma mark ADelegateDistributor 
-(void)AddAccelerometerDelegate:(id<UIAccelerometerDelegate>)delegate
{
   NSLog(@"adding accelerometer delegate %p", delegate);
   // Add delegate as an indirect delegate of the Accelerometer. If delegate
   // is the first known Accelerometer delegate, then register the receiver
   // as the direct delegate of the Accelerometer and start UIAcceleration events
   // flowing to all indirect delegates.
   NSMutableArray* accelerometerQueue = [fDelegates objectForKey:kAccelerometerService];
   
   [accelerometerQueue addObject:delegate];
   
   if (!amAcceleratorDelegate)//1 == [accelerometerQueue count])
   {
      [self BecomeAccelerometerDelegate];
   }
}

-(void)RemoveAccelerometerDelegate:(id<UIAccelerometerDelegate>)delegate
{
   NSLog(@"removing accelerometer delegate %p", delegate);
   // Remove delegate from the set of accelerometer delegates and, if there are
   // no more delegates, remove the receiver as the direct delegate of the
   // accelerometer.
   NSMutableArray* accelerometerQueue = [fDelegates objectForKey:kAccelerometerService];
   
   [accelerometerQueue removeObject:delegate];
   
   if (0 == [accelerometerQueue count])
   {
      [self BecomeFreeOfAccelerometer];
       amAcceleratorDelegate = false;
   }   
   else {
       NSLog(@"FUCKERONIOUS%p", delegate);
       
   }
}

#pragma mark UIAccelerometer delegate
-(void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{         
   // distribute the UIAcceleration to all registered delegates
   for (id<UIAccelerometerDelegate>delegate in [fDelegates objectForKey:kAccelerometerService])
   {
      [delegate accelerometer:accelerometer didAccelerate:acceleration];
   }
}

@end
