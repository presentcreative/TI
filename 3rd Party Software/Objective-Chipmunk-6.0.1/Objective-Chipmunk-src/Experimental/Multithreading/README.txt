This patch provides a very rough set of changes to enable a multithreaded solver in Chipmunk. For complex simulations with lots of stacking, you could see as much as a 50% speedup. It currently is hard coded to use two threads and ovewrites the cpSpace code.

To apply this patch run this on the command line:

cd <something>/Objective-Chipmunk-1.2.3/Chipmunk
patch -p0 -i ../Experimental/Multithreading/solver.patch


I'm also working on a multi-threaded collision detection algorithm based on a single axis sort and sweep. This algorithm can be very fast and is easy to parallellize, but it only works well when your objects are mostly spaced out over a single axis like racing games. My first attempt to integrate this with Chipmunk was actually slower than the non-threaded version because of the way I was performing the locking. I haven't had time for a second attempt yet. Also, because the algorithm used is not as general as Chipmunk's bounding box tree, there won't be a performance boost for all types of games.

Lastly, I have plans for a simple lockless data structure that will allow you to run Chipmunk and your rendering in separate threads. This should provide a good performance boost to all Chipmunk games even on single CPU devices.

What's left to be done?
* Make a separate cpSpaceThreaded type.
* Finish the collision detection algorithm.
* Finish the Chipmunk/rendering data structure.
* Integrate it as seemlessly as possible with Objective-Chipmunk.

When will it be released officially?
Hopefully by the end of summer 2011.