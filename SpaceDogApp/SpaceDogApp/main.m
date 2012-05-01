// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   int retVal = UIApplicationMain(argc, argv, nil, nil);
   [pool release];
   return retVal;
}
