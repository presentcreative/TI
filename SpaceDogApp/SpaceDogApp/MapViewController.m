// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "MapViewController.h"
#import "BookView.h"
#import "Constants.h"

#define kMapAssetsFilename    @"Map_Assets.plist"
#define kMapBackgroundImage   @"mapnew.jpg"
#define kBookViewTag          99

@implementation MapViewController

#pragma mark - View lifecycle

-(void)loadView
{
   // The Map view is simple enough that it doesn't need to reside in an xib
   ABookView* controllersView = [[ABookView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kPageWidth, kFullPageHeight)];
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:kMapBackgroundImage ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
   }
   else
   {
      UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
      controllersView.image = image;
      [image release];
   
      self.view = controllersView;
   }
   [controllersView release];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // load the assets descriptor file
   ABookView* bookView = (ABookView*)self.view;
   
   [bookView LoadAssets:kMapAssetsFilename];   
}

-(void)viewDidAppear:(BOOL)animated
{
   ABookView* bookView = (ABookView*)self.view;

   [bookView StartAnimations];   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations, i.e. Home button on right
   if (interfaceOrientation == UIDeviceOrientationLandscapeRight
       || interfaceOrientation == UIDeviceOrientationLandscapeLeft)
   {
      return YES;
   }
   
   return NO;
}

@end
