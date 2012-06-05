#include <stdlib.h>
#include <assert.h>

#import "load_image.h"
#import <Cocoa/Cocoa.h>

Image *
load_image(char *name)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSString* in_path = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
		CFURLRef in_url = (CFURLRef)[NSURL fileURLWithPath:in_path];
		
		CGImageSourceRef image_source = CGImageSourceCreateWithURL(in_url, NULL);
		CGImageRef img = CGImageSourceCreateImageAtIndex(image_source, 0, NULL);
		
		Image *image = calloc(1, sizeof(Image));
		int w = image->w = CGImageGetWidth(img);
		int h = image->h = CGImageGetHeight(img);
		void * pixels = image->pixels = calloc(sizeof(Pixel), w*h);

		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		CGContextRef context = CGBitmapContextCreate(pixels, w, h, 8, w*sizeof(Pixel), colorSpace, kCGImageAlphaPremultipliedLast);
		
		CGContextDrawImage(context, CGRectMake(0, 0, w, h), img);
	[pool release];
	
	return image;
}

void
free_image(Image *image)
{
	free(image->pixels);
	free(image);
}
