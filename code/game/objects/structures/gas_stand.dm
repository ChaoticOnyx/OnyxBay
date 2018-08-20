/obj/structure/gas_stand
	name = "gas stand"
	icon = 'icons/obj/gas_stand.dmi'
	desc = "Gas stand with retractable gas mask."
	icon_state = "gas_stand_idle"

	var/obj/item/weapon/tank/tank
	var/mob/living/carbon/breather
	var/obj/item/clothing/mask/breath/contained

	var/spawn_type = null
	var/mask_type = /obj/item/clothing/mask/breath/anesthetic

	var/is_loosen = TRUE
	var/valve_opened = FALSE

/obj/structure/gas_stand/New()
	..()
	if (spawn_type)
		tank = new spawn_type (src)
	contained = new mask_type (src)
	update_icon()

/obj/structure/gas_stand/update_icon()
	if (breather)
		icon_state = "gas_stand_inuse"
	else
		icon_state = "gas_stand_idle"

	overlays.Cut()

	if (tank)
		if(istype(tank,/obj/item/weapon/tank/anesthetic))
			overlays += "tank_anest"
		else if(istype(tank,/obj/item/weapon/tank/nitrogen))
			overlays += "tank_nitro"
		else if(istype(tank,/obj/item/weapon/tank/oxygen))
			overlays += "tank_oxyg"
		else if(istype(tank,/obj/item/weapon/tank/phoron))
			overlays += "tank_phoron"
		else if(istype(tank,/obj/item/weapon/tank/hydrogen))
			overlays += "tank_hydro"
		else
			overlays += "tank_other"

/obj/structure/gas_stand/Destroy()
	STOP_PROCESSING(SSobj,src)
	if(breather)
		breather.internal = null
		if(breather.internals)
			breather.internals.icon_state = "internal0"
	if(tank)
		qdel(tank)
	if(breather)
		breather.remove_from_mob(contained)
		src.visible_message("<span class='notice'>The mask rapidly retracts just before /the [src] is destroyed!</span>")
	qdel(contained)
	contained = null
	breather = null
	return ..()

/obj/structure/gas_stand/attack_robot(var/mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/gas_stand/MouseDrop(var/mob/living/carbon/human/target, src_location, over_location)
	..()
	if(istype(target) && CanMouseDrop(target))
		if(!can_apply_to_target(target, usr)) // There is no point in attempting to apply a mask if it's impossible.
			return
		usr.visible_message("\The [usr] begins placing the mask onto [target]..")
		if(!do_mob(usr, target, 25) || !can_apply_to_target(target, usr))
			return
		// place mask and add fingerprints
		usr.visible_message("\The [usr] has placed \the mask on [target]'s mouth.")
		attach_mask(target)
		src.add_fingerprint(usr)
		update_icon()
		START_PROCESSING(SSobj,src)

/obj/structure/gas_stand/attack_hand(mob/user as mob)
	if (tank && is_loosen)
		user.visible_message("<span class='notice'>\The [user] removes \the [tank] from \the [src].</span>", "<span class='notice'>You remove \the [tank] from \the [src].</span>")
		user.put_in_hands(tank)
		src.add_fingerprint(user)
		tank.add_fingerprint(user)
		tank = null
		update_icon()
		return
	if (!tank)
		to_chat(user, "<span class='warning'>There is no tank in \the [src]!</span>")
		return
	else
		if (valve_opened)
			src.visible_message("<span class='notice'>\The [user] closes valve on \the [src]!</span>")
			if(breather)
				if(breather.internals)
					breather.internals.icon_state = "internal0"
				breather.internal = null
			valve_opened = FALSE
			update_icon()
		else
			src.visible_message("<span class='notice'>\The [user] opens valve on \the [src]!</span>")
			if(breather)
				breather.internal = tank
				if(breather.internals)
					breather.internals.icon_state = "internal1"
			valve_opened = TRUE	
			playsound(get_turf(src), 'sound/effects/internals.ogg', 100, 1)
			update_icon()
			START_PROCESSING(SSobj,src)

/obj/structure/gas_stand/proc/attach_mask(var/mob/living/carbon/C)
	if(C && istype(C))
		contained.forceMove(get_turf(C))
		C.equip_to_slot(contained, slot_wear_mask)
		if(tank)
			tank.forceMove(C)
		breather = C

/obj/structure/gas_stand/proc/can_apply_to_target(var/mob/living/carbon/human/target, mob/user as mob)
	if(!user)
		user = target
	// Check target validity
	if(!target.organs_by_name[BP_HEAD])
		to_chat(user, "<span class='warning'>\The [target] doesn't have a head.</span>")
		return
	if(!target.check_has_mouth())
		to_chat(user, "<span class='warning'>\The [target] doesn't have a mouth.</span>")
		return
	if(target.wear_mask && target != breather)
		to_chat(user, "<span class='warning'>\The [target] is already wearing a mask.</span>")
		return
	if(target.head && (target.head.body_parts_covered & FACE))
		to_chat(user, "<span class='warning'>Remove their [target.head] first.</span>")
		return
	if(!tank)
		to_chat(user, "<span class='warning'>There is no tank in \the [src].</span>")
		return
	if(is_loosen)
		to_chat(user, "<span class='warning'>Tighten \the nut with a wrench first.</span>")
		return
	if(!Adjacent(target))
		return
	//when there is a breather:
	if(breather && target != breather)
		to_chat(user, "<span class='warning'>\The [src] is already in use.</span>")
		return
	//Checking if breather is still valid
	if(target == breather && target.wear_mask != contained)
		to_chat(user, "<span class='warning'>\The [target] is not using the supplied mask.</span>")
		return
	return 1

/obj/structure/gas_stand/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isWrench(W))
		if (valve_opened)
			to_chat(user, "<span class='warning'>Close the valve first.</span>")
			return
		if (tank)
			if (!is_loosen)
				is_loosen = TRUE
			else
				is_loosen = FALSE
				if (valve_opened)
					START_PROCESSING(SSobj,src)
			user.visible_message("<span class='notice'>\The [user] [is_loosen == TRUE ? "loosen" : "tighten"] \the nut holding [tank] in place.</span>", "<span class='notice'>You [is_loosen == TRUE ? "loosen" : "tighten"] \the nut holding [tank] in place.</span>")
			return
		else
			to_chat(user, "<span class='warning'>There is no tank in \the [src].</span>")
			return

	if(istype(W, /obj/item/weapon/tank))
		if(tank)
			to_chat(user, "<span class='warning'>\The [src] already has a tank installed!</span>")
		else if(!is_loosen)
			to_chat(user, "<span class='warning'>Loosen the nut with a wrench first.</span>")
		else
			user.drop_item()
			W.forceMove(src)
			tank = W
			user.visible_message("<span class='notice'>\The [user] attaches \the [tank] to \the [src].</span>", "<span class='notice'>You attach \the [tank] to \the [src].</span>")
			src.add_fingerprint(user)
			update_icon()

/obj/structure/gas_stand/examine(var/mob/user)
	. = ..()
	if(tank)
		if (!is_loosen)
			to_chat(user, "\The [tank] connected to it.")
		to_chat(user, "The meter shows [round(tank.air_contents.return_pressure())]. The valve is [valve_opened == TRUE ? "open" : "closed"].")
		if (tank.distribute_pressure == 0)
			to_chat(user, "Use wrench to replace tank.")
	else
		to_chat(user, "<span class='warning'>It is missing a tank!</span>")

/obj/structure/gas_stand/Process()
	if(breather)
		if(!can_apply_to_target(breather))
			if(tank)
				tank.forceMove(src)
			if (breather.wear_mask==contained)
				breather.remove_from_mob(contained)
				contained.forceMove(src)
			else
				qdel(contained)
				contained=new mask_type (src)
			src.visible_message("<span class='notice'>\The [contained] slips to \the [src]!</span>")
			breather = null
			update_icon()
			return
		if(valve_opened)
			if (tank)
				breather.internal = tank
				if(breather.internals)
					breather.internals.icon_state = "internal1"
		else
			if(breather.internals)
				breather.internals.icon_state = "internal0"
			breather.internal = null
	else if (valve_opened)
		var/datum/gas_mixture/removed = tank.remove_air(0.01)
		var/datum/gas_mixture/environment = loc.return_air()
		environment.merge(removed)
		if (tank.distribute_pressure == 0 && !breather)
			return PROCESS_KILL
	else
		return PROCESS_KILL

/obj/structure/gas_stand/anesthetic
	icon_state = "gas_stand_idle"
	name = "anaesthetic machine"
	desc = "Anaesthetic machine used to support the administration of anaesthesia ."
	spawn_type = /obj/item/weapon/tank/anesthetic
	mask_type = /obj/item/clothing/mask/breath/anesthetic
	is_loosen = FALSE

