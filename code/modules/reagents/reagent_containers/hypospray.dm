////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray //obsolete, use hypospray/vial for the actual hypospray item
	name = "hypospray"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
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
		to_chat(user, "<span class='notice'>[trans] units injected. [reagents.total_volume] units remaining in \the [src].</span>")

	return

/obj/item/reagent_containers/hypospray/vial
	name = "hypospray"
	item_state = "autoinjector"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients. Uses a replacable 30u vial."
	var/obj/item/reagent_containers/vessel/beaker/vial/loaded_vial
	volume = 0

/obj/item/reagent_containers/hypospray/vial/Initialize()
	. = ..()
	loaded_vial = new /obj/item/reagent_containers/vessel/beaker/vial(src)
	volume = loaded_vial.volume
	reagents.maximum_volume = loaded_vial.reagents.maximum_volume

/obj/item/reagent_containers/hypospray/vial/attack_hand(mob/user as mob)
	if(user.get_inactive_hand() == src)
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
	icon_state = "blue1"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 10
	volume = 10
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 2)
	atom_flags = null
	startswith = list(/datum/reagent/inaprovaline)
	var/content_desc = "Inaprovaline 10u. Use to stabilize an injured person."
	var/base_state = "blue"

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
		icon_state = "[base_state]1"
	else
		icon_state = "[base_state]0"

/obj/item/reagent_containers/hypospray/autoinjector/examine(mob/user, infix)
	. = ..()

	if(reagents && reagents.reagent_list.len)
		. += SPAN_NOTICE("It is currently loaded.")
	else
		. += SPAN_NOTICE("It is spent.")

/obj/item/reagent_containers/hypospray/autoinjector/detox
	icon_state = "green1"
	content_desc = "Dylovene 10u. Use in case of poisoning."
	base_state = "green"
	startswith = list(/datum/reagent/dylovene)

/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine
	icon_state = "lightpurple1"
	content_desc = "Tricordrazine 10u. Use to speed up recovery from physical trauma."
	base_state = "lightpurple"
	startswith = list(/datum/reagent/tricordrazine)

/obj/item/reagent_containers/hypospray/autoinjector/pain
	icon_state = "purple1"
	content_desc = "Tramadol 10u. Highly potent painkiller. Warning: Do Not Mix With Alcohol!"
	base_state = "purple"
	startswith = list(/datum/reagent/painkiller/tramadol)

/obj/item/reagent_containers/hypospray/autoinjector/combatpain
	icon_state = "black1"
	content_desc = "Metazine 5u. Used for immediate and temporary pain relief."
	base_state = "black"
	amount_per_transfer_from_this = 5
	volume = 5
	startswith = list(/datum/reagent/painkiller)

/obj/item/reagent_containers/hypospray/autoinjector/mindbreaker
	icon_state = "black1"
	content_desc = ""
	base_state = "black"
	amount_per_transfer_from_this = 5
	volume = 5
	startswith = list(/datum/reagent/mindbreaker)

/obj/item/reagent_containers/hypospray/autoinjector/antirad
	icon_state = "orange1"
	content_desc = "Hyronalin 10u. Use in case of radiation poisoning."
	base_state = "orange"
	startswith = list(/datum/reagent/hyronalin)

/obj/item/reagent_containers/hypospray/autoinjector/antirad/mine
	name = "Radfi-X"
	desc = "A rapid way to administer a mix of radiation-purging drugs by untrained personnel. Severe radiation poisoning may require multiple doses."
	content_desc = "#1 brand among uranium miners across the galaxy!"
	icon_state = "mine1"
	base_state = "mine"
	startswith = list(
		/datum/reagent/hyronalin = 5,
		/datum/reagent/dylovene = 5)

/obj/item/reagent_containers/hypospray/autoinjector/dexalinp
	icon_state = "darkblue1"
	content_desc = "Dexalin plus 10u. Used for hypoxia. Increases oxygenation to almost 85%!"
	base_state = "darkblue"
	startswith = list(/datum/reagent/dexalinp)

/obj/item/reagent_containers/hypospray/autoinjector/bicaridine
	icon_state = "red1"
	content_desc = "Bicaridine 10u. Used to treat serious physical wounds."
	base_state = "red"
	startswith = list(/datum/reagent/bicaridine)

/obj/item/reagent_containers/hypospray/autoinjector/dermaline
	icon_state = "yellow1"
	content_desc = "Dermaline 10u. Used to treat burn wounds."
	base_state = "yellow"
	startswith = list(/datum/reagent/dermaline)
