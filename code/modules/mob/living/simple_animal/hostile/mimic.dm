#define WAIT_TO_HEAL 20 SECONDS
#define WAIT_TO_CRIT 15 SECONDS
#define CRIT_MULTIPLIER 10

var/global/list/protected_objects = list(/obj/structure/table, /obj/structure/cable, /obj/structure/window, /obj/item/projectile, /obj/structure/window_frame)

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

	var/weakref/copy_of
	var/weakref/creator // the creator
	var/destroy_objects = FALSE
	var/knockdown_people = FALSE
	var/default_appearance = /obj/structure/closet/crate
	var/inactive_time = 0

	var/_healing = FALSE
	var/_in_ambush = FALSE

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
	_add_actions()

	health = maxHealth

	register_signal(src, SIGNAL_MOVED, .proc/_update_inactive_time)

/mob/living/simple_animal/hostile/mimic/proc/_update_inactive_time()
	inactive_time = world.time

/mob/living/simple_animal/hostile/mimic/attack_hand(mob/user)
	. = ..()
	
	if(user.a_intent != I_HURT && _in_ambush)
		user.attack_generic(src, rand(melee_damage_lower * CRIT_MULTIPLIER, melee_damage_upper * CRIT_MULTIPLIER), attacktext, environment_smash, damtype, defense)

	_update_inactive_time()

/mob/living/simple_animal/hostile/mimic/Life()
	. = ..()
	
	if(client)
		update_action_buttons()

	_handle_healing()
	_handle_ambush()

/mob/living/simple_animal/hostile/mimic/proc/update_verbs()
	verbs.Cut()

	var/obj/item/C = copy_of.resolve()

	if(!is_target_valid_for_mimicry(C))
		return

	if(C.w_class < ITEM_SIZE_NORMAL)
		verbs += /mob/living/proc/ventcrawl
		verbs += /mob/living/proc/hide

/mob/living/simple_animal/hostile/mimic/proc/_handle_healing()
	var/healing_check = world.time > inactive_time + WAIT_TO_HEAL
	if(_healing != healing_check)
		to_chat(src, SPAN(healing_check ? "notice" : "warning", "You [healing_check ? "begin to heal" : "stop healing"] yourself."))
		_healing = healing_check

	if(_healing)
		THROTTLE(heal_cd, 1 SECOND)
		if(heal_cd)
			var/heal_amount = max(1, maxHealth * 0.01)
			health = clamp(health + heal_amount, 0, maxHealth)

/mob/living/simple_animal/hostile/mimic/proc/_handle_ambush()
	var/ambush_check = world.time > inactive_time + WAIT_TO_CRIT
	if(_in_ambush != ambush_check)
		to_chat(src, SPAN(ambush_check ? "notice" : "warning", "You have [ambush_check ? "entered" : "exited"] the ambush mode."))
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
	var/atom/movable/C = copy_of.resolve()

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
	copy_of = weakref(target)
	appearance = target
	icon_living = icon_state

	if(istype(target, /obj/structure))
		maxHealth = target.anchored * 50 + 50
		destroy_objects = TRUE

		if(target.density && target.anchored)
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
	update_verbs()

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
	
	if(is_type_in_list(O, protected_objects))
		return FALSE
	
	if(get_dist(src, O) > 1)
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

/mob/living/simple_animal/hostile/mimic/proc/_add_actions()
	var/datum/action/mimic/mimicry/A = new()

	A.Grant(src)

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

	var/obj/T = _choose_mimicry_target()

	if(!T)
		to_chat(usr, SPAN("warning", "No valid targets to mimicry"))
		return

	mimicry(T)

/mob/living/simple_animal/hostile/mimic/ventcrawl_carry()
	return TRUE

/datum/action/mimic/mimicry
	name = "Mimicry"

	button_icon_state = "mimicry"
	action_type = AB_GENERIC
	procname = /mob/living/simple_animal/hostile/mimic/verb/Mimicry

/datum/action/mimic/Grant(mob/living/T)
	. = ..()

	target = T

#undef WAIT_TO_HEAL
#undef WAIT_TO_CRIT
#undef CRIT_MULTIPLIER
