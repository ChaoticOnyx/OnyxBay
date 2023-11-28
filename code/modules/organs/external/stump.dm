/obj/item/organ/external/stump
	name = "limb stump"
	icon_name = ""
	dislocated = -1
	disable_food_organ = TRUE

/obj/item/organ/external/stump/New(mob/living/carbon/holder, obj/item/organ/external/limb)
	if(istype(limb))
		organ_tag = limb.organ_tag
		if(!BP_IS_ROBOTIC(limb)) // These nasty fucks are broken, fuck robolimbs, their dumb icons and whomever the fuck created them in their current fucking state
			icon_name = limb.icon_name
		body_part = limb.body_part
		amputation_point = limb.amputation_point
		joint = limb.joint
		parent_organ = limb.parent_organ
		if(limb.limb_flags & ORGAN_FLAG_GENDERED_ICON)
			limb_flags |= ORGAN_FLAG_GENDERED_ICON
	..(holder)
	if(istype(limb))
		max_damage = limb.max_damage
		if(BP_IS_ROBOTIC(limb) && (!parent || BP_IS_ROBOTIC(parent)))
			robotize() //if both limb and the parent are robotic, the stump is robotic too

/obj/item/organ/external/stump/is_stump()
	return 1

/obj/item/organ/external/stump/rejuvenate(ignore_prosthetic_prefs)
	. = ..()
	var/mob/living/carbon/human/H = owner
	removed(drop_organ = FALSE)
	H.restore_limb(organ_tag)
	if(organ_tag == BP_L_ARM||organ_tag == BP_R_ARM)
		H.restore_limb(organ_tag==BP_L_ARM?BP_L_HAND:BP_R_HAND)

	if(organ_tag == BP_L_LEG||organ_tag == BP_R_LEG)
		H.restore_limb(organ_tag==BP_L_LEG?BP_L_FOOT:BP_R_FOOT)

	H.regenerate_icons()

/obj/item/organ/external/stump/update_damstate()
	damage_state = "00"
	return

// Cut version of ../external/on_update_icon(), since stumps don't need THAT much stuff
/obj/item/organ/external/stump/on_update_icon()
	ClearOverlays()
	mob_overlays = list()

	/////
	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/husk = owner && (MUTATION_HUSK in owner.mutations)
	var/hulk = owner && (MUTATION_HULK in owner.mutations)

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

	var/stump_icon = is_stump() ? "_s" : ""
	chosen_icon_state = "[icon_name][gender][body_build][stump_icon]"

	/////
	if(force_icon)
		chosen_icon = force_icon
	else if(BP_IS_ROBOTIC(src))
		chosen_icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_main.dmi'
	else if(!dna)
		chosen_icon = 'icons/mob/human_races/r_human.dmi'
	else
		chosen_icon = species.get_icobase(owner)

	/////
	var/icon/temp_icon = icon(chosen_icon)
	var/list/icon_states = temp_icon.IconStates()
	if(!icon_states.Find(chosen_icon_state))
		dir = EAST
		icon = null
		return // Just cutting it here fuck drawing stumps for everything

	/////
	var/icon/mob_icon = apply_colouration(icon(chosen_icon, chosen_icon_state))
	if(husk)
		mob_icon.ColorTone(husk_color_mod)
	if(hulk)
		var/list/tone = ReadRGB(hulk_color_mod)
		mob_icon.MapColors(rgb(tone[1], 0, 0), rgb(0, tone[2], 0), rgb(0, 0, tone[3]))

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
		var/mutable_appearance/upper_appearance = mutable_appearance(under_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS)
		upper_appearance.layer = FLOAT_LAYER
		mob_overlays += upper_appearance

		if(icon_position & LEFT)
			under_icon.Insert(icon(mob_icon, dir = EAST), dir = EAST)
		if(icon_position & RIGHT)
			under_icon.Insert(icon(mob_icon, dir = WEST),dir = WEST)

		var/mutable_appearance/under_appearance = mutable_appearance(under_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS)
		upper_appearance.layer = BODYPARTS_LOW_LAYER
		mob_overlays += under_appearance
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
