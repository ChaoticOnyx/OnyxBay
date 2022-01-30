/*
 * Acid
 */
 #define ACID_STRONG     2
 #define ACID_MODERATE   1.5
 #define ACID_WEAK       1

/obj/effect/acid
	name = "acid"
	desc = "Burbling corrosive stuff. Probably a bad idea to roll around in it."
	icon_state = "acid"
	icon = 'icons/mob/alien.dmi'

	density = FALSE
	opacity = FALSE
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER

	var/atom/target
	var/acid_strength = ACID_WEAK
	var/melt_time = 10 SECONDS
	var/last_melt = 0

/obj/effect/acid/New(loc, supplied_target)
	..(loc)
	target = supplied_target
	melt_time = melt_time / acid_strength
	desc += "\n<b>It's melting \the [target]!</b>"
	pixel_x = target.pixel_x
	pixel_y = target.pixel_y
	START_PROCESSING(SSprocessing, src)

/obj/effect/acid/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	target = null
	. = ..()

/obj/effect/acid/Process()
	if(QDELETED(target))
		qdel(src)
	else if(world.time > last_melt + melt_time)
		var/done_melt = target.acid_melt()
		last_melt = world.time
		if(done_melt)
			qdel(src)

/atom/var/acid_melted = 0

/atom/proc/acid_melt()
	. = FALSE
	switch(acid_melted)
		if(0)
			visible_message("<span class='alium'>Acid hits \the [src] with a sizzle!</span>")
		if(1 to 3)
			visible_message("<span class='alium'>The acid melts \the [src]!</span>")
		if(4)
			visible_message("<span class='alium'>The acid melts \the [src] away into nothing!</span>")
			. = TRUE
			qdel(src)
	acid_melted++

/*
 * Egg
 */

// Just a decoration with no actual use.
/obj/structure/alien/egg
	desc = "It looks like a weird egg. You feel like it might be dangerous in a galaxy far away, at the times long gone."
	name = "egg"
	icon_state = "egg_growing"
	density = 0
	anchored = 1

/*
 * Weeds
 */
/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird purple weeds."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weeds"

	anchored = 1
	density = 0
	plane = FLOOR_PLANE
	layer = ABOVE_TILE_LAYER
	var/obj/effect/alien/weeds/node/linked_node = null

/obj/effect/alien/weeds/node
	icon_state = "weednode"
	name = "purple sac"
	desc = "Weird purple octopus-like thing."
	layer = ABOVE_TILE_LAYER + 0.01
	var/node_range = 3

/obj/effect/alien/weeds/node/New()
	..(src.loc, src)

/obj/effect/alien/weeds/New(pos, node)
	..()
	if(istype(loc, /turf/space))
		qdel(src)
		return
	linked_node = node
	if(icon_state == "weeds")
		icon_state = pick("weeds", "weeds1", "weeds2")
	spawn(rand(150, 200))
		if(src)
			Life()
	return

/obj/effect/alien/weeds/proc/Life()
	set background = 1
	var/turf/U = get_turf(src)

	if (istype(U, /turf/space))
		qdel(src)
		return

	if(!linked_node || (get_dist(linked_node, src) > linked_node.node_range) )
		return

	for(var/dirn in GLOB.cardinal)
		var/turf/T = get_step(src, dirn)

		if(!istype(T) || T.density || (locate(/obj/effect/alien/weeds) in T) || istype(T, /turf/space))
			continue

		var/turf_eligible = TRUE
		var/atom/previous_loc = get_step(src, get_dir(src, linked_node))
		for(var/obj/O in T)
			if(istype(O, /obj/structure/window))
				if(!O.CanPass(src, previous_loc))
					turf_eligible = FALSE
					break
			if(!O.CanZASPass(previous_loc)) // So it will grow through the stuff like consoles and disposal units, but will get blocked by airlocks and inflatable walls
				turf_eligible = FALSE
				break

		if(turf_eligible)
			new /obj/effect/alien/weeds(T, linked_node)


/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
		if(3.0)
			if(prob(5))
				qdel(src)
	return

/obj/effect/alien/weeds/attackby(obj/item/W, mob/user)
	if(W.attack_verb.len)
		visible_message("<span class='danger'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")

	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			qdel(src)
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	else
		if(prob(50))
			qdel(src)

/obj/effect/alien/weeds/attack_generic(mob/user, damage, attack_verb)
	visible_message("<span class='danger'>[user] [attack_verb] the [src]!</span>")
	user.do_attack_animation(src)
	if(prob(50 + damage))
		qdel(src)
	return


/obj/effect/alien/weeds/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300 + T0C && prob(80))
		qdel(src)
