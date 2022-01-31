/obj/item/gun/energy/gun
	name = "tactical taser"
	desc = "Crafted in underground factories of Redknight & Company Dominance Tech, the TEG02 Mjolnir is a versatile energy based sidearm, capable of switching between low, medium and high power projectile settings. In other words: stun, shock or kill."
	icon_state = "tasertacticalstun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	max_shots = 10
	fire_delay = 10 // To balance for the fact that it is a pistol and can be used one-handed without penalty

	projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	modifystate = "tasertacticalstun"
	combustion = FALSE

	firemodes = list(
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode/stunsphere, modifystate = "tasertacticalstun"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam,                        modifystate = "tasertacticalkill")
		)

/obj/item/gun/energy/secure/gun
	name = "tactical taser"
	desc = "A more secure modification of TEG02, the TEG02-S is designed to please paranoid constituents. Body cam not included."
	icon_state = "tasertacticalstun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	max_shots = 10
	fire_delay = 10 // To balance for the fact that it is a pistol and can be used one-handed without penalty

	projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	modifystate = "tasertacticalstun"
	authorized_modes = list(ALWAYS_AUTHORIZED, AUTHORIZED)

	firemodes = list(
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode/stunsphere, modifystate = "tasertacticalstun"),
		list(mode_name = "shock",  projectile_type = /obj/item/projectile/beam/stun/shock,             modifystate = "tasertacticalshock"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam,                        modifystate = "tasertacticalkill")
		)

/obj/item/gun/energy/gun/small
	name = "small energy gun"
	desc = "A smaller model of the versatile LAEP90 Perun, the LAEP90-C packs considerable utility in a smaller package. Best used in situations where full-sized sidearms are inappropriate."
	icon_state = "smallgunstun"
	max_shots = 5
	w_class = ITEM_SIZE_SMALL
	force = 2 //it's the size of a car key, what did you expect?
	projectile_type = /obj/item/projectile/energy/electrode
	modifystate = "smallgunstun"

	firemodes = list(
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode,  modifystate = "smallgunstun"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam/smalllaser,   modifystate = "smallgunkill")
		)

/obj/item/gun/energy/secure/gun/small
	name = "small energy gun"
	desc = "Combining the two LAEP90 variants, the secure and compact LAEP90-CS is the next best thing to keeping your security forces on a literal leash."
	icon_state = "smallgunstun"
	max_shots = 5
	w_class = ITEM_SIZE_SMALL
	force = 2
	projectile_type = /obj/item/projectile/energy/electrode
	modifystate = "smallgunstun"

	firemodes = list(
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode, modifystate = "smallgunstun"),
		list(mode_name = "shock",  projectile_type = /obj/item/projectile/beam/stun/shock,  modifystate = "tasertacticalshock"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam/smalllaser,  modifystate = "smallgunkill")
		)

/obj/item/gun/energy/gun/mounted
	name = "mounted energy gun"
	self_recharge = 1
	use_external_power = 1

/obj/item/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	icon_state = "nucgun"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 5, TECH_POWER = 3)
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_LARGE
	force = 12.5
	mod_weight = 1.2
	mod_reach = 0.8
	mod_handy = 0.75
	projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	self_recharge = 1
	modifystate = null
	one_hand_penalty = 2 //bulkier than an e-gun, but not quite the size of a carbine
	recharge_time = 5

	firemodes = list(
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode/stunsphere),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam)
		)

	var/fail_counter = 0

/obj/item/gun/energy/gun/nuclear/proc/get_charge_overlay()
	var/ratio = power_supply.percent()
	ratio = round(ratio, 25)
	return "nucgun-[ratio]"

/obj/item/gun/energy/gun/nuclear/proc/get_reactor_overlay()
	if(fail_counter > 30)
		return "nucgun-crit"
	if(fail_counter > 15)
		return "nucgun-medium"
	if(power_supply.percent() <= 50)
		return "nucgun-light"
	return "nucgun-clean"

/obj/item/gun/energy/gun/nuclear/proc/get_mode_overlay()
	var/datum/firemode/current_mode = firemodes[sel_mode]
	switch(current_mode.name)
		if("stun")
			return "nucgun-stun"
		if("lethal")
			return "nucgun-kill"

/obj/item/gun/energy/gun/nuclear/update_icon()
	var/list/new_overlays = list()

	new_overlays += get_charge_overlay()
	new_overlays += get_reactor_overlay()
	new_overlays += get_mode_overlay()

	overlays = new_overlays

/obj/item/gun/energy/egun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: Stun and kill."
	icon_state = "egunstun100"
	modifystate = "egun"
	item_state = null	//so the human update icon uses the icon_state instead.
	max_shots = 10
	fire_delay = 10 // To balance for the fact that it is a pistol and can be used one-handed without penalty
	force = 10.0
	mod_weight = 0.8
	mod_reach = 0.55
	mod_handy = 1.0

	projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 4, TECH_POWER = 3)
	modifystate = "egunstun"
	combustion = FALSE

	firemodes = list(
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode/stunsphere, modifystate="egunstun"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam,                        modifystate="egunkill")
		)
