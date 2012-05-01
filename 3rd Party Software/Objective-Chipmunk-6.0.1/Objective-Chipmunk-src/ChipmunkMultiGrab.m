#import "ChipmunkMultiGrab.h"


// A constraint subclass that tracks a grab point
@interface ChipmunkGrab : ChipmunkPivotJoint {
	ChipmunkBody *_body;
	cpVect _pos;
	cpFloat _smoothing;
}

@property(nonatomic, assign) cpVect pos;

-(id)initWithPos:(cpVect)pos body:(ChipmunkBody *)body smoothing:(cpFloat)smoothing;

@end


@implementation ChipmunkGrab

@synthesize pos = _pos;

static void 
GrabPreSolve(cpConstraint *constraint, cpSpace *space)
{
	cpBody *grabBody = cpConstraintGetA(constraint);
	ChipmunkGrab *grab = cpConstraintGetUserData(constraint);
	cpFloat dt = cpSpaceGetCurrentTimeStep(space);
	cpFloat coef = cpfpow(grab->_smoothing, dt);
	
	// Smooth out the mouse position.
	cpVect pos = cpvlerp(grab->_pos, cpBodyGetPos(grabBody), coef);
	cpBodySetVel(grabBody, cpvmult(cpvsub(pos, cpBodyGetPos(grabBody)), 1.0/dt));
	cpBodySetPos(grabBody, pos);
}

-(id)initWithPos:(cpVect)pos body:(ChipmunkBody *)body smoothing:(cpFloat)smoothing;
{
	ChipmunkBody *grabBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
	grabBody.pos = pos;
	
	if((self = [super initWithBodyA:grabBody bodyB:body pivot:pos])){
		_body = grabBody;
		_pos = pos;
		_smoothing = smoothing;
		
		cpConstraintSetPreSolveFunc(self.constraint, GrabPreSolve);
	}
	
	return self;
}

// Add/Remove no objects if the grab was void.
- (void)addToSpace:(ChipmunkSpace *)space {if(self.bodyB) [super addToSpace:space];}
- (void)removeFromSpace:(ChipmunkSpace *)space {if(self.bodyB) [super removeFromSpace:space];}


@end


@implementation ChipmunkMultiGrab

@synthesize layers = _layers, group = _group;

-(id)initForSpace:(ChipmunkSpace *)space withSmoothing:(cpFloat)smoothing withGrabForce:(cpFloat)force;
{
	if((self = [super init])){
		_space = [space retain];
		_grabs = [[NSMutableArray alloc] init];
		
		_smoothing = smoothing;
		_force = force;
		
		_layers = CP_ALL_LAYERS;
		_group = CP_NO_GROUP;
	}
	
	return self;
}

-(void)dealloc
{
	[_space release];
	[super dealloc];
}

-(BOOL)beginLocation:(cpVect)pos;
{
	ChipmunkShape *shape = [_space pointQueryFirst:pos layers:_layers group:_group];
	ChipmunkBody *body = (shape && ![shape.body isStatic] ? shape.body : nil);
	
	ChipmunkGrab *grab = [[ChipmunkGrab alloc] initWithPos:pos body:shape.body smoothing:_smoothing];
	grab.maxForce = _force;
	
	[_grabs addObject:grab];
	[_space add:grab];
	[grab release];
	
	return (body != nil);
}

static ChipmunkGrab *
BestGrab(NSArray *grabs, cpVect pos)
{
	ChipmunkGrab *match = nil;
	cpFloat best = INFINITY;
	
	for(ChipmunkGrab *grab in grabs){
		cpFloat dist = cpvdistsq(pos, grab.pos);
		if(dist < best){
			match = grab;
			best = dist;
		}
	}
	
	return match;
}

-(void)updateLocation:(cpVect)pos;
{
	BestGrab(_grabs, pos).pos = pos;
}

-(void)endLocation:(cpVect)pos;
{
	cpAssertHard([_grabs count] != 0, "Grab set is already empty!");
	ChipmunkGrab *grab = BestGrab(_grabs, pos);
	
	[_space remove:grab];
	[_grabs removeObject:grab];
}

@end
