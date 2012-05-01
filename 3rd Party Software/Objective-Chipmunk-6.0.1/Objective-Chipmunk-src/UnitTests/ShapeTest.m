#include "SimpleTestCase.h"

#include "ObjectiveChipmunk.h"

@interface ShapeTest : SimpleTestCase {}
@end

@implementation ShapeTest

#define TestAccessors(o, p, v) o.p = v; GHAssertEquals(o.p, v, nil);

static void
testPropertiesHelper(id self, ChipmunkBody *body, ChipmunkShape *shape)
{
	GHAssertNotNULL(shape.shape, nil);
	GHAssertEquals(body, shape.body, nil);
	GHAssertNil(shape.data, nil);
	GHAssertFalse(shape.sensor, nil);
	GHAssertEquals(shape.elasticity, (cpFloat)0, nil);
	GHAssertEquals(shape.friction, (cpFloat)0, nil);
	GHAssertEquals(shape.surfaceVel, cpvzero, nil);
	GHAssertNil(shape.collisionType, nil);
	GHAssertNil(shape.group, CP_NO_GROUP);
	GHAssertEquals(shape.layers, CP_ALL_LAYERS, nil);
	
	cpBB bb = [shape cacheBB];
	GHAssertEquals(shape.bb, bb, nil);
	
	TestAccessors(shape, data, @"object");
	TestAccessors(shape, sensor, YES);
	TestAccessors(shape, elasticity, (cpFloat)0);
	TestAccessors(shape, friction, (cpFloat)0);
	TestAccessors(shape, surfaceVel, cpv(5,6));
	TestAccessors(shape, collisionType, @"type");
	TestAccessors(shape, group, @"group");
	TestAccessors(shape, layers, (cpLayers)123);
}

-(void)testProperties {
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:1 andMoment:1];
	
	ChipmunkCircleShape *circle = [ChipmunkCircleShape circleWithBody:body radius:1 offset:cpv(1,2)];
	testPropertiesHelper(self, body, circle);
	GHAssertEquals(circle.radius, (cpFloat)1, nil);
	GHAssertEquals(circle.offset, cpv(1,2), nil);
	
	GHAssertTrue([circle pointQuery:cpv(1,2)], nil);
	GHAssertTrue([circle pointQuery:cpv(1,2.9)], nil);
	GHAssertFalse([circle pointQuery:cpv(1,3.1)], nil);
	
	
	ChipmunkSegmentShape *segment = [ChipmunkSegmentShape segmentWithBody:body from:cpvzero to:cpv(1,0) radius:1];
	testPropertiesHelper(self, body, segment);
	GHAssertEquals(segment.a, cpvzero, nil);
	GHAssertEquals(segment.b, cpv(1,0), nil);
	GHAssertEquals(segment.normal, cpv(-0.0,1), nil);
	
	GHAssertTrue([segment pointQuery:cpvzero], nil);
	GHAssertTrue([segment pointQuery:cpv(1,0)], nil);
	GHAssertTrue([segment pointQuery:cpv(0.5, 0.5)], nil);
	GHAssertFalse([segment pointQuery:cpv(0,3)], nil);
	
	ChipmunkPolyShape *poly = [ChipmunkPolyShape boxWithBody:body width:10 height:10];
	testPropertiesHelper(self, body, poly);
	GHAssertTrue([poly pointQuery:cpv(0,0)], nil);	
	GHAssertTrue([poly pointQuery:cpv(3,3)], nil);	
	GHAssertFalse([poly pointQuery:cpv(-10,0)], nil);	
}

@end