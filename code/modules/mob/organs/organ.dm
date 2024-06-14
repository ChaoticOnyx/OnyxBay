var/list/limb_icon_cache = list()

/// Layer for bodyparts that should appear behind every other bodypart - Mostly, legs when facing WEST or EAST
#define BODYPARTS_LOW_LAYER -2

/obj/item/organ
	name = "organ"
	icon = 'icons/mob/human_races/organs/human.dmi'
	germ_level = 0
	w_class = ITEM_SIZE_TINY
	dir = SOUTH

	// Strings.
	/// Unique identifier.
	var/organ_tag = "organ"
	/// Organ holding this object.
	var/parent_organ = BP_CHEST

	// Status tracking.
	/// Various status flags (such as robotic)
	var/status = 0
	/// Lose a vital limb, die immediately.
	var/vital

	// Reference data.
	/// Current mob owning the organ.
	var/mob/living/carbon/human/owner
	/// Original DNA.
	var/datum/dna/dna
	/// Original species.
	var/datum/species/species

	// Damage vars.
	/// Current damage to the organ
	var/damage = 0
	/// Damage before becoming broken
	var/min_broken_damage = 30
	/// Damage cap
	var/max_damage
	/// Is this organ already being rejected?
	var/rejecting

	var/death_time

	/// path of food made from organ, ex.
	var/food_organ_type
	var/obj/item/reagent_containers/food/food_organ
	/// used to override food_organ's creation and using
	var/disable_food_organ = FALSE

	/// A bitfield for a collection of organ behavior flags.
	var/organ_flags = 0

	/// Used when caching robolimb icons.
	var/model
	/// Used to force override of species-specific organ icons (for prosthetics).
	var/force_icon
	// Appearance vars.
	/// Icon state base.
	var/icon_name = null
	/// Part flag
	var/body_part = null
	/// Used in mob overlay layering calculations.
	var/icon_position = 0
	/// Cached limb overlays
	var/list/mob_overlays
	var/body_build = ""
	/// Skin tone.
	var/s_tone
	/// Skin base.
	var/s_base = ""
	/// skin colour
	var/list/s_col
	/// How the skin colour is applied.
	var/s_col_blend = ICON_ADD
	/// hair colour
	var/list/h_col
	/// Secondary hair color
	var/list/h_s_col
	/// Markings (body_markings) to apply to the icon
	var/list/markings = list()

	drop_sound = SFX_DROP_FLESH
	pickup_sound = SFX_PICKUP_FLESH

/obj/item/organ/return_item()
	return food_organ

/obj/item/organ/proc/organ_eaten(mob/user)
	qdel(src)

/obj/item/organ/proc/update_food_from_organ()
	food_organ.SetName(name)
	food_organ.appearance = src
	reagents.trans_to(food_organ, reagents.total_volume)

/obj/item/organ/Destroy()
	if(owner)

		owner = null
	dna = null
	QDEL_NULL(food_organ)

	if(ismob(loc))
		var/mob/M = loc
		M.drop(src, force = TRUE, changing_slots = TRUE) // Changing_slots prevents drop_sound from playing

	return ..()

/obj/item/organ/proc/update_health()
	return

/obj/item/organ/proc/is_broken()
	return (damage >= min_broken_damage || (status & ORGAN_CUT_AWAY) || (status & ORGAN_BROKEN))

/obj/item/organ/New(mob/living/carbon/holder)
	..(holder)

	if(food_organ_type && !disable_food_organ)
		food_organ = new food_organ_type(src)

	if(max_damage)
		min_broken_damage = Floor(max_damage / 2)
	else
		max_damage = min_broken_damage * 2

	if(istype(holder))
		owner = holder
		w_class = max(w_class + mob_size_difference(holder.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller organs.

		if(holder.dna)
			dna = holder.dna.Clone()
			species = all_species[dna.species]
		else
			species = all_species[SPECIES_HUMAN]
			log_debug("[src] spawned in [holder] without a proper DNA.")

	if(dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.b_type

	create_reagents(5 * (w_class-1)**2)
	reagents.add_reagent(/datum/reagent/nutriment/protein, reagents.maximum_volume)

/obj/item/organ/proc/set_dna(datum/dna/new_dna)
	if(new_dna)
		dna = new_dna.Clone()
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA.Cut()
		blood_DNA[dna.unique_enzymes] = dna.b_type
		species = all_species[new_dna.species]

/obj/item/organ/proc/die()
	damage = max_damage
	status |= ORGAN_DEAD
	set_next_think(0)
	death_time = world.time
	if(owner && vital)
		owner.death()

/obj/item/organ/think()
	if(loc != owner)
		owner = null

	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	//Process infections
	if(BP_IS_ROBOTIC(src) || (owner?.species?.species_flags & SPECIES_FLAG_IS_PLANT))
		germ_level = 0
		// If `think()` is called not by the owner in `handle_organs()` but on his own.
		if(NEXT_THINK)
			set_next_think(world.time + 1 SECOND)
		return

	if(owner)
		if(isundead(owner))
			germ_level = 0
			if(NEXT_THINK)
				set_next_think(world.time + 1 SECOND)
			return

	if(!owner)
		if(reagents && !is_preserved())
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
			if(B && prob(40))
				reagents.remove_reagent(/datum/reagent/blood, 0.1)
				blood_splatter(src, B, 1)
			if(config.health.organs_can_decay)
				take_general_damage(rand(1, 3))
			germ_level += rand(2, 6)
			if(germ_level >= INFECTION_LEVEL_TWO)
				germ_level += rand(2, 6)
			if(germ_level >= INFECTION_LEVEL_THREE)
				die()

	else if(owner.bodytemperature >= 170) // Cryo stops germs from moving and doing their bad stuffs
		// Handle antibiotics and curing infections
		handle_antibiotics()
		handle_rejection()
		handle_germ_effects()

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

	if(food_organ)
		update_food_from_organ()

	// If `think()` is called not by the owner in `handle_organs()` but on his own.
	if(NEXT_THINK)
		set_next_think(world.time + 1 SECOND)

/obj/item/organ/proc/cook_organ()
	die()

/obj/item/organ/proc/is_preserved()
	if(istype(loc,/obj/item/organ))
		var/obj/item/organ/O = loc
		return O.is_preserved()
	else
		return (istype(loc,/obj/item/organ/internal/cerebrum/mmi) || istype(loc,/obj/structure/closet/body_bag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer) || istype(loc,/obj/item/storage/box/freezer) || istype(loc,/mob/living/simple_animal/hostile/little_changeling))

/obj/item/organ/examine(mob/user, infix)
	. = ..()

	. += show_decay_status(user)

	if(get_dist(src, user) > 1)
		return

	. += food_organ.get_bitecount()

/obj/item/organ/proc/show_decay_status(mob/user)
	if(status & ORGAN_DEAD)
		return SPAN_NOTICE("\The [src] looks severely damaged.")

/obj/item/organ/proc/handle_germ_effects()
	//** Handle the effects of infections

	var/virus_immunity = owner.virus_immunity()

	var/antibiotics = owner.chem_effects[CE_ANTIBIOTIC]

	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(virus_immunity*0.3))
		germ_level--

	if (germ_level >= INFECTION_LEVEL_ONE/2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(antibiotics < 5 && prob(round(germ_level/6 * owner.immunity_weakness() * 0.01)))
			if(virus_immunity > 0)
				germ_level += round(1/virus_immunity, 1) // Immunity starts at 100. This doubles infection rate at 50% immunity. Rounded to nearest whole.
			else // Will only trigger if immunity has hit zero. Once it does, 10x infection rate.
				germ_level += 10

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		owner.bodytemperature += between(0, (fever_temperature - (20 CELSIUS))/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

	if (germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		//spread germs
		if (antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(owner.immunity_weakness() * 0.3) ))
			parent.germ_level++

		if (prob(3))	//about once every 30 seconds
			take_general_damage(1,silent=prob(30))

/obj/item/organ/proc/handle_rejection()
	// Process unsuitable transplants. TODO: consider some kind of
	// immunosuppressant that changes transplant data to make it match.
	if(owner.virus_immunity() < 10) //for now just having shit immunity will suppress it
		return
	if(BP_IS_ROBOTIC(src))
		return
	if(dna)
		if(!rejecting)
			if(owner.blood_incompatible(dna.b_type, species))
				rejecting = 1
		else
			rejecting++ //Rejection severity increases over time.
			if(rejecting % 10 == 0) //Only fire every ten rejection ticks.
				switch(rejecting)
					if(1 to 50)
						germ_level++
					if(51 to 200)
						germ_level += rand(1,2)
					if(201 to 500)
						germ_level += rand(2,3)
					if(501 to INFINITY)
						germ_level += rand(3,5)
						owner.reagents.add_reagent(/datum/reagent/toxin, rand(1,2))

/obj/item/organ/proc/receive_chem(chemical as obj)
	return 0

/obj/item/organ/proc/remove_rejuv()
	qdel(src)

/obj/item/organ/proc/rejuvenate(ignore_prosthetic_prefs = FALSE)
	damage = 0
	status = 0
	if(!ignore_prosthetic_prefs && owner && owner.client && owner.client.prefs && owner.client.prefs.real_name == owner.real_name)
		var/status = owner.client.prefs.organ_data[organ_tag]
		if(status == "assisted")
			mechassist()
		else if(status == "mechanical")
			robotize()
		else if(status == "cyborg")
			robotize(owner.client.prefs.rlimb_data[name])
//Germs
/obj/item/organ/proc/handle_antibiotics()
	if(!owner || !germ_level)
		return
	var/antibiotics = owner.chem_effects[CE_ANTIBIOTIC]
	if (!antibiotics)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 5	//at germ_level == 500, this should cure the infection in 5 minutes
	else
		germ_level -= 3 //at germ_level == 1000, this will cure the infection in 10 minutes

/obj/item/organ/proc/take_general_damage(amount, silent = FALSE)
	CRASH("Not Implemented")

/obj/item/organ/proc/heal_damage(amount)
	damage = between(0, damage - round(amount, 0.1), max_damage)


/obj/item/organ/proc/robotize(company, skip_prosthetics = FALSE, keep_organs = FALSE, just_printed = FALSE) //Being used to make robutt hearts, etc
	status = ORGAN_ROBOTIC
	if(owner?.isSynthetic()) // If owner becomes fully synthetic - he receives all corresponding emotes.
		owner.add_synth_emotes()

	if(company)
		var/datum/robolimb/R = GLOB.all_robolimbs[company]
		if(!R || (species && (species.name in R.species_cannot_use)) || \
		 (R.restricted_to.len && !(species.name in R.restricted_to)) || \
		 (R.applies_to_part.len && !(organ_tag in R.applies_to_part)))
			R = basic_robolimb
		else
			model = company
			force_icon = R.icon
			name = "robotic [initial(name)]"
			desc = "[R.desc] It looks like it was produced by [R.company]."

/obj/item/organ/proc/mechassist() //Used to add things like pacemakers, etc
	status = ORGAN_ASSISTED

/**
 *  Remove an organ
 *
 *  drop_organ - if true, organ will be dropped at the loc of its former owner
 */
/obj/item/organ/proc/removed(mob/living/user, drop_organ = TRUE)
	if(!istype(owner))
		return

	if(drop_organ)
		dropInto(owner.loc)

	playsound(src, SFX_FIGHTING_CRUNCH, rand(65, 80), FALSE)

	// Start processing the organ on his own
	set_next_think(world.time)
	rejecting = null
	if(!BP_IS_ROBOTIC(src))
		var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list //TODO fix this and all other occurences of locate(/datum/reagent/blood) horror
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			owner.vessel.trans_to(src, 5, 1, 1)

	if(owner && vital)
		if(user)
			admin_attack_log(user, owner, "Removed a vital organ ([src]).", "Had a vital organ ([src]) removed.", "removed a vital organ ([src]) from")
		owner.death()

	owner = null

/obj/item/organ/proc/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	owner = target
	forceMove(owner) //just in case
	if(BP_IS_ROBOTIC(src))
		set_dna(owner.dna)
	return 1

/obj/item/organ/attack(mob/target, mob/user)
	if(status & ORGAN_ROBOTIC || !istype(target) || !istype(user) || (user != target && user.a_intent == I_HELP))
		return ..()

	if(food_organ.bitecount == 0)
		if(alert("Do you really want to use this organ as food? It will be useless for anything else afterwards.",,"Ew, no.","Bon appetit!") == "Ew, no.")
			to_chat(user, SPAN_NOTICE("You successfully repress your cannibalistic tendencies."))
			return
		update_food_from_organ()
		cook_organ()

	if(QDELETED(src))
		return

	target.attackby(return_item(), user)

/obj/item/organ/proc/can_feel_pain()
	return (!BP_IS_ROBOTIC(src) && owner && (!owner.no_pain || !species || !(species.species_flags & SPECIES_FLAG_NO_PAIN)))

/obj/item/organ/proc/is_usable()
	return !(status & (ORGAN_CUT_AWAY|ORGAN_MUTATED|ORGAN_DEAD))

/obj/item/organ/proc/can_recover()
	return (!(status & ORGAN_DEAD) || death_time >= world.time - ORGAN_RECOVERY_THRESHOLD)

/obj/item/organ/proc/get_scan_results()
	. = list()
	if(BP_IS_ASSISTED(src))
		. += "Assisted"
	else if(BP_IS_ROBOTIC(src))
		. += "Mechanical"

	if(status & ORGAN_CUT_AWAY)
		. += "Severed"
	if(status & ORGAN_MUTATED)
		. += "Genetic Deformation"
	if(status & ORGAN_DEAD)
		if(can_recover())
			. += "Critical"
		else
			. += "Destroyed"
	switch (germ_level)
		if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
			. +=  "Mild Infection"
		if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
			. +=  "Mild Infection+"
		if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
			. +=  "Mild Infection++"
		if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
			. +=  "Acute Infection"
		if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
			. +=  "Acute Infection+"
		if (INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
			. +=  "Acute Infection++"
		if (INFECTION_LEVEL_THREE to INFINITY)
			. +=  "Septic"
	if(rejecting)
		. += "Genetic Rejection"

//used by stethoscope
/obj/item/organ/proc/listen()
	return

/obj/item/organ/proc/get_icon_key()
	. = list()

	var/gender = "_m"
	if(!(organ_flags & ORGAN_FLAG_GENDERED_ICON))
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
	if(istype(src, /obj/item/organ/external))
		var/obj/item/organ/external/E = src
		. += E?.is_stump() ? "_s" : ""
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

	if(species && species.species_appearance_flags & HAS_SKIN_COLOR)
		if(s_col && length(s_col) >= 3)
			. += "_color_[s_col[1]]_[s_col[2]]_[s_col[3]]_[s_col_blend]"

	for(var/E in markings)
		var/datum/sprite_accessory/marking/M = E
		if (M.draw_target == MARKING_TARGET_SKIN)
			. += "-[M.name][markings[E]]]"

	return .

/obj/item/organ/on_update_icon()
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
	if(!(organ_flags & ORGAN_FLAG_GENDERED_ICON))
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

/obj/item/organ/proc/update_icon_drop(mob/living/carbon/human/powner)
	return

/obj/item/organ/proc/get_overlays()
	update_icon()
	return mob_overlays

/obj/item/organ/proc/apply_colouration(icon/applying)
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
	if(species && species.species_appearance_flags & HAS_SKIN_COLOR)
		if(s_col && s_col.len >= 3)
			applying.Blend(rgb(s_col[1], s_col[2], s_col[3]), s_col_blend)

	return applying
