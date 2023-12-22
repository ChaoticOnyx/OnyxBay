var/list/limb_icon_cache = list()

/// Layer for bodyparts that should appear behind every other bodypart - Mostly, legs when facing WEST or EAST
#define BODYPARTS_LOW_LAYER -2

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
	if(!isnull(human.s_tone) && (human.species.appearance_flags & HAS_A_SKIN_TONE))
		s_tone = human.s_tone
		if(human.species.appearance_flags & SECONDARY_HAIR_IS_SKIN)
			h_s_col = list(s_tone, s_tone, s_tone)
	if(human.species.appearance_flags & HAS_SKIN_COLOR)
		s_col = list(human.r_skin, human.g_skin, human.b_skin)
		if(human.species.appearance_flags & SECONDARY_HAIR_IS_SKIN)
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
	if(!isnull(dna.GetUIValue(DNA_UI_SKIN_TONE)) && (species.appearance_flags & HAS_A_SKIN_TONE))
		s_tone = dna.GetUIValue(DNA_UI_SKIN_TONE)
		if(species.appearance_flags & SECONDARY_HAIR_IS_SKIN)
			h_s_col = list(s_tone, s_tone, s_tone)
	if(species.appearance_flags & HAS_SKIN_COLOR)
		s_col = list(dna.GetUIValue(DNA_UI_SKIN_R), dna.GetUIValue(DNA_UI_SKIN_G), dna.GetUIValue(DNA_UI_SKIN_B))
		if(species.appearance_flags & SECONDARY_HAIR_IS_SKIN)
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

/obj/item/organ/external/proc/get_icon_key()
	. = list()

	var/gender = "_m"
	if(!(limb_flags & ORGAN_FLAG_GENDERED_ICON))
		gender = null
	else if(dna?.GetUIState(DNA_UI_GENDER))
		gender = "_f"
	else if(owner?.gender == FEMALE)
		gender = "_f"

	var/bb = ""
	if(owner)
		if(!BP_IS_ROBOTIC(src))
			bb = owner.body_build.index
		else
			bb = owner.body_build.roboindex

	. += "[organ_tag]"
	. += "[gender]"
	. += "[species.get_race_key(owner)]"
	. += "[bb]"
	. += is_stump() ? "_s" : ""
	if(owner?.mind?.special_role == "Zombie")
		. += "_z"

	if(force_icon)
		. += "[force_icon]"
	else if(BP_IS_ROBOTIC(src))
		. += "robot"
	else if(owner && (MUTATION_SKELETON in owner.mutations))
		. += "skeleton"
	else if(owner && (MUTATION_HUSK in owner.mutations))
		. += "husk"
	else if (owner && (MUTATION_HULK in owner.mutations))
		. += "hulk"

	//Colour, maybe simplify this one day and actually calculate it once
	if(status & ORGAN_DEAD)
		. += "_dead"

	if(s_tone)
		. += "_tone_[s_tone]"

	if(species && species.appearance_flags & HAS_SKIN_COLOR)
		if(s_col && length(s_col) >= 3)
			. += "_color_[s_col[1]]_[s_col[2]]_[s_col[3]]_[s_col_blend]"

	for(var/E in markings)
		var/datum/sprite_accessory/marking/M = E
		if (M.draw_target == MARKING_TARGET_SKIN)
			. += "-[M.name][markings[E]]]"

	return .


/obj/item/organ/external/on_update_icon()
	ClearOverlays()
	mob_overlays = list()

	/////
	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/husk = owner && (MUTATION_HUSK in owner.mutations)
	var/hulk = owner && (MUTATION_HULK in owner.mutations)
	var/zombie = owner?.mind?.special_role == "Zombie"

	/////
	var/gender = "_m"
	if(!(limb_flags & ORGAN_FLAG_GENDERED_ICON))
		gender = null
	else if (dna && dna.GetUIState(DNA_UI_GENDER))
		gender = "_f"
	else if(owner && owner.gender == FEMALE)
		gender = "_f"

	if(owner)
		if(!BP_IS_ROBOTIC(src))
			body_build = owner.body_build.index
		else
			body_build = owner.body_build.roboindex

	var/chosen_icon = ""
	var/chosen_icon_state = ""

	chosen_icon_state = "[icon_name][gender][body_build][zombie ? "_z" : ""]"

	/////
	if(force_icon)
		chosen_icon = force_icon
	else if(BP_IS_ROBOTIC(src))
		chosen_icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_main.dmi'
	else if(!dna)
		chosen_icon = 'icons/mob/human_races/r_human.dmi'
	else if(owner && (MUTATION_SKELETON in owner.mutations))
		chosen_icon = 'icons/mob/human_races/r_skeleton.dmi'
	else
		chosen_icon = species.get_icobase(owner)

	/////
	var/icon/temp_icon = icon(chosen_icon)
	var/list/icon_states = temp_icon.IconStates()
	if(!icon_states.Find(chosen_icon_state))
		if(icon_states.Find("[icon_name][gender][body_build]"))
			chosen_icon_state = "[icon_name][gender][body_build]"
		else if(icon_states.Find("[icon_name][gender]"))
			chosen_icon_state = "[icon_name][gender]"
		else if(icon_states.Find("[icon_name]"))
			chosen_icon_state = "[icon_name]"
		else
			CRASH("Can't find proper icon_state for \the [src] (key: [chosen_icon_state], icon: [chosen_icon]).")

	/////
	var/icon/mob_icon = apply_colouration(icon(chosen_icon, chosen_icon_state))
	if(husk)
		mob_icon.ColorTone(husk_color_mod)
	if(hulk)
		var/list/tone = ReadRGB(hulk_color_mod)
		mob_icon.MapColors(rgb(tone[1], 0, 0), rgb(0, tone[2], 0), rgb(0, 0, tone[3]))

	//	Handle husk overlay.
	if(husk && ("overlay_husk" in icon_states(chosen_icon)))
		var/icon/mask = new(chosen_icon)
		var/icon/husk_over = new(species.get_icobase(src), "overlay_husk")
		mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
		husk_over.Blend(mask, ICON_ADD)
		mob_icon.Blend(husk_over, ICON_OVERLAY)

	/////
	var/list/sorted = list()
	for(var/E in markings)
		var/datum/sprite_accessory/marking/M = E
		if(M.draw_target == MARKING_TARGET_SKIN)
			var/color = markings[E]
			var/icon/I = icon(M.icon, "[M.icon_state]-[organ_tag]")
			I.Blend(color, M.blend)
			ADD_SORTED(sorted, list(list(M.draw_order, I, M)), /proc/cmp_marking_order)

	for(var/entry in sorted) // Revisit this with blendmodes
		mob_icon.Blend(entry[2], entry[3]["layer_blend"])


	// Fix leg layering here
	// Alternatively you could use masks but it's about same amount of work
	// Note: This really only works because everything up until now was icon ops to build an icon we can work with
	// If we ever move to pure overlays for body hair / modifiers / cosmetic changes to a limb, look up daedalusdock's implementation
	if(icon_position & (LEFT | RIGHT))
		var/icon/under_icon = new('icons/mob/human_races/r_human.dmi', "blank")
		under_icon.Insert(icon(mob_icon, dir = NORTH), dir = NORTH)
		under_icon.Insert(icon(mob_icon, dir = SOUTH), dir = SOUTH)
		if(!(icon_position & LEFT))
			under_icon.Insert(icon(mob_icon, dir = EAST), dir = EAST)
		if(!(icon_position & RIGHT))
			under_icon.Insert(icon(mob_icon, dir = WEST), dir = WEST)

		// At this point, the icon has all the valid states for both left and right leg overlays
		mob_overlays += mutable_appearance(under_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS, layer = FLOAT_LAYER)

		if(icon_position & LEFT)
			under_icon.Insert(icon(mob_icon, dir = EAST), dir = EAST)
		if(icon_position & RIGHT)
			under_icon.Insert(icon(mob_icon, dir = WEST),dir = WEST)

		mob_overlays += mutable_appearance(under_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS, layer = FLOAT_LAYER + BODYPARTS_LOW_LAYER)
	else
		var/mutable_appearance/limb_appearance = mutable_appearance(mob_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS)
		if(icon_position & UNDER)
			limb_appearance.layer = BODYPARTS_LOW_LAYER
		mob_overlays += limb_appearance

	if(blocks_emissive)
		var/mutable_appearance/limb_em_block = emissive_blocker(chosen_icon, chosen_icon_state, FLOAT_LAYER)
		limb_em_block.dir = dir
		mob_overlays += limb_em_block

	AddOverlays(mob_overlays)
	dir = EAST
	icon = null

/obj/item/organ/external/proc/update_icon_drop(mob/living/carbon/human/powner)
	return

/obj/item/organ/external/proc/get_overlays()
	update_icon()
	return mob_overlays

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

/obj/item/organ/external/proc/apply_colouration(icon/applying)
	if(species && species.limbs_are_nonsolid)
		applying.MapColors("#4d4d4d","#969696","#1c1c1c", "#000000")
		if(species.name != SPECIES_HUMAN)
			applying.SetIntensity(1.5)
		else
			applying.SetIntensity(0.7)
		applying += rgb(,,,180) // Makes the icon translucent, SO INTUITIVE TY BYOND

	else if(status & ORGAN_DEAD)
		applying.ColorTone(rgb(10,50,0))
		applying.SetIntensity(0.7)

	if(s_tone)
		if(s_tone >= 0)
			applying.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			applying.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
	if(species && species.appearance_flags & HAS_SKIN_COLOR)
		if(s_col && s_col.len >= 3)
			applying.Blend(rgb(s_col[1], s_col[2], s_col[3]), s_col_blend)

	return applying

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
