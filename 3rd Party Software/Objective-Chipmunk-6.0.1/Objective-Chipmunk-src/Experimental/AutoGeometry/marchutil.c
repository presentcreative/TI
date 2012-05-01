#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "chipmunk.h"
#include "march.h"
#include "polyline.h"

#include "load_image.h"

static void
print_usage(int error)
{
	printf(
		"Usage: marchutil -image <png filename> -threshold <number> -tolerance <number>\n"
	);
	
	exit(error);
}

static void
print_polyline(polyline line)
{
  cpVect *points = line.verts;
  int count = line.count;
  printf("* %i\n", count);
  
	for(int i=0; i<count; i++){
		cpVect p = points[i];
		printf("%.2f, %.2f\n", p.x, p.y);
	}
	
	printf("\n");
}

// The basic algorithm works by using a sampling function.
// It passes you a coordinate and a pointer.
// You can use this to sample an image of any format or
// a purely mathematical function such as perlin noise if you want to do procedural levels.
static cpFloat
sample_alpha(int x, int y, Image *image)
{
  return 1.0f - get_pixel(image, x, y).a/255.0f;
}

int
main(int argc, char **argv)
{
	if(argc == 1) print_usage(1);
	
	char *image_name = NULL;
	cpFloat threshold = 0.5f;
	cpFloat tolerance = 1.0f;
	
	for(int i=1; i<argc; i++){
		if(strcmp(argv[i], "-image") == 0){
			image_name = argv[++i];
		} else if(strcmp(argv[i], "-threshold") == 0){
			threshold = strtod(argv[++i], NULL);
		} else if(strcmp(argv[i], "-tolerance") == 0){
			tolerance = strtod(argv[++i], NULL);
		} else {
			printf("Unrecognized parameter: '%s'\n", argv[i]);
		}
	}
	
	if(image_name == NULL){
		printf("Error did not specify filname using -image\n");
		print_usage(1);
	}
	
	// Load an image using some Cocoa magic.
	Image *image = load_image(image_name);
	printf("%i, %i\n", image->w, image->h);
	printf("%s\n", image_name);
	
	// Create an empty polyline set, this will be filled in by march_soft().
	polylines lines = polylines_new();
  
  // Trace the image as an anti-aliased (soft) image.
  // Each time the algorithm needs a pixel from the image it
  // will call the sample_alpha() callback passing it the image pointer.
  // Each time it generates a line segment, it will call poly_lines_collect_segment() and pass it the polyline set.
  // Polyline sets are built up one line segment at a time, each added using poly_lines_collect_segment().
  // You can use your own segment callback as well, but there probably isn't a good reason to.
  march_soft(
    250, 200, image->w, image->h, threshold,
    (segment_func)polylines_collect_segment, &lines,
    (sampling_func)sample_alpha, image
  );
  
  for(int i=0; i<lines.count; i++){
  	// march_soft() and march_hard() generate thousands of tiny little line segments each no more than a pixel in length.
  	// Two simplification algorithms are provided that are tuned for curvy and hard edged shapes.
  	polyline simplified = polyline_simplify_curves(lines.lines[i], tolerance);
  	
  	print_polyline(simplified);
  	
  	polyline_free(simplified);
  }
  
	free_image(image);
	polylines_free(lines);
	
	return 0;
}