// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

/**
 * Global Constants
 */

#define kTreasureIslandURL             @"http://spacedogbooks.com/treasureisland"

#define kBookInfoPlist                 @"TreasureIsland.plist"
#define kBookInfoChapterKeyTemplate    @"Chapter%d"
#define kChapterAssetsFilename         @"Chapter%d_Assets.plist"

#define kPageWidth                     1024
#define kPageHeight                    748
#define kSystemStatusBarHeight         20
#define kFullPageHeight                kPageHeight+kSystemStatusBarHeight

#define kPageNumberTemplate            @"TI_%d_%d.jpg" // TI_<chapter number>_<page number>

#define kScrollViewBaseTag             1000
#define kViewSetLoadRemoveIncrement    1

// Map related
#define kDraggableShipViewTag          200

// accelerometer related
#define kSampleRate                    60.0  // samples per second
#define kCutoffFrequency                5.0

// Notifications
#define kNotificationChapterSelected   @"NOTIFICATION_CHAPTER_SELECTED"
#define kNotificationChapterLoaded     @"NOTIFICATION_CHAPTER_LOADED"
//#define kNotificationPageVisible       @"NOTIFICATION_PAGE_VISIBLE"
//#define kNotificationPageHidden        @"NOTIFICATION_PAGE_HIDDEN"
#define kNotificationSkipIntro         @"NOTIFICATION_SKIP_INTRO"
#define kNotificationTheEnd            @"NOTIFICATION_THE_END"
#define kNotificationCloseMap          @"NOTIFICATION_CLOSE_MAP"
#define kNotificationMapHidden         @"NOTIFICATION_MAP_HIDDEN"

// Chipmunk related
#define kGravitationalConstant         8000.0f
#define kFilterFactor                    0.1f //0.05f

