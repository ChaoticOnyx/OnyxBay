var/global/list/narsie_list = list()
/obj/singularity/narsie //Moving narsie to its own file for the sake of being clearer
	name = "Nar-Sie"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie-small-chains"
	pixel_x = -236
	pixel_y = -256

	light_outer_range = 1
	light_color = "#3e0000"
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO.
	dissipate = 0 // Do we lose energy over time?
	grav_pull = 10 //How many tiles out do we pull?
	consume_range = 3 //How many tiles out do we eat
	plane = ABOVE_LIGHTING_LAYER
	var/announce = 1
	var/cause_hell = 1
	create_childs = FALSE

/obj/singularity/narsie/Initialize()
	narsie_list.Add(src)
	if(announce)
		to_world("<font size='15' color='red'><b>[uppertext(name)] HAS RISEN</b></font>")
		sound_to(world, sound('sound/effects/wind/wind_5_1.ogg'))

	narsie_spawn_animation()

	if(cause_hell)
		SetUniversalState(/datum/universal_state/hell)
	GLOB.cult.narsie_summoned = TRUE
	GLOB.ert.is_station_secure = FALSE
	spawn(10 SECONDS)
		if(evacuation_controller)
			evacuation_controller.call_evacuation(null, TRUE, 1)
			evacuation_controller.evac_no_return = 0 // Cannot recall
	. = ..()

/obj/singularity/narsie/Destroy()
	narsie_list.Remove(src)
	..()

/obj/singularity/narsie/Process()
	eat()

	if(!target || prob(5))
		pickcultist()

	move()

	if(prob(25))
		mezzer()

/obj/singularity/narsie/eat()
	for (var/turf/A in orange(consume_range, src))
		consume(A)

/obj/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(M.status_flags & GODMODE)
				continue
			if(!iscultist(M))
				to_chat(M, "<span class='danger'> You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>")
				M.apply_effect(3, STUN)


/obj/singularity/narsie/Bump(atom/A)
	if(!cause_hell) return

/obj/singularity/narsie/Bumped(atom/A)
	if(!cause_hell) return

/obj/singularity/narsie/move(force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(GLOB.alldirs - last_failed_movement)

	if(target)
		movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one

	spawn(0)
		loc = get_step(src, movement_dir)
	spawn(1)
		loc = get_step(src, movement_dir)
	return 1

/obj/singularity/narsie/consume(atom/A) //This one is for the small ones.
	var/mob/living/C = locate(/mob/living) in A
	if(istype(C))
		if(iscultist(C))
			return
		C.loc = get_turf(C)
		C.gib()
		return

	else if(isliving(A))
		var/mob/living/L = A
		if(iscultist(L))
			return
		L.gib()
		return

	else if(isturf(A))
		var/turf/T = A
		if(istype(T, /turf/simulated/wall/cult))
			return
		else if(istype(T, /turf/simulated/floor))
			if(prob(50))
				T.ChangeTurf(/turf/simulated/floor/misc/cult)
		else if(istype(T, /turf/simulated/wall))
			if(prob(20))
				T.ChangeTurf(/turf/simulated/wall/cult)
	return

/obj/singularity/narsie/ex_act(severity) //No throwing bombs at it either. --NEO
	return

/obj/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/cultists = list()
	for(var/datum/mind/cult_nh_mind in GLOB.cult.current_antagonists)
		if(!cult_nh_mind.current)
			continue
		if(cult_nh_mind.current.stat)
			continue
		var/turf/pos = get_turf(cult_nh_mind.current)
		if(pos.z != src.z)
			continue
		cultists += cult_nh_mind.current
	if(cultists.len)
		acquire(pick(cultists))
		return
		//If there was living cultists, it picks one to follow.
	for(var/mob/living/carbon/human/food in GLOB.living_mob_list_)
		if(food.stat)
			continue
		var/turf/pos = get_turf(food)
		if(!pos)	//Catches failure of get_turf.
			continue
		if(pos.z != src.z)
			continue
		cultists += food
	if(cultists.len)
		acquire(pick(cultists))
		return
		//no living cultists, pick a living human instead.
	for(var/mob/observer/ghost/ghost in GLOB.player_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(pos.z != src.z)
			continue
		cultists += ghost
	if(cultists.len)
		acquire(pick(cultists))
		return
		//no living humans, follow a ghost instead.

/obj/singularity/narsie/proc/acquire(const/mob/food)
	var/capname = uppertext(name)

	to_chat(target, "<span class='notice'><b>[capname] HAS LOST INTEREST IN YOU.</b></span>")
	target = food

	if (ishuman(target))
		to_chat(target, "<span class='danger'>[capname] HUNGERS FOR YOUR SOUL.</span>")
	else
		to_chat(target, "<span class='danger'>[capname] HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL.</span>")

/obj/singularity/narsie/on_capture()
	return

/obj/singularity/narsie/on_release()
	return

/**
 * Wizard narsie.
 */
/obj/singularity/narsie/wizard
	grav_pull = 0

/obj/singularity/narsie/wizard/eat()
	for(var/turf/T in trange(consume_range, src))
		consume(T)

/obj/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/obj/narsie_spawn_anim.dmi'
	dir = SOUTH
	move_self = 0
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = 1
	icon = initial(icon)
