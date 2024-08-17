
/obj/item/organ/external/head
	organ_tag = BP_HEAD
	icon_name = "head"
	name = "head"
	slot_flags = SLOT_BELT
	max_damage = 75
	min_broken_damage = 40
	w_class = ITEM_SIZE_NORMAL
	body_part = HEAD
	parent_organ = BP_CHEST
	joint = "jaw"
	amputation_point = "neck"
	encased = "skull"
	artery_name = "carotid artery"
	cavity_name = "cranial"
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_GENDERED_ICON | ORGAN_FLAG_HEALS_OVERKILL | ORGAN_FLAG_CAN_BREAK

	internal_organs_size = 3

	var/can_intake_reagents = 1

	var/has_lips = TRUE

	var/forehead_graffiti
	var/graffiti_style

	var/skull_path = /obj/item/skull

/obj/item/organ/external/head/droplimb(clean, disintegrate = DROPLIMB_EDGE, ignore_children, silent)
	if(BP_IS_ROBOTIC(src) && disintegrate == DROPLIMB_BURN)
		var/obj/item/organ/internal/cerebrum/mmi/MMI = owner.internal_organs_by_name[BP_BRAIN]
		if(istype(MMI))
			MMI.visible_message(SPAN_DANGER("You see a bright flash as you get catapulted out of your body. You feel disoriented, which must be normal since you're just a brain in a can."), SPAN_NOTICE("[owner]'s head ejects an MMI!"))
			MMI.removed()
	return ..()

/obj/item/organ/external/head/organ_eaten(mob/user)
	. = ..()
	var/obj/item/skull/SK = new /obj/item/skull(get_turf(src))
	if(!isturf(loc))
		user.put_in_active_hand(SK)

/obj/item/organ/external/head/examine(mob/user, infix)
	. = ..()

	if(forehead_graffiti && graffiti_style)
		. += SPAN_NOTICE("It has \"[forehead_graffiti]\" written on it in [graffiti_style]!")

/obj/item/organ/external/head/proc/write_on(mob/penman, style)
	var/head_name = name
	var/atom/target = src
	if(owner)
		head_name = "[owner]'s [name]"
		target = owner

	if(forehead_graffiti)
		to_chat(penman, "<span class='notice'>There is no room left to write on [head_name]!</span>")
		return

	var/graffiti = sanitizeSafe(input(penman, "Enter a message to write on [head_name]:") as text|null, MAX_NAME_LEN)
	if(graffiti)
		if(!target.Adjacent(penman))
			to_chat(penman, "<span class='notice'>[head_name] is too far away.</span>")
			return

		if(owner && owner.check_head_coverage())
			to_chat(penman, "<span class='notice'>[head_name] is covered up.</span>")
			return

		penman.visible_message("<span class='warning'>[penman] begins writing something on [head_name]!</span>", "You begin writing something on [head_name].")

		if(do_after(penman, 3 SECONDS, target))
			if(owner && owner.check_head_coverage())
				to_chat(penman, "<span class='notice'>[head_name] is covered up.</span>")
				return

			penman.visible_message("<span class='warning'>[penman] writes something on [head_name]!</span>", "You write something on [head_name].")
			forehead_graffiti = graffiti
			graffiti_style = style
			if(owner)
				log_and_message_admins("has written something on [owner]'s ([owner.ckey]) head: \"[graffiti]\".", penman)

/obj/item/organ/external/head/get_agony_multiplier()
	return (owner && owner.headcheck(organ_tag)) ? 1.50 : 1

/obj/item/organ/external/head/robotize(company, skip_prosthetics = FALSE, keep_organs = FALSE, just_printed = FALSE)
	if(company)
		var/datum/robolimb/R = GLOB.all_robolimbs[company]
		if(istype(R))
			can_intake_reagents = R.can_eat
	. = ..(company, skip_prosthetics, 1)
	has_lips = FALSE

/obj/item/organ/external/head/take_external_damage(brute, burn, damage_flags, used_weapon = null)
	. = ..()
	if ((brute_dam > 40) && prob(50))
		disfigure("brute")
	if (burn_dam > 40)
		disfigure("burn")

/obj/item/organ/external/head/get_icon_key()
	. = ..()
	if(owner?.lip_style && !BP_IS_ROBOTIC(src) && (species && (species.species_appearance_flags & HAS_LIPS)))
		. += "[owner.lip_style]"
	else
		. += "nolips"

	if(owner)
		var/datum/species/S = owner.species
		var/has_eyes_overlay = S.has_eyes_icon
		if(BP_IS_ROBOTIC(src)) // Robolimbs don't always have eye icon.
			var/datum/robolimb/R = GLOB.all_robolimbs[model]
			has_eyes_overlay = R?.has_eyes_icon
		if(has_eyes_overlay)
			var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[S.vision_organ ? S.vision_organ : BP_EYES]
			if(!ishuman(loc))
				for(var/thing in contents)
					if(istype(thing, /obj/item/organ/internal/eyes))
						eyes = thing
			if(eyes)
				. += "[rgb(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3])]"
			else if(owner.should_have_organ(BP_EYES))
				. += "eyeless"


/obj/item/organ/external/head/on_update_icon()
	..()
	if(owner)
		var/datum/species/S = owner.species
		var/has_eyes_overlay = S.has_eyes_icon
		if(BP_IS_ROBOTIC(src)) // Robolimbs don't always have eye icon.
			var/datum/robolimb/R = GLOB.all_robolimbs[model]
			has_eyes_overlay = R?.has_eyes_icon

		var/datum/body_build/BB = owner.body_build
		if(has_eyes_overlay)
			var/eye_icon_location = S.icobase
			var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[S.vision_organ ? S.vision_organ : BP_EYES]
			if(!ishuman(loc))
				for(var/thing in contents)
					if(istype(thing, /obj/item/organ/internal/eyes))
						eyes = thing
			if(eyes)
				mob_overlays |= mutable_appearance(eye_icon_location, "eyes[BB.index]", color = rgb(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3]), flags = DEFAULT_APPEARANCE_FLAGS|RESET_COLOR)
			else if(owner.should_have_organ(BP_EYES))
				mob_overlays |= mutable_appearance(eye_icon_location, "eyeless[BB.index]", flags = DEFAULT_APPEARANCE_FLAGS)

		if(owner.lip_style && !BP_IS_ROBOTIC(src) && species && (species.species_appearance_flags & HAS_LIPS))
			mob_overlays |= mutable_appearance(S.icobase, "lips[BB.index]", color = owner.lip_style, flags = DEFAULT_APPEARANCE_FLAGS|RESET_COLOR|RESET_ALPHA)

	SetOverlays(mob_overlays)

	AddOverlays(get_hair_icon()) // Hair is handled separately for mob icon so we do not add it to mob_overlays Maybe this should change sometime
	AddOverlays(get_facial_hair_icon()) // Hair is handled separately for mob icon so we do not add it to mob_overlays Maybe this should change sometime

/obj/item/organ/external/head/proc/get_hair_icon()
	var/image/res = image(species.icon_template,"")
	if(!owner)
		return res

	if(owner.h_style)
		var/icon/HI
		var/icon/HSI
		var/datum/sprite_accessory/hair/H = GLOB.hair_styles_list[owner.h_style]
		if((owner.head?.flags_inv & BLOCKHEADHAIR) && !(H.flags & VERY_SHORT))
			H = GLOB.hair_styles_list["Short Hair"]
		if(H)
			if((!length(H.species_allowed) || (species.name in H.species_allowed)) && species.hair_key)
				if(istype(owner.body_build,/datum/body_build/slim))
					HI = icon(GLOB.hair_icons["slim"][species.hair_key], H.icon_state)
				else
					HI = icon(GLOB.hair_icons["default"][species.hair_key], H.icon_state)

				if(H.do_coloration && length(h_col) >= 3)
					HI.Blend(rgb(h_col[1], h_col[2], h_col[3]), H.blend)

				if(H.has_secondary)
					if(istype(owner.body_build,/datum/body_build/slim))
						HSI = icon(GLOB.hair_icons["slim"][species.hair_key], H.icon_state + "_s")
					else
						HSI = icon(GLOB.hair_icons["default"][species.hair_key], H.icon_state + "_s")
					if(species.species_appearance_flags & SECONDARY_HAIR_IS_SKIN)
						if(species.species_appearance_flags & HAS_A_SKIN_TONE)
							if(s_tone >= 0)
								HSI.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
							else
								HSI.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
						else
							HSI.Blend(rgb(s_col[1], s_col[2], s_col[3]), s_col_blend)
					else if(length(h_col) >= 3)
						HSI.Blend(rgb(h_s_col[1], h_s_col[2], h_s_col[3]), H.blend)
		if(HI)
			var/list/sorted_hair_markings = list()
			for(var/E in markings)
				var/datum/sprite_accessory/marking/M = E
				if(M.draw_target == MARKING_TARGET_HAIR)
					var/color = markings[E]
					var/icon/I = icon(M.icon, M.icon_state)
					I.Blend(HI, ICON_AND)
					I.Blend(color, ICON_MULTIPLY)
					ADD_SORTED(sorted_hair_markings, list(list(M.draw_order, I)), /proc/cmp_marking_order)
			for(var/entry in sorted_hair_markings)
				HI.Blend(entry[2], ICON_OVERLAY)
			//TODO : Add emissive blocker here if hair should block it. Else, leave as is
			res.AddOverlays(HI)

		if(HSI)
			res.AddOverlays(HSI)

	var/list/sorted_head_markings = list()
	for(var/E in markings)
		var/datum/sprite_accessory/marking/M = E
		if(M.draw_target == MARKING_TARGET_HEAD)
			var/color = markings[E]
			var/icon/I = icon(M.icon, M.icon_state)
			if(!M.do_coloration && owner.h_style)
				var/datum/sprite_accessory/hair/H = GLOB.hair_styles_list[owner.h_style]
				if(H.do_coloration && length(h_col) >= 3)
					I.Blend(rgb(h_col[1], h_col[2], h_col[3]), ICON_ADD)
				else
					I.Blend(rgb(200 + s_tone, 150 + s_tone, 123 + s_tone), ICON_ADD)
			else
				I.Blend(color, ICON_ADD)
			ADD_SORTED(sorted_head_markings, list(list(M.draw_order, I)), /proc/cmp_marking_order)

	for(var/entry in sorted_head_markings)
		res.AddOverlays(entry[2])

	return res

/obj/item/organ/external/head/proc/get_facial_hair_icon()
	var/image/res = image(species.icon_template, "")
	if(!owner)
		return res

	if(owner.f_style)
		var/datum/sprite_accessory/FH = GLOB.facial_hair_styles_list[owner.f_style]
		if(FH?.species_allowed && species.facial_hair_key && (species.name in FH.species_allowed))
			var/icon/FHI
			if(istype(owner.body_build,/datum/body_build/slim))
				FHI = icon(GLOB.facial_hair_icons["slim"][species.hair_key], FH.icon_state)
			else
				FHI = icon(GLOB.facial_hair_icons["default"][species.hair_key], FH.icon_state)
			if(FH.do_coloration)
				FHI.Blend(rgb(owner.r_facial, owner.g_facial, owner.b_facial), FH.blend)
			res.AddOverlays(FHI)

	return res

/obj/item/organ/external/head/update_icon_drop(mob/living/carbon/human/powner)
	if(!powner)
		return
	owner = powner // This is kinda hackly ngl
	get_hair_icon()
	get_facial_hair_icon()
	update_icon()
	owner = null

/obj/item/skull
	name = "skull"
	desc = "Supposed to be inside someone's head."
	icon = 'icons/obj/items.dmi'
	icon_state = "skull_human"
	item_state = "skullmask"
	force = 5.0
	throwforce = 7.0
	mod_reach = 0.3
	mod_weight = 0.5
	mod_handy = 0.5
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("bludgeoned", "skulled", "buttheaded", "spooked")
	var/iscut = 0

/obj/item/skull/attackby(obj/item/W as obj, mob/user as mob)
	if(W.sharp && !iscut)
		user.visible_message("<span class='warning'><b>[user]</b> cuts [src] open with [W]!</span>")
		icon_state = "skull_human_cut"
		iscut = 1
		name = "facial bones"
		desc = "Used to be someone's face."
		return
	if((istype(W,/obj/item/handcuffs/cable)) && iscut)
		user.visible_message("<span class='notice'>[user] attaches [W] to [src].</span>")
		new /obj/item/clothing/mask/skullmask(user.loc)
		qdel(src)
		qdel(W)
		return
	if(istype(W, /obj/item/stack/material) && iscut)
		var/obj/item/stack/M = W
		if(M.get_material_name() == MATERIAL_STEEL)
			if(do_after(usr, 10, src))
				new /obj/item/reagent_containers/vessel/skullgoblet(user.loc)
				user.visible_message("<span class='notice'>[user] makes a goblet out of [src].</span>")
				M.use(1)
				qdel(src)
		else if(M.get_material_name() == MATERIAL_GOLD)
			if(do_after(usr, 10, src))
				new /obj/item/reagent_containers/vessel/skullgoblet/gold(user.loc)
				user.visible_message("<span class='notice'>[user] makes a <b>golden</b> goblet out of [src].</span>")
				M.use(1)
				qdel(src)
		return
	..()
