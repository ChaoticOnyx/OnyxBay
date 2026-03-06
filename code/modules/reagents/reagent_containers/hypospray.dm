////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray //obsolete, use hypospray/vial for the actual hypospray item
	name = "hypospray"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "hypo"
	origin_tech = list(TECH_MATERIAL = 4, TECH_BIO = 5)
	amount_per_transfer_from_this = 5
	unacidable = 1
	volume = 30
	possible_transfer_amounts = null
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	slot_flags = SLOT_BELT

	drop_sound = SFX_DROP_GUN
	pickup_sound = SFX_PICKUP_GUN

/obj/item/reagent_containers/hypospray/do_surgery(mob/living/carbon/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()
	attack(M, user)
	return 1

/obj/item/reagent_containers/hypospray/attack(mob/living/M as mob, mob/user as mob)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	if (!istype(M))
		return

	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			to_chat(user, "<span class='danger'>\The [H] is missing that limb!</span>")
			return
		else if(BP_IS_ROBOTIC(affected))
			to_chat(user, "<span class='danger'>You cannot inject a robotic limb.</span>")
			return

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.do_attack_animation(M)
	to_chat(user, "<span class='notice'>You inject [M] with [src].</span>")
	to_chat(M, "<span class='notice'>You feel a tiny prick!</span>")
	user.visible_message("<span class='warning'>[user] injects [M] with [src].</span>")

	if(M.reagents)
		var/contained = reagentlist()
		var/trans = reagents.trans_to_mob(M, amount_per_transfer_from_this, CHEM_BLOOD)
		admin_inject_log(user, M, src, contained, trans)
		to_chat(user, "<span class='notice'>[trans] ml injected. [reagents.total_volume] ml remaining in \the [src].</span>")

	return

/obj/item/reagent_containers/hypospray/vial
	name = "hypospray"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients. Uses a replaceable 50 ml vial."
	var/obj/item/reagent_containers/vessel/beaker/vial/loaded_vial
	volume = 0

/obj/item/reagent_containers/hypospray/vial/Initialize()
	. = ..()
	loaded_vial = new /obj/item/reagent_containers/vessel/beaker/vial(src)
	volume = loaded_vial.volume
	reagents.maximum_volume = loaded_vial.reagents.maximum_volume

/obj/item/reagent_containers/hypospray/vial/attack_hand(mob/user as mob)
	if(user.has_in_passive_hand(src))
		if(loaded_vial)
			reagents.trans_to_holder(loaded_vial.reagents,volume)
			reagents.maximum_volume = 0
			loaded_vial.update_icon()
			user.pick_or_drop(loaded_vial)
			loaded_vial = null
			to_chat(user, "You remove the vial from the [src].")
			update_icon()
			playsound(src.loc, 'sound/weapons/flipblade.ogg', 50, 1)
			return
		..()
	else
		return ..()

/obj/item/reagent_containers/hypospray/vial/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers/vessel/beaker/vial))
		if(!loaded_vial)
			if(!do_after(user, 10, , luck_check_type = LUCK_CHECK_MED) || loaded_vial || !(W in user))
				return FALSE
			if(!user.drop(W, src))
				return
			if(W.is_open_container())
				W.atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
				W.update_icon()
			loaded_vial = W
			reagents.maximum_volume = loaded_vial.reagents.maximum_volume
			loaded_vial.reagents.trans_to_holder(reagents,volume)
			user.visible_message("<span class='notice'>[user] has loaded [W] into \the [src].</span>","<span class='notice'>You load \the [W] into \the [src].</span>")
			update_icon()
			playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
		else
			to_chat(user,"<span class='notice'>\The [src] already has a vial.</span>")
	else
		..()

/obj/item/reagent_containers/hypospray/autoinjector
	name = "autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	icon_state = "injector_blue"
	amount_per_transfer_from_this = 15
	volume = 15
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 2)
	atom_flags = null
	startswith = list(/datum/reagent/inaprovaline)
	var/content_desc = "Inaprovaline 15ml. Use to stabilize an injured person."

/obj/item/reagent_containers/hypospray/autoinjector/Initialize()
	. = ..()
	update_icon()
	if(content_desc)
		desc += " The label reads, \"[content_desc]\"."
	return

/obj/item/reagent_containers/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	..()
	update_icon()
	return

/obj/item/reagent_containers/hypospray/autoinjector/on_update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-used"
	update_held_icon()

/obj/item/reagent_containers/hypospray/autoinjector/examine(mob/user, infix)
	. = ..()

	if(reagents && reagents.reagent_list.len)
		. += SPAN_NOTICE("It is currently loaded.")
	else
		. += SPAN_NOTICE("It is spent.")

/obj/item/reagent_containers/hypospray/autoinjector/detox
	icon_state = "injector_green"
	content_desc = "Dylovene 15ml. Use in case of poisoning."
	startswith = list(/datum/reagent/dylovene)

/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine
	icon_state = "injector_lightpurple"
	content_desc = "Tricordrazine 15ml. Use to speed up recovery from physical trauma."
	startswith = list(/datum/reagent/tricordrazine)

/obj/item/reagent_containers/hypospray/autoinjector/pain
	icon_state = "injector_purple"
	content_desc = "Tramadol 15ml. Highly potent painkiller. Warning: Do Not Mix With Alcohol!"
	startswith = list(/datum/reagent/painkiller/tramadol)

/obj/item/reagent_containers/hypospray/autoinjector/combatpain
	icon_state = "injector_black"
	content_desc = "Metazine 5ml. Used for immediate and temporary pain relief."
	amount_per_transfer_from_this = 5
	volume = 5
	startswith = list(/datum/reagent/painkiller)

/obj/item/reagent_containers/hypospray/autoinjector/mindbreaker
	icon_state = "injector_black"
	content_desc = ""
	amount_per_transfer_from_this = 5
	volume = 5
	startswith = list(/datum/reagent/mindbreaker)

/obj/item/reagent_containers/hypospray/autoinjector/antirad
	icon_state = "injector_orange"
	content_desc = "Hyronalin 15ml. Use in case of radiation poisoning."
	startswith = list(/datum/reagent/hyronalin)

/obj/item/reagent_containers/hypospray/autoinjector/antirad/mine
	name = "Radfi-X"
	desc = "A rapid way to administer a mix of radiation-purging drugs by untrained personnel. Severe radiation poisoning may require multiple doses."
	content_desc = "#1 brand among uranium miners across the galaxy!"
	icon_state = "injector_mine"
	startswith = list(
		/datum/reagent/arithrazine = 5,
		/datum/reagent/hyronalin = 5,
		/datum/reagent/dylovene = 5)

/obj/item/reagent_containers/hypospray/autoinjector/dexalinp
	icon_state = "injector_darkblue"
	content_desc = "Dexalin plus 15ml. Used for hypoxia. Increases oxygenation to almost 85%!"
	startswith = list(/datum/reagent/dexalinp)

/obj/item/reagent_containers/hypospray/autoinjector/bicaridine
	icon_state = "injector_red"
	content_desc = "Bicaridine 15ml. Used to treat serious physical wounds."
	startswith = list(/datum/reagent/bicaridine)

/obj/item/reagent_containers/hypospray/autoinjector/dermaline
	icon_state = "injector_yellow"
	content_desc = "Dermaline 15ml. Used to treat burn wounds."
	startswith = list(/datum/reagent/dermaline)

/obj/item/reagent_containers/hypospray/autoinjector/adrenaline
	icon_state = "injector_pink"
	content_desc = "Adrenaline 15ml. Used to treat cardiac arrest."
	startswith = list(/datum/reagent/adrenaline)
