//Luminescents are able to consume and use metroid extracts, without them decaying.
/datum/component/extract_eater
	/// The metroid extract we currently have integrated
	var/obj/item/metroid_extract/current_extract
	/// The cooldown of us using exteracts
	var/extract_cooldown = 0
	/// How strong is our glow
	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	/// A list of all luminescent related actions we have
	var/list/luminescent_actions

/datum/component/extract_eater/Destroy(force, silent)
	. = ..()
	for(var/datum/action/A in luminescent_actions)
		A.Remove(parent)

/datum/species/promethean/luminescent
	name = SPECIES_LUMINESCENT
	icobase = 'icons/mob/human_races/prometheans/r_luminescent.dmi'

/datum/species/promethean/luminescent/New()
	. = ..()
	add_think_ctx("update_glow", CALLBACK(src, nameof(.proc/update_glow)), 0)

/datum/species/promethean/luminescent/handle_post_spawn(mob/living/carbon/human/new_jellyperson)
	. = ..()

	var/datum/component/extract_eater/extract_eater_comp = new_jellyperson.AddComponent(/datum/component/extract_eater)
	new_jellyperson.set_light(1, 0.5, extract_eater_comp.glow_intensity, 2, new_jellyperson.dna.mcolor)
	extract_eater_comp.luminescent_actions = list()

	var/datum/action/innate/integrate_extract/integrate_extract = new(src)
	integrate_extract.Grant(new_jellyperson)
	extract_eater_comp.luminescent_actions += integrate_extract

	var/datum/action/cooldown/use_extract/extract_minor = new(src)
	extract_minor.Grant(new_jellyperson)
	extract_eater_comp.luminescent_actions += extract_minor

	var/datum/action/cooldown/use_extract/major/extract_major = new(src)
	extract_major.Grant(new_jellyperson)
	extract_eater_comp.luminescent_actions += extract_major
	spawn(5)
		new_jellyperson.update_action_buttons()

/datum/species/promethean/luminescent/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/component/extract_eater/extract_eater_comp = H.get_component(/datum/component/extract_eater)

	for(var/datum/action/A in extract_eater_comp.luminescent_actions)
		A.Remove(H)

	spawn(1)
		H.update_action_buttons()
	H.light.destroy()
	qdel(extract_eater_comp)

/// Updates the glow of our internal glow thing.
/datum/species/promethean/luminescent/proc/update_glow(mob/living/carbon/C, intensity)
	var/datum/component/extract_eater/extract_eater_comp = C.get_component(/datum/component/extract_eater)
	if(!extract_eater_comp)
		return
	if(intensity)
		extract_eater_comp.glow_intensity = intensity
	else
		extract_eater_comp.glow_intensity = LUMINESCENT_DEFAULT_GLOW
	C.set_light(1, 0.5, extract_eater_comp.glow_intensity, extract_eater_comp.glow_intensity, C.dna.mcolor)

/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "metroidconsume"
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/integrate_extract/New(Target)
	. = ..()

/// Callback for /datum/component/action_item_overlay to find the metroid extract from within the species
/datum/action/innate/integrate_extract/proc/locate_extract()
	var/datum/component/extract_eater/extract_eater_comp = owner.get_component(/datum/component/extract_eater)
	if(!istype(extract_eater_comp))
		return null

	return extract_eater_comp.current_extract

/datum/action/innate/integrate_extract/proc/update_button()
	var/datum/component/extract_eater/extract_eater_comp = owner.get_component(/datum/component/extract_eater)
	if(!istype(extract_eater_comp) || !extract_eater_comp.current_extract)
		name = "Integrate Extract"
		button_icon_state = "metroidconsume"
		button.update_icon()
	else
		name = "Eject Extract"
		button_icon_state = "metroideject"
		button.AddOverlays(image(extract_eater_comp.current_extract.icon, icon_state = extract_eater_comp.current_extract.icon_state))


/datum/action/innate/integrate_extract/Activate()
	var/mob/living/carbon/human/human_owner = owner
	var/datum/component/extract_eater/extract_eater_comp = owner.get_component(/datum/component/extract_eater)
	if(!istype(extract_eater_comp))
		return

	if(extract_eater_comp.current_extract)
		var/obj/item/metroid_extract/to_remove = extract_eater_comp.current_extract
		if(!human_owner.put_in_active_hand(to_remove))
			to_remove.forceMove(human_owner.drop_location())

		extract_eater_comp.current_extract = null
		to_chat(human_owner, SPAN_NOTICE("[to_remove.name] ejected"))

	else
		var/obj/item/metroid_extract/to_integrate = human_owner.get_active_item()
		if(!istype(to_integrate) || to_integrate.Uses <= 0)
			to_chat(human_owner, SPAN_NOTICE("Need an unused metroid extract!"))
			return
		if(!human_owner.can_unequip(to_integrate))
			return
		human_owner.drop(to_integrate)
		to_integrate.forceMove(human_owner)
		extract_eater_comp.current_extract = to_integrate
		to_chat(human_owner, SPAN_NOTICE("[to_integrate.name] consumed"))

	for(var/datum/action/to_update as anything in extract_eater_comp.luminescent_actions)
		to_update.button.update_icon()

/datum/action/cooldown/use_extract
	name = "Extract Minor Activation"
	action_type = AB_INNATE
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "metroiduse1"
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_alien"
	var/activation_type = METROID_ACTIVATE_MINOR
	shared_cooldown = TRUE

/datum/action/cooldown/use_extract/New(Target)
	. = ..()


/// Callback for /datum/component/action_item_overlay to find the metroid extract from within the species
/datum/action/cooldown/use_extract/proc/locate_extract()
	var/datum/component/extract_eater/extract_eater_comp = owner.get_component(/datum/component/extract_eater)
	if(!istype(extract_eater_comp))
		return null

	return extract_eater_comp.current_extract

/datum/action/cooldown/use_extract/IsAvailable(feedback = FALSE)
	. = ..()
	var/datum/component/extract_eater/extract_eater_comp = owner.get_component(/datum/component/extract_eater)
	if(istype(extract_eater_comp) && extract_eater_comp.current_extract && .)
		return TRUE
	return FALSE

/datum/action/cooldown/use_extract/Activate()
	if(!IsAvailable())
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	var/datum/component/extract_eater/extract_eater_comp = owner.get_component(/datum/component/extract_eater)
	if(!istype(extract_eater_comp) || !extract_eater_comp.current_extract)
		return

	extract_eater_comp.extract_cooldown = world.time + 10 SECONDS
	var/after_use_cooldown = extract_eater_comp.current_extract.activate(human_owner, extract_eater_comp, activation_type)
	cooldown_time = after_use_cooldown
	StartCooldown()

/datum/action/cooldown/use_extract/major
	name = "Extract Major Activation"
	button_icon_state = "metroiduse2"
	activation_type = METROID_ACTIVATE_MAJOR
	shared_cooldown = TRUE
