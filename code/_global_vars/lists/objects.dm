GLOBAL_LIST_EMPTY(active_diseases)
GLOBAL_LIST_EMPTY(med_hud_users)          // List of all entities using a medical HUD.
GLOBAL_LIST_EMPTY(sec_hud_users)          // List of all entities using a security HUD.
GLOBAL_LIST_EMPTY(xeno_hud_users)
GLOBAL_LIST_EMPTY(gland_hud_users)
GLOBAL_LIST_EMPTY(hud_icon_reference)

GLOBAL_LIST_EMPTY(listening_objects) // List of objects that need to be able to hear, used to avoid recursive searching through contents.
GLOBAL_LIST_EMPTY(golems_resonator)
GLOBAL_LIST_EMPTY(global_mutations) // List of hidden mutation things.

GLOBAL_LIST_EMPTY(lizard_colors)

GLOBAL_LIST_EMPTY(reg_dna)

GLOBAL_LIST_EMPTY(global_map)

GLOBAL_LIST_EMPTY(vortex_manipulators)

GLOBAL_LIST_EMPTY(premade_manuals) // List of wiki topics, associated with hardcoded books . Used to find the book by topic, fast, without creating instances.

// Announcer intercom, because too much stuff creates an intercom for one message then hard del()s it. Also headset, for things that should be affected by comms outages.
GLOBAL_DATUM_INIT(global_announcer, /obj/item/device/radio/announcer, new)
GLOBAL_DATUM_INIT(global_headset, /obj/item/device/radio/announcer/subspace, new)
/// Global AI for announcing stuff.
GLOBAL_DATUM(global_ai_announcer, /mob/living/silicon/ai)

var/host = null //only here until check @ code\modules\ghosttrap\trap.dm:112 is fixed
GLOBAL_DATUM_INIT(sun, /datum/sun, new)
GLOBAL_DATUM_INIT(universe, /datum/universal_state, new)

GLOBAL_LIST_EMPTY(intact_station_closets) // List of closets (excluding crates) located on the STATION Z-LEVELS that have never been opened since initialization. Mostly for the Gatecrasher event, but may be useful for more fun thingies.
