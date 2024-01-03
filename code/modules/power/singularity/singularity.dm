/obj/singularity
	name = "gravitational singularity"
	desc = "A gravitational singularity."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	anchored = 1
	density = 1
	layer = SINGULARITY_LAYER
	light_outer_range = 6
	unacidable = 1 //Don't comment this out.

	var/current_size = 1
	var/allowed_size = 1
	var/energy = 100 // How strong are we?
	var/dissipate = 1 // Do we lose energy over time?
	var/dissipate_delay = 10
	var/dissipate_track = 0
	var/dissipate_strength = 1 // How much energy do we lose?
	var/move_self = 1 // Do we move on our own?
	var/grav_pull = 4 // How many tiles out do we pull?
	var/consume_range = 0 // How many tiles out do we eat.
	var/event_chance = 15 // Prob for event each tick.
	var/target = null // Its target. Moves towards the target if it has one.
	var/last_failed_movement = 0 // Will not move in the same dir if it couldnt before, will help with the getting stuck on fields thing.
	var/last_warning

	var/chained = 0// Adminbus chain-grab

	var/create_childs = TRUE // if true - creates a dummy-singularity for each connected Z-level
	var/list/obj/singularity/child/childs = list()

	var/follows_ghosts = FALSE
	var/picking_coldown = 0
	var/mob/observer/ghost/the_chosen = null
	var/mob/observer/ghost/prev_ghost = null

	var/datum/radiation_source/pulse_source

/obj/singularity/New(loc, starting_energy = 50, temp = 0)
	//CARN: admin-alert for chuckle-fuckery.
	admin_investigate_setup()
	energy = starting_energy

	if(temp)
		spawn(temp)
			qdel(src)

	..()
	set_next_think(world.time)
	for(var/obj/machinery/power/singularity_beacon/singubeacon in SSmachines.machinery)
		if(singubeacon.active)
			target = singubeacon
			break

	if(create_childs)
		create_childs()

/obj/singularity/Destroy()
	if(!QDELETED(pulse_source))
		qdel(pulse_source)

	for(var/obj/singularity/child/SC in childs)
		childs -= SC
		if(!QDELETED(SC))
			qdel(SC)
	return ..()

/obj/singularity/proc/create_childs()
	for(var/obj/singularity/child/SC in childs)
		childs -= SC
		SC.parent = null
		qdel(SC)

	for(level in (GetConnectedZlevels(z) - z))
		var/obj/singularity/child/SC = new (locate(x, y, level), src, level)
		childs += SC

/obj/singularity/attack_hand(mob/user)
	consume(user)
	return 1

/obj/singularity/ex_act(severity)
	if(current_size == STAGE_SUPER)//IT'S UNSTOPPABLE
		return
	switch(severity)
		if(1.0)
			if(prob(25))
				investigate_log("has been destroyed by an explosion.", I_SINGULO)
				qdel(src)
				return
			else
				energy += 50
		if(2.0 to 3.0)
			energy += round((rand(20, 60) / 2), 1)
			return

/obj/singularity/bullet_act(obj/item/projectile/P)
	return 0 //Will there be an impact? Who knows. Will we see it? No.

/obj/singularity/Bump(atom/A)
	consume(A)

/obj/singularity/Bumped(atom/A)
	consume(A)

/obj/singularity/touch_map_edge()
	var/old_z = z
	..()
	if(old_z != z && create_childs)
		create_childs()

/obj/singularity/think()
	eat()
	dissipate()
	check_energy()

	if(current_size >= STAGE_TWO)
		move()

		if(QDELETED(pulse_source))
			pulse_source = SSradiation.radiate(src, new /datum/radiation/preset/hawking)

		pulse_source.update_energy((energy / 50) * HAWKING_RAY_ENERGY)

		if(prob(event_chance)) //Chance for it to run a special event TODO: Come up with one or two more that fit.
			event()
	else
		if(!QDELETED(pulse_source))
			qdel(pulse_source)

	if(follows_ghosts && picking_coldown <= world.time)
		if(!target)
			pick_ghost()

	set_next_think(world.time + 1 SECOND)

/obj/singularity/proc/pick_ghost()
	picking_coldown = world.time + 20 SECONDS

	var/zlevels = GetConnectedZlevels(z)
	for(var/mob/observer/ghost/G in shuffle(GLOB.ghost_mob_list))
		if(!G.client)
			continue
		if(G == prev_ghost)
			continue
		if(G.z in zlevels)
			the_chosen = G
			break

/obj/singularity/proc/stop_following()
	picking_coldown = world.time + 40 SECONDS

	prev_ghost = the_chosen
	the_chosen = null

/obj/singularity/attack_ai() //To prevent ais from gibbing themselves when they click on one.
	return

/obj/singularity/proc/admin_investigate_setup()
	last_warning = world.time
	var/count = locate(/obj/machinery/containment_field) in orange(30, src)

	if(!count)
		message_admins("A singulo has been created without containment fields active ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>).")

	investigate_log("was created. [count ? "" : "<font color='red'>No containment fields were active.</font>"]", I_SINGULO)

/obj/singularity/proc/dissipate()
	if(!dissipate)
		return

	if(dissipate_track >= dissipate_delay)
		energy -= dissipate_strength
		dissipate_track = 0
	else
		dissipate_track++

/obj/singularity/proc/expand(force_size = 0, growing = 1)
	if(current_size == STAGE_SUPER)//if this is happening, this is an error
		message_admins("expand() was called on a super singulo. This should not happen. Contact a coder immediately!")
		return

	var/temp_allowed_size = allowed_size

	if(force_size)
		temp_allowed_size = force_size

	switch(temp_allowed_size)
		if(STAGE_ONE)
			SetName("gravitational singularity")
			desc = "A gravitational singularity."
			current_size = STAGE_ONE
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			pixel_x = 0
			pixel_y = 0
			grav_pull = 4
			consume_range = 0
			dissipate_delay = 10
			dissipate_track = 0
			dissipate_strength = 1
			ClearOverlays()
			follows_ghosts = FALSE
			the_chosen = null
			if(chained)
				SetOverlays("chain_s1")
			visible_message(SPAN("notice", "The singularity has shrunk to a rather pitiful size."))

		if(STAGE_TWO) // 1 to 3 does not check for the turfs if you put the gens right next to a 1x1 then its going to eat them.
			SetName("gravitational singularity")
			desc = "A gravitational singularity."
			current_size = STAGE_TWO
			icon = 'icons/effects/96x96.dmi'
			icon_state = "singularity_s3"
			pixel_x = -32
			pixel_y = -32
			grav_pull = 6
			consume_range = 1
			dissipate_delay = 5
			dissipate_track = 0
			dissipate_strength = 5
			ClearOverlays()
			follows_ghosts = FALSE
			the_chosen = null
			if(chained)
				SetOverlays("chain_s3")
			if(growing)
				visible_message(SPAN("notice", "The singularity noticeably grows in size."))
			else
				visible_message(SPAN("notice", "The singularity has shrunk to a less powerful size."))

		if(STAGE_THREE)
			if(can_expand(step_size = 2))
				SetName("gravitational singularity")
				desc = "A gravitational singularity."
				current_size = STAGE_THREE
				icon = 'icons/effects/160x160.dmi'
				icon_state = "singularity_s5"
				pixel_x = -64
				pixel_y = -64
				grav_pull = 8
				consume_range = 2
				dissipate_delay = 4
				dissipate_track = 0
				dissipate_strength = 20
				ClearOverlays()
				follows_ghosts = FALSE
				the_chosen = null
				if(chained)
					SetOverlays("chain_s5")
				if(growing)
					visible_message(SPAN("notice", "The singularity expands to a reasonable size."))
				else
					visible_message(SPAN("notice", "The singularity has returned to a safe size."))

		if(STAGE_FOUR)
			if(can_expand(step_size = 3))
				SetName("gravitational singularity")
				desc = "A gravitational singularity."
				current_size = STAGE_FOUR
				icon = 'icons/effects/224x224.dmi'
				icon_state = "singularity_s7"
				pixel_x = -96
				pixel_y = -96
				grav_pull = 10
				consume_range = 3
				dissipate_delay = 10
				dissipate_track = 0
				dissipate_strength = 10
				ClearOverlays()
				follows_ghosts = FALSE
				the_chosen = null
				if(chained)
					SetOverlays("chain_s7")
				if(growing)
					visible_message(SPAN("warning", "The singularity expands to a dangerous size."))
				else
					visible_message(SPAN("notice", "Miraculously, the singularity reduces in size, and can be contained."))

		if(STAGE_FIVE) // This one also lacks a check for gens because it eats everything.
			SetName("gravitational singularity")
			desc = "A gravitational singularity."
			current_size = STAGE_FIVE
			icon = 'icons/effects/288x288.dmi'
			icon_state = "singularity_s9"
			pixel_x = -128
			pixel_y = -128
			grav_pull = 10
			consume_range = 4
			dissipate = 0 // It cant go smaller due to e loss.
			ClearOverlays()
			if(!config.misc.forbid_singulo_following)
				follows_ghosts = TRUE
			if(chained)
				SetOverlays("chain_s9")
			if(growing)
				visible_message(SPAN("danger", "<font size='2'>The singularity has grown out of control!</font>"))
			else
				visible_message(SPAN("warning", "The singularity miraculously reduces in size and loses its supermatter properties."))

		if(STAGE_SUPER)// SUPERSINGULO
			SetName("super gravitational singularity")
			desc = "A gravitational singularity with the properties of supermatter. <b>It has the power to destroy worlds.</b>"
			current_size = STAGE_SUPER
			icon = 'icons/effects/352x352.dmi'
			icon_state = "singularity_s11"//uh, whoever drew that, you know that black holes are supposed to look dark right? What's this, the clown's singulo?
			pixel_x = -160
			pixel_y = -160
			grav_pull = 16
			consume_range = 5
			dissipate = 0 // It cant go smaller due to e loss
			event_chance = 25 // Events will fire off more often.
			if(!config.misc.forbid_singulo_following)
				follows_ghosts = TRUE
			if(chained)
				SetOverlays("chain_s9")
			visible_message(SPAN("sinister", "<font size='3'>You witness the creation of a destructive force that cannot possibly be stopped by human hands.</font>"))

	for(var/obj/singularity/child/SC in childs)
		SC.expand(temp_allowed_size, growing)

	if(current_size == allowed_size)
		investigate_log("<font color='red'>grew to size [current_size].</font>", I_SINGULO)
		return 1
	else if(current_size < (--temp_allowed_size) && current_size != STAGE_SUPER)
		expand(temp_allowed_size)
	else
		return 0

/obj/singularity/proc/can_expand(step_size)

	for(var/direction in GLOB.cardinal)
		if(!check_turfs_in(direction))
			return FALSE
	for(var/corner in GLOB.cornerdirs)
		if(!check_turfs_in(corner))
			return FALSE
	for(var/obj/singularity/child/SC in childs)
		for(var/direction in GLOB.cardinal)
			if(!SC.check_turfs_in(direction, step_size))
				return FALSE
	return TRUE

/obj/singularity/proc/check_energy()
	if(energy <= 0)
		investigate_log("collapsed.", I_SINGULO)
		qdel(src)
		return 0

	switch(energy) // Some of these numbers might need to be changed up later -Mport.
		if(1 to 199)
			allowed_size = STAGE_ONE
		if(200 to 499)
			allowed_size = STAGE_TWO
		if(500 to 999)
			allowed_size = STAGE_THREE
		if(1000 to 1999)
			allowed_size = STAGE_FOUR
		if(2000 to 49999)
			allowed_size = STAGE_FIVE
		if(50000 to INFINITY)
			allowed_size = STAGE_SUPER

	if(current_size != allowed_size && current_size != STAGE_SUPER)
		expand(null, current_size < allowed_size)
	return 1

/obj/singularity/proc/eat()
	for(var/atom/X in orange(grav_pull, src))
		var/dist = get_dist(X, src)
		if(dist > consume_range)
			X.singularity_pull(src, current_size)
		else if(dist <= consume_range)
			consume(X)

	for(var/obj/singularity/child/SC in childs)
		SC.eat()

/obj/singularity/proc/consume(const/atom/A)
	energy += A.singularity_act(src, current_size)
	return

/obj/singularity/proc/move(force_move_direction = 0)
	if(!move_self)
		return FALSE

	var/movement_dir = pick(GLOB.alldirs - last_failed_movement)

	if(force_move_direction)
		movement_dir = force_move_direction

	else if((target || the_chosen) && prob(60))
		movement_dir = get_dir(src, target || the_chosen) // moves to a singulo beacon, if there is one

	if(current_size >= STAGE_FIVE) // The superlarge one does not care about things in its way
		step(src, movement_dir)
		for(var/obj/singularity/child/SC in childs)
			SC.move()

	else if(can_move_to(movement_dir))
		last_failed_movement = 0 // Reset this because we moved
		step(src, movement_dir)
		for(var/obj/singularity/child/SC in childs)
			SC.move()

	else
		last_failed_movement = movement_dir

/obj/singularity/proc/can_move_to(direction)
	if(check_turfs_in(direction))
		return TRUE

	for(var/obj/singularity/child/SC in childs)
		if(SC.check_turfs_in(direction))
			return TRUE

/obj/singularity/proc/check_turfs_in(direction = 0, step = 0)
	if(!direction)
		return FALSE
	var/steps = 0
	if(!step)
		switch(current_size)
			if(STAGE_ONE)
				steps = 1
			if(STAGE_TWO)
				steps = 3 // Yes this is right
			if(STAGE_THREE)
				steps = 3
			if(STAGE_FOUR)
				steps = 4
			if(STAGE_FIVE)
				steps = 5
			if(STAGE_SUPER)
				steps = 6
	else
		steps = step
	var/list/turfs = list()
	var/turf/considered_turf = loc
	for(var/i in 1 to steps)
		considered_turf = get_step(considered_turf,direction)
	if(!isturf(considered_turf))
		return FALSE
	turfs.Add(considered_turf)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH, SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST, WEST)
			dir2 = 1
			dir3 = 2
	var/turf/other_turf = considered_turf
	for(var/j = 1 to steps-1)
		other_turf = get_step(other_turf,dir2)
		if(!isturf(other_turf))
			return FALSE
		turfs.Add(other_turf)
	for(var/k = 1 to steps-1)
		considered_turf = get_step(considered_turf,dir3)
		if(!isturf(considered_turf))
			return FALSE
		turfs.Add(considered_turf)
	for(var/turf/check_turf in turfs)
		if(isnull(check_turf))
			continue
		if(!can_move(check_turf))
			return FALSE
	return TRUE

/obj/singularity/proc/can_move(turf/considered_turf)
	if(!considered_turf)
		return FALSE
	if((locate(/obj/machinery/containment_field) in considered_turf)||(locate(/obj/machinery/shieldwall) in considered_turf))
		return FALSE
	else if(locate(/obj/machinery/field_generator) in considered_turf)
		var/obj/machinery/field_generator/G = locate(/obj/machinery/field_generator) in considered_turf
		if(G?.active)
			return FALSE
	else if(locate(/obj/machinery/shieldwallgen) in considered_turf)
		var/obj/machinery/shieldwallgen/S = locate(/obj/machinery/shieldwallgen) in considered_turf
		if(S?.active)
			return FALSE
	return TRUE

/obj/singularity/proc/event()
	var/numb = pick(1, 2, 3, 4, 5, 6)

	switch(numb)
		if(1) // EMP.
			emp_area()
		if(2, 3) // Tox damage all carbon mobs in area.
			toxmob()
		if(4) // Stun mobs who lack optic scanners.
			mezzer()
		else
			return 0
	if(current_size == STAGE_SUPER)
		smwave()
	return 1

/obj/singularity/proc/toxmob()
	var/toxrange = 10
	var/toxdamage = 4
	if(energy > 200)
		toxdamage = round(((energy - 150) / 50) * 4, 1)

	for(var/mob/living/M in view(toxrange, loc))
		if(M.status_flags & GODMODE)
			continue
		toxdamage = (toxdamage - (toxdamage * M.getarmor(null, "rad")))
		M.apply_effect(toxdamage, TOX)

	for(var/obj/singularity/child/SC in childs)
		SC.toxmob()

/obj/singularity/proc/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(istype(M, /mob/living/carbon/brain)) //Ignore brains
			continue
		if(M.status_flags & GODMODE)
			continue
		if(M.stat == CONSCIOUS)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.glasses, /obj/item/clothing/glasses/hud/standard/meson) && current_size != STAGE_SUPER)
					to_chat(H, SPAN("notice", "You look directly into The [name], good thing you had your protective eyewear on!"))
					return
				else
					to_chat(H, SPAN("warning", "You look directly into The [name], but your eyewear does absolutely nothing to protect you from it!"))
		to_chat(M, SPAN("danger", "You look directly into The [name] and feel [current_size == STAGE_SUPER ? "helpless" : "weak"]."))
		M.apply_effect(3, STUN)
		visible_message(SPAN("danger", "[M] stares blankly at The [src]!"))

	for(var/obj/singularity/child/SC in childs)
		SC.mezzer()

/obj/singularity/proc/emp_area()
	if(current_size != STAGE_SUPER)
		empulse(src, 8, 10)
	else
		empulse(src, 12, 16)

	for(var/obj/singularity/child/SC in childs)
		SC.emp_area()

/obj/singularity/proc/smwave()
	for(var/mob/living/M in view(10, loc))
		if(prob(67))
			to_chat(M, SPAN("warning", "You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat."))
			to_chat(M, SPAN("notice", "Miraculously, it fails to kill you."))
		else
			to_chat(M, SPAN("danger", "You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat."))
			to_chat(M, SPAN("danger", "You don't even have a moment to react as you are reduced to ashes by the intense radiation."))
			M.dust()

	var/datum/radiation_source/temp_source = SSradiation.radiate(src, new /datum/radiation/preset/singularity_beta)
	temp_source.schedule_decay(10 SECONDS)

	for(var/obj/singularity/child/SC in childs)
		SC.smwave()

/obj/singularity/proc/on_capture()
	chained = 1
	ClearOverlays()
	move_self = 0
	switch(current_size)
		if(STAGE_ONE)
			AddOverlays(image('icons/obj/singularity.dmi', "chain_s1"))
		if(STAGE_TWO)
			AddOverlays(image('icons/effects/96x96.dmi', "chain_s3"))
		if(STAGE_THREE)
			AddOverlays(image('icons/effects/160x160.dmi', "chain_s5"))
		if(STAGE_FOUR)
			AddOverlays(image('icons/effects/224x224.dmi', "chain_s7"))
		if(STAGE_FIVE)
			AddOverlays(image('icons/effects/288x288.dmi', "chain_s9"))

	for(var/obj/singularity/child/SC in childs)
		SC.on_capture()

/obj/singularity/proc/on_release()
	chained = 0
	ClearOverlays()
	move_self = 1

	for(var/obj/singularity/child/SC in childs)
		SC.on_release()

/obj/singularity/singularity_act(S, size)
	if(current_size <= size)
		var/gain = energy / 2
		var/dist = max((current_size - 2), 1)
		explosion(loc, dist, (dist * 2), (dist * 4))
		spawn(0)
			qdel(src)
		return gain

/obj/singularity/child
	var/assigned_level
	var/obj/singularity/parent = null

/obj/singularity/child/New(newloc, parent, level)
	if(!parent || !level)
		qdel(src)
		return

	src.parent = parent
	assigned_level = level

/obj/singularity/child/Destroy()
	if(!QDELETED(parent))
		parent.childs -= src
		qdel(parent)
	parent = null
	return ..()

/obj/singularity/child/move()
	forceMove(locate(parent.x, parent.y, assigned_level))

/obj/singularity/child/consume(const/atom/A)
	parent.consume(A)

/obj/singularity/child/ex_act(severity)
	parent.ex_act(severity)

/obj/singularity/child/singularity_act(S, size)
	return parent.singularity_act(S, size)

/obj/singularity/no_childs
	create_childs = FALSE
