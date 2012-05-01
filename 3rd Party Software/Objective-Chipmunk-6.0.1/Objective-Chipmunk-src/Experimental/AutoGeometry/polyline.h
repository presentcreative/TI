typedef struct polyline {
  int count, size;
  cpVect *verts;
} polyline;

typedef struct polylines {
  int count, size;
  polyline *lines;
} polylines;

// Create a polyline set. Must be released with polylines_free()
polylines polylines_new();

// Free a polyline.
void polyline_free(polyline line);

// Free a polyline set and all the polylines it references.
void polylines_free(polylines lines);


// Add a line segment to a polyline.
// Use a callback from march_soft() or march_hard() to build a polyline set.
void polylines_collect_segment(cpVect v0, cpVect v1, polylines *lines);

// Returns true if a polyline is a loop
int polyline_is_looped(polyline line);

// Simplify a polyline using a recursive divide and conquer algorithm.
// Works best on curved or irregular shapes.
// The simplified polyline will never be more than 'tol' units from the original input data.
// Returned polyline must be freed using polyline_free().
polyline polyline_simplify_curves(polyline line, cpFloat tol);

// Simplify a polygon by the angle of each vertex.
// Works best on hard edged shapes with straight lines.
// Vertexes that change in angle by less than 'tol' radians are discarded.
// Generally works well as a pre-pass before calling polyline_simplify().
// Returned polyline must be freed using polyline_free().
polyline polyline_simplify_vertexes(polyline line, cpFloat tol);

// Create a convex hull from a polyline.
// Returned polyline must be freed using polyline_free().
polyline polyline_to_convex_hull(polyline line);
