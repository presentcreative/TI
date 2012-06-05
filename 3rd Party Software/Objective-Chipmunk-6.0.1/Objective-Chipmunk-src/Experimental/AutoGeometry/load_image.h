typedef struct Pixel {
	unsigned char r, g, b, a;
} Pixel;

typedef struct Image {
	int w, h;
	Pixel *pixels;
} Image;

Image *load_image(char *name);
void free_image(Image *image);

static inline Pixel get_pixel(Image *image, int x, int y){
  return image->pixels[x + y*image->w];
}
