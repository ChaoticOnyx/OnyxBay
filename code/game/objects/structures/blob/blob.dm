/obj/structure/blob
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "blob"
	anchored = TRUE

	layer = BLOB_BASE_LAYER

	var/health = BLOB_HEALTH
	var/max_health = BLOB_HEALTH

	var/damage = BLOB_DAMAGE
	
	var/fire_resist = BLOB_FIRE_RESIST
	var/brute_resist = BLOB_BRUTE_RESIST

	var/static/upgrade_tree = BLOB_UPGRADE_TREE

/obj/structure/blob/Initialize()
	. = ..()

	health = max_health
	START_PROCESSING(SSobj, src)

/obj/structure/blob/core/Destroy()
	. = ..()
	
	STOP_PROCESSING(SSobj, src)

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
	var/list/possible_locs = list()
	var/turf/current_loc = loc
	for(var/dir in list(NORTH, EAST, SOUTH, WEST, UP, DOWN))
		var/possible_loc = get_step(src, dir)

		if(dir == UP)
			if(istype(possible_loc, /turf/simulated/open))
				possible_locs += possible_loc
				continue
			
			continue
		
		if(dir == DOWN)
			if(istype(current_loc, /turf/simulated/open))
				possible_locs += possible_loc
				continue
			
			continue

		var/loc_is_not_suitable = istype(possible_loc, /turf/space)\
								|| istype(possible_loc, /turf/simulated/wall)\
								|| (locate(/obj/structure/blob) in possible_loc)

		if(loc_is_not_suitable)
			continue
	
		possible_locs += possible_loc
	
	if(length(possible_locs) == 0)
		return
	
	var/target_loc = pick(possible_locs)
	new /obj/structure/blob(target_loc)

/obj/structure/blob/Process()
	. = ..()
	
	if(!life())
		return TRUE

	THROTTLE(attack_cooldown, BLOB_ATTACK_COOLDOWN)
	THROTTLE(expand_cooldown, BLOB_EXPAND_COOLODNW)
	THROTTLE(upgrade_cooldown, BLOB_UPGRADE_COOLDOWN)
	
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

	if (istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if (W.welding)
			damage += (BLOB_WELDING_BASE_DAMAGE / fire_resist)
			playsound(I, 'sound/items/welder.ogg', 60, TRUE)

	if (I.sharp)
		damage += (BLOB_SHAPR_BASE_DAMAGE / brute_resist)

	if (I.edge)
		damage += (BLOB_EDGE_BASE_DAMAGE / brute_resist)

	if (!I.sharp && !I.edge)
		damage += (BLOB_BLUNT_BASE_DAMAGE / brute_resist)

	health -= damage

/obj/structure/blob/blob_act()
	return

/obj/structure/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = min(0.01 * exposed_temperature / fire_resist, 0)

	if (damage)
		health -= damage
		update_icon()

/obj/structure/blob/ex_act(severity)
	health -= ((BLOB_EXPLOSION_BASE_DAMAGE / brute_resist) - (severity * 5))
	update_icon()

/obj/structure/blob/bullet_act(obj/item/projectile/P)
	..()

	switch(P.damage_type)
		if (BRUTE)
			health -= (P.damage / brute_resist)
		if (BURN)
			health -= (P.damage / fire_resist)

	update_icon()
