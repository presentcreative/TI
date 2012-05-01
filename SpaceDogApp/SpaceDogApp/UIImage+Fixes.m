// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "UIImage+Fixes.h"

@implementation UIImage (Fixes)

- (id)initWithCoder:(NSCoder *)aDecoder
{
   return nil;
}

+ (UIImage*)newImageFromResource:(NSString*)resourceName
{
   NSString* imageFile = [[NSString alloc] initWithFormat:@"%@/%@",
                          [[NSBundle mainBundle] resourcePath], resourceName];
   UIImage* image = nil;
   
   image = [[UIImage alloc] initWithContentsOfFile:imageFile];
   [imageFile release];
   
   return image;
}

@end
