// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "SpaceDogAppAppDelegate.h"
#import "SpaceDogAppViewController.h"

@implementation SpaceDogAppAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
   self.window.rootViewController = self.viewController;
   [self.window makeKeyAndVisible];
   
   return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
   if (nil != self.viewController)
   {
      [self.viewController applicationWillResignActive:application];
   }   
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   /*
    Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   /*
    Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   /*
    Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    */
   if (nil != self.viewController)
   {
      [self.viewController applicationDidBecomeActive:application];
   }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   /*
    Called when the application is about to terminate.
    Save data if appropriate.
    See also applicationDidEnterBackground:.
    */
}

- (void)dealloc
{
   Release(_window);
   Release(_viewController);
   
   [super dealloc];
}

@end
