
/mob/living/carbon/human/gatecrasher/Initialize()
	. = ..()
	add_think_ctx("unposessed_death_check", CALLBACK(src, nameof(.proc/unpossessed_death_check)), world.time + 45 SECONDS)

/mob/living/carbon/human/gatecrasher/proc/unpossessed_death_check()
	if(ckey) // Possessed, no euthanasia required
		remove_think_ctx("unposessed_death_check")
		return

	adjustOxyLoss(maxHealth) // Cease life functions.
	setBrainLoss(maxHealth)

	var/obj/item/organ/internal/heart/my_heart = internal_organs_by_name[BP_HEART]
	my_heart?.pulse = PULSE_NONE
	remove_think_ctx("unposessed_death_check")

/mob/living/carbon/human/gatecrasher/on_ghost_possess()
	. = ..()
	var/role_notice = ""
	if(prob(65)) // Sorry no antagonizing today
		role_notice = "Given that you are not an antag,"
	else
		var/antag_poll = list(
			MODE_CHANGELING = 3,
			MODE_TRAITOR = 15,
			MODE_VAMPIRE = 3,
			MODE_CULTIST = 5,
			MODE_REVOLUTIONARY = 5
		)
		var/datum/antagonist/selected_antag = GLOB.all_antag_types_[util_pick_weight(antag_poll)]
		selected_antag?.add_antagonist(mind, TRUE, max_stat = UNCONSCIOUS)
		role_notice = "Even though you happen to be an antag,"

	spawn(1 SECOND) // Added a delay so that this should pop up at the bottom, since we can get a lot of other spam by possessing a human and becoming an antag.
		var/disclaimer = "*--------------------*\n<b>You're a gatecrasher!</b>\n"
		disclaimer += "How did you end up in a locker aboard the station? What are your goals? Who are you? You tell the world! Your past and your future are yours to craft.\n"
		disclaimer += "<b>[role_notice] remember that you're not above the rules.</b> You have a chance to make this shift unique and unforgettable, don't waste it by aimlessly wreaking havoc and succumbing to wanton carnage.\n"
		disclaimer += "Please, do your best to make it fun for the others, and have fun yourself!\n*--------------------*"
		to_chat(src, SPAN("notice", "[disclaimer]"))
