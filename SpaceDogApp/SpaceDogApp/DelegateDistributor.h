// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>

@interface ADelegateDistributor : NSObject <UIAccelerometerDelegate>
{
   NSMutableDictionary* fDelegates;
}

+(ADelegateDistributor*)sharedDelegateDistributor;

-(void)AddAccelerometerDelegate:(id<UIAccelerometerDelegate>)delegate;
-(void)RemoveAccelerometerDelegate:(id<UIAccelerometerDelegate>)delegate;

@end
