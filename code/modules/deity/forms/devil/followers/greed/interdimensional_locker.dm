/datum/action/cooldown/spell/interdimensional_locker
	name = "Interdimensional locker"
	desc = ""
	button_icon_state = "devil_interdimensional_locker"
	cooldown_time = 1 SECOND
	/// Reference to the summoned locker
	var/obj/structure/closet/locker
	/// Type of the locker to summon
	var/locker_type = /obj/structure/closet/cabinet
	click_to_activate = TRUE

/datum/action/cooldown/spell/interdimensional_locker/New()
	. = ..()
	initialize_locker()

/datum/action/cooldown/spell/interdimensional_locker/Destroy()
	unregister_signal(locker, SIGNAL_QDELETING)
	locker = null
	return ..()

/datum/action/cooldown/spell/interdimensional_locker/proc/initialize_locker()
	locker = new locker_type()
	register_signal(locker, SIGNAL_QDELETING, nameof(.proc/initialize_locker))

/datum/action/cooldown/spell/interdimensional_locker/cast(atom/cast_on)
	if(!locker)
		initialize_locker()

	if(locker.loc != null)
		var/list/mobs_inside = list()
		recursive_content_check(locker, mobs_inside, recursion_limit = 3, client_check = FALSE, sight_check = FALSE, include_mobs = TRUE, include_objects = FALSE)

		for(var/i in mobs_inside)
			var/mob/M = i
			M.dropInto(get_turf(locker))
			M.reset_view()
			to_chat(M, SPAN_WARNING("You are suddenly flung out of \the [locker]!"))

		locker.forceMove(null)
		click_to_activate = TRUE
		return

	var/turf/target = get_turf(cast_on)
	if(!istype(target))
		return

	for(var/atom/A in target)
		if(A.density)
			return

	locker.forceMove(target)
	click_to_activate = FALSE
