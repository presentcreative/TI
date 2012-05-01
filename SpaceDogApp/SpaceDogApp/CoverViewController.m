//
//  CoverViewController.m
//  SpaceDogApp
//
//  Created by Dan on 11-05-12.
//  Copyright 2011 Daniel Nesbitt. All rights reserved.
//

#import "CoverViewController.h"


@implementation CoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   if (UIDeviceOrientationIsLandscape(interfaceOrientation))
   {
      return YES;
   }
   return NO;
}

-(IBAction)readButtonPress:(id)sender
{
   [self dismissModalViewControllerAnimated:YES];
}

@end
