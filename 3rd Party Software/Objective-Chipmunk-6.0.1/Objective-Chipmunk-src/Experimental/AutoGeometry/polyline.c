#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "chipmunk.h"
#include "march.h"
#include "polyline.h"

polylines
polylines_new()
{
  int size = 4;
  return (polylines){0, size, calloc(size, sizeof(polyline))};
}

void
polyline_free(polyline line)
{
	free(line.verts);
}

void
polylines_free(polylines lines)
{
	for(int i=0; i<lines.count; i++) polyline_free(lines.lines[i]);
	free(lines.lines);
}

// Find the polyline that ends with v.
static int
polylines_find_ends(polylines *lines, cpVect v){
  for(int i=0; i<lines->count; i++){
    polyline *line = lines->lines + i;
    if(cpveq(line->verts[line->count - 1], v)) return i;
  }
  
  return -1;
}

// Find the polyline that starts with v.
static int
polylines_find_starts(polylines *lines, cpVect v){
  for(int i=0; i<lines->count; i++){
    polyline *line = lines->lines + i;
    if(cpveq(line->verts[0], v)) return i;
  }
  
  return -1;
}

// Grow the allocated memory for a polyline.
static void
grow_polyline(polyline *line, int count)
{
  line->count += count;
  
  int size = line->size;
  while(line->count > size) size *= 2;
  
  if(line->size != size){
    line->size = size;
    line->verts = realloc(line->verts, size*sizeof(cpVect));
  }
}

// Add a new polyline to a polyline set.
static void
polylines_add(polylines *lines, cpVect v0, cpVect v1)
{
  // grow lines
  lines->count++;
  if(lines->count > lines->size){
    lines->size *= 2;
    lines->lines = realloc(lines->lines, lines->size*sizeof(polyline));
  }
  
  // init the line
  const int startSize = 64;
  polyline *line = &lines->lines[lines->count - 1];
  (*line) = (polyline){
    2, startSize, malloc(startSize*sizeof(cpVect))
  };
  
  line->verts[0] = v0;
  line->verts[1] = v1;
}

// Join two polylines in a polyline set together.
static void
polylines_join(polylines *lines, int before, int after)
{
  polyline *lbefore = &lines->lines[before];
  polyline *lafter = &lines->lines[after];
  
  // append
  int count = lbefore->count;
  grow_polyline(lbefore, lafter->count);
  memmove(lbefore->verts + count, lafter->verts, lafter->count*sizeof(cpVect));
  
  // delete lafter
  lines->count--;
 	free(lines->lines[after].verts);
  lines->lines[after] = lines->lines[lines->count];
}

// Push v onto the end of line.
static void
polyline_push(polyline *line, cpVect v)
{
  int count = line->count;
  grow_polyline(line, 1);
  line->verts[count] = v;
}

// Push v onto the beginning of line.
static void
polyline_enqueue(polyline *line, cpVect v)
{
  int count = line->count;
  grow_polyline(line, 1);
  memmove(line->verts + 1, line->verts, count*sizeof(cpVect));
  line->verts[0] = v;
}

// Add a segment to a polyline set.
// A segment will either start a new polyline, join two others, or grow a polyline.
void
polylines_collect_segment(cpVect v0, cpVect v1, polylines *lines)
{
  int before = polylines_find_ends(lines, v0);
  int after = polylines_find_starts(lines, v1);
  
  if(before >= 0 && after >= 0){
    if(before == after){
      // loop by pushing v1 onto before
      polyline_push(&lines->lines[before], v1);
    } else {
      // join before and after
      polylines_join(lines, before, after);
    }
  } else if(before >= 0){
    // push v1 onto before
    polyline_push(&lines->lines[before], v1);
  } else if(after >= 0){
    // enqueue v0 onto after
    polyline_enqueue(&lines->lines[after], v0);
  } else {
    // create new line from v0 and v1
    polylines_add(lines, v0, v1);
  }
}

// Check if a polyline is longer than a certain length
static cpFloat
polyline_is_longer(cpVect *points, int length, int start, int end, cpFloat min)
{
  cpFloat len = 0.0f;
	for(int i=start; i!=end; i=(i+1)%length){
		len += cpvdist(points[i], points[(i+1)%length]);
		if(len > min) return 1;
	}
  
  return 0;
}

// Recursive reduction function used by polyline_simplify().
static void
reduce_recurse(
	cpVect *verts, polyline *reduced,
	int length, int start, int end,
	cpFloat min, cpFloat tol
){
  if((end - start + length)%length < 2) return;
  
	cpVect a = verts[start];
	cpVect b = verts[end];
	if(cpvnear(a, b, min) && polyline_is_longer(verts, length, start, end, min)) return;
	
	cpFloat max = 0.0;
	int maxi = start + 1;
	
	cpVect n = cpvnormalize(cpvperp(cpvsub(a, b)));
	cpFloat d = cpvdot(n, a);
	
	for(int i=(start+1)%length; i!=end; i=(i+1)%length){
		cpFloat dist = fabs(cpvdot(n, verts[i]) - d);
		
		if(dist > max){
			max = dist;
			maxi = i;
		}
	}
	
	if(max > tol){
    reduce_recurse(verts, reduced, length, start, maxi, min, tol);
    reduced->verts[reduced->count++] = verts[maxi];
    reduce_recurse(verts, reduced, length, maxi, end, min, tol);
	}
}

static inline cpFloat
sharpness(cpVect a, cpVect b, cpVect c)
{
  return cpvdot(cpvnormalize(cpvsub(a, b)), cpvnormalize(cpvsub(c, b)));
}

struct loop_indexes {
	int start, end;
};

// Heuristic to find good starting points for reducing a loop
// Currently it picks the "sharpest" vertex, and the vertex farthest from it.
static struct loop_indexes
polyline_loop_indexes(polyline line)
{
	int length = line.count;
  struct loop_indexes indexes = {0, 0};
	
  cpFloat maxSharp = sharpness(line.verts[length-2], line.verts[0], line.verts[1]);
  
  for(int i=1; i<length-1; i++){
    cpFloat sharp = sharpness(line.verts[i-1], line.verts[i], line.verts[i+1]);
    if(sharp > maxSharp){
      maxSharp = sharp;
      indexes.start = i;
    }
  }
  
  cpVect vert = line.verts[indexes.start];
  cpFloat maxDist = 0.0f;
  
  for(int i=0; i<length-1; i++){
    cpFloat dist = cpvdist(vert, line.verts[i]);
    if(dist > maxDist){
      maxDist = dist;
      indexes.end = i;
    }
  }
  
  return indexes;
}

// Returns true if the polyline starts and ends with the same vertex.
int
polyline_is_looped(polyline line)
{
	return cpveq(line.verts[0], line.verts[line.count-1]);
}

// Recursively reduce the vertex count on a polyline. Works best for smooth shapes.
// 'tol' is the maximum error for the reduction.
// The reduced polyline will never be farther than this distance from the original polyline.
polyline
polyline_simplify_curves(polyline line, cpFloat tol)
{
	cpFloat min = tol/2.0f;
	polyline reduced = {0, line.count, malloc(line.count*sizeof(cpVect))};
  
  if(polyline_is_looped(line)){
    struct loop_indexes indexes = polyline_loop_indexes(line);
    
		reduced.verts[reduced.count++] = line.verts[indexes.start];
		reduce_recurse(line.verts, &reduced, line.count - 1, indexes.start, indexes.end, min, tol);
		reduced.verts[reduced.count++] = line.verts[indexes.end];
		reduce_recurse(line.verts, &reduced, line.count - 1, indexes.end, indexes.start, min, tol);
		reduced.verts[reduced.count++] = line.verts[indexes.start];
  } else {
		reduced.verts[reduced.count++] = line.verts[0];
		reduce_recurse(line.verts, &reduced, line.count, 0, line.count - 1, min, tol);
		reduced.verts[reduced.count++] = line.verts[line.count - 1];
  }
	
	return (polyline){reduced.count, reduced.count, realloc(reduced.verts, reduced.count*sizeof(cpVect))};
}

// Join similar adjacent line segments together. Works well for hard edged shapes.
// 'tol' is the minimum anglular difference in radians of a vertex.
polyline
polyline_simplify_vertexes(polyline line, cpFloat tol)
{
	polyline result = {2, line.count, malloc(line.count*sizeof(cpVect))};
	result.verts[0] = line.verts[0];
	result.verts[1] = line.verts[1];
	
	cpFloat minSharp = -cos(tol);
	
	for(int i=2; i<line.count; i++){
		cpVect vert = line.verts[i];
		cpFloat sharp = sharpness(result.verts[result.count - 2], result.verts[result.count - 1], vert);
		
		if(sharp < minSharp){
			result.verts[result.count - 1] = vert;
		} else {
			result.verts[result.count++] = vert;
		}
	}
	
	if(
		polyline_is_looped(line) &&
		sharpness(result.verts[result.count - 2], result.verts[0], result.verts[1]) < minSharp
	){
		result.verts[0] = result.verts[result.count - 2];
		result.count--;
	}
	
	return (polyline){result.count, result.count, realloc(result.verts, result.count*sizeof(cpVect))};
}

static inline int
is_behind(cpVect a, cpVect b, cpVect v)
{
	cpVect delta = cpvsub(b, a);
	return cpvcross(delta, v) < cpvcross(delta, a);
}

// Add a vertex to a convex hull. The vertex may be ignored, added, or replace other vertexes.
static void
hull_push_point(polyline *hull, cpVect v)
{
	cpVect *verts = hull->verts;
	int count = hull->count;
	
	cpVect result[count];
	int rcount = 0;
	
	int behind_prev = is_behind(verts[count - 1], verts[0], v);
	
	for(int i=0; i<count; i++){
		int behind = is_behind(verts[i], verts[(i+1)%count], v);
		
		if(!behind && behind_prev){
			result[rcount++] = v;
		}
		
		if(!(behind && behind_prev)){
			result[rcount++] = verts[i];
		}
		
		behind_prev = behind;
	}
	
	memcpy(verts, result, rcount*sizeof(cpVect));
	hull->count = rcount;
}

// Make a polyline (looped or not) into a convex shape.
polyline
polyline_to_convex_hull(polyline line)
{
	polyline hull = {2, line.count, malloc(line.count*sizeof(cpVect))};
	hull.verts[0] = line.verts[0];
	hull.verts[1] = line.verts[1];
	
	for(int i=2; i<line.count; i++)
		hull_push_point(&hull, line.verts[i]);
	
	if(polyline_is_looped(line))
		hull.verts[hull.count++] = hull.verts[0];
	
	return (polyline){hull.count, hull.count, realloc(hull.verts, hull.count*sizeof(cpVect))};
}
