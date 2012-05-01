#include <stdio.h>
#include <stdlib.h>

#include <OpenGL/gl.h>
#include <GLUT/glut.h>

#include "load_image.h"

typedef struct Vertex {
	GLfloat x, y;
} Vertex;

typedef struct Linestrip {
	Vertex *verts;
	int count;
	
	struct Linestrip *next;
} Linestrip;

Linestrip *linestrips = NULL;

GLuint texnum;
int width = 0, height = 0;


static void
display(void)
{
	glClear(GL_COLOR_BUFFER_BIT);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texnum);
	glColor3f(1.0, 1.0, 1.0);
	glBegin(GL_QUADS); {
		glTexCoord2f(0.0, 0.0); glVertex2f(-1.0, -1.0);
		glTexCoord2f(1.0, 0.0); glVertex2f( 1.0, -1.0);
		glTexCoord2f(1.0, 1.0); glVertex2f( 1.0,  1.0);
		glTexCoord2f(0.0, 1.0); glVertex2f(-1.0,  1.0);
	} glEnd();
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(0.0f, width, 0.0f, height);
	
	glDisable(GL_TEXTURE_2D);
	glColor3f(1.0, 0.0, 0.0);
	for(Linestrip *strip=linestrips; strip; strip=strip->next){
		Vertex *verts = strip->verts;
		glBegin(GL_LINE_STRIP); {
			for(int i=0; i<strip->count; i++) glVertex2f(verts[i].x, verts[i].y);
		} glEnd();
	}
	
	glFlush();
}

static GLuint
load_texture(char *filename)
{
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	
	GLuint tex;
	glGenTextures(1, &tex);
	glBindTexture(GL_TEXTURE_2D, tex);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	Image *image = load_image(filename);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image->w, image->h, 0, GL_RGBA, GL_UNSIGNED_BYTE, image->pixels);
	free_image(image);
	
	return tex;
}

static void
initGL(void)
{
	glClearColor(0.5, 0.5, 0.5, 1.0);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	char image_name[1024] = {'\0'};
	scanf("%1023s\n", image_name);
	printf("loading png %s\n", image_name);
	texnum = load_texture(image_name);
	
	for(int count=0; scanf("* %d\n", &count) != EOF;){
		printf("reading strip of length %d\n", count);
		Linestrip *strip = calloc(1, sizeof(Linestrip));
		strip->count = count;
		
		strip->next = linestrips;
		linestrips = strip;
		
		Vertex *verts = strip->verts = calloc(count, sizeof(Vertex));
		for(int i=0; i<count; i++) scanf("%f, %f\n", &verts[i].x, &verts[i].y);
	}
}

int
main(int argc, char *argv[])
{
	scanf("%i, %i\n", &width, &height);
	
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);
	glutInitWindowSize(width, height);
	glutInitWindowPosition(100, 100);
	glutCreateWindow("March Viewer");
	initGL();
	
	glutDisplayFunc(display);
	glutMainLoop();
	
	return 0;
}