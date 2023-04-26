#define BLOOD_VOLUME_SLIME_SPLIT 45
//Slime people are able to split like slimes, retaining a single mind that can swap between bodies at will, even after death.

/datum/species/promethean/slime
	name = SPECIES_SLIMEPERSON
	name_plural = "Slimepeople"
	var/datum/action/innate/split_body/slime_split
	var/list/mob/living/carbon/bodies
	var/datum/action/innate/swap_body/swap_body

/datum/species/promethean/slime/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	if(ishuman(H))
		slime_split = new
		slime_split.Grant(H)
		swap_body = new
		swap_body.Grant(H)

		if(!bodies || !length(bodies))
			bodies = list(H)
		else
			bodies |= H

/datum/species/promethean/slime/spec_death(gibbed, mob/living/carbon/human/H)
	if(slime_split)
		if(!H.mind || !H.mind.active)
			return

		var/list/available_bodies = (bodies - H)
		for(var/mob/living/L in available_bodies)
			if(!swap_body.can_swap(L))
				available_bodies -= L

		if(!LAZYLEN(available_bodies))
			return

		swap_body.swap_to_dupe(H.mind, pick(available_bodies))

/datum/species/promethean/slime/handle_environment_special(mob/living/carbon/human/H)
	. = ..()
	if(H.get_blood_volume() >= BLOOD_VOLUME_SLIME_SPLIT)
		if(prob(0.5))
			to_chat(H, SPAN_NOTICE("You feel very bloated!"))

	else if(H.nutrition >= STOMACH_FULLNESS_HIGH)
		H.regenerate_blood(0.15)
		if(H.get_blood_volume() <= BLOOD_VOLUME_LOSE_NUTRITION)
			H.nutrition += -0.125

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	if(H.get_blood_volume() >= BLOOD_VOLUME_SLIME_SPLIT)
		return TRUE
	return FALSE

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	if(!(H.dna?.species))
		return

	if(!ispromethean(H))
		return

	H.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.</span>",
		"<span class='notice'>You focus intently on moving your body while \
		standing perfectly still...</span>")

	if(do_after(owner, 6 SECONDS, owner))
		if(H.get_blood_volume() >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(H, SPAN_WARNING("...but there is not enough of you to go around! You must attain more mass to split!"))
	else
		to_chat(H, SPAN_WARNING("...but fail to stand perfectly still!"))

/datum/action/innate/split_body/proc/make_dupe()
	var/mob/living/carbon/human/H = owner

	if(!(H.dna?.species))
		return

	var/mob/living/carbon/human/spare = new /mob/living/carbon/human(H.loc)

	spare.dna = H.dna.Clone()
	spare.dna.mcolor = "#[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.UpdateAppearance(mutcolor_update=1)
	spare.domutcheck()
	spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))

	//H.blood_volume *= 0.45 //FIXME CHANGE TO BRAIN

	var/datum/species/promethean/slime/origin_datum = H.dna.species
	origin_datum.bodies |= spare

	var/datum/species/promethean/slime/spare_datum = spare.dna.species
	spare_datum.bodies = origin_datum.bodies

	spare.modifiers = H.modifiers.Copy()
	H.mind.transfer_to(spare)
	spare.visible_message("<span class='warning'>[H] distorts as a new body \
		\"steps out\" of [H].</span>",
		"<span class='notice'>...and after a moment of disorentation, \
		you're besides yourself!</span>")


/datum/action/innate/swap_body
	name = "Swap Body"
	button_icon_state = "slimeswap"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/swap_body/Activate()
	if(!ispromethean(owner))
		to_chat(owner, SPAN_WARNING("You are not a slimeperson."))
		Remove(owner)
	else
		ui_interact(owner)

/datum/action/innate/swap_body/tgui_host(mob/user)
	return owner

/datum/action/innate/swap_body/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/action/innate/swap_body/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeBodySwapper", name)
		ui.open()

/datum/action/innate/swap_body/tgui_data(mob/user)
	var/mob/living/carbon/human/H = owner
	if(!ispromethean(H))
		return

	var/datum/species/promethean/slime/SS = H.dna.species

	var/list/data = list()
	data["bodies"] = list()
	for(var/b in SS.bodies)
		var/mob/living/carbon/human/body = b
		if(!body || QDELETED(body) || !ispromethean(body))
			SS.bodies -= b
			continue

		var/list/L = list()
		L["htmlcolor"] = body.dna.mcolor
		L["area"] = get_area_name(body, TRUE)
		var/stat = "error"
		switch(body.stat)
			if(CONSCIOUS)
				stat = "Conscious"
			if(UNCONSCIOUS) // Also includes UNCONSCIOUS
				stat = "Unconscious"
			if(DEAD)
				stat = "Dead"
		var/occupied
		if(body == H)
			occupied = "owner"
		else if(body.mind && body.mind.active)
			occupied = "stranger"
		else
			occupied = "available"

		L["status"] = stat
		L["exoticblood"] = body.species.blood_volume
		L["name"] = body.name
		L["ref"] = "\ref[body]"
		L["occupied"] = occupied
		var/button
		if(occupied == "owner")
			button = "selected"
		else if(occupied == "stranger")
			button = "danger"
		else if(can_swap(body))
			button = null
		else
			button = "disabled"

		L["swap_button_state"] = button
		L["swappable"] = (occupied == "available") && can_swap(body)

		data["bodies"] += list(L)

	return data

/datum/action/innate/swap_body/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = owner
	if(!ispromethean(owner))
		return
	if(!H.mind || !H.mind.active)
		return

	var/datum/species/promethean/slime/SS = H.dna.species
	var/mob/living/carbon/human/selected = locate(params["ref"]) in SS.bodies
	if(!can_swap(selected))
		return
	SStgui.close_uis(src)
	swap_to_dupe(H.mind, selected)

/datum/action/innate/swap_body/proc/can_swap(mob/living/carbon/human/dupe)
	var/mob/living/carbon/human/H = owner
	if(!ispromethean(H))
		return FALSE
	var/datum/species/promethean/slime/SS = H.dna.species

	if(QDELETED(dupe)) //Is there a body?
		SS.bodies -= dupe
		return FALSE

	if(!ispromethean(dupe)) //Is it a slimeperson?
		SS.bodies -= dupe
		return FALSE

	if(dupe.stat == DEAD) //Is it alive?
		return FALSE

	if(dupe.stat != CONSCIOUS) //Is it awake?
		return FALSE

	if(dupe.mind && dupe.mind.active) //Is it unoccupied?
		return FALSE

	if(!(dupe in SS.bodies)) //Do we actually own it?
		return FALSE

	return TRUE

/datum/action/innate/swap_body/proc/swap_to_dupe(datum/mind/M, mob/living/carbon/human/dupe)
	if(!can_swap(dupe)) //sanity check
		return
	if(M.current.stat == CONSCIOUS)
		M.current.visible_message("<span class='notice'>[M.current] \
			stops moving and starts staring vacantly into space.</span>",
			SPAN_NOTICE("You stop moving this body..."))
	else
		to_chat(M.current, SPAN_NOTICE("You abandon this body..."))
	dupe.modifiers = M.current.modifiers.Copy()
	M.transfer_to(dupe)
	dupe.visible_message("<span class='notice'>[dupe] blinks and looks \
		around.</span>",
		SPAN_NOTICE("...and move this one instead."))
