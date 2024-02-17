/datum/spell/hand/dimensional_locker
	name = "Dimensional Locker"
	desc = "Dimensional Locker."
	school = "conjuration"
	feedback = "DL"
	spell_flags = Z2NOCAST
	charge_max  = 600
	invocation_type = SPI_NONE
	icon_state = "wiz_acid"
	/// Reference to the summoned locker
	var/obj/structure/closet/locker
	/// Type of the locker to summon
	var/locker_type = /obj/structure/closet/cabinet

/datum/spell/hand/dimensional_locker/New()
	..()
	initialize_locker()

/datum/spell/hand/dimensional_locker/Destroy()
	unregister_signal(locker, SIGNAL_QDELETING)
	locker = null
	return ..()

/datum/spell/hand/dimensional_locker/proc/initialize_locker()
	locker = new locker_type()
	register_signal(locker, SIGNAL_QDELETING, nameof(.proc/initialize_locker))

/datum/spell/hand/dimensional_locker/cast(target, mob/user)
	if(!locker)
		initialize_locker()

	if(locker.loc != null)
		var/list/mobs_inside = list()
		recursive_content_check(locker, mobs_inside,  recursion_limit = 3, client_check = FALSE, sight_check = FALSE, include_mobs = TRUE, include_objects = FALSE)

		for(var/i in mobs_inside)
			var/mob/M = i
			M.dropInto(get_turf(locker))
			M.reset_view()
			to_chat(M, SPAN_WARNING("You are suddenly flung out of \the [locker]!"))

		locker.forceMove(null)
		return

	else
		return ..()

/datum/spell/hand/dimensional_locker/cast_hand(turf/target, mob/user)
	if(target.density)
		return

	for(var/atom/A in target)
		if(A.density)
			return

	locker.forceMove(target)
