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

/obj/effect/acid/New(loc, supplied_target)
	..(loc)
	target = supplied_target
	melt_time = melt_time / acid_strength
	desc += "\n<b>It's melting \the [target]!</b>"
	pixel_x = target.pixel_x
	pixel_y = target.pixel_y
	set_next_think(world.time)

/obj/effect/acid/Destroy()
	target = null
	. = ..()

/obj/effect/acid/think()
	if(QDELETED(target))
		qdel(src)
		return

	var/done_melt = target.acid_melt()

	if(done_melt)
		qdel(src)
		return

	set_next_think(world.time + melt_time)

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

/obj/structure/alien/egg
	desc = "It looks like a weird egg."
	name = "egg"
	icon_state = "egg_growing"
	density = 0
	anchored = 1
	var/progress = 0
	var/progress_max = 75 // Point at which we can harvest it manually; hatches autimatically at progress_max*2

/obj/structure/alien/egg/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/alien/egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/alien/egg/Process()
	progress++
	if(progress >= progress_max*2)
		hatch()

/obj/structure/alien/egg/attack_hand(mob/user)
	if(progress == -1)
		return ..()
	if(!isliving(user))
		return ..()
	var/mob/living/M = user
	if(progress < progress_max)
		if(M.faction != "xenomorph")
			to_chat(M, "You touch \the [src].")
		else
			to_chat(M, "<span class='alium'>\The [src] is not ready to hatch yet.</alium>")
		return
	if(M.faction != "xenomorph")
		to_chat(M, "You touch \the [src]... And it starts moving.")
	else
		to_chat(M, "<span class='alium'>You caress \the [src] as it hatches at your command.</alium>")
	hatch()

/obj/structure/alien/egg/_examine_text(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/M = user
		if(M.faction == "xenomorph")
			if(progress < progress_max)
				. += "\nIt's not ready to hatch yet..."
			else
				. += "\nIt's ready to hatch!"

/obj/structure/alien/egg/update_icon()
	if(progress == -1)
		icon_state = "egg_opened"
	else if(progress < progress_max)
		icon_state = "egg_growing"
	else
		icon_state = "egg"

/obj/structure/alien/egg/proc/hatch()
	set waitfor = 0

	progress = -1
	STOP_PROCESSING(SSobj, src)
	update_icon()
	flick("egg_opening", src)
	sleep(5)
	if(get_turf(src))
		new /mob/living/simple_animal/hostile/facehugger(get_turf(src))

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
