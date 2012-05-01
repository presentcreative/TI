#import "ObjectiveChipmunk.h"

@implementation ChipmunkShape

@synthesize data;

- (void) dealloc {
	[self.body release];
	cpShapeDestroy(self.shape);
	[super dealloc];
}


- (cpShape *)shape {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (ChipmunkBody *)body {
	cpBody *body = self.shape->body;
	return (body ? body->data : nil);
}

- (void)setBody:(ChipmunkBody *)value {
	if(self.body != value){
		[self.body release];
		self.shape->body = [[value retain] body];
	}
}

// accessor macros
#define getter(type, lower, upper, member) \
- (type)lower {return self.shape->member;}
#define setter(type, lower, upper, member) \
- (void)set##upper:(type)value {self.shape->member = value;};
#define both(type, lower, upper, member) \
getter(type, lower, upper, member) \
setter(type, lower, upper, member)

getter(cpBB, bb, BB, bb)
both(BOOL, sensor, Sensor, sensor)
both(cpFloat, elasticity, Elasticity, e)
both(cpFloat, friction, Friction, u)
both(cpVect, surfaceVel, SurfaceVel, surface_v)
both(id, collisionType, CollisionType, collision_type)
both(id, group, Group, group)
both(cpLayers, layers, Layers, layers)

- (cpBB)cacheBB {return cpShapeCacheBB(self.shape);}

- (bool)pointQuery:(cpVect)point {
	return cpShapePointQuery(self.shape, point);
}

- (NSSet *)chipmunkObjects {return [NSSet setWithObject:self];}
- (void)addToSpace:(ChipmunkSpace *)space {[space addShape:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeShape:self];}

@end


@implementation ChipmunkSegmentQueryInfo

- (id)initWithStart:(cpVect)start end:(cpVect)end;
{
	if((self = [super init])){
		_start = start;
		_end = end;
	}
	
	return self;
}

- (cpSegmentQueryInfo *)info {return &_info;}
- (ChipmunkShape *)shape {return (_info.shape ? _info.shape->data : nil);}
- (cpFloat)t {return _info.t;}
- (cpVect)normal {return _info.n;}
- (cpVect)point {return cpSegmentQueryHitPoint(_start, _end, _info);}
- (cpFloat)dist {return cpSegmentQueryHitDist(_start, _end, _info);}
- (cpVect)start {return _start;}
- (cpVect)end {return _end;}

- (void)dealloc
{
	[self.shape release];
	[super dealloc];
}


@end

@implementation ChipmunkShapeQueryInfo

@synthesize shape = _shape;
- (cpContactPointSet *)contactPoints {return &_contactPoints;}

- (id)initWithShape:(ChipmunkShape *)shape andPoints:(cpContactPointSet *)set;
{
	if((self = [super init])){
		_shape = [shape retain];
		_contactPoints = *set;
	}
	
	return self;
}

- (void)dealloc {
	[_shape release];
	[super dealloc];
}

@end

@implementation ChipmunkCircleShape

+ (ChipmunkCircleShape *)circleWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset;
{
	return [[[self alloc] initWithBody:body radius:radius offset:offset] autorelease];
}

- (cpShape *)shape {return (cpShape *)&_shape;}

- (id)initWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset {
	if((self = [super init])){
		[body retain];
		cpCircleShapeInit(&_shape, body.body, radius, offset);
		self.shape->data = self;
	}
	
	return self;
}

- (cpFloat)radius {return cpCircleShapeGetRadius((cpShape *)&_shape);}
- (cpVect)offset {return cpCircleShapeGetOffset((cpShape *)&_shape);}

@end


@implementation ChipmunkSegmentShape

+ (ChipmunkSegmentShape *)segmentWithBody:(ChipmunkBody *)body from:(cpVect)a to:(cpVect)b radius:(cpFloat)radius;
{
	return [[[self alloc] initWithBody:body from:a to:b radius:radius] autorelease];
}

- (cpShape *)shape {return (cpShape *)&_shape;}

- (id)initWithBody:(ChipmunkBody *)body from:(cpVect)a to:(cpVect)b radius:(cpFloat)radius {
	if((self = [super init])){
		[body retain];
		cpSegmentShapeInit(&_shape, body.body, a, b, radius);
		self.shape->data = self;
	}
	
	return self;
}

- (cpVect)a {return cpSegmentShapeGetA((cpShape *)&_shape);}
- (cpVect)b {return cpSegmentShapeGetB((cpShape *)&_shape);}
- (cpVect)normal {return cpSegmentShapeGetNormal((cpShape *)&_shape);}
- (cpFloat)radius {return cpSegmentShapeGetRadius((cpShape *)&_shape);}

@end


@implementation ChipmunkPolyShape

+ (ChipmunkPolyShape *)polyWithBody:(ChipmunkBody *)body count:(int)count verts:(cpVect *)verts offset:(cpVect)offset;
{
	return [[[self alloc] initWithBody:body count:count verts:verts offset:offset] autorelease];
}

+ (id)boxWithBody:(ChipmunkBody *)body width:(cpFloat)width height:(cpFloat)height;
{
	return [[[self alloc] initBoxWithBody:body width:width height:height] autorelease];
}

- (cpShape *)shape {return (cpShape *)&_shape;}

- (id)initWithBody:(ChipmunkBody *)body count:(int)count verts:(cpVect *)verts offset:(cpVect)offset {
	if((self = [super init])){
		[body retain];
		cpPolyShapeInit(&_shape, body.body, count, verts, offset);
		self.shape->data = self;
	}
	
	return self;
}

- (id)initBoxWithBody:(ChipmunkBody *)body width:(cpFloat)width height:(cpFloat)height;
{
	if((self = [super init])){
		[body retain];
		cpBoxShapeInit(&_shape, body.body, width, height);
		self.shape->data = self;
	}
	
	return self;
}

- (int)count {return cpPolyShapeGetNumVerts((cpShape *)&_shape);}
- (cpVect)getVertex:(int)index {return cpPolyShapeGetVert((cpShape *)&_shape, index);}

@end

@implementation ChipmunkStaticCircleShape : ChipmunkCircleShape
- (void)addToSpace:(ChipmunkSpace *)space {[space addStaticShape:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeStaticShape:self];}
@end

@implementation ChipmunkStaticSegmentShape : ChipmunkSegmentShape
- (void)addToSpace:(ChipmunkSpace *)space {[space addStaticShape:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeStaticShape:self];}
@end

@implementation ChipmunkStaticPolyShape : ChipmunkPolyShape
- (void)addToSpace:(ChipmunkSpace *)space {[space addStaticShape:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeStaticShape:self];}
@end
