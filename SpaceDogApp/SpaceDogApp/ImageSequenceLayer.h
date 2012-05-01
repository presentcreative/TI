// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface AImageSequenceLayer : CALayer
{
   unsigned int fImageIndex;
   unsigned int fLastImageIndex;
}

@property (assign) unsigned int imageIndex;
@property (assign) unsigned int lastImageIndex;

// Use this property to obtain the index currently displayed on screen
@property (readonly) unsigned int currentImageIndex; 

// For use with sample rects set by the delegate
-(id)initWithImage:(CGImageRef)img;

// If all samples are the same size 
-(id)initWithImage:(CGImageRef)img imageSize:(CGSize)size;

-(void)resetImageIndices;

@end
