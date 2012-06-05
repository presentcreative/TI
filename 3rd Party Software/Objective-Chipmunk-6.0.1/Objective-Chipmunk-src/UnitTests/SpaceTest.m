#include "SimpleTestCase.h"

#define CP_ALLOW_PRIVATE_ACCESS
#include "ObjectiveChipmunk.h"

@interface SpaceTest : SimpleTestCase {}
@end

@implementation SpaceTest

#define TestAccessors(o, p, v) o.p = v; GHAssertEquals(o.p, v, nil);
#define AssertRetainCount(obj, count) GHAssertEquals([obj retainCount], (NSUInteger)count, nil)

-(void)testProperties {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	GHAssertEquals(space.gravity, cpvzero, nil);
	GHAssertEquals(space.damping, (cpFloat)1.0, nil);
	GHAssertEquals(space.idleSpeedThreshold, (cpFloat)0, nil);
	GHAssertEquals(space.sleepTimeThreshold, (cpFloat)INFINITY, nil);
	
	GHAssertNotNULL(space.space, nil);
	GHAssertNotNil(space.staticBody, nil);
	
	TestAccessors(space, iterations, 50);
	TestAccessors(space, gravity, cpv(1,2));
	TestAccessors(space, damping, (cpFloat)5);
	TestAccessors(space, idleSpeedThreshold, (cpFloat)5);
	TestAccessors(space, sleepTimeThreshold, (cpFloat)5);
	
	[space release];
}

static NSSet *
segmentQueryInfoToShapes(NSArray *arr)
{
	NSMutableSet *set = [NSMutableSet setWithCapacity:[arr count]];
	for(ChipmunkSegmentQueryInfo *info in arr)[set addObject:info.shape];
	return set;
}

static NSSet *
shapeQueryInfoToShapes(NSArray *arr)
{
	NSMutableSet *set = [NSMutableSet setWithCapacity:[arr count]];
	for(ChipmunkShapeQueryInfo *info in arr)[set addObject:info.shape];
	return set;
}

static void
testPointQueries_helper(id self, ChipmunkSpace *space, ChipmunkBody *body)
{
	ChipmunkShape *circle = [space add:[[ChipmunkCircleShape alloc] initWithBody:body radius:1 offset:cpv(1,1)]];
	ChipmunkShape *segment = [space add:[[ChipmunkSegmentShape alloc] initWithBody:body from:cpvzero to:cpv(1,1) radius:1]];
	ChipmunkShape *box = [space add:[[ChipmunkPolyShape alloc] initBoxWithBody:body width:1 height:1]];
	
	NSSet *set;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Point queries
	set = [NSSet setWithArray:[space pointQueryAll:cpvzero layers:CP_ALL_LAYERS group:CP_NO_GROUP]];
	GHAssertEqualObjects(set, ([NSSet setWithObjects:segment, box, nil]), nil);
	
	set = [NSSet setWithArray:[space pointQueryAll:cpv(1,1) layers:CP_ALL_LAYERS group:CP_NO_GROUP]];
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, nil]), nil);
	
	set = [NSSet setWithArray:[space pointQueryAll:cpv(0.4, 0.4) layers:CP_ALL_LAYERS group:CP_NO_GROUP]];
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, box, nil]), nil);
	
	set = [NSSet setWithArray:[space pointQueryAll:cpv(-0.6, -0.6) layers:CP_ALL_LAYERS group:CP_NO_GROUP]];
	GHAssertEqualObjects(set, ([NSSet setWithObjects:segment, nil]), nil);
	
	set = [NSSet setWithArray:[space pointQueryAll:cpv(-1,-1) layers:CP_ALL_LAYERS group:CP_NO_GROUP]];
	GHAssertEqualObjects(set, ([NSSet setWithObjects:nil]), nil);
	
	// Segment queries
	set = segmentQueryInfoToShapes([space segmentQueryAllFrom:cpv(-2,-2) to:cpv(4,4) layers:CP_ALL_LAYERS group:CP_NO_GROUP]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, box, nil]), nil);
	
	set = segmentQueryInfoToShapes([space segmentQueryAllFrom:cpv(2,-2) to:cpv(-2,2) layers:CP_ALL_LAYERS group:CP_NO_GROUP]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:segment, box, nil]), nil);
	
	set = segmentQueryInfoToShapes([space segmentQueryAllFrom:cpv(3,-1) to:cpv(-1,3) layers:CP_ALL_LAYERS group:CP_NO_GROUP]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, nil]), nil);
	
	set = segmentQueryInfoToShapes([space segmentQueryAllFrom:cpv(2.4,-1.6) to:cpv(-1.6,2.4) layers:CP_ALL_LAYERS group:CP_NO_GROUP]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, box, nil]), nil);
	
	set = segmentQueryInfoToShapes([space segmentQueryAllFrom:cpv(2,2) to:cpv(3,3) layers:CP_ALL_LAYERS group:CP_NO_GROUP]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:nil]), nil);
	
	ChipmunkSegmentQueryInfo *info;
	info = [space segmentQueryFirstFrom:cpv(-2,-2) to:cpv(1,1) layers:CP_ALL_LAYERS group:CP_NO_GROUP];
	GHAssertEqualObjects(info.shape, segment, nil, nil);
	
	info = [space segmentQueryFirstFrom:cpv(-2,-2) to:cpv(-1,-1) layers:CP_ALL_LAYERS group:CP_NO_GROUP];
	GHAssertEqualObjects(info.shape, nil, nil, nil);
	
	// Shape queries
	ChipmunkBody *queryBody = [ChipmunkBody bodyWithMass:1 andMoment:1];
	ChipmunkShape *queryShape = [ChipmunkCircleShape circleWithBody:queryBody radius:1 offset:cpvzero];
	
	queryBody.pos = cpvzero;
	set = shapeQueryInfoToShapes([space shapeQueryAll:queryShape]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, box, nil]), nil);
	
	queryBody.pos = cpv(1,1);
	set = shapeQueryInfoToShapes([space shapeQueryAll:queryShape]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, box, nil]), nil);
	
	queryBody.pos = cpv(0,-1);
	set = shapeQueryInfoToShapes([space shapeQueryAll:queryShape]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:segment, box, nil]), nil);
	
	queryBody.pos = cpv(0,-1.6);
	set = shapeQueryInfoToShapes([space shapeQueryAll:queryShape]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:segment, nil]), nil);
	
	queryBody.pos = cpv(2,2);
	set = shapeQueryInfoToShapes([space shapeQueryAll:queryShape]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:circle, segment, nil]), nil);
	
	queryBody.pos = cpv(4,4);
	set = shapeQueryInfoToShapes([space shapeQueryAll:queryShape]);
	GHAssertEqualObjects(set, ([NSSet setWithObjects:nil]), nil);
	
	[space remove:circle];
	[space remove:segment];
	[space remove:box];
	[pool release];
	
	AssertRetainCount(circle, 1);
	AssertRetainCount(segment, 1);
	AssertRetainCount(box, 1);
	
	[circle release];
	[segment release];
	[box release];
}

-(void)testPointQueries {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	
	testPointQueries_helper(self, space, space.staticBody);
	
	ChipmunkBody *staticRogue = [ChipmunkBody staticBody];
	testPointQueries_helper(self, space, staticRogue);
	
	ChipmunkBody *normalRogue = [ChipmunkBody bodyWithMass:1 andMoment:1];
	testPointQueries_helper(self, space, normalRogue);
	
	ChipmunkBody *normal = [space add:[ChipmunkBody bodyWithMass:1 andMoment:1]];
	testPointQueries_helper(self, space, normalRogue);
	[space remove:normal];
	
	[space release];
}

-(void)testShapes {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	ChipmunkShape *shape;
	
	// Check that static shapes get added correctly
	shape = [space add:[ChipmunkCircleShape circleWithBody:space.staticBody radius:1 offset:cpvzero]];
	GHAssertTrue(cpSpatialIndexContains(space.space->staticShapes, shape.shape, shape.shape->hashid), nil);
	
	shape = [space add:[ChipmunkCircleShape circleWithBody:[ChipmunkBody staticBody] radius:1 offset:cpvzero]];
	GHAssertTrue(cpSpatialIndexContains(space.space->staticShapes, shape.shape, shape.shape->hashid), nil);
	
	// Check that normal shapes get added correctly
	ChipmunkBody *rogue = [ChipmunkBody bodyWithMass:1 andMoment:1];
	shape = [space add:[ChipmunkCircleShape circleWithBody:rogue radius:1 offset:cpvzero]];
	GHAssertTrue(cpSpatialIndexContains(space.space->activeShapes, shape.shape, shape.shape->hashid), nil);
	
	ChipmunkBody *normal = [space add:[ChipmunkBody bodyWithMass:1 andMoment:1]];
	shape = [space add:[ChipmunkCircleShape circleWithBody:normal radius:1 offset:cpvzero]];
	GHAssertTrue(cpSpatialIndexContains(space.space->activeShapes, shape.shape, shape.shape->hashid), nil);
	
	[space release];
}

-(void)testBasicSimulation {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	space.gravity = cpv(0, -100);
	
	[space addBounds:CGRectMake(-50, 0, 100, 100) thickness:1 elasticity:1 friction:1 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:nil];
	
	ChipmunkBody *ball = [space add:[ChipmunkBody bodyWithMass:1 andMoment:cpMomentForCircle(1, 0, 1, cpvzero)]];
	ball.pos = cpv(-10, 10);
	[space add:[ChipmunkCircleShape circleWithBody:ball radius:1 offset:cpvzero]];
	
	ChipmunkBody *box = [space add:[ChipmunkBody bodyWithMass:1 andMoment:cpMomentForBox(1, 2, 2)]];
	box.pos = cpv(10, 10);
	[space add:[ChipmunkPolyShape boxWithBody:box width:2 height:2]];
	
	for(int i=0; i<100; i++) [space step:0.01];
	
	cpFloat cp_collision_slop = 0.5f; // TODO relpace
	GHAssertEqualsWithAccuracy(ball.pos.y, (cpFloat)1, 1.1*cp_collision_slop, nil);
	GHAssertEqualsWithAccuracy(box.pos.y, (cpFloat)1, 1.1*cp_collision_slop, nil);
	
	[space release];
}

// TODO test sleeping

@end