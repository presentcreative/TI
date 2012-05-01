// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ChapterMenu.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Constants.h"
#import "BookManager.h"
#import "UIImage+Fixes.h"

#define kChapterBoxWidth         130.0f
#define kChapterBoxWidthPad        5.0f
#define kChapterBoxInitialOffset  10.0f
#define kChapterBoxHeight         95.0f
#define kChapterBoxHeightPad       5.0f

#define kScrollTopTag            900
#define kScrollBottomTag         901
#define kScrollBackTag           902
#define kScrollViewTag           904
#define kChapterBoxTagBase       200

#define kScrollerTriggerPoint     30

#define kChapterBoxNameTemplate @"chp_%d.jpg"

@interface AChapterMenu (Private)
-(void)BuildScrollerFromElement:(NSDictionary*)element;
-(void)ExpandCollapseScroll:(UIPanGestureRecognizer*)panRecognizer;
-(void)ChapterBoxTapped:(UITapGestureRecognizer*)tapRecognizer;
-(NSUInteger)numChapters;
@end


@implementation AChapterMenu

@synthesize scrollToggleHotspot = fScrollToggleHotspot;
@synthesize scrollTopMinY = fScrollTopMinY;
@synthesize scrollTopMaxY = fScrollTopMaxY;

@synthesize scrollTop = fScrollTop;
@synthesize scrollBottom = fScrollBottom;
@synthesize scrollBack = fScrollBack;

@synthesize scroller = fScroller;

@synthesize selectedChapter = fSelectedChapter;

-(UIImageView*)scrollTop
{
   return (UIImageView*)[self.containerView viewWithTag:kScrollTopTag];
}

-(UIImageView*)scrollBottom
{
   return (UIImageView*)[self.containerView viewWithTag:kScrollBottomTag];
}

-(UIImageView*)scrollBack
{
   return (UIImageView*)[self.containerView viewWithTag:kScrollBackTag];
}

-(UIScrollView*)scroller
{
   return (UIScrollView*)[self.containerView viewWithTag:kScrollViewTag];
}

-(void)BaseInit 
{
   self.scrollTopMinY = 0.0f;
   self.scrollTopMaxY = 0.0f;
   
   self.selectedChapter = 0;   
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   UIImageView* scrollImageView = nil;
   UIImage* scrollViewImage = nil;
   CGRect frame;
   
   // the scroll is displayed 'open', initially
   frame = element.scrollBackFrame;
   scrollImageView = [[UIImageView alloc] initWithFrame:frame];
   scrollViewImage = [UIImage newImageFromResource:element.scrollBackResource];
   scrollImageView.image = scrollViewImage;
   [scrollViewImage release];
   scrollImageView.tag = kScrollBackTag;
   scrollImageView.clipsToBounds = YES;
   scrollImageView.userInteractionEnabled = YES;
   scrollImageView.autoresizesSubviews = YES;
   [view addSubview:scrollImageView];
   [scrollImageView release];
   
   // the scroller holding the 'Chapter Menu' images is initially visible and
   // only becomes hidden when the scroll has been collapsed to its min height
   [self BuildScrollerFromElement:element];
         
   frame = element.scrollBottomFrame;
   scrollImageView = [[UIImageView alloc] initWithFrame:frame];
   scrollViewImage = [UIImage newImageFromResource:element.scrollBottomResource];
   scrollImageView.image = scrollViewImage;
   [scrollViewImage release];
   scrollImageView.tag = kScrollBottomTag;
   scrollImageView.userInteractionEnabled = NO;
   [view addSubview:scrollImageView];
   [scrollImageView release];
      
   // open the scroll by panning on the upper part of the scroll
   self.scrollToggleHotspot = element.scrollToggleHotspot;
   
   UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] 
                                            initWithTarget:self 
                                            action:@selector(ExpandCollapseScroll:)];
   panRecognizer.cancelsTouchesInView = YES;
   panRecognizer.minimumNumberOfTouches = 1;
   panRecognizer.maximumNumberOfTouches = 1;
   
   self.scrollTopMinY = element.scrollTopMinY;
   self.scrollTopMaxY = element.scrollTopMaxY;
   
   frame = element.scrollTopFrame;
   scrollImageView = [[UIImageView alloc] initWithFrame:frame];
   scrollViewImage = [UIImage newImageFromResource:element.scrollTopResource];
   scrollImageView.image = scrollViewImage;
   [scrollViewImage release];
   scrollImageView.tag = kScrollTopTag;
   scrollImageView.userInteractionEnabled = YES;
   [scrollImageView addGestureRecognizer:panRecognizer];
   [panRecognizer release];
   
   [view addSubview:scrollImageView];
   [scrollImageView release];  
}

-(void)BuildScrollerFromElement:(NSDictionary*)element
{   
   // Build the scroll view itself - it's hidden, initially
   UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:element.scrollerFrame];
   scrollView.tag = kScrollViewTag;
   scrollView.alpha = 1.0f;
   scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
   scrollView.userInteractionEnabled = YES;
   
   scrollView.contentSize = CGSizeMake(kChapterBoxWidth, 
                                       [self numChapters] * (kChapterBoxHeight+kChapterBoxHeightPad*2.0f) + ([self numChapters]*kChapterBoxHeightPad*2.0f) + (kChapterBoxHeightPad*2.0f));
      
   scrollView.scrollEnabled = YES;
   scrollView.pagingEnabled = NO;
   scrollView.showsHorizontalScrollIndicator = NO;
   scrollView.showsVerticalScrollIndicator = NO;
   scrollView.alwaysBounceVertical = YES;
   scrollView.bounces = YES;
   scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
   scrollView.directionalLockEnabled = YES;
	
   scrollView.clipsToBounds = YES;
   scrollView.backgroundColor = [UIColor clearColor];
   
   [self.scrollBack addSubview:scrollView];
   [scrollView release]; 
   
   // now load it
   CGFloat lastY = kChapterBoxInitialOffset;
   
   for (int i = 1; i <= [self numChapters]; i++)
   {
      NSString* chapterBoxName = [NSString stringWithFormat:kChapterBoxNameTemplate, i];
      NSString* imagePath = [[NSBundle mainBundle] pathForResource:chapterBoxName ofType:nil];
      
      if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
      {
         ALog(@"Chapter Box %d file missing: %@", i, imagePath);
      }
      else
      {
         // position the UIImageView holding the 'Chapter Box' at the correct
         // offset from the beginning of the UIScrollView's content area
         CGRect frame = CGRectMake(0.0f+kChapterBoxWidthPad/2.0f, 
                                   lastY+kChapterBoxHeightPad, 
                                   kChapterBoxWidth+kChapterBoxWidthPad*2.0f, 
                                   kChapterBoxHeight+kChapterBoxHeightPad*2.0f);
         
         lastY += (kChapterBoxHeight+kChapterBoxHeightPad*4.0f);
                  
         // place the ChapterBox on a UIImageView's layer and surround it with a shadow
         // that can be pulsed when the image is selected
         UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
         imageView.layer.borderWidth = 1.0f;
         
         UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
         imageView.layer.contents = (id)image.CGImage;
         [image release];
         imageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
         imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
         imageView.layer.shadowRadius = 5.0;
         imageView.layer.shadowOpacity = 0.0;
         imageView.userInteractionEnabled = YES;
         
         // use a tag on the UIImageView to identify the chapter with which it's associated
         imageView.tag = kChapterBoxTagBase + i;
         
         // create a callback so that tapping on a Chapter Box can initiate display of the
         // associated chapter
         UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ChapterBoxTapped:)];
         tapRecognizer.numberOfTapsRequired = 1;
         tapRecognizer.numberOfTouchesRequired = 1;
         [imageView addGestureRecognizer:tapRecognizer];
         [tapRecognizer release];
         
         [self.scroller addSubview:imageView];
         [imageView release];
      }      
   }   
}

-(void)ExpandCollapseScroll:(UIPanGestureRecognizer*)panRecognizer
{
   // what vertical distance did the user's finger move?
   CGFloat deltaY = ((CGPoint)[panRecognizer translationInView:[self.scrollTop superview]]).y;
         
   // the scrollTop needs to move in the direction panned (if possible) and the
   // scrollBack needs to increase/decrease in height
   CGFloat newValue = 0.0;
   
   // move the scrollTop, clamping it at its min/max Y, if necessary
   CGRect scrollTopFrame = self.scrollTop.frame; 
   
   CGFloat currentY = scrollTopFrame.origin.y;
   
   // min clamp
   if (currentY + deltaY < self.scrollTopMinY)
   {
      deltaY = self.scrollTopMinY - currentY;
   }
   
   // max clamp
   if (currentY + deltaY > self.scrollTopMaxY)
   {
      deltaY = self.scrollTopMaxY - currentY;
   }
   
   newValue = scrollTopFrame.origin.y + deltaY;
   
   scrollTopFrame.origin.y = newValue;
   self.scrollTop.frame = scrollTopFrame;
   
   // now re-origin and resize the back
   CGRect scrollBackFrame = self.scrollBack.frame;
      
   // if deltaY is -ve, height is increasing
   newValue = scrollBackFrame.size.height - deltaY;   
   scrollBackFrame.size.height = newValue;
   
   newValue = scrollBackFrame.origin.y + deltaY;
   scrollBackFrame.origin.y = newValue;
   
   self.scrollBack.frame = scrollBackFrame;
   
   // if the scrollBack is within 20 points of its max height, reveal the scroller
   // otherwise hide the scroller
   CGFloat scrollerAlpha = 0.0;
   
   if (self.scrollTop.frame.origin.y - kScrollerTriggerPoint < self.scrollTopMinY)
   {
      scrollerAlpha = 1.0;
   }

   // nest a CATransaction so that we can control the duration of the change in alpha,
   // otherwise, the scroller will 'pop' into view, which is ugly
   [UIView beginAnimations:@"changeScrollerOpacity" context:nil];
   
   [UIView setAnimationDuration:1.0f];
   
   self.scroller.alpha = scrollerAlpha;
   
   [UIView commitAnimations];
      
   // update the pan recognizer so that the next event received is with
   // respect to the current pan position
   [panRecognizer setTranslation:CGPointZero inView:[self.scrollTop superview]];
}

-(void)ChapterBoxTapped:(UITapGestureRecognizer*)tapRecognizer
{
   // extract the chapter number of the Chapter Box that was tapped
   UIImageView* tappedView = (UIImageView*)tapRecognizer.view;
   
   self.selectedChapter = tappedView.tag - kChapterBoxTagBase - 1;
   
   // pulse the UIImageView's layer shadow prior to initiating the selection
   CABasicAnimation* shadowPulseAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
   shadowPulseAnimation.delegate = self;
   shadowPulseAnimation.fromValue = [NSNumber numberWithFloat:0.0];
   shadowPulseAnimation.toValue = [NSNumber numberWithFloat:1.0];
   shadowPulseAnimation.duration = 0.5;
   shadowPulseAnimation.autoreverses = YES;
   shadowPulseAnimation.removedOnCompletion = YES;
   
   [tappedView.layer addAnimation:shadowPulseAnimation forKey:@"shadowPulseAnimation"];   
}

-(NSUInteger)numChapters
{
   return [[ABookManager sharedBookManager] TotalNumberOfChapters];
}

#pragma mark -
#pragma mark Animation delegate protocol
-(void)animationDidStop:(CAAnimation*)anim finished:(BOOL)flag
{
   // the shadow pulse has finished - trigger the change in chapter
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kNotificationChapterSelected
    object:self 
    userInfo:[NSDictionary 
              dictionaryWithObject:[NSNumber numberWithUnsignedInteger:self.selectedChapter] 
              forKey:@"chapterNumber"]];
}

@end
