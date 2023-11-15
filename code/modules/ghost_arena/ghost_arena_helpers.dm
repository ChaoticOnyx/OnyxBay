/area/ghost_arena
	name = "\improper ghost arena"
	icon_state = "space"
	dynamic_lighting = 0

/obj/effect/landmark/ghost_arena_center
	name = "Ghost Arena Map Spawnpoint"

/obj/effect/landmark/ghost_arena_center/Initialize()
	. = ..()
	SSarena.ghost_arena_centerX = x
	SSarena.ghost_arena_centerY = y
	SSarena.ghost_arena_centerZ = z

/obj/effect/landmark/ghost_arena_spawn/greytide
	name = "Greytide spawn"

/obj/effect/landmark/ghost_arena_spawn/greytide/Initialize()
	. = ..()
	SSarena.ghost_arena_spawns_grey += src

/obj/effect/landmark/ghost_arena_spawn/greytide/Destroy()
	SSarena.ghost_arena_spawns_grey -= src
	return ..()

/obj/effect/landmark/ghost_arena_spawn/security
	name = "Security spawn"

/obj/effect/landmark/ghost_arena_spawn/security/Initialize()
	. = ..()
	SSarena.ghost_arena_spawns_sec += src

/obj/effect/landmark/ghost_arena_spawn/security/Destroy()
	SSarena.ghost_arena_spawns_sec -= src
	return ..()

/obj/effect/landmark/ghost_arena_spawn/Initialize()
	. = ..()
	SSarena.ghost_arena_spawns += src

/obj/effect/landmark/ghost_arena_spawn/Destroy()
	SSarena.ghost_arena_spawns -= src
	return ..()

/datum/ghost_arena_player
	var/kills = 0
	var/deaths = 0
	var/money = 0
	var/gamemode_voted = FALSE
	var/map_voted = FALSE

/datum/ghost_arena_player/New(start_money)
	money = start_money
