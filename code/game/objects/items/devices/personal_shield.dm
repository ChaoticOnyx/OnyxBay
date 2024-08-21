/obj/item/device/personal_shield
	name = "personal shield"
	desc = "Truely a life-saver: this device protects its user from being hit by objects moving very, very fast, though only for a few shots."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	var/obj/aura/personal_shield/device/shield
	var/obj/item/cell/power_supply //What type of power cell this uses
	var/charge_cost = 20 //How much energy is needed to fire.
	var/max_shots = 5 //Determines the capacity of the weapon's power cell. Specifying a cell_type overrides this value.
	w_class = ITEM_SIZE_SMALL
	var/active = FALSE
	var/mob/living/holder = null
	item_flags = ITEM_FLAG_IS_BELT
	slot_flags = SLOT_BELT

/obj/item/device/personal_shield/Initialize()
	. = ..()
	power_supply = new /obj/item/cell/device/variable(src, max_shots*charge_cost)

/obj/item/device/personal_shield/proc/is_active(mob/living/user)
	var/act = FALSE
	for(var/obj/item/device/personal_shield/a in user.contents)
		if(a.active)
			act = TRUE
	return act

/obj/item/device/personal_shield/attack_self(mob/living/user)
	playsound(user, 'sound/effects/weapons/energy/toggle_mode1.ogg', 25, 1)
	spawn(5)
	if(power_supply.charge && !is_active(user))
		active = TRUE
		shield = new(user,src)
		holder = user
	else
		QDEL_NULL(shield)
		active = FALSE
		holder = null
		playsound(user,'sound/mecha/internaldmgalarm.ogg',25,1)

/obj/item/device/personal_shield/Move()
	..()
	if(holder && !(src in holder.contents))
		QDEL_NULL(shield)
		active = FALSE
		holder = null
	return

/obj/item/device/personal_shield/forceMove()
	..()
	if(holder && !(src in holder.contents))
		QDEL_NULL(shield)
		active = FALSE
		holder = null
	return

/obj/item/device/personal_shield/proc/take_charge(cost)
	if(!power_supply.use(cost) && cost)
		QDEL_NULL(shield)
		active = FALSE
		holder = null
		to_chat(loc,"<span class='danger'>\The [src] begins to spark!</span>")
		update_icon()
		return

/obj/item/device/personal_shield/on_update_icon()
	if(power_supply.charge)
		icon_state = "batterer"
	else
		icon_state = "battererburnt"

/obj/item/device/personal_shield/Destroy()
	QDEL_NULL(shield)
	QDEL_NULL(power_supply)
	return ..()
