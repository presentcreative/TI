// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ImageSequenceLayer.h"


@implementation AImageSequenceLayer

-(void)dealloc
{
   self.contents = nil;
      
   [super dealloc];
}

-(id)retain
{
   return [super retain];
}

-(oneway void)release
{
   [super release];
}

#pragma mark -
#pragma mark Initialization, variable image size
- (id)initWithImage:(CGImageRef)img;
{
   self = [super init];
   
   if (nil != self)
   {
      self.contents = (id)img;
      [self resetImageIndices];
   }
   
   return self;
}

#pragma mark -
#pragma mark Initialization, fixed image size
- (id)initWithImage:(CGImageRef)img imageSize:(CGSize)size;
{
   self = [self initWithImage:img];
   
   if (nil != self)
   {
      CGSize imageSizeNormalized = CGSizeMake(size.width/CGImageGetWidth(img), size.height/CGImageGetHeight(img));
      
      self.bounds = CGRectMake( 0, 0, size.width, size.height );
      
      self.contentsRect = CGRectMake( 0, 0, imageSizeNormalized.width, imageSizeNormalized.height );
   }
   
   return self;
}

@synthesize imageIndex = fImageIndex;
@synthesize lastImageIndex = fLastImageIndex;

+ (BOOL)needsDisplayForKey:(NSString *)key;
{
   return [key isEqualToString:@"imageIndex"];
}

+ (id <CAAction>)defaultActionForKey:(NSString *)aKey;
{
   if ([aKey isEqualToString:@"contentsRect"] || 
       [aKey isEqualToString:@"bounds"])
   {
      return (id <CAAction>)[NSNull null];
   }
      
   return [super defaultActionForKey:aKey];
}

-(unsigned int)currentImageIndex;
{
   return ((AImageSequenceLayer*)[self presentationLayer]).imageIndex;
}

-(void)resetImageIndices
{
   self.imageIndex = 1;
   self.lastImageIndex = 1;
}

// Implement displayLayer: on the delegate to override how image rectangles are calculated; 
// remember to use currentImageIndex, ignore imageIndex == 0, and set the layer's bounds
- (void)display
{
   // if the request is to display the same image as was last displayed, then
   // avoid the overhead and do nothing...
   if (self.lastImageIndex == self.currentImageIndex)
   {
      return;
   }
   
   // call our delegate to fill in the details of the bounds and contentsRect
   // to be displayed
   if ([self.delegate respondsToSelector:@selector(displayLayer:)])
   {
      [self.delegate displayLayer:self];
      
      self.lastImageIndex = self.currentImageIndex;
   }
}

@end
