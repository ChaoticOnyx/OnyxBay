//Luminescents are able to consume and use slime extracts, without them decaying.

/datum/species/jelly/luminescent
	name = "Luminescent"
	plural_form = null
	id = SPECIES_LUMINESCENT
	examine_limb_id = SPECIES_LUMINESCENT
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/luminescent,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/luminescent,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/luminescent,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/luminescent,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/luminescent,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/luminescent,
	)
	mutanteyes = /obj/item/organ/internal/eyes
	/// How strong is our glow
	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	/// Internal dummy used to glow (very cool)
	var/obj/effect/dummy/luminescent_glow/glow
	/// The slime extract we currently have integrated
	var/obj/item/slime_extract/current_extract
	/// A list of all luminescent related actions we have
	var/list/luminescent_actions
	/// The cooldown of us using exteracts
	COOLDOWN_DECLARE(extract_cooldown)

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/jelly/luminescent/Destroy(force, ...)
	current_extract = null
	QDEL_NULL(glow)
	QDEL_LIST(luminescent_actions)
	return ..()


/datum/species/jelly/luminescent/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(current_extract)
		current_extract.forceMove(C.drop_location())
		current_extract = null
	QDEL_NULL(glow)
	QDEL_LIST(luminescent_actions)

/datum/species/jelly/luminescent/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species)
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
/datum/species/jelly/luminescent/proc/update_glow(mob/living/carbon/C, intensity)
	if(intensity)
		glow_intensity = intensity
	glow.set_light_range_power_color(glow_intensity, glow_intensity, C.dna.features["mcolor"])

/obj/effect/dummy/luminescent_glow
	name = "luminescent glow"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_system = MOVABLE_LIGHT
	light_range = LUMINESCENT_DEFAULT_GLOW
	light_power = 2.5
	light_color = COLOR_WHITE

/obj/effect/dummy/luminescent_glow/Initialize(mapload)
	. = ..()
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL


/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	desc = "Eat a slime extract to use its properties."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeconsume"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/integrate_extract/New(Target)
	. = ..()
	AddComponent(/datum/component/action_item_overlay, item_callback = CALLBACK(src, PROC_REF(locate_extract)))

/// Callback for /datum/component/action_item_overlay to find the slime extract from within the species
/datum/action/innate/integrate_extract/proc/locate_extract()
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species))
		return null

	return species.current_extract

/datum/action/innate/integrate_extract/update_button_name(atom/movable/screen/movable/action_button/button, force = FALSE)
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species) || !species.current_extract)
		name = "Integrate Extract"
		desc = "Eat a slime extract to use its properties."
	else
		name = "Eject Extract"
		desc = "Eject your current slime extract."

	return ..()

/datum/action/innate/integrate_extract/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species) || !species.current_extract)
		button_icon_state = "slimeconsume"
	else
		button_icon_state = "slimeeject"

	return ..()

/datum/action/innate/integrate_extract/Activate()
	var/mob/living/carbon/human/human_owner = owner
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species))
		return

	if(species.current_extract)
		var/obj/item/slime_extract/to_remove = species.current_extract
		if(!human_owner.put_in_active_hand(to_remove))
			to_remove.forceMove(human_owner.drop_location())

		species.current_extract = null
		human_owner.balloon_alert(human_owner, "[to_remove.name] ejected")

	else
		var/obj/item/slime_extract/to_integrate = human_owner.get_active_held_item()
		if(!istype(to_integrate) || to_integrate.Uses <= 0)
			human_owner.balloon_alert(human_owner, "need an unused slime extract!")
			return
		if(!human_owner.temporarilyRemoveItemFromInventory(to_integrate))
			return
		to_integrate.forceMove(human_owner)
		species.current_extract = to_integrate
		human_owner.balloon_alert(human_owner, "[to_integrate.name] consumed")

	for(var/datum/action/to_update as anything in species.luminescent_actions)
		to_update.build_all_button_icons()

/datum/action/innate/use_extract
	name = "Extract Minor Activation"
	desc = "Pulse the slime extract with energized jelly to activate it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeuse1"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	var/activation_type = SLIME_ACTIVATE_MINOR

/datum/action/innate/use_extract/New(Target)
	. = ..()
	AddComponent(/datum/component/action_item_overlay, item_callback = CALLBACK(src, PROC_REF(locate_extract)))

/// Callback for /datum/component/action_item_overlay to find the slime extract from within the species
/datum/action/innate/use_extract/proc/locate_extract()
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species))
		return null

	return species.current_extract

/datum/action/innate/use_extract/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return

	var/datum/species/jelly/luminescent/species = target
	if(istype(species) && species.current_extract && (COOLDOWN_FINISHED(species, extract_cooldown)))
		return TRUE
	return FALSE

/datum/action/innate/use_extract/Activate()
	var/mob/living/carbon/human/human_owner = owner
	var/datum/species/jelly/luminescent/species = human_owner.dna?.species
	if(!istype(species) || !species.current_extract)
		return

	COOLDOWN_START(species, extract_cooldown, 10 SECONDS)
	var/after_use_cooldown = species.current_extract.activate(human_owner, species, activation_type)
	COOLDOWN_START(species, extract_cooldown, after_use_cooldown)

/datum/action/innate/use_extract/major
	name = "Extract Major Activation"
	desc = "Pulse the slime extract with plasma jelly to activate it."
	button_icon_state = "slimeuse2"
	activation_type = SLIME_ACTIVATE_MAJOR
