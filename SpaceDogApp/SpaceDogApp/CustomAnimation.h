// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

@class CMDeviceMotion;

@protocol ACustomAnimation

@optional

// NOT optional, declaring the property here stops the compiler from whining...
@property (copy) NSString* animationId;
@property (copy) NSString* completionNotification;

// truly optional
-(void)TriggerWithRecognizer:(UIGestureRecognizer*)recognizer;

@required

-(id<ACustomAnimation>)initWithElement:(NSDictionary*)element RenderOnView:(UIView*)view;
-(id<ACustomAnimation>)initWithElement:(NSDictionary*)element RenderOnLayer:(CALayer*)layer;

-(void)Start:(BOOL)triggered;
-(void)Stop;

-(void)Trigger;
-(void)Trigger:(NSNotification*)notification;
-(void)TriggerWithSpec:(NSDictionary*)triggerSpec;

-(void)DisplayLinkDidTick:(CADisplayLink*)displayLink;

-(IBAction)HandleGesture:(UIGestureRecognizer*)recognizer;
-(void)HandleTilt:(NSDictionary*)tiltInfo;
-(void)NotificationReceived:(NSNotification*)notification;
-(void)MotionUpdated:(CMDeviceMotion*)deviceMotion;

@end


