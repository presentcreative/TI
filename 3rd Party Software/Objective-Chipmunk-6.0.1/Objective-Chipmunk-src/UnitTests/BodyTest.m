#include "SimpleTestCase.h"

#include "ObjectiveChipmunk.h"

@interface BodyTest : SimpleTestCase {}
@end

@implementation BodyTest

#define TestAccessors(o, p, v) o.p = v; GHAssertEquals(o.p, v, nil);

-(void)testProperties {
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:123 andMoment:123];
	GHAssertEquals(body.mass, (cpFloat)123, nil);
	GHAssertEquals(body.moment, (cpFloat)123, nil);
	
	GHAssertNotNULL(body.body, nil);
	GHAssertNil(body.data, nil);
	
	TestAccessors(body, data, @"object");
	TestAccessors(body, mass, (cpFloat)5);
	TestAccessors(body, moment, (cpFloat)5);
	TestAccessors(body, pos, cpv(5,6));
	TestAccessors(body, vel, cpv(5,6));
	TestAccessors(body, force, cpv(5,6));
	TestAccessors(body, angle, (cpFloat)5);
	TestAccessors(body, angVel, (cpFloat)5);
	TestAccessors(body, torque, (cpFloat)5);
	
	body.angle = 0;
	GHAssertEquals(body.rot, cpv(1,0), nil);
	
	body.angle = M_PI;
	GHAssertTrue(cpvdist(body.rot, cpv(-1,0)) < 1e-5, nil);
	
	body.angle = M_PI_2;
	GHAssertTrue(cpvdist(body.rot, cpv(0,1)) < 1e-5, nil);
	
	GHAssertFalse(body.isSleeping, nil);
	GHAssertFalse(body.isStatic, nil);
	GHAssertTrue(body.isRogue, nil);
}

-(void)testBasic {
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:1 andMoment:1];
	
	[body applyForce:cpv(0,1) offset:cpv(1,0)];
	GHAssertTrue(body.force.y > 0, nil);
	GHAssertTrue(body.force.x == 0, nil);
	GHAssertTrue(body.torque > 0, nil);
	
	[body resetForces];
	GHAssertEquals(body.force, cpvzero, nil);
	GHAssertEquals(body.torque, (cpFloat)0, nil);
	
	[body applyImpulse:cpv(0,1) offset:cpv(1,0)];
	GHAssertTrue(body.vel.y > 0, nil);
	GHAssertTrue(body.vel.x == 0, nil);
	GHAssertTrue(body.angVel > 0, nil);
}

-(void)testMisc {
	ChipmunkBody *staticBody = [ChipmunkBody staticBody];
	GHAssertFalse(staticBody.isSleeping, nil);
	GHAssertTrue(staticBody.isStatic, nil);
	GHAssertTrue(staticBody.isRogue, nil);
	
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:1 andMoment:1];
	[space add:body];
	GHAssertFalse(body.isSleeping, nil);
	GHAssertFalse(body.isStatic, nil);
	GHAssertFalse(body.isRogue, nil);
	
	[body sleep];
	GHAssertTrue(body.isSleeping, nil);
	[space release];
}

@end
