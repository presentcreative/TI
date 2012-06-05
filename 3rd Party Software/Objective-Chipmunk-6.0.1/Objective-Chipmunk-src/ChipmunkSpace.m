#define CP_ALLOW_PRIVATE_ACCESS
#import "ObjectiveChipmunk.h"

#if (defined OBJECTIVE_CHIPMUNK_TRIAL)
	#import <UIKit/UIKit.h>
#endif

// Private class used to wrap the statically allocated staticBody attached to each space.
@interface _ChipmunkStaticBodySingleton : ChipmunkBody {
	cpBody *_bodyPtr;
	ChipmunkSpace *space; // weak ref
}

@end

typedef struct handlerContext {
	id target;
	ChipmunkSpace *space;
	id typeA, typeB;
	SEL beginSelector;
	bool (*beginFunc)(id self, SEL selector, cpArbiter *arb, ChipmunkSpace *space);
	SEL preSolveSelector;
	bool (*preSolveFunc)(id self, SEL selector, cpArbiter *arb, ChipmunkSpace *space);
	SEL postSolveSelector;
	void (*postSolveFunc)(id self, SEL selector, cpArbiter *arb, ChipmunkSpace *space);
	SEL separateSelector;
	void (*separateFunc)(id self, SEL selector, cpArbiter *arb, ChipmunkSpace *space);
} handlerContext;

@implementation ChipmunkSpace

+ (void)initialize
{
	static BOOL done = FALSE; if(done) return; done = TRUE;
	
#if (defined OBJECTIVE_CHIPMUNK_TRIAL) && !TARGET_IPHONE_SIMULATOR
	UIAlertView *alert = [[UIAlertView alloc]
		initWithTitle:@"Objective-Chipmunk Trial"
		message:@"This copy of Objective-Chipmunk is a trial, please consider purchasing if you continue using it."
		delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil
	];
	
	[alert show];
	[alert release];
#endif
}

- (id)init {
	if((self = [super init])){
		_children = [[NSMutableSet alloc] init];
		_handlers = [[NSMutableArray alloc] init];
		
		cpSpaceInit(&_space);
		_space.data = self;
		_staticBody = [[ChipmunkBody alloc] initStaticBody];
		_space.staticBody = _staticBody.body;
	}
	
	return self;
}

- (void) dealloc {
	[_children release];
	
	for(NSData *data in _handlers){
		[((handlerContext *)[data bytes])->target release];
	}
	
	[_handlers release];
	
	[_staticBody release];
	cpSpaceDestroy(&_space);
	
	[super dealloc];
}

- (cpSpace *)space {return &_space;}

@synthesize data = _data;

// accessor macros
#define getter(type, lower, upper) \
- (type)lower {return cpSpaceGet##upper(&_space);}
#define setter(type, lower, upper) \
- (void)set##upper:(type)value {cpSpaceSet##upper(&_space, value);};
#define both(type, lower, upper) \
getter(type, lower, upper) \
setter(type, lower, upper)

both(int, iterations, Iterations);
both(cpVect, gravity, Gravity);
both(cpFloat, damping, Damping);
both(cpFloat, idleSpeedThreshold, IdleSpeedThreshold);
both(cpFloat, sleepTimeThreshold, SleepTimeThreshold);
both(cpFloat, collisionSlop, CollisionSlop);
both(cpFloat, collisionBias, CollisionBias);
both(cpTimestamp, collisionPersistence, CollisionPersistence);
both(bool, enableContactGraph, EnableContactGraph);
getter(cpFloat, currentTimeStep, CurrentTimeStep);

- (ChipmunkBody *)staticBody {return _staticBody;}

#define HANDLER_FUNC(fname, postfix, rtype, target) \
static rtype fname##Func##postfix(cpArbiter *arb, struct cpSpace *space, handlerContext *ctx) \
{return ctx->fname##Func(target, ctx->fname##Selector, arb, ctx->space);}

#define HANDLER_FUNCS(postfix, target) \
HANDLER_FUNC(begin, postfix, bool, target) \
HANDLER_FUNC(preSolve, postfix, bool, target) \
HANDLER_FUNC(postSolve, postfix, void, target) \
HANDLER_FUNC(separate, postfix, void, target)

HANDLER_FUNCS(, ctx->target)
HANDLER_FUNCS(_shapea, ((ChipmunkShape *)(arb->swappedColl ? arb->b->data : arb->a->data))->data)
HANDLER_FUNCS(_shapeb, ((ChipmunkShape *)(arb->swappedColl ? arb->a->data : arb->b->data))->data)

#define HFUNC(fname, postfix, Fname) (fname ? (cpCollision##Fname##Func)fname##Func##postfix : NULL)
#define HFUNCS(postfix) \
HFUNC(begin, postfix, Begin), \
HFUNC(preSolve, postfix, PreSolve), \
HFUNC(postSolve, postfix, PostSolve), \
HFUNC(separate, postfix, Separate)

// Free collision handler targets for the given type pair
static void
filterHandlers(NSMutableArray **handlers, id typeA, id typeB)
{
	NSMutableArray *newHandlers = [[NSMutableArray alloc] initWithCapacity:[(*handlers) count]];
	
	for(NSData *data in (*handlers)){
		const handlerContext *context = [data bytes];
		if(
			(context->typeA == typeA && context->typeB == typeB) || 
			(context->typeA == typeB && context->typeB == typeA)
		){
			[context->target release];
		} else {
			[newHandlers addObject:data];
		}
	}
	
	[(*handlers) release];
	(*handlers) = newHandlers;
}

- (void)setDefaultCollisionHandler:(id)target
	begin:(SEL)begin
	preSolve:(SEL)preSolve
	postSolve:(SEL)postSolve
	separate:(SEL)separate;
{
	[target retain];
	filterHandlers(&_handlers, nil, nil);
	
	handlerContext handler = {
		target, self, nil, nil,
		begin, (void *)(begin ? [target methodForSelector:begin] : NULL),
		preSolve, (void *)(preSolve ? [target methodForSelector:preSolve] : NULL),
		postSolve, (void *)(postSolve ? [target methodForSelector:postSolve] : NULL),
		separate, (void *)(separate ? [target methodForSelector:separate] : NULL),
	};
	NSData *data = [NSData dataWithBytes:&handler length:sizeof(handler)];
	
	cpSpaceSetDefaultCollisionHandler(&_space,
		HFUNCS(),
		(void *)[data bytes]
	);
	
	[_handlers addObject:data];
}
	
- (void)addCollisionHandler:(id)target
	typeA:(id)a typeB:(id)b
	begin:(SEL)begin
	preSolve:(SEL)preSolve
	postSolve:(SEL)postSolve
	separate:(SEL)separate;
{
	[target retain];
	[self removeCollisionHandlerForTypeA:a andB:b];
	
	handlerContext handler = {
		target, self, a, b,
		begin, (void *)(begin ? [target methodForSelector:begin] : NULL),
		preSolve, (void *)(preSolve ? [target methodForSelector:preSolve] : NULL),
		postSolve, (void *)(postSolve ? [target methodForSelector:postSolve] : NULL),
		separate, (void *)(separate ? [target methodForSelector:separate] : NULL),
	};
	NSData *data = [NSData dataWithBytes:&handler length:sizeof(handler)];
	
	cpSpaceAddCollisionHandler(
		&_space, a, b,
		HFUNCS(),
		(void *)[data bytes]
	);
	
	[_handlers addObject:data];
}

- (void)addShapeAHandler:(Class)klass
	typeA:(id)a typeB:(id)b
	begin:(SEL)begin
	preSolve:(SEL)preSolve
	postSolve:(SEL)postSolve
	separate:(SEL)separate;
{
	[self removeCollisionHandlerForTypeA:a andB:b];
	
	handlerContext handler = {
		nil, self, a, b,
		begin, (void *)(begin ? [klass  instanceMethodForSelector:begin] : NULL),
		preSolve, (void *)(preSolve ? [klass instanceMethodForSelector:preSolve] : NULL),
		postSolve, (void *)(postSolve ? [klass instanceMethodForSelector:postSolve] : NULL),
		separate, (void *)(separate ? [klass instanceMethodForSelector:separate] : NULL),
	};
	NSData *data = [NSData dataWithBytes:&handler length:sizeof(handler)];
	
	cpSpaceAddCollisionHandler(
		&_space, a, b,
		HFUNCS(_shapea),
		(void *)[data bytes]
	);
	
	[_handlers addObject:data];
}

- (void)addShapeBHandler:(Class)klass
	typeA:(id)a typeB:(id)b
	begin:(SEL)begin
	preSolve:(SEL)preSolve
	postSolve:(SEL)postSolve
	separate:(SEL)separate;
{
	[self removeCollisionHandlerForTypeA:a andB:b];
	
	handlerContext handler = {
		nil, self, a, b,
		begin, (void *)(begin ? [klass  instanceMethodForSelector:begin] : NULL),
		preSolve, (void *)(preSolve ? [klass instanceMethodForSelector:preSolve] : NULL),
		postSolve, (void *)(postSolve ? [klass instanceMethodForSelector:postSolve] : NULL),
		separate, (void *)(separate ? [klass instanceMethodForSelector:separate] : NULL),
	};
	NSData *data = [NSData dataWithBytes:&handler length:sizeof(handler)];
	
	cpSpaceAddCollisionHandler(
		&_space, a, b,
		HFUNCS(_shapeb),
		(void *)[data bytes]
	);
	
	[_handlers addObject:data];
}

- (void)removeCollisionHandlerForTypeA:(id)a andB:(id)b;
{
	filterHandlers(&_handlers, a, b);
	cpSpaceRemoveCollisionHandler(&_space, a, b);
}

- (id)add:(NSObject<ChipmunkObject> *)obj;
{
	if([obj conformsToProtocol:@protocol(ChipmunkBaseObject)]){
		[(id<ChipmunkBaseObject>)obj addToSpace:self];
	} else {
		[self addBaseObjects:[obj chipmunkObjects]];
	}
	
	return obj;
}

- (void)addBaseObjects:(id <NSFastEnumeration>)objects;
{for(id <ChipmunkBaseObject> base in objects) [base addToSpace:self];}

- (id)remove:(NSObject<ChipmunkObject> *)obj;
{
	if([obj conformsToProtocol:@protocol(ChipmunkBaseObject)]){
		[(id<ChipmunkBaseObject>)obj removeFromSpace:self];
	} else {
		[self removeBaseObjects:[obj chipmunkObjects]];
	}
	
	return obj;
}

- (void)removeBaseObjects:(id <NSFastEnumeration>)objects;
{for(id <ChipmunkBaseObject> base in objects) [base removeFromSpace:self];}

typedef struct postStepContext {
	id target;
	SEL selector;
} postStepContext;

static void
postStepPerform(cpSpace *unused, id object, NSData *data)
{
	const postStepContext *context = [data bytes];
	[context->target performSelector:context->selector withObject:object];
	
	[object release];
	[context->target release];
	[data release];
}

- (void)addPostStepCallback:(id)target selector:(SEL)selector key:(id)key;
{
	if(!cpSpaceGetPostStepData(&_space, key)){
		// TODO add a space check once cpSpace has a data pointer to prevent possible cycles?
		[target retain];
		[key retain];
		
		postStepContext context = {target, selector};
		cpSpaceAddPostStepCallback(&_space, (cpPostStepFunc)postStepPerform, key, [[NSData alloc] initWithBytes:&context length:sizeof(context)]);
	}
}

- (void)addPostStepRemoval:(id <ChipmunkObject>)obj;
{
	[self addPostStepCallback:self selector:@selector(remove:) key:obj];
}

static void queryAll(cpShape *shape, NSMutableArray *array){[array addObject:shape->data];}

- (NSArray *)pointQueryAll:(cpVect)point layers:(cpLayers)layers group:(id)group;
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	cpSpacePointQuery(&_space, point, layers, group, (cpSpacePointQueryFunc)queryAll, array);
	return [array autorelease];
}

- (ChipmunkShape *)pointQueryFirst:(cpVect)point layers:(cpLayers)layers group:(id)group;
{
	cpShape *shape = cpSpacePointQueryFirst(&_space, point, layers, group);
	return (shape ? shape->data : nil);
}

typedef struct segmentQueryContext {
	cpVect start, end;
	NSMutableArray *array;
} segmentQueryContext;

static void
segmentQueryAll(cpShape *shape, cpFloat t, cpVect n, segmentQueryContext *sqc)
{
	ChipmunkSegmentQueryInfo *info = [[ChipmunkSegmentQueryInfo alloc] initWithStart:sqc->start end:sqc->end];
	*info.info = (cpSegmentQueryInfo){.shape=shape, .t=t, .n=n};
	[shape->data retain];
	
	[sqc->array addObject:info];
	[info release];
}

- (NSArray *)segmentQueryAllFrom:(cpVect)start to:(cpVect)end layers:(cpLayers)layers group:(id)group;
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	segmentQueryContext sqc = {start, end, array};
	
	cpSpaceSegmentQuery(&_space, start, end, layers, group, (cpSpaceSegmentQueryFunc)segmentQueryAll, &sqc);
	
	return [array autorelease];
}

- (ChipmunkSegmentQueryInfo *)segmentQueryFirstFrom:(cpVect)start to:(cpVect)end layers:(cpLayers)layers group:(id)group;
{
	ChipmunkSegmentQueryInfo *info = [[ChipmunkSegmentQueryInfo alloc] initWithStart:start end:(cpVect)end];
	cpSpaceSegmentQueryFirst(&_space, start, end, layers, group, info.info);
	[info.shape retain];
	
	return [info autorelease];
}

- (NSArray *)bbQueryAll:(cpBB)bb layers:(cpLayers)layers group:(id)group;
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	cpSpaceBBQuery(&_space, bb, layers, group, (cpSpaceBBQueryFunc)queryAll, array);
	return [array autorelease];
}

static void
shapeQueryAll(cpShape *shape, cpContactPointSet *points, NSMutableArray *array)
{
	ChipmunkShapeQueryInfo *info = [[ChipmunkShapeQueryInfo alloc] initWithShape:shape->data andPoints:points];
	[array addObject:info];
	[info release];
}

- (NSArray *)shapeQueryAll:(ChipmunkShape *)shape;
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	cpSpaceShapeQuery(&_space, shape.shape, (cpSpaceShapeQueryFunc)shapeQueryAll, array);
	return [array autorelease];
}

- (BOOL)shapeTest:(ChipmunkShape *)shape
{
	return cpSpaceShapeQuery(&_space, shape.shape, NULL, NULL);
}

- (void)activateShapesTouchingShape:(ChipmunkShape *)shape;
{
	cpSpaceActivateShapesTouchingShape(&_space, shape.shape);
}

static void PushBody(cpBody *body, NSMutableArray *arr){[arr addObject:body->data];}
- (NSArray *)bodies;
{
	NSMutableArray *arr = [NSMutableArray array];
	cpSpaceEachBody(&_space, (cpSpaceBodyIteratorFunc)PushBody, arr);
	
	return arr;
}

static void PushShape(cpShape *shape, NSMutableArray *arr){[arr addObject:shape->data];}
- (NSArray *)shapes;
{
	NSMutableArray *arr = [NSMutableArray array];
	cpSpaceEachShape(&_space, (cpSpaceShapeIteratorFunc)PushShape, arr);
	
	return arr;
}

static void PushConstraint(cpConstraint *constraint, NSMutableArray *arr){[arr addObject:constraint->data];}
- (NSArray *)constraints;
{
	NSMutableArray *arr = [NSMutableArray array];
	cpSpaceEachConstraint(&_space, (cpSpaceConstraintIteratorFunc)PushConstraint, arr);
	
	return arr;
}


- (void)reindexStatic;
{cpSpaceReindexStatic(&_space);}

- (void)reindexShape:(ChipmunkShape *)shape;
{cpSpaceReindexShape(&_space, shape.shape);}

- (void)reindexShapesForBody:(ChipmunkBody *)body
{cpSpaceReindexShapesForBody(&_space, body.body);}

- (void)step:(cpFloat)dt;
{cpSpaceStep(&_space, dt);}

#pragma mark Extras

- (ChipmunkBody *)addBody:(ChipmunkBody *)obj {
	cpSpaceAddBody(&_space, obj.body);
	[_children addObject:obj];
	return obj;
}

- (ChipmunkBody *)removeBody:(ChipmunkBody *)obj {
	cpSpaceRemoveBody(&_space, obj.body);
	[_children removeObject:obj];
	return obj;
}


- (ChipmunkShape *)addShape:(ChipmunkShape *)obj {
	cpSpaceAddShape(&_space, obj.shape);
	[_children addObject:obj];
	return obj;
}

- (ChipmunkShape *)removeShape:(ChipmunkShape *)obj {
	cpSpaceRemoveShape(&_space, obj.shape);
	[_children removeObject:obj];
	return obj;
}

- (ChipmunkShape *)addStaticShape:(ChipmunkShape *)obj {
	cpSpaceAddStaticShape(&_space, obj.shape);
	[_children addObject:obj];
	return obj;
}

- (ChipmunkShape *)removeStaticShape:(ChipmunkShape *)obj {
	cpSpaceRemoveStaticShape(&_space, obj.shape);
	[_children removeObject:obj];
	return obj;
}

- (ChipmunkConstraint *)addConstraint:(ChipmunkConstraint *)obj {
	cpSpaceAddConstraint(&_space, obj.constraint);
	[_children addObject:obj];
	return obj;
}

- (ChipmunkConstraint *)removeConstraint:(ChipmunkConstraint *)obj {
	cpSpaceRemoveConstraint(&_space, obj.constraint);
	[_children removeObject:obj];
	return obj;
}

static ChipmunkStaticSegmentShape *
boundSeg(ChipmunkBody *body, cpVect a, cpVect b, cpFloat radius, cpFloat elasticity,cpFloat friction, cpLayers layers, id group, id collisionType)
{
	ChipmunkStaticSegmentShape *seg = [ChipmunkStaticSegmentShape segmentWithBody:body from:a to:b radius:radius];
	seg.elasticity = elasticity;
	seg.friction = friction;
	seg.layers = layers;
	seg.group = group;
	seg.collisionType = collisionType;
	
	return seg;
}

- (void)addBounds:(CGRect)bounds thickness:(cpFloat)radius
	elasticity:(cpFloat)elasticity friction:(cpFloat)friction
	layers:(cpLayers)layers group:(id)group
	collisionType:(id)collisionType;
{
	cpFloat l = bounds.origin.x - radius;
	cpFloat r = bounds.origin.x + bounds.size.width + radius;
	cpFloat b = bounds.origin.y - radius;
	cpFloat t = bounds.origin.y + bounds.size.height + radius;
	
	ChipmunkBody *staticBody = _staticBody;
	[self addBaseObjects:ChipmunkObjectFlatten(
		boundSeg(staticBody, cpv(l,b), cpv(l,t), radius, elasticity, friction, layers, group, collisionType),
		boundSeg(staticBody, cpv(l,t), cpv(r,t), radius, elasticity, friction, layers, group, collisionType),
		boundSeg(staticBody, cpv(r,t), cpv(r,b), radius, elasticity, friction, layers, group, collisionType),
		boundSeg(staticBody, cpv(r,b), cpv(l,b), radius, elasticity, friction, layers, group, collisionType),
		nil
	)];
}

@end
