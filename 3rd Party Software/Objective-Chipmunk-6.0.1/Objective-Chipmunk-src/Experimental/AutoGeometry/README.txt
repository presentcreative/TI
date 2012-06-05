The AutoGeometry module for Chipmunk-Pro will allow you to easily and efficiently vectorize image masks. Currently it can generate simplified polylines or convex hulls, but doesn't yet handle decomposing concave shapes. It provides functions for tracing soft images such as anti-aliased image masks and hard images such as tile maps. Because it works using a sampling function, you could even sample procedural data such as perlin noise!

How do I use it?
I've provided a sample command line program that uses it to dump simplified vector outlines out as text. You can use this to generate collision outlines for your levels if you want. Run it like this:

./marchutil -image blobs.png -threshold 0.5 -tolerance 1.0 > vector_outlines.txt

This will vectorize blobs.png along the 50% alpha contour and simplify the curves so that they are within 1.0 pixel of the real contour. See marchutil.c for the output format.

If you want to see it you can run this:

./marchutil < vector_outlines.txt

Currently there is only a low level C API, but you can use it at runtime by including march.c/h and polyline.c/h in your project. See marchutil.c for an example of how to use it.

What's left to be done?
* Support for tiling. This would allow you to vectorize just one part of an image at a time. You could implement very efficient destructable terrain this way.
* Objective-C API that can easily work with CGImages or texture data.
* Faster convex hull algorithm.
* Approximate convex decomposition to break down concave shapes into simple convex ones.
* Examples!

When will it be released officially?
I'm hoping to have it done by the end of summer 2011.