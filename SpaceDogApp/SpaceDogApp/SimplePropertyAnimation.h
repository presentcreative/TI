// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "CustomAnimationImpl.h"

@interface ASimplePropertyAnimation : ACustomAnimationImpl
{
   id fFromValue;
   id fToValue;
   
   BOOL fUpdateToFinalValue;
}

@property (nonatomic, retain) id fromValue;
@property (nonatomic, retain) id toValue;
@property (assign) BOOL updateToFinalValue;

@end
