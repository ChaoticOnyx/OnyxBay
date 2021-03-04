/*
	Datum-based species. Should make for much cleaner and easier to maintain race code.
*/

/datum/species

	// Descriptors and strings.
	var/name                                             // Species name.
	var/name_plural                                      // Pluralized name (since "[name]s" is not always valid)
	var/blurb = "A completely nondescript species."      // A brief lore summary for use in the chargen screen.

	var/list/body_builds = list(
		new /datum/body_build
	)

	// Icon/appearance vars.
	var/icobase = 'icons/mob/human_races/r_human.dmi'   // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.

	// Damage overlay and masks.
	var/damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	var/damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'

	var/prone_icon                            // If set, draws this from icobase when mob is prone.
	var/has_floating_eyes                     // Eyes will overlay over darkness (glow)

	var/blood_color = COLOR_BLOOD_HUMAN               // Red.
	var/flesh_color = "#ffc896"               // Pink.
	var/blood_oxy = 1
	var/base_color                            // Used by changelings. Should also be used for icon previes..
	var/limb_blend = ICON_ADD
	var/tail                                  // Name of tail state in species effects icon file.
	var/tail_animation                        // If set, the icon to obtain tail animation states from.
	var/tail_blend = ICON_ADD
	var/tail_hair

	var/list/hair_styles
	var/list/facial_hair_styles

	var/eye_icon = "eyes_s"
	var/eye_icon_location = 'icons/mob/human_face.dmi'

	var/organs_icon		//species specific internal organs icons

	var/default_h_style = "Bald"
	var/default_f_style = "Shaved"

	var/race_key = 0                          // Used for mob icon cache string.
	var/icon/icon_template = 'icons/mob/human_races/r_template.dmi' // Used for mob icon generation for non-32x32 species.
	var/pixel_offset_x = 0                    // Used for offsetting large icons.
	var/pixel_offset_y = 0                    // Used for offsetting large icons.

	var/mob_size	= MOB_MEDIUM
	var/strength    = STR_MEDIUM
	var/show_ssd = "fast asleep"
	var/virus_immune
	var/short_sighted                         // Permanent weldervision.
	var/light_sensitive                       // Ditto, but requires sunglasses to fix
	var/blood_volume = 560                    // Initial blood volume.
	var/hunger_factor = DEFAULT_HUNGER_FACTOR // Multiplier for hunger.
	var/taste_sensitivity = TASTE_NORMAL      // How sensitive the species is to minute tastes.

	var/min_age = 17
	var/max_age = 70

	// Language/culture vars.
	var/default_language = LANGUAGE_GALCOM    // Default language is used when 'say' is used without modifiers.
	var/language = LANGUAGE_GALCOM            // Default racial language, if any.
	var/list/secondary_langs = list()         // The names of secondary languages that are available to this species.
	var/assisted_langs = list()               // The languages the species can't speak without an assisted organ.
	var/list/speech_sounds                    // A list of sounds to potentially play when speaking.
	var/list/speech_chance                    // The likelihood of a speech sound playing.
	var/num_alternate_languages = 0           // How many secondary languages are available to select at character creation
	var/name_language = LANGUAGE_GALCOM       // The language to use when determining names for this species, or null to use the first name/last name generator
	var/additional_langs                      // Any other languages the species always gets.

	// Combat vars.
	var/total_health = 200                   // Point at which the mob will enter crit.
	var/list/unarmed_types = list(           // Possible unarmed attacks that the mob will use in combat,
		/datum/unarmed_attack,
		/datum/unarmed_attack/bite
		)
	var/list/unarmed_attacks = null           // For empty hand harm-intent attack
	var/brute_mod =      1                    // Physical damage multiplier.
	var/burn_mod =       1                    // Burn damage multiplier.
	var/oxy_mod =        1                    // Oxyloss modifier
	var/toxins_mod =     1                    // Toxloss modifier
	var/radiation_mod =  1                    // Radiation modifier
	var/flash_mod =      1                    // Stun from blindness modifier.
	var/metabolism_mod = 1                    // Reagent metabolism modifier
	var/vision_flags = SEE_SELF               // Same flags as glasses.

	// Death vars.
	var/meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	var/remains_type = /obj/item/remains/xeno
	var/gibbed_anim = "gibbed-h"
	var/dusted_anim = "dust-h"
	var/death_sound
	var/death_message = "seizes up and falls limp, their eyes dead and lifeless..."
	var/knockout_message = "collapses, having been knocked unconscious."
	var/halloss_message = "slumps over, too weak to continue fighting..."
	var/halloss_message_self = "The pain is too severe for you to keep going..."

	var/limbs_are_nonsolid
	var/spawns_with_stack = 0
	// Environment tolerance/life processes vars.
	var/reagent_tag                                   //Used for metabolizing reagents.
	var/breath_pressure = 16                          // Minimum partial pressure safe for breathing, kPa
	var/breath_type = "oxygen"                        // Non-oxygen gas breathed, if any.
	var/poison_type = "plasma"                        // Poisonous air.
	var/exhale_type = "carbon_dioxide"                // Exhaled gas type.
	var/cold_level_1 = 243                           // Cold damage level 1 below this point. -30 Celsium degrees
	var/cold_level_2 = 200                            // Cold damage level 2 below this point.
	var/cold_level_3 = 120                            // Cold damage level 3 below this point.
	var/heat_level_1 = 400                            // Heat damage level 1 above this point.
	var/heat_level_2 = 500                            // Heat damage level 2 above this point.
	var/heat_level_3 = 1000                           // Heat damage level 3 above this point.
	var/passive_temp_gain = 0		                  // Species will gain this much temperature every second
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.
	var/body_temperature = 310.15	                  // Species will try to stabilize at this temperature.
	                                                  // (also affects temperature processing)

	var/heat_discomfort_level = 315                   // Aesthetic messages about feeling warm.
	var/cold_discomfort_level = 285                   // Aesthetic messages about feeling chilly.
	var/list/heat_discomfort_strings = list(
		"You feel sweat drip down your neck.",
		"You feel uncomfortably warm.",
		"Your skin prickles in the heat."
		)
	var/list/cold_discomfort_strings = list(
		"You feel chilly.",
		"You shiver suddenly.",
		"Your chilly flesh stands out in goosebumps."
		)

	// HUD data vars.
	var/datum/hud_data/hud
	var/hud_type
	var/health_hud_intensity = 1

	var/grab_type = GRAB_NORMAL		// The species' default grab type.

	// Body/form vars.
	var/list/inherent_verbs 	  // Species-specific verbs.
	var/has_fine_manipulation = 1 // Can use small items.
	var/siemens_coefficient = 1   // The lower, the thicker the skin and better the insulation.
	var/darksight = 2             // Native darksight distance.
	var/species_flags = 0         // Various specific features.
	var/appearance_flags = 0      // Appearance/display related features.
	var/spawn_flags = 0           // Flags that specify who can spawn as this species
	var/slowdown = 0              // Passive movement speed malus (or boost, if negative)
	var/primitive_form            // Lesser form, if any (ie. monkey for humans)
	var/greater_form              // Greater form, if any, ie. human for monkeys.
	var/holder_type
	var/gluttonous                // Can eat some mobs. Values can be GLUT_TINY, GLUT_SMALLER, GLUT_ANYTHING, GLUT_ITEM_TINY, GLUT_ITEM_NORMAL, GLUT_ITEM_ANYTHING, GLUT_PROJECTILE_VOMIT
	var/stomach_capacity = 5      // How much stuff they can stick in their stomach
	var/rarity_value = 1          // Relative rarity/collector value for this species.
	                              // Determines the organs that the species spawns with and
	var/list/has_organ = list(    // which required-organ checks are conducted.
		BP_HEART =    /obj/item/organ/internal/heart,
		BP_STOMACH =  /obj/item/organ/internal/stomach,
		BP_LUNGS =    /obj/item/organ/internal/lungs,
		BP_LIVER =    /obj/item/organ/internal/liver,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain,
		BP_APPENDIX = /obj/item/organ/internal/appendix,
		BP_EYES =     /obj/item/organ/internal/eyes
		)
	var/vision_organ              // If set, this organ is required for vision. Defaults to "eyes" if the species has them.
	var/breathing_organ           // If set, this organ is required for breathing. Defaults to "lungs" if the species has them.

	var/obj/effect/decal/cleanable/blood/tracks/move_trail = /obj/effect/decal/cleanable/blood/tracks/footprints // What marks are left when walking

	var/list/skin_overlays = list()

	var/list/has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin),
		BP_HEAD =   list("path" = /obj/item/organ/external/head),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right)
		)

	// The basic skin colours this species uses
	var/list/base_skin_colours

	var/list/genders = list(MALE, FEMALE)

	// Bump vars
	var/bump_flag = HUMAN	// What are we considered to be when bumped?
	var/push_flags = ~HEAVY	// What can we push?
	var/swap_flags = ~HEAVY	// What can we swap place with?

	var/pass_flags = 0
	var/breathing_sound = 'sound/voice/monkey.ogg'
	var/list/equip_adjust = list()
	var/list/equip_overlays = list()

	var/sexybits_location	//organ tag where they are located if they can be kicked for increased pain

	var/list/prone_overlay_offset = list(0, 0) // amount to shift overlays when lying
	var/icon_scale = 1
/*
These are all the things that can be adjusted for equipping stuff and
each one can be in the NORTH, SOUTH, EAST, and WEST direction. Specify
the direction to shift the thing and what direction.

example:
	equip_adjust = list(
		slot_back_str = list(NORTH = list(SOUTH = 12, EAST = 7), EAST = list(SOUTH = 2, WEST = 12))
			)

This would shift back items (backpacks, axes, etc.) when the mob
is facing either north or east.
When the mob faces north the back item icon is shifted 12 pixes down and 7 pixels to the right.
When the mob faces east the back item icon is shifted 2 pixels down and 12 pixels to the left.

The slots that you can use are found in items_clothing.dm and are the inventory slot string ones, so make sure
	you use the _str version of the slot.
*/

/datum/species/proc/get_eyes(mob/living/carbon/human/H)
	return

/datum/species/New()
	if(hud_type)
		hud = new hud_type()
	else
		hud = new()

	//If the species has eyes, they are the default vision organ
	if(!vision_organ && has_organ[BP_EYES])
		vision_organ = BP_EYES
	//If the species has lungs, they are the default breathing organ
	if(!breathing_organ && has_organ[BP_LUNGS])
		breathing_organ = BP_LUNGS

	unarmed_attacks = list()
	for(var/u_type in unarmed_types)
		unarmed_attacks += new u_type()

	//Build organ descriptors
	for(var/limb_type in has_limbs)
		var/list/organ_data = has_limbs[limb_type]
		var/obj/item/organ/limb_path = organ_data["path"]
		organ_data["descriptor"] = initial(limb_path.name)

/datum/species/proc/sanitize_name(name)
	return sanitizeName(name)

/datum/species/proc/equip_survival_gear(mob/living/carbon/human/H, boxtype = 0)
	if(istype(H.get_equipped_item(slot_back), /obj/item/weapon/storage/backpack))
		switch(boxtype)
			if(2)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/security(H.back), slot_in_backpack)
			if(1)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
			else
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	else
		switch(boxtype)
			if(2)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/security(H), slot_r_hand)
			if(1)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
			else
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)

/datum/species/proc/create_organs(mob/living/carbon/human/H) //Handles creation of mob organs.

	H.mob_size = mob_size
	var/list/obj/item/organ/internal/foreign_organs = list()

	for(var/obj/item/organ/external/E in H.contents)
		for(var/obj/item/organ/internal/O in E.internal_organs)
			if(istype(O) && O.foreign)
				E.internal_organs -= O
				H.internal_organs -= O
				foreign_organs |= O

	for(var/obj/item/organ/organ in H.contents)
		if((organ in H.organs) || (organ in H.internal_organs))
			qdel(organ)

	if(H.organs)                  H.organs.Cut()
	if(H.internal_organs)         H.internal_organs.Cut()
	if(H.organs_by_name)          H.organs_by_name.Cut()
	if(H.internal_organs_by_name) H.internal_organs_by_name.Cut()

	H.organs = list()
	H.internal_organs = list()
	H.organs_by_name = list()
	H.internal_organs_by_name = list()

	for(var/limb_type in has_limbs)
		var/list/organ_data = has_limbs[limb_type]
		var/limb_path = organ_data["path"]
		new limb_path(H)

	for(var/organ_tag in has_organ)
		var/organ_type = has_organ[organ_tag]
		var/obj/item/organ/O = new organ_type(H)
		if(organ_tag != O.organ_tag)
			warning("[O.type] has a default organ tag \"[O.organ_tag]\" that differs from the species' organ tag \"[organ_tag]\". Updating organ_tag to match.")
			O.organ_tag = organ_tag
		H.internal_organs_by_name[organ_tag] = O

	for(var/obj/item/organ/internal/organ in foreign_organs)
		var/obj/item/organ/external/E = H.get_organ(organ.parent_organ)
		E.internal_organs |= organ
		H.internal_organs_by_name[organ.organ_tag] = organ
		organ.after_organ_creation()

	for(var/name in H.organs_by_name)
		H.organs |= H.organs_by_name[name]

	for(var/name in H.internal_organs_by_name)
		H.internal_organs |= H.internal_organs_by_name[name]

	for(var/obj/item/organ/O in (H.organs|H.internal_organs))
		O.owner = H

	H.sync_organ_dna()

/datum/species/proc/hug(mob/living/carbon/human/H,mob/living/target)

	var/mob/living/carbon/human/V
	if(istype(target,/mob/living/carbon/human))
		V = target
	var/zone
	if(H.zone_sel)
		zone = H.zone_sel.selecting
	else
		zone = BP_CHEST	//When something terrible happens, we just hug 'em

	if(V && !V.get_organ(zone) && zone != BP_MOUTH)
		zone = BP_CHEST //And again to make sure we are not shaking nonexistent hands nor sexually harassing phantom groins. Is there a probability of a spessman existing w/ no chest tho? :thinking:

	switch(zone)
		if(BP_HEAD)
			H.visible_message("<span class='notice'>[H] pats [target] on the head!</span>", \
							"<span class='notice'>You pat [target] on the head!</span>")
		if(BP_L_ARM, BP_R_ARM)
			H.visible_message("<span class='notice'>[H] pats [target] on the shoulder!</span>", \
							"<span class='notice'>You pat [target] on the shoulder!</span>")
			if(prob(50))
				to_chat(target, "<span class='notice'>You feel a bit more encouraged!</span>")
		if(BP_L_LEG, BP_R_LEG)
			H.visible_message("<span class='notice'>[H] touches [target]'s hip!</span>", \
							"<span class='notice'>You touch [target]'s hip!</span>")
		if(BP_L_HAND, BP_R_HAND)
			H.visible_message("<span class='notice'>[H] reaches out to shake [target]'s hand!</span>", \
							"<span class='notice'>You reach out to shake [target]'s hand!</span>")
			H.next_move = world.time + 25 // Trying to shake one's hands during a fight is kinda risky, y'know.
			if(!do_after(H,25,target))
				return
			if(target.a_intent == I_HELP)
				H.visible_message("<span class='notice'>[H] and [target] shake hands!</span>", \
								"<span class='notice'>You shake [target]'s hand!</span>")
			else
				H.visible_message("<span class='warning'>[target] refuses to shake [H]'s hand!</span>", \
								"<span class='warning'>[target] refuses to shake your hand!</span>")
		if(BP_MOUTH)
			var/obj/item/clothing/mask/actor_mask = H.wear_mask
			var/obj/item/clothing/mask/target_mask
			if(V)
				target_mask = V.wear_mask
			if(actor_mask && target_mask)
				if(istype(actor_mask, /obj/item/clothing/mask/smokable/cigarette) && istype(target_mask, /obj/item/clothing/mask/smokable/cigarette))
					H.visible_message(SPAN_NOTICE("[H] reaches out for [target]'s face...)"), \
									SPAN_NOTICE("You reach out for [target]'s face..."))
					H.next_move = world.time + 15
					if(!do_after(H,15,target) || target.a_intent != I_HELP)
						return
					H.visible_message(SPAN_NOTICE("\The [actor_mask] touches \the [target_mask].</span>")) // Harsh spessman flirt
					var/obj/item/clothing/mask/smokable/cigarette/actor_cig = actor_mask
					var/obj/item/clothing/mask/smokable/cigarette/target_cig = target_mask
					if(actor_cig.lit && !target_cig.lit)
						target_cig.light(actor_cig, H)
					if(!actor_cig.lit && target_cig.lit)
						actor_cig.light(target_cig, H)
					return

			if(actor_mask)
				to_chat(H, "\A [actor_mask] is in the way!")
				return
			if(target_mask)
				to_chat(H, "[target] wears \a [target_mask]. It's in your way!")
				return

			H.visible_message("<span class='notice'>[H] reaches out for [target]'s face...</span>", \
							"<span class='notice'>You reach out for [target]'s face...</span>")
			H.next_move = world.time + 15 // In a matter of a second we get subpoenaed for sexual harassment
			if(!do_after(H,15,target) || target.a_intent != I_HELP)
				return
			H.visible_message("<span class='notice'>[H] kisses [target]!</span>", \
							"<span class='notice'>You kiss [target]!</span>")

		else // Well I can't figure out what exactly we should do w/ ppl's feet and eyes
			H.visible_message("<span class='notice'>[H] hugs [target]!</span>", \
							"<span class='notice'>You hug [target]!</span>")

	// Legacy for sum raisin
	//H.visible_message("<span class='notice'>[H] hugs [target] to make [t_him] feel better!</span>", \
	//				"<span class='notice'>You hug [target] to make [t_him] feel better!</span>")

/datum/species/proc/remove_inherent_verbs(mob/living/carbon/human/H)
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			H.verbs -= verb_path
	return

/datum/species/proc/add_inherent_verbs(mob/living/carbon/human/H)
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			H.verbs |= verb_path
	return

/datum/species/proc/handle_post_spawn(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	add_inherent_verbs(H)
	H.mob_bump_flag = bump_flag
	H.mob_swap_flags = swap_flags
	H.mob_push_flags = push_flags
	H.pass_flags = pass_flags

/datum/species/proc/handle_pre_spawn(mob/living/carbon/human/H)
	return

/datum/species/proc/handle_death(mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	return

/datum/species/proc/handle_new_grab(mob/living/carbon/human/H, obj/item/grab/G)
	return

// Only used for alien plasma weeds atm, but could be used for Dionaea later.
/datum/species/proc/handle_environment_special(mob/living/carbon/human/H)
	return

/datum/species/proc/handle_movement_delay_special(mob/living/carbon/human/H)
	return 0

// Used to update alien icons for aliens.
/datum/species/proc/handle_login_special(mob/living/carbon/human/H)
	return

// As above.
/datum/species/proc/handle_logout_special(mob/living/carbon/human/H)
	return

// Builds the HUD using species-specific icons and usable slots.
/datum/species/proc/build_hud(mob/living/carbon/human/H)
	return

//Used by xenos understanding larvae and dionaea understanding nymphs.
/datum/species/proc/can_understand(mob/other)
	return

/datum/species/proc/can_overcome_gravity(mob/living/carbon/human/H)
	return FALSE

// Used for any extra behaviour when falling and to see if a species will fall at all.
/datum/species/proc/can_fall(mob/living/carbon/human/H)
	return TRUE

// Used to override normal fall behaviour. Use only when the species does fall down a level.
/datum/species/proc/handle_fall_special(mob/living/carbon/human/H, turf/landing)
	return FALSE

// Called when using the shredding behavior.
/datum/species/proc/can_shred(mob/living/carbon/human/H, ignore_intent)

	if((!ignore_intent && H.a_intent != I_HURT) || H.pulling_punches)
		return 0

	for(var/datum/unarmed_attack/attack in unarmed_attacks)
		if(!attack.is_usable(H))
			continue
		if(attack.shredding)
			return 1

	return 0

// Called in life() when the mob has no client.
/datum/species/proc/handle_npc(mob/living/carbon/human/H)
	return

/datum/species/proc/handle_vision(mob/living/carbon/human/H)
	H.update_sight()
	H.set_sight(H.sight|get_vision_flags(H)|H.equipment_vision_flags)

	if(H.stat == DEAD)
		return 1

	if(!H.druggy)
		H.set_see_in_dark((H.sight == (SEE_TURFS|SEE_MOBS|SEE_OBJS)) ? 8 : min(darksight + H.equipment_darkness_modifier, 8))
		if(H.equipment_see_invis)
			H.set_see_invisible(min(H.see_invisible, H.equipment_see_invis))

	if(H.equipment_tint_total >= TINT_BLIND)
		H.eye_blind = max(H.eye_blind, 1)

	if(!H.client)//no client, no screen to update
		return 1

	H.set_fullscreen(H.eye_blind && !H.equipment_prescription, "blind", /obj/screen/fullscreen/blind)
	H.set_fullscreen(H.stat == UNCONSCIOUS, "blackout", /obj/screen/fullscreen/blackout)

	if(config.welder_vision)
		H.set_fullscreen(H.equipment_tint_total, "welder", /obj/screen/fullscreen/impaired, H.equipment_tint_total)
	var/how_nearsighted = get_how_nearsighted(H)
	H.set_fullscreen(how_nearsighted, "nearsighted", /obj/screen/fullscreen/oxy, how_nearsighted)
	H.set_fullscreen(H.eye_blurry, "blurry", /obj/screen/fullscreen/blurry)
	H.set_fullscreen(H.druggy, "high", /obj/screen/fullscreen/high)

	for(var/overlay in H.equipment_overlays)
		H.client.screen |= overlay

	return 1

/datum/species/proc/get_how_nearsighted(mob/living/carbon/human/H)
	var/prescriptions = short_sighted
	if(H.disabilities & NEARSIGHTED)
		prescriptions += 7
	if(H.equipment_prescription)
		if(H.disabilities & NEARSIGHTED)
			prescriptions -= H.equipment_prescription
		else
			prescriptions += H.equipment_prescription

	var/light = light_sensitive
	if(light)
		if(H.eyecheck() > FLASH_PROTECTION_NONE)
			light = 0
		else
			var/turf_brightness = 1
			var/turf/T = get_turf(H)
			if(T && T.lighting_overlay)
				turf_brightness = min(1, T.get_lumcount())
			if(turf_brightness < 0.33)
				light = 0
			else
				light = round(light * turf_brightness)
				if(H.equipment_light_protection)
					light -= H.equipment_light_protection
	return Clamp(max(prescriptions, light), 0, 7)

/datum/species/proc/set_default_hair(mob/living/carbon/human/H)
	H.h_style = H.species.default_h_style
	H.f_style = H.species.default_f_style
	H.update_hair()

/datum/species/proc/get_blood_name()
	return "blood"

/datum/species/proc/handle_death_check(mob/living/carbon/human/H)
	return FALSE

//Mostly for toasters
/datum/species/proc/handle_limbs_setup(mob/living/carbon/human/H)
	return FALSE

// Impliments different trails for species depending on if they're wearing shoes.
/datum/species/proc/get_move_trail(mob/living/carbon/human/H)
	if( H.shoes || ( H.wear_suit && (H.wear_suit.body_parts_covered & FEET) ) )
		return /obj/effect/decal/cleanable/blood/tracks/footprints
	else
		return move_trail

/datum/species/proc/update_skin(mob/living/carbon/human/H)
	return

/datum/species/proc/disarm_attackhand(mob/living/carbon/human/attacker, mob/living/carbon/human/target)

	attacker.do_attack_animation(target)

	if(target.parrying)
		if(target.handle_parry(attacker, w_atk=null))
			return
	if(target.blocking)
		if(target.handle_block_normal(attacker))
			return

	if(target.w_uniform)
		target.w_uniform.add_fingerprint(attacker)
	var/obj/item/organ/external/affecting = target.get_organ(ran_zone(attacker.zone_sel.selecting))

	var/list/holding = list(target.get_active_hand() = 40, target.get_inactive_hand() = 20)

	//See if they have any guns that might go off
	for(var/obj/item/weapon/gun/W in holding)
		if(W && prob(holding[W]))
			var/list/turfs = list()
			for(var/turf/T in view())
				turfs += T
			if(turfs.len)
				var/turf/shoot_to = pick(turfs)
				target.visible_message("<span class='danger'>[target]'s [W] goes off during the struggle!</span>")
				return W.afterattack(shoot_to,target)

	var/effective_armor = target.getarmor(attacker.zone_sel.selecting, "melee")
	target.poise -= round(4.0+4.0*((100-effective_armor)/100),0.1)

	//target.visible_message("Debug \[DISARM\]: [target] lost [round(4.0+4.0*((100-effective_armor)/100),0.1)] poise ([target.poise]/[target.poise_pool])") // Debug Message

	//var/randn = rand(1, 100)
	if(!(species_flags & SPECIES_FLAG_NO_SLIP) && target.poise <= 20 && !prob(target.poise*4.5) && !target.lying)
		var/armor_check = target.run_armor_check(affecting, "melee")
		playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(prob(100-target.poise*6.5))
			target.visible_message("<span class='danger'>[attacker] has pushed [target]!</span>")
			target.apply_effect(4, WEAKEN, armor_check)
		else
			target.visible_message("<span class='warning'>[attacker] attempted to push [target]!</span>")
		return

	if(!prob(target.poise*2)) //30 poise = 40% disarm, 20 poise = 60% disarm, 10 poise = 80% disarm, 0 poise = 100% disarm
		//See about breaking grips or pulls
		if(target.break_all_grabs(attacker))
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			return

		//Actually disarm them
		for(var/obj/item/I in holding)
			if(I && I.canremove)
				target.drop_from_inventory(I)
				target.visible_message("<span class='danger'>[attacker] has disarmed [target]!</span>")
				playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return

	playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	target.visible_message("<span class='warning'>[attacker] attempted to disarm \the [target]!</span>")

/datum/species/proc/disfigure_msg(mob/living/carbon/human/H) //Used for determining the message a disfigured face has on examine. To add a unique message, just add this onto a specific species and change the "return" message.
	var/datum/gender/T = gender_datums[H.get_gender()]
	return "<span class='danger'>[T.His] face is horribly mangled!</span>\n"

/datum/species/proc/max_skin_tone()
	if(appearance_flags & HAS_SKIN_TONE_GRAV)
		return 100
	if(appearance_flags & HAS_SKIN_TONE_SPCR)
		return 165
	return 220

/datum/species/proc/get_hair_styles()
	var/list/L = LAZYACCESS(hair_styles, type)
	if(!L)
		L = list()
		LAZYSET(hair_styles, type, L)
		for(var/hairstyle in GLOB.hair_styles_list)
			var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
			if(!(name in S.species_allowed))
				continue
			ADD_SORTED(L, hairstyle, /proc/cmp_text_asc)
			L[hairstyle] = S
	return L

/datum/species/proc/get_facial_hair_styles(gender)
	var/list/facial_hair_styles_by_species = LAZYACCESS(facial_hair_styles, type)
	if(!facial_hair_styles_by_species)
		facial_hair_styles_by_species = list()
		LAZYSET(facial_hair_styles, type, facial_hair_styles_by_species)

	var/list/facial_hair_style_by_gender = facial_hair_styles_by_species[gender]
	if(!facial_hair_style_by_gender)
		facial_hair_style_by_gender = list()
		LAZYSET(facial_hair_styles_by_species, gender, facial_hair_style_by_gender)

		for(var/facialhairstyle in GLOB.facial_hair_styles_list)
			var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]
			if(gender == MALE && S.gender == FEMALE)
				continue
			if(gender == FEMALE && S.gender == MALE)
				continue
			if(!(name in S.species_allowed))
				continue
			ADD_SORTED(facial_hair_style_by_gender, facialhairstyle, /proc/cmp_text_asc)
			facial_hair_style_by_gender[facialhairstyle] = S

	return facial_hair_style_by_gender
