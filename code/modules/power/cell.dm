// Power Cells
/obj/item/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = list(TECH_POWER = 1)
	force = 5.0
	throwforce = 5.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/c_uid			 // Unique ID
	var/charge			 // Current charge
	var/maxcharge = 1000 // Capacity in Wh
	var/overlay_state
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 50)

/obj/item/cell/New()
	if(isnull(charge))
		charge = maxcharge
	c_uid = sequential_id(/obj/item/cell)
	..()

/obj/item/cell/Initialize()
	. = ..()
	update_icon()

/obj/item/cell/drain_power(drain_check, surge, power = 0)
	if(drain_check)
		return 1

	if(charge <= 0)
		return 0

	var/cell_amt = power * CELLRATE

	return use(cell_amt) / CELLRATE

/obj/item/cell/proc/add_charge(amount)
	charge = between(0, charge + amount, maxcharge)

/obj/item/cell/update_icon()
	var/new_overlay_state = null
	if(percent() >= 95)
		new_overlay_state = "cell-o2"
	else if(charge >= 0.05)
		new_overlay_state = "cell-o1"

	if(new_overlay_state != overlay_state)
		overlay_state = new_overlay_state
		overlays.Cut()
		if(overlay_state)
			overlays += image('icons/obj/power.dmi', overlay_state)

/obj/item/cell/proc/percent()		// return % charge of cell
	return maxcharge && (100.0 * charge / maxcharge)

/obj/item/cell/proc/fully_charged()
	return charge == maxcharge

// checks if the power cell is able to provide the specified amount of charge
/obj/item/cell/proc/check_charge(amount)
	return charge >= amount

// use power from a cell, returns the amount actually used
/obj/item/cell/proc/use(amount)
	if(amount < 0) // I can not trust these fuckers to do this properly and actually check what they pass.
		crash_with("Cell ([src], [c_uid]) called use() with negative amount ([amount]).")
		return 0
	var/used = min(charge, amount)
	charge -= used
	update_icon()
	return used

// Checks if the specified amount can be provided. If it can, it removes the amount
// from the cell and returns 1. Otherwise does nothing and returns 0.
/obj/item/cell/proc/checked_use(amount)
	if(!check_charge(amount))
		return 0
	use(amount)
	return 1

/obj/item/cell/proc/give(amount)
	if(amount < 0) // I can not trust these fuckers to do this properly and actually check what they pass.
		crash_with("Power cell ([src], [c_uid]) called give() with negative amount ([amount]).")
		return 0
	if(maxcharge == charge)
		return 0
	var/amount_used = min(maxcharge - charge,amount)
	charge += amount_used
	update_icon()
	return amount_used

/obj/item/cell/_examine_text(mob/user)
	. = ..()
	. += "\nThe label states it's capacity is [maxcharge] Wh"
	. += "\nThe charge meter reads [round(src.percent(), 0.1)]%"

/obj/item/cell/emp_act(severity)
	//remove this once emp changes on dev are merged in
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		severity *= R.cell_emp_mult

	// Lose 1/2, 1/4, 1/6 of the current charge per hit or 1/4, 1/8, 1/12 of the max charge per hit, whichever is highest
	use(max((charge / (2 * severity)), (maxcharge/(4 * severity))))
	..()


/obj/item/cell/proc/get_electrocute_damage()
	switch(charge)
		if(5000000 to INFINITY) //Ave cells
			return min(rand(300, 650),rand(300, 650))
		if(3000000 to 5000000-1)
			return min(rand(130, 320),rand(130, 320))
		if(1000000 to 3000000-1)
			return min(rand(50, 160),rand(50, 160))
		if(200000 to 1000000-1)
			return min(rand(25, 80),rand(25, 80))
		if(100000 to 200000-1)
			return min(rand(20, 60),rand(20, 60))
		if(50000 to 100000-1)
			return min(rand(15, 40),rand(15, 40))
		if(1000 to 50000-1)
			return min(rand(10, 20),rand(10, 20))
		else
			return 0


// SUBTYPES BELOW

/obj/item/cell/empty
	charge = 0

// Smaller variant, used by energy guns and similar small devices.
/obj/item/cell/device
	name = "device power cell"
	desc = "A small power cell designed to power handheld devices."
	icon_state = "device"
	w_class = ITEM_SIZE_SMALL
	force = 0
	throw_range = 7
	maxcharge = 100
	matter = list(MATERIAL_STEEL = 70, MATERIAL_GLASS = 5)

/obj/item/cell/device/variable/New(newloc, charge_amount)
	maxcharge = charge_amount
	..(newloc)

/obj/item/cell/device/standard
	name = "standard device power cell"
	maxcharge = 25

/obj/item/cell/device/high
	name = "advanced device power cell"
	desc = "A small power cell designed to power more energy-demanding devices."
	icon_state = "hdevice"
	maxcharge = 100
	matter = list(MATERIAL_STEEL = 70, MATERIAL_GLASS = 6)

/obj/item/cell/crap
	name = "old power cell"
	desc = "A cheap old power cell. It's probably been in use for quite some time now."
	origin_tech = list(TECH_POWER = 0)
	maxcharge = 100
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 40)

/obj/item/cell/crap/empty
	charge = 0

/obj/item/cell/standard
	name = "standard power cell"
	desc = "A standard and relatively cheap power cell, commonly used."
	origin_tech = list(TECH_POWER = 0)
	maxcharge = 250
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 40)

/obj/item/cell/standard/empty
	charge = 0

/obj/item/cell/apc
	name = "APC power cell"
	desc = "A special power cell designed for heavy-duty use in area power controllers."
	origin_tech = list(TECH_POWER = 1)
	maxcharge = 500
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 50)


/obj/item/cell/high
	name = "advanced power cell"
	desc = "An advanced high-grade power cell, for use in important systems."
	origin_tech = list(TECH_POWER = 2)
	icon_state = "hcell"
	maxcharge = 1000
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 60)

/obj/item/cell/high/empty
	charge = 0


/obj/item/cell/mecha
	name = "exosuit power cell"
	desc = "A special power cell designed for heavy-duty use in industrial exosuits."
	origin_tech = list(TECH_POWER = 3)
	icon_state = "hcell"
	maxcharge = 1500
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 70)


/obj/item/cell/super
	name = "enhanced power cell"
	desc = "A very advanced power cell with increased energy density, for use in critical applications."
	origin_tech = list(TECH_POWER = 5)
	icon_state = "scell"
	maxcharge = 2000
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 70)

/obj/item/cell/super/empty
	charge = 0


/obj/item/cell/hyper
	name = "superior power cell"
	desc = "This very expensive power cell provides the best energy density reachable with conventional electrochemical cells."
	origin_tech = list(TECH_POWER = 6)
	icon_state = "hpcell"
	maxcharge = 3000
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 80)

/obj/item/cell/hyper/empty
	charge = 0


/obj/item/cell/apex
	name = "apex power cell"
	desc = "Pinnacle of power storage technology, this extremely expensive power cell uses compact superconductors to provide nearly fantastic energy density."
	origin_tech = list(TECH_POWER = 7, TECH_MATERIAL = 7, TECH_MAGNET = 5, TECH_ENGINEERING = 5)
	icon_state = "acell"
	maxcharge = 5000
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 90)

/obj/item/cell/apex/empty
	charge = 0


/obj/item/cell/infinite
	name = "experimental power cell"
	desc = "This special experimental power cell has both very large capacity, and ability to recharge itself by draining power from contained bluespace pocket."
	icon_state = "icell"
	origin_tech =  null
	maxcharge = 3000
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 80)

/obj/item/cell/infinite/check_charge()
	return 1

/obj/item/cell/infinite/use()
	return 1


/obj/item/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = list(TECH_POWER = 1)
	icon = 'icons/obj/power.dmi'
	icon_state = "potatocell"
	maxcharge = 50


/obj/item/cell/metroid
	name = "charged metroid core"
	desc = "A yellow metroid core infused with plasma, it crackles with power."
	origin_tech = list(TECH_POWER = 2, TECH_BIO = 4)
	icon = 'icons/mob/metroids.dmi' //'icons/obj/harvest.dmi'
	icon_state = "yellow metroid extract" //"potato_battery"
	maxcharge = 200
	matter = null


/obj/item/cell/quantum
	name = "bluespace cell"
	desc = "This special experimental power cell utilizes bluespace manipulation techniques; it can form a recursive quantum connection with another cell of its kind, making them share their charge through virtually any distance."
	icon_state = "qcell"
	origin_tech = list(TECH_POWER = 6, TECH_MATERIAL = 6, TECH_BLUESPACE = 3, TECH_MAGNET = 5)
	var/obj/item/cell/quantum/partner = null
	maxcharge = 3000
	var/quantum_id = 0

/obj/item/cell/quantum/Initialize()
	. = ..()
	quantum_id = rand(10000, 99999)

/obj/item/cell/quantum/update_icon()
	var/new_overlay_state = null
	if(percent() >= 95)
		new_overlay_state = "qcell-o2"
	else if(charge >= 0.05)
		new_overlay_state = "qcell-o1"

	if(new_overlay_state != overlay_state)
		overlay_state = new_overlay_state
		overlays.Cut()
		if(overlay_state)
			overlays += image('icons/obj/power.dmi', overlay_state)

/obj/item/cell/quantum/_examine_text(mob/user)
	. = ..()
	. += "\nIts quantum ID is: #[quantum_id]"
	if(partner)
		. += "\nIt is recursively bound with the bluespace cell #[partner.quantum_id]"

/obj/item/cell/quantum/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/cell/quantum))
		var/obj/item/cell/quantum/Q = W
		if(W == partner)
			Q.quantum_unbind()
			quantum_unbind()
			to_chat(user, SPAN("notice", "\The [Q] (#[Q.quantum_id]) is no longer bound with \the [src] (#[quantum_id])."))
			return
		else
			if(partner)
				to_chat(user, SPAN("warning", "\The [src] (#[quantum_id]) is already bound with \the [partner] (#[partner.quantum_id])!"))
				return
			else if(Q.partner)
				to_chat(user, SPAN("warning", "\The [Q] (#[Q.quantum_id]) is already bound with \the [Q.partner] (#[Q.partner.quantum_id])!"))
				return
			quantum_bind(Q)
			to_chat(user, SPAN("notice", "\The [Q] (#[Q.quantum_id]) is now bound with \the [src] (#[src.quantum_id])."))
			return
	else
		..()

/obj/item/cell/quantum/add_charge(amount)
	. = ..()
	sync_charge()

/obj/item/cell/quantum/use(amount)
	. = ..()
	sync_charge()

/obj/item/cell/quantum/give(amount)
	. = ..()
	sync_charge()

/obj/item/cell/quantum/Destroy()
	if(partner)
		partner.quantum_unbind(TRUE)
	partner = null
	return ..()

/obj/item/cell/quantum/proc/sync_charge()
	if(!partner)
		return
	partner.charge = charge
	partner.update_icon()

/obj/item/cell/quantum/proc/quantum_bind(obj/item/cell/quantum/Q)
	partner = Q
	Q.partner = src
	var/average_charge = (charge + Q.charge) / 2
	charge = average_charge
	Q.charge = average_charge
	update_icon()
	Q.update_icon()

/obj/item/cell/quantum/proc/quantum_unbind(forced = FALSE)
	if(!partner)
		return
	partner = null
	if(charge)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, get_turf(src))
		s.start()
		if(forced)
			visible_message(SPAN("warning", "All of a sudden, \the [src] quickly discharges!")) // No need to show this if a cell gets manually unbound
	charge = 0
	update_icon()
