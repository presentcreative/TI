// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "PreferencesManager.h"

static APreferencesManager* sSharedPreferencesManager = nil;

@implementation APreferencesManager

+ (id)sharedPreferencesManager
{
   @synchronized(self)
   {
      if (nil == sSharedPreferencesManager)
      {
         sSharedPreferencesManager = [[super allocWithZone:NULL] init];
      }
   }
   
   return sSharedPreferencesManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
   return [[self sharedPreferencesManager] retain];
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

#pragma mark Preferences 
-(void)setUserHowToSavvy:(BOOL)savvy
{
   NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
   
   if (nil != userDefaults)
   {
      [userDefaults setBool:savvy forKey:@"userHowToSavvy"];
   }   
}

-(BOOL)userHowToSavvy
{
   BOOL result = NO;
   
   NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
   
   if (nil != userDefaults)
   {
      result = [userDefaults boolForKey:@"userHowToSavvy"];
   }
   
   return result;
}

-(BOOL)isUserHowToSavvy
{
   return [self userHowToSavvy];
}

@end
