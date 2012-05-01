// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "WhaleSpray.h"
#import "NSDictionary+ElementAndPropertyValues.h"

#define kWipeOpenAnimation @"WipeOpen"
#define kFadeOutAnimation  @"FadeOut"

#define kWhaleSprayWidth   61.0f
#define kWhaleSprayHeight  99.0f

@implementation AWhaleSpray

@synthesize layer=fLayer;
@synthesize finalWidth=fFinalWidth;
@synthesize finalHeight=fFinalHeight;
@synthesize animationInProgress=fAnimationInProgress;

-(void)dealloc
{   
   fLayer.delegate = nil;
   
   if (nil != fLayer.superlayer)
   {
      [fLayer removeFromSuperlayer];
   }
   
   Release(fLayer);
   
   [super dealloc];
}

-(void)BaseInit 
{
   [super BaseInit];
   
   self.finalWidth = kWhaleSprayWidth;
   self.finalHeight = kWhaleSprayHeight;
   self.animationInProgress = NO;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   [super BaseInitWithElement:element RenderOnView:view];
      
   fLayer = [[CALayer alloc] init];
   fLayer.frame = element.frame;
      
   NSString* imagePath = [[NSBundle mainBundle] pathForResource:element.resource ofType:nil];
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
   {
      ALog(@"image file missing: %@", imagePath);
      
      return;
   }
   
   UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
   [fLayer setContents:(id)image.CGImage]; 
   [image release];
   
   [view.layer addSublayer:fLayer];
}

-(void)WipeOpen
{
   // the endingRect is fully 'open'
   CGRect endingRect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
   
   self.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
   
   CGAffineTransform t = CGAffineTransformMakeScale(self.finalWidth, self.finalHeight);
   CGRect endingBounds = CGRectApplyAffineTransform(endingRect, t);
   
   CGRect currentContentsRect = self.layer.contentsRect;
   
   CABasicAnimation* contentsRectAnimation = [[CABasicAnimation alloc] init];
   contentsRectAnimation.keyPath = @"contentsRect";
   contentsRectAnimation.fromValue = [NSValue valueWithCGRect:currentContentsRect];
   contentsRectAnimation.toValue = [NSValue valueWithCGRect:endingRect];
   
   CGRect currentBounds = self.layer.bounds;
   
   CABasicAnimation* boundsAnimation = [[CABasicAnimation alloc] init];
   boundsAnimation.keyPath = @"bounds";
   boundsAnimation.fromValue = [NSValue valueWithCGRect:currentBounds];
   boundsAnimation.toValue = [NSValue valueWithCGRect:endingBounds];
   
   CAAnimationGroup* animations = [[CAAnimationGroup alloc] init];
   animations.duration = 1.0f;   //seconds
   animations.delegate = self;
   animations.animations = [NSArray arrayWithObjects:contentsRectAnimation, boundsAnimation, nil];
   
   [animations setValue:kWipeOpenAnimation forKey:@"animationId"];
   
   [contentsRectAnimation release];
   [boundsAnimation release];
   
   [CATransaction begin];
   
   self.layer.contentsRect = endingRect;
   self.layer.bounds = endingBounds;
   
   [self.layer addAnimation:animations forKey:@"WipeOpen"];
   [animations release];
   
   [CATransaction commit];
}

-(void)FadeOut
{   
   CABasicAnimation* opacityAnimation = [[CABasicAnimation alloc] init];
   opacityAnimation.keyPath = @"opacity";
   opacityAnimation.duration = 0.8f;
   opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
   opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
   opacityAnimation.delegate = self;
   
   [opacityAnimation setValue:kFadeOutAnimation forKey:@"animationId"];
   
   [CATransaction begin];
   
   self.layer.opacity = 0.0f;
   
   [self.layer addAnimation:opacityAnimation forKey:@"opacity"];
   [opacityAnimation release];
   
   [CATransaction commit];   
}

#pragma mark -
#pragma mark ACustomAnimation protocol
-(void)Start:(BOOL)triggered
{
   if (triggered)
   {
      if (!self.isAnimationInProgress)
      {
         self.animationInProgress = YES;
         
         [self WipeOpen];
      }
   }
}

-(void)Stop
{
   if (nil != self.layer)
   {
      [self.layer removeAllAnimations];
      
      self.animationInProgress = NO;
   }
}

#pragma mark -
#pragma CAAnimationDelegate protocol
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
   if (flag)
   {
      NSString* completedAnimationId = [anim valueForKey:@"animationId"];
      
      if ([kWipeOpenAnimation isEqualToString:completedAnimationId])
      {
         [self FadeOut];
      }
      else if ([kFadeOutAnimation isEqualToString:completedAnimationId])
      {
         // reset the whalespray image's bounds and opacity
         [CATransaction begin];
         [CATransaction setDisableActions:YES];
         
         self.layer.bounds = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
         self.layer.opacity = 1.0f;
         
         [CATransaction commit];
         
         self.animationInProgress = NO;
      }
   }
}

@end
