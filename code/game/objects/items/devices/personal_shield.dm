/obj/item/device/personal_shield
	name = "personal shield"
	desc = "Truely a life-saver: this device protects its user from being hit by objects moving very, very fast, though only for a few shots."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	var/obj/aura/personal_shield/device/shield
	var/obj/item/cell/power_supply //What type of power cell this uses
	var/charge_cost = 20 //How much energy is needed to fire.
	var/max_shots = 7 //Determines the capacity of the weapon's power cell. Specifying a cell_type overrides this value.
	w_class = ITEM_SIZE_SMALL
	var/active = FALSE
	var/mob/living/holder = null
	item_flags = ITEM_FLAG_IS_BELT
	slot_flags = SLOT_BELT

/obj/item/device/personal_shield/Initialize()
	. = ..()
	power_supply = new /obj/item/cell/device/variable(src, max_shots*charge_cost)

/obj/item/device/personal_shield/attack_self(mob/living/user)
	if(power_supply.charge && !active)
		active = TRUE
		shield = new(user,src)
		holder = user
	else
		QDEL_NULL(shield)
		active = FALSE
		holder = null

/obj/item/device/personal_shield/Move()
	..()
	if(holder && get_turf(holder) != get_turf(src))
		QDEL_NULL(shield)
		active = FALSE
		holder = null
	return

/obj/item/device/personal_shield/forceMove()
	..()
	if(holder && get_turf(holder) != get_turf(src))
		QDEL_NULL(shield)
		active = FALSE
		holder = null
	return

/obj/item/device/personal_shield/proc/take_charge(cost)
	if(!power_supply.checked_use(cost))
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
