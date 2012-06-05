#import "ObjectiveChipmunk.h"

@implementation ChipmunkBody
+ (id)bodyWithMass:(cpFloat)mass andMoment:(cpFloat)moment;
{
	return [[[self alloc] initWithMass:mass andMoment:moment] autorelease];
}

+ (id)staticBody;
{
	return [[[self alloc] initStaticBody] autorelease];
}

- (id)initWithMass:(cpFloat)mass andMoment:(cpFloat)moment;
{
	if((self = [super init])){
		cpBodyInit(&_body, mass, moment);
		_body.data = self;
	}
	
	return self;
}

- (id)initStaticBody;
{
	if((self = [super init])){
		cpBodyInitStatic(&_body);
		_body.data = self;
	}
	
	return self;
}

- (void) dealloc;
{
	cpBodyDestroy(&_body);
	[super dealloc];
}


- (cpBody *)body {return &_body;}


@synthesize data;

// accessor macros
#define getter(type, lower, upper) \
- (type)lower {return cpBodyGet##upper(&_body);}
#define setter(type, lower, upper) \
- (void)set##upper:(type)value {cpBodySet##upper(&_body, value);};
#define both(type, lower, upper) \
getter(type, lower, upper) \
setter(type, lower, upper)


both(cpFloat, mass, Mass)
both(cpFloat, moment, Moment)
both(cpVect, pos, Pos)
both(cpVect, vel, Vel)
both(cpVect, force, Force)
both(cpFloat, angle, Angle)
both(cpFloat, angVel, AngVel)
both(cpFloat, torque, Torque)
getter(cpVect, rot, Rot)
both(cpFloat, velLimit, VelLimit);
both(cpFloat, angVelLimit, AngVelLimit);

- (cpFloat)kineticEnergy {return cpBodyKineticEnergy(&_body);}

- (cpVect)local2world:(cpVect)v {return cpBodyLocal2World(&_body, v);}
- (cpVect)world2local:(cpVect)v {return cpBodyWorld2Local(&_body, v);}

- (void)resetForces {cpBodyResetForces(&_body);}
- (void)applyForce:(cpVect)force offset:(cpVect)offset {cpBodyApplyForce(&_body, force, offset);}
- (void)applyImpulse:(cpVect)j offset:(cpVect)offset {cpBodyApplyImpulse(&_body, j, offset);}

- (bool)isSleeping {return cpBodyIsSleeping(&_body);}
- (bool)isRogue {return cpBodyIsRogue(&_body);}
- (bool)isStatic {return cpBodyIsStatic(&_body);}

- (void)activate {cpBodyActivate(&_body);}
- (void)activateStatic:(ChipmunkShape *)filter {cpBodyActivateStatic(&_body, filter.shape);}
- (void)sleepWithGroup:(ChipmunkBody *)group {cpBodySleepWithGroup(&_body, group.body);}
- (void)sleep {cpBodySleep(&_body);}

- (NSSet *)chipmunkObjects {return [NSSet setWithObject:self];}
- (void)addToSpace:(ChipmunkSpace *)space {[space addBody:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeBody:self];}

static void PushShape(cpBody *ignored, cpShape *shape, NSMutableArray *arr){[arr addObject:shape->data];}
- (NSArray *)shapes;
{
	NSMutableArray *arr = [NSArray array];
	cpBodyEachShape(&_body, (cpBodyShapeIteratorFunc)PushShape, arr);
	
	return arr;
}

static void PushConstraint(cpBody *ignored, cpConstraint *constraint, NSMutableArray *arr){[arr addObject:constraint->data];}
- (NSArray *)constraints;
{
	NSMutableArray *arr = [NSArray array];
	cpBodyEachConstraint(&_body, (cpBodyConstraintIteratorFunc)PushConstraint, arr);
	
	return arr;
}

static void CallArbiterBlock(cpBody *body, cpArbiter *arbiter, ChipmunkBodyArbiterIteratorBlock block){block(arbiter);}
- (void)eachArbiter:(ChipmunkBodyArbiterIteratorBlock)block;
{
	cpBodyEachArbiter(&_body, (cpBodyArbiterIteratorFunc)CallArbiterBlock, block);
}

#pragma mark Extras

- (CGAffineTransform) affineTransform;
{
	cpVect rot = _body.rot, pos = _body.p;
	return CGAffineTransformMake(rot.x, rot.y, -rot.y, rot.x, pos.x, pos.y);
}

@end
