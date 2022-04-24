/obj/structure/blob
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "blob"
	anchored = TRUE

	layer = BLOB_BASE_LAYER

	var/health = BLOB_HEALTH
	var/max_health = BLOB_HEALTH

	var/damage = BLOB_DAMAGE

	var/static/upgrade_tree = BLOB_UPGRADE_TREE
	/// Contains the "core" blob.
	/// When that core is dead (deleted) - our blob can't expand anymore.
	/// FIXME: These links prevents the core blob from garbage collecting (somehow even weakrefs doesn't help).
	var/obj/structure/blob/core = null

	var/_attack_cooldown
	var/_expand_cooldown
	var/_upgrade_cooldown
	var/_health_cooldown

/obj/structure/blob/New(loc, obj/structure/blob/core)
	. = ..()

	src.core = core
	health = max_health

	_attack_cooldown  = world.time
	_expand_cooldown  = world.time
	_upgrade_cooldown = world.time
	_health_cooldown  = world.time

/obj/structure/blob/Initialize()
	. = ..()

	START_PROCESSING(SSobj, src)

/obj/structure/blob/proc/can_expand()
	if(QDELETED(core))
		return FALSE

	if(TICK_CHECK)
		return FALSE

	var/dist = get_dist(src, core)
	if(dist > BLOB_MAX_DISTANCE_FROM_CORE)
		var/chance_to_spawn = max(BLOB_MIN_CHANCE_TO_SPAWN, 100 - (dist - BLOB_MAX_DISTANCE_FROM_CORE) * 10)
		if(prob(chance_to_spawn))
			return TRUE

		return FALSE

	return TRUE

/// When a blob is far than `BLOB_EFFICIENT_REGENERATION_DISTANCE` then a distance penalty applies to `BLOB_REGENERATION_MULTIPLIER`.
/obj/structure/blob/proc/heal()
	if(health >= max_health)
		return

	var/distance = get_dist(src, core)
	var/coefficient = BLOB_REGENERATION_MULTIPLIER

	if(distance > BLOB_EFFICIENT_REGENERATION_DISTANCE)
		coefficient = distance / BLOB_EFFICIENT_REGENERATION_DISTANCE / coefficient
		coefficient = max(0.01, coefficient)

	health += max_health * coefficient
	health = min(health, max_health)

/obj/structure/blob/proc/life()
	if(health <= 0)
		die()
		return FALSE

	return TRUE

/obj/structure/blob/proc/attack()
	for(var/atom/A in range(1, src))
		A.blob_act(damage)

/obj/structure/blob/proc/die()
	if(QDELETED(src))
		return

	qdel(src)

/obj/structure/blob/proc/upgrade()
	var/current_type = type
	var/upgrades_for_type = upgrade_tree[current_type]

	for(var/next_type in upgrades_for_type)
		var/chance_to_upgrade = upgrades_for_type[next_type]

		if(!prob(chance_to_upgrade))
			continue

		var/obj/structure/blob/upgraded = new next_type(loc)
		upgraded.health = health
		qdel(src)
		return

/obj/structure/blob/proc/expand()
	if(!can_expand())
		return

	var/list/possible_locs = list()
	var/turf/current_loc = loc
	for(var/dir in list(NORTH, EAST, SOUTH, WEST, UP, DOWN))
		var/possible_loc = get_step(src, dir)
		var/loc_is_not_suitable = istype(possible_loc, /turf/space)\
								|| istype(possible_loc, /turf/simulated/wall)\
								|| istype(possible_loc, /turf/simulated/mineral)\
								|| (locate(/obj/structure/blob) in possible_loc)

		if(dir == UP)
			loc_is_not_suitable = loc_is_not_suitable || !istype(possible_loc, /turf/simulated/open)
		else if(dir == DOWN)
			loc_is_not_suitable = loc_is_not_suitable || !istype(current_loc, /turf/simulated/open)

		if(loc_is_not_suitable)
			continue

		possible_locs += possible_loc

	if(length(possible_locs) == 0)
		return

	var/target_loc = pick(possible_locs)
	var/obj/structure/blob/new_blob = new /obj/structure/blob(target_loc, core)
	new_blob.health = new_blob.max_health / 2

/obj/structure/blob/Process()
	. = ..()

	if(!life())
		return TRUE

	THROTTLE_SHARED(attack_cooldown, BLOB_ATTACK_COOLDOWN, _attack_cooldown)
	THROTTLE_SHARED(expand_cooldown, BLOB_EXPAND_COOLODNW, _expand_cooldown)
	THROTTLE_SHARED(upgrade_cooldown, BLOB_UPGRADE_COOLDOWN, _upgrade_cooldown)
	THROTTLE_SHARED(health_cooldown, BLOB_HEAL_COOLDOWN, _health_cooldown)

	if(health_cooldown)
		heal()

	if(attack_cooldown)
		attack()

	if(expand_cooldown && prob(BLOB_EXPAND_CHANCE))
		expand()

	if(upgrade_cooldown && prob(BLOB_UPGRADE_CHANCE))
		upgrade()

	return TRUE

/obj/structure/blob/update_icon()
	var/hurt_percentage = round(health / max_health * 100)

	if(hurt_percentage <= 50)
		icon_state = "blob_damaged"
	else
		icon_state = initial(icon_state)

/obj/structure/blob/attackby(obj/item/I, mob/user)
	. = ..()

	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	var/damage = 0

	if (istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/W = I

		if (W.welding)
			damage += BLOB_WELDING_BASE_DAMAGE
			playsound(I, 'sound/items/welder.ogg', 60, TRUE)

	if (I.sharp)
		damage += BLOB_SHAPR_BASE_DAMAGE

	if (I.edge)
		damage += BLOB_EDGE_BASE_DAMAGE

	if (!I.sharp && !I.edge)
		damage += BLOB_BLUNT_BASE_DAMAGE

	health -= min(damage, BLOB_DAMAGE_CAP)

/obj/structure/blob/blob_act()
	return

/obj/structure/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = min(0.01 * exposed_temperature, 0)

	if (damage)
		health -= damage
		update_icon()

/obj/structure/blob/flamer_fire_act(burnlevel)
	health -= min(burnlevel * 2.5, BLOB_DAMAGE_CAP)
	update_icon()

/obj/structure/blob/ex_act(severity)
	health -= min(BLOB_EXPLOSION_BASE_DAMAGE - (severity * 5), BLOB_DAMAGE_CAP)
	update_icon()

/obj/structure/blob/bullet_act(obj/item/projectile/P)
	..()

	health -= min(P.damage, BLOB_DAMAGE_CAP)
	update_icon()

/obj/structure/blob/Crossed(O)
	. = ..()

	var/obj/item/projectile/P = O
	if(!istype(P))
		return

	bullet_act(P)
