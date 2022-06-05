//defines that give qdel hints. these can be given as a return in destory() or by calling

#define QDEL_HINT_QUEUE 		0 //qdel should queue the object for deletion.
#define QDEL_HINT_LETMELIVE		1 //qdel should let the object live after calling destory.
#define QDEL_HINT_IWILLGC		2 //functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
#define QDEL_HINT_HARDDEL		3 //qdel should assume this object won't gc, and queue a hard delete using a hard reference.
#define QDEL_HINT_HARDDEL_NOW	4 //qdel should assume this object won't gc, and hard del it post haste.
#define QDEL_HINT_FINDREFERENCE	5 //functionally identical to QDEL_HINT_QUEUE if TESTING is not enabled in _compiler_options.dm.
								  //if TESTING is enabled, qdel will call this object's find_references() verb.
#define QDEL_HINT_IFFAIL_FINDREFERENCE 6		//Above but only if gc fails.
//defines for the gc_destroyed var

#define GC_QUEUE_FILTER 1 //! short queue to filter out quick gc successes so they don't hang around in the main queue for 5 minutes
#define GC_QUEUE_CHECK 2 //! main queue that waits 5 minutes because thats the longest byond can hold a reference to our shit.
#define GC_QUEUE_HARDDELETE 3 //! short queue for things that hard delete instead of going thru the gc subsystem, this is purely so if they *can* softdelete, they will soft delete rather then wasting time with a hard delete.
#define GC_QUEUE_COUNT 3 //! Number of queues, used for allocating the nested lists. Don't forget to increase this if you add a new queue stage

#define GC_QUEUED_FOR_QUEUING -1
#define GC_QUEUED_FOR_HARD_DEL -2
#define GC_CURRENTLY_BEING_QDELETED -3

// Defines for the time an item has to get its reference cleaned before it fails the queue and moves to the next.
#define GC_FILTER_QUEUE 1 SECONDS
#define GC_CHECK_QUEUE 5 MINUTES
#define GC_DEL_QUEUE 10 SECONDS

#define QDELING(X) (X.gc_destroyed)
#define QDELETED(X) (!X || QDELING(X))
#define QDESTROYING(X) (!X || X.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)

#define QDEL_NULL(x) if(x) { qdel(x) ; x = null }
#define QDEL_LIST(L) if(L) { for(var/I in L) qdel(I); L.Cut(); }
#define QDEL_NULL_LIST(x) if(x) { for(var/y in x) { qdel(y) } ; x = null }
#define QDEL_IN(item, time) addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, time > GC_FILTER_QUEUE ? weakref(item) : item), time, TIMER_STOPPABLE)
#define QDEL_LIST_ASSOC(L) if(L) { for(var/I in L) { qdel(L[I]); qdel(I); } L.Cut(); }
#define QDEL_LIST_ASSOC_VAL(L) if(L) { for(var/I in L) qdel(L[I]); L.Cut(); }
