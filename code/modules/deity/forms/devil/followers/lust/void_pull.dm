#define SPELL_CAST_DURATION 6
#define SPELL_CAST_INTERVAL 0.5 SECONDS

/datum/action/cooldown/spell/aoe/void_pull
	name = "Void Pull"
	cooldown_time = 40 SECONDS
	button_icon_state = "devil_void_pull"
	aoe_radius = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

/datum/action/cooldown/spell/aoe/void_pull/cast(atom/target)
	var/obj/effect/voidin = new /obj/effect/voidin(get_turf(target))
	var/list/atom/things_to_cast_on = get_things_to_cast_on(target)

	var/spell_duration = 0
	while(do_after(owner, SPELL_CAST_INTERVAL, target = target, can_move = FALSE) && spell_duration < SPELL_CAST_DURATION)
		if(!(spell_duration % 2))
			playsound(get_turf(target), 'sound/magic/air_whistling.ogg', 100, FALSE)
		for(var/thing_to_target in things_to_cast_on)
			cast_on_thing_in_aoe(thing_to_target, target)
		spell_duration++

	qdel(voidin)

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center)
	var/list/things = list()
	// Default behavior is to get all atoms in range, center and owner not included.
	for(var/mob/living/nearby_thing in range(aoe_radius, center))
		if(nearby_thing == owner)
			continue

		things += nearby_thing

	return things

// For the actual cast, we microstun people nearby and pull them in
/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/target)
	// If the victim's within the stun radius, they're stunned / knocked down
	if(get_dist(victim, target) < stun_radius)
		victim.AdjustParalysis(5)
		victim.AdjustWeakened(5)

	// Otherwise, they take a few steps closer
	victim.forceMove(get_step_towards(victim, target))

/obj/effect/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	pixel_x = -32
	pixel_y = -32
	var/obj/effect/effect/warp/voidpull/warp

/obj/effect/voidin/Initialize(mapload)
	. = ..()
	warp = new /obj/effect/effect/warp/voidpull(get_turf(src))
	QDEL_IN(src, 5 SECONDS)
	return ..()

/obj/effect/voidin/Destroy()
	QDEL_NULL(warp)
	return ..()

/obj/effect/effect/warp/voidpull
	icon = 'icons/effects/160x160.dmi'
	icon_state = "singularity_s5"
	anchored = TRUE
	plane = WARP_EFFECT_PLANE
	appearance_flags = PIXEL_SCALE
	pixel_x = -64
	pixel_y = -64

#undef SPELL_CAST_DURATION
#undef SPELL_CAST_INTERVAL
