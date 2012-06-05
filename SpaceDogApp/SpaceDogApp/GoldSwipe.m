// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "GoldSwipe.h"
#import "TriggeredTextureAtlasBasedSequence.h"
#import "ImageSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@interface AGoldSwipe (Private)
-(void)SetUpSwipe1Sequence;
-(void)SetUpSwipe2Sequence;
@end


@implementation AGoldSwipe

@synthesize swipe1Sequence=fSwipe1Sequence;
@synthesize swipe2Sequence=fSwipe2Sequence;
@synthesize sequenceToPlay=fSequenceToPlay;
@synthesize sequenceInPlay=fSequenceInPlay;

-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   Release(fSwipe1Sequence);
   Release(fSwipe2Sequence);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.sequenceInPlay = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   ATriggeredTextureAtlasBasedSequence* tSequence = nil;
   
   // first swipe sequence
   tSequence = [[ATriggeredTextureAtlasBasedSequence alloc] 
                initWithElement:element.swipe1Layer 
                RenderOnView:nil];
   
   self.swipe1Sequence = tSequence;
   [tSequence release];
   [view.layer addSublayer:self.swipe1Sequence.layer];
   
   // second swipe sequence
   tSequence = [[ATriggeredTextureAtlasBasedSequence alloc] 
                initWithElement:element.swipe2Layer 
                RenderOnView:nil];
   
   self.swipe2Sequence = tSequence;
   [tSequence release];
   [view.layer addSublayer:self.swipe2Sequence.layer];
   
   // register for the 2 Notifications that could be issued by the sequences
   void* notificationBlock = ^(NSNotification* notif){
      
      if ([@"swipe1Sequence" isEqualToString:[notif name]])
      {
         // first swipe completed
         [self SetUpSwipe2Sequence];
      }
      else if ([@"swipe2Sequence" isEqualToString:[notif name]])
      {
         // that's it! All the coins have been swept off the table :)
         self.swipe2Sequence.layer.hidden = YES;
         self.sequenceInPlay = YES; // prevent any unnecessary processing...
      }
   };
   
   [[NSNotificationCenter defaultCenter]
    addObserverForName:@"swipe1Sequence"
    object:nil 
    queue:nil 
    usingBlock:notificationBlock];
   
   [[NSNotificationCenter defaultCenter]
    addObserverForName:@"swipe2Sequence"
    object:nil 
    queue:nil 
    usingBlock:notificationBlock];
   
   [self SetUpSwipe1Sequence];
}

-(void)SetUpSwipe1Sequence
{
   self.swipe2Sequence.layer.hidden = NO;
   self.swipe1Sequence.layer.hidden = NO;
   self.sequenceToPlay = @selector(PlaySwipe1Sequence);
   
   self.sequenceInPlay = NO;
}

-(void)SetUpSwipe2Sequence
{
   self.swipe1Sequence.layer.hidden = NO;
   self.swipe2Sequence.layer.hidden = NO;
   self.sequenceToPlay = @selector(PlaySwipe2Sequence);   
   
   self.sequenceInPlay = NO;
}

-(void)PlaySwipe1Sequence
{
   [self.swipe1Sequence Trigger];
}

-(void)PlaySwipe2Sequence
{
   [self.swipe2Sequence Trigger];
}

#pragma mark -
#pragma mark ACustomAnimation protocol 
-(void)Start:(BOOL)triggered
{
   // prime the animations
   [self.swipe1Sequence Start:NO];
   [self.swipe2Sequence Start:NO];
}

-(void)Stop
{
   [super Stop];
   [self.swipe1Sequence Stop];
   [self.swipe2Sequence Stop];
    [self SetUpSwipe2Sequence];
   [self SetUpSwipe1Sequence];

}

-(void)HandleGesture:(UIGestureRecognizer*)recognizer
{
   if (!self.sequenceInPlay)
   {
      self.sequenceInPlay = YES;
      
      [self performSelector:self.sequenceToPlay];
   }
}

@end
