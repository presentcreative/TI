// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "CreditsPage.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "TextureAtlasBasedSequence.h"
#import "OrderedDictionary.h"
#import "NSTimer+Blocks.h"
#import "Constants.h"
#import "AmbientSound.h"
#import "StaticImage.h"
#import "BookView.h"
#import "NSMutableArray+Queue.h"


#define kScrollViewTag        101
#define kImageViewTag         102
#define kSkipIntroButtonTag   103
#define kBeginBookButtonTag   104

#define kScrollStep                0.01f
#define kTopLayerMidpoint        731.5f

#define kChimneySmokeAnimation   @"chimneySmokeAnimation"

@interface ACreditsPage (Private)
-(void)SwitchSkipIntroForBegin;
-(void)SwitchBeginForSkipIntro;

-(CAKeyframeAnimation*)AnimationOfLayer:(CALayer*)layer 
                               OverPath:(NSArray*)pathPoints 
                            ForDuration:(CGFloat)duration 
                         WithIdentifier:(NSString*)identifier;

-(CAKeyframeAnimation*)RotationAnimationForLayer:(CALayer*)layer 
                                       WithSpecs:(NSArray*)rotationByFrameSpecs 
                                     ForDuration:(CGFloat)duration 
                                  WithIdentifier:(NSString*)identifier;
-(void)ResetLayers;
@end


@implementation ACreditsPage

@synthesize scrollDuration=fScrollDuration;
@synthesize scrollStart=fScrollStart;
@synthesize maxScrollX=fMaxScrollX;
@synthesize creditAnimationDuration=fCreditAnimationDuration;
@synthesize creditSpecsByTimeOffset=fCreditSpecsByTimeOffset;
@synthesize creditDisplayIndex=fCreditDisplayIndex;
@synthesize scrollTimer=fScrollTimer;
@synthesize creditDisplayTimer=fCreditDisplayTimer;
@synthesize turnTimer=fTurnTimer;
@synthesize sequenceStart=fSequenceStart;
@synthesize turnSpecs=fTurnSpecs;
@synthesize creditsSound=fCreditsSound;

@synthesize bottomImageLayer=fBottomImageLayer;
@synthesize topImageLayer=fTopImageLayer;

@synthesize topImageLayerAnimationFired=fTopImageLayerAnimationFired;

@synthesize blackDog1Layer=fBlackDog1Layer;
@synthesize blackDog1LayerFrame=fBlackDog1LayerFrame;
@synthesize blackDog1LayerPathPoints=fBlackDog1LayerPathPoints;
@synthesize blackDog1LayerAnimationDuration=fBlackDog1LayerAnimationDuration;

@synthesize porter1Layer=fPorter1Layer;
@synthesize porter1LayerPathPoints=fPorter1LayerPathPoints;
@synthesize porter1LayerAnimationDuration=fPorter1LayerAnimationDuration;

@synthesize blackDog2Layer=fBlackDog2Layer;
@synthesize blackDog2LayerPathPoints=fBlackDog2LayerPathPoints;
@synthesize blackDog2LayerAnimationDuration=fBlackDog2LayerAnimationDuration;

@synthesize porter2Layer=fPorter2Layer;
@synthesize porter2LayerPathPoints=fPorter2LayerPathPoints;
@synthesize porter2LayerAnimationDuration=fPorter2LayerAnimationDuration;

@synthesize blackDogAndPorter1Layer=fBlackDogAndPorter1Layer;
@synthesize blackDogAndPorter1LayerPathPoints=fBlackDogAndPorter1LayerPathPoints;
@synthesize blackDogAndPorter1LayerAnimationDuration=fBlackDogAndPorter1LayerAnimationDuration;

@synthesize blackDogAndPorter2Layer=fBlackDogAndPorter2Layer;
@synthesize blackDogAndPorter2LayerPathPoints=fBlackDogAndPorter2LayerPathPoints;
@synthesize blackDogAndPorter2LayerAnimationDuration=fBlackDogAndPorter2LayerAnimationDuration;

@synthesize tree1Layer=fTree1Layer;
@synthesize trees2Layer=fTrees2Layer;

-(void)dealloc
{
   [fTurnTimer invalidate];
   Release(fTurnTimer);
   Release(fTurnSpecs);
   Release(fSequenceStart);
   
   Release(fScrollStart);
   Release(fCreditSpecsByTimeOffset);
   Release(fScrollTimer);
   Release(fCreditDisplayTimer);
   Release(fCreditsSound);
   
   self.bottomImageLayer.delegate = nil;
   if (self.bottomImageLayer.superlayer)
   {
      [self.bottomImageLayer removeFromSuperlayer];
   }
   Release(fBottomImageLayer);
   
   self.topImageLayer.delegate = nil;
   if (self.topImageLayer.superlayer)
   {
      [self.topImageLayer removeFromSuperlayer];
   }
   Release(fTopImageLayer);
   
   self.blackDog1Layer.delegate = nil;
   if (self.blackDog1Layer.superlayer)
   {
      [self.blackDog1Layer removeFromSuperlayer];
   }
   Release(fBlackDog1Layer);
   Release(fBlackDog1LayerPathPoints);
   
   self.porter1Layer.delegate = nil;
   if (self.porter1Layer.superlayer)
   {
      [self.porter1Layer removeFromSuperlayer];
   }
   Release(fPorter1Layer);
   Release(fPorter1LayerPathPoints);
   
   self.blackDog2Layer.delegate = nil;
   if (self.blackDog2Layer.superlayer)
   {
      [self.blackDog2Layer removeFromSuperlayer];
   }
   Release(fBlackDog2Layer);
   Release(fBlackDog2LayerPathPoints);
   
   self.porter2Layer.delegate = nil;
   if (self.porter2Layer.superlayer)
   {
      [self.porter2Layer removeFromSuperlayer];
   }
   Release(fPorter2Layer);
   Release(fPorter2LayerPathPoints);
   
   self.blackDogAndPorter1Layer.delegate = nil;
   if (self.blackDogAndPorter1Layer.superlayer)
   {
      [self.blackDogAndPorter1Layer removeFromSuperlayer];
   }
   Release(fBlackDogAndPorter1Layer);
   Release(fBlackDogAndPorter1LayerPathPoints);
   
   self.blackDogAndPorter2Layer.delegate = nil;
   if (self.blackDogAndPorter2Layer.superlayer)
   {
      [self.blackDogAndPorter2Layer removeFromSuperlayer];
   }
   Release(fBlackDogAndPorter2Layer);
   Release(fBlackDogAndPorter2LayerPathPoints);
   
   self.tree1Layer.delegate = nil;
   if (self.tree1Layer.superlayer)
   {
      [self.tree1Layer removeFromSuperlayer];
   }
   Release(fTree1Layer);
   
   self.trees2Layer.delegate = nil;
   if (self.trees2Layer.superlayer)
   {
      [self.trees2Layer removeFromSuperlayer];
   }
   Release(fTrees2Layer);
   
   [super dealloc];
}

-(void)BaseInit
{
   [super BaseInit];
   
   self.scrollDuration = 0.0f;
   self.maxScrollX = 0.0f;
   self.creditAnimationDuration = 0.0f;
   self.creditDisplayIndex = 0;
   
   self.topImageLayerAnimationFired = NO;
   
   self.blackDog1LayerPathPoints = [NSArray array];
   self.blackDog1LayerAnimationDuration = 0.0f;
   
   self.porter1LayerPathPoints = [NSArray array];
   self.porter1LayerAnimationDuration = 0.0f;
   
   self.blackDog2LayerPathPoints = [NSArray array];
   self.blackDog2LayerAnimationDuration = 0.0f;
   
   self.porter2LayerPathPoints = [NSArray array];
   self.porter2LayerAnimationDuration = 0.0f;
      
   self.blackDogAndPorter1LayerPathPoints = [NSArray array];
   self.blackDogAndPorter1LayerAnimationDuration = 0.0f;
   
   self.blackDogAndPorter2LayerPathPoints = [NSArray array];
   self.blackDogAndPorter2LayerAnimationDuration = 0.0f;
   
   OrderedDictionary* od = [[OrderedDictionary alloc] init];
   self.creditSpecsByTimeOffset = od;
   [od release];
   
   self.turnTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(DisplayLinkDidTick:)];
   [self.turnTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
   self.turnTimer.paused = YES;
   
   fTurnSpecs = [[NSMutableArray alloc] initWithCapacity:16];
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
   
   NSDictionary* layerSpec = nil;
   NSString* imagePath = nil;

   self.scrollDuration = element.scrollDuration;
   self.maxScrollX = element.maxX;
   self.creditAnimationDuration = element.animationDuration;
   
   CGRect frame = element.frame;
   
   UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:element.bounds];
   scrollView.tag = kScrollViewTag;
   scrollView.contentSize = frame.size;
   scrollView.scrollEnabled = NO;
   
   [view addSubview:scrollView];
   [scrollView release];
   
   // now, set the images over which the scrollView will scroll
   imagePath = [[NSBundle mainBundle] pathForResource:element.bottomImageResource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", element.bottomImageResource);
      
      return;
   }
   
   CALayer* aLayer = nil;
   UIImage* image = nil;
   
   aLayer = [[CALayer alloc] init];
   self.bottomImageLayer = aLayer;
   [aLayer release];
   
   self.bottomImageLayer.zPosition = 0;
   self.bottomImageLayer.frame = CGRectMake(725.0f, 0, 1234.0f, 748.0f);
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.bottomImageLayer setContents:(id)image.CGImage];
   [image release];
   
   imagePath = [[NSBundle mainBundle] pathForResource:element.topImageResource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"Image file missing: %@", element.topImageResource);
      
      return;
   }
   
   aLayer = [[CALayer alloc] init];
   self.topImageLayer = aLayer;
   [aLayer release];
   
   self.topImageLayer.frame = CGRectMake(0.0f, 0.0f, 1463.0f, 748.0f);
   self.topImageLayer.zPosition = 10;
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [self.topImageLayer setContents:(id)image.CGImage];
   [image release];
   
   // the images overwhich panning occurs will exist on their own view
   UIView* imageView = [[UIView alloc] initWithFrame:element.frame];
   imageView.tag = kImageViewTag;
   
   [self.scrollView addSubview:imageView];
   [imageView release];
   
   [self.imageView.layer addSublayer:self.bottomImageLayer];
   [self.imageView.layer addSublayer:self.topImageLayer];
   

   // The credits themselves
   layerSpec = element.creditsLayer;
   
   CALayer* creditsLayer = [[CALayer alloc] init];
   creditsLayer.frame = layerSpec.frame;
      
   NSUInteger creditSpecIndex = 0;
   
   for (NSDictionary* creditSpec in layerSpec.creditSpecs)
   {     
      CALayer* creditSpecLayer = [[CALayer alloc] init];
      
      creditSpecLayer.frame = creditSpec.frame;
      creditSpecLayer.opacity = 0.0f;
      
      imagePath = [[NSBundle mainBundle] pathForResource:creditSpec.resource ofType:nil];
   
      if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
      {
         ALog(@"image file missing: %@", imagePath);
         
         [creditSpecLayer release];
         [creditsLayer release];
                  
         return;
      }
   
      image = [[UIImage alloc] initWithContentsOfFile:imagePath];
      [creditSpecLayer setContents:(id)image.CGImage];
      [image release];
      
      // keep a reference to the layer by its timeOffset
      NSNumber* timeOffset = [NSNumber numberWithFloat:creditSpec.timeOffset];
      
      // build the simple data holder
      ACreditDisplaySpec* creditDisplaySpec = [[ACreditDisplaySpec alloc] init];
      creditDisplaySpec.displayDuration = creditSpec.displayDuration;
      creditDisplaySpec.creditLayer = creditSpecLayer;
      
      [self.creditSpecsByTimeOffset insertObject:creditDisplaySpec forKey:timeOffset atIndex:creditSpecIndex++];      
      [creditDisplaySpec release];
      
      [creditsLayer addSublayer:creditSpecLayer]; 
      [creditSpecLayer release];
   }
   
   // Add any sub-animations that may have been specified
   ATextureAtlasBasedSequence* tSequence = nil;
   
   ////////////////////////////////////////////////////////////////////////////////
   // smoke from the chimney at the Admiral Benbow
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:element.chimneySmokeLayer 
                RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:kChimneySmokeAnimation];
   [self.imageView.layer addSublayer:tSequence.layer];
   [tSequence release]; 
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // Black Dog walking down the path to the Admiral Benbow (1)
   layerSpec = element.blackDog1Layer;
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:layerSpec 
                RenderOnView:nil];
   
   self.blackDog1LayerFrame = layerSpec.frame;
   [self.animationsByName setObject:tSequence forKey:@"blackDog1Layer"];
   self.blackDog1Layer = tSequence.layer;
   self.blackDog1Layer.zPosition = 15;
   [self.imageView.layer addSublayer:self.blackDog1Layer];
   [tSequence release];  
   
   self.blackDog1LayerPathPoints = layerSpec.pathPoints;
   self.blackDog1LayerAnimationDuration = layerSpec.duration;
   
   ////////////////////////////////////////////////////////////////////////////////
   // The Porter walking down the path to the Admiral Benbow (1)
   layerSpec = element.porter1Layer;
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:layerSpec 
                RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:@"porter1Layer"];
   self.porter1Layer = tSequence.layer;
   self.porter1Layer.zPosition = 15;
   [self.imageView.layer addSublayer:self.porter1Layer];
   [tSequence release];  
   
   self.porter1LayerPathPoints = layerSpec.pathPoints;
   self.porter1LayerAnimationDuration = layerSpec.duration;
   

   ////////////////////////////////////////////////////////////////////////////////
   // Black Dog walking down the path to the Admiral Benbow (2)
   layerSpec = element.blackDog2Layer;
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:layerSpec 
                RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:@"blackDog2Layer"];
   self.blackDog2Layer = tSequence.layer;
   self.blackDog2Layer.zPosition = 5;
   [self.imageView.layer addSublayer:self.blackDog2Layer];
   [tSequence release];  
   
   self.blackDog2LayerPathPoints = layerSpec.pathPoints;
   self.blackDog2LayerAnimationDuration = layerSpec.duration;
   
   ////////////////////////////////////////////////////////////////////////////////
   // The Porter walking down the path to the Admiral Benbow (2)
   layerSpec = element.porter2Layer;
   
   tSequence = (ATextureAtlasBasedSequence*)[[ATextureAtlasBasedSequence alloc] 
                initWithElement:layerSpec 
                RenderOnView:nil];
   
   [self.animationsByName setObject:tSequence forKey:@"porter2Layer"];
   self.porter2Layer = tSequence.layer;
   self.porter2Layer.zPosition = 5;
   [self.imageView.layer addSublayer:self.porter2Layer];
   [tSequence release];  
   
   self.porter2LayerPathPoints = layerSpec.pathPoints;
   self.porter2LayerAnimationDuration = layerSpec.duration;
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // Black Dog and the Porter walking down the path to the Admiral Benbow (combined image) (1)
   layerSpec = element.blackDogAndPorter1Layer;
   
   AStaticImage* staticImage = (AStaticImage*)[[AStaticImage alloc] 
                                initWithElement:layerSpec 
                                RenderOnView:nil];
   
   [self.animations addObject:staticImage];
   self.blackDogAndPorter1Layer = staticImage.layer;
   self.blackDogAndPorter1Layer.zPosition = 2;
   self.blackDogAndPorter1Layer.opacity = 0.0f;
   [self.imageView.layer addSublayer:self.blackDogAndPorter1Layer];
   [staticImage release];  
   
   self.blackDogAndPorter1LayerPathPoints = layerSpec.pathPoints;
   self.blackDogAndPorter1LayerAnimationDuration = layerSpec.duration;
   
   
   ////////////////////////////////////////////////////////////////////////////////
   // Black Dog and the Porter walking down the path to the Admiral Benbow (combined image) (2)
   layerSpec = element.blackDogAndPorter2Layer;
   
   staticImage = (AStaticImage*)[[AStaticImage alloc] 
                  initWithElement:layerSpec 
                  RenderOnView:nil];
   
   [self.animations addObject:staticImage];
   self.blackDogAndPorter2Layer = staticImage.layer;
   self.blackDogAndPorter2Layer.zPosition = 2;
   self.blackDogAndPorter2Layer.opacity = 0.0f;
   [self.imageView.layer addSublayer:self.blackDogAndPorter2Layer];
   [staticImage release];  
   
   self.blackDogAndPorter2LayerPathPoints = layerSpec.pathPoints;
   self.blackDogAndPorter2LayerAnimationDuration = layerSpec.duration;
   
   // add the first tree that Black Dog and the Porter travel behind
   layerSpec = element.tree1Layer;
   
   staticImage = (AStaticImage*)[[AStaticImage alloc] 
                  initWithElement:layerSpec 
                  RenderOnView:nil];
   
   [self.animations addObject:staticImage];
   self.tree1Layer = staticImage.layer;
   self.tree1Layer.zPosition = 3;
   self.tree1Layer.hidden = YES;
   [self.imageView.layer addSublayer:self.tree1Layer];
   [staticImage release];   
   
   
   // add the second set of trees that Black Dog and the Porter travel behind
   layerSpec = element.trees2Layer;
   
   staticImage = (AStaticImage*)[[AStaticImage alloc] 
                  initWithElement:layerSpec 
                  RenderOnView:nil];
   
   [self.animations addObject:staticImage];
   self.trees2Layer = staticImage.layer;
   self.trees2Layer.zPosition = 3;
   self.trees2Layer.hidden = YES;
   [self.imageView.layer addSublayer:self.trees2Layer];
   [staticImage release]; 
   
   
   // Add the "Skip Intro" button/image
   layerSpec = element.skipIntroButton;
   
   UIButton* skipIntroButton = [UIButton buttonWithType:UIButtonTypeCustom];
   skipIntroButton.frame = layerSpec.frame;
   skipIntroButton.tag = kSkipIntroButtonTag;
   [skipIntroButton addTarget:self action:@selector(SkipIntro) forControlEvents:UIControlEventTouchUpInside];
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", layerSpec.resource);
      
      [creditsLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [skipIntroButton setImage:image forState:UIControlStateNormal];
   [image release];
   [view addSubview:skipIntroButton];
   
   // Add the "Begin" button/image (initially hidden)
   layerSpec = element.beginBookButton;
   
   UIButton* beginBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
   beginBookButton.frame = layerSpec.frame;
   beginBookButton.tag = kBeginBookButtonTag;
   beginBookButton.alpha = 0.0f;
   [beginBookButton addTarget:self action:@selector(SkipIntro) forControlEvents:UIControlEventTouchUpInside];
   
   imagePath = [[NSBundle mainBundle] pathForResource:layerSpec.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", layerSpec.resource);
      
      [creditsLayer release];
      
      return;
   }
   
   image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [beginBookButton setImage:image forState:UIControlStateNormal];
   [image release];
   [view addSubview:beginBookButton];
   
   // the credits layer floats above all the others         
   [view.layer addSublayer:creditsLayer];
   [creditsLayer release];
   
   // assume there's a sound effect...
   layerSpec = element.soundEffect;
   
   AAmbientSound* soundEffect = (AAmbientSound*)[[AAmbientSound alloc] initWithElement:layerSpec RenderOnView:view];
   self.creditsSound = soundEffect;
   [soundEffect release];
   
   // load the turn specs
   for (NSDictionary* turnSpecDictionary in element.turnSpecs)
   {
      ATurnSpec* turnSpec = [[ATurnSpec alloc] initWithSpec:turnSpecDictionary];
      
      [self.turnSpecs addObject:turnSpec];
      
      [turnSpec release];
   }
}

-(UIScrollView*)scrollView
{
   return (UIScrollView*)[self.containerView viewWithTag:kScrollViewTag];
}

-(UIImageView*)imageView
{
   return (UIImageView*)[self.containerView viewWithTag:kImageViewTag];
}

-(UIButton*)skipIntroButton
{
   return (UIButton*)[self.containerView viewWithTag:kSkipIntroButtonTag];
}

-(UIButton*)beginBookButton
{
   return (UIButton*)[self.containerView viewWithTag:kBeginBookButtonTag];
}

-(void)Scroll:(NSTimer*)timer
{
   NSTimeInterval runningTime = -[self.scrollStart timeIntervalSinceNow];
      
   if (runningTime > self.scrollDuration)
   {
      // stop the scrolling
      [self.scrollView setContentOffset:CGPointMake(self.maxScrollX,0.0f) animated:YES];

      [self.scrollTimer invalidate];
      self.scrollTimer = nil;
      
      return;
   }
   
   // adjust the contentOffset of the scrollView to achieve a "panning" effect over the
   // underlying image
   CGPoint currentOffset = self.scrollView.contentOffset;
   CGFloat offsetDelta = self.maxScrollX * runningTime/self.scrollDuration;
   currentOffset.x = 0.0f + offsetDelta;
   [self.scrollView setContentOffset:currentOffset animated:YES];
   
   
   if (0.80f > runningTime/self.scrollDuration)
   {
      // as well, move the topImageLayer some fraction of the distance moved by the scrollView
      CGPoint currentTopImageLayerPosition = self.topImageLayer.position;
      currentTopImageLayerPosition.x = kTopLayerMidpoint + (100.0f * runningTime/self.scrollDuration);
      
      [CATransaction begin];
      [CATransaction setDisableActions:YES];
      
      self.topImageLayer.position = currentTopImageLayerPosition;
      
      [CATransaction commit];      
   }
   else 
   {
      if (!self.topImageLayerAnimationFired)
      {
         // start the position animation of the topImageLayer - the topImage layer moves to the right at
         // a slightly slower rate than the scrollView pans across the underlying image. After the topImageLayer
         // has moved "the appropriate distance" (determined experimentally...) it then reverses and returns to
         // its origin - this increases the "dramatic" impact in that it looks like an aerial camera is providing
         // the view of Black Dog and the Porter making their way towards the Admiral Benbow
         
         CGPoint currentTopImageLayerPosition = self.topImageLayer.position;
         CGPoint newTopImageLayerPosition = CGPointMake(kTopLayerMidpoint, currentTopImageLayerPosition.y);
         
         CABasicAnimation* theAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
         theAnimation.duration = 3.8f; // TODO: should parameterize this
         theAnimation.removedOnCompletion = YES;
         theAnimation.fillMode = kCAFillModeRemoved;
         theAnimation.fromValue = [NSValue valueWithCGPoint:currentTopImageLayerPosition];
         theAnimation.toValue = [NSValue valueWithCGPoint:newTopImageLayerPosition];
         [theAnimation setValue:@"TopImageLayerAnimation" forKey:@"animationId"];
         
         [CATransaction begin];
         
         self.topImageLayer.position = newTopImageLayerPosition;
         
         [self.topImageLayer addAnimation:theAnimation forKey:@"position"]; 
         
         [CATransaction commit];
         
         self.topImageLayerAnimationFired = YES;
      }
   }
}

-(void)DisplayCredit:(NSTimer*)creditDisplayTimer
{
   // Add the display animation to the credit layer specified by the current
   // value of the creditDisplayIndex
   ACreditDisplaySpec* creditDisplaySpec = (ACreditDisplaySpec*)[self.creditSpecsByTimeOffset 
                                                                 objectForKey:[self.creditSpecsByTimeOffset 
                                                                               keyAtIndex:self.creditDisplayIndex]];
      
   if (nil != creditDisplaySpec)
   { 
      CALayer* creditDisplayLayer = creditDisplaySpec.creditLayer;
      
      // reveal the credit and then set a timer that will hide the credit - a little
      // Rube Goldberg-ish but simpler than animating the opacity explicitly. Note that
      // 'creditAnimationDuration' refers to the time taken to transition the opacity
      // from 0.0 to 1.0. - this transition time is fixed for all credits (though the
      // actual displayDuration may vary)
      [CATransaction begin];
      [CATransaction setAnimationDuration:self.creditAnimationDuration];
      
      creditDisplayLayer.opacity = 1.0;
      
      [CATransaction commit];
      
      // schedule the timer that, upon firing, will re-hide the credit layer
      [NSTimer scheduledTimerWithTimeInterval:creditDisplaySpec.displayDuration block:^{
         
         [CATransaction begin];
         [CATransaction setAnimationDuration:self.creditAnimationDuration];
         
         creditDisplayLayer.opacity = 0.0;
         
         [CATransaction commit];
         
       } repeats:NO];
      
      // prepare for displaying the next credit
      self.creditDisplayIndex = self.creditDisplayIndex + 1;
      
      if (self.creditDisplayIndex < [self.creditSpecsByTimeOffset count])
      {
         CGFloat timeOffset = [(NSNumber*)[self.creditSpecsByTimeOffset keyAtIndex:self.creditDisplayIndex] floatValue];
                  
         [creditDisplayTimer setFireDate:[self.scrollStart dateByAddingTimeInterval:timeOffset]];         
      }
      else 
      {
         // credit display is done!
         [creditDisplayTimer invalidate];
         
         self.creditDisplayTimer = nil;
         
         [self SwitchSkipIntroForBegin];
      }
   }
}

-(void)SkipIntro
{
   // Issue a Notification telling the controller to skip the intro
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kNotificationSkipIntro object:nil];
   
   // TODO: verify that this works, here !!!
   self.creditsSound = nil;
}

-(void)SwitchSkipIntroForBegin
{
   self.skipIntroButton.alpha = 0.0f;
   self.beginBookButton.alpha = 1.0f;
}

-(void)SwitchBeginForSkipIntro
{
   self.beginBookButton.alpha = 0.0f;
   self.skipIntroButton.alpha = 1.0f;   
}

-(CAKeyframeAnimation*)AnimationOfLayer:(CALayer*)layer 
                               OverPath:(NSArray*)pathPoints 
                            ForDuration:(CGFloat)duration 
                         WithIdentifier:(NSString*)identifier
{
   CAKeyframeAnimation* pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
   [pathAnimation setValue:identifier forKey:@"animationId"];
   pathAnimation.delegate = self;
   pathAnimation.duration = duration;
   pathAnimation.calculationMode = kCAAnimationPaced;
   
   CGPoint initialPosition = layer.position;

   CGMutablePathRef layerPath = CGPathCreateMutable();
   CGPathMoveToPoint(layerPath, NULL, initialPosition.x, initialPosition.y);
   
   for (NSValue* pointValue in pathPoints)
   {
      CGPoint pathPoint = [pointValue CGPointValue];
      CGPathAddLineToPoint(layerPath, NULL, pathPoint.x, pathPoint.y);
   }

   pathAnimation.path = layerPath;
   CGPathRelease(layerPath);
      
   return pathAnimation;
}

-(CAKeyframeAnimation*)RotationAnimationForLayer:(CALayer*)layer WithSpecs:(NSArray*)rotationByFrameSpecs ForDuration:(CGFloat)duration WithIdentifier:(NSString*)identifier
{
   CAKeyframeAnimation* rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
   [rotationAnimation setValue:identifier forKey:@"animationId"];
   rotationAnimation.delegate = self;
   rotationAnimation.duration = duration;
   rotationAnimation.calculationMode = kCAAnimationPaced;
   
   NSMutableArray* transformValues = [NSMutableArray arrayWithCapacity:[rotationByFrameSpecs count]];
   
   for (NSNumber* angularDelta in rotationByFrameSpecs)
   {
      [transformValues addObject:[NSValue valueWithCATransform3D:CATransform3DRotate(layer.transform, DEGREES_TO_RADIANS([angularDelta floatValue]), 0.0f, 0.0f, 1.0f)]];
   }
   
   rotationAnimation.values = transformValues;
   
   return rotationAnimation;
}

-(CAKeyframeAnimation*)BlackDog1LayerRotationAnimation
{
   NSArray* angularDeltas = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:-30.0f],
                             [NSNumber numberWithFloat:-30.0f],
                             nil];
   
   return [self RotationAnimationForLayer:self.blackDog1Layer 
                                WithSpecs:angularDeltas 
                              ForDuration:self.blackDog1LayerAnimationDuration 
                           WithIdentifier:@"blackDog1Layer_rotation"];
}

-(CAKeyframeAnimation*)Porter1LayerRotationAnimation
{
   NSArray* angularDeltas = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:-30.0f],
                             nil];
   
   return [self RotationAnimationForLayer:self.porter1Layer 
                                WithSpecs:angularDeltas 
                              ForDuration:self.porter1LayerAnimationDuration 
                           WithIdentifier:@"porter1Layer_rotation"];
}

-(CAKeyframeAnimation*)Porter2LayerRotationAnimation
{
   NSArray* angularDeltas = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:-60.0f],
                             [NSNumber numberWithFloat:-60.0f],
                             nil];
   
   return [self RotationAnimationForLayer:self.porter2Layer 
                                WithSpecs:angularDeltas 
                              ForDuration:self.porter2LayerAnimationDuration 
                           WithIdentifier:@"porter2Layer_rotation"];
}

#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   [self Stop];
   
   [self.creditsSound Start:triggered];
   
   [(id<ACustomAnimation>)[self.animationsByName objectForKey:kChimneySmokeAnimation] Start:NO];
   
   // start the automatic scrolling across the "underlying" opening illustration
   self.scrollTimer = [NSTimer timerWithTimeInterval:kScrollStep
                                              target:self
                                            selector:@selector(Scroll:)
                                            userInfo:nil
                                             repeats:YES];
   self.scrollStart = [NSDate date];
   
   [[NSRunLoop currentRunLoop] addTimer:self.scrollTimer forMode:NSDefaultRunLoopMode];

   // start the timer that controls display of the actual credits
   self.creditDisplayIndex = 0;
   
   CGFloat initialTimeInterval = [(NSNumber*)[self.creditSpecsByTimeOffset keyAtIndex:self.creditDisplayIndex] floatValue];
   
   self.creditDisplayTimer = [NSTimer timerWithTimeInterval:initialTimeInterval
                                                     target:self
                                                   selector:@selector(DisplayCredit:)
                                                   userInfo:nil
                                                    repeats:YES];
   
   [[NSRunLoop currentRunLoop] addTimer:self.creditDisplayTimer forMode:NSDefaultRunLoopMode];
   
   CAKeyframeAnimation* theAnimation = nil;
   
   // add the animations of Black Dog and the Porter
   [CATransaction begin];
   
   [(id<ACustomAnimation>)[self.animationsByName objectForKey:@"blackDog1Layer"] Start:triggered];
      
   //self.blackDog1Layer.position = [(NSValue*)[self.blackDog1LayerPathPoints lastObject] CGPointValue];
   theAnimation = [self 
                   AnimationOfLayer:self.blackDog1Layer 
                   OverPath:self.blackDog1LayerPathPoints 
                   ForDuration:self.blackDog1LayerAnimationDuration
                   WithIdentifier:@"blackDog1"];
   
   CGPoint blackDog1LayerFinalPosition = [(NSValue*)[self.blackDog1LayerPathPoints lastObject] CGPointValue];
   
   // this should keep Black Dog from appearing at the top of the screen (just after exiting at the bottom)
   self.blackDog1Layer.position = blackDog1LayerFinalPosition;
   [self.blackDog1Layer addAnimation:theAnimation forKey:@"position"];
   
   //[self.blackDog1Layer addAnimation:[self BlackDog1LayerRotationAnimation] forKey:@"blackDog1Layer_rotation"];

   
   [(id<ACustomAnimation>)[self.animationsByName objectForKey:@"porter1Layer"] Start:triggered];
   
   theAnimation = [self 
                   AnimationOfLayer:self.porter1Layer 
                   OverPath:self.porter1LayerPathPoints 
                   ForDuration:self.porter1LayerAnimationDuration
                   WithIdentifier:@"porter1"];
   [self.porter1Layer addAnimation:theAnimation forKey:@"position"];
   
   //[self.porter1Layer addAnimation:[self Porter1LayerRotationAnimation] forKey:@"porter1Layer_rotation"];
   
   self.sequenceStart = [NSDate date];
   self.turnTimer.paused = NO;
   
   [CATransaction commit];
}

-(void)Stop
{
   self.turnTimer.paused = YES;
   self.sequenceStart = nil;
   
   // make sure the Bookmark is NOT visible for the Credits sequence
   [self.mainViewController HideBookmark];

   // make sure the correct button is showing
   [self SwitchBeginForSkipIntro];

   [self.scrollTimer invalidate];
   self.scrollTimer = nil;
   
   self.scrollStart = nil;
   
   [self.creditDisplayTimer invalidate];
   self.creditDisplayTimer = nil;
   
   self.creditDisplayIndex = 0;
   
   // hide any and all credits
   [CATransaction begin];
   [CATransaction setDisableActions:YES];
   
   for (ACreditDisplaySpec* displaySpec in [self.creditSpecsByTimeOffset allValues])
   {
      displaySpec.creditLayer.opacity = 0.0f;
   }
      
   [CATransaction commit];
   
   self.topImageLayerAnimationFired = NO;
   
   [self ResetLayers];
   
//   self.blackDogAndPorter1Layer.hidden = YES;
//   self.blackDogAndPorter2Layer.hidden = YES;
//   
//   self.tree1Layer.opacity = 0.0f;
//   self.trees2Layer.opacity = 0.0f;
   
   [self.creditsSound DeadStop];
}

-(void)ResetLayers
{
   [self.blackDog1Layer removeAllAnimations];
   [self.porter1Layer removeAllAnimations];
   [self.blackDog2Layer removeAllAnimations];
   [self.porter2Layer removeAllAnimations];
   [self.blackDogAndPorter1Layer removeAllAnimations];
   [self.blackDogAndPorter2Layer removeAllAnimations];
}

-(void)DisplayLinkDidTick:(CADisplayLink*)displayLink
{
   // The CADisplayLink is being used as the timer that will initiate rotations
   // to the various layers as they progress along their paths.
   CGFloat timeSinceStart = -1.0f * (CGFloat)[self.sequenceStart timeIntervalSinceNow];
   
   ATurnSpec* turnSpec = [self.turnSpecs peek];
   
   if (nil == turnSpec)
   {
      // the queue is empty - no point in continuing to receive displayLink callbacks...
      displayLink.paused = YES;
      
      return;
   }
   
   if (timeSinceStart < turnSpec.startTime)
   {
      // not time for a rotation yet...
      return;
   }
   
   CALayer* layerToRotate = nil;
   
   if ([@"blackDog1_turn" isEqualToString:turnSpec.layerName])
   {
      layerToRotate = self.blackDog1Layer;
   }
   else if ([@"porter1_turn" isEqualToString:turnSpec.layerName])
   {
      layerToRotate = self.porter1Layer;
   }
   else if ([@"blackDog2_turn" isEqualToString:turnSpec.layerName])
   {
      return;
   }
   else if ([@"porter2_turn" isEqualToString:turnSpec.layerName])
   {
      layerToRotate = self.porter2Layer;
   }
   else if ([@"blackDogAndPorter1_turn" isEqualToString:turnSpec.layerName])
   {
      layerToRotate = self.blackDogAndPorter1Layer;
   }
   else if ([@"blackDogAndPorter2_turn" isEqualToString:turnSpec.layerName])
   {
      layerToRotate = self.blackDogAndPorter2Layer;
   }
   else
   {
      NSLog(@"*** Error - unknown ATurnSpec received: %@", turnSpec.description);
   }
   
   if (nil != layerToRotate)
   {            
      NSNumber* startValue = [layerToRotate valueForKeyPath:@"transform.rotation.z"];
      NSNumber* endValue = [NSNumber numberWithFloat:(turnSpec.rotation * M_PI / 180)];
            
      
      //NSLog(@"About to rotate %@ from %@ to %@", turnSpec.layerName, startValue, endValue);
                        
      CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
      rotationAnimation.duration = turnSpec.duration;
      rotationAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateZ];
      rotationAnimation.fromValue = startValue;
      rotationAnimation.toValue = endValue;
      rotationAnimation.additive = YES;
      rotationAnimation.removedOnCompletion = NO;
      rotationAnimation.fillMode = kCAFillModeForwards;
      rotationAnimation.delegate = self;
            
      [rotationAnimation setValue:turnSpec.layerName forKey:@"animationId"];
      
      [layerToRotate addAnimation:rotationAnimation forKey:@"transform"];
   }
   
   // remove the turnSpec from the queue now that we're done with it
   [self.turnSpecs dequeue];
}

#pragma mark CAAnimation delegate
-(void)animationDidStop:(CAAnimation*)anim finished:(BOOL)finished
{   
   NSString* animationIdentifier = [anim valueForKey:@"animationId"];
   
   if ([@"porter1" isEqualToString:animationIdentifier])
   {
      if (!finished)
      {
         return;
      }
            
      // launch the second of the Black Dog/Porter animations
      
      CAKeyframeAnimation* theAnimation = nil;
      
      [CATransaction begin];
      
      self.blackDog2Layer.opacity = 1.0f;
      
      [(id<ACustomAnimation>)[self.animationsByName objectForKey:@"blackDog2Layer"] Start:NO];
      
      theAnimation = [self 
                      AnimationOfLayer:self.blackDog2Layer 
                      OverPath:self.blackDog2LayerPathPoints 
                      ForDuration:self.blackDog2LayerAnimationDuration
                      WithIdentifier:@"blackDog2"];
      [self.blackDog2Layer addAnimation:theAnimation forKey:@"position"]; 
      
      
      self.porter2Layer.opacity = 1.0f;
      
      [(id<ACustomAnimation>)[self.animationsByName objectForKey:@"porter2Layer"] Start:NO];
      
      theAnimation = [self 
                      AnimationOfLayer:self.porter2Layer 
                      OverPath:self.porter2LayerPathPoints 
                      ForDuration:self.porter2LayerAnimationDuration
                      WithIdentifier:@"porter2"];
      [self.porter2Layer addAnimation:theAnimation forKey:@"position"];
      
      [self.porter2Layer addAnimation:[self Porter2LayerRotationAnimation] forKey:@"porter2Layer_rotation"];
      
      [CATransaction commit];
   }
   else if ([@"blackDog2" isEqualToString:animationIdentifier])
   {
      self.blackDog2Layer.opacity = 0.0f;
   }
   else if ([@"porter2" isEqualToString:animationIdentifier])
   {
      self.porter2Layer.opacity = 0.0f;
      
      if (!finished)
      {
         return;
      }
      
      // start the 3rd animation, i.e. the first animation of Black Dog and the Porter together
      self.blackDogAndPorter1Layer.hidden = NO;
      self.blackDogAndPorter1Layer.opacity = 1.0f;
      
      CAKeyframeAnimation* theAnimation = [self 
                                           AnimationOfLayer:self.blackDogAndPorter1Layer 
                                           OverPath:self.blackDogAndPorter1LayerPathPoints 
                                           ForDuration:self.blackDogAndPorter1LayerAnimationDuration
                                           WithIdentifier:@"blackDogAndPorter1"];
      [self.blackDogAndPorter1Layer addAnimation:theAnimation forKey:@"position"];
   }
   else if ([@"blackDogAndPorter1" isEqualToString:animationIdentifier])
   {
      self.blackDogAndPorter1Layer.opacity = 0.0f;
      
      if (!finished)
      {
         return;
      }
            
      // start the 4th animation, i.e. the second animation of Black Dog and the Porter together
      [CATransaction begin];
      
      self.tree1Layer.hidden = NO;
      self.tree1Layer.opacity = 1.0f;
      self.trees2Layer.hidden = NO;
      self.trees2Layer.opacity = 1.0f;
      
      self.blackDogAndPorter2Layer.hidden = NO;
      self.blackDogAndPorter2Layer.opacity = 1.0f;
      
      CAKeyframeAnimation* theAnimation = [self 
                                           AnimationOfLayer:self.blackDogAndPorter2Layer 
                                           OverPath:self.blackDogAndPorter2LayerPathPoints 
                                           ForDuration:self.blackDogAndPorter2LayerAnimationDuration
                                           WithIdentifier:@"blackDogAndPorter2"];
      [self.blackDogAndPorter2Layer addAnimation:theAnimation forKey:@"position"]; 
      
      [CATransaction commit];
   }
   else if ([@"blackDogAndPorter2" isEqualToString:animationIdentifier])
   {
      self.blackDogAndPorter2Layer.opacity = 0.0f;
   }
   else if ([@"blackDogAndPorter1_turn" isEqualToString:animationIdentifier])
   {
      NSNumber* finalValue = ((CABasicAnimation*)anim).toValue;
      
      [CATransaction begin];
      [CATransaction setDisableActions:YES];
      [self.blackDogAndPorter1Layer setValue:finalValue forKeyPath:@"transform.rotation.z"];
      [CATransaction commit];
   }
   else if ([@"porter2_turn" isEqualToString:animationIdentifier])
   {
      NSNumber* finalValue = ((CABasicAnimation*)anim).toValue;
      
      [CATransaction begin];
      [CATransaction setDisableActions:YES];
      [self.porter2Layer setValue:finalValue forKeyPath:@"transform.rotation.z"];
      [CATransaction commit];
   }
//   else if ([@"blackDogAndPorter2_turn" isEqualToString:animationIdentifier])
//   {
//      CALayer* presentationLayer = (CALayer*)[self.blackDogAndPorter2Layer presentationLayer];
//      
//      NSNumber* finalValue = [presentationLayer valueForKeyPath:@"transform.rotation.z"];
//      
//      [CATransaction begin];
//      [CATransaction setDisableActions:YES];
//      [self.blackDogAndPorter2Layer setValue:finalValue forKeyPath:@"transform.rotation.z"];
//      [CATransaction commit];
//   }
}

@end



@implementation ATurnSpec

@synthesize startTime=fStartTime;
@synthesize layerName=fLayerName;
@synthesize rotation=fRotation;
@synthesize duration=fDuration;

-(void)dealloc
{
   Release(fLayerName);
   
   [super dealloc];
}

-(ATurnSpec*)initWithSpec:(NSDictionary*)turnSpecDictionary
{
   if (self = [super init])
   {
      self.startTime = turnSpecDictionary.startTime;
      self.layerName = turnSpecDictionary.layerName;
      self.rotation = turnSpecDictionary.rotation;
      self.duration = turnSpecDictionary.duration;
   }
   
   return self;
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"ATurnSpec rotation of %@ by %f degrees, in %f seconds, at timeOffset %f seconds", 
           self.layerName,
           self.rotation,
           self.duration,
           self.startTime];
}

@end



@implementation ACreditDisplaySpec

@synthesize displayDuration=fDisplayDuration;
@synthesize creditLayer=fCreditLayer;

-(void)dealloc
{
   Release(fCreditLayer);
   
   [super dealloc];
}

@end
