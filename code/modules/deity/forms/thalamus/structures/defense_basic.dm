/datum/deity_power/structure/thalamus/tendril
	name = "Tendril"
	desc = "An upgraded tendril with a large boney spike at the end"
	power_path = /datum/deity_power/structure/thalamus/tendril
	resource_cost = list(
		/datum/deity_resource/thalamus/nutrients = 10
	)

/obj/structure/deity/thalamus/tendril
	name = "tendril"
	desc = ""
	icon_state = "tendril_pulling"
	var/damage = 14
	var/vision_range = 4
	var/datum/proximity_trigger/square/proximity
	var/datum/hostility/hostility = /datum/hostility/lymph_node
	var/obj/item/gun/tentacle_thalamus/tentacle
	var/melee_damage_lower = 25
	var/melee_damage_upper = 25
	var/pulling = TRUE

/obj/structure/deity/thalamus/tendril/Initialize(mapload, datum, owner, health)
	. = ..()
	tentacle = new (src)
	proximity = new(
		src,
		/obj/structure/deity/thalamus/tendril/proc/on_proximity,
		/obj/structure/deity/thalamus/tendril/proc/on_changed_turf_visibility,
		vision_range,
		PROXIMITY_EXCLUDE_HOLDER_TURF,
		src
	)
	hostility = new hostility()
	proximity.register_turfs()

/obj/structure/deity/thalamus/tendril/proc/on_changed_turf_visibility(list/prior_turfs, list/current_turfs)
	if(!length(prior_turfs))
		return

	if(QDELETED(src))
		return

	var/list/turfs_to_check = current_turfs - prior_turfs
	for(var/turf/T as anything in turfs_to_check)
		for(var/atom/movable/AM in T)
			on_proximity(AM)

/obj/structure/deity/thalamus/tendril/proc/on_proximity(atom/movable/AM)
	if(hostility?.can_target(src, AM))
		THROTTLE(shooting_cd, 0.5 SECONDS)
		if(!shooting_cd)
			return

		tentacle_attack(AM)
		var/atom/movable/flick_holder = new /atom/movable(loc)
		flick_holder.anchored = TRUE
		flick_holder.icon = icon
		flick_holder.layer = layer + 0.1
		if(pulling)
			flick_holder.icon_state = "tendril_pulling_flick"
		else
			flick_holder.icon_state = "tendril_pushing_flick"
		sleep(5)
		qdel(flick_holder)

/obj/structure/deity/thalamus/tendril/proc/tentacle_attack(atom/movable/AM)
	tentacle?.Fire(AM, src)

/datum/deity_power/structure/thalamus/tendril_enhanced

/obj/item/gun/tentacle_thalamus
	var/pulling = TRUE
	var/projectile_type = /obj/item/projectile/whip_of_torment

/obj/item/gun/tentacle_thalamus/consume_next_projectile(mob/user = usr)
	var/obj/item/projectile/thalamus_tentacle/P =  new /obj/item/projectile/thalamus_tentacle(src, pulling)
	return(P)

/obj/item/projectile/thalamus_tentacle
	name = "Thalamus Tentacle"
	icon_state = null
	hitscan = TRUE
	impact_on_original = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/tendril
	tracer_type = /obj/effect/projectile/tracer/tendril
	impact_type = /obj/effect/projectile/impact/tendril
	kill_count = 1000
	projectile_light = FALSE
	fire_sound = SFX_THALAMUS_TENDRIL
	var/pulling = TRUE

/obj/item/projectile/thalamus_tentacle/Initialize(mapload, pulling)
	. = ..()
	src.pulling = pulling
	if(!pulling)
		muzzle_type = /obj/effect/projectile/muzzle/tendril/pushing
		tracer_type = /obj/effect/projectile/tracer/tendril/pushing
		impact_type = /obj/effect/projectile/impact/tendril/pushing

/obj/item/projectile/thalamus_tentacle/on_hit(atom/target, blocked, def_zone)
	if(isturf(target))
		return

	var/atom/movable/T = target
	if(pulling)
		var/grab_chance = 100
		if(iscarbon(T))
			var/mob/living/carbon/C = T
			grab_chance -= C.run_armor_check(def_zone)
			if(def_zone == BP_CHEST || def_zone == BP_GROIN) // It is easier to grab limbs with a whip
				grab_chance -= 20
		if(!T.anchored && prob(grab_chance))
			T.throw_at(firer, get_dist(firer, T) - 1, 1)
	else
		if(!T.anchored)
			var/turf/throwback_turf = get_step(target, get_dir(firer, target))
			T.throw_at(throwback_turf, 2, 2, )

	return ..()

/obj/effect/projectile/muzzle/tendril
	icon_state = "muzzle_tendril_pulling"
	light_max_bright = 0

/obj/effect/projectile/muzzle/tendril/pushing
	icon_state = "muzzle_tendril_pushing"

/obj/effect/projectile/tracer/tendril
	icon_state = "tracer_tendril_pulling"
	light_max_bright = 0

/obj/effect/projectile/tracer/tendril/pushing
	icon_state = "tracer_tendril_pushing"

/obj/effect/projectile/impact/tendril
	icon_state = "impact_tendril_pulling"
	light_max_bright = 0

/obj/effect/projectile/impact/tendril/pushing
	icon_state = "impact_tendril_pushing"
