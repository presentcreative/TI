// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$
#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "Constants.h"
#import "OALAudioTrack.h"
#import "ScrollView.h"

#define kBookmarkViewTag            2
#define kCoverViewTag               3
#define kReadBookBtnTag             4
#define kPageSelectionViewTag       5
#define kLogoPageViewTag            6
#define kHowToViewTag               7
#define kCreditsPageTag             8
#define kBookmarkHighlightViewTag   9
#define kLeftReadArrow             10
#define kRightReadArrow            11
#define kPageSelectionArrowTag    100
#define kPageViewTagBase         1000

#define kLogoPageDisplayTimeInterval 2.5f
#define kLogoPageFadeTimeInterval    1.5f

#define kReadBookBtnOriginX      428
#define kReadBookBtnOriginY      530
#define kReadBookBtnWidth        166
#define kReadBookBtnHeight        71

#define kBookmarkOriginX         924
#define kBookmarkHiddenOriginY  -320
#define kBookmarkVisibleOriginY  0

#define kBookmarkHighlightOriginX           kBookmarkOriginX+10.0f
#define kBookmarkHighlightHiddenOriginY    320.0f
#define kBookmarkHighlightVisibleOriginY     0.0f

#define kBookmarkCoverPageOptionOriginY       20
#define kBookmarkCoverPageOptionSizeHeight    50

#define kBookmarkMapOptionOriginY             90
#define kBookmarkMapOptionSizeHeight          40

#define kBookmarkHelpOptionOriginY           145
#define kBookmarkHelpOptionSizeHeight         50

#define kBookmarkSpaceDogOptionOriginY       210
#define kBookmarkSpaceDogOptionSizeHeight     45

#define kBookmarkDismissOptionOriginY        270
#define kBookmarkDismissOptionSizeHeight      60

#define kBookmarkMaximumY                   450

#define kBookmarkAnimationSeconds              0.45
#define kBookmarkRevealAnimationSeconds        1.0

#define kPageSelectionGroupWidth         30
#define kPageSelectionGroupHeight        92
#define kPageSelectionMarkerWidth        30
#define kPageSelectionMarkerHeight       36
#define kPageNumberFilename     @"%03d.png"

@class ABookView;

@interface SpaceDogAppViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
   BOOL fAppJustOpened;
   BOOL fBookmarkVisible;
   
   NSMutableArray* fViewQueue;
   
   NSInteger fActivePage;
   NSUInteger fActiveChapter;

   AScrollView* fMainScrollView;
      
   MapViewController* fMapViewController;
   
   OALAudioTrack* fCurrentTrack;
   
   CGFloat fLastContentOffset;
   
   CGRect fHowToDismissRegion;
   
   int    fCurrentScrollDirection;
   int    fCurrentForwardPreload;
   int    fCurrentBackwardPreload;
   int    fTargetIndex;
   
   CADisplayLink* fDisplayLink;
}

@property (assign) BOOL appJustOpened;
@property (assign, getter=isBookmarkVisible) BOOL bookmarkVisible;
@property (nonatomic, retain) NSMutableArray* viewQueue;
@property (nonatomic, retain) UIScrollView* mainScrollView;
@property (nonatomic, retain) MapViewController* mapViewController;
@property (nonatomic, retain) OALAudioTrack* currentTrack;
@property (assign) CGFloat lastContentOffset;
@property (assign) CGRect howToDismissRegion;

@property (readonly) ABookView* currentBookView;
@property (readonly) UIImageView* CoverView;
@property (readonly) ABookView* HowToPageView;
@property (readonly) ABookView* CreditsPageView;
@property (readonly) UIImageView* BookmarkView;
@property (readonly) UIImageView* BookmarkHighlightView;

@property (nonatomic, retain) CADisplayLink* displayLink;

-(void)RevealBookmark;
-(void)HideBookmark;

-(void)applicationWillResignActive:(UIApplication*)application;
-(void)applicationDidBecomeActive:(UIApplication*)application;

@end