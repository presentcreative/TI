// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>

@class AAssetManager;

@protocol AAssetManagerDelegate

@optional
-(void)assetManager:(AAssetManager*)assetManager didReceiveGesture:(UIGestureRecognizer*)recognizer;

@end


