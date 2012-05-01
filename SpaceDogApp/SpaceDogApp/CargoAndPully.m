// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "CargoAndPully.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "BookView.h"
#import "Trigger.h"
#import "OALSimpleAudio.h"
#import "NSTimer+Blocks.h"

#define kSoundTriggerThreshold   50.0f // pixels

@interface ACargoAndPully (Private)
-(CGFloat)MoveDeltaY:(CGFloat)deltaY;
-(void)PlaySoundCargoDown;
-(void)PlaySoundCargoUp;
@end

@implementation ACargoAndPully

@synthesize cargoView=fCargoView;
@synthesize minY=fMinY;
@synthesize maxY=fMaxY;
@synthesize cargoDownSoundEffect=fCargoDownSoundEffect;
@synthesize cargoUpSoundEffect=fCargoUpSoundEffect;
@synthesize soundPlaying=fSoundPlaying;

-(void)dealloc
{   
   if (![@"" isEqualToString:fCargoDownSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fCargoDownSoundEffect];
   }
   Release(fCargoDownSoundEffect);
   
   if (![@"" isEqualToString:fCargoUpSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] unloadEffect:fCargoUpSoundEffect];
   }
   Release(fCargoUpSoundEffect);
   
   Release(fCargoView);
   
   [super dealloc];
}

-(void)BaseInit 
{
   [super BaseInit];
   
   self.minY = 0.0f;
   self.maxY = 0.0f;
   self.cargoDownSoundEffect = @"";
   self.cargoUpSoundEffect = @"";
   self.soundPlaying = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
               
   ////////////////////////////////////////////////////////////////////////////////
   // cargo view   
   NSDictionary* viewSpec = element.cargoView;
   
   self.minY = viewSpec.minY;
   self.maxY = viewSpec.maxY;
   
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:viewSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   UIImageView* cargoView = [[UIImageView alloc] init];
   cargoView.frame = viewSpec.frame; 
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   cargoView.image = image;
   [image release];
   
   self.cargoView = cargoView;
   self.cargoView.userInteractionEnabled = YES;
   [view addSubview:self.cargoView];
   [cargoView release];
   
   self.cargoDownSoundEffect = viewSpec.cargoDownSoundEffect;
   
   if (![@"" isEqualToString:self.cargoDownSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.cargoDownSoundEffect];
   }
   
   self.cargoUpSoundEffect = viewSpec.cargoUpSoundEffect;
   
   if (![@"" isEqualToString:self.cargoUpSoundEffect])
   {
      [[OALSimpleAudio sharedInstance] preloadEffect:self.cargoUpSoundEffect];
   }
}

-(CGFloat)MoveDeltaY:(CGFloat)deltaY
{    
   CGPoint currentPosition = self.cargoView.center;
   
   CGFloat newY = currentPosition.y + deltaY;
   
   // clamp to min/max specified for this segment
   if (newY <= self.minY)
   {
      newY = self.minY;
   }
   else if (newY >= self.maxY)
   {
      newY = self.maxY;
   }
   
   currentPosition.y = newY;
   
   self.cargoView.center = currentPosition;
   
   if (fabs(newY) > kSoundTriggerThreshold)
   {
      if (0.0f < newY)
      {
         [self PlaySoundCargoDown];
      }
      else
      {
         [self PlaySoundCargoUp];
      }
   }
   
   return newY;
}

-(void)PlaySoundCargoDown
{
   if (self.isSoundPlaying)
   {
      return;
   }
   
   self.soundPlaying = YES;
   
   [[OALSimpleAudio sharedInstance] playEffect:self.cargoDownSoundEffect];
   
   [NSTimer scheduledTimerWithTimeInterval:1.0f block:^{self.soundPlaying=NO;} repeats:NO];
}

-(void)PlaySoundCargoUp
{
   if (self.isSoundPlaying)
   {
      return;
   }
   
   self.soundPlaying = YES;
   
   [[OALSimpleAudio sharedInstance] playEffect:self.cargoUpSoundEffect];
   
   [NSTimer scheduledTimerWithTimeInterval:1.0f block:^{self.soundPlaying=NO;} repeats:NO];
}


#pragma mark ACustomAnimation protocol
// retrieve the latest results recorded by the pan gesture recognizer and
// translate the position on the cargoView
-(IBAction)HandleGesture:(UIGestureRecognizer*)sender
{
   UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
   
   CGFloat deltaY = ((CGPoint)[recognizer translationInView:self.cargoView]).y;
   
   [CATransaction begin];
   
   // disabling actions makes the animation of the layers smoother
   [CATransaction setDisableActions:YES];
   
   [self MoveDeltaY:deltaY];
   
   [CATransaction commit];
   
   [recognizer setTranslation:CGPointZero inView:self.containerView];
}

@end
