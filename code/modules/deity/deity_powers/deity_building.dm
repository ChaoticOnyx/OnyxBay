/mob/living/deity
	var/list/currently_building = list()
	var/list/buildings = list()
	var/construct_speed = 1 // Split up between all constructs
	var/datum/deity_power/selected_power

/mob/living/deity/Destroy()
	for(var/obj/structure/deity/struct in buildings)
		struct.linked_deity = null
		remove_building(struct)

	return ..()

/mob/living/deity/proc/add_building(obj/structure/deity/building)
	if(!istype(building))
		return

	buildings |= building
	if(!building.gives_sight)
		return

	deity_net.add_source(building)

/mob/living/deity/proc/remove_building(obj/structure/building)
	buildings.Remove(building)
	deity_net.remove_source(building)

/mob/living/deity/proc/set_selected_power(datum/deity_power/power_to_select)
	selected_power = power_to_select
	var/datum/hud/deity/D = hud_used
	D.update_selected(selected_power)

/mob/living/deity/proc/get_building_type_amount(type)
	. = 0
	for(var/b in buildings)
		if(istype(b, type))
			.++

/mob/living/deity/proc/get_dist_to_nearest_building(atom/A)
	var/atom/a = get_atom_closest_to_atom(A, buildings)
	if(a)
		. = get_dist(A, a)

/mob/living/deity/proc/get_dist_to_nearest_building_type(target, type)
	var/list/eligible_buildings = list()
	for(var/obj/structure/deity/struct in buildings)
		if(!istype(struct, type))
			continue

		eligible_buildings += struct

	if(!eligible_buildings.len)
		return -1

	var/atom/closest = get_atom_closest_to_atom(target, eligible_buildings)

	return get_dist(target, closest)

/mob/living/deity/Life()
	. = ..()
	if(.)
		if(currently_building.len)
			//var/con_speed = construct_speed / currently_building.len
			for(var/b in currently_building)
				continue

		else if(health < maxHealth) // Not building? Heal ourselves
			health = min(maxHealth, health + construct_speed)

/obj/structure/deity
	var/health = 10
	var/mob/living/deity/linked_deity

	icon = 'icons/obj/cult.dmi'
	var/gives_sight = TRUE

	var/last_click = 0
	var/click_cooldown = 10
	var/activation_cost_resource
	var/activation_cost_amount

	density = TRUE
	anchored = TRUE

/obj/structure/deity/Initialize(mapload, datum, owner, health)
	. = ..()
	if(owner)
		linked_deity = owner
		linked_deity.add_building(src)
	//else
	//	qdel_self()

/obj/structure/deity/Destroy()
	linked_deity?.remove_building(src)
	linked_deity = null
	return ..()

/obj/structure/deity/attackby(obj/item/O, mob/user)
	..()
	take_damage(O.force)

/obj/structure/deity/bullet_act(obj/item/projectile/P)
	take_damage(P.damage)
	..()

/obj/structure/deity/proc/take_damage(damage)
	health -= damage
	if(health <= 0)
		visible_message(SPAN_DANGER("\The [src] is smashed apart!"))
	else
		visible_message(SPAN_DANGER("\the [src] has been hit!"))

/obj/structure/deity/proc/deity_click(mob/living/deity/D)
	if(can_activate(D))
		activate()
		last_click = world.time

/obj/structure/deity/proc/can_activate(mob/living/deity/D, warning = TRUE)
	if(last_click + click_cooldown < world.time && D == linked_deity)
		if(activation_cost_resource && !linked_deity.form.use_resource(activation_cost_resource, activation_cost_amount))
			if(warning)
				to_chat(linked_deity, "<span class='warning'>You need more [activation_cost_resource] to activate \the [src]</span>")
			return FALSE

		return TRUE

	return FALSE

/obj/structure/deity/proc/activate()
	return

/obj/structure/deity/processing

/obj/structure/deity/processing/Initialize()
	. = ..()
	set_next_think(world.time + 5 SECONDS)

/obj/structure/deity/processing/think()
	set_next_think(world.time + 5 SECONDS)

/obj/structure/deity/processing/Destroy()
	set_next_think(0)
	return ..()
