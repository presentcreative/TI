// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Windows.h"
#import "NSDictionary+ElementAndPropertyValues.h"

#define kWindowFrameExpansionFactor 0.10f

@interface AWindows (Private)
-(CGRect)ContentsRectForWindowAtIndex:(NSUInteger)windowIndex PrimaryImage:(BOOL)primaryImage;
-(CGRect)ExtendedWindowFrameFrom:(CGRect)originalWindowFrame;
@end

@implementation AWindows

@synthesize frameKeyTemplate=fFrameKeyTemplate;
@synthesize windowCoordinates=fWindowCoordinates;
@synthesize windowLocations=fWindowLocations;
@synthesize layersByWindowIndex=fLayersByWindowIndex;

-(void)dealloc
{
   for(CALayer* layer in fLayersByWindowIndex)
   {
      layer.delegate = nil;
      if (layer.superlayer)
      {
         [layer removeFromSuperlayer];
      }
   }
   Release(fFrameKeyTemplate);
   Release(fWindowCoordinates);
   Release(fWindowLocations);
   Release(fLayersByWindowIndex);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   fWindowLocations = [[OrderedDictionary alloc] init];
   fLayersByWindowIndex = [[NSMutableArray alloc] init];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   self.frameKeyTemplate = element.frameKeyTemplate;
   
   NSString* resourcePath = nil;
   
   // load the dictionary specifying the window coordinates
   resourcePath = [[NSBundle mainBundle] pathForResource:element.windowCoordinates ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
   {
      ALog(@"plist file missing: %@", resourcePath);
      
      return;
   }
   
   if (fWindowCoordinates)
   {
      [fWindowCoordinates release];
      fWindowCoordinates = nil;
   }
   fWindowCoordinates = [[NSDictionary alloc] initWithContentsOfFile:resourcePath];
   
   // load the one texture that's shared by all window layers
   resourcePath = [[NSBundle mainBundle] pathForResource:element.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
   {
      ALog(@"image file missing: %@", resourcePath);
      
      return;
   }
      
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:resourcePath];
   
   CALayer* windowLayer = nil;
   NSUInteger windowIndex = 1;
   
   for (NSDictionary* windowSpec in element.windowSpecs)
   {
      // create a layer on which to display the individual window
      windowLayer = [[CALayer alloc] init];
      windowLayer.frame = windowSpec.frame;
      
      // DEBUG
      // draw each window's layer with a frame, so we can see its exact position
//      windowLayer.borderColor = [UIColor whiteColor].CGColor;
//      windowLayer.borderWidth = 3.0f;
      
      // give the layer a reference to the shared texture
      [windowLayer setContents:(id)image.CGImage];
      
      // point the layer to the part of the texture representing its window
      windowLayer.contentsRect = [self ContentsRectForWindowAtIndex:windowIndex PrimaryImage:YES];
      
      NSValue* windowLocation = [NSValue valueWithCGRect:windowLayer.frame];
      NSNumber* state = [NSNumber numberWithBool:NO];   // off/inital
      
      [self.windowLocations insertObject:state forKey:windowLocation atIndex:windowIndex-1];
      
      // add the layer to the view
      [view.layer addSublayer:windowLayer];
      
      [self.layersByWindowIndex addObject:windowLayer];
      
      [windowLayer release];
      
      windowIndex++;
   }
   
   [image release];
}

-(CGRect)ContentsRectForWindowAtIndex:(NSUInteger)windowIndex PrimaryImage:(BOOL)primaryImage
{
   CGRect result = CGRectZero;
   
   if (0 == windowIndex)
   {
      return result;
   }
   
   NSString* frameKey = [NSString stringWithFormat:self.frameKeyTemplate, windowIndex, primaryImage?1:2];
   
   NSDictionary* frameSpec = [[self.windowCoordinates objectForKey:@"frames"] objectForKey:frameKey];
   
   CGSize imageSize = CGSizeFromString([frameSpec objectForKey:@"spriteSize"]);
   CGSize textureSize = CGSizeFromString([[self.windowCoordinates objectForKey:@"metadata"] objectForKey:@"size"]);
   CGRect textureRect = CGRectFromString([frameSpec objectForKey:@"textureRect"]);
   
   result = CGRectMake(textureRect.origin.x/textureSize.width, 
                       textureRect.origin.y/textureSize.height, 
                       imageSize.width/textureSize.width, 
                       imageSize.height/textureSize.height);
   
   return result;
}

-(CGRect)ExtendedWindowFrameFrom:(CGRect)windowFrame
{
   // answer a window frame that x% bigger all around (to make activation easier
   CGFloat newWidth = windowFrame.size.width + (windowFrame.size.width * kWindowFrameExpansionFactor);
   CGFloat newHeight = windowFrame.size.height + (windowFrame.size.height * kWindowFrameExpansionFactor);
   
   
   CGRect result = CGRectMake(windowFrame.origin.x-(newWidth/2), 
                              windowFrame.origin.y-(newHeight/2.0f), 
                              newWidth, 
                              newHeight);
   
   return result;
}

#pragma mark ACustomAnimation protocol
-(void)TriggerWithRecognizer:(UIGestureRecognizer*)recognizer
{
   if (![recognizer isKindOfClass:[UITapGestureRecognizer class]])
   {
      return;
   }
   
   UITapGestureRecognizer* tapRecognizer = (UITapGestureRecognizer*)recognizer;
   
   CGPoint tapLocation = [tapRecognizer locationInView:self.containerView];
   
   for (NSUInteger i = 0; i < [self.windowLocations count]; i++)
   {
      NSValue* windowLocationValue = (NSValue*)[self.windowLocations keyAtIndex:i];
      
      CGRect windowFrame = [windowLocationValue CGRectValue];
      
      if (CGRectContainsPoint([self ExtendedWindowFrameFrom:windowFrame], tapLocation))
      {
         //NSLog(@"tapped windowFrame = %@, tapLocation = %@", NSStringFromCGRect(windowFrame), NSStringFromCGPoint(tapLocation));
         
         // turn the window's light on or off, according to the current state
         NSNumber* currentState = [self.windowLocations objectForKey:windowLocationValue];
         
         //NSLog(@"current state = %@", [currentState boolValue]?@"YES":@"NO");
         
         BOOL newState = ![currentState boolValue];
         
         // Note that the following messages sends the negated value of 'newState' in order to correctly specify
         // whether it's the _primary_ or _secondary_ image that's to be displayed
         CGRect contentsRectForImageInNewState = [self ContentsRectForWindowAtIndex:i+1 PrimaryImage:!newState];
         
         //NSLog(@"contentsRectForImageInNewState = %@", NSStringFromCGRect(contentsRectForImageInNewState));
         //NSLog(@" ");
         
         // set the window image to the image representing the new state...
         CALayer* windowLayer = [self.layersByWindowIndex objectAtIndex:i];
         
         // wrap the change in contentsRect in a transaction that disables default actions
         // so that the image change is instantaneous, i.e NOT animated
         [CATransaction begin];
         [CATransaction setDisableActions:YES];
         windowLayer.contentsRect = contentsRectForImageInNewState;
         [CATransaction commit];
         
         // ... record the new state
         [self.windowLocations setObject:[NSNumber numberWithBool:newState] forKey:windowLocationValue];
         
         // we're done!
         break;
      }
   }
}

@end
