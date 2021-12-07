////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/hypospray //obsolete, use hypospray/vial for the actual hypospray item
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

/obj/item/weapon/reagent_containers/hypospray/do_surgery(mob/living/carbon/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()
	attack(M, user)
	return 1

/obj/item/weapon/reagent_containers/hypospray/attack(mob/living/M as mob, mob/user as mob)
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

/obj/item/weapon/reagent_containers/hypospray/vial
	name = "hypospray"
	item_state = "autoinjector"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients. Uses a replacable 30u vial."
	var/obj/item/weapon/reagent_containers/glass/beaker/vial/loaded_vial
	volume = 0

/obj/item/weapon/reagent_containers/hypospray/vial/Initialize()
	. = ..()
	loaded_vial = new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	volume = loaded_vial.volume
	reagents.maximum_volume = loaded_vial.reagents.maximum_volume

/obj/item/weapon/reagent_containers/hypospray/vial/attack_hand(mob/user as mob)
	if(user.get_inactive_hand() == src)
		if(loaded_vial)
			reagents.trans_to_holder(loaded_vial.reagents,volume)
			reagents.maximum_volume = 0
			loaded_vial.update_icon()
			user.put_in_hands(loaded_vial)
			loaded_vial = null
			to_chat(user, "You remove the vial from the [src].")
			update_icon()
			playsound(src.loc, 'sound/weapons/flipblade.ogg', 50, 1)
			return
		..()
	else
		return ..()

/obj/item/weapon/reagent_containers/hypospray/vial/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/reagent_containers/glass/beaker/vial))
		if(!loaded_vial)
			if(!do_after(user,10) || loaded_vial || !(W in user))
				return 0
			if(W.is_open_container())
				W.atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
				W.update_icon()
			user.drop_item()
			W.forceMove(src)
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

/obj/item/weapon/reagent_containers/hypospray/autoinjector
	name = "autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	icon_state = "blue1"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 10
	volume = 10
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 2)
	atom_flags = null
	var/list/starts_with = list(/datum/reagent/inaprovaline = 10)
	var/content_desc = "Inaprovaline 10u. Use to stabilize an injured person."
	var/base_state = "blue"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/Initialize()
	. = ..()
	for(var/T in starts_with)
		reagents.add_reagent(T, starts_with[T])
	update_icon()
	if(content_desc)
		desc += " The label reads, \"[content_desc]\"."
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	..()
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "[base_state]1"
	else
		icon_state = "[base_state]0"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/examine(mob/user)
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += "\n<span class='notice'>It is currently loaded.</span>"
	else
		. += "\n<span class='notice'>It is spent.</span>"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/detox
	icon_state = "green1"
	content_desc = "Dylovene 10u. Use in case of poisoning."
	base_state = "green"
	starts_with = list(/datum/reagent/dylovene = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricordrazine
	icon_state = "red1"
	content_desc = "Tricordrazine 10u. Use to speed up recovery from physical trauma."
	base_state = "red"
	starts_with = list(/datum/reagent/tricordrazine = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/pain
	icon_state = "purple1"
	content_desc = "Tramadol 10u. Highly potent painkiller. Warning: Do Not Mix With Alcohol!"
	base_state = "purple"
	starts_with = list(/datum/reagent/tramadol = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/combatpain
	icon_state = "black1"
	content_desc = "Oxycodone 5u"
	base_state = "black"
	starts_with = list(/datum/reagent/tramadol/oxycodone = 5)
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/weapon/reagent_containers/hypospray/autoinjector/mindbreaker
	icon_state = "black1"
	content_desc = ""
	base_state = "black"
	starts_with = list(/datum/reagent/mindbreaker = 5)
	amount_per_transfer_from_this = 5
	volume = 5
