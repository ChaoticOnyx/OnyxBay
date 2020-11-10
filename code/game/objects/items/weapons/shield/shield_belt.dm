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

	var/active = 0
/obj/item/weapon/shield/shield_belt/syndicate_shield_belt
	icon_state = "utilitybelt"
	item_state = "utility"
	name = "syndicate shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot, looks suspicious"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6, TECH_ILLEGAL = 4)
	var/max_power = 3000
	var/current_power =3000
/obj/item/weapon/shield/shield_belt/experimental_shield_belt
	icon_state = "utilitybelt"
	item_state = "utility"
	name = "experimental shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6)
	max_power = 0
	current_power = 0
	/obj/item/weapon/cell/bcell
/obj/item/weapon/shield/shield_belt/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	if(slot == slot_belt_str && contents.len)
		for(var/obj/item/I in contents)
			ret.overlays += image("icon" = 'icons/mob/onmob/belt.dmi', "icon_state" = "[I.item_state ? I.item_state : I.icon_state]")
	return ret
/obj/item/weapon/shield/shield_belt/experimental_shield_belt
	if(istype(W, /obj/item/weapon/cell/device))
		if(!bcell && user.unEquip(W))
			W.forceMove(src)
			bcell = W
			to_chat(user, "<span class='notice'>You install a cell into the [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
	else if(isScrewdriver(W))
		if(bcell)
			bcell.update_icon()
			bcell.dropInto(loc)
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			status = 0
			update_icon()
	else
		..()
/obj/item/weapon/melee/baton/robot/examine_cell(mob/user, prefix)
	. += "\n<span class='notice'>The shield belt is running off an external power supply.</span>"
/obj/item/weapon/shield/shield_belt/attack_self(mob/living/user)
	if (current_power!=0)
		if(!active )
			active=1
			shield = new(user,src)
		else
			active=0
			QDEL_NULL(shield)
	else
		to_chat(loc,"<span class='danger'>\The [src] has no energy!</span>")
/obj/item/weapon/shield/shield_belt/Move()
	QDEL_NULL(shield)
	return ..()

/obj/item/weapon/shield/shield_belt/proc/take_charge(obj/item/projectile/P)
	current_power=current_power-P.damage*10
	if(current_power<0)
		current_power = 0
		QDEL_NULL(shield)
		to_chat(loc,"<span class='danger'>\The [src] begins to spark as it turns off!</span>")
/obj/item/weapon/shield/shield_belt/emp_act(severity)
	current_power=0
	active=0
	QDEL_NULL(shield)