#define WAIT_TO_HEAL 20 SECONDS
#define WAIT_TO_CRIT 15 SECONDS
#define CRIT_MULTIPLIER 10

var/global/list/protected_objects = list(
	/obj/structure/table,
	/obj/structure/cable,
	/obj/structure/window,
	/obj/item/projectile,
	/obj/structure/window_frame
)

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_living = "crate"

	meat_type = /obj/item/reagent_containers/food/carpmeat
	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = 4
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "attacked"
	attack_sound = 'sound/weapons/bite.ogg'

	min_gas = null
	max_gas = null
	minbodytemp = 0

	faction = "mimic"
	move_to_delay = 8

	controllable = TRUE

	var/obj/copy_of
	var/weakref/creator // the creator
	var/destroy_objects = FALSE
	var/knockdown_people = FALSE
	var/default_appearance = /obj/structure/closet/crate
	var/inactive_time = 0

	var/_healing = FALSE
	var/_in_ambush = FALSE
	var/_in_trap_mode = FALSE
	var/obj/item/mimic_trap/trap

/mob/living/simple_animal/hostile/mimic/New(newloc, obj/o, mob/living/creator)
	..()

	o = o || default_appearance

	if(!o)
		var/list/valid_targets = list()

		for(var/obj/O in (view(world.view) - src))
			valid_targets += O

		o = pick(valid_targets)

	if(ispath(o))
		o = new o(newloc)

	if(creator)
		set_creator(creator)

	mimicry(o)

	health = maxHealth
	register_signal(src, SIGNAL_MOVED, .proc/_on_moved)

/mob/living/simple_animal/hostile/mimic/proc/_on_moved()
	_update_inactive_time()

	if(_in_trap_mode)
		_deactivate_trap()
	
	// Hack, `/obj/structure/bed` types have custom logic based on
	// their self direction and that can significantly change appearance.
	if(istype(copy_of, /obj/structure/bed))
		copy_of.set_dir(dir)
		copy_of.update_icon()
		appearance = copy_of

/mob/living/simple_animal/hostile/mimic/proc/_update_inactive_time()
	inactive_time = world.time

/mob/living/simple_animal/hostile/mimic/proc/_handle_contents()
	var/has_mob = FALSE

	for(var/atom/movable/A in contents)
		if(ismob(A))
			var/mob/M = A

			if(M.is_dead())
				M.forceMove(get_turf(src))
				M.gib()
			else
				has_mob = TRUE
				M.attack_generic(src, rand(melee_damage_lower * (CRIT_MULTIPLIER / 2), melee_damage_upper * (CRIT_MULTIPLIER / 2)), attacktext, environment_smash, damtype, defense)
		else if(A != copy_of)
			A.forceMove(get_turf(src))

	anchored = has_mob

/mob/living/simple_animal/hostile/mimic/attack_hand(mob/user)
	. = ..()
	
	if(user.a_intent != I_HURT)
		if(_in_trap_mode)
			_activate_trap(user)
		else if(_in_ambush)
			user.attack_generic(src, rand(melee_damage_lower * CRIT_MULTIPLIER, melee_damage_upper * CRIT_MULTIPLIER), attacktext, environment_smash, damtype, defense)

	_update_inactive_time()

/mob/living/simple_animal/hostile/mimic/on_pulling_try(mob/user)
	if(_in_trap_mode)
		_activate_trap(user)

/mob/living/simple_animal/hostile/mimic/Life()
	. = ..()
	
	if(client)
		update_action_buttons()

	_handle_healing()
	_handle_ambush()
	_handle_contents()

/mob/living/simple_animal/hostile/mimic/proc/_update_verbs()
	var/obj/item/C = copy_of

	if(!is_target_valid_for_mimicry(C))
		return

	if(C.w_class < ITEM_SIZE_NORMAL)
		verbs |= /mob/living/proc/ventcrawl
		verbs |= /mob/living/proc/hide
	else
		verbs ^= /mob/living/proc/ventcrawl
		verbs ^= /mob/living/proc/hide

	if(can_setup_trap())
		verbs |= /mob/living/simple_animal/hostile/mimic/verb/Trap
	else
		verbs ^= /mob/living/simple_animal/hostile/mimic/verb/Trap

/mob/living/simple_animal/hostile/mimic/proc/_handle_healing()
	var/healing_check = world.time > inactive_time + WAIT_TO_HEAL
	if(_healing != healing_check)
		if(healing_check)
			to_chat(src, SPAN("notice", "You begin to heal yourself"))
		else
			to_chat(src, SPAN("warning", "You stop healing yourself"))

		_healing = healing_check

	if(_healing)
		THROTTLE(heal_cd, 1 SECOND)

		if(heal_cd)
			var/heal_amount = max(1, maxHealth * 0.01)
			health = clamp(health + heal_amount, 0, maxHealth)

/mob/living/simple_animal/hostile/mimic/proc/_handle_ambush()
	var/ambush_check = world.time > inactive_time + WAIT_TO_CRIT
	if(_in_ambush != ambush_check)
		if(ambush_check)
			to_chat(src, SPAN("notice", "You have entered the ambush mode"))
		else
			to_chat(src, SPAN("warning", "You have exited the ambush mode"))

		_in_ambush = ambush_check

/mob/living/simple_animal/hostile/mimic/find_target()
	. = ..()

	if(.)
		audible_emote("growls at [.]")

/mob/living/simple_animal/hostile/mimic/ListTargets()
	// Return a list of targets that isn't the creator
	. = ..()

	if(creator)
		return . - creator.resolve()

/mob/living/simple_animal/hostile/mimic/proc/_release_copy()
	var/atom/movable/C = copy_of

	if(!C)
		return

	C.forceMove(src.loc)

	if(istype(C, /obj/structure/closet))
		for(var/atom/movable/M in src)
			M.forceMove(C)

	if(istype(C, /obj/item/storage))
		var/obj/item/storage/S = C

		for(var/atom/movable/M in src)
			if(S.can_be_inserted(M, null, 1))
				S.handle_item_insertion(M)
			else
				M.forceMove(src.loc)

	for(var/atom/movable/M in src)
		M.forceMove(get_turf(src))

/mob/living/simple_animal/hostile/mimic/proc/mimicry(obj/target)
	if(copy_of)
		_release_copy()

	if(!is_target_valid_for_mimicry(target))
		return

	forceMove(get_turf(target))
	target.forceMove(src)
	copy_of = target
	appearance = target
	icon_living = icon_state

	if(istype(target, /obj/structure))
		maxHealth = 100
		destroy_objects = TRUE
		knockdown_people = TRUE

		melee_damage_lower = initial(melee_damage_lower) * 2
		melee_damage_upper = initial(melee_damage_upper) * 2
	else if(istype(target, /obj/item))
		var/obj/item/I = target

		maxHealth = 15 * I.w_class
		melee_damage_lower = 2 + I.force
		melee_damage_upper = 2 + I.force
		move_to_delay = 2 * I.w_class

	health = clamp(health, 0, maxHealth)
	_update_verbs()
	_update_actions()

/mob/living/simple_animal/hostile/mimic/proc/set_creator(mob/living/creator)
	creator = weakref(creator)
	faction = "\ref[creator]" // very unique

/mob/living/simple_animal/hostile/mimic/death()
	if(copy_of)
		_release_copy()

	..(null, "dies!")
	qdel(src)

/mob/living/simple_animal/hostile/mimic/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/AttackingTarget()
	. =..()

	if(!knockdown_people)
		return

	var/mob/living/L = .

	if(istype(L) && prob(15))
		L.Weaken(1)
		L.visible_message(SPAN_DANGER("\The [src] knocks down \the [L]!"))

/mob/living/simple_animal/hostile/mimic/Destroy()
	copy_of = null
	creator = null

	unregister_signal(src, SIGNAL_MOVED)

	return ..()

/mob/living/simple_animal/hostile/mimic/proc/is_target_valid_for_mimicry(obj/O)
	if(QDELETED(O))
		return FALSE

	if((!istype(O, /obj/item) && !istype(O, /obj/structure)))
		return FALSE

	if(O.anchored)
		return FALSE
	
	if(is_type_in_list(O, protected_objects))
		return FALSE
	
	if(get_dist(src, O) > 1)
		return FALSE

	return TRUE

/mob/living/simple_animal/hostile/mimic/proc/can_setup_trap()
	var/obj/structure/closet/C = copy_of

	if(QDELETED(C))
		return FALSE
	
	if(!istype(C))
		return FALSE

	return TRUE

/mob/living/simple_animal/hostile/mimic/proc/_choose_mimicry_target()
	var/list/targets = view(1, src)

	for(var/atom/A in targets)
		if(!is_target_valid_for_mimicry(A))
			targets -= A

	if(!length(targets))
		return
	
	var/obj/T = input(usr, "Choose target for mimicry", "Mimicry") as null | anything in targets

	if(!is_target_valid_for_mimicry(T))
		return
	
	return T

/mob/living/simple_animal/hostile/mimic/proc/_update_actions()
	for(var/datum/action/A in actions)
		A.Remove(src)

	var/datum/action/mimic/mimicry/M = new()
	M.Grant(src)

	if(can_setup_trap())
		var/datum/action/mimic/trap/T = new()
		T.Grant(src)

/mob/living/simple_animal/hostile/mimic/sleeping
	wander = FALSE
	stop_automated_movement = TRUE

	var/awake = FALSE

/mob/living/simple_animal/hostile/mimic/sleeping/ListTargets()
	if(!awake)
		return null
	return ..()

/mob/living/simple_animal/hostile/mimic/sleeping/proc/trigger()
	if(!awake)
		visible_message("<b>\The [src]</b> starts to move!")
		awake = TRUE

/mob/living/simple_animal/hostile/mimic/sleeping/adjustBruteLoss(damage)
	trigger()
	..(damage)

/mob/living/simple_animal/hostile/mimic/sleeping/attack_hand()
	trigger()
	..()

/mob/living/simple_animal/hostile/mimic/sleeping/DestroySurroundings()
	if(awake)
		..()

/mob/living/simple_animal/hostile/mimic/MiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_MIDDLE_CLICK)
		if(is_target_valid_for_mimicry(A))
			mimicry(A)

	..()

/mob/living/simple_animal/hostile/mimic/AltClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_ALT_CLICK)
		if(is_target_valid_for_mimicry(A))
			mimicry(A)

	..()

/mob/living/simple_animal/hostile/mimic/CtrlClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_CTRL_CLICK)
		if(is_target_valid_for_mimicry(A))
			mimicry(A)

	..()

/mob/living/simple_animal/hostile/mimic/CtrlShiftClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_CTRL_SHIFT_CLICK)
		if(is_target_valid_for_mimicry(A))
			mimicry(A)

	..()

/mob/living/simple_animal/hostile/mimic/verb/Mimicry()
	set name = "Mimicry"
	set category = "Mimic"

	if(anchored)
		to_chat(usr, SPAN("warning", "You can't move"))
		return

	if(_in_trap_mode)
		to_chat(usr, SPAN("warning", "You can't mimicry while in trap mode"))
		return

	var/obj/T = _choose_mimicry_target()

	if(!T)
		to_chat(usr, SPAN("warning", "No valid targets to mimicry"))
		return

	mimicry(T)

/mob/living/simple_animal/hostile/mimic/verb/Trap()
	set name = "Trap"
	set category = "Mimic"

	var/static/list/trap_targets = list(
		"captain's spare ID" = /obj/item/card/id/captains_spare,
		"captain's antique laser gun" = /obj/item/gun/energy/captain,
		"stunbaton" = /obj/item/melee/baton/loaded,
		"10 diamonds" = /obj/item/stack/material/diamond/ten,
		"1000 credit" = /obj/item/spacecash/bundle/c1000,
		"rapid construction device" = /obj/item/rcd,
		"taser pistol" = /obj/item/gun/energy/security/pistol,
		"crowbar" = /obj/item/crowbar,
		"gold coin" = /obj/item/material/coin/gold,
		"insulated gloves" = /obj/item/clothing/gloves/insulated,
		"multitool" = /obj/item/device/multitool,
		"one-hand energy sword" = /obj/item/melee/energy/sword/one_hand,
		"powersink" = /obj/item/device/powersink,
		"toy katana" = /obj/item/toy/katana,
		"hypospray" = /obj/item/reagent_containers/hypospray,
		"carbon dioxide jetpack" = /obj/item/tank/jetpack/carbondioxide,
		"revolver" = /obj/item/gun/projectile/revolver,
		"nuclear authentication disk" = /obj/item/disk/nuclear_fake,
		".50 magnum pistol" = /obj/item/gun/projectile/pistol/magnum_pistol,
		"rubber piggy" = /obj/item/toy/pig
	)

	if(!can_setup_trap())
		to_chat(usr, SPAN("warning", "You can't do it in your current form"))
		return

	if(anchored)
		to_chat(usr, SPAN("warning", "You can't move"))
		return

	if(_in_trap_mode)
		to_chat(src, SPAN("warning", "You are already in trap mode"))
		return

	if(!_in_ambush)
		to_chat(src, SPAN("warning", "Enter the ambush mode first"))
		return

	var/selected = input(usr, "Choose an appearance for the trap", "Trap") as null | anything in trap_targets

	if(!selected)
		return

	_set_closet_opened_state(TRUE)

	trap = new /obj/item/mimic_trap/(get_turf(src), src, trap_targets[selected])
	_in_trap_mode = TRUE

/mob/living/simple_animal/hostile/mimic/proc/_set_closet_opened_state(state)
	var/obj/structure/closet/C = copy_of

	ASSERT(istype(C))

	C.opened = state
	C.update_icon()
	appearance = C

/mob/living/simple_animal/hostile/mimic/proc/_activate_trap(mob/victim)
	victim.forceMove(src)
	
	to_chat(victim, SPAN("danger", "\The [src] has stuffed you into itself and is starts tearing you apart!"))
	to_chat(src, SPAN("notice", "You caught [victim]!"))

	_deactivate_trap()

/mob/living/simple_animal/hostile/mimic/proc/_deactivate_trap()
	_update_inactive_time()
	_set_closet_opened_state(FALSE)
	_in_trap_mode = FALSE
	QDEL_NULL(trap)

/mob/living/simple_animal/hostile/mimic/ventcrawl_carry()
	return TRUE

/datum/action/mimic/mimicry
	name = "Mimicry"

	button_icon_state = "mimicry"
	action_type = AB_GENERIC
	procname = /mob/living/simple_animal/hostile/mimic/verb/Mimicry

/datum/action/mimic/trap
	name = "Trap"

	button_icon_state = "trap"
	action_type = AB_GENERIC
	procname = /mob/living/simple_animal/hostile/mimic/verb/Trap

/datum/action/mimic/Grant(mob/living/T)
	. = ..()

	target = T

/obj/item/mimic_trap
	name = "Unknown"
	desc = "Unknown"
	anchored = TRUE

	var/weakref/owner

/obj/item/mimic_trap/New(loc, mob/living/simple_animal/hostile/mimic/owner, object_path)
	..()

	src.owner = weakref(owner)

	ASSERT(src.owner)

	var/obj/item/from = new object_path(get_turf(src))
	from.forceMove(src)
	appearance = from
	layer = MOB_LAYER + 0.1

/obj/item/mimic_trap/Destroy()
	for(var/A in contents)
		qdel(A)

	owner = null

	. = ..()

/obj/item/mimic_trap/attack_hand(mob/user)
	var/mob/living/simple_animal/hostile/mimic/M = owner.resolve()

	M.attack_hand(user)

/obj/item/mimic_trap/on_pulling_try(mob/user)
	attack_hand(user)

#undef WAIT_TO_HEAL
#undef WAIT_TO_CRIT
#undef CRIT_MULTIPLIER
