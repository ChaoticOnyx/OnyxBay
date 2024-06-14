/obj/item/fighter_component/battery
	name = "fighter battery"
	icon_state = "battery"
	slot = HARDPOINT_SLOT_BATTERY
	active = FALSE
	var/charge = 10000
	var/maxcharge = 10000
	var/self_charge = FALSE //TODO! Engine powers this.

/obj/item/fighter_component/battery/think()
	if(self_charge)
		give(1000)

/obj/item/fighter_component/battery/proc/give(amount)
	if(charge >= maxcharge)
		return FALSE

	charge += amount
	charge = Clamp(charge, 0, maxcharge)

/obj/item/fighter_component/battery/proc/use_power(amount)
	if(!active)
		return FALSE

	charge -= amount
	charge = Clamp(charge, 0, maxcharge)
	if(charge <= 0)
		var/obj/structure/overmap/small_craft/F = loc
		if(!istype(F))
			return FALSE

		if(active)
			F.set_master_caution(TRUE)
			active = FALSE
	return charge > 0
