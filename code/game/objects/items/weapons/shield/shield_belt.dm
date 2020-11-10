/obj/item/weapon/shield/shield_belt
	name = "shield belt"
	desc = "Protects user from bullets and lasers, but don't allow you to shoot"
	icon = 'icons/obj/clothing/belts.dmi' //to be changed
	icon_state = "utilitybelt"
	item_state = "utility"
	icon_state="utility"
	item_flags = ITEM_FLAG_IS_BELT
	slot_flags = SLOT_BELT
	attack_verb = "Bashed"
	var/obj/aura/shields/shield_belt/shield
	var/max_power = 3000
	var/current_power =3000
	var/obj/item/weapon/cell/bcell
	var/restored_power_per_tick = 5
/obj/item/weapon/shield/shield_belt/Destroy()
	QDEL_NULL(shield)
	if(!ispath(bcell))
		QDEL_NULL(bcell)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/shield/shield_belt/proc/turn_off()
	QDEL_NULL(shield)

/obj/item/weapon/shield/shield_belt/proc/turn_on(var/mob/user)
	shield = new(user,src)

/obj/item/weapon/shield/shield_belt/dropped(var/mob/user)
	turn_off()

/obj/item/weapon/shield/shield_belt/equipped(var/mov/user,var/slot)
	if(slot != slot_belt)
		turn_off()

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt
	icon_state = "utilitybelt"
	item_state = "utility"
	name = "syndicate shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot, looks suspicious"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6, TECH_ILLEGAL = 4)

/obj/item/weapon/shield/shield_belt/experimental_shield_belt
	icon_state = "utilitybelt"
	item_state = "utility"
	name = "experimental shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6)
	bcell = /obj/item/weapon/cell/high
/obj/item/weapon/shield/shield_belt/experimental_shield_belt/Initialize()
	. = ..()
	if(ispath(bcell))
		bcell = new bcell(src)
/obj/item/weapon/shield/shield_belt/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	if(slot == slot_belt_str && contents.len)
		for(var/obj/item/I in contents)
			ret.overlays += image("icon" = 'icons/mob/onmob/belt.dmi', "icon_state" = "[I.item_state ? I.item_state : I.icon_state]")
	return ret

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cell))
		if(!bcell && user.unEquip(W))
			W.forceMove(src)
			bcell = W
			to_chat(user, "<span class='notice'>You install a cell into the [src].</span>")
			//update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
	else if(isScrewdriver(W))
		if(bcell)
			bcell.update_icon()
			bcell.dropInto(loc)
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			turn_off()

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/examine(mob/user, distance)
	. = ..()
	to_chat(user, "The internal capacitor currently has [round(current_power/max_power * 100)]% charge.")

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/examine(mob/user, distance)
	. = ..()
	if(bcell)
		to_chat(user, "There is \a [bcell] in \the [src].")
		to_chat(user, "The internal capacitor currently has [round(bcell.charge/bcell.maxcharge * 100)]% charge.")
	else
		to_chat(user, "There is no cell in \the [src].")

/obj/item/weapon/shield/shield_belt/proc/toggle(var/mob/user)
	if(!shield)
		turn_on(user)
	else
		turn_off()
/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/AltClick(mob/living/user)
	if (loc == user)
		if (current_power > 300&&!shield)
			toggle(user)
		else if(shield)
			toggle(user)
		else
			to_chat(loc,"<span class='danger'>\The [src] has no energy!</span>")

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/AltClick(mob/living/user)
	if(bcell)
		if (bcell.charge > 300&&!shield)
			toggle(user)
		else if(shield)
			toggle(user)
		else
			to_chat(loc,"<span class='danger'>\The [src] has no energy!</span>")
	else
		to_chat(loc,SPAN_DANGER("\The [src] has no battery!"))

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/Process(wait)
	if(current_power >= max_power)
		return PROCESS_KILL
	current_power += min(restored_power_per_tick * wait, max_power - current_power)

/obj/item/weapon/shield/shield_belt/proc/take_charge(obj/item/projectile/P)
	START_PROCESSING(SSobj, src)
	if (istype(src, /obj/item/weapon/shield/shield_belt/syndicate_shield_belt))
		take_internal_charge(P)
	else
		take_cell_charge(P)

/obj/item/weapon/shield/shield_belt/proc/take_internal_charge(obj/item/projectile/P)
	current_power=current_power-P.damage*10
	if(current_power<0)
		current_power = 0
		to_chat(loc,"<span class='danger'>\The [src] begins to spark as it turns off!</span>")
		turn_off()

/obj/item/weapon/shield/shield_belt/proc/take_cell_charge(obj/item/projectile/P)
	if(bcell)
		if(bcell.checked_use(current_power-P.damage*10))
		else
			bcell.charge=0
			QDEL_NULL(shield)
			to_chat(loc,"<span class='danger'>\The [src] begins to spark as it turns off!</span>")
			turn_off()

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/emp_act(severity)
	current_power=max(current_power / (2 * severity), max_power/(4 * severity))
	turn_off()

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/emp_act(severity)
	if(bcell)
		bcell.emp_act(severity)	//let's not duplicate code everywhere if we don't have to please.
	..()
