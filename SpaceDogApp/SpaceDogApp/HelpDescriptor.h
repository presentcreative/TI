// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>

#define kSwipeDescriptor   @"SWIPE"
#define kShakeDescriptor   @"SHAKE"
#define kShakeAndRotateDescriptor @"SHAKE_AND_ROTATE"
#define kTapDescriptor     @"TAP"
#define kRotateDescriptor  @"ROTATE"

#define kSwipeLeft         @"LEFT"
#define kSwipeRight        @"RIGHT"
#define kSwipeUp           @"UP"
#define kSwipeDown         @"DOWN"


@interface AHelpDescriptor : NSObject 
{
   NSString* fType;
   NSString* fArrowDirection;
   CGRect fFrame;
}

@property (copy) NSString* type;
@property (copy) NSString* arrowDirection;
@property (assign) CGRect frame;

@property (readonly) BOOL isSwipeDescriptor;
@property (readonly) BOOL isShakeDescriptor;
@property (readonly) BOOL isShakeAndRotateDescriptor;
@property (readonly) BOOL isTapDescriptor;
@property (readonly) BOOL isRotateDescriptor;

@property (readonly) BOOL isSwipeUp;
@property (readonly) BOOL isSwipeDown;
@property (readonly) BOOL isSwipeLeft;
@property (readonly) BOOL isSwipeRight;

@end
