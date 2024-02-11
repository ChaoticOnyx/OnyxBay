#if !defined(USING_MAP_DATUM)

	#include "exodus_areas.dm"
	#include "exodus_effects.dm"
	#include "exodus_holodecks.dm"
	#include "exodus_shuttles.dm"
	#include "exodus_jobs.dm"

	#define USING_MAP_DATUM /datum/map/exodus

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Exodus

#endif
