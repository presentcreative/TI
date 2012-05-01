// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>


@interface APreferencesManager : NSObject 
{

}

+(APreferencesManager*)sharedPreferencesManager;

@property (assign, getter=isUserHowToSavvy) BOOL userHowToSavvy;

@end
