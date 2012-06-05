#include "SimpleTestCase.h"

#include "ObjectiveChipmunk.h"

#define AssertRetainCount(obj, count) GHAssertEquals([obj retainCount], (NSUInteger)count, nil)

@interface MemoryTest : SimpleTestCase {}
@end

@implementation MemoryTest

-(void)testBasic {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	
	ChipmunkBody *body1 = [[ChipmunkBody alloc] initWithMass:1 andMoment:1];
	ChipmunkBody *body2 = [[ChipmunkBody alloc] initWithMass:1 andMoment:1];
	
	ChipmunkShape *shape1 = [[ChipmunkCircleShape alloc] initWithBody:body1 radius:1 offset:cpvzero];
	ChipmunkShape *shape2 = [[ChipmunkCircleShape alloc] initWithBody:body2 radius:1 offset:cpvzero];
	
	ChipmunkConstraint *joint1 = [[ChipmunkPivotJoint alloc] initWithBodyA:body1 bodyB:body2 pivot:cpvzero];
	ChipmunkConstraint *joint2 = [[ChipmunkPivotJoint alloc] initWithBodyA:body1 bodyB:body2 pivot:cpvzero];
	
	[space add:body1];
	[space add:body2];
	[space add:shape1];
	[space add:shape2];
	[space add:joint1];
	[space add:joint2];
	
	AssertRetainCount(body1, 5);
	AssertRetainCount(body2, 5);
	AssertRetainCount(shape1, 2);
	AssertRetainCount(shape2, 2);
	AssertRetainCount(joint1, 2);
	AssertRetainCount(joint2, 2);
	
	[space remove:body1];
	[space remove:shape1];
	[space remove:joint1];
	
	AssertRetainCount(body1, 4);
	AssertRetainCount(body2, 5);
	AssertRetainCount(shape1, 1);
	AssertRetainCount(shape2, 2);
	AssertRetainCount(joint1, 1);
	AssertRetainCount(joint2, 2);
	
	[space release];
	
	AssertRetainCount(body1, 4);
	AssertRetainCount(body2, 4);
	AssertRetainCount(shape1, 1);
	AssertRetainCount(shape2, 1);
	AssertRetainCount(joint1, 1);
	AssertRetainCount(joint2, 1);
	
	[joint1 release];
	[joint2 release];
	
	AssertRetainCount(body1, 2);
	AssertRetainCount(body2, 2);
	
	[shape1 release];
	[shape2 release];
	
	AssertRetainCount(body1, 1);
	AssertRetainCount(body2, 1);
	
	[body1 release];
	[body2 release];
}

-(void)testStaticBody {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	ChipmunkBody *staticBody = space.staticBody;
	
	AssertRetainCount(staticBody, 1);
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:space.staticBody radius:1 offset:cpvzero];
	AssertRetainCount(staticBody, 2);
	
	[space add:shape];
	AssertRetainCount(shape, 2);
	AssertRetainCount(staticBody, 2);
	
	[space release];
	AssertRetainCount(shape, 1);
	AssertRetainCount(staticBody, 1);
	
	[shape release];
}

-(void)testSetters {
	ChipmunkBody *body = [[ChipmunkBody alloc] initStaticBody];
	
	
	ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:nil radius:1 offset:cpvzero];
	shape.body = body;
	AssertRetainCount(body, 2);
	
	shape.body = body;
	AssertRetainCount(body, 2);
	
	shape.body = nil;
	AssertRetainCount(body, 1);
	
	
//	ChipmunkConstraint *joint = [ChipmunkPivotJoint pivotJointWithBodyA:nil bodyB:nil pivot:cpvzero];
//	joint.bodyA = body; joint.bodyB = body;
//	AssertRetainCount(body, 3);
//	
//	joint.bodyA = body; joint.bodyB = body;
//	AssertRetainCount(body, 3);
//	
//	joint.bodyA = nil; joint.bodyB = nil;
//	AssertRetainCount(body, 1);
	
	
	[body release];
}

-(void)testPostStepCallbacks {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	NSObject *obj1 = [[NSObject alloc] init];
	NSObject *obj2 = [[NSObject alloc] init];
	
	// Registering the callback should retain the object twice
	[space addPostStepCallback:obj1 selector:@selector(isEqual:) key:obj1];
	AssertRetainCount(obj1, 3);
	
	// Registering the same callback a second time should not add more retains
	[space addPostStepCallback:obj1 selector:@selector(isEqual:) key:obj1];
	AssertRetainCount(obj1, 3);
	
	// A key can only be registered once to prevent double removals.
	// Registering a second target with the same key is a no-op.
	[space addPostStepCallback:obj2 selector:@selector(isEqual:) key:obj1];
	AssertRetainCount(obj1, 3);
	AssertRetainCount(obj2, 1);
	
	[space addPostStepCallback:obj1 selector:@selector(isEqual:) key:obj2];
	AssertRetainCount(obj1, 4);
	AssertRetainCount(obj2, 2);
	
	// Stepping the space should release the callback handler and both objects
	[space step:1];
	AssertRetainCount(obj1, 1);
	AssertRetainCount(obj2, 1);
	
	[space release];
	[obj1 release];
	[obj2 release];
}

-(void)testCollisionHandlers {
	NSString *a = @"a";
	NSString *b = @"b";
	NSString *c = @"c";
	
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	NSObject *obj = [[NSObject alloc] init];
	
	[space addCollisionHandler:obj typeA:a typeB:b begin:nil preSolve:nil postSolve:nil separate:nil];
	AssertRetainCount(obj, 2);
	
	// registering the same callback should not change the retain count
	[space addCollisionHandler:obj typeA:a typeB:b begin:nil preSolve:nil postSolve:nil separate:nil];
	AssertRetainCount(obj, 2);
	
	// swapping the types should not change the retain count
	[space addCollisionHandler:obj typeA:b typeB:a begin:nil preSolve:nil postSolve:nil separate:nil];
	AssertRetainCount(obj, 2);
	
	// register a second handler with the same target
	[space addCollisionHandler:obj typeA:b typeB:c begin:nil preSolve:nil postSolve:nil separate:nil];
	AssertRetainCount(obj, 3);
	
	// swapping again
	[space addCollisionHandler:obj typeA:c typeB:b begin:nil preSolve:nil postSolve:nil separate:nil];
	AssertRetainCount(obj, 3);
	
	// overwrite the first handler, retain count should go down
	[space addCollisionHandler:nil typeA:a typeB:b begin:nil preSolve:nil postSolve:nil separate:nil];
	AssertRetainCount(obj, 2);
	
	// remove the second handler explicitly
	[space removeCollisionHandlerForTypeA:b andB:c];
	AssertRetainCount(obj, 1);
	
	// test releasing handlers when the space is freed
	[space addCollisionHandler:obj typeA:a typeB:b begin:nil preSolve:nil postSolve:nil separate:nil];
	[space setDefaultCollisionHandler:obj begin:nil preSolve:nil postSolve:nil separate:nil];
	AssertRetainCount(obj, 3);
	
	[space release];
	AssertRetainCount(obj, 1);
	
	[obj release];
}

@end
