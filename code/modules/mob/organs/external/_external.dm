/****************************************************
				EXTERNAL ORGANS
****************************************************/

/obj/item/organ/external
	name = "external"
	min_broken_damage = 0
	max_damage = 60
	dir = SOUTH
	organ_tag = "limb"
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | LONG_GLIDE

	food_organ_type = /obj/item/reagent_containers/food/meat/human

	throwforce = 2.5
	necessary_organ_modules = list(/obj/item/organ_module/actuators, /obj/item/organ_module/processor)
	// Strings
	var/broken_description             // fracture string if any.
	var/damage_state = "00"            // Modifier used for generating the on-mob damage overlay for this limb.

	// Damage vars.
	var/brute_mod = 1                  // Multiplier for incoming brute damage.
	var/burn_mod = 1                   // As above for burn.

	var/brute_dam = 0                  // Actual current brute damage.
	var/brute_ratio = 0                // Ratio of current brute damage to max damage.
	var/brute_last = 0

	var/burn_dam = 0                   // Actual current burn damage.
	var/burn_ratio = 0                 // Ratio of current burn damage to max damage.
	var/burn_last = 0

	var/blunt_dam = 0                  // Amount of blunt brute damage.
	var/blunt_last = 0
	var/blunt_ratio = 0
	var/cut_dam = 0                    // Amount of sharp brute damage, aka "cut area".
	var/cut_last = 0
	var/cut_ratio = 0
	var/pierce_dam = 0                 // Amount of pierce brute damage, aka "cut depth".
	var/pierce_last = 0
	var/pierce_ratio = 0

	var/max_bleeding = 0               // Potential bleeding, not counting scabbing, bandages or clamps.
	var/bleeding = 0                   // Effective bleeding severity at the moment.
	var/bandaged = 0                   // Bandaged stage.
	var/scabbed = 0                    // Scabbing stage.
	var/clamped = FALSE                // Clamped state. Completely prevents bleeding, but also prevents sharp regeneration and is interrupted by any damage.
	var/salved = FALSE                 // Salved state. Speeds up blunt regeneration and decreases pain. Interrupted by any damage.

	var/last_dam = -1                  // used in healing/processing calculations.
	var/pain = 0                       // How much the limb hurts.
	var/full_pain = 0                  // Overall pain including damages.
	var/max_pain = null                // Maximum pain the limb can accumulate. The actual effect's capped at max_damage.
	var/pain_disability_threshold      // Point at which a limb becomes unusable due to pain.

	// Movement delay vars.
	var/movement_tally    = 0          // Defines movement speed
	var/damage_multiplier = 0.5        // Default damage multiplier
	var/stumped_tally     = 8          // 4.0  tally if limb stmuped
	var/splinted_tally    = 2          // 1.0 tally if limb splinted
	var/broken_tally      = 3          // 1.5 tally if limb broken

	// A bitfield for a collection of limb behavior flags.
	var/limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_BREAK

	// Appearance vars.
	var/icon_name = null               // Icon state base.
	var/body_part = null               // Part flag
	var/icon_position = 0              // Used in mob overlay layering calculations.
	var/model                          // Used when caching robolimb icons.
	var/force_icon                     // Used to force override of species-specific limb icons (for prosthetics).
	var/list/mob_overlays              // Cached limb overlays
	var/body_build = ""
	var/s_tone                         // Skin tone.
	var/s_base = ""                    // Skin base.
	var/list/s_col                     // skin colour
	var/s_col_blend = ICON_ADD         // How the skin colour is applied.
	var/list/h_col                     // hair colour
	var/list/h_s_col                   // Secondary hair color
	var/list/markings = list()         // Markings (body_markings) to apply to the icon

	// Wound and structural data.
	var/wound_update_accuracy = 2      // how often wounds should be updated, a higher number means less often
	var/obj/item/organ/external/parent // Master-limb.
	var/list/children                  // Sub-limbs.
	var/list/internal_organs = list()  // Internal organs of this body part
	var/base_miss_chance = 20          // Chance of missing.
	var/genetic_degradation = 0

	//Forensics stuff
	var/list/autopsy_data = list()    // Trauma data for forensics.

	// Joint/state stuff.
	var/joint = "joint"                // Descriptive string used in dislocation.
	var/amputation_point               // Descriptive string used in amputation.
	var/dislocated = 0                 // If you target a joint, you can dislocate the limb, causing temporary damage to the organ.
	var/encased                        // Needs to be opened with a saw to access the organs.
	var/artery_name = "artery"         // Flavour text for cartoid artery, aorta, etc.
	var/arterial_bleed_severity = 1    // Multiplier for bleeding in a limb.
	var/tendon_name = "tendon"         // Flavour text for Achilles tendon, etc.
	var/cavity_name = "cavity"
	var/deformities = 0				   // Currently used for glasgow smiles. Gonna add chopped-off fingers and torn-off nipples later.

	// Surgery vars.
	var/cavity_max_w_class = 0
	var/hatch_state = 0
	var/stage = 0
	var/cavity = 0
	var/atom/movable/applied_pressure
	var/atom/movable/splinted
	var/internal_organs_size = 0       // Current size cost of internal organs in this body part
	var/list/embedded_objects

	// HUD element variable, see organ_icon.dm get_damage_hud_image()
	var/image/hud_damage_image

/obj/item/organ/external/Initialize(mapload, ...)
	. = ..()
	if(!mapload && owner)
		owner.update_organ_movespeed()

/obj/item/organ/external/proc/get_fingerprint()

	if((limb_flags & ORGAN_FLAG_FINGERPRINT) && dna && !is_stump() && !BP_IS_ROBOTIC(src))
		return md5(dna.uni_identity)

	for(var/obj/item/organ/external/E in children)
		var/print = E.get_fingerprint()
		if(print)
			return print

/obj/item/organ/external/organ_eaten(mob/user)
	for(var/obj/item/organ/external/stump/stump in children)
		qdel(stump)
	..()

/obj/item/organ/external/afterattack(atom/A, mob/user, proximity)
	..()
	if(proximity && get_fingerprint())
		A.add_partial_print(get_fingerprint())

/obj/item/organ/external/New(mob/living/carbon/holder)
	..()
	if(isnull(pain_disability_threshold))
		pain_disability_threshold = (max_damage * 0.75)
	if(owner)
		replaced(owner)
		sync_colour_to_human(owner)
		if(isnull(max_pain))
			max_pain = min(max_damage * 2.5, owner.species.total_health * 1.5)
	else if(isnull(max_pain))
		max_pain = max_damage * 1.5 // Should not ~probably~ happen
	get_overlays()

	if(food_organ in implants)
		implants -= food_organ

/obj/item/organ/external/Destroy()
	if(parent?.children)
		parent.children -= src
		parent = null

	QDEL_NULL_LIST(children)

	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	BIO?.change_host(get_turf(src)) // Because we don't want biostructures to get wrecked so easily

	QDEL_NULL_LIST(internal_organs)

	applied_pressure = null
	if(splinted?.loc == src)
		QDEL_NULL(splinted)

	if(owner)
		if(limb_flags & ORGAN_FLAG_CAN_GRASP) owner.grasp_limbs -= src
		if(limb_flags & ORGAN_FLAG_CAN_STAND) owner.stance_limbs -= src
		owner.organs -= src
		owner.organs_by_name -= organ_tag
		while(null in owner.organs)
			owner.organs -= null
		owner.bad_external_organs.Remove(src)

	drop_embedded_objects()

	QDEL_NULL_LIST(organ_modules)

	if(autopsy_data)
		autopsy_data.Cut()

	return ..()

/obj/item/organ/external/set_dna(datum/dna/new_dna)
	..()
	s_col_blend = species.limb_blend
	s_base = new_dna.s_base

/obj/item/organ/external/emp_act(severity)
	var/burn_damage = 0
	switch (severity)
		if (1)
			burn_damage = 15
		if (2)
			burn_damage = 7
		if (3)
			burn_damage = 3

	var/mult = BP_IS_ROBOTIC(src) + BP_IS_ASSISTED(src)
	burn_damage *= mult/burn_mod //ignore burn mod for EMP damage

	var/power = 4 - severity //stupid reverse severity
	for(var/obj/item/I in implants)
		if(I.obj_flags & OBJ_FLAG_CONDUCTIBLE)
			burn_damage += I.w_class * rand(power, 3*power)

	if(owner && burn_damage)
		owner.custom_pain("Something inside your [src] burns a [severity < 2 ? "bit" : "lot"]!", power * 15) //robotic organs won't feel it anyway
		take_external_damage(0, burn_damage, 0, used_weapon = "Hot metal")

/obj/item/organ/external/attack_self(mob/user)
	if(!contents.len)
		return ..()
	var/list/removable_objects = list()
	for(var/obj/item/organ/external/E in (contents + src))
		if(!istype(E))
			continue
		for(var/obj/item/I in E.contents)
			if(istype(I,/obj/item/organ))
				continue
			if(I == E.return_item())
				continue
			removable_objects |= I
	if(removable_objects.len)
		var/obj/item/I = pick(removable_objects)
		I.dropInto(user.loc) //just in case something was embedded that is not an item
		if(istype(I))
			if(!(user.l_hand && user.r_hand))
				user.pick_or_drop(I)
		user.visible_message("<span class='danger'>\The [user] rips \the [I] out of \the [src]!</span>")
		return //no eating the limb until everything's been removed
	return ..()

/obj/item/organ/external/examine(mob/user, infix)
	. = ..()

	if(in_range(user, src) || isghost(user))
		for(var/obj/item/I in contents)
			if(istype(I, /obj/item/organ))
				continue

			if(I == return_item())
				continue

			. += SPAN_DANGER("There is \a [I] sticking out of it.")

		var/ouchies = get_wounds_desc()
		if(ouchies != "nothing")
			. += SPAN_NOTICE("There is [ouchies] visible on it.")

/obj/item/organ/external/show_decay_status(mob/user)
	..(user)
	for(var/obj/item/organ/external/child in children)
		child.show_decay_status(user)

/obj/item/organ/external/attackby(obj/item/W, mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	switch(stage)
		if(0)
			if(W.sharp)
				if(do_mob(user, src, DEFAULT_ATTACK_COOLDOWN))
					if(children?.len)
						var/obj/item/organ/external/external_child = pick(children)
						status |= ORGAN_CUT_AWAY
						children.Remove(external_child)
						external_child.forceMove(get_turf(src))
						external_child.SetTransform(rotation = rand(180))
						external_child.compile_icon()
						compile_icon()
						user.visible_message(SPAN("danger", "<b>[user]</b> cuts [external_child] from [src] with [W]!"))
					else
						user.visible_message(SPAN("danger", "<b>[user]</b> cuts [src] open with [W]!"))
						stage++
					return
		if(1)
			if(istype(W))
				if(do_mob(user, src, DEFAULT_ATTACK_COOLDOWN))
					user.visible_message(SPAN("danger", "<b>[user]</b> cracks [src] open like an egg with [W]!"))
					drop_embedded_objects()
					stage++
					return
		if(2)
			if(W.sharp || istype(W, /obj/item/hemostat) || isWirecutter(W))
				var/list/organs = get_contents_recursive()
				if(do_mob(user, src, DEFAULT_ATTACK_COOLDOWN))
					if(organs.len)
						var/obj/item/removing = pick(organs)
						var/obj/item/organ/external/current_child = removing.loc

						current_child.implants.Remove(removing)
						current_child.internal_organs.Remove(removing)

						status |= ORGAN_CUT_AWAY

						removing.forceMove(get_turf(src))
						user.visible_message(SPAN_DANGER("<b>[user]</b> extracts [removing] from [src] with [W]!"))
					else
						if(organ_tag == BP_HEAD && W.sharp)
							var/obj/item/organ/external/head/H = src // yeah yeah this is horrible
							if(!H.skull_path)
								user.visible_message(SPAN("danger", "<b>[user]</b> fishes around fruitlessly in [src] with [W]."))
								return
							user.visible_message(SPAN("danger", "<b>[user]</b> rips the skin off [H] with [W], revealing a skull."))
							if(istype(H.loc, /turf))
								new H.skull_path(H.loc)
								gibs(H.loc)
							else
								new H.skull_path(user.loc)
								gibs(user.loc)
							H.skull_path = null // So no skulls dupe in case of lags
							qdel(src)
						else
							if(src && !QDELETED(src))
								food_organ.appearance = food_organ_type
								food_organ.forceMove(get_turf(loc))
								food_organ = null
								qdel(src)
							user.visible_message(SPAN_DANGER("<b>[user]</b> fishes around fruitlessly in [src] with [W]."))
				return
	..()


/**
 *  Get a list of contents of this organ and all the child organs
 */
/obj/item/organ/external/proc/get_contents_recursive()
	var/list/all_items = list()

	all_items.Add(implants)
	all_items.Add(internal_organs)
	all_items.Add(embedded_objects)

	for(var/obj/item/organ/external/child in children)
		all_items.Add(child.get_contents_recursive())

	return all_items

/obj/item/organ/external/update_health()
	damage = min(max_damage, (brute_dam + burn_dam))
	return

/obj/item/organ/external/replaced(mob/living/carbon/human/target)
	..()

	if(!QDELETED(owner))

		if(limb_flags & ORGAN_FLAG_CAN_GRASP && length(owner.grasp_limbs))
			owner.grasp_limbs[src] = TRUE
		if(limb_flags & ORGAN_FLAG_CAN_STAND && length(owner.stance_limbs))
			owner.stance_limbs[src] = TRUE
		owner.organs_by_name[organ_tag] = src
		owner.organs |= src

		if(owner.mind?.vampire)
			limb_flags &= ~ORGAN_FLAG_CAN_BREAK

		for(var/obj/item/organ/organ in internal_organs)
			organ.replaced(owner, src)

		for(var/obj/implant in implants)
			implant.forceMove(owner)

			if(istype(implant, /obj/item/implant))
				var/obj/item/implant/imp_device = implant

				// we can't use implanted() here since it's often interactive
				imp_device.imp_in = owner
				imp_device.implanted = 1

		for(var/obj/item/organ/external/organ in children)
			organ.replaced(owner)

	if(!parent && parent_organ)
		parent = owner.organs_by_name[src.parent_organ]
		if(parent)
			if(!parent.children)
				parent.children = list()
			parent.children.Add(src)
			/// NOWOUNDS TODO: Stump removal
			parent.update_damages()

//Helper proc used by various tools for repairing robot limbs
/obj/item/organ/external/proc/robo_repair(repair_amount, damage_type, damage_desc, obj/item/tool, mob/living/user)
	if((!BP_IS_ROBOTIC(src)))
		return 0

	var/damage_amount
	switch(damage_type)
		if(BRUTE) damage_amount = brute_dam
		if(BURN)  damage_amount = burn_dam
		else return 0

	if(!damage_amount)
		if(src.hatch_state != HATCH_OPENED)
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
		return 0

	if(damage_amount >= ROBOLIMB_SELF_REPAIR_CAP)
		to_chat(user, "<span class='danger'>The damage is far too severe to patch over externally.</span>")
		return 0

	if(user == src.owner)
		var/grasp
		if(user.l_hand == tool && (src.body_part & (ARM_LEFT|HAND_LEFT)))
			grasp = BP_L_HAND
		else if(user.r_hand == tool && (src.body_part & (ARM_RIGHT|HAND_RIGHT)))
			grasp = BP_R_HAND

		if(grasp)
			to_chat(user, "<span class='warning'>You can't reach your [src.name] while holding [tool] in your [owner.get_bodypart_name(grasp)].</span>")
			return 0

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(!do_mob(user, owner, 10))
		to_chat(user, "<span class='warning'>You must stand still to do that.</span>")
		return 0

	switch(damage_type)
		if(BRUTE) src.heal_damage(repair_amount, 0, 0, 1)
		if(BURN)  src.heal_damage(0, repair_amount, 0, 1)
	owner.regenerate_icons()
	if(user == src.owner)
		user.visible_message("<span class='notice'>\The [user] patches [damage_desc] on \his [src.name] with [tool].</span>")
	else
		user.visible_message("<span class='notice'>\The [user] patches [damage_desc] on [owner]'s [src.name] with [tool].</span>")

	return 1


/*
This function completely restores a damaged organ to perfect condition.
*/
/obj/item/organ/external/rejuvenate(ignore_prosthetic_prefs = FALSE)
	var/list/kept_modules = list()
	for(var/obj/item/organ_module/module in organ_modules)
		kept_modules += module

	damage_state = "00"

	status = 0

	burn_dam = 0
	brute_dam = 0
	cut_dam = 0
	pierce_dam = 0
	blunt_dam = 0

	germ_level = 0
	genetic_degradation = 0

	remove_all_pain()

	// handle internal organs
	for(var/obj/item/organ/current_organ in internal_organs)
		current_organ.rejuvenate(ignore_prosthetic_prefs)

	// remove embedded objects and drop them on the floor
	drop_embedded_objects()

	for(var/obj/implanted_object in implants)
		if(istype(implanted_object, /obj/item/organ_module))
			continue
		if(!istype(implanted_object,/obj/item/implant)) // We don't want to remove REAL implants. Just stuck things etc.
			implanted_object.dropInto(get_turf(src))
			implants -= implanted_object

	for(var/obj/item/organ_module/module in kept_modules)
		if(QDELETED(module))
			continue
		if(module.loc != src)
			module.forceMove(src)
		if(!(module in organ_modules))
			organ_modules += module
		if(!(module in implants))
			implants += module

	if(owner && !ignore_prosthetic_prefs)
		if(owner.client && owner.client.prefs && owner.client.prefs.real_name == owner.real_name)
			var/status = owner.client.prefs.organ_data[organ_tag]
			if(status == "amputated")
				remove_rejuv()
			else if(status == "cyborg")
				var/robodata = owner.client.prefs.rlimb_data[organ_tag]
				if(robodata)
					robotize(robodata)
				else
					robotize()
		owner.update_health()

/obj/item/organ/external/remove_rejuv()
	if(owner)
		owner.organs -= src
		owner.organs_by_name -= organ_tag
		while(null in owner.organs) owner.organs -= null
	if(children && children.len)
		for(var/obj/item/organ/external/E in children)
			if(E) E.remove_rejuv()
	children.Cut()
	for(var/obj/item/organ/internal/I in internal_organs)
		if(I) I.remove_rejuv()
	..()

/****************************************************
			   PROCESSING & UPDATING
****************************************************/

//external organs handle brokenness a bit differently when it comes to damage.
/obj/item/organ/external/is_broken()
	return ((status & ORGAN_CUT_AWAY) || ((status & ORGAN_BROKEN) && !splinted))

/obj/item/organ/external/proc/is_dislocated()
	if(dislocated > 0)
		return 1
	if(is_parent_dislocated())
		return 1//if any parent is dislocated, we are considered dislocated as well
	return 0

/obj/item/organ/external/proc/is_parent_dislocated()
	var/obj/item/organ/external/O = parent
	while(O && O.dislocated != -1)
		if(O.dislocated == 1)
			return 1
		O = O.parent
	return 0

//Determines if we even need to process this organ.
/obj/item/organ/external/proc/need_process()
	if(get_pain())
		return TRUE

	if(status & (ORGAN_CUT_AWAY|ORGAN_BLEEDING|ORGAN_BROKEN|ORGAN_DEAD|ORGAN_MUTATED))
		return TRUE

	if((brute_dam || burn_dam) && !BP_IS_ROBOTIC(src)) //Robot limbs don't autoheal and thus don't need to process when damaged
		return TRUE

	if(last_dam != brute_dam + burn_dam) // Process when we are fully healed up.
		last_dam = brute_dam + burn_dam
		return TRUE

	last_dam = brute_dam + burn_dam

	if(germ_level)
		return TRUE

	return FALSE

/obj/item/organ/external/var/should_update_damage_icons_this_tick = FALSE

/obj/item/organ/external/think()
	if(owner)
		// Process wounds, doing healing etc. Only do this every few ticks to save processing power
		if(owner.life_tick % wound_update_accuracy == 0)
			should_update_damage_icons_this_tick = handle_regeneration()
	else
		remove_all_pain()
		..()

/obj/item/organ/external/cook_organ()
	..()
	for(var/obj/item/organ/internal in internal_organs)
		internal.cook_organ()

/obj/item/organ/external/die()
	for(var/obj/item/organ/external/E in children)
		E.take_blunt_damage(10, "parent organ sepsis", TRUE)
	..()

// Handles natural heal, internal bleedings and infections
/obj/item/organ/external/proc/handle_regeneration()
	if(BP_IS_ROBOTIC(src)) // T-1000 would NOT be proud.
		return

	var/mob/living/carbon/human/H
	if(ishuman(owner))
		H = owner

	var/heal_amt = H ? H.coagulation * 0.5 : 0.5

	if(!heal_amt)
		return // No autoheal

	// Organs won't autoheal until all the wounds are scabbed.
	// Scabbing progresses faster under properly-applied bandages.
	if(scabbed < max_bleeding)
		if(!clamped)
			scabbed += (H ? H.coagulation : 1.0) * ((bandaged >= scabbed) ? 1:0 * 0.5) * wound_update_accuracy
	else
		heal_amt = round(heal_amt * wound_update_accuracy * config.health.organ_regeneration_multiplier, 0.1)

		// Evenly spreading regeneration between burn and brute damage if both are present
		if(burn_dam && brute_dam)
			heal_amt *= 0.5

		if(burn_dam)
			heal_burn_damage(heal_amt * (salved ? 2.5 : 1.0), FALSE, FALSE, FALSE)

		if(brute_dam)
			if(blunt_dam && (pierce_dam || cut_dam))
				heal_amt *= 0.5

			 if(blunt_dam)
			 	heal_blunt_damage(heal_amt * (salved ? 2.5 : 1.0), FALSE, FALSE, FALSE)

			// Wounds won't close naturally if they are clamped
			if(!clamped)
				heal_sharp_damage(heal_amt, FALSE, FALSE, FALSE)

	update_damages()
	owner?.update_health()
	return update_damstate()

// Updates damage ratios, bleeding status, etc.
/obj/item/organ/external/proc/update_damages()
	if(owner && (owner.status_flags & GODMODE))
		max_bleeding = 0
		bandaged = 0
		scabbed = 0
		bleeding = 0
		brute_dam = 0
		burn_dam = 0
		return

	// Bleeding
	if(!BP_IS_ROBOTIC(src))
		max_bleeding = max(cut_dam, pierce_dam)
		bandaged = clamp(bandaged, 0, max_bleeding)
		scabbed = clamp(scabbed, 0, max_bleeding)

		bleeding = clamped ? 0 : floor(max_bleeding - max(bandaged, scabbed))

		if(bleeding)
			status |= ORGAN_BLEEDING
		else
			status &= ~ORGAN_BLEEDING

	brute_dam = blunt_dam + cut_dam + pierce_dam

	// Ratios
	burn_ratio = burn_dam / max_damage
	brute_ratio = brute_dam / max_damage
	blunt_ratio = blunt_dam / max_damage
	cut_ratio = cut_dam / max_damage
	pierce_ratio = pierce_dam / max_damage
	return

//Returns TRUE if damage_state changed
/obj/item/organ/external/proc/update_damstate()
	var/tburn = 0
	var/tbrute = 0

	if(!burn_dam)
		tburn = 0
	else if(burn_dam < max_damage * 0.25)
		tburn = 1
	else if(burn_dam < max_damage * 0.75)
		tburn = 2
	else
		tburn = 3

	if(!brute_dam)
		tbrute = 0
	else if(brute_dam < max_damage * 0.25)
		tbrute = 1
	else if(brute_dam < max_damage)
		tbrute = 2
	else
		tbrute = 3

	if(damage_state != "[tbrute][tburn]")
		damage_state = "[tbrute][tburn]"
		return TRUE
	return FALSE

/****************************************************
			   DISMEMBERMENT
****************************************************/
/obj/item/organ/external/proc/get_droplimb_messages_for(droptype, clean)
	switch(droptype)
		if(DROPLIMB_EDGE)
			if(!clean)
				var/gore_sound = "[BP_IS_ROBOTIC(src) ? "tortured metal" : "ripping tendons and flesh"]"
				return list(
					"\The [owner]'s [src.name] flies off in an arc!",\
					"Your [src.name] goes flying off!",\
					"You hear a terrible sound of [gore_sound]." \
					)
		if(DROPLIMB_BURN)
			var/gore = "[BP_IS_ROBOTIC(src) ? "": " of burning flesh"]"
			if(clean)
				return list(
					"\The [owner]'s [src.name] flashes away into ashes!",\
					"Your [src.name] flashes away into ashes!",\
					"You hear a crackling sound[gore]." \
					)
			else
				return list(
					"\The [owner]'s [src.name] burns away into ashes!",\
					"Your [src.name] burns away into ashes!",\
					"You hear a crackling sound[gore]." \
					)
		if(DROPLIMB_BLUNT)
			var/gore = "[BP_IS_ROBOTIC(src) ? "": " in shower of gore"]"
			var/gore_sound = "[BP_IS_ROBOTIC(src) ? "rending sound of tortured metal" : "sickening splatter of gore"]"
			return list(
				"\The [owner]'s [src.name] explodes[gore]!",\
				"Your [src.name] explodes[gore]!",\
				"You hear the [gore_sound]." \
				)

//Handles dismemberment
/obj/item/organ/external/proc/droplimb(clean, disintegrate = DROPLIMB_EDGE, ignore_children, silent, drop_modules = FALSE)

	if(!(limb_flags & ORGAN_FLAG_CAN_AMPUTATE) || !owner)
		return

	if(disintegrate == DROPLIMB_EDGE && species.limbs_are_nonsolid)
		disintegrate = DROPLIMB_BLUNT //splut

	if(!silent)
		var/list/organ_msgs = get_droplimb_messages_for(disintegrate, clean)
		if(LAZYLEN(organ_msgs) >= 3)
			owner.visible_message("<span class='danger'>[organ_msgs[1]]</span>", \
				"<span class='moderate'><b>[organ_msgs[2]]</b></span>", \
				"<span class='danger'>[organ_msgs[3]]</span>")

	var/mob/living/carbon/human/victim = owner //Keep a reference for post-removed().
	var/obj/item/organ/external/parent_organ = parent

	var/use_flesh_colour = species.get_flesh_colour(owner)
	var/use_blood_colour = species.get_blood_colour(owner)
	adjust_pain(60)

	removed(null, 0, ignore_children, (disintegrate != DROPLIMB_EDGE))
	if(QDELETED(src))
		victim.update_health()
		victim.update_damage_overlays()
		victim.regenerate_icons()
		return

	if(drop_modules)
		for(var/obj/item/organ_module/module in organ_modules.Copy())
			module.remove(src)

	if(!clean)
		victim.shock_stage += min_broken_damage

	if(parent_organ)
		if(clean)
			/// NOWOUNDS TODO: Better way to implement clean cut bleeding
			parent_organ.take_cut_damage(min_broken_damage, "a limb amputation", TRUE)
			parent_organ.update_damages()
		else
			var/obj/item/organ/external/stump/stump = new (victim, src)
			stump.SetName("stump of \a [name]")
			stump.artery_name = "mangled [artery_name]"
			stump.arterial_bleed_severity = arterial_bleed_severity
			stump.adjust_pain(max_damage)

			victim.organs |= stump

			stump.movement_tally = stumped_tally * damage_multiplier
			if(disintegrate != DROPLIMB_BURN)
				stump.sever_artery()

			stump.update_damages()
			stump.replaced(victim)

	victim.update_organ_movespeed()

	spawn(1) // Yes, we DO need to wait before regenerating icons since all the stuff takes a literal eternity
		if(!QDELETED(victim)) // Since the victim can misteriously vanish during that spawn(1) causing runtimes
			victim.update_health()
			victim.update_damage_overlays()
			victim.regenerate_icons()

	dir = 2
	switch(disintegrate)
		if(DROPLIMB_EDGE)
			compile_icon()
			add_blood(victim)
			if(organ_tag == BP_HEAD)
				SetTransform(rotation = 90)
			else
				SetTransform(rotation = rand(180))
			forceMove(victim.loc)
			update_icon_drop(victim)
			if(!clean && !QDELETED(src)) // Throw limb around.
				if(isturf(loc))
					throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1, 3), rand(1, 2))
				dir = 2
		if(DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(victim.loc)
			for(var/obj/item/I in src)
				if(I.w_class > ITEM_SIZE_SMALL && !istype(I, /obj/item/organ))
					I.forceMove(victim.loc)
			qdel(src)
		if(DROPLIMB_BLUNT)
			var/obj/effect/decal/cleanable/blood/gibs/gore
			if(BP_IS_ROBOTIC(src))
				gore = new /obj/effect/decal/cleanable/blood/gibs/robot(victim.loc)
			else
				gore = new /obj/effect/decal/cleanable/blood/gibs(victim.loc)
				if(species)
					gore.fleshcolor = use_flesh_colour
					gore.basecolor = use_blood_colour
					gore.update_icon()

			for(var/obj/item/I in src)
				I.forceMove(victim.loc)
				if(isturf(I.loc))
					I.throw_at(get_edge_target_turf(I, pick(GLOB.alldirs)), rand(1, 2), rand(1, 2))

			qdel(src)

/****************************************************
			   HELPERS
****************************************************/

/obj/item/organ/external/proc/is_stump()
	return 0

/obj/item/organ/external/proc/release_restraints(mob/living/carbon/human/holder)
	if(!holder)
		holder = owner
	if(!holder)
		return
	if (holder.handcuffed && (body_part in list(ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT)))
		holder.visible_message(\
			"\The [holder.handcuffed.name] falls off of [holder.name].",\
			"\The [holder.handcuffed.name] falls off you.")
		holder.drop(holder.handcuffed, force = TRUE)

// Checks if the organ is fully bandaged
/obj/item/organ/external/proc/is_bandaged()
	return (bandaged >= max_bleeding)

// Applies the amt of 'bandaged', up to 'max_bleeding'.
// Returns the amount of bleeding left.
/obj/item/organ/external/proc/bandage(amt = 999)
	if(bandaged >= max_bleeding)
		return 0 // No bandaging needed

	if(amt == -1)
		bandaged = max_bleeding
	else
		bandaged = min(max_bleeding, bandaged + amt)

	update_damages()
	if(owner)
		owner.update_surgery()
		owner.update_bandages(TRUE)

	return (max_bleeding - bandaged)

/obj/item/organ/external/proc/salve()
	salved = TRUE
	return

/obj/item/organ/external/proc/clamp_organ()
	if(clamped || !max_bleeding)
		return FALSE

	clamped = TRUE
	bandaged = 0
	update_damages()
	owner?.update_surgery()
	return TRUE

/obj/item/organ/external/proc/remove_clamps()
	. = clamped
	clamped = FALSE
	return

/obj/item/organ/external/proc/update_tally()
	movement_tally = initial(movement_tally)
	if(splinted)
		movement_tally += splinted_tally * damage_multiplier
	else if(status & ORGAN_BROKEN)
		movement_tally += broken_tally * damage_multiplier

	for(var/obj/item/organ_module/module in organ_modules)
		movement_tally += module.organ_tally

	owner?.update_organ_movespeed()

/obj/item/organ/external/proc/fracture()
	if(!config.health.bones_can_break)
		return
	if(BP_IS_ROBOTIC(src))
		return	//ORGAN_BROKEN doesn't have the same meaning for robot limbs
	if((status & ORGAN_BROKEN) || !(limb_flags & ORGAN_FLAG_CAN_BREAK))
		return

	if(owner)
		owner.visible_message(\
			"<span class='danger'>You hear a loud cracking sound coming from \the [owner].</span>",\
			"<span class='danger'>Something feels like it shattered in your [name]!</span>",\
			"<span class='danger'>You hear a sickening crack.</span>")
		jostle_bone()
		if(can_feel_pain())
			owner.emote("scream")

	playsound(src.loc, SFX_BREAK_BONE, 100, 1, -2)
	status |= ORGAN_BROKEN
	update_tally()

	//Kinda difficult to keep standing when your leg's gettin' wrecked, eh?
	if(limb_flags & ORGAN_FLAG_CAN_STAND)
		if(prob(67))
			owner.Weaken(5)
			owner.Stun(3)

	broken_description = pick("broken", "fracture", "hairline fracture")

	// Fractures have a chance of getting you out of restraints
	if (prob(25))
		release_restraints()

	// This is mostly for the ninja suit to stop ninja being so crippled by breaks.
	// TODO: consider moving this to a suit proc or process() or something during
	// hardsuit rewrite.
	if(!splinted && owner && istype(owner.wear_suit, /obj/item/clothing/suit/space/rig))
		var/obj/item/clothing/suit/space/rig/suit = owner.wear_suit
		suit.handle_fracture(owner, src)

/obj/item/organ/external/proc/mend_fracture(use_damage_check = FALSE)
	if(BP_IS_ROBOTIC(src))
		return FALSE // ORGAN_BROKEN doesn't have the same meaning for robot limbs
	if(use_damage_check && (blunt_dam >= min_broken_damage * config.health.organ_health_multiplier))
		return FALSE // will just immediately fracture again

	status &= ~ORGAN_BROKEN
	update_tally()
	return TRUE

/obj/item/organ/external/proc/apply_splint(atom/movable/splint)
	if(!splinted)
		splinted = splint
		update_tally()
		if(!applied_pressure)
			applied_pressure = splint
		return 1
	return 0

/obj/item/organ/external/proc/remove_splint()
	if(splinted)
		if(splinted.loc == src)
			splinted.dropInto(owner? owner.loc : src.loc)
		if(applied_pressure == splinted)
			applied_pressure = null
		splinted = null
		update_tally()
		return 1
	return 0

/obj/item/organ/external/robotize(company, skip_prosthetics = FALSE, keep_organs = FALSE, just_printed = FALSE)

	if(BP_IS_ROBOTIC(src))
		return

	..()
	// TODO[V] Investigate why BEEDAUNS made robotize() obliterate all existing flags instead of just adding one

	if(just_printed)
		status |= ORGAN_CUT_AWAY

	if(company)
		var/datum/robolimb/R = GLOB.all_robolimbs[company]
		brute_mod = R?.brute_mod
		burn_mod = R?.burn_mod

		if(!R || (species && (species.name in R.species_cannot_use)) || \
		 (R.restricted_to.len && !(species.name in R.restricted_to)) || \
		 (R.applies_to_part.len && !(organ_tag in R.applies_to_part)))
			R = basic_robolimb
		else
			model = company
			desc = "[R.desc] It looks like it was produced by [R.company]."

		name = "robotic [initial(name)]"
		force_icon = (species && (species.name in R.racial_icons)) ? R.racial_icons[species.name] : R.icon

	dislocated = -1
	remove_splint()
	update_icon(1)
	unmutate()
	update_tally()

	for(var/obj/item/organ/external/T in children)
		T.robotize(company, 1)

	if(owner)

		if(!skip_prosthetics)
			owner.full_prosthetic = null // Will be rechecked next isSynthetic() call.

		if(!keep_organs)
			for(var/obj/item/organ/thing in internal_organs)
				if(istype(thing))
					if(thing.vital || BP_IS_ROBOTIC(thing))
						continue
					internal_organs -= thing
					owner.internal_organs_by_name -= thing.organ_tag
					owner.internal_organs.Remove(thing)
					qdel(thing)

		while(null in owner.internal_organs)
			owner.internal_organs -= null

	return 1

/obj/item/organ/external/proc/get_damage()	//returns total damage
	return (brute_dam+burn_dam)	//could use max_damage?

/obj/item/organ/external/is_usable(ignore_pain = FALSE)
	return ..() && !is_stump() && !(status & ORGAN_TENDON_CUT) && (ignore_pain || !can_feel_pain() || get_pain() < pain_disability_threshold) && brute_ratio < 1 && burn_ratio < 1 && is_robotic_usable()

/obj/item/organ/external/proc/is_robotic_usable()
	if(BP_IS_ROBOTIC(src))
		return TRUE
	if(organ_tag == BP_CHEST)
		return TRUE
	if(organ_tag == BP_HEAD)
		return TRUE

	if(!LAZYLEN(organ_modules))
		return TRUE

	if(is_path_in_list(/obj/item/organ_module/actuators, organ_modules))
		return TRUE

	if(is_path_in_list(/obj/item/organ_module/muscle, organ_modules))
		return TRUE

	return FALSE


/obj/item/organ/external/proc/is_malfunctioning()
	return (BP_IS_ROBOTIC(src) && (brute_dam + burn_dam) >= 10 && prob(brute_dam + burn_dam))

/obj/item/organ/external/proc/embed(obj/item/W, silent = 0, supplied_message)
	if(!owner || loc != owner)
		return FALSE
	if(W.w_class > ITEM_SIZE_NORMAL)
		return FALSE
	if(species.species_flags & SPECIES_FLAG_NO_EMBED)
		return FALSE
	if(!silent)
		if(supplied_message)
			owner.visible_message("<span class='danger'>[supplied_message]</span>")
		else
			owner.visible_message("<span class='danger'>\The [W] sticks in the wound!</span>")

	LAZYADD(embedded_objects, W)
	owner.embedded_flag = 1
	owner.verbs += /mob/proc/yank_out_object
	W.add_blood(owner)
	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop(W, src, force = TRUE)
	else
		W.forceMove(src)

	return TRUE

/obj/item/organ/external/removed(mob/living/user, drop_organ = 1, ignore_children = 0, detach_children_and_internals = 0)
	if(!owner)
		return

	if(limb_flags & ORGAN_FLAG_CAN_GRASP) owner.grasp_limbs -= src
	if(limb_flags & ORGAN_FLAG_CAN_STAND) owner.stance_limbs -= src

	switch(body_part)
		if(FOOT_LEFT, FOOT_RIGHT)
			owner.drop(owner.shoes, force = TRUE)
		if(HAND_LEFT)
			owner.drop(owner.gloves, force = TRUE)
			owner.drop_l_hand(force = TRUE)
		if(HAND_RIGHT)
			owner.drop(owner.gloves, force = TRUE)
			owner.drop_r_hand(force = TRUE)
		if(HEAD)
			owner.drop(owner.glasses, force = TRUE)
			owner.drop(owner.head, force = TRUE)
			owner.drop(owner.l_ear, force = TRUE)
			owner.drop(owner.r_ear, force = TRUE)
			owner.drop(owner.wear_mask, force = TRUE)

	var/mob/living/carbon/human/victim = owner

	..()

	victim.bad_external_organs -= src

	remove_splint()
	for(var/atom/movable/implant in implants)
		//large items and non-item objs fall to the floor, everything else stays
		var/obj/item/I = implant
		if(istype(I) && I.w_class < ITEM_SIZE_NORMAL)
			implant.forceMove(src)

			// let actual implants still inside know they're no longer implanted
			if(istype(I, /obj/item/implant))
				var/obj/item/implant/imp_device = I
				imp_device.imp_in = null
		else
			implants.Remove(implant)
			implant.forceMove(get_turf(src))

	// Attached organs also fly off.
	if(!ignore_children)
		for(var/obj/item/organ/external/O in children)
			O.removed()
			if(!QDELETED(O) && !detach_children_and_internals)
				O.forceMove(src)

				// if we didn't lose the organ we still want it as a child
				children += O
				O.parent = src

	// Grab all the internal giblets too.
	for(var/obj/item/organ/organ in internal_organs)
		organ.removed(user, 0, detach_children_and_internals)  // Organ stays inside and connected
		if(!QDELETED(organ))
			organ.forceMove(src)

	// Remove parent references
	if(parent)
		parent.children -= src
		parent = null

	release_restraints(victim)
	victim.organs -= src
	victim.organs_by_name -= organ_tag

	//Robotic limbs explode if sabotaged.
	if(BP_IS_ROBOTIC(src) && (status & ORGAN_SABOTAGED))
		victim.visible_message(
			"<span class='danger'>\The [victim]'s [src.name] explodes violently!</span>",\
			"<span class='danger'>Your [src.name] explodes!</span>",\
			"<span class='danger'>You hear an explosion!</span>")
		explosion(get_turf(owner), -1, -1, 2, 3)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, victim)
		spark_system.attach(owner)
		spark_system.start()
		spawn(10)
			qdel(spark_system)
		qdel(src)
	else if(is_stump())
		qdel(src)

/obj/item/organ/external/head/proc/disfigure(type = "brute")
	if(status & ORGAN_DISFIGURED)
		return
	if(!(limb_flags & ORGAN_FLAG_CAN_BREAK)) // No need to disfigure xenomorphs and dionaea, right?
		return
	if(owner)
		if(type == "brute")
			owner.visible_message("<span class='danger'>You hear a sickening cracking sound coming from \the [owner]'s [name].</span>",	\
			"<span class='danger'>Your [name] becomes a mangled mess!</span>",	\
			"<span class='danger'>You hear a sickening crack.</span>")
		else
			owner.visible_message("<span class='danger'>\The [owner]'s [name] melts away, turning into mangled mess!</span>",	\
			"<span class='danger'>Your [name] melts away!</span>",	\
			"<span class='danger'>You hear a sickening sizzle.</span>")
	status |= ORGAN_DISFIGURED

// Cutting the organ deep enough to conduct surgeries.
// This is the incision step of surgery.
/obj/item/organ/external/proc/surgically_incise(used_weapon = null)
	if(pierce_dam >= min_broken_damage)
		return
	take_pierce_damage(min_broken_damage - pierce_dam, used_weapon, TRUE)
	owner?.update_surgery()
	return

// Stretching the wound to be wide enough to conduct surgeries.
// This is the retract step of surgery.
/obj/item/organ/external/proc/surgically_retract(used_weapon = null)
	if(cut_dam >= min_broken_damage)
		return // It's wider than enough already.
	take_cut_damage(min_broken_damage - cut_dam, used_weapon, TRUE)
	if(!encased)
		for(var/obj/item/implant/I in implants)
			I.exposed()
	owner?.update_surgery()
	return

/obj/item/organ/external/proc/is_surgically_open(check_clamps = TRUE)
	. = SURGERY_CLOSED
	if(check_clamps && !clamped)
		return
	if(pierce_dam >= min_broken_damage * 0.5)
		. = SURGERY_OPEN
		if(cut_dam >= min_broken_damage * 0.5)
			. = SURGERY_RETRACTED
			if(encased && (status & ORGAN_BROKEN))
				. = SURGERY_ENCASED
	return

/obj/item/organ/external/proc/jostle_bone(force)
	if(!(status & ORGAN_BROKEN)) //intact bones stay still
		return
	if(brute_dam + force < min_broken_damage/5)	//no papercuts moving bones
		return
	if(length(internal_organs) && prob(brute_dam + force))
		owner.custom_pain("A piece of bone in your [encased ? encased : name] moves painfully!", 50, affecting = src)
		var/obj/item/organ/internal/I = pick(internal_organs)
		I.take_internal_damage(rand(3,5))

/obj/item/organ/external/proc/get_damages_desc()
	var/is_robotic = BP_IS_ROBOTIC(src)

	var/flavor_text = ""

	var/blunt_desc = ""
	if(blunt_dam)
		switch(round((blunt_dam / max_damage) * 100))
			if(1 to 33)
				blunt_desc = "lightly" + (is_robotic ? "dented" : "bruised")
			if(34 to 66)
				blunt_desc = (is_robotic ? "dented" : "bruised")
			if(66 to 99)
				blunt_desc = "severely" + (is_robotic ? "dented" : "bruised")
			if(100)
				blunt_desc = "<b>crushed</b>"

	var/sharp_desc = ""
	if(cut_dam)
		switch(round((cut_dam / max_damage) * 100))
			if(0 to 20)
				sharp_desc = "narrow"
			if(21 to 45)
				sharp_desc = ""
			if(46 to 70)
				sharp_desc = "wide"
			if(71 to 99)
				sharp_desc = "gaping"
			if(100)
				sharp_desc = "<b>massive</b>"
	if(pierce_dam)
		if(sharp_desc)
			sharp_desc += ", "
		switch(round((pierce_dam / max_damage) * 100))
			if(0 to 20)
				sharp_desc += "shallow"
			if(21 to 45)
				sharp_desc += ""
			if(46 to 70)
				sharp_desc += "deepish"
			if(71 to 99)
				sharp_desc += "deep"
			if(100)
				sharp_desc += "<b>penetrating</b>"

	var/burns_desc = ""
	if(burn_dam)
		if(!is_robotic)
			switch(round(burn_ratio))
				if(1 to 10)
					burns_desc = "a few blisters"
				if(11 to 20)
					burns_desc = "some blisters"
				if(21 to 45)
					burns_desc = "burns"
				if(46 to 70)
					burns_desc = "severe burns"
				if(71 to 99)
					burns_desc = "massive burns"
				if(100 to 150)
					burns_desc = "<b>carbonised burns</b>"
				if(151 to 200)
					burns_desc = "<b>horrifying charred burns</b>"
		else
			switch(round(burn_ratio))
				if(1 to 10)
					burns_desc = "a few burn marks"
				if(11 to 20)
					burns_desc = "some burn marks"
				if(21 to 45)
					burns_desc = "scorches"
				if(46 to 70)
					burns_desc = "severe scorches"
				if(71 to 99)
					burns_desc = "massive scorches"
				if(100 to 150)
					burns_desc = "<b>severe melting</b>"
				if(151 to 200)
					burns_desc = "<b>massive melting</b>"

	var/bandages_desc = ""
	if(max_bleeding)
		if(bandaged >= max_bleeding)
			flavor_text += "bandaged "
		else if(scabbed >= max_bleeding)
			flavor_text += "scabbed "
		else if(bandaged && bleeding)
			flavor_text += "partially bandaged, bleeding "
		else
			flavor_text += "<b>bleeding</b> "

	// Assembling all the stuff from above into a human-readable line
	if(blunt_desc)
		flavor_text += "is " + blunt_desc

	if(sharp_desc)
		if(flavor_text)
			flavor_text += ", has "
		else
			flavor_text += "has "
		flavor_text += bandages_desc + sharp_desc + (is_robotic ? " tears" : " wounds")

	if(burns_desc)
		if(flavor_text)
			flavor_text += ", with "
		else
			flavor_text = "has "
		flavor_text += burns_desc

	return flavor_text

/obj/item/organ/external/proc/get_wounds_desc()
	if(BP_IS_ROBOTIC(src))
		var/list/descriptors = list()
		switch(hatch_state)
			if(HATCH_UNSCREWED)
				descriptors += "a closed but unsecured panel"
			if(HATCH_OPENED)
				descriptors += "an open panel"
		return english_list(descriptors)

	var/list/flavor_text = list()
	if((status & ORGAN_CUT_AWAY) && !is_stump() && !(parent && parent.status & ORGAN_CUT_AWAY))
		flavor_text += "a tear at the [amputation_point] so severe that it hangs by a scrap of flesh"

	if(organ_tag == BP_HEAD && deformities == 1)
		flavor_text += "terrible scars on cheeks forming a horrifying smile"

	if(is_surgically_open(FALSE) >= (encased ? SURGERY_ENCASED : SURGERY_RETRACTED))
		var/list/bits = list()
		if(status & ORGAN_BROKEN)
			bits += "broken bones"
		for(var/obj/item/organ/organ in internal_organs)
			bits += "[organ.damage ? "damaged " : ""][organ.name]"
		if(bits.len)
			flavor_text += "[english_list(bits)] visible in the wounds"

	return english_list(flavor_text)

/obj/item/organ/external/get_scan_results()
	. = ..()
	if(blunt_dam)
		. += "Bruised"
	if(cut_dam || pierce_dam)
		. += "Open wound"
	if(status & ORGAN_ARTERY_CUT)
		. += "[capitalize(artery_name)] ruptured"
	if(status & ORGAN_TENDON_CUT)
		. += "Severed [tendon_name]"
	if(dislocated == 2) // non-magical constants when
		. += "Dislocated"
	if(splinted)
		. += "Splinted"
	if(status & ORGAN_BLEEDING)
		. += "Bleeding"
	if(status & ORGAN_BROKEN)
		. += capitalize(broken_description)
	if(length(implants))
		var/unknown_body = 0
		for(var/I in implants)
			var/obj/item/implant/imp = I
			if(istype(imp) && imp.known)
				. += "[capitalize(imp.name)] implanted"
			else
				unknown_body++
		if(unknown_body)
			. += "Unknown body present"

/obj/item/organ/external/proc/inspect(mob/user)
	if(is_stump())
		to_chat(user, "<span class='notice'>[owner] is missing that bodypart.</span>")
		return

	var/damage_description
	if(blunt_dam)
		damage_description = "bruised"
	if(cut_dam || pierce_dam)
		damage_description += damage_description ? " and cut" : "cut"

	user.visible_message(SPAN("notice", "[user] starts inspecting [owner]'s [name] carefully."))

	if(damage_description)
		to_chat(user, SPAN("warning", "[owner]'s [name] is [damage_description]!"))
	else
		to_chat(user, SPAN("notice", "You find no visible wounds."))

	if(LAZYLEN(embedded_objects))
		to_chat(user, SPAN("warning", "There's [english_list(embedded_objects)] sticking out of [owner]'s [name]."))

	to_chat(user, "<span class='notice'>Checking skin now...</span>")
	if(!do_mob(user, owner, 10))
		to_chat(user, "<span class='notice'>You must stand still to check [owner]'s skin for abnormalities.</span>")
		return

	var/list/badness = list()
	if(owner.shock_stage >= 30)
		badness += "clammy and cool to the touch"
	if(owner.getToxLoss() >= 25)
		badness += "jaundiced"
	if(owner.get_blood_oxygenation() <= 50)
		badness += "turning blue"
	if(owner.get_blood_circulation() <= 60)
		badness += "very pale"
	if(status & ORGAN_DEAD)
		badness += "rotting"
	if(!badness.len)
		to_chat(user, "<span class='notice'>[owner]'s skin is normal.</span>")
	else
		to_chat(user, "<span class='warning'>[owner]'s skin is [english_list(badness)].</span>")

	to_chat(user, "<span class='notice'>Checking bones now...</span>")
	if(!do_mob(user, owner, 10))
		to_chat(user, "<span class='notice'>You must stand still to feel [src] for fractures.</span>")
		return

	if(status & ORGAN_BROKEN)
		to_chat(user, "<span class='warning'>The [encased ? encased : "bone in the [name]"] moves slightly when you poke it!</span>")
		owner.custom_pain("Your [name] hurts where it's poked.",40, affecting = src)
	else
		to_chat(user, "<span class='notice'>The [encased ? encased : "bones in the [name]"] seem to be fine.</span>")

	if(status & ORGAN_TENDON_CUT)
		to_chat(user, "<span class='warning'>The tendons in [name] are severed!</span>")
	if(dislocated == 2)
		to_chat(user, "<span class='warning'>The [joint] is dislocated!</span>")
	return 1

/obj/item/organ/external/listen()
	var/list/sounds = list()
	for(var/obj/item/organ/internal/I in internal_organs)
		var/gutsound = I.listen()
		if(gutsound)
			sounds += gutsound
	if(!sounds.len)
		if(owner.pulse())
			sounds += "faint pulse"
	return sounds

/obj/item/organ/external/proc/jointlock(mob/attacker)
	if(!can_feel_pain())
		return

	var/armor = owner.run_armor_check(owner, "melee")
	if(armor < 100)
		to_chat(owner, "<span class='danger'>You feel extreme pain!</span>")

		var/max_halloss = round(owner.species.total_health * 0.8 * ((100 - armor) / 100)) //up to 80% of passing out, further reduced by armour
		adjust_pain(Clamp(0, max_halloss - owner.getHalLoss(), 30))

//Adds autopsy data for used_weapon.
/obj/item/organ/external/proc/add_autopsy_data(used_weapon, damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

/obj/item/organ/external/proc/has_genitals()
	return !BP_IS_ROBOTIC(src) && species && species.sexybits_location == organ_tag

// Added to the mob's move delay tally if this organ is being used to move with.
/obj/item/organ/external/proc/movement_delay(max_delay)
	. = 0
	if(is_stump())
		. += max_delay
	else if(splinted)
		. += max_delay/8
	else if(status & ORGAN_BROKEN)
		. += max_delay * 3/8
	else if(BP_IS_ROBOTIC(src))
		. += max_delay * CLAMP01(damage/max_damage)

/obj/item/organ/external/proc/drop_embedded_objects()
	if(!LAZYLEN(embedded_objects))
		return FALSE
	var/turf/my_turf = get_turf(src)
	for(var/obj/O in embedded_objects)
		O.forceMove(my_turf)
	LAZYCLEARLIST(embedded_objects)
	return TRUE

/obj/item/organ/external/proc/drop_embedded_object(obj/thing)
	if(!LAZYLEN(embedded_objects))
		return FALSE
	var/turf/my_turf = get_turf(src)
	for(var/obj/O in embedded_objects)
		if(O == thing)
			O.forceMove(my_turf)
			LAZYREMOVE(embedded_objects, O)
			return TRUE
	return FALSE
