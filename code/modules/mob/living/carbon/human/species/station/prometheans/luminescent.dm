//Luminescents are able to consume and use metroid extracts, without them decaying.

/datum/species/promethean/luminescent
	name = SPECIES_LUMINESCENT
	/// How strong is our glow
	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	/// Internal dummy used to glow (very cool)
	var/obj/effect/dummy/luminescent_glow/glow
	/// The metroid extract we currently have integrated
	var/obj/item/metroid_extract/current_extract
	/// A list of all luminescent related actions we have
	var/list/luminescent_actions
	/// The cooldown of us using exteracts
	var/extract_cooldown = 0

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/promethean/luminescent/Destroy(force, ...)
	current_extract = null
	QDEL_NULL(glow)
	QDEL_LIST(luminescent_actions)
	return ..()

/datum/species/promethean/luminescent/handle_post_spawn(mob/living/carbon/human/new_jellyperson)
	. = ..()
	glow = new(new_jellyperson)
	update_glow(new_jellyperson)

	luminescent_actions = list()

	var/datum/action/innate/integrate_extract/integrate_extract = new(src)
	integrate_extract.Grant(new_jellyperson)
	luminescent_actions += integrate_extract

	var/datum/action/innate/use_extract/extract_minor = new(src)
	extract_minor.Grant(new_jellyperson)
	luminescent_actions += extract_minor

	var/datum/action/innate/use_extract/major/extract_major = new(src)
	extract_major.Grant(new_jellyperson)
	luminescent_actions += integrate_extract

/// Updates the glow of our internal glow thing.
/datum/species/promethean/luminescent/proc/update_glow(mob/living/carbon/C, intensity)
	if(intensity)
		glow_intensity = intensity
	glow.set_light(glow_intensity, glow_intensity, l_color = C.dna.mcolor)

/obj/effect/dummy/luminescent_glow
	name = "luminescent glow"
	desc = "Tell a coder if you're seeing this."
	var/light_range = LUMINESCENT_DEFAULT_GLOW
	var/light_power = 2.5
	light_color = COLOR_WHITE

/obj/effect/dummy/luminescent_glow/Initialize(mapload)
	. = ..()
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL
	set_light(light_power, LUMINESCENT_DEFAULT_GLOW, l_color = light_color)


/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	//desc = "Eat a metroid extract to use its properties."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "metroidconsume"
	button_icon = 'icons/mob/actions/actions_metroid.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/integrate_extract/New(Target)
	. = ..()

/// Callback for /datum/component/action_item_overlay to find the metroid extract from within the species
/datum/action/innate/integrate_extract/proc/locate_extract()
	var/datum/species/promethean/luminescent/species = target
	if(!istype(species))
		return null

	return species.current_extract

/datum/action/innate/integrate_extract/proc/update_button()
	var/datum/species/promethean/luminescent/species = target
	if(!istype(species) || !species.current_extract)
		name = "Integrate Extract"
		button_icon_state = "metroidconsume"
		button.UpdateIcon()
		//desc = "Eat a metroid extract to use its properties."
	else
		name = "Eject Extract"
		button_icon_state = "metroideject"
		button.overlays += image(species.current_extract.icon, icon_state = species.current_extract.icon_state)
		//desc = "Eject your current metroid extract."


/datum/action/innate/integrate_extract/Activate()
	var/mob/living/carbon/human/human_owner = owner
	var/datum/species/promethean/luminescent/species = target
	if(!istype(species))
		return

	if(species.current_extract)
		var/obj/item/metroid_extract/to_remove = species.current_extract
		if(!human_owner.put_in_active_hand(to_remove))
			to_remove.forceMove(human_owner.drop_location())

		species.current_extract = null
		to_chat(human_owner, SPAN_NOTICE("[to_remove.name] ejected"))

	else
		var/obj/item/metroid_extract/to_integrate = human_owner.get_active_item()
		if(!istype(to_integrate) || to_integrate.Uses <= 0)
			to_chat(human_owner, SPAN_NOTICE("Need an unused metroid extract!"))
			return
		if(!human_owner.can_unequip(to_integrate))
			return
		to_integrate.forceMove(human_owner)
		species.current_extract = to_integrate
		to_chat(human_owner, SPAN_NOTICE("[to_integrate.name] consumed"))

	for(var/datum/action/to_update as anything in species.luminescent_actions)
		to_update.button.UpdateIcon()

/datum/action/innate/use_extract
	name = "Extract Minor Activation"
	//desc = "Pulse the metroid extract with energized jelly to activate it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "metroiduse1"
	button_icon = 'icons/mob/actions/actions_metroid.dmi'
	background_icon_state = "bg_alien"
	var/activation_type = METROID_ACTIVATE_MINOR

/datum/action/innate/use_extract/New(Target)
	. = ..()


/// Callback for /datum/component/action_item_overlay to find the metroid extract from within the species
/datum/action/innate/use_extract/proc/locate_extract()
	var/datum/species/promethean/luminescent/species = target
	if(!istype(species))
		return null

	return species.current_extract

/datum/action/innate/use_extract/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return

	var/datum/species/promethean/luminescent/species = target
	species.extract_cooldown < world.time
	if(istype(species) && species.current_extract && (species.extract_cooldown < world.time))
		return TRUE
	return FALSE

/datum/action/innate/use_extract/Activate()
	if(!IsAvailable())
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	var/datum/species/promethean/luminescent/species = human_owner.dna?.species
	if(!istype(species) || !species.current_extract)
		return

	species.extract_cooldown = world.time + 10 SECONDS
	var/after_use_cooldown = species.current_extract.activate(human_owner, species, activation_type)
	species.extract_cooldown = world.time + after_use_cooldown

/datum/action/innate/use_extract/major
	name = "Extract Major Activation"
	//desc = "Pulse the metroid extract with plasma jelly to activate it."
	button_icon_state = "metroiduse2"
	activation_type = METROID_ACTIVATE_MAJOR
