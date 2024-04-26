//////////////////////////////
//Contents: Ladders, Stairs.//
//////////////////////////////

/obj/structure/ladder
	name = "ladder"
	desc = "A ladder. You can climb it up and down."
	icon_state = "ladder01"
	icon = 'icons/obj/structures.dmi'
	density = 0
	opacity = 0
	anchored = 1

	var/allowed_directions = DOWN
	var/obj/structure/ladder/target_up
	var/obj/structure/ladder/target_down

	var/const/climb_time = 2 SECONDS
	var/const/drag_time = 15 SECONDS
	var/static/list/climbsounds = list('sound/effects/ladder.ogg','sound/effects/ladder2.ogg','sound/effects/ladder3.ogg','sound/effects/ladder4.ogg')

	var/static/radial_ladder_down = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_ladder_down")
	var/static/radial_ladder_up = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_ladder_up")

	var/static/list/radial_options = list("up" = radial_ladder_up, "down" = radial_ladder_down)

/obj/structure/ladder/Initialize()
	. = ..()
	// the upper will connect to the lower
	if(allowed_directions & DOWN) //we only want to do the top one, as it will initialize the ones before it.
		for(var/obj/structure/ladder/L in GetBelow(src))
			if(L.allowed_directions & UP)
				target_down = L
				L.target_up = src
				return
	update_icon()

/obj/structure/ladder/Destroy()
	if(target_down)
		target_down.target_up = null
		target_down = null
	if(target_up)
		target_up.target_down = null
		target_up = null
	return ..()

/obj/structure/ladder/attackby(obj/item/C, mob/user)
	climb(user)

/obj/structure/ladder/attack_hand(mob/user)
	climb(user)

/obj/structure/ladder/attack_robot(mob/user)
	climb(user)

/obj/structure/ladder/attack_ai(mob/user)
	var/mob/living/silicon/ai/ai = user
	if(!istype(ai))
		return
	var/mob/observer/eye/AIeye = ai.eyeobj
	if(istype(AIeye))
		instant_climb(AIeye)

/obj/structure/ladder/attack_ghost(mob/user)
	instant_climb(user)

/obj/structure/ladder/proc/instant_climb(mob/user)
	var/target_ladder = getTargetLadder(user)
	user.forceMove(get_turf(target_ladder))

/obj/structure/ladder/proc/climb(mob/user)
	if(!user.may_climb_ladders(src))
		return

	var/obj/structure/ladder/target_ladder = getTargetLadder(user)
	if(!target_ladder)
		return
	if(!user.Move(get_turf(src)))
		to_chat(user, "<span class='notice'>You fail to reach \the [src].</span>")
		return

	var/dragging = FALSE

	for (var/obj/item/grab/G in user)
		dragging = TRUE
		G.adjust_position()

	var/direction = target_ladder == target_up ? "up" : "down"

	user.visible_message("<span class='notice'>\The [user] begins climbing [direction] \the [src]!</span>",
	"You begin climbing [direction] \the [src]!",
	"You hear the grunting and clanging of a metal ladder being used.")

	target_ladder.audible_message("<span class='notice'>You hear something coming [direction] \the [src]</span>", splash_override = "*crank crank*")

	var/time = dragging ? drag_time : climb_time

	if(do_after(user, time, src))
		climbLadder(user, target_ladder)
		for (var/obj/item/grab/G in user)
			G.adjust_position(force = 1)

/obj/structure/ladder/proc/getTargetLadder(mob/user)
	if((!target_up && !target_down) || (target_up && !istype(target_up.loc, /turf) || (target_down && !istype(target_down.loc, /turf))))
		to_chat(user, "<span class='notice'>\The [src] is incomplete and can't be climbed.</span>")
		return
	if(target_down && target_up)
		var/direction = show_radial_menu(user, src,  radial_options, require_near = !(isEye(user) || isobserver(user)))

		if(!direction)
			return

		if(!user.may_climb_ladders(src))
			return

		switch(direction)
			if("up")
				return target_up
			if("down")
				return target_down
	else
		return target_down || target_up

/mob/proc/may_climb_ladders(ladder)
	if(!Adjacent(ladder))
		to_chat(src, "<span class='warning'>You need to be next to \the [ladder] to start climbing.</span>")
		return FALSE
	if(incapacitated())
		to_chat(src, "<span class='warning'>You are physically unable to climb \the [ladder].</span>")
		return FALSE

	var/carry_count = 0
	for(var/obj/item/grab/G in src)
		if(!G.ladder_carry())
			to_chat(src, "<span class='warning'>You can't carry [G.affecting] up \the [ladder].</span>")
			return FALSE
		else
			carry_count++
	if(carry_count > 1)
		to_chat(src, "<span class='warning'>You can't carry more than one person up \the [ladder].</span>")
		return FALSE

	return TRUE

/mob/observer/ghost/may_climb_ladders(ladder)
	return TRUE

/obj/structure/ladder/proc/climbLadder(mob/user, target_ladder)
	var/turf/T = get_turf(target_ladder)
	for(var/atom/A in T)
		if(!A.CanPass(user, user.loc, 1.5, 0))
			to_chat(user, "<span class='notice'>\The [A] is blocking \the [src].</span>")
			return FALSE
	playsound(src, pick(climbsounds), 50)
	playsound(target_ladder, pick(climbsounds), 50)
	return user.Move(T)

/obj/structure/ladder/CanPass(obj/mover, turf/source, height, airflow)
	return airflow || !density

/obj/structure/ladder/on_update_icon()
	icon_state = "ladder[!!(allowed_directions & UP)][!!(allowed_directions & DOWN)]"

/obj/structure/ladder/up
	allowed_directions = UP
	icon_state = "ladder10"

/obj/structure/ladder/updown
	allowed_directions = UP|DOWN
	icon_state = "ladder11"

/obj/structure/stairs
	name = "stairs"
	desc = "Stairs leading to another deck.  Not too useful if the gravity goes out."
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	density = 0
	opacity = 0
	anchored = 1
	layer = RUNE_LAYER

/obj/structure/stairs/Initialize()
	for(var/turf/turf in locs)
		var/turf/simulated/open/above = GetAbove(turf)
		if(!above)
			warning("Stair created without level above: ([loc.x], [loc.y], [loc.z])")
			return INITIALIZE_HINT_QDEL
		if(!istype(above))
			above.ChangeTurf(/turf/simulated/open)
	. = ..()

/obj/structure/stairs/Destroy()
	loc = null // Since it's easier than allowing it to get forceMoved and facing even more trouble
	return ..()

/obj/structure/stairs/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(get_dir(loc, target) == dir && upperStep(mover.loc))
		return FALSE
	return ..()

/obj/structure/stairs/forceMove()
	return FALSE

/obj/structure/stairs/Bumped(atom/movable/A)
	var/turf/above = GetAbove(A)
	if(above)
		var/turf/target = get_step(above, dir)
		var/turf/source = A.loc
		if(above.CanZPass(source, UP) && target.Enter(A, src))
			A.forceMove(target)
			if(isliving(A))
				var/mob/living/L = A
				if(L.pulling)
					L.pulling.forceMove(target)
			if(ishuman(A))
				playsound(source, SFX_FOOTSTEP_STAIRS, 50)
				playsound(target, SFX_FOOTSTEP_STAIRS, 50)
		else
			show_splash_text(A, "something blocks the path", "There's something blocking the path.")
	else
		show_splash_text(A, "nothing of interest in this direction", "There's nothing of interest in this direction.")

/obj/structure/stairs/proc/upperStep(turf/T)
	return (T == loc)

// type paths to make mapping easier.
/obj/structure/stairs/north
	dir = NORTH
	bound_height = 64
	bound_y = -32
	pixel_y = -32

/obj/structure/stairs/south
	dir = SOUTH
	bound_height = 64

/obj/structure/stairs/east
	dir = EAST
	bound_width = 64
	bound_x = -32
	pixel_x = -32

/obj/structure/stairs/west
	dir = WEST
	bound_width = 64

/obj/structure/stairs/short
	icon_state = "stairs_short"

/obj/structure/stairs/short/north
	dir = NORTH

/obj/structure/stairs/short/south
	dir = SOUTH

/obj/structure/stairs/short/east
	dir = EAST

/obj/structure/stairs/short/west
	dir = WEST
