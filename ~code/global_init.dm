/*
	The initialization of the game happens roughly like this:
	1. All global variables are initialized (including the global_init instance$
	2. The map is initialized, and map objects are created.
	3. world/New() runs, creating the process scheduler (and the old master con$
	4. processScheduler/setup() runs, creating all the processes. game_controll$
	5. The gameticker is created.
*/

var/global/datum/global_init/init = new ()

/*
	Pre-map initialization stuff should go here.
*/
/datum/global_init/New()
	callHook("global_init")

	// kept out of a hook to preserve call order
	initialize_chemical_reactions()


	qdel(src) //we're done

// This dumb shit must be wiped out of existence as soon as possible
// Not worth trying to make it properly qdelable since it's not designed to be so, just let it be
// Maintaining 2015 code in the year 2022 is pure suffering.
/datum/global_init/Destroy()
	. = ..()
	return QDEL_HINT_LETMELIVE
