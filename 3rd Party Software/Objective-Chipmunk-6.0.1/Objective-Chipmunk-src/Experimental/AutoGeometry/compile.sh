gcc -arch i386 -std=c99 -g -I ../../../Chipmunk/include/chipmunk marchutil.c load_image.m march.c polyline.c -framework Cocoa -o marchutil
gcc -arch i386 -std=c99 -g -I ../../../Chipmunk/include/chipmunk marchview.c load_image.m -framework Cocoa -framework OpenGL -framework GLUT -o marchview
./marchutil -image blobs.png -threshold 0.5 -tolerance 1 | ./marchview
