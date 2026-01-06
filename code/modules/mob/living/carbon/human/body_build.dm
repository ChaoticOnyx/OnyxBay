var/global/datum/body_build/default_body_build = new


/datum/body_build
	var/name         = "Default"

	var/genders      = list(MALE, FEMALE)
	var/index        = ""
	var/roboindex    = ""  // for slim and slim_alt BBs prothesis
	var/misk_icon    = 'icons/mob/mob.dmi'
	var/list/clothing_icons = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob.dmi',
		"slot_gloves"	 = 'icons/inv_slots/gloves/mob.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand.dmi'
		)

	var/rig_back      = 'icons/inv_slots/rig/mob.dmi'
	var/blood_icon    = 'icons/mob/human_races/masks/blood_human.dmi'
	var/dam_mask      = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	var/bandages_icon = 'icons/mob/human_races/bandages/mob.dmi'

	var/movespeed_modifier = /datum/movespeed_modifier/bodybuild
	var/equipment_modifier = 0 // Positive values allow to partially ignore equipment_slowdown, negative values apply additional slowdown if any slowing-down equipment is being worn
	var/poise_pool         = HUMAN_DEFAULT_POISE
	var/stomach_capacity   = STOMACH_CAPACITY_NORMAL
	var/ambiguous_gender   = FALSE // If TRUE, both females and females will be PLURAL if there's no beard and their groin is covered
	var/melee_modifier     = 1.0
	var/climb_speed        = 1.0 // Climbing tables, etc.; lower is faster

	var/list/equip_adjust
	var/list/equip_overlays = list()

/datum/body_build/proc/get_mob_icon(slot, icon_state)
	var/icon/I

	if(!(slot in default_onmob_slots))
		to_world_log("##ERROR. Wrong sprite group for mob icon \"[slot]\"")
		return I // Nonexistent slot, just give 'em an empty icon

	for(var/datum/body_build/BB in list(src, default_body_build))
		if(slot == slot_handcuffed_str || slot == slot_legcuffed_str)
			I = BB.misk_icon
		else
			I = BB.clothing_icons[slot]

		if(icon_state in GLOB.bb_clothing_icon_states[BB.type][slot])
			break

	return I

/datum/body_build/slim
	name                 = "Slim"

	index                = "_slim"
	roboindex            = "_slim"
	genders              = list(FEMALE)
	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_slim.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_slim.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_slim.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob_slim.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob_slim.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r_slim.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_slim.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_slim.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob_slim.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob_slim.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob_slim.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_slim.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_slim.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand_slim.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand_slim.dmi'
		)
	rig_back             = 'icons/inv_slots/rig/mob_slim.dmi'
	blood_icon           = 'icons/mob/human_races/masks/blood_human_slim.dmi'
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_human_slim.dmi'
	bandages_icon        = 'icons/mob/human_races/bandages/mob_slim.dmi'

	stomach_capacity   = STOMACH_CAPACITY_LOW
	poise_pool         = HUMAN_LOW_POISE
	melee_modifier     = 0.75 // It's kinda hard to club people when you're two times thinner than a regular person.

	equip_adjust = list(
		"slot_l_hand" = list(
			"SOUTH" = list("x" = -1, "y" = 0),
			"NORTH" = list("x" =  1, "y" = 0),
			"EAST"  = list("x" = -2, "y" = 0)
			),
		"slot_r_hand" = list(
			"SOUTH" = list("x" =  1, "y" = 0),
			"NORTH" = list("x" = -1, "y" = 0),
			"WEST"  = list("x" =  2, "y" = 0)
			)
		)

/datum/body_build/slim/alt
	name                 = "Slim Alt"
	index                = "_slim_alt"
	roboindex            = "_slim_alt"
	genders              = list(FEMALE)
	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_slimalt.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_slimalt.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_slim.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob_slim.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob_slim.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r_slim.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_slim.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_slimalt.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob_slim.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob_slim.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob_slim.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_slim.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_slimalt.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand_slim.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand_slim.dmi'
		)
	blood_icon           = 'icons/mob/human_races/masks/blood_human_slim_alt.dmi'
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_human_slim_alt.dmi'
	bandages_icon        = 'icons/mob/human_races/bandages/mob_slim_alt.dmi'

/datum/body_build/slim/male
	name                 = "Slim"
	index                = "_slim"
	roboindex            = "_slim"
	genders              = list(MALE)
	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_slim_m.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_slim_m.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_slim.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob_slim.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob_slim.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r_slim.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_slim.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_slim.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob_slim.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob_slim.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob_slim_m.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_slim_m.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_slim_m.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand_slim.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand_slim.dmi'
		)
	blood_icon           = 'icons/mob/human_races/masks/blood_human_m_slim.dmi'
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_human_m_slim.dmi'

	ambiguous_gender = TRUE

/datum/body_build/slim/flat
	name                 = "Slim Flat"
	index                = "_slim_flat"
	roboindex            = "_slim_flat"
	genders              = list(FEMALE)
	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_slim_m.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_slim_m.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_slim.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob_slim.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob_slim.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r_slim.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_slim.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_slim.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob_slim.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob_slim.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob_slim_m.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_slim_m.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_slim_flat.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand_slim.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand_slim.dmi'
		)
	blood_icon           = 'icons/mob/human_races/masks/blood_human_m_slim.dmi'
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_human_m_slim.dmi'

	ambiguous_gender = TRUE

/datum/body_build/fat
	name                 = "Fat"
	index                = "_fat"
	roboindex            = "_fat"
	genders              = list(MALE, FEMALE)
	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_fat.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_fat.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_fat.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob_fat.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob_fat.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob_fat.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_fat.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_fat.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand.dmi'
		)
	rig_back             = 'icons/inv_slots/rig/mob_fat.dmi'
	blood_icon           = 'icons/mob/human_races/masks/blood_human.dmi'
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	bandages_icon        = 'icons/mob/human_races/bandages/mob_fat.dmi'

	stomach_capacity   = STOMACH_CAPACITY_HIGH
	movespeed_modifier = /datum/movespeed_modifier/bodybuild/fat
	equipment_modifier = 0.5
	poise_pool         = HUMAN_HIGH_POISE
	ambiguous_gender   = TRUE
	melee_modifier     = 1.15 // Force is acceleration times MASS, so...
	climb_speed        = 2.5 // You're a landwhale; not a, what, tablewhale?


/datum/body_build/slim/alt/tajaran //*sigh. I regret of doing this.
	name                 = "Slim Tajaran"

	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_slimalt.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_slimalt_tajaran.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_slim.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob_slim.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob_slim.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r_slim.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_tajaran.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob_tajaran.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_slimalt.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob_slim.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob_slim.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob_slim.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_slim.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_slimalt.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand_slim.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand_slim.dmi'
		)

	rig_back             = 'icons/inv_slots/rig/mob_slim.dmi'
	blood_icon           = 'icons/mob/human_races/masks/blood_human_slim.dmi'
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_tajaran_slim.dmi'

	equipment_modifier = -0.5
	climb_speed = 0.75

/datum/body_build/tajaran
	name                 = "Tajaran"

	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_tajaran.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_tajaran.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_tajaran.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob_tajaran.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_tajaran.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_tajaran.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand.dmi'
		)
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_tajaran.dmi'
	climb_speed = 0.75

/datum/body_build/tajaran/fat
	name                 = "Fat Tajaran"
	index                = "_fat"
	roboindex            = "_fat"
	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_fat.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_fat.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_fat.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_tajaran.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob_tajaran.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_tajaran.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob_fat.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob_fat.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_fat.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_fat.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand.dmi'
		)
	rig_back             = 'icons/inv_slots/rig/mob_fat.dmi'
	bandages_icon        = 'icons/mob/human_races/bandages/mob_fat.dmi'

	movespeed_modifier = /datum/movespeed_modifier/bodybuild/fat
	equipment_modifier = 0.5
	poise_pool         = HUMAN_HIGH_POISE
	ambiguous_gender   = TRUE
	climb_speed        = 1.0 // Even a OH-LAWD-CHONK-BOI-fat cat is at least as agile as a normal human

/datum/body_build/unathi
	name                 = SPECIES_UNATHI

	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob.dmi', // They DO have their own assigned DMI but, well, just take a look yourself and leave it be.
		"slot_gloves"    = 'icons/inv_slots/gloves/mob.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob.dmi',
		"slot_l_ear"     = 'icons/inv_slots/ears/mob.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_unathi.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob_unathi.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob_unathi.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand.dmi'
		)
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_lizard.dmi'

	poise_pool         = HUMAN_HIGH_POISE
	melee_modifier     = 1.15

/datum/body_build/vox
	name                 = "Vox"

	clothing_icons       = list(
		"slot_w_uniform" = 'icons/inv_slots/uniforms/mob_vox.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob_vox.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob_vox.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob_vox.dmi',,
		"slot_l_ear"     = 'icons/inv_slots/ears/mob.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob_vox.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob_vox.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob_vox.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob.dmi',
		"slot_tie"       = 'icons/inv_slots/acessories/mob_vox.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand.dmi'
		)

/datum/body_build/monkey
	name                 = "Monkey"

	clothing_icons       = list(
		"slot_w_uniform" = 'icons/mob/species/monkey/uniform.dmi',
		"slot_suit"      = 'icons/inv_slots/suits/mob.dmi',
		"slot_gloves"    = 'icons/inv_slots/gloves/mob.dmi',
		"slot_glasses"   = 'icons/inv_slots/glasses/mob.dmi',,
		"slot_l_ear"     = 'icons/inv_slots/ears/mob.dmi',
		"slot_r_ear"     = 'icons/inv_slots/ears/mob_r.dmi',
		"slot_wear_mask" = 'icons/inv_slots/masks/mob.dmi',
		"slot_head"      = 'icons/inv_slots/hats/mob.dmi',
		"slot_shoes"     = 'icons/inv_slots/shoes/mob.dmi',
		"slot_belt"      = 'icons/inv_slots/belts/mob.dmi',
		"slot_s_store"   = 'icons/inv_slots/suitstorage/mob.dmi',
		"slot_back"      = 'icons/inv_slots/back/mob.dmi',
		"slot_tie"       = 'icons/mob/species/monkey/ties.dmi',
		"slot_hidden"    = 'icons/inv_slots/hidden/mob.dmi',
		"slot_wear_id"   = 'icons/mob/onmob/id.dmi',
		"slot_l_hand"    = 'icons/mob/onmob/items/lefthand.dmi',
		"slot_r_hand"    = 'icons/mob/onmob/items/righthand.dmi'
		)
	blood_icon           = 'icons/mob/human_races/masks/blood_monkey.dmi'
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_monkey.dmi'
	bandages_icon        =  null

	stomach_capacity   = STOMACH_CAPACITY_LOW

	equipment_modifier = -0.5
	melee_modifier     = 1.25 // Monke muscles are no joke
	climb_speed        = 0.5

/datum/body_build/xenomorph
	name                 = "Xenomorph"
	genders              = list(MALE, FEMALE, NEUTER)
	blood_icon           = null // Fuck it, I ain't gonna spend all day showering if I'm an apex predator
	dam_mask             = 'icons/mob/human_races/masks/dam_mask_xenos.dmi'
	bandages_icon        =  null

	poise_pool         = HUMAN_MAX_POISE
	climb_speed        = 0.5 // Realistically, they should be able to jog along walls and ceilings, effectively ignoring four-legged thingies, but let's keep things at least somewhat balanced.
