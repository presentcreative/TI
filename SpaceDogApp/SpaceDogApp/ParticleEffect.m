// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "ParticleEffect.h"
#import "NSDictionary+ElementAndPropertyValues.h"
#import "Trigger.h"
#import "BookView.h"
#import "ES1Renderer.h"

#define MAXIMUM_FRAME_RATE 90.0f		// Must also be set in ParticleEmitter.m
#define MINIMUM_FRAME_RATE 15.0f
#define UPDATE_INTERVAL (1.0 / MAXIMUM_FRAME_RATE)
#define MAX_CYCLES_PER_FRAME (MAXIMUM_FRAME_RATE / MINIMUM_FRAME_RATE)

@interface AParticleEffect (Private)
-(void)GameLoop;
-(void)DrawParticles:(id)sender;
-(void)StartAnimation;
-(void)StopAnimation;
@end

@implementation AParticleEffect

@synthesize propertyId=fPropertyId;
@synthesize containerView=fContainerView;
@synthesize triggers=fTriggers;
@synthesize particleLayer=fParticleLayer;
@synthesize renderer=fRenderer;
@synthesize animating=fAnimating;
@synthesize animationFrameInterval=fAnimationFrameInterval;

-(void)dealloc
{
   Release(fPropertyId);
   Release(fContainerView);
   Release(fTriggers);
   Release(fRenderer);
   Release(fParticleLayer);
   
   [super dealloc];
}


-(void)BaseInit
{
   self.propertyId = @"";
   self.containerView = nil;
   
   NSMutableArray* theTriggers = [[NSMutableArray alloc] initWithCapacity:4];
   self.triggers = theTriggers;
   [theTriggers release];
         
   self.animating = NO;
   self.animationFrameInterval = 1;
}

-(void)BaseInitWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   self.propertyId = element.propertyId;
   self.containerView = view;
   
   // Get the layer
   CAEAGLLayer* eaglLayer = [[CAEAGLLayer alloc] init];
   eaglLayer.frame = element.frame;
   self.particleLayer = eaglLayer;
   [eaglLayer release];
      
   self.particleLayer.opaque = NO;
   self.particleLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithBool:FALSE], 
                                            kEAGLDrawablePropertyRetainedBacking, 
                                            kEAGLColorFormatRGBA8, 
                                            kEAGLDrawablePropertyColorFormat, 
                                            nil];
   
   // For now, we'll assume that the particle layer is to appear over an underlying image
   // and should thus be transparent
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   const CGFloat backgroundColorComponents[] = {0.0f, 0.0f, 0.0f,0.0f};
   CGColorRef backgroundColor = CGColorCreate(colorSpace, backgroundColorComponents);
   self.particleLayer.backgroundColor = backgroundColor;
   CGColorRelease(backgroundColor);
   CGColorSpaceRelease(colorSpace);
   
   // The particle emitter only works with OpenGL ES 1.1, so we only create an ES1Renderer instance
   id<ESRenderer> theRenderer = [[ES1Renderer alloc] init];
   self.renderer = theRenderer;
   [theRenderer release];
   
   self.renderer.particleDescriptor = element.resource;
   
   if (nil != view)
   {
      [view.layer addSublayer:self.particleLayer];
      
      if ([view isKindOfClass:[ABookView class]])
      {
         [(ABookView*)view RegisterAsset:self WithKey:self.propertyId];
      }
   }
   
   ATrigger* theTrigger = nil;
   
   if (element.hasTriggers)
   {
      for (NSDictionary* triggerSpec in element.triggers)
      {
         theTrigger = [[ATrigger alloc] initWithTriggerSpec:triggerSpec ForAnimation:self OnView:view];
         [theTrigger release];
      }
   }
   else if (element.hasTrigger)
   {
      theTrigger = [[ATrigger alloc] initWithTriggerSpec:element.trigger ForAnimation:self OnView:view];
      [theTrigger release];
   }
}

-(id)initWithElement:(NSDictionary*)element RenderOnView:(UIView*)view
{
   if (self = [super init])
   {
      [self BaseInit];
      
      [self BaseInitWithElement:element RenderOnView:view];
   }
   
   return self;
}

- (void)GameLoop
{   
	static double lastFrameTime = 0.0f;
	static double cyclesLeftOver = 0.0f;
	double currentTime;
	double updateIterations;
	
	// Apple advises to use CACurrentMediaTime() as CFAbsoluteTimeGetCurrent() is synced with the mobile
	// network time and so could change causing hiccups.
	currentTime = CACurrentMediaTime();
	updateIterations = ((currentTime - lastFrameTime) + cyclesLeftOver);
	
	if(updateIterations > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
		updateIterations = (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL);
	
	while (updateIterations >= UPDATE_INTERVAL) {
		updateIterations -= UPDATE_INTERVAL;
		
		// Update the game logic passing in the fixed update interval as the delta
		[self.renderer updateWithDelta:UPDATE_INTERVAL];		
	}
	
	cyclesLeftOver = updateIterations;
	lastFrameTime = currentTime;
   
	// Render the scene
   [self DrawParticles:nil];
}

- (void)DrawParticles:(id)sender
{
   [self.renderer render];
}

- (void)layoutSubviews
{
   [self.renderer resizeFromLayer:(CAEAGLLayer*)self.particleLayer];
   [self DrawParticles:nil];
}

//- (NSInteger)animationFrameInterval
//{
//   return self.animationFrameInterval;
//}
//
//- (void)setAnimationFrameInterval:(NSInteger)frameInterval
//{
//   // Frame interval defines how many display frames must pass between each time the
//   // display link fires. The display link will only fire 30 times a second when the
//   // frame internal is two on a display that refreshes 60 times a second. The default
//   // frame interval setting of one will fire 60 times a second when the display refreshes
//   // at 60 times a second. A frame interval setting of less than one results in undefined
//   // behavior.
//   if (frameInterval >= 1)
//   {
//      self.animationFrameInterval = frameInterval;
//      
//      if (self.isAnimating)
//      {
//         [self StopAnimation];
//         [self StartAnimation];
//      }
//   }
//}

- (void)StartAnimation
{
   if (!self.isAnimating)
   {      
      self.animating = TRUE;
      
      [self.renderer resizeFromLayer:(CAEAGLLayer*)self.particleLayer];
      [self DrawParticles:nil];
   }
}

- (void)StopAnimation
{
   if (self.isAnimating)
   {      
      self.animating = FALSE;
   }
}

#pragma mark ACustomAnimation protocol
-(id<ACustomAnimation>)initWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
   return self;
}

-(void)Start:(BOOL)triggered
{
   [self StartAnimation];
}

-(void)Stop
{
   [self StopAnimation]; 
}

-(void)DisplayLinkDidTick:(CADisplayLink *)displayLink
{
   if (self.isAnimating)
   {
      [self GameLoop];
   }
}

-(void)TriggerWithSpec:(NSDictionary*)triggerSpec
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(IBAction)HandleGesture:(UIGestureRecognizer*)recognizer
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(void)HandleTilt:(NSDictionary*)tiltInfo
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.   
}

-(void)NotificationReceived:(NSNotification*)notification
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.
}

-(void)MotionUpdated:(CMDeviceMotion*)deviceMotion
{
   // NO-OP implementation, to satisfy ACustomAnimation protocol.   
}

-(void)Trigger
{
   [self Start:YES];
}

// Many page-based animations start and stop when the page on which they're
// resident becomes visible or invisible, respectively
-(void)Trigger:(NSNotification*)notification
{   
}

@end
