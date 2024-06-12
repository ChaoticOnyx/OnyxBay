/obj/item/organ/external/set_dir()
	return

/obj/item/organ/external/proc/compile_icon()
	ClearOverlays()
	update_icon()

/obj/item/organ/external/proc/sync_colour_to_human(mob/living/carbon/human/human)
	s_tone = null
	s_col = null
	s_base = ""
	h_col = list(human.r_hair, human.g_hair, human.b_hair)
	h_s_col = list(human.r_s_hair, human.g_s_hair, human.b_s_hair)
	if(BP_IS_ROBOTIC(src))
		var/datum/robolimb/franchise = GLOB.all_robolimbs[model]
		if(!(franchise && franchise.skintone))
			return
	if(species && human.species && species.name != human.species.name)
		return
	if(!isnull(human.s_tone) && (human.species.species_appearance_flags & HAS_A_SKIN_TONE))
		s_tone = human.s_tone
		if(human.species.species_appearance_flags & SECONDARY_HAIR_IS_SKIN)
			h_s_col = list(s_tone, s_tone, s_tone)
	if(human.species.species_appearance_flags & HAS_SKIN_COLOR)
		s_col = list(human.r_skin, human.g_skin, human.b_skin)
		if(human.species.species_appearance_flags & SECONDARY_HAIR_IS_SKIN)
			h_s_col = s_col

/obj/item/organ/external/proc/sync_colour_to_dna()
	s_tone = null
	s_col = null
	s_base = dna.s_base
	h_col = list(dna.GetUIValue(DNA_UI_HAIR_R),dna.GetUIValue(DNA_UI_HAIR_G),dna.GetUIValue(DNA_UI_HAIR_B))
	h_s_col = list(dna.GetUIValue(DNA_UI_S_HAIR_R),dna.GetUIValue(DNA_UI_S_HAIR_G),dna.GetUIValue(DNA_UI_S_HAIR_B))
	if(BP_IS_ROBOTIC(src))
		var/datum/robolimb/franchise = GLOB.all_robolimbs[model]
		if(!(franchise && franchise.skintone))
			return
	if(!isnull(dna.GetUIValue(DNA_UI_SKIN_TONE)) && (species.species_appearance_flags & HAS_A_SKIN_TONE))
		s_tone = dna.GetUIValue(DNA_UI_SKIN_TONE)
		if(species.species_appearance_flags & SECONDARY_HAIR_IS_SKIN)
			h_s_col = list(s_tone, s_tone, s_tone)
	if(species.species_appearance_flags & HAS_SKIN_COLOR)
		s_col = list(dna.GetUIValue(DNA_UI_SKIN_R), dna.GetUIValue(DNA_UI_SKIN_G), dna.GetUIValue(DNA_UI_SKIN_B))
		if(species.species_appearance_flags & SECONDARY_HAIR_IS_SKIN)
			h_s_col = s_col

/obj/item/organ/external/head/sync_colour_to_human(mob/living/carbon/human/human)
	..()
	var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[BP_EYES]
	if(eyes) eyes.update_colour()

/obj/item/organ/external/head/removed()
	update_icon()
	if(!owner)
		return

	SetName("[owner.real_name]'s head")
	var/mob/living/carbon/human/victim = owner
	..()
	update_icon_drop(victim)
	victim.update_hair()
	victim.update_facial_hair()

// Returns an image for use by the human health dolly HUD element.
// If the limb is in pain, it will be used as a minimum damage
// amount to represent the obfuscation of being in agonizing pain.

// Global scope, used in code below.
var/list/flesh_hud_colours = list("#00ff00","#aaff00","#ffff00","#ffaa00","#ff0000","#aa0000","#660000")
var/list/robot_hud_colours = list("#ffffff","#cccccc","#aaaaaa","#888888","#666666","#444444","#222222","#000000")

/obj/item/organ/external/proc/get_damage_hud_image(painkiller_mult = 0)

	// Species-standardized old-school health icon
	// Probably works faster than the new fancy bodyshape-reflective system
	if(!hud_damage_image)
		var/image/temp = image('icons/hud/common/screen_health.dmi', "[icon_name]")
		if(species)
			// Calculate the required colour matrix.
			var/r = 0.30 * species.health_hud_intensity
			var/g = 0.59 * species.health_hud_intensity
			var/b = 0.11 * species.health_hud_intensity
			temp.color = list(r, r, r, g, g, g, b, b, b)
		hud_damage_image = image(null)
		hud_damage_image.AddOverlays(temp)


	// Calculate the required color index.
	var/dam_state = min(1, ((brute_dam + burn_dam) / max(1, max_damage)))
	var/min_dam_state = min(1, (full_pain / max(1, max_damage)))
	if(min_dam_state && dam_state < min_dam_state)
		dam_state = min_dam_state
	// Apply colour and return product.
	var/list/hud_colours = !BP_IS_ROBOTIC(src) ? flesh_hud_colours : robot_hud_colours
	var/final_color = hud_colours[max(1, min(ceil(dam_state * hud_colours.len), hud_colours.len))]
	if(painkiller_mult)
		final_color = gradient(final_color, "#bfbfbf", min(painkiller_mult, 0.9))
	hud_damage_image.color = final_color
	return hud_damage_image

/obj/item/organ/external/proc/bandage_level()
	if(damage_state_text() == "00")
		return 0
	if(!is_bandaged())
		return 0
	if(burn_dam + brute_dam == 0)
		. = 0
	else if (burn_dam + brute_dam < (max_damage * 0.25 / 2))
		. = 1
	else if (burn_dam + brute_dam < (max_damage * 0.75 / 2))
		. = 2
	else
		. = 3
