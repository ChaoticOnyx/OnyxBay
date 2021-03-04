/*
	Click code cleanup
	~Sayu
*/

// 1 decisecond click delay (above and beyond mob/next_move)
/mob/var/next_click = 0

/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.

	Note that this proc can be overridden, and is in the case of screen objects.
*/

/atom/Click(location, control, params) // This is their reaction to being clicked on (standard proc)
	var/datum/click_handler/click_handler = usr.GetClickHandler()
	click_handler.OnClick(src, params)

/atom/DblClick(location, control, params)
	var/datum/click_handler/click_handler = usr.GetClickHandler()
	click_handler.OnDblClick(src, params)

/*
	Standard mob ClickOn()
	Handles exceptions: middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is recieving it.
	The most common are:
	* mob/UnarmedAttack(atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item,user) - used only when adjacent
	* item/afterattack(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/
/mob/proc/ClickOn(atom/A, params)

	if(world.time <= next_click) // Hard check, before anything else, to avoid crashing
		return

	next_click = world.time + 1

	var/list/modifiers = params2list(params)
	var/dragged = modifiers["drag"]
	if(dragged && !modifiers[dragged])
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return 1
	if(modifiers["ctrl"] && modifiers["alt"])
		CtrlAltClickOn(A)
		return 1
	if(modifiers["middle"])
		MiddleClickOn(A)
		return 1
	if(modifiers["shift"])
		ShiftClickOn(A)
		return 0
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return 1
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return 1

	if(stat || paralysis || stunned || weakened)
		return

	face_atom(A) // change direction to face what you clicked on

	if(!canClick()) // in the year 2000...
		return

	if(istype(loc, /obj/mecha))
		if(!locate(/turf) in list(A, A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		return M.click_action(A, src)

	if(restrained())
		setClickCooldown(10)
		RestrainedClickOn(A)
		return 1

	if(in_throw_mode)
		if(isturf(A) || isturf(A.loc))
			throw_item(A)
			trigger_aiming(TARGET_CAN_CLICK)
			return 1
		throw_mode_off()

	var/obj/item/W = get_active_hand()

	if(W == A) // Handle attack_self
		W.attack_self(src)
		trigger_aiming(TARGET_CAN_CLICK)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)
		return 1

	//Atoms on your person
	// A is your location but is not a turf; or is on you (backpack); or is on something on you (box in backpack); sdepth is needed here because contents depth does not equate inventory storage depth.
	var/sdepth = A.storage_depth(src)
	if((!isturf(A) && A == loc) || (sdepth != -1 && sdepth <= 1))
		if(W)
			var/resolved = W.resolve_attackby(A, src, params)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params) // 1 indicates adjacency
		else
			if(ismob(A)) // No instant mob attacking
				setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			UnarmedAttack(A, 1)

		trigger_aiming(TARGET_CAN_CLICK)
		return 1

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	//Atoms on turfs (not on your person)
	// A is a turf or is on a turf, or in something on a turf (pen in a box); but not something in something on a turf (pen in a box in a backpack)
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src)) // see adjacent.dm
			if(W)
				// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = W.resolve_attackby(A,src, params)
				if(!resolved && A && W)
					W.afterattack(A, src, 1, params) // 1: clicking something Adjacent
			else
				if(ismob(A)) // No instant mob attacking
					setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				UnarmedAttack(A, 1)

			trigger_aiming(TARGET_CAN_CLICK)
			return
		else // non-adjacent click
			if(W)
				W.afterattack(A, src, 0, params) // 0: not Adjacent
			else
				RangedAttack(A, params)

			trigger_aiming(TARGET_CAN_CLICK)
	return 1

/mob/proc/setClickCooldown(timeout)
	next_move = max(world.time + timeout, next_move)

/mob/proc/canClick()
	if(config.no_click_cooldown || next_move <= world.time)
		return 1
	return 0

// Default behavior: ignore double clicks, the second click that makes the doubleclick call already calls for a normal click
/mob/proc/DblClickOn(atom/A, params)
	return

/*
	Translates into attack_hand, etc.

	Note: proximity_flag here is used to distinguish between normal usage (flag=1),
	and usage when clicking on things telekinetically (flag=0).  This proc will
	not be called at ranged except with telekinesis.

	proximity_flag is not currently passed to attack_hand, and is instead used
	in human click code to allow glove touches only at melee range.
*/
/mob/proc/UnarmedAttack(atom/A, proximity_flag)
	return

/mob/living/UnarmedAttack(atom/A, proximity_flag)

	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(src, "You cannot attack people before the game has started.")
		return 0

	if(stat)
		return 0

	return 1

/*
	Ranged unarmed attack:

	This currently is just a default for all mobs, involving
	laser eyes and telekinesis.  You could easily add exceptions
	for things like ranged glove touches, spitting alien acid/neurotoxin,
	animals lunging, etc.
*/
/mob/proc/RangedAttack(atom/A, params)
	if(!mutations.len) return
	if((MUTATION_LASER in mutations) && a_intent == I_HURT)
		LaserEyes(A) // moved into a proc below
	else if(MUTATION_TK in mutations)
		setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		A.attack_tk(src)
/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(atom/A)
	return

/*
	Middle click
	Only used for swapping hands
*/
/mob/proc/MiddleClickOn(atom/A)
	swap_hand()
	return

// In case of use break glass
/*
/atom/proc/MiddleClick(mob/M as mob)
	return
*/

/*
	Shift click
	For most mobs, examine.
	This is overridden in ai.dm
*/
/mob/proc/ShiftClickOn(atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(mob/user)
	if(user.client && src in view(user.client.eye))
		user.examinate(src)

	return

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return
/atom/proc/CtrlClick(mob/user)
	return

/atom/movable/CtrlClick(mob/user)
	if(Adjacent(user))
		user.start_pulling(src)

/*
	Alt click
	Unused except for AI
*/
/mob/proc/AltClickOn(atom/A)
	A.AltClick(src)

/atom/proc/AltClick(mob/user)
	var/turf/T = get_turf(src)
	if(T && user.TurfAdjacent(T))
		if(user.listed_turf == T)
			user.listed_turf = null
		else
			user.listed_turf = T
			user.client.statpanel = "Turf"
	return 1

/mob/proc/TurfAdjacent(turf/T)
	return T.AdjacentQuick(src)

/mob/observer/ghost/TurfAdjacent(turf/T)
	if(!isturf(loc) || !client)
		return FALSE
	return z == T.z && (get_dist(loc, T) <= client.view)

/*
	Control+Shift click
	Unused except for AI
*/
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)
	return

/atom/proc/CtrlShiftClick(mob/user)
	return

/*
	Control+Alt click
*/
/mob/proc/CtrlAltClickOn(atom/A)
	A.CtrlAltClick(src)
	return

/atom/proc/CtrlAltClick(mob/user)
	return

/*
	Misc helpers

	Laser Eyes: as the name implies, handles this since nothing else does currently
	face_atom: turns the mob towards what you clicked on
*/
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	var/turf/T = get_turf(src)

	var/obj/item/projectile/beam/LE = new (T)
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)
	LE.launch(A)
/mob/living/carbon/human/LaserEyes()
	if(nutrition>0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else
		to_chat(src, "<span class='warning'>You're out of energy!  You need food!</span>")

// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/A)
	if(!A || !x || !y || !A.x || !A.y) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	var/direction
	if(abs(dx) < abs(dy))
		if(dy > 0)	direction = NORTH
		else		direction = SOUTH
	else
		if(dx > 0)	direction = EAST
		else		direction = WEST
	if(direction != dir)
		facedir(direction)

/obj/screen/click_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "click_catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = 2
	screen_loc = "CENTER-7,CENTER-7"

/obj/screen/click_catcher/Destroy()
	return QDEL_HINT_LETMELIVE

/proc/create_click_catcher()
	. = list()
	for(var/i = 0, i<15, i++)
		for(var/j = 0, j<15, j++)
			var/obj/screen/click_catcher/CC = new()
			CC.screen_loc = "NORTH-[i],EAST-[j]"
			. += CC

/obj/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && istype(usr, /mob/living/carbon))
		var/mob/living/carbon/C = usr
		C.swap_hand()
	else
		var/turf/T = screen_loc2turf(screen_loc, get_turf(usr))
		if(T)
			T.Click(location, control, params)
	. = 1

/*
	Custom click handling
*/

/mob
	var/datum/stack/click_handlers

/mob/Destroy()
	if(click_handlers)
		click_handlers.QdelClear()
		QDEL_NULL(click_handlers)
	. = ..()

var/const/CLICK_HANDLER_NONE                 = 0
var/const/CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT = 1
var/const/CLICK_HANDLER_ALL                  = (~0)

/datum/click_handler
	var/mob/user
	var/flags = 0
	var/species
	var/mouse_icon
	var/handler_name

/datum/click_handler/New(mob/user)
	..()
	src.user = user
	if(flags & (CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT))
		GLOB.logged_out_event.register(user, src, /datum/click_handler/proc/OnMobLogout)

/datum/click_handler/Destroy()
	if(flags & (CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT))
		GLOB.logged_out_event.unregister(user, src, /datum/click_handler/proc/OnMobLogout)
	user = null
	. = ..()

/datum/click_handler/proc/Enter()
	return

/datum/click_handler/proc/Exit()
	return

/datum/click_handler/proc/OnMobLogout()
	user.RemoveClickHandler(src)

/datum/click_handler/proc/OnClick(atom/A, params)
	return

/datum/click_handler/proc/OnDblClick(atom/A, params)
	return

/datum/click_handler/default/OnClick(atom/A, params)
	user.ClickOn(A, params)

/datum/click_handler/default/OnDblClick(atom/A, params)
	user.DblClickOn(A, params)

/mob/proc/GetClickHandler(datum/click_handler/popped_handler)
	if(!click_handlers)
		click_handlers = new()
	if(click_handlers.is_empty())
		PushClickHandler(/datum/click_handler/default)
	return click_handlers.Top()

/mob/proc/RemoveClickHandler(datum/click_handler/click_handler)
	if(!click_handlers)
		return

	var/was_top = click_handlers.Top() == click_handler

	if(was_top)
		click_handler.Exit()
	click_handlers.Remove(click_handler)
	qdel(click_handler)

	if(!was_top)
		return
	click_handler = click_handlers.Top()
	if(click_handler)
		click_handler.Enter()

/mob/proc/PopClickHandler()
	if(!click_handlers)
		return
	RemoveClickHandler(click_handlers.Top())

/mob/proc/PushClickHandler(datum/click_handler/new_click_handler_type)
	if((initial(new_click_handler_type.flags) & CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT) && !client)
		return FALSE
	if(!click_handlers)
		click_handlers = new()
	var/datum/click_handler/click_handler = click_handlers.Top()
	if(click_handler)
		click_handler.Exit()

	click_handler = new new_click_handler_type(src)
	click_handler.Enter()
	click_handlers.Push(click_handler)

/datum/click_handler/proc/mob_check(mob/living/carbon/human/user) //Check can mob use a ability
	return

/datum/click_handler/human/mob_check(mob/living/carbon/human/user)
	if(ishuman(user))
		if(user.species.name == src.species)
			return TRUE
	return FALSE

/datum/click_handler/human/OnClick(atom/target)
	return

/////////////////
//Changeling CH//
/////////////////

/datum/click_handler/changeling/mob_check(mob/living/carbon/human/user)
	if(ishuman(user) && user.mind && user.mind.changeling)
		return TRUE
	return FALSE

/datum/click_handler/changeling/OnClick(atom/target) //Check can mob use a ability
	return

/datum/click_handler/changeling/changeling_lsdsting
	handler_name = "Hallucination Sting"

/datum/click_handler/changeling/changeling_lsdsting/OnClick(atom/target)
	user.changeling_lsdsting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_silence_sting
	handler_name = "Silence Sting"

/datum/click_handler/changeling/changeling_silence_sting/OnClick(atom/target)
	user.changeling_silence_sting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_chemical_sting
	handler_name = "Chem Sting"

/datum/click_handler/changeling/changeling_chemical_sting/OnClick(atom/target)
	user.changeling_chemical_sting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_blind_sting
	handler_name = "Blind Sting"

/datum/click_handler/changeling/changeling_blind_sting/OnClick(atom/target)
	user.changeling_blind_sting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_deaf_sting
	handler_name = "Deaf Sting"

/datum/click_handler/changeling/changeling_deaf_sting/OnClick(atom/target)
	user.changeling_deaf_sting(target)
	user.PopClickHandler()
	return

/*
/datum/click_handler/changeling/changeling_paralysis_sting
	handler_name = "Paralysis Sting"

/datum/click_handler/changeling/changeling_paralysis_sting/OnClick(atom/target)
	return user.changeling_paralysis_sting(target)

/datum/click_handler/changeling/changeling_paralysis_sting
	handler_name = "Transformation Sting"

/datum/click_handler/changeling/changeling_paralysis_sting/OnClick(atom/target)
	return user.changeling_paralysis_sting(target)

/datum/click_handler/changeling/changeling_unfat_sting
	handler_name = "Unfat Sting"

/datum/click_handler/changeling/changeling_unfat_sting/OnClick(atom/target)
	return user.changeling_unfat_sting(target)
*/

/datum/click_handler/changeling/infest
	handler_name = "Infest"

/datum/click_handler/changeling/infest/OnClick(atom/target)
	var/mob/living/simple_animal/hostile/little_changeling/L = user
	L.infest(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_death_sting
	handler_name = "Death Sting"

/datum/click_handler/changeling/changeling_death_sting/OnClick(atom/target)
	user.changeling_death_sting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_extract_dna_sting
	handler_name = "Extract DNA Sting"

/datum/click_handler/changeling/changeling_extract_dna_sting/OnClick(atom/target)
	user.changeling_extract_dna_sting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_fake_arm_blade_sting
	handler_name = "Fake arm Blade"

/datum/click_handler/changeling/changeling_fake_arm_blade_sting/OnClick(atom/target)
	user.changeling_fake_arm_blade_sting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_bioelectrogenesis
	handler_name = "Bioelectrogenesis"

/datum/click_handler/changeling/changeling_bioelectrogenesis/OnClick(atom/target)
	user.changeling_bioelectrogenesis(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/changeling_vomit_sting
	handler_name = "Vomit Sting"

/datum/click_handler/changeling/changeling_vomit_sting/OnClick(atom/target)
	user.changeling_vomit_sting(target)
	user.PopClickHandler()
	return

/datum/click_handler/changeling/little_paralyse
	handler_name = "Paralyse"

/datum/click_handler/changeling/little_paralyse/OnClick(atom/target)
	var/mob/living/simple_animal/hostile/little_changeling/L = user
	L.paralyse_sting(target)
	user.PopClickHandler()
	return

/////////////////
//  WIZARD CH  //
/////////////////

/datum/click_handler/wizard/mob_check(mob/living/carbon/human/user)
	return 1
/datum/click_handler/wizard/OnClick(atom/target)

/datum/click_handler/wizard/fireball
	handler_name = "Fireball"
/datum/click_handler/wizard/fireball/mob_check(mob/living/carbon/human/user)
	return 1
/datum/click_handler/wizard/fireball/OnClick(atom/target)
	if (!isliving(target) && !isturf(target))
		return 0
	for(var/spell/spell_storage in user.mind.learned_spells)
		if (src.handler_name == spell_storage.name)
			return spell_storage.perform(user,0,target)
	to_chat(user, "We cannot find it's power... call admins")
	return 0
