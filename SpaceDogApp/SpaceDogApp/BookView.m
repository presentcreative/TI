// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#include <stdlib.h>
#include <objc/objc.h>
#include <math.h>
#import <mach/mach.h>

#import "BookView.h"
#import "SpaceDogAppAppDelegate.h"
#import "Constants.h"
#import "BookManager.h"
#import "NSArray+PropertyValues.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "HelpDescriptor.h"
#import "Trigger.h"

#define kTapHelpImageName              @"tap.png"
#define kSwipeHelpImageName            @"swipe.png"
#define kShakeHelpImageName            @"shake.png"
#define kRotationHelpImageName         @"rotation.png"
#define kShakeAndRotateHelpImageName   @"shakeandrotate.png"

#define kHelpLayerFadeInFadeOutDuration   1.0f
#define kHelpLayerDisplayDuration         2.0f

#define kHelpSuperLayerName      @"helpSuperLayer"


@interface ABookView (Private)
-(CABasicAnimation*)ChangeOpacityFrom:(CGFloat)fromValue To:(CGFloat)toValue;
@end


@implementation ABookView

@synthesize assetChapterNumber = fAssetChapterNumber;
@synthesize assetPageNumber = fAssetPageNumber;
@synthesize pageNumber = fPageNumber;
@synthesize assets = fAssets;
@synthesize helpDescriptors = fHelpDescriptors;
@synthesize helpSuperLayer = fHelpSuperLayer;
@synthesize triggersOnView = fTriggersOnView;

- (id)initWithFrame:(CGRect)frame 
{
   self = [super initWithFrame:frame];
   
   if (self) 
   {
      self.pageNumber = -1;
      self.assetChapterNumber = 0;
      self.assetPageNumber = 0;
      self.assets = [NSMutableDictionary dictionary];
      self.triggersOnView = [NSMutableArray array];
      self.helpDescriptors = [NSMutableArray array];
      self.helpSuperLayer = nil;
      fStarted = NO;
      
      self.opaque = YES;
   }
   
   return self;
}

- (void)dealloc 
{
   // Confirm that all animations are stopped.
   [self StopAnimations];

   // Remove all assets
   Release(fAssets);
   Release(fHelpDescriptors);
   
   self.helpSuperLayer.delegate = nil;
   if (self.helpSuperLayer.superlayer)
   {
      [self.helpSuperLayer removeFromSuperlayer];
   }
   Release(fHelpSuperLayer);
   
   // Remove gesture recognizers
   for (UIGestureRecognizer* gestureRecognizer in self.gestureRecognizers)
   {
      [self removeGestureRecognizer:gestureRecognizer];
   }
   
   // Remove triggers
   Release(fTriggersOnView);
   
   NSLog(@"Page %d deallocated", self.pageNumber);
   
   [super dealloc];
}

-(void)Sterilize
{
   NSLog(@"Sterilizing ABookView for page %d", fPageNumber);
   
   fPageNumber = -1;
   self.tag = -100;
   self.userInteractionEnabled = NO;
   self.image = nil;
   
   self.helpSuperLayer.delegate = nil;
   if (self.helpSuperLayer.superlayer)
   {
      [self.helpSuperLayer removeFromSuperlayer];
   }
   Release(fHelpSuperLayer);
   
   // Remove gesture recognizers
   for (UIGestureRecognizer* gestureRecognizer in self.gestureRecognizers)
   {
      [self removeGestureRecognizer:gestureRecognizer];
   }
   
   [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

   [fTriggersOnView removeAllObjects];
   [fAssets removeAllObjects];
   [fHelpDescriptors removeAllObjects];
   
   self.layer.sublayers = nil;
}

-(void)SetToPageNumber:(NSInteger)rawPageNumber 
{
   ABookManager* bookManager = [ABookManager sharedBookManager];
   
   NSArray* chapterAndPage = [bookManager ChapterAndPageForRawPage:rawPageNumber];
   
   NSUInteger chapter = [chapterAndPage chapter];
   NSUInteger page = [chapterAndPage page];
   
   self.frame = CGRectMake(rawPageNumber*kPageWidth, 0.0f, kPageWidth, kPageHeight);
   self.tag = kScrollViewBaseTag + rawPageNumber;
   self.userInteractionEnabled = YES;
   
   NSString* imageKey = [NSString stringWithFormat:kPageNumberTemplate, chapter, page];
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:imageKey ofType:nil];
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   self.image = image;
   [image release];
   
   self.pageNumber = rawPageNumber;
   
   self.assetChapterNumber = chapterAndPage.chapter;
   self.assetPageNumber = chapterAndPage.page;
   
   [self LoadAssets];
}

// Load the assets implied by the receiver's current state, i.e. page number
-(void)LoadAssets
{   
   NSString* assetsFilename = [NSString stringWithFormat:kChapterAssetsFilename, self.assetChapterNumber];

   [self LoadAssets:assetsFilename];
}

-(void)LoadAssets:(NSString*)assetsFilename
{
   NSURL* assetsURL = [[NSBundle mainBundle] URLForResource:assetsFilename withExtension:nil]; 
   
   // catch and release!
   NSDictionary* assetsDict = [[NSDictionary alloc] initWithContentsOfURL:assetsURL];
   
   NSDictionary* pageDescriptor = nil;
   
   for (NSDictionary* assetPageDescriptor in assetsDict.pages)
   {
      if (self.assetPageNumber == assetPageDescriptor.pageNumber)
      {
         pageDescriptor = assetPageDescriptor;
         break;
      }
   }
   
   if (nil == pageDescriptor)
   {
      [assetsDict release];
      
      return;
   }

   NSLog(@"Loading %d elements on page %d", pageDescriptor.elements.count, self.pageNumber);

   // process the animation and sound elements, assuming all represent specs to custom animations that
   // encapsulate all the setup and registration activities
   for (NSDictionary* element in pageDescriptor.elements)
   {      
      Class customAnimationClass = NSClassFromString(element.customClass);
      
      id<ACustomAnimation> customAnimation = [[customAnimationClass alloc] initWithElement:element RenderOnView:self];
      
      [(NSObject*)customAnimation release];
   }


   // process any help system descriptors that might be available for the page
   for (NSDictionary* element in pageDescriptor.helpDescriptors)
   {
      AHelpDescriptor* helpDescriptor = [[AHelpDescriptor alloc] init];
      helpDescriptor.type = element.type;
      helpDescriptor.frame = element.frame;
      
      if (helpDescriptor.isSwipeDescriptor)
      {
         helpDescriptor.arrowDirection = element.arrowDirection;
      }
      
      [self.helpDescriptors addObject:helpDescriptor];
      [helpDescriptor release];
   }
   
   [assetsDict release];   
}

-(void)RegisterAsset:(id<ACustomAnimation>)customAnimationAsset WithKey:(NSString*)assetKey
{
   NSAssert(nil == [self.assets objectForKey:assetKey],
            @"The Asset ID %@ appeared multiple times on page %d",
            assetKey, self.pageNumber);
   [self.assets setObject:customAnimationAsset forKey:assetKey];
}

-(void)StartAnimations
{
   if (fStarted)
   {
      // Already running; stop first
      [self StopAnimations];
   }
   
   fStarted = YES;
   
   NSLog(@"Starting %d animations on page %d", self.assets.count, self.pageNumber);
   
   for (id<ACustomAnimation>anim in [self.assets allValues])
   {
      [anim Start:NO];
   }   
   
   for (ATrigger* trigger in fTriggersOnView)
   {
      trigger.activated = YES;
   }
}

-(void)DisplayLinkDidTick:(CADisplayLink *)displayLink
{
   if (!fStarted)
   {
      // Ignore ticks if this page isn't running
      return;
   }
   for (id<ACustomAnimation>anim in [self.assets allValues])
   {
      [anim DisplayLinkDidTick:displayLink];
   }      
}

-(void)StopAnimations
{
   if (!fStarted)
   {
      // Already started
      return;
   }
   
   NSLog(@"Stopping %d animations on page %d", self.assets.count, self.pageNumber);
   
   for (ATrigger* trigger in fTriggersOnView)
   {
      trigger.activated = NO;
   }
   
   for (id<ACustomAnimation>anim in [self.assets allValues])
   {
      [anim Stop];
   }  

   fStarted = NO;
}

// ShowHelp involves translating the HelpDescriptors that apply to a given page
// to CALayer instances containing descriptor-appropriate graphics, positioned
// according to the descriptor's frame (and then showing those layers on the
// screen, briefly).
-(void)ShowHelp
{
   // don't do anything if there are no help descriptors OR if help is already
   // in progress
   if (0 == [self.helpDescriptors count] || nil != self.helpSuperLayer)
   {
      return;
   }
   
   CALayer* aLayer = [[CALayer alloc] init];
   self.helpSuperLayer = aLayer;
   [aLayer release];
   
   self.helpSuperLayer.zPosition = NSUIntegerMax;
   self.helpSuperLayer.name = kHelpSuperLayerName;
   self.helpSuperLayer.frame = CGRectMake(0.0f, 0.0f, kPageWidth, kPageHeight);
   self.helpSuperLayer.opacity = 0.0f;
      
   for (AHelpDescriptor* helpDescriptor in self.helpDescriptors)
   {
      CALayer* helpLayer = [[CALayer alloc] init];
      helpLayer.zPosition = 100;
      helpLayer.frame = helpDescriptor.frame;
      
      NSString* resourceName = @"";
      
      if ([@"TAP" isEqualToString:helpDescriptor.type])
      {
         resourceName = kTapHelpImageName;
      }
      else if ([@"SWIPE" isEqualToString:helpDescriptor.type])
      {
         resourceName = kSwipeHelpImageName;
      }
      else if ([@"SHAKE" isEqualToString:helpDescriptor.type])
      {
         resourceName = kShakeHelpImageName;
      }      
      else if ([@"ROTATE" isEqualToString:helpDescriptor.type])
      {
         resourceName = kRotationHelpImageName;
      }
      else if ([@"SHAKE_AND_ROTATE" isEqualToString:helpDescriptor.type])
      {
         resourceName = kShakeAndRotateHelpImageName;
      }
      
      if ([@"" isEqualToString:resourceName])
      {
         ALog("*** Error - unknown HelpDescriptor type encountered: %@", resourceName);
         
         [helpLayer release];
         
         return;
      }
      
      NSString* imagePath = [[NSBundle mainBundle] pathForResource:resourceName ofType:nil];
      
      if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
      {
         ALog("*** Error - HelpDescriptor image not found at: %@", imagePath);
         
         [helpLayer release];
         
         return;
      }
      
      UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
      [helpLayer setContents:(id)image.CGImage];
      [image release];
      
      // swipe icons (other than "swipe left") are derived from the default by
      // rotating the layer the appropriate amount
      if (helpDescriptor.isSwipeDescriptor)
      {
         CATransform3D t = CATransform3DIdentity;
         
         if (helpDescriptor.isSwipeRight)
         {
            t = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180), 0.0f, 0.0f, 1.0f);
         }
         else if (helpDescriptor.isSwipeUp)
         {
            t = CATransform3DMakeRotation(DEGREES_TO_RADIANS(90), 0.0f, 0.0f, 1.0f);
         }
         else if (helpDescriptor.isSwipeDown)
         {
            t = CATransform3DMakeRotation(DEGREES_TO_RADIANS(270), 0.0f, 0.0f, 1.0f);
         }
         
         helpLayer.transform = t;
      }
      
      [self.helpSuperLayer addSublayer:helpLayer];
      [helpLayer release];
   }
   
   // add the super layer to the receiver's display list...
   [self.layer addSublayer:self.helpSuperLayer];
    
   // make the super layer (and all its sublayers...) visible...
   [CATransaction begin];
   
   self.helpSuperLayer.opacity = 1.0f;
   [self.helpSuperLayer addAnimation:[self ChangeOpacityFrom:0.0f To:1.0f] forKey:@"opacity"];
   
   [CATransaction commit];

   // ... and then set a timer to manage their dismissal
   [NSTimer scheduledTimerWithTimeInterval:kHelpLayerDisplayDuration
                                    target:self
                                  selector:@selector(RemoveHelp:)
                                  userInfo:nil
                                   repeats:NO];
}

-(void)RemoveHelp:(NSTimer*)timer
{
   // first, fade out the help layers...
   [CATransaction begin];
   
   self.helpSuperLayer.opacity = 0.0f;
   [self.helpSuperLayer addAnimation:[self ChangeOpacityFrom:1.0f To:0.0f] forKey:@"opacity"];
   
   [CATransaction commit];
   
   // then get rid of them
   self.helpSuperLayer = nil;
}

-(CABasicAnimation*)ChangeOpacityFrom:(CGFloat)fromValue To:(CGFloat)toValue
{
   CABasicAnimation* opacityChangeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
   opacityChangeAnimation.duration = kHelpLayerFadeInFadeOutDuration;
   opacityChangeAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
   opacityChangeAnimation.toValue = [NSNumber numberWithFloat:toValue];
   
   return opacityChangeAnimation;
}

@end
