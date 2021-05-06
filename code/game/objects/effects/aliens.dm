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

	density = 0
	opacity = 0
	anchored = 1

	var/atom/target
	var/acid_strength = ACID_WEAK
	var/melt_time = 10 SECONDS
	var/last_melt = 0

/obj/effect/acid/New(loc, supplied_target)
	..(loc)
	target = supplied_target
	melt_time = melt_time / acid_strength
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


#define MAX_PROGRESS 100

/obj/structure/alien/egg
	desc = "It looks like a weird egg."
	name = "egg"
	icon_state = "egg_growing"
	density = 0
	anchored = 1
	var/progress = 0

/obj/structure/alien/egg/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/alien/egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/alien/egg/CanUseTopic(mob/user)
	return isghost(user) ? STATUS_INTERACTIVE : STATUS_CLOSE

/obj/structure/alien/egg/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["spawn"])
		attack_ghost(usr)

/obj/structure/alien/egg/Process()
	progress++
	if(progress >= MAX_PROGRESS)
		for(var/mob/observer/ghost/O in GLOB.ghost_mob_list)
			if(O.client && O.client.prefs && (MODE_XENOMORPH in O.client.prefs.be_special_role))
				to_chat(O, "<span class='notice'>An alien is ready to hatch! ([ghost_follow_link(src, O)]) (<a href='byond://?src=\ref[src];spawn=1'>spawn</a>)</span>")
		STOP_PROCESSING(SSobj, src)
		update_icon()

/obj/structure/alien/egg/update_icon()
	if(progress == -1)
		icon_state = "egg_hatched"
	else if(progress < MAX_PROGRESS)
		icon_state = "egg_growing"
	else
		icon_state = "egg"

/obj/structure/alien/egg/attack_ghost(mob/observer/ghost/user)
	if(progress == -1) //Egg has been hatched
		return

	if(progress < MAX_PROGRESS)
		to_chat(user, "\The [src] has not yet matured.")
		return

	if(!user.MayRespawn(1))
		return

	// Check for bans properly.
	if(jobban_isbanned(user, MODE_XENOMORPH))
		to_chat(user, "<span class='danger'>You are banned from playing a Xenophage.</span>")
		return

	var/confirm = alert(user, "Are you sure you want to join as a Xenophage larva?", "Become Larva", "No", "Yes")

	if(!src || confirm != "Yes")
		return

	if(!user || !user.ckey)
		return

	if(progress == -1) //Egg has been hatched.
		to_chat(user, "Too slow...")
		return

	flick("egg_opening",src)
	progress = -1 // No harvesting pls.
	sleep(5)

	if(!src || !user)
		visible_message("<span class='alium'>\The [src] writhes with internal motion, but nothing comes out.</span>")
		progress = MAX_PROGRESS // Someone else can have a go.
		return // What a pain.

	// Create the mob, transfer over key.
	var/mob/living/carbon/alien/larva/larva = new(get_turf(src))
	larva.ckey = user.ckey
	GLOB.xenomorphs.add_antagonist(larva.mind, 1)
	spawn(-1)
		if(user)
			qdel(user) // Remove the keyless ghost if it exists.
	visible_message("<span class='alium'>\The [src] splits open with a wet slithering noise, and \the [larva] writhes free!</span>")

	// Turn us into a hatched egg.
	name = "hatched alien egg"
	desc += " This one has hatched."
	update_icon()

#undef MAX_PROGRESS

/*
 * Weeds
 */
#define NODERANGE 3

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
	light_range = NODERANGE
	var/node_range = NODERANGE

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

	direction_loop:
		for(var/dirn in GLOB.cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/effect/alien/weeds) in T || istype(T, /turf/space))
				continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

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

/obj/effect/alien/weeds/attackby(obj/item/weapon/W, mob/user)
	if(W.attack_verb.len)
		visible_message("<span class='danger'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
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

#undef NODERANGE
