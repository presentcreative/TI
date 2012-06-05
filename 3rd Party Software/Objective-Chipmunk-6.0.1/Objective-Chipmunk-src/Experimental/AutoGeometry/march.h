// Function type used as a callback from the marching squares algorithm to sample an image function.
typedef cpFloat (*sampling_func)(int x, int y, void *data);

// Function type used as a callback from the marching squares algorithm to output a line segment.
typedef void (*segment_func)(cpVect v0, cpVect v1, void *data);

// Trace an anti-aliased contour of an image along a particular threshold.
void march_soft(
  int x1, int y1, int x2, int y2, cpFloat threshold,
  segment_func segment, void *segment_data,
  sampling_func sample, void *sample_data
);

// Trace an aliased curve of an image along a particular threshold.
void march_hard(
  int x1, int y1, int x2, int y2, cpFloat threshold,
  segment_func segment, void *segment_data,
  sampling_func sample, void *sample_data
);
