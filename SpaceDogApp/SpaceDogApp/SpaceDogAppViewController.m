// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "Constants.h"
#import "SpaceDogAppViewController.h"
#import "MapViewController.h"
#import "ObjectAL.h"
#import "BookManager.h"
#import "BookView.h"
#import "NSMutableArray+Queue.h"
#import "NSArray+PropertyValues.h"
#import "PreferencesManager.h"
#import "UIImage+Fixes.h"
#import <mach/mach.h>

#define kCoverPageNumber         999
#define kCreditsPageNumber       998
#define kLogoPageNumber          997

#define kDefaultForwardPreload   1
#define kDefaultBackwardPreload  1
#define kNumPagesOffscreen       2
#define kMaxChapter1PagesToLoad  3
#define kMaxCachedViews          3

#define kSpaceDogLogoPage        @"SDB_Logo.jpg"
#define kLogoPageAssetsFile      @"LogoPage_Assets.plist"

enum SCROLLING_DIRECTION
{
   SCROLLING_NONE,
   SCROLLING_RIGHT,
   SCROLLING_LEFT,
   SCROLLING_UP,
   SCROLLING_DOWN,
   SCROLLING_CRAZY
};

@interface SpaceDogAppViewController (Private)
-(void)BuildBookmark;
-(void)BuildScrollView;
-(void)PopulateViewQueue;
-(void)BookmarkAnimateVisible:(BOOL)makeVisible;
-(void)DisplayCover;
-(void)DisplayLogoPage;
-(void)BuildScrollView;
-(void)InitializeChapter1;
-(void)DisplayLinksPage:(NSNotification*)notification;
-(void)ExitToSpaceDogSite;
-(void)HideLogoPage;
-(void)BuildHowToPage;
-(void)BuildCreditsPage;
-(void)HowToPageTouched:(UIGestureRecognizer*)recognizer;
-(void)ShowCredits;
-(void)ConfigureAudio;
-(void)RegisterForNotifications;
-(void)PositionOnChapter:(NSUInteger)chapterNumber;

-(void)InsertLoadedPage:(ABookView*)page;
-(ABookView*)LoadedPageWithNumber:(NSUInteger)rawPageNumber;
-(BOOL)IsLoaded:(NSUInteger)pageNumber;
-(void)ShowPage:(NSUInteger)pageNumber Scrolling:(int)scrollDirection;
-(void)ReportMemoryUsage;
-(void)ReportPages;
-(void)LoadPagesInRange:(NSIndexSet*)range;
-(void)UnloadPagesNotInRange:(NSIndexSet*)range;
-(void)UnloadPage:(ABookView*)page;
-(void)UnloadPageNumbered:(NSUInteger)pageNumber;
-(void)LoadPageNumbered:(NSUInteger)pageNumber;
-(void)CenterViewSetOn:(NSUInteger)selectedPageNumber Scrolling:(int)scrollDirection;
@end


@implementation SpaceDogAppViewController

@synthesize viewQueue=fViewQueue;
@synthesize appJustOpened=fAppJustOpened;
@synthesize bookmarkVisible=fBookmarkVisible;
@synthesize mainScrollView = fMainScrollView;
@synthesize mapViewController = fMapViewController;
@synthesize currentTrack = fCurrentTrack;
@synthesize lastContentOffset = fLastContentOffset;
@synthesize howToDismissRegion = fHowToDismissRegion;
@synthesize displayLink = fDisplayLink;

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   Release(fMapViewController);
   Release(fCurrentTrack);
   Release(fMainScrollView);
   Release(fViewQueue);
   
   [super dealloc];
}

- (void)didReceiveMemoryWarning
{
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   
   NSLog(@"*** Low Memory Warning, current usage:");
   [self ReportMemoryUsage];
}

-(void)applicationWillResignActive:(UIApplication*)application
{
   // the app has been resurrected - make sure it picks up where it left off...
   ABookView* activePage = [self LoadedPageWithNumber:fActivePage];
   
   if (nil != activePage)
   {
      [activePage StopAnimations];
   }
}

-(void)applicationDidBecomeActive:(UIApplication*)application
{
   // the app has been resurrected - make sure it picks up where it left off...
   ABookView* activePage = [self LoadedPageWithNumber:fActivePage];
   
   if (nil != activePage)
   {
      [activePage StartAnimations];
   }
}

#pragma mark - View lifecycle

-(void)viewDidUnload
{
   [self.displayLink invalidate];
   self.displayLink = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   fCurrentForwardPreload = kDefaultForwardPreload;
   fCurrentBackwardPreload = kDefaultBackwardPreload;
   
   self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(DisplayLinkDidTick:)];
   [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
   
   [super viewDidLoad];
   
   self.appJustOpened = YES;
   
   self.lastContentOffset = 0.0f;
   
   self.howToDismissRegion = CGRectMake(800.0f, 660.0f, 185.0f, 55.0f);
   
   [self ConfigureAudio];
   
   [self BuildScrollView];
   
   [self PopulateViewQueue];
   
   [self InitializeChapter1];
   
   [self BuildBookmark];
   
   [self RegisterForNotifications];
   
   [self DisplayLogoPage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   if (interfaceOrientation == UIDeviceOrientationLandscapeRight)
   {
      return YES;
   }
   
   return NO;
}


-(ABookView*)currentBookView
{   
   return (ABookView*)[fMainScrollView viewWithTag:kPageViewTagBase+fActivePage];
}

-(UIImageView*)CoverView
{
   return (UIImageView*)[self.view viewWithTag:kCoverViewTag];
}
   
-(ABookView*)HowToPageView
{
   return (ABookView*)[self.view viewWithTag:kHowToViewTag];
}

-(ABookView*)CreditsPageView
{
   return (ABookView*)[self.view viewWithTag:kCreditsPageTag];
}

-(UIImageView*)BookmarkView
{
   return (UIImageView*)[self.view viewWithTag:kBookmarkViewTag];
}

-(UIImageView*)BookmarkHighlightView
{
   return (UIImageView*)[self.view viewWithTag:kBookmarkHighlightViewTag];
}

-(void)PopulateViewQueue
{
   fViewQueue = [[NSMutableArray alloc] initWithCapacity:kMaxCachedViews];
   
   for (NSUInteger i = 1; i <= kMaxCachedViews; i++)
   {
      ABookView* bookView = [[ABookView alloc] init];
      
      [self.viewQueue enqueue:bookView];
      
      [bookView release];
   }
}

- (void)BuildBookmark
{
   self.bookmarkVisible = NO;
   
   UIImage* bookmarkImage = [UIImage newImageFromResource:@"bookmark.png"];
   UIImageView* bookmarkImageView = [[UIImageView alloc] initWithImage:bookmarkImage];
   [bookmarkImage release];
      
   // the bookmark starts out invisible and disabled...
   CGRect frame = bookmarkImageView.frame;
   frame.origin.x = kBookmarkOriginX;
   frame.origin.y = kBookmarkHiddenOriginY;
   bookmarkImageView.frame = frame;
   bookmarkImageView.userInteractionEnabled = YES;
   bookmarkImageView.alpha = 0.0;
   bookmarkImageView.tag = kBookmarkViewTag;
   
   [self.view addSubview:bookmarkImageView];

   // build the bookmark highlight
   UIImage* highlightImage = [UIImage newImageFromResource:@"highlight.png"];
   CGRect highlightFrame = CGRectMake(kBookmarkHighlightOriginX, 0.0f, 60.0f, 12.0f);
   UIImageView* highlightImageView = [[UIImageView alloc] initWithImage:highlightImage];
   [highlightImage release];
   
   highlightImageView.tag = kBookmarkHighlightViewTag;
   highlightImageView.frame = highlightFrame;
   highlightImageView.alpha = 0.0f;
   
   [self.view insertSubview:highlightImageView aboveSubview:bookmarkImageView];
   [highlightImageView release];
   
   // add a gesture recognizer for showing/hiding the bookmark
   UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] 
                                            initWithTarget:self 
                                            action:@selector(HandleBookmarkPan:)];
   panRecognizer.minimumNumberOfTouches = 1;
   panRecognizer.maximumNumberOfTouches = 1;
   panRecognizer.cancelsTouchesInView = NO;
   [bookmarkImageView addGestureRecognizer:panRecognizer];
   [panRecognizer release];	
      
   // set up to handle the various taps that may occur on the bookmark
   UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] 
                                            initWithTarget:self 
                                            action:@selector(HandleBookmarkTap:)];
   tapRecognizer.cancelsTouchesInView = YES;
   [bookmarkImageView addGestureRecognizer:tapRecognizer];
   [tapRecognizer release];
   
   [bookmarkImageView release];
}

-(void)RevealBookmark
{
   if (self.isBookmarkVisible)
   {
      return;
   }
      
   UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
      
   [UIView animateWithDuration: kBookmarkRevealAnimationSeconds
                         delay: 0.0
                       options: animationOptions
                    animations: ^{self.BookmarkView.alpha = 1.0f; self.BookmarkHighlightView.alpha = 1.0f;}
                    completion: ^(BOOL finished){self.BookmarkView.userInteractionEnabled = YES; self.bookmarkVisible=YES;}];
}

-(void)HideBookmark
{
   if (!self.isBookmarkVisible)
   {
      return;
   }
   
   UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
      
   [UIView animateWithDuration: kBookmarkRevealAnimationSeconds
                         delay: 0.0
                       options: animationOptions
                    animations: ^{self.BookmarkView.alpha = 0.0f; self.BookmarkHighlightView.alpha = 0.0f;}
                    completion: ^(BOOL finished){self.BookmarkView.userInteractionEnabled = NO; self.bookmarkVisible=NO;}];
}

// Make the Bookmark in/visible
-(void)BookmarkAnimateVisible:(BOOL)makeVisible
{  
   CGRect bookmarkFrame = self.BookmarkView.frame;

   if (makeVisible)
   {
      // set the origin for the 'visible' view
      bookmarkFrame.origin.y = kBookmarkVisibleOriginY;
   }
   else
   {
      // set the frame for the hidden position
      bookmarkFrame.origin.y = kBookmarkHiddenOriginY;
   }
   
   [UIView animateWithDuration:kBookmarkAnimationSeconds 
                    animations:^{
                       self.BookmarkView.frame = bookmarkFrame;
                    }];
}

- (IBAction)HandleBookmarkPan:(UIGestureRecognizer*)sender 
{
   UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)sender;
   
   // what vertical distance did the user's finger move?
   CGFloat deltaY = ((CGPoint)[panRecognizer translationInView:[self.BookmarkView superview]]).y;
   
   CGFloat newY = 0.0f;
   
   // calculate a new Y for the Bookmark's frame, clamping it at its min/max Y, if necessary 
   CGRect bookmarkFrame = self.BookmarkView.frame;
   
   if ((bookmarkFrame.origin.y + deltaY >= kBookmarkHiddenOriginY) && (bookmarkFrame.origin.y + deltaY <= kBookmarkVisibleOriginY))
   {
      newY = deltaY;
   }
   
   // update to the new, actual Y value
   bookmarkFrame.origin.y += newY;
            
   // finally, move the Bookmark
   self.BookmarkView.frame = bookmarkFrame;
   
   // update the pan recognizer so that the next event received is with
   // respect to the current pan position
   [panRecognizer setTranslation:CGPointZero inView:[self.BookmarkView superview]];  
}

- (IBAction)HandleBookmarkTap:(UIGestureRecognizer *)sender
{
	UITapGestureRecognizer* tapRecognizer = (UITapGestureRecognizer*)sender;
   CGPoint location = [tapRecognizer locationInView:tapRecognizer.view];
 
   UIView* bookmarkView = [self.view viewWithTag:kBookmarkViewTag];
   
   CGRect optionRect = CGRectZero;
   
   // Cover page selected?
   optionRect = CGRectMake(0, kBookmarkCoverPageOptionOriginY, bookmarkView.frame.size.width, kBookmarkCoverPageOptionSizeHeight);
   if (CGRectContainsPoint(optionRect, location))
   {
      // return to cover page
      [self BookmarkAnimateVisible:NO];
      
      [[self LoadedPageWithNumber:fActivePage] StopAnimations];
      
      [self DisplayCover];
      
      return;
   }

   // Map selected?
   optionRect = CGRectMake(0, kBookmarkMapOptionOriginY, bookmarkView.frame.size.width, kBookmarkMapOptionSizeHeight);
   if (CGRectContainsPoint(optionRect, location))
   {
      [self BookmarkAnimateVisible:NO];
      
      MapViewController* mvc = [[MapViewController alloc] init];
      [self presentModalViewController:mvc animated:YES];
      self.mapViewController = mvc;
      [mvc release];
      
      [[self LoadedPageWithNumber:fActivePage] StopAnimations];
      
      NSLog(@"Map built!");
      [self ReportMemoryUsage];
      
      return;
   }
   
   // Help selected?
   optionRect = CGRectMake(0, kBookmarkHelpOptionOriginY, bookmarkView.frame.size.width, kBookmarkHelpOptionSizeHeight);
   if (CGRectContainsPoint(optionRect, location))
   {
      [self BookmarkAnimateVisible:NO];
      
      [self.currentBookView ShowHelp];
      
      return;
   }  
   
   // Space Dog selected?
   optionRect = CGRectMake(0, kBookmarkSpaceDogOptionOriginY, bookmarkView.frame.size.width, kBookmarkSpaceDogOptionSizeHeight);
   if (CGRectContainsPoint(optionRect, location))
   {
      [self BookmarkAnimateVisible:NO];
      
      [self ExitToSpaceDogSite];
      
      return;
   }
   
   // Just dismiss the Bookmark?
   optionRect = CGRectMake(0, kBookmarkDismissOptionOriginY, bookmarkView.frame.size.width, kBookmarkDismissOptionSizeHeight);
   if (CGRectContainsPoint(optionRect, location))
   {
      [self BookmarkAnimateVisible:NO];
   }
}

-(void)DisplayLogoPage
{
   NSLog(@"LogoPage about to be built...");
   [self ReportMemoryUsage];
   UIImage* logoPageImage = [UIImage newImageFromResource:kSpaceDogLogoPage];
   ABookView* logoPageView = [[ABookView alloc] init];
   logoPageView.frame = CGRectMake(0.0f, 0.0f, kPageWidth, kPageHeight);
   logoPageView.image = logoPageImage;
   [logoPageImage release];
   
   logoPageView.assetPageNumber = kLogoPageNumber;
   [logoPageView LoadAssets:kLogoPageAssetsFile];
   
   logoPageView.userInteractionEnabled = NO;
   logoPageView.tag = kLogoPageViewTag; 
   logoPageView.alpha = 0.0f;
   
   [self.view addSubview:logoPageView];
   [logoPageView release];
   
   [UIView animateWithDuration:kLogoPageFadeTimeInterval
                         delay:0.0f
                       options:(UIViewAnimationCurveEaseIn)
                    animations: ^{logoPageView.alpha = 1.0f;}
                    completion:^(BOOL finished){
                       
                       // start the gleam!
                       [logoPageView StartAnimations];
                       
                       // the user must view the logo page for some arbitrary amount of time <g>
                       [NSTimer scheduledTimerWithTimeInterval:kLogoPageDisplayTimeInterval
                                                        target:self
                                                      selector:@selector(HideLogoPage:)
                                                      userInfo:nil
                                                       repeats:NO];
                    }];
   NSLog(@"LogoPage built...");
   [self ReportMemoryUsage];

}
    
-(void)HideLogoPage:(NSTimer*)logoTimer
{
   // build the cover...
   [self DisplayCover];
   
   UIImageView* logoPageView = (UIImageView*)[self.view viewWithTag:kLogoPageViewTag];
   
   // fade out the logo page...
   [UIView animateWithDuration:kLogoPageFadeTimeInterval
                         delay:0.0f
                       options:(UIViewAnimationCurveEaseOut)
                    animations: ^{logoPageView.alpha = 0.0f; self.mainScrollView.alpha = 1.0;}
                    completion:^(BOOL finished){
                       [logoPageView removeFromSuperview];
                       NSLog(@"LogoPage removed...");
                       [self ReportMemoryUsage];
                    }];
}

-(void)DisplayCover
{
   NSLog(@"CoverPage about to be built...");
   [self ReportMemoryUsage];
   
   UIImage* coverImage = nil;
   
   coverImage = [UIImage newImageFromResource:@"TI_Cover.jpg"];
   ABookView* coverView = [[ABookView alloc] initWithImage:coverImage];
   [coverImage release];
   
   coverView.tag = kCoverViewTag;
   coverView.assetPageNumber = kCoverPageNumber;
   coverView.userInteractionEnabled = YES;
      
   // Add the bouncing buttons
   UIImageView* arrowView = nil;
   
   coverImage = [UIImage newImageFromResource:@"arrow_left.png"];
   arrowView = [[UIImageView alloc] initWithImage:coverImage];
   [coverImage release];
   
   arrowView.tag = kLeftReadArrow;
   arrowView.frame = CGRectMake(376.0f, 544.0f, 66.0f, 61.0f);
   [coverView addSubview:arrowView];
   [arrowView release];
   
   coverImage = [UIImage newImageFromResource:@"arrow_right.png"];
   arrowView = [[UIImageView alloc] initWithImage:coverImage];
   [coverImage release];
   
   arrowView.tag = kRightReadArrow;
   arrowView.frame = CGRectMake(582.0f, 547.0f, 60.0f, 60.0f);
   [coverView addSubview:arrowView];
   [arrowView release];
   
   // make 'em bounce
   [UIView animateWithDuration:1.0f
                         delay:0.0f
                       options:(UIViewAnimationCurveEaseOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat)
                    animations:^{
                       CGPoint arrowPosition = CGPointZero;
                       UIView* arrow = nil;
                       
                       arrow = [coverView viewWithTag:kLeftReadArrow];
                       arrowPosition = arrow.center;
                       arrowPosition.x = arrowPosition.x + 10.0f;
                       arrow.center = arrowPosition;
                       
                       arrow = [coverView viewWithTag:kRightReadArrow];
                       arrowPosition = arrow.center;
                       arrowPosition.x = arrowPosition.x - 10.0f;
                       arrow.center = arrowPosition;
                    }
                    completion:^(BOOL finished){

                    }];   

   
   CGRect readBookBtnFrame = CGRectMake(kReadBookBtnOriginX, kReadBookBtnOriginY, kReadBookBtnWidth, kReadBookBtnHeight);
   UIButton* readBookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
   readBookBtn.frame = readBookBtnFrame;
   readBookBtn.tag = kReadBookBtnTag;
   [readBookBtn addTarget:self action:@selector(HideCover) forControlEvents:UIControlEventTouchUpInside];
    
   if (self.appJustOpened)
   {
      // load the Cover page beneath the logo page that's currently visible
      UIImageView* logoPageView = (UIImageView*)[self.view viewWithTag:kLogoPageViewTag];
      [self.view insertSubview:coverView belowSubview:logoPageView];
      [self.view insertSubview:readBookBtn belowSubview:logoPageView]; 
      
      self.appJustOpened = NO;
   }
   else 
   {
      // just make the Cover page top-most in the stack
      [self.view addSubview:coverView];
      [self.view addSubview:readBookBtn];
   }
   
   [coverView release];

   fActivePage = 0;
   CGPoint scrollOffset = self.mainScrollView.contentOffset;
   scrollOffset.x = 0;
   self.mainScrollView.contentOffset = scrollOffset;
         
   // start the theme music
   self.currentTrack = [OALAudioTrack track];

   [self.currentTrack playFile:@"TreasureIsland.m4a" loops:-1];

   NSLog(@"CoverPage built...");
   [self ReportMemoryUsage];

   [self BuildHowToPage];
}

-(void)BuildHowToPage
{
   NSLog(@"HowToPage about to be built...");
   [self ReportMemoryUsage];

   UIImage* howToImage = [UIImage newImageFromResource:@"howto.jpg"];
   UIImageView* howToImgView = [[UIImageView alloc] initWithImage:howToImage];
   [howToImage release];
   
   howToImgView.userInteractionEnabled = YES;
   howToImgView.tag = kHowToViewTag;
   
   // recognize touches on the howto page that indicate that the user doesn't want to see the howto
   // page again...
   UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HowToPageTouched:)];
   recognizer.cancelsTouchesInView = NO;
   recognizer.numberOfTapsRequired = 1;
   recognizer.numberOfTouchesRequired = 1;
   recognizer.delegate = self;
   [howToImgView addGestureRecognizer:recognizer];
   [recognizer release];
   
   // load the howto page beneath the Cover page
   [self.view insertSubview:howToImgView belowSubview:self.CoverView];
   [howToImgView release];

   NSLog(@"HowToPage built...");
   [self ReportMemoryUsage];

   [self BuildCreditsPage];
}

-(void)BuildCreditsPage
{
   NSLog(@"CreditsPage about to be built...");
   [self ReportMemoryUsage];

   NSString* imageKey = [NSString stringWithFormat:kPageNumberTemplate, 0, 0];
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:imageKey ofType:nil];
   
   ABookView* creditsPageView = [[ABookView alloc] init];
   creditsPageView.frame = CGRectMake(0.0f, 0.0f, 1959.0f, 748.0f);
   creditsPageView.tag = kCreditsPageTag;
   creditsPageView.assetPageNumber = kCreditsPageNumber;
   creditsPageView.userInteractionEnabled = YES;
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   creditsPageView.image = image;
   [image release];
   
   [creditsPageView LoadAssets:@"CreditsPage_Assets.plist"];
   
   [self.view insertSubview:creditsPageView belowSubview:self.HowToPageView];
   
   NSLog(@"CreditsPage just built...");
   [self ReportMemoryUsage];

   [creditsPageView release];
}

-(void)HideCover
{
   // fade out the opening opening theme
   [self.currentTrack fadeTo:0.0f duration:1.0f target:self selector:@selector(OpeningThemeComplete:)];
   
   UIView* btnView = [self.view viewWithTag:kReadBookBtnTag];
   [btnView removeFromSuperview];
   
   UIView* coverView = [self.view viewWithTag:kCoverViewTag];
   [coverView removeFromSuperview];
}

-(void)OpeningThemeComplete:(id)stopper
{
   [self.currentTrack clear];
   self.currentTrack = nil;
}

-(void)HideMap:(NSNotification*)notification
{
   [self dismissModalViewControllerAnimated:YES];
      
   [[self LoadedPageWithNumber:fActivePage] StartAnimations];

   // clean up the Map!
   self.mapViewController = nil;
   
   NSLog(@"Map dismissed!");
   [self ReportMemoryUsage];
}

-(void)HowToPageTouched:(UIGestureRecognizer*)recognizer
{
   CGPoint touchLocation = [recognizer locationInView:recognizer.view];
   
   if (CGRectContainsPoint(self.howToDismissRegion, touchLocation))
   {
      [self.HowToPageView removeFromSuperview];
      
      [self ShowCredits];
   } 
}

-(void)ShowCredits
{
   // ensure that we're positioned at the first page of the first chapter
   fActiveChapter = 1;
   fActivePage = 0;
   
   // readers have to either watch the credits or leave the page by hitting its
   // 'Skip Intro' or 'Begin' buttons - no swiping allowed...
   fMainScrollView.scrollEnabled = NO;
         
   // start up the animations on the page to be revealed
   ABookView* creditsPageView = self.CreditsPageView;
   
   if (nil != creditsPageView)
   {
      [creditsPageView StartAnimations];      
   }
}

-(void)ExitToSpaceDogSite
{
   NSURL* treasureIslandURL = [NSURL URLWithString:kTreasureIslandURL];
   
   [[UIApplication sharedApplication] openURL:treasureIslandURL];   
}

-(BOOL)ChapterIsTooBig:(NSUInteger)chapterNumber
{
   return [[ABookManager sharedBookManager] ChapterIsBig:chapterNumber];
}

-(void)PositionOnChapter:(NSUInteger)chapterNumber
{
   // prepare to position the main scroll view on the initial page for
   // the selected chapter
   
   ABookManager* bookManager = [ABookManager sharedBookManager];
   
   NSUInteger rawPageNumberForChapterStart = [bookManager RawPageIndexForChapter:chapterNumber AndPage:0];
   
   if (fActivePage == rawPageNumberForChapterStart)
   {
      // we're already there!
      return;
   }
      
   // Unload the current view set...
   for (UIView* subview in self.mainScrollView.subviews)
   {
      if ([subview isKindOfClass:[ABookView class]])
      {
         [subview removeFromSuperview];
         [self.viewQueue enqueue:subview];
         [(ABookView*)subview Sterilize];
      }
   }
   
   NSUInteger firstPageToLoad = 0;
   NSUInteger lastPageToLoad = 0;
   NSUInteger pageToShow = 0;
   CGFloat newContentOffset = 0.0f;
   
   NSUInteger backwardPreload = fCurrentBackwardPreload;
   NSUInteger forwardPreload = fCurrentForwardPreload;
   
   // adjust backward/forward preload based on current memory situation/chapter requested
   if ([self ChapterIsTooBig:chapterNumber])
   {
      backwardPreload = 0;
      forwardPreload = 0;
   }
   
   // the first chapter is a special case, i.e. it actually starts on page 1
   // (versus page 0)
   if (0 == rawPageNumberForChapterStart)
   {
      firstPageToLoad = 1;
      lastPageToLoad = 1 + forwardPreload + 1;
      pageToShow = 1;
      newContentOffset = kPageWidth;
   }
   else
   {
      firstPageToLoad = rawPageNumberForChapterStart - backwardPreload;
      lastPageToLoad = rawPageNumberForChapterStart + forwardPreload;
      pageToShow = rawPageNumberForChapterStart;
      newContentOffset = rawPageNumberForChapterStart * kPageWidth;
   }
   
   // ... otherwise, load the selected set   
   for (NSUInteger i = firstPageToLoad; i <= lastPageToLoad; i++)
   {
      ABookView* page = (ABookView*)[self.viewQueue dequeue];
      
      [page SetToPageNumber:i];
      
      [self.mainScrollView addSubview:page];
   }
   
   // position the scrollView on the first page of the chapter
   [self.mainScrollView setContentOffset:CGPointMake(newContentOffset, 0.0f) animated:NO];
   
   self.lastContentOffset = newContentOffset;
   
   [self ShowPage:pageToShow Scrolling:SCROLLING_NONE];
}

-(void)LoadChapter:(NSUInteger)chapter
{
   fActiveChapter = chapter;
      
   // jump to the requested chapter
   [self PositionOnChapter:chapter];
      
   [self.view bringSubviewToFront:self.BookmarkView];
   
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kNotificationChapterLoaded
    object:nil];
}

-(void)ChapterSelected:(NSNotification*)notification
{
   // extract the number of the chapter to be loaded
   NSDictionary* notificationData = [notification userInfo];
   
   if (nil != notificationData)
   {
      NSNumber* chapterNumber = [notificationData objectForKey:@"chapterNumber"];
      
      if (nil != chapterNumber)
      {                           
         // start the chapter loading...
         [self LoadChapter:[chapterNumber unsignedIntegerValue]];
      }
   }
}

-(void)ChapterLoaded:(NSNotification*)notification
{   
   [self HideMap:nil]; 
   
   //[[self LoadedPageWithNumber:fActivePage] StartAnimations];
}

-(void)SkipIntro:(NSNotification*)notification
{
   fMainScrollView.scrollEnabled = YES;
   
   [fMainScrollView setContentOffset:CGPointMake(kPageWidth, 0.0f) animated:YES];
   
   // force the unloading of the Credits Page
   [self.CreditsPageView StopAnimations];
   [self.CreditsPageView removeFromSuperview];
   
   [[self LoadedPageWithNumber:1] StartAnimations];
   
   NSLog(@"CreditsPage removed");
   [self ReportMemoryUsage];
}

-(void)ConfigureAudio
{   
   // We don't want ipod music to keep playing since
   [OALAudioSession sharedInstance].allowIpod = NO;
   
   // Mute all audio if the silent switch is turned on.
   [OALAudioSession sharedInstance].honorSilentSwitch = YES;
}

-(void)RegisterForNotifications
{
   // notification issued when a new chapter has been selected
   [[NSNotificationCenter defaultCenter]
    addObserver:self 
    selector:@selector(ChapterSelected:)
    name:kNotificationChapterSelected 
    object:nil];
   
   // issued when a new chapter has been loaded
   [[NSNotificationCenter defaultCenter]
    addObserver:self 
    selector:@selector(ChapterLoaded:) 
    name:kNotificationChapterLoaded 
    object:nil];
   
   // forces the credits sequence to be skipped
   [[NSNotificationCenter defaultCenter]
    addObserver:self 
    selector:@selector(SkipIntro:) 
    name:kNotificationSkipIntro
    object:nil];
   
   // received when the reader wants to dismiss the Map
   [[NSNotificationCenter defaultCenter]
    addObserver:self 
    selector:@selector(HideMap:) 
    name:kNotificationCloseMap
    object:nil];
}

-(void)BuildScrollView
{
   AScrollView* scrollView = [[AScrollView alloc] initWithFrame:CGRectMake(0, 0, kPageWidth, kPageHeight)];
   
   scrollView.leftScrollRegion = CGRectMake(0.0f, 0.0f, 200.0f, kPageHeight);
   scrollView.rightScrollRegion = CGRectMake(824.0f, 0.0f, 200.0f, kPageHeight);
   
   scrollView.contentSize = CGSizeMake([[ABookManager sharedBookManager] TotalNumberOfPages] * kPageWidth, kPageHeight);
   scrollView.scrollEnabled = YES;
   scrollView.pagingEnabled = YES;
   scrollView.showsHorizontalScrollIndicator = NO;
   scrollView.alwaysBounceVertical = NO;
   scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
   scrollView.directionalLockEnabled = YES;
   scrollView.bounces = NO;	
   scrollView.clipsToBounds = YES;
   scrollView.backgroundColor = [UIColor blackColor];
   scrollView.alpha = 0.0;
   scrollView.delegate = self;
   
   self.mainScrollView = scrollView;
   [scrollView release];
   
   [self.view addSubview:self.mainScrollView];
}

-(void)InitializeChapter1
{
   fTargetIndex = 1;
      
   for (NSInteger pageIndex = 1; pageIndex <= kMaxCachedViews; pageIndex++)
   {  
      ABookView* page = (ABookView*)[self.viewQueue dequeue];
      
      [page SetToPageNumber:pageIndex];
      
      [self.mainScrollView addSubview:page];
            
      NSLog(@"Added page %d", pageIndex);
      [self ReportMemoryUsage];
   }
}

-(void)InsertLoadedPage:(ABookView*)page
{
   [self.mainScrollView addSubview:page];
   if (fActivePage == page.pageNumber)
   {
      // This page is already supposed to be visible,
      //  lets get this moving.
      [page StartAnimations];
   }
}

-(void)LoadPageNumbered:(NSUInteger)pageNumber
{
   ABookView* page = [self LoadedPageWithNumber:pageNumber];

   if (!page)
   {
      NSLog(@"background ABOUT TO LOAD PAGE: %d", pageNumber);
      [self ReportMemoryUsage];
      
      page = (ABookView*)[self.viewQueue dequeue];
      
      if (page)
      {
         [page SetToPageNumber:pageNumber];
      
         // Make sure its added on the main thread:
         [self performSelectorOnMainThread:@selector(InsertLoadedPage:) withObject:page waitUntilDone:YES];
      
         //[page release];
            
         NSLog(@"background LOADED PAGE: %d", page.pageNumber);
         [self ReportMemoryUsage];
      }
      else
      {
         NSLog(@"background PAGE LOAD FAILED: %d", pageNumber);
         [self ReportMemoryUsage];         
      }
   }   
}

-(void)UnloadPageNumbered:(NSUInteger)pageNumber
{
   ABookView* page = [self LoadedPageWithNumber:pageNumber];

   if (nil != page)
   {
      [self UnloadPage:page];
   }
}

-(void)UnloadPage:(ABookView*)page
{
   if (!page)
   {
      return;
   }
   
   NSUInteger pageNumber = page.pageNumber;
   
   NSLog(@"background ABOUT TO REMOVE PAGE: %d", pageNumber);
   [self ReportMemoryUsage];
   
   [page retain];

   // Make sure its removed on the main thread:
   [page performSelectorOnMainThread:@selector(StopAnimations) withObject:nil waitUntilDone:YES];

   [page performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
   
   [page Sterilize];
   
   [self.viewQueue enqueue:page];
   
   [page release];
   
   NSLog(@"background REMOVED PAGE: %d", pageNumber);
   [self ReportMemoryUsage];
}

-(void)DisplayLinkDidTick:(CADisplayLink*)displayLink
{
   for (UIView* view in self.mainScrollView.subviews)
   {
      if ([view isKindOfClass:[ABookView class]])
      {
         ABookView* page = (ABookView*)view;
         [page DisplayLinkDidTick:displayLink];
      }
   }   
}


-(NSIndexSet*)ActivePageSet
{
   // Direct values
   NSInteger rangeStart = fActivePage - fCurrentBackwardPreload;
   NSInteger rangeEnd = fActivePage + fCurrentForwardPreload;
   
   // Now, clamp them
   rangeStart = MAX(rangeStart, 1);
   rangeEnd =   MIN(rangeEnd, [ABookManager sharedBookManager].LastPageIndex);
   
   // Convert to a range
   NSRange activePageRange = {rangeStart, rangeEnd - rangeStart + 1};
   
   NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:activePageRange];
   
   return indexSet;
}

-(void)UnloadPagesNotInRange:(NSIndexSet*)range
{
   // Remove pages that are no longer in the range
   for (UIView* view in self.mainScrollView.subviews)
   {
      if ([view isKindOfClass:[ABookView class]])
      {
         ABookView* page = (ABookView*)view;
         NSInteger pageNumber = page.pageNumber;
         if (![range containsIndex:pageNumber])
         {
            [self UnloadPage:page];
         }
      }
   }   
}

-(void)LoadPagesInRange:(NSIndexSet*)range
{   
   // Added any new pages that are in the range.
   [range enumerateIndexesUsingBlock:^(NSUInteger pageNumber, BOOL* stop){
      
      [self LoadPageNumbered:pageNumber];               
   }];
}

-(void)LoadPagesInRange:(NSIndexSet*)range Scrolling:(int)scrollDirection
{
   NSLog(@"Loading pages in range: %@", range);
   fCurrentScrollDirection = scrollDirection;
   dispatch_queue_t mainQueue = dispatch_get_main_queue();
   dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   
   dispatch_async(concurrentQueue, ^{
      
      NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

      [self performSelectorOnMainThread:@selector(UnloadPagesNotInRange:) withObject:range waitUntilDone:YES];
      
      [self LoadPagesInRange:range];

      dispatch_async(mainQueue, ^{

         if (SCROLLING_NONE == scrollDirection)
         {            
            CGPoint contentOffset = self.mainScrollView.contentOffset;
            
            contentOffset.x = fTargetIndex * kPageWidth;
            
            self.mainScrollView.contentOffset = contentOffset;
            
            ABookView* page = [self LoadedPageWithNumber:fTargetIndex];
            [page StartAnimations];

            fActivePage = fTargetIndex;
            
            // notify that the chapter has been loaded (and is visible)
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kNotificationChapterLoaded
             object:nil];
         }
         
         self.mainScrollView.scrollEnabled = YES;
      });
      
      [pool drain];
      
   });
}

-(ABookView*)LoadedPageWithNumber:(NSUInteger)rawPageNumber
{
   return (ABookView*)[self.view viewWithTag:kScrollViewBaseTag+rawPageNumber];
}

-(BOOL)IsLoaded:(NSUInteger)pageNumber
{
   return nil != [self LoadedPageWithNumber:pageNumber];
}

-(void)ReportPages
{
   NSLog(@"Currently loaded pages:\n-------------");
   for (UIView* view in self.mainScrollView.subviews)
   {
      if ([view isKindOfClass:[ABookView class]])
      {
         ABookView* bookView = (ABookView*)view;
         NSLog(@"  %d:: retains: %d, assets: %d, address: %p", 
               bookView.pageNumber, 
               bookView.retainCount, 
               bookView.assets.count,
               bookView);
      }
      else
      {
         NSLog(@"  ?:: <not a page> object:%@", view);
      }
   }
   NSLog(@"Other views:\n-------------");
   for (UIView* view in self.view.subviews)
   {
      NSLog(@"  %@", view);
   }
//   NSLog(@"Preloaded sound effects: %d", [OALSimpleAudio sharedInstance].preloadCacheCount);
//   [self ReportMemoryUsage];
}

-(void)ReportMemoryUsage
{
   struct task_basic_info info;
   mach_msg_type_number_t size = sizeof(info);
   kern_return_t kerr = task_info(mach_task_self(),
                                  TASK_BASIC_INFO,
                                  (task_info_t)&info,
                                  &size);
   if( kerr == KERN_SUCCESS ) 
   {
      NSLog(@"Memory usage (bytes): %u", info.resident_size);
      NSLog(@" ");
   } 
   else 
   {
      NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
      NSLog(@" ");
   }
}

// This method adds and removes pages so that the selectedPageNumber is in the
// middle of the current 'view set', i.e. the set of currently loaded ABookView
// instances.
-(void)CenterViewSetOn:(NSUInteger)selectedPageNumber Scrolling:(int)scrollDirection
{
   fTargetIndex = selectedPageNumber;
   NSInteger lastPage = [ABookManager sharedBookManager].LastPageIndex;
   
   
   // Load pages before the selected page...
   NSInteger loadStart = selectedPageNumber - fCurrentBackwardPreload;
   if (SCROLLING_RIGHT == scrollDirection)
   {
      // When scrolling left, lower pages are forward, not backward
      loadStart = selectedPageNumber - fCurrentForwardPreload;
   }
   
   // ... unless that would mean attempting to load pages before the start of
   // the book, in which case we clamp the bottom of the load range to the
   // first page of the book (which is page 1).
   if (loadStart < 1)
   {
      loadStart = 1;
      fTargetIndex = 1;
   }
   
   NSInteger loadLength = fCurrentBackwardPreload + fCurrentForwardPreload + 1;
   
   // also check for attempting to load beyond the end of the book
   if (loadStart+loadLength > lastPage+1)
   {      
      loadLength = lastPage - loadStart + 1;
   }
   
   // Extend to more then the center page
   NSRange loadRange = NSMakeRange(loadStart, loadLength);
   
   self.mainScrollView.scrollEnabled = NO;
   
   [self LoadPagesInRange:[NSIndexSet indexSetWithIndexesInRange:loadRange] Scrolling:scrollDirection];
}

-(void)ShowPage:(NSUInteger)pageNumber Scrolling:(int)scrollDirection
{
   fActivePage = pageNumber;
   
   [self UnloadPagesNotInRange:[self ActivePageSet]];
   
   // Start animations on this page
   ABookView* page = [self LoadedPageWithNumber:pageNumber];
   if (page)
   {
      [page StartAnimations];
   }
   else
   {
      NSLog(@"Trying to show page %d, which hasn't been loaded; loading now", pageNumber);
      
      // Now that loading is no longer done in the background
      //  through LoadPagesInRange, we can just load it now
      [self LoadPageNumbered:pageNumber];
   }

   // Stop animations on all other pages- necessary?
   for (UIView* view in self.mainScrollView.subviews)
   {
      if ([view isKindOfClass:[ABookView class]])
      {
         ABookView* page = (ABookView*)view;
         
         if (pageNumber != page.pageNumber)
         {
            [page StopAnimations];
         }
      }
   } 
   
   // Determine which pages to unload and load based on the scrollDirection
   NSInteger pageNumberToLoad = 0;
   
   self.mainScrollView.scrollEnabled = NO;
   
   switch (scrollDirection)
   {
      case SCROLLING_LEFT:
      {         
         //if (1 < fActivePage - fCurrentForwardPreload)
         //{
         //   [self UnloadPage:[self LoadedPageWithNumber:fActivePage-(fCurrentForwardPreload+1)]];
         //}
            
         pageNumberToLoad = fActivePage + fCurrentForwardPreload;
            
         ABookManager* bookManager = [ABookManager sharedBookManager];
            
         if (![self IsLoaded:pageNumberToLoad] && pageNumberToLoad <= bookManager.LastPageIndex)
         {
           [self LoadPageNumbered:pageNumberToLoad];
         }
      }
      break;
         
      case SCROLLING_RIGHT:
      {
         //[self UnloadPage:[self LoadedPageWithNumber:fActivePage + fCurrentForwardPreload + 1]]; 
         
         pageNumberToLoad = fActivePage - fCurrentBackwardPreload;
         
         if (1 <= pageNumberToLoad)
         {
            [self LoadPageNumbered:pageNumberToLoad];
         }
      }
      break;
   }
   
   self.mainScrollView.scrollEnabled = YES;
}

#pragma mark -
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
   // if the Bookmark is not currently visible, then make it so
   if (!self.isBookmarkVisible)
   {
      [self RevealBookmark];
   }
   
   // next, determine if a new page was actually scrolled-to - if not,
   // then just get out. The purpose of this check is to stop minor/unintentional
   // horizontal movements of the scrollView from triggering a page load
   if (self.lastContentOffset == scrollView.contentOffset.x)
   {
      return;
   }
   
   // determine the number of the page scrolled-to
   NSInteger selectedPageNum;
   NSInteger scrollOffsetX = (NSUInteger)scrollView.contentOffset.x;
   
   // also, determine the current scrolling direction
   int scrollDirection = self.lastContentOffset > scrollView.contentOffset.x?SCROLLING_RIGHT:SCROLLING_LEFT;
         
   selectedPageNum = scrollOffsetX / kPageWidth;
   
   if (0 == selectedPageNum)
   {
      [scrollView setContentOffset:CGPointMake(kPageWidth, 0.0f) animated:YES];
      
      return;
   }
   
   self.lastContentOffset = scrollView.contentOffset.x;

   [self ShowPage:selectedPageNum Scrolling:scrollDirection];
}

// this delegate method is called when a UIScrollView's setContentOffset:animated:
// method is called and the animation has completed. It's effectively the equivalent
// of the scrollViewDidEndDecelerating: method and, since the same stuff needs to
// happen, we just call the scrollViewDidEndDecelerating: method "manually"
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
{
   [self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
   BOOL result = NO;
   
   if (kHowToViewTag == gestureRecognizer.view.tag)
   {
      CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
      
      if (CGRectContainsPoint(self.howToDismissRegion, touchLocation))
      {
         result = YES;
      }      
   }
   
   return result;
}

@end
