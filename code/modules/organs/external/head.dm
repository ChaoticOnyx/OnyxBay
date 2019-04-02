
/obj/item/organ/external/head
	organ_tag = BP_HEAD
	icon_name = "head"
	name = "head"
	slot_flags = SLOT_BELT
	max_damage = 75
	min_broken_damage = 35
	w_class = ITEM_SIZE_NORMAL
	body_part = HEAD
	parent_organ = BP_CHEST
	joint = "jaw"
	amputation_point = "neck"
	gendered_icon = 1
	encased = "skull"
	artery_name = "cartoid artery"
	cavity_name = "cranial"

	var/can_intake_reagents = 1
	var/eye_icon = "eyes_s"
	var/eye_icon_location = 'icons/mob/human_face.dmi'

	var/has_lips = 1

	var/forehead_graffiti
	var/graffiti_style

/obj/item/organ/external/head/examine(mob/user)
	. = ..()

	if(forehead_graffiti && graffiti_style)
		to_chat(user, "<span class='notice'>It has \"[forehead_graffiti]\" written on it in [graffiti_style]!</span>")

/obj/item/organ/external/head/proc/write_on(var/mob/penman, var/style)
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

/obj/item/organ/external/head/set_dna(var/datum/dna/new_dna)
	..()
	eye_icon = species.eye_icon
	eye_icon_location = species.eye_icon_location

/obj/item/organ/external/head/get_agony_multiplier()
	return (owner && owner.headcheck(organ_tag)) ? 1.50 : 1

/obj/item/organ/external/head/robotize(var/company, var/skip_prosthetics, var/keep_organs)
	if(company)
		var/datum/robolimb/R = all_robolimbs[company]
		if(R)
			can_intake_reagents = R.can_eat
			eye_icon = R.use_eye_icon
	. = ..(company, skip_prosthetics, 1)
	has_lips = null

/obj/item/organ/external/head/removed()
	if(owner)
		var/mob/living/carbon/human/victim = owner
		SetName("[victim.real_name]'s head")
		victim.drop_from_inventory(owner.glasses)
		victim.drop_from_inventory(owner.head)
		victim.drop_from_inventory(owner.l_ear)
		victim.drop_from_inventory(owner.r_ear)
		victim.drop_from_inventory(owner.wear_mask)
		update_icon_drop(victim)
		spawn(1)
			victim.update_hair()
	..()

/obj/item/organ/external/head/take_damage(brute, burn, damage_flags, used_weapon = null)
	. = ..()
	if (!disfigured)
		if (brute_dam > 40)
			if (prob(50))
				disfigure("brute")
		if (burn_dam > 40)
			disfigure("burn")

/obj/item/organ/external/head/no_eyes
	eye_icon = "blank_eyes"

/obj/item/organ/external/head/update_icon()

	..()

	if(owner)
		if(eye_icon)
			var/icon/eyes_icon = new/icon(eye_icon_location, eye_icon)
			var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[owner.species.vision_organ ? owner.species.vision_organ : BP_EYES]
			if(eyes)
				eyes_icon.Blend(rgb(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3]), ICON_ADD)
			else if(owner.should_have_organ(BP_EYES))
				eyes_icon = new/icon('icons/mob/human_face.dmi', "eyeless")
				eyes_icon.Blend(rgb(128,0,0), ICON_ADD)
			else
				eyes_icon.Blend(rgb(128,0,0), ICON_ADD)
			mob_icon.Blend(eyes_icon, ICON_OVERLAY)
			overlays |= eyes_icon

		if(owner.lip_style && robotic < ORGAN_ROBOT && (species && (species.appearance_flags & HAS_LIPS)))
			var/icon/lip_icon = new/icon('icons/mob/human_face.dmi', "lips_[owner.lip_style]_s")
			overlays |= lip_icon
			mob_icon.Blend(lip_icon, ICON_OVERLAY)

		overlays |= get_hair_icon()

	return mob_icon

/obj/item/organ/external/head/proc/get_hair_icon()
	var/image/res = image(species.icon_template,"")
	if(owner.f_style)
		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[owner.f_style]
		if(facial_hair_style && facial_hair_style.species_allowed && (species.name in facial_hair_style.species_allowed))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(owner.r_facial, owner.g_facial, owner.b_facial), facial_hair_style.blend)
			res.overlays |= facial_s

	if(owner.h_style)
		var/style = owner.h_style
		var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_list[style]
		if(owner.head && (owner.head.flags_inv & BLOCKHEADHAIR))
			if(!(hair_style.flags & VERY_SHORT))
				hair_style = GLOB.hair_styles_list["Short Hair"]
		if(hair_style && (species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration && islist(h_col) && h_col.len >= 3)
				hair_s.Blend(rgb(h_col[1], h_col[2], h_col[3]), hair_style.blend)
			res.overlays |= hair_s
	return res

/obj/item/organ/external/head/update_icon_drop(var/mob/living/carbon/human/powner)
	overlays.Cut()
	if(powner.f_style)
		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[powner.f_style]
		if(facial_hair_style && facial_hair_style.species_allowed && (species.name in facial_hair_style.species_allowed))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(powner.r_facial, powner.g_facial, powner.b_facial), facial_hair_style.blend)
			src.overlays += facial_s

	if(powner.h_style)
		var/style = powner.h_style
		var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_list[style]
		if(hair_style && (species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration && islist(h_col) && h_col.len >= 3)
				hair_s.Blend(rgb(h_col[1], h_col[2], h_col[3]), hair_style.blend)
			src.overlays += hair_s
	return

/obj/item/weapon/skull
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

/obj/item/weapon/skull/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.sharp && !iscut)
		user.visible_message("<span class='warning'><b>[user]</b> cuts [src] open with [W]!</span>")
		icon_state = "skull_human_cut"
		iscut = 1
		name = "facial bones"
		desc = "Used to be someone's face."
		return
	if((istype(W,/obj/item/weapon/handcuffs/cable)) && iscut)
		user.visible_message("<span class='notice'>[user] attaches [W] to [src].</span>")
		new/obj/item/clothing/mask/skullmask(user.loc)
		qdel(src)
		qdel(W)
		return
	if(istype(W, /obj/item/stack/material) && iscut)
		var/obj/item/stack/M = W
		if(M.get_material_name() == "steel")
			if(do_after(usr, 10, src))
				new/obj/item/weapon/reagent_containers/food/drinks/skullgoblet(user.loc)
				user.visible_message("<span class='notice'>[user] makes a goblet out of [src].</span>")
				M.use(1)
				qdel(src)
		else if(M.get_material_name() == "gold")
			if(do_after(usr, 10, src))
				new/obj/item/weapon/reagent_containers/food/drinks/skullgoblet/gold(user.loc)
				user.visible_message("<span class='notice'>[user] makes a <b>golden</b> goblet out of [src].</span>")
				M.use(1)
				qdel(src)
		return
	..()
