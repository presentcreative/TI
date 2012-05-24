    // Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "TextureAtlasBasedSequence.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "ImageSequenceLayer.h"
#import "NSMutableArray+Queue.h"
#import "BookView.h"
#import "CALayer+CustomAnimation.h"

@interface ATextureAtlasBasedSequence (Private)
-(void)BaseStart:(NSTimer*)timer;
-(void)RepeatSequence:(NSTimer*)timer;
-(AImageSequence*)BaseSequence;
@end


@implementation ATextureAtlasBasedSequence

@synthesize sequenceId = fSequenceId;
@synthesize resourceBase = fResourceBase;
@synthesize imageSequences = fImageSequences;
@synthesize sequenceInPlay = fSequenceInPlay;
@synthesize lastCompletedSequence = fLastCompletedSequence;
@synthesize repeatCount = fRepeatCount;
@synthesize duration = fDuration;
@synthesize delay = fDelay;
@synthesize effectQueue = fEffectQueue;
@synthesize singleImageBaseSequence = fSingleImageBaseSequence;
@synthesize layer = fLayer;
@synthesize baseFrame = fBaseFrame;
@synthesize textureAtlas = fTextureAtlas;
@synthesize stepTriggerRequired = fStepTriggerRequired;
@synthesize autoResetToBase = fAutoResetToBase;
@synthesize forward = fForward;

-(void)dealloc
{  
   self.layer.delegate = nil;
   if (self.layer.superlayer)
   {
      [self.layer removeFromSuperlayer];
   }
   Release(fLayer);
   
   Release(fSequenceId);
   Release(fResourceBase);
   Release(fImageSequences);
   Release(fEffectQueue);
   Release(fTextureAtlas);
   
   [super dealloc];

}

-(id)retain
{
   return [super retain];
}

-(void)BaseInit
{
   [super BaseInit];
   self.forward = YES;
   self.sequenceInPlay = 0;
   self.repeatCount = NSUIntegerMax;
   
   self.duration = 0.0f;
   self.delay = 0.0f;
   self.effectQueue = [NSMutableArray array];
   self.singleImageBaseSequence = NO;
   self.textureAtlas = nil;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{   
   self.sequenceId = element.propertyId;
   
   self.stepTriggerRequired = element.stepTriggerRequired;
   self.autoResetToBase = element.autoResetToBase;
   
   if (element.hasNumRepeats)
   {
      self.repeatCount = element.numRepeats;
   }
   
   if (element.hasDelay)
   {
      self.delay = element.delay;
   }
   
   self.resourceBase = element.resourceBase;
   
   // load the texture atlas
   NSString* textureAtlasPath = [[NSBundle mainBundle] pathForResource:self.resourceBase ofType:@"plist"];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:textureAtlasPath])
   {
      ALog(@"Animation texture atlas file missing: %@", self.resourceBase);
      
      return;
   }
   
   NSDictionary* textureDict = [[NSDictionary alloc] initWithContentsOfFile:textureAtlasPath];
   self.textureAtlas = textureDict;
   [textureDict release];
   
   // process the image sequences
   NSMutableArray* sequences = [[NSMutableArray alloc] initWithCapacity:[element.sequences count]];
   self.imageSequences = sequences;
   [sequences release];
   
   BOOL isBaseSequence = YES;
   
   NSUInteger sequenceIndex = 0;
   for (NSDictionary* sequenceSpec in element.sequences)
   {
      AImageSequence* imageSequence = [[AImageSequence alloc] initWithSequenceSpec:sequenceSpec];
      
      imageSequence.sequenceIndex = sequenceIndex++;
      
      if (isBaseSequence)
      {
         // there can only be one base sequence
         imageSequence.baseSequence = YES;
         
         isBaseSequence = NO;
      }
       
       [self.imageSequences addObject:imageSequence];
       [imageSequence release];
       
   }

   // because the receiver manages a texture atlas based-image, there is only
   // one image to set :)
   NSString* texturePath = [[NSBundle mainBundle] pathForResource:self.resourceBase ofType:@"png"];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:texturePath])
   {
      ALog(@"Animation texture file missing: %@", self.resourceBase);
      
      return;
   }

   // set up some place for the sequence(s) to run
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:texturePath];
   AImageSequenceLayer* imageSequenceLayer = [[AImageSequenceLayer alloc] initWithImage:image.CGImage];
   [image release];

   self.layer = imageSequenceLayer;
   [imageSequenceLayer release];
   
   // initialize the layer with the first image of the base sequence
   [self PositionOnBaseSequence];
   
   if (nil != view && [view isKindOfClass:[ABookView class]])
   {
      [(ABookView*)view RegisterAsset:self WithKey:self.sequenceId];
   }
   
   self.baseFrame = element.frame;
   self.layer.frame = self.baseFrame;
   
   if (nil != view)
   {
     [view.layer addSublayer:self.layer];  
   }
   
   // set the base sequence as the current sequence
   self.sequenceInPlay = 0;
}

-(void)BaseStart:(NSTimer*)timer
{
   if (nil != timer)
   {
      if ([timer isValid])
      {
         // TODO: determine constant or variable delay and set new timeInterval
         //       accordingly
      }
   }
   
   // are there any pre-animation effects to apply?
   NSArray* propertyEffects = ((AImageSequence*)[self.imageSequences objectAtIndex:self.sequenceInPlay]).preSequencePropertyEffects;
   
   if (nil != propertyEffects && 0 < [propertyEffects count])
   {
      // yes, apply them...
      [self ApplyPreSequenceEffects:0];
   }
   else 
   {
      // no, just start animating the base sequence
      [self AnimateSequence:0];      
   }
}

-(void)Start:(BOOL)triggered
{
   [self TransitionSequence];
   [self BaseStart:nil];
   
   if (self.currentSequence.hasSoundEffect)
   {
      [self.currentSequence.soundEffect Start:triggered];
   }
}

-(void)Stop
{
   if (self.currentSequence.hasSoundEffect)
   {
      [self.currentSequence.soundEffect Stop];
   }

   [self.layer removeAllAnimations];

   [self ResetToBaseSequence];
}

-(AImageSequence*)BaseSequence
{
   AImageSequence* result = nil;
   
   // the base sequence is always the first sequence specified in the page descriptor. always.
   if (0 < [self.imageSequences count])
   {
      result = [self.imageSequences objectAtIndex:0];
   }
   
   return result;
}

-(void)PositionOnBaseSequence
{
   AImageSequence* baseSequence = [self BaseSequence];
   
   if (nil != baseSequence)
   {
      self.layer.delegate = self;
      self.layer.contentsRect = [self ContentsRectForImageAtIndex:baseSequence.firstImageIndex];
      self.layer.position = [self PositionForImageAtIndex:baseSequence.firstImageIndex];
      
      SequenceTransition st;
      st.sequence = 0;
      st.frame = 0;
      self.lastCompletedSequence = st;
   }
}

-(void)RepeatSequence:(NSTimer*)repeatTimer
{
   NSDictionary* userInfo = repeatTimer.userInfo;
   
   NSUInteger sequenceIndex = [(NSNumber*)[userInfo objectForKey:@"sequenceIndex"] unsignedIntegerValue];
   
   [self AnimateSequence:sequenceIndex];
}

-(void)AnimateSequence:(unsigned int)sequenceIndex Forward:(BOOL)animateForward
{
   // reset the lastCompletedSequence as it's no longer relevant
   SequenceTransition st = self.lastCompletedSequence;
   
   NSUInteger currentSequenceIndex = st.sequence;
   
   AImageSequence* sequenceToAnimate = [self.imageSequences objectAtIndex:sequenceIndex];
   
   // however, *which* image in the texture map to be displayed still needs to be determined
   if (sequenceToAnimate.isImageless)
   {
      //self.layer.bounds = [self BoundsForImageAtIndex:0];
      self.layer.contentsRect = [self ContentsRectForImageAtIndex:0];
      self.layer.position = [self PositionForImageAtIndex:0];
      //      [self ArrangeImageAtIndex:0 OnLayer:self.layer];
      
      
      // are there any postEffects to apply?
      [self ApplyPostSequenceEffects:sequenceToAnimate.sequenceIndex];
      
      st.sequence = 0;
      st.frame = 0;
      
      self.lastCompletedSequence = st;
      
      return;
   }
   
   if (sequenceToAnimate.isSingleImageSequence)
   {
      int imageIndex = sequenceToAnimate.imageIndices.location;
      
      //self.layer.bounds = [self BoundsForImageAtIndex:imageIndex];
      self.layer.contentsRect = [self ContentsRectForImageAtIndex:imageIndex];
      self.layer.position = [self PositionForImageAtIndex:imageIndex];
      //      [self ArrangeImageAtIndex:imageIndex OnLayer:self.layer];
      
      
      // are there any postEffects to apply?
      [self ApplyPostSequenceEffects:sequenceToAnimate.sequenceIndex];
      
      st.sequence = sequenceIndex;
      st.frame = imageIndex;
      
      self.lastCompletedSequence = st;
      
      return;
   }
   
   if (sequenceToAnimate.isUnpatterned)
   {
      int imageIndex = sequenceToAnimate.initialFrame;
      
      self.layer.contentsRect = [self ContentsRectForImageAtIndex:imageIndex];
      self.layer.position = [self PositionForImageAtIndex:imageIndex];
      
      st.sequence = sequenceIndex;
      st.frame = imageIndex;
      
      self.lastCompletedSequence = st;
      
      return;
   }
   
   // finally! Build and schedule the animation
   CAAnimation* sequenceAnimation = animateForward?sequenceToAnimate.animation:sequenceToAnimate.reverseAnimation;
   
   NSString* currentSequenceAnimationKey = [NSString stringWithFormat:@"sequence_%d", st.sequence];
   
   st.sequence = sequenceIndex;
   st.frame = 0;
   
   self.lastCompletedSequence = st;
   
   // stop the currently running soundeffect
   if (!self.layer.animationsPaused)
   {
      AImageSequence* currentlyExecutingSequence = [self.imageSequences objectAtIndex:currentSequenceIndex];
      
      if (currentlyExecutingSequence.hasSoundEffect)
      {
         [currentlyExecutingSequence.soundEffect Stop];
      }
   }
   
   [self.layer removeAnimationForKey:currentSequenceAnimationKey];

   sequenceAnimation.delegate = self;
   [self.layer addAnimation:sequenceAnimation forKey:sequenceToAnimate.animationKey];
   sequenceAnimation.delegate = nil; //Stop retaining self
   
   if (!self.layer.animationsPaused)
   {
      if (sequenceToAnimate.hasSoundEffect)
      {
         [sequenceToAnimate.soundEffect Start:NO];
      }
   }   
}

-(void)AnimateSequence:(unsigned int)sequenceIndex
{
    AImageSequence* sequenceToAnimate = [self.imageSequences objectAtIndex:sequenceIndex];
    if (sequenceToAnimate.hasToggleProperty)
    {
        [self AnimateSequence:sequenceIndex Forward:self.isForward];
        self.forward = !self.isForward;
    }else {
        [self AnimateSequence:sequenceIndex Forward:YES];
    }
}

-(void)AnimateFromIndex:(unsigned int)fromIndex ToIndex:(unsigned int)toIndex
{
   //NSLog(@"animating from %d to %d", fromIndex, toIndex);
   
   if (fromIndex == toIndex)
   {
      return;
   }
   
   // animation is occurring 'manually', here...
   NSUInteger indexStep = fromIndex < toIndex ? 1 : -1;
   NSUInteger indexTarget = fromIndex < toIndex ? toIndex + 1 : toIndex - 1;
   NSUInteger loopCounter = fromIndex + indexStep;
   
   do {
      
      self.layer.contentsRect = [self ContentsRectForImageAtIndex:loopCounter];
      self.layer.position = [self PositionForImageAtIndex:loopCounter];
//      CGPoint position = [self PositionForImageAtIndex:loopCounter];
      
      loopCounter = loopCounter + indexStep;
      
   } while (loopCounter != indexTarget);
}
    
-(void)ResetToBaseSequence
{
   self.sequenceInPlay = 0;
   
   SequenceTransition st;
   st.sequence = 0;
   st.frame = 1;
   self.lastCompletedSequence = st;
}

-(void)ApplyPreSequenceEffects:(unsigned int)sequenceIndex
{
   [self ApplyPropertyEffects:((AImageSequence*)[self.imageSequences objectAtIndex:sequenceIndex]).preSequencePropertyEffects];   
}

-(void)ApplyPostSequenceEffects:(unsigned int)sequenceIndex
{
   [self ApplyPropertyEffects:((AImageSequence*)[self.imageSequences objectAtIndex:sequenceIndex]).postSequencePropertyEffects]; 
}

-(void)ApplyPropertyEffects:(NSArray*)propertyEffects
{
   if (nil != propertyEffects && 0 < [propertyEffects count])
   {
      if (1 == [propertyEffects count])
      {
         [self ApplyEffect:[propertyEffects objectAtIndex:0] :NO];
      }
      else 
      {
         [self ApplyEffects:propertyEffects :NO];
      }
   }   
}

-(void)TransitionSequence
{
   // transition from the current sequence to the next requested sequence
   [self AnimateSequence:self.sequenceInPlay];
}

// Calculate the next sequence to which to transition, returning YES if there is
// a sequence to which to transition, NO otherwise.
-(BOOL)CalculateNextSequence
{
   BOOL result = NO;
   
   // transitions can only occur if an appropriate 'predecessor' frame has
   // just been displayed. To determine this, we examine the 'SequenceTransitions'
   // for all but the current sequence in play to see if there are any matches
   
   // collect SequenceTransitions from sequences not in play
   NSMutableDictionary* candidateSequences = [NSMutableDictionary dictionary];
      
   // for all known image sequences...
   for (int i = 0; i < [self.imageSequences count]; i++)
   {
      // a sequence doesn't transition to itself...  unless its the only sequence
      if (i == self.sequenceInPlay && [self.imageSequences count]>1)
      {
         continue;
      }
      
      AImageSequence* imageSequence = [self.imageSequences objectAtIndex:i];
      
      // ... gather all known transitions:
      for (NSValue* sequenceTransitionValue in imageSequence.transitions)
      {
         [candidateSequences setObject:[NSNumber numberWithInt:i] forKey:sequenceTransitionValue];
      }
   }
   
   // now, try and find a match
   for (NSValue* sequenceTransitionValue in [candidateSequences allKeys])
   {
      SequenceTransition candidateTransition;
      
      [sequenceTransitionValue getValue:&candidateTransition];
      
      if (candidateTransition.sequence == self.lastCompletedSequence.sequence &&
          candidateTransition.frame == self.lastCompletedSequence.frame)
      {
         // match found
         self.sequenceInPlay = [(NSNumber*)[candidateSequences objectForKey:sequenceTransitionValue] intValue];
         //[self.layer resetImageIndices];
         
         result = YES;
                  
         break;
      }
   }   
   
   return result;
}

-(AImageSequence*)currentSequence
{
   AImageSequence* result = nil;
   
   @try 
   {
      result = (AImageSequence*)[self.imageSequences objectAtIndex:self.sequenceInPlay];
   }
   @catch (NSException* e) 
   {
      // do nothing
   }
   
   return result;
}

-(NSDictionary*)currentImageSpec
{
   return [self ImageSpecForImageIndex:self.layer.currentImageIndex];
}

#pragma mark ACustomAnimation protocol

-(void)TriggerBase
{
   [self Start:YES];
}

-(void)Trigger
{
   [self Start:YES];
}

-(void)ApplyEffects:(NSArray*)effectsToApply :(BOOL)pre
{   
   // load the queue
   for (NSDictionary* effectSpec in effectsToApply)
   {
      //DLog(@"animating property: %@ (from: %@, to: %@)", effectSpec.property, effectSpec.fromValue, effectSpec.toValue);
      
      CAAnimation* animation = [self AnimationFromSpec:effectSpec];
      
      [animation setValue:[NSString stringWithFormat:@"%@_%@", pre?@"preEffect":@"postEffect", effectSpec.property] forKey:@"animationKey"];
      
      [self.effectQueue enqueue:animation];
   }
   
   // start the ball rolling
   CABasicAnimation* effect = (CABasicAnimation*)[self.effectQueue dequeue];
   effect.delegate = self;
   
   [CATransaction begin];
   
   NSString* propertyToAnimate = (NSString*)[effect valueForKey:@"property"];
   
   [self.layer setValue:effect.toValue forKey:propertyToAnimate];
   [self.layer addAnimation:effect forKey:propertyToAnimate];
   
   [CATransaction commit];
   
   effect.delegate = nil;
}

-(void)ApplyEffect:(NSDictionary*)effectSpec :(BOOL)pre
{
   DLog(@"animating property: %@ (from: %@, to: %@)", effectSpec.property, effectSpec.fromValue, effectSpec.toValue);
   
   CAAnimation* animation = [self AnimationFromSpec:effectSpec];
   
   [animation setValue:[NSString stringWithFormat:@"%@_%@", pre?@"preEffect":@"postEffect", effectSpec.property] forKey:@"animationKey"];
      
   DLog(@"processing effect: %@", effectSpec.propertyId);
   
   // actually apply the effect
   animation.delegate = self;
   
   [CATransaction begin];
   
   [self.layer setValue:effectSpec.toValue forKey:effectSpec.property];
   [self.layer addAnimation:animation forKey:effectSpec.property];
   
   [CATransaction commit];
   
   animation.delegate = nil;
}

-(CAAnimation*)AnimationFromSpec:(NSDictionary*)effectSpec
{
   CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:effectSpec.property];
   [animation setValue:effectSpec.property forKey:@"property"];
   animation.fromValue = effectSpec.fromValue;
   animation.toValue = effectSpec.toValue;
   animation.duration = effectSpec.duration;
   
   return animation;
}

-(NSDictionary*)ImageSpecForImageIndex:(unsigned int)imageIndex
{
   NSString* imageSpecKey = [NSString stringWithFormat:@"%@%04d.png", self.resourceBase, imageIndex];
   
  return [[self.textureAtlas objectForKey:@"frames"] objectForKey:imageSpecKey];
}

// Based on the index of the image to be displayed, answer the appropriate
// bounds for that image as extracted from the texture atlas.
//
// Note that in the case where the image in the sprite sheet has been trimmed
// with respect to its original dimensions and position, its bounds have to be adjusted
// so that it's ultimately positioned properly. The following code is what's used
// by Zwoptext to determine the various elements included in what we call the
// 'imageSpec':
//
// NSSize spriteSize = NSZeroSize;
// NSRect textureRect = NSZeroRect;
// NSPoint spriteOffset = NSZeroPoint;
// NSRect spriteSourceColorRect = sprite.sourceColorRect;
// NSSize spriteSourceSize = sprite.sourceSize;
// BOOL spriteIsTrimmed = sprite.isTrimmed;
// BOOL textureIsRotated = sprite.isRotated;
//
// // set textureRect
// textureRect.origin = sprite.position;
// textureRect.size = sprite.size;
//
// // set spriteSize & spriteOffset
// spriteSize = (spriteIsTrimmed) ? spriteSourceColorRect.size : spriteSourceSize;
// if(spriteIsTrimmed) {
// 	NSLog(@"spriteIsTrimmed: %i",spriteIsTrimmed);
// 	spriteOffset.x = ((spriteSourceColorRect.origin.x + spriteSourceColorRect.size.width * 0.5) - (spriteSourceSize.width * 0.5));
// 	spriteOffset.y = -((spriteSourceColorRect.origin.y + spriteSourceColorRect.size.height * 0.5) - (spriteSourceSize.height * 0.5));
// }

-(CGRect)BoundsForImageAtIndex:(unsigned int)imageIndex
{
   CGRect result = CGRectZero;
   
   if (0 == imageIndex)
   {
      return result;
   }
   
   NSDictionary* imageSpec = [self ImageSpecForImageIndex:imageIndex];
   
   BOOL isTrimmed = [(NSNumber*)[imageSpec objectForKey:@"spriteTrimmed"] boolValue];
   
   if (isTrimmed)
   {
      // adjust the bounds of the image to be displayed
      CGRect spriteColorRect = CGRectFromString([imageSpec objectForKey:@"spriteColorRect"]);
      CGPoint spriteOffset = CGPointFromString([imageSpec objectForKey:@"spriteOffset"]);
            
      result.origin.x = spriteColorRect.origin.x - spriteOffset.x;
      result.origin.y = spriteColorRect.origin.y + spriteOffset.y; 
      result.size.width = spriteColorRect.size.width;
      result.size.height = spriteColorRect.size.height;
      
      DLog(@"trimmed origin = %f, %f", result.origin.x, result.origin.y);
   }
   else
   {
      result.size = CGSizeFromString([imageSpec objectForKey:@"spriteSize"]);      
   }
      
   return result;
}

-(CGPoint)PositionForImageAtIndex:(unsigned int)imageIndex
{
   CGPoint result = CGPointZero;
   
   if (0 == imageIndex)
   {
      return result;
   }
   
   NSDictionary* imageSpec = [self ImageSpecForImageIndex:imageIndex];
   
   BOOL isTrimmed = [(NSNumber*)[imageSpec objectForKey:@"spriteTrimmed"] boolValue];
   
   // if the sprite we're referencing is 'untrimmed', then the position for the
   // image is simply the geometric center of the image in the containing view's
   // coordinate system
   CGRect layerFrame = self.layer.frame;
         
   if (isTrimmed)
   {
      CGRect baseFrame = self.baseFrame;
            
      // however, if the sprite is trimmed then its position coordinate needs
      // to be adjusted so that it appears in the same position it did before
      // the trimming operation took place
      CGPoint spriteOffset = CGPointFromString([imageSpec objectForKey:@"spriteOffset"]);
      CGRect spriteColorRect = CGRectFromString([imageSpec objectForKey:@"spriteColorRect"]);
      CGSize spriteSize = CGSizeFromString([imageSpec objectForKey:@"spriteSize"]);
      
      result.x = baseFrame.origin.x + spriteOffset.x;
      result.y = baseFrame.origin.y + spriteSize.height/2 + spriteOffset.y;
      
      //DLog(@"trimmed position: %f, %f", result.x, result.y);

      
//      layerFrame.origin.x = baseFrame.origin.x + spriteColorRect.origin.x;
//      layerFrame.origin.y = baseFrame.origin.y + spriteColorRect.origin.y;
      layerFrame.size.width = spriteColorRect.size.width;
      layerFrame.size.height = spriteColorRect.size.height;
      
      self.layer.frame = layerFrame;
            
      //DLog(@"layerFrame = %f, %f, %f, %f", layerFrame.origin.x, layerFrame.origin.y, layerFrame.size.width, layerFrame.size.height);
   }
   else 
   {
      // CGRect layerFrame = self.baseFrame;
      CGSize spriteSourceSize = CGSizeFromString([imageSpec objectForKey:@"spriteSourceSize"]);
      
      result.x = layerFrame.origin.x + spriteSourceSize.width/2.0f;
      result.y = layerFrame.origin.y + spriteSourceSize.height/2.0f;
   }

   return result;
}

// Based on the index of the image to be displayed, answer the appropriate
// contentsRect for that image as extracted from the texture atlas. Note that the
// contentsRect is displayed in the unit coordinate space!
-(CGRect)ContentsRectForImageAtIndex:(unsigned int)imageIndex
{
   CGRect result = CGRectZero;
   
   if (0 == imageIndex)
   {
      return result;
   }
   
   NSDictionary* imageSpec = [self ImageSpecForImageIndex:imageIndex];
   
   CGSize imageSize = CGSizeFromString([imageSpec objectForKey:@"spriteSize"]);
   CGSize textureSize = CGSizeFromString([[self.textureAtlas objectForKey:@"metadata"] objectForKey:@"size"]);
   CGRect textureRect = CGRectFromString([imageSpec objectForKey:@"textureRect"]);
   
   result = CGRectMake(textureRect.origin.x/textureSize.width, textureRect.origin.y/textureSize.height, imageSize.width/textureSize.width, imageSize.height/textureSize.height);

   return result;
}

-(void)ArrangeImageAtIndex:(unsigned int)imageIndex OnLayer:(CALayer*)imageLayer;
{
   if (0 == imageIndex)
   {
      return;
   }
   
   NSDictionary* imageSpec = [self ImageSpecForImageIndex:imageIndex];
   
   BOOL isTrimmed = [(NSNumber*)[imageSpec objectForKey:@"spriteTrimmed"] boolValue];
   
   if (!isTrimmed)
   {
      imageLayer.contentsRect = [self ContentsRectForImageAtIndex:imageIndex];
      imageLayer.position = [self PositionForImageAtIndex:imageIndex];
      
      return;
   }

   CGRect baseFrame = self.baseFrame;
   
   // however, if the sprite is trimmed then its position coordinate needs
   // to be adjusted so that it appears in the same position it did before
   // the trimming operation took place
   CGPoint spriteOffset = CGPointFromString([imageSpec objectForKey:@"spriteOffset"]);
   CGRect spriteColorRect = CGRectFromString([imageSpec objectForKey:@"spriteColorRect"]);
   
   CGPoint position = CGPointZero;
   
   position.x = baseFrame.origin.x + spriteOffset.x;
   position.y = baseFrame.origin.y + spriteOffset.y;
   
   CGRect layerFrame = CGRectZero;
   
   layerFrame.origin.x = baseFrame.origin.x + spriteColorRect.origin.x;
   layerFrame.origin.y = baseFrame.origin.y + spriteColorRect.origin.y;
   layerFrame.size.width = spriteColorRect.size.width;
   layerFrame.size.height = spriteColorRect.size.height;
   
   // disable animation of the properties we're about to set...
//   [CATransaction begin];
//   
//   [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
   
   imageLayer.frame = layerFrame;
   imageLayer.position = position;
   
//   [CATransaction commit];
}

-(NSString*)animationId
{
   return self.sequenceId;
}

#pragma mark -
#pragma mark CAAnimation delegate protocol
-(void)animationDidStop:(CABasicAnimation*)anim finished:(BOOL)animationFinished
{
   //DLog(@"anim.toValue = %@, anim.keyPath = %@", anim.toValue, anim.keyPath);
   
   //[self.layer setValue:anim.toValue forKey:anim.keyPath];
   
   //DLog(@"animation completing: %@", [anim valueForKey:@"animationKey"]);
   
   if (animationFinished)
   {
      NSString* animationKey = [anim valueForKey:@"animationKey"];
      
      [self.layer removeAnimationForKey:animationKey];
      
      if ([animationKey hasPrefix:@"sequence"])
      {
         // a sequence has just completed - determine if there are any 'postEffects'
         // to be applied to the layer. If not, determine the next sequence to be
         // executed and then transition to it
         SequenceTransition st;
         st.sequence = self.sequenceInPlay;
         st.frame = [((NSNumber*)anim.toValue) intValue];
         
         self.lastCompletedSequence = st;
         
         // are there any post-sequence Notifications to issue?
         AImageSequence* justCompletedSequence = [self.imageSequences objectAtIndex:self.sequenceInPlay];
         
         if (justCompletedSequence.hasPostExecutionNotification)
         {
            [justCompletedSequence IssuePostExecutionNotification];
         }
         
         // are there any post-animation effects to apply?
         NSArray* propertyEffects = self.currentSequence.postSequencePropertyEffects;
         
         if (nil != propertyEffects && 0 < [propertyEffects count])
         {
            [self ApplyPostSequenceEffects:self.currentSequence.sequenceIndex];
         }
         else 
         {
            NSUInteger sequenceIndex = self.currentSequence.sequenceIndex;
            
            if ((sequenceIndex == [self.imageSequences count]-1) && self.autoResetToBase)
            {
               [self ResetToBaseSequence];
               [self TransitionSequence];
            }
            else if (0 != sequenceIndex && !self.stepTriggerRequired)
            {
               // transition to the next sequence
               if (YES == [self CalculateNextSequence])
               {
                  [self TransitionSequence];
               }
               else 
               {
                  [self ResetToBaseSequence];
               }
            }
            else 
            {
               // is there a delay between executions of the base sequence?
               AImageSequence* baseSequence = [self.imageSequences objectAtIndex:0];
               
               if (baseSequence.isFiniteRepeat || baseSequence.isContinuousRepeat)
               {
                  // Not Implemented Yet (or implemented elsewhere)
                  return;
               }
               
               CGFloat delayInterval = 0.0f;
               
               if (baseSequence.isContinuousWithDelayRepeat)
               {
                  delayInterval = baseSequence.repeatDelay;
               }
               else if (baseSequence.isContinuousWithRandomDelayRepeat)
               {
                  delayInterval = ((baseSequence.repeatDelayMax-baseSequence.repeatDelayMin)*(float)arc4random()/ARC4RANDOM_MAX)+baseSequence.repeatDelayMin;
               }
               
               [NSTimer scheduledTimerWithTimeInterval:delayInterval
                                                target:self
                                              selector:@selector(RepeatSequence:)
                                              userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:0] 
                                                                                   forKey:@"sequenceIndex"]
                                               repeats:NO];
            }
         }
      }
      else if ([animationKey hasPrefix:@"postEffect"])
      {         
         CABasicAnimation* nextAnimation = (CABasicAnimation*)[self.effectQueue dequeue];
         
         // are there any more effects queued?
         if (nil != nextAnimation)
         {
            //DLog(@"next animation will change %@ from %f to %f", nextAnimation.keyPath, [nextAnimation.fromValue floatValue], [nextAnimation.toValue floatValue]);
            
            // execute the next effect animation in the sequence
            nextAnimation.delegate = self;
            [self.layer addAnimation:nextAnimation forKey:[nextAnimation valueForKey:@"animationKey"]];
            nextAnimation.delegate = nil;
         }         
         else 
         {
            if (!self.currentSequence.isBaseSequence)
            {
               // transition to the next sequence
               [self CalculateNextSequence];
               [self TransitionSequence];
            }
         }
      }
      else if ([animationKey hasPrefix:@"preEffect"])
      {
         // the 'preEffect' for the current sequenceInPlay has completed - time
         // to execute the sequence itself
         [self AnimateSequence:self.sequenceInPlay];
      }
   }
}


#pragma mark -
#pragma mark AImageSequenceLayer delegate
// AImageSequenceLayer needs this method for variable image sizes to work
- (void)displayLayer:(CALayer*)layer
{   
   AImageSequenceLayer* imageLayer = (AImageSequenceLayer*)layer;
      
   unsigned int imageIndex = imageLayer.currentImageIndex;
      
   if (0 == imageIndex)
   {
      return;
   }
      
   //imageLayer.bounds = [self BoundsForImageAtIndex:imageIndex];
   imageLayer.contentsRect = [self ContentsRectForImageAtIndex:imageIndex];
   imageLayer.position = [self PositionForImageAtIndex:imageIndex];
//   [self ArrangeImageAtIndex:imageIndex OnLayer:imageLayer];

   
   // update the lastCompletedSequence info that supports transitions
   SequenceTransition st;
   st.sequence = self.sequenceInPlay;
   st.frame = imageIndex;
   
   self.lastCompletedSequence = st;
   
   //DLog(@"frame just displayed (%@): %d, %d", self.sequenceId, st.sequence, st.frame);
   
//   DLog(@"Displaying texture %d, bounds: %f, %f, %f, %f contentsRect: %f, %f, %f, %f", 
//        imageIndex,
//        imageLayer.bounds.origin.x, imageLayer.bounds.origin.y, imageLayer.bounds.size.width, imageLayer.bounds.size.height,
//        imageLayer.contentsRect.origin.x, imageLayer.contentsRect.origin.y, imageLayer.contentsRect.size.width, imageLayer.contentsRect.size.height);
   
}

@end
