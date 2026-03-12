#define MEDICAL_STACK_FINITE 0
#define MEDICAL_STACK_FILLED 1
#define MEDICAL_STACK_EMPTY  2

/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 10
	max_amount = 10
	w_class = ITEM_SIZE_SMALL
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

	var/icon_state_default = ""
	var/stack_full = FALSE // 1 - stack looks different if it's never been used
	var/stack_empty = MEDICAL_STACK_FINITE // 0 - stack disappears, 1 - stack can be empty, 2 - stack is already empty

	drop_sound = SFX_DROP_CARDBOARD
	pickup_sound = SFX_PICKUP_CARDBOARD

/obj/item/stack/medical/on_update_icon()
	if(stack_full && amount == max_amount)
		icon_state = "[icon_state_default]_full"
	else if(!amount)
		icon_state = "[icon_state_default]_empty"
	else
		icon_state = icon_state_default

/obj/item/stack/medical/Initialize()
	. = ..()
	icon_state_default = icon_state
	update_icon()

/obj/item/stack/medical/use(used)
	if(uses_charge)
		return ..()

	if(stack_empty == MEDICAL_STACK_EMPTY)
		return FALSE

	if(!can_use(used))
		return FALSE

	if(used > 0)
		amount -= used

	if(get_amount() <= 0)
		if(stack_empty == MEDICAL_STACK_FINITE)
			qdel(src) //should be safe to qdel immediately since if someone is still using this stack it will persist for a little while longer
			return TRUE
		stack_empty = MEDICAL_STACK_EMPTY
		name = "empty [name]"

	update_icon()
	return TRUE

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(stack_empty == MEDICAL_STACK_EMPTY || !get_amount())
		to_chat(user, SPAN("warning", "\The [src] is empty!"))
		return TRUE

	if(!istype(M))
		to_chat(user, SPAN("warning", "\The [src] cannot be applied to [M]!"))
		return TRUE

	if(!ishuman(user) && !issilicon(user))
		to_chat(user, FEEDBACK_YOU_LACK_DEXTERITY)
		return TRUE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(!istype(affecting))
			to_chat(user, SPAN("warning", "\The [M] is missing that body part!"))
			return TRUE

		var/used_amount = apply_on_human(H, affecting, mob/user)
		if(used_amount != 0)
			H.update_health()
			if(affecting.update_damstate())
				H.update_damage_overlays()
			use(used_amount)
		return TRUE

	user.visible_message( \
		SPAN("notice", "[M] has been applied with [src] by [user]."), \
		SPAN("notice", "You apply \the [src] to [M].") \
	)
	use(1)
	M.heal_organ_damage((heal_brute / 2), (heal_burn / 2))
	return TRUE

/obj/item/stack/medical/proc/apply_on_human(mob/living/carbon/human/H, obj/item/organ/external/affecting, mob/user)
	if(BP_IS_ROBOTIC(affecting))
		to_chat(user, SPAN("warning", "This isn't useful at all on a robotic limb."))
		return 0

	var/blocked_by_clothes = null
	if(affecting.organ_tag == BP_HEAD)
		var/obj/item/clothing/C = H.head
		if(istype(C) && (C.body_parts_covered & SLOT_HEAD))
			blocked_by_clothes = C
	else
		var/obj/item/clothing/C = H.wear_suit
		if(istype(C))
			switch(affecting.organ_tag)
				if(BP_CHEST)
					if(C.body_parts_covered & UPPER_TORSO)
						blocked_by_clothes = C
				if(BP_GROIN)
					if(C.body_parts_covered & LOWER_TORSO)
						blocked_by_clothes = C
				else
					if(C.body_parts_covered & (UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS))
						blocked_by_clothes = C

	if(blocked_by_clothes)
		to_chat(user, SPAN("warning", "You can't apply [src] through [blocked_by_clothes]!"))
		return 0

	return 1

/obj/item/stack/medical/get_storage_cost()
	return base_storage_cost(w_class)

/obj/item/stack/medical/bandage
	name = "roll of bandage"
	singular_name = "bandage length"
	desc = "Name brand NanoTrasen dissolvable bandage product."
	icon_state = "bandage"
	item_state = "bandage"
	origin_tech = list(TECH_BIO = 1)
	slot_flags = SLOT_GLOVES
	heal_brute = 7.5
	stack_full = TRUE
	amount = 20
	var/bandaged_per_use = 20

/obj/item/stack/medical/bandage/apply_on_human(mob/living/carbon/human/H, obj/item/organ/external/affecting, mob/user)
	. = ..()
	if(!.)
		return

	if(affecting.is_bandaged())
		to_chat(user, SPAN("notice", "The wounds on [H]'s [affecting.name] have already been bandaged."))
		return 0

	user.visible_message(SPAN("notice", "\The [user] starts bandaging [H]'s [affecting.name]."), \
						 SPAN("notice", "You start bandaging [H]'s [affecting.name]."))

	if(!do_mob(user, H, 2.5 SECONDS))
		to_chat(user, SPAN("warning", "You must stand still to bandage wounds."))
		return 0

	var/work_done = FALSE
	while(TRUE)
		if(QDELETED(H))
			return 0

		if(QDELETED(affecting))
			to_chat(user, SPAN("warning", "[H] is missing that body part!"))
			return 0

		if(affecting.is_bandaged())
			break

		var/old_bandage_level = affecting.bandage_level()
		affecting.bandage(bandaged_per_use)
		if(old_bandage_level != affecting.bandage_level())
			H.update_bandages(1)

		use(1)
		work_done = TRUE

		if(!get_amount())
			if(affecting.is_bandaged())
				to_chat(user, SPAN("warning", "\The [src] is used up."))
			else
				to_chat(user, SPAN("warning", "\The [src] is used up, but [H]'s [affecting.name] is not properly bandaged yet!"))
			break

		if(affecting.is_bandaged())
			break

		if(!do_mob(user, H, 1 SECOND))
			to_chat(user, SPAN("warning", "You must stand still to bandage wounds."))
			break

	if(work_done) // In case if somebody's bandaged the limb before we had a chance to do anything useful.
		user.visible_message(SPAN("notice", "\The [user] bandages [H]'s [affecting.name]."), \
							 SPAN("notice", "You bandage [H]'s [affecting.name]."))

	return -1

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns and bruises. Also works as an antiseptic and topical painkiller. Smells like aloe and welding fuel."
	gender = PLURAL
	singular_name = "ointment dose"
	icon_state = "salve"
	item_state = "salve"
	heal_burn = 7.5
	origin_tech = list(TECH_BIO = 1)
	stack_empty = MEDICAL_STACK_FILLED
	splittable = 0

	drop_sound = SFX_DROP_HERB
	pickup_sound = SFX_PICKUP_HERB

/obj/item/stack/medical/ointment/apply_on_human(mob/living/carbon/human/H, obj/item/organ/external/affecting, mob/user)
	. = ..()
	if(!.)
		return

	if(affecting.salved)
		to_chat(user, SPAN("notice", "[H]'s [affecting.name] has already been salved."))
		return 0

	user.visible_message(SPAN("notice", "\The [user] starts smearing salve over [H]'s [affecting.name]."), \
						 SPAN("notice", "You start smearing salve over [H]'s [affecting.name]."))

	if(!do_mob(user, H, 2 SECONDS))
		to_chat(user, SPAN("warning", "You must stand still to apply salve."))
		return 0

	if(QDELETED(affecting))
		to_chat(user, SPAN("warning", "[H] is missing that body part!"))
		return 0

	if(affecting.salved)
		to_chat(user, SPAN("notice", "[H]'s [affecting.name] has already been salved."))
		return 0

	user.visible_message(SPAN("notice", "[user] smears some salve over [H]'s [affecting.name]."), \
						 SPAN("notice", "You smear some salve over [H]'s [affecting.name]."))

	affecting.salve()
	return 1

/obj/item/stack/medical/gel
	name = "medical gel"
	desc = "You should not be able to see this."
	stack_empty = MEDICAL_STACK_FILLED
	splittable = FALSE
	stack_full = TRUE
	amount = 20

/obj/item/stack/medical/gel/proc/refill(amt = 1)
	if(get_amount() >= max_amount)
		return 0
	amount += amt
	if(stack_empty == MEDICAL_STACK_EMPTY)
		name = initial(name)
		stack_empty = MEDICAL_STACK_FILLED
	update_icon()
	return 1

/obj/item/stack/medical/gel/proc/refill_from_same(obj/item/stack/medical/gel/I, mob/user)
	if(!istype(I))
		return

	if(I.singular_name != singular_name)
		return

	var/obj/item/stack/medical/advanced/O = I
	if(!O.amount)
		to_chat(user, SPAN("warning", "You are trying to refill \the [src] using an empty container."))
		return
	var/amt_to_transfer = min((max_amount - amount), O.amount)
	if(refill(amt_to_transfer))
		to_chat(user, SPAN("notice", "You refill \the [src] with [amt_to_transfer] doses of [O]."))
		O.use(amt_to_transfer)
	else
		to_chat(user, SPAN("notice", "\The [src] is already full."))

/obj/item/stack/medical/gel/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/medical/gel))
		refill_from_same(W, user)
		return
	..()

/obj/item/stack/medical/gel/somatic
	name = "somatic gel"
	singular_name = "somatic gel dose"
	desc = "A container of somatic gel, manufactured by Vey-Med. A bendable nozzle makes it easy to apply. Effectively seals up even severe wounds."
	icon_state = "brutegel"
	item_state = "brutegel"
	heal_brute = 15.0
	origin_tech = list(TECH_BIO = 2)

/obj/item/stack/medical/gel/somatic/apply_on_human(mob/living/carbon/human/H, obj/item/organ/external/affecting, mob/user)
	. = ..()
	if(!.)
		return

	if(affecting.status & ORGAN_BLEEDING)
		to_chat(user, SPAN("warning", "You can't treat [H]'s [affecting.name] while it's bleeding!"))
		return 0

	if(!affecting.cut_dam && !affecting.pierce_dam)
		to_chat(user, SPAN("notice", "There are no open wounds on [H]'s [affecting.name]!"))
		return 0

	user.visible_message(SPAN("notice", "\The [user] starts applying somatic gel on [H]'s [affecting.name]."), \
						 SPAN("notice", "You start applying somatic gel on [H]'s [affecting.name]."))

	if(!do_mob(user, H, 2.5 SECONDS))
		to_chat(user, SPAN("warning", "You must stand still to apply somatic gel."))
		return 0

	var/work_done = FALSE
	while(TRUE)
		if(QDELETED(H))
			return 0

		if(QDELETED(affecting))
			to_chat(user, SPAN("warning", "[H] is missing that body part!"))
			return 0

		if(!affecting.cut_dam && !affecting.pierce_dam)
			break

		affecting.heal_sharp_damage(heal_brute, FALSE)
		use(1)
		work_done = TRUE

		if(!get_amount())
			if(!affecting.cut_dam && !affecting.pierce_dam)
				to_chat(user, SPAN("warning", "\The [src] is used up."))
			else
				to_chat(user, SPAN("warning", "\The [src] is used up, but there's still a wound on [H]'s [affecting.name]!"))
			break

		if(!affecting.cut_dam && !affecting.pierce_dam)
			break

		if(!do_mob(user, H, 2 SECONDS))
			to_chat(user, SPAN("warning", "You must stand still to apply somatic gel."))
			break

	user.visible_message(SPAN("notice", "\The [user] applies somatic gel on [H]'s [affecting.name]."), \
						 SPAN("notice", "You apply somatic gel on [H]'s [affecting.name]."))

	return -1

/obj/item/stack/medical/gel/burn
	name = "burn gel"
	singular_name = "burn gel dose"
	desc = "A container of protein-renaturating gel, manufactured by Vey-Med. A bendable nozzle makes it easy to apply. It's said to renaturate proteins, effectively treating severe burns. Doesn't cause skin cancer. Probably."
	icon_state = "burngel"
	item_state = "burngel"
	heal_burn = 15
	origin_tech = list(TECH_BIO = 3)

/obj/item/stack/medical/gel/burn/apply_on_human(mob/living/carbon/human/H, obj/item/organ/external/affecting, mob/user)
	. = ..()
	if(!.)
		return

	if(affecting.status & ORGAN_BLEEDING)
		to_chat(user, SPAN("warning", "You can't treat [H]'s [affecting.name] while it's bleeding!"))
		return 0

	if(!burn_dam)
		to_chat(user, SPAN("notice", "There are no open wounds on [H]'s [affecting.name]!"))
		return 0

	user.visible_message(SPAN("notice", "\The [user] starts applying burn gel on [H]'s [affecting.name]."), \
						 SPAN("notice", "You start applying burn gel on [H]'s [affecting.name]."))

	if(!do_mob(user, H, 2.5 SECONDS))
		to_chat(user, SPAN("warning", "You must stand still to apply burn gel."))
		return 0

	var/work_done = FALSE
	while(TRUE)
		if(QDELETED(H))
			return 0

		if(QDELETED(affecting))
			to_chat(user, SPAN("warning", "[H] is missing that body part!"))
			return 0

		if(!burn_dam)
			break

		affecting.heal_burn_damage(heal_burn, FALSE)
		use(1)
		work_done = TRUE

		if(!get_amount())
			if(!burn_dam)
				to_chat(user, SPAN("warning", "\The [src] is used up."))
			else
				to_chat(user, SPAN("warning", "\The [src] is used up, but there's still a burn on [H]'s [affecting.name]!"))
			break

		if(!burn_dam)
			break

		if(!do_mob(user, H, 2 SECONDS))
			to_chat(user, SPAN("warning", "You must stand still to apply burn gel."))
			break

	user.visible_message(SPAN("notice", "\The [user] applies burn gel on [H]'s [affecting.name]."), \
						 SPAN("notice", "You apply burn gel on [H]'s [affecting.name]."))

	return -1

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	desc = "Modular splints capable of supporting and immobilizing bones in both limbs and appendages."
	icon_state = "splint"
	amount = 5
	max_amount = 5
	animal_heal = 0
	var/list/splintable_organs = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT)	//List of organs you can splint, natch.

/obj/item/stack/medical/splint/apply_on_human(mob/living/carbon/human/H, obj/item/organ/external/affecting, mob/user)
	. = ..()
	if(!.)
		return

	var/limb = affecting.name
	if(!(affecting.organ_tag in splintable_organs))
		to_chat(user, SPAN("warning", "You can't use \the [src] to apply a splint there!"))
		return
	if(affecting.splinted)
		to_chat(user, SPAN("notice", "[M]'s [limb] is already splinted!"))
		return
	if (M != user)
		user.visible_message(SPAN("notice", "[user] starts to apply \the [src] to [M]'s [limb]."), \
				                 SPAN("notice", "You start to apply \the [src] to [M]'s [limb]."), \
							    SPAN("warning", "You hear something being wrapped."))
	else
		if((user.active_hand == ACTIVE_HAND_RIGHT && (affecting.organ_tag in list(BP_R_ARM, BP_R_HAND)) || \
			user.active_hand == ACTIVE_HAND_LEFT && (affecting.organ_tag in list(BP_L_ARM, BP_L_HAND)) ))
			to_chat(user, SPAN("warning", "You can't apply a splint to the arm you're using!"))
			return
		user.visible_message(SPAN("notice", "[user] starts to apply \the [src] to their [limb]."), \
					             SPAN("notice", "You start to apply \the [src] to your [limb]."), \
					            SPAN("warning", "You hear something being wrapped."))
	if(do_after(user, 50, M, luck_check_type = LUCK_CHECK_MED))
		if(M == user && prob(75))
			user.visible_message(SPAN("warning", "\The [user] fumbles [src]."), \
						         SPAN("warning", "You fumble [src]."), \
						         SPAN("warning", "You hear something being wrapped."))
			return
		var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(user,1)
		if(S)
			if(affecting.apply_splint(S))
				S.forceMove(affecting)
				if (M != user)
					user.visible_message(SPAN("notice", "\The [user] finishes applying \the [src] to [M]'s [limb]."), \
						                           SPAN("notice", "You finish applying \the [src] to [M]'s [limb]."), \
						   	                      SPAN("warning", "You hear something being wrapped."))
				else
					user.visible_message(SPAN("notice", "\The [user] successfully applies \the [src] to their [limb]."), \
									               SPAN("notice", "You successfully apply \the [src] to your [limb]."), \
										          SPAN("warning", "You hear something being wrapped."))
				src.use(1)
				return
			S.dropInto(src.loc) //didn't get applied, so just drop it
		user.visible_message(SPAN("warning", "\The [user] fails to apply [src]."), \
						              SPAN("warning", "You fail to apply [src]."), \
						              SPAN("warning", "You hear something being wrapped."))

/obj/item/stack/medical/splint/ghetto
	name = "makeshift splints"
	singular_name = "makeshift splint"
	desc = "For holding your limbs in place with duct tape and scrap metal."
	icon_state = "tape-splint"
	amount = 1
	splintable_organs = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/obj/item/stack/medical/patches
	name = "pack of patches"
	singular_name = "patch"
	desc = "Name brand NanoTrasen patches. These can save you from various ouchies and boo boos."
	icon_state = "bandaid"
	item_state = "cigpacket"
	origin_tech = list(TECH_BIO = 1)
	amount = 6
	max_amount = 6
	heal_brute = 3
	animal_heal = 5
	stack_full = 1
	stack_empty = 1
	splittable = 0

/obj/item/stack/medical/patches/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting) //nullchecked by ..()

		if(affecting.is_bandaged())
			to_chat(user, SPAN("notice", "[M]'s [affecting.name] doesn't seem to be bleeding."))
			return 1
		else
			user.visible_message(SPAN("notice", "\The [user] starts placing bandaids on [M]'s [affecting.name]."), \
								 SPAN("notice", "You start placing bandaids on [M]'s [affecting.name]."))
			var/used = 0

			while(!affecting.is_bandaged() && used < get_amount())
				if(!do_mob(user, M, 1.5 SECONDS))
					to_chat(user, SPAN("warning", "You must stand still to place a bandaid."))
					break
				user.visible_message(SPAN("notice", "\The [user] places a bandaid on [M]'s [affecting.name]."), \
									 SPAN("notice", "You place a bandaid on [M]'s [affecting.name]."))
				affecting.bandage(20)
				used++

			affecting.update_damages()
			if(affecting.update_damstate())
				H.update_damage_overlays()
			if(used == get_amount())
				if(affecting.is_bandaged())
					to_chat(user, SPAN("warning", "\The [src] is used up."))
				else
					to_chat(user, SPAN("warning", "\The [src] is used up, but [M]'s [affecting.name] is still not completely covered."))
			use(used)
			H.update_bandages(1)

/obj/item/stack/medical/advanced/resurrection_serum
	name = "prototype serum injector"
	singular_name = "serum dose"
	desc = "A weird-looking injector with some sort of bloody-red serum inside."
	description_antag = "This more-expensive-than-your-life-is liquid, rumored to be made of mysterious vampire-like creatures, is capable brining dead to life."
	icon_state = "resurrect_serum"
	origin_tech = list(TECH_BIO = 10)
	amount = 1
	stack_empty = 1
	splittable = 0

/obj/item/stack/medical/advanced/resurrection_serum/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(!M.is_ic_dead())
		to_chat(user, SPAN("notice", "\The [src] quickly retracts its needles as you bring it close to [M]."))
		return

	to_chat(user, SPAN("notice", "You prepare to inject [M]..."))
	if(!do_after(user, 100, luck_check_type = LUCK_CHECK_MED))
		return

	if(!M.is_ic_dead())
		to_chat(user, SPAN("notice", "\The [src] quickly retracts its needles as soon as you try to inject [M]!"))
		return

	M.revive()
	to_chat(user, SPAN("notice", "You inject [M] with \the [src]. A moment later, their body twitches."))
	to_chat(M, SPAN("notice", "You hear a swarm of voices. They tell us.. They tell you to come back."))
	use(1)

/obj/item/stack/medical/advanced/resurrection_serum/ten
	name = "serum injector"
	desc = "A weird-looking injector with some sort of bloody-red serum inside. For some reason you feel like this thing is unbeliveably valuable."
	amount = 10
