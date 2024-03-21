#define BLOOD_VOLUME_SLIME_SPLIT 45
//Slime people are able to split like slimes, retaining a single mind that can swap between bodies at will, even after death.

/datum/component/body_swapper
	var/list/mob/living/carbon/bodies
	var/datum/action/innate/split_body/slime_split
	var/datum/action/innate/swap_body/swap_body

/datum/species/promethean/slime
	name = SPECIES_SLIMEPERSON
	name_plural = "Slimepeople"
	icobase = 'icons/mob/human_races/prometheans/r_slime.dmi'


/datum/species/promethean/slime/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	if(ishuman(H))
		var/datum/component/body_swapper/BS = H.AddComponent(/datum/component/body_swapper)
		BS.slime_split = new
		BS.slime_split.Grant(H)
		BS.swap_body = new
		BS.swap_body.Grant(H)
		H.update_action_buttons()
		if(!BS.bodies || !length(BS.bodies))
			BS.bodies = list(H)
		else
			BS.bodies |= H

/datum/species/promethean/slime/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/component/body_swapper/BS = H.get_component(/datum/component/body_swapper)
	BS.slime_split.Remove(H)
	BS.swap_body.Remove(H)
	spawn(1)
		H.update_action_buttons()
	qdel(BS)

/datum/species/promethean/slime/handle_death(mob/living/carbon/human/H)
	var/datum/component/body_swapper/BS = H.get_component(/datum/component/body_swapper)
	if(BS.slime_split)
		if(!H.mind || !H.mind.active)
			return

		var/list/available_bodies = (BS.bodies - H)
		for(var/mob/living/L in available_bodies)
			if(!BS.swap_body.can_swap(L))
				available_bodies -= L

		if(!LAZYLEN(available_bodies))
			return

		BS.swap_body.swap_to_dupe(H.mind, pick(available_bodies))

/datum/species/promethean/slime/handle_environment_special(mob/living/carbon/human/H)
	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = H.internal_organs_by_name[BP_METROID]
	var/jelly_amount = jelly_vessel.stored_jelly
	var/jelly_volume = round((jelly_amount/blood_volume)*100)
	if(jelly_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		if(prob(0.5))
			to_chat(H, SPAN_NOTICE("You feel very bloated!"))

	else if(H.nutrition >= STOMACH_FULLNESS_HIGH)
		jelly_vessel.add_jelly(0.15)
		if(jelly_volume <= BLOOD_VOLUME_LOSE_NUTRITION)
			H.remove_nutrition(0.125)

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = H.internal_organs_by_name[BP_METROID]
	var/jelly_amount = jelly_vessel.stored_jelly
	var/jelly_volume = round((jelly_amount/H.species.blood_volume)*100)

	if(jelly_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		return TRUE
	return FALSE

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	if(!(H.dna?.species))
		return

	if(!ispromethean(H))
		return

	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = H.internal_organs_by_name[BP_METROID]
	var/jelly_amount = jelly_vessel.stored_jelly
	var/jelly_volume = round((jelly_amount/H.species.blood_volume)*100)

	H.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.</span>",
		"<span class='notice'>You focus intently on moving your body while \
		standing perfectly still...</span>")

	if(do_after(owner, 6 SECONDS, owner))
		if(jelly_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(H, SPAN_WARNING("...but there is not enough of you to go around! You must attain more mass to split!"))
	else
		to_chat(H, SPAN_WARNING("...but fail to stand perfectly still!"))

/datum/action/innate/split_body/proc/make_dupe()
	var/mob/living/carbon/human/H = owner

	if(!(H.dna?.species))
		return

	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = H.internal_organs_by_name[BP_METROID]
	var/mob/living/carbon/human/spare = new /mob/living/carbon/human/slimeperson(H.loc)

	spare.dna = H.dna.Clone()
	spare.dna.mcolor = "#[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.UpdateAppearance(mutcolor_update=1)
	spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))
	spare.AddComponent(/datum/component/body_swapper)

	jelly_vessel.remove_jelly(H.species.blood_volume*(BLOOD_VOLUME_SLIME_SPLIT/100))

	var/datum/component/body_swapper/BS_original = H.get_component(/datum/component/body_swapper)
	BS_original.bodies |= spare

	var/datum/component/body_swapper/BS_spare = spare.get_component(/datum/component/body_swapper)
	BS_spare.bodies = BS_original.bodies

	spare.modifiers = H.modifiers.Copy()

	if(H.mind.transfer_to(spare))
		spare.visible_message("<span class='warning'>[H] distorts as a new body \
			\"steps out\" of [H].</span>",
			"<span class='notice'>...and after a moment of disorentation, \
			you're besides yourself!</span>")
		spare.update_action_buttons()


/datum/action/innate/swap_body
	name = "Swap Body"
	button_icon_state = "slimeswap"
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/swap_body/Activate()
	if(!ispromethean(owner))
		to_chat(owner, SPAN_WARNING("You are not a slimeperson."))
		Remove(owner)
	else
		tgui_interact(owner)

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

	var/datum/component/body_swapper/BS = H.get_component(/datum/component/body_swapper)
	var/list/data = list()
	data["bodies"] = list()
	for(var/b in BS.bodies)
		var/mob/living/carbon/human/body = b
		if(!body || QDELETED(body) || !ispromethean(body))
			BS.bodies -= b
			continue

		var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = body.internal_organs_by_name[BP_METROID]
		var/jelly_amount = jelly_vessel.stored_jelly

		var/list/L = list()
		L["htmlcolor"] = body.dna.mcolor
		var/area/A = get_area(get_turf(body))
		L["area"] = A.name
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
		L["exoticblood"] = jelly_amount
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

	var/datum/component/body_swapper/BS = H.get_component(/datum/component/body_swapper)

	var/mob/living/carbon/human/selected = locate(params["ref"]) in BS.bodies
	if(!can_swap(selected))
		return
	SStgui.close_uis(src)
	swap_to_dupe(H.mind, selected)

/datum/action/innate/swap_body/proc/can_swap(mob/living/carbon/human/dupe)
	var/mob/living/carbon/human/H = owner
	if(!ispromethean(H))
		return FALSE
	var/datum/component/body_swapper/BS = H.get_component(/datum/component/body_swapper)

	if(QDELETED(dupe)) //Is there a body?
		BS.bodies -= dupe
		return FALSE

	if(!ispromethean(dupe)) //Is it a slimeperson?
		BS.bodies -= dupe
		return FALSE

	if(dupe.stat == DEAD) //Is it alive?
		return FALSE

	if(dupe.stat == CONSCIOUS) //Is it awake?
		return FALSE

	if(dupe.mind && dupe.mind.active) //Is it unoccupied?
		return FALSE

	if(!(dupe in BS.bodies)) //Do we actually own it?
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
	dupe.update_action_buttons()
