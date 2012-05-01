// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <UIKit/UIKit.h>

@class SpaceDogAppViewController;

@interface SpaceDogAppAppDelegate : NSObject <UIApplicationDelegate> 
{

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SpaceDogAppViewController *viewController;

@end
