
/obj/item/weapon/backwear/reagent/pepper
	name = "crowdbuster kit"
	desc = "A heavy backpack made of two pepper tanks and a retractable pepperspray nozzle, manufactured by Uhang Inc. Your best choice for killing them asthmatics!"
	icon_state = "pepper1"
	base_icon = "pepper"
	item_state = "backwear_pepper"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster
	atom_flags = null
	initial_capacity = 300
	initial_reagent_types = list(/datum/reagent/capsaicin/condensed = 1)
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/weapon/backwear/reagent/pepper/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/structure/reagent_dispensers/peppertank))
		var/amount = min((initial_capacity - reagents.total_volume), O.reagents.total_volume)
		if(!O.reagents.total_volume)
			to_chat(user, SPAN("warning", "\The [O] is empty."))
			return
		if(!amount)
			to_chat(user, SPAN("notice", "\The [src] is already full."))
			return
		O.reagents.trans_to_obj(src, amount)
		to_chat(user, SPAN("notice", "You crack the cap off the top of your [src] and fill it with [amount] units of the contents of \the [O]."))
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return

/obj/item/weapon/backwear/reagent/pepper/resolve_grab_gear(mob/living/carbon/human/user)
	. = ..()
	if(. && gear)
		var/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/C = gear
		C.external_container = src // Sadly it's safer and easier to do it this way since New/Initialize sequences are a shitmaze

/obj/item/weapon/backwear/reagent/standard_dispenser_refill(mob/user, obj/structure/reagent_dispensers/target)
	return 0

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster
	name = "crowdbuster"
	desc = "It fires a large cloud of condensed capsaicin to blind and down an opponent quickly."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "crowdbuster0"
	item_state = "crowdbuster"
	possible_transfer_amounts = null
	volume = 0
	amount_per_transfer_from_this = 10
	step_delay = 1
	atom_flags = null
	slot_flags = null
	canremove = 0
	unacidable = 1 //TODO: make these replaceable so we won't need such ducttaping
	matter = null
	var/obj/item/weapon/backwear/reagent/base_unit

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/New(newloc, obj/item/weapon/backwear/base)
	base_unit = base
	src.verbs -= /obj/item/weapon/reagent_containers/spray/verb/empty
	..(newloc)

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/attack_self(mob/user)
	widespray = !widespray
	if(widespray)
		to_chat(user, "\The [src]'s nozzle is now set to wide spraying mode.")
		icon_state = "crowdbuster1"
	else
		to_chat(user, "\The [src]'s nozzle is now set to narrow spraying mode.")
		icon_state = "crowdbuster0"
