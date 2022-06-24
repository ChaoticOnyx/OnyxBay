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
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode, modifystate = "tasertacticalstun"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam/laser/small, modifystate = "tasertacticalkill")
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
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode, modifystate = "tasertacticalstun"),
		list(mode_name = "shock",  projectile_type = /obj/item/projectile/beam/stun/shock,  modifystate = "tasertacticalshock"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam/laser/small, modifystate = "tasertacticalkill")
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
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode,   modifystate = "smallgunstun"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/energy/laser/small, modifystate = "smallgunkill")
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
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/beam/laser/small, modifystate = "smallgunkill")
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
	recharge_time = 8

	firemodes = list(
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/energy/laser/lesser)
		)

	var/fail_counter = 0

//override for failcheck behaviour
/obj/item/gun/energy/gun/nuclear/Process()
	if(fail_counter > 0)
		fail_counter--
		if(fail_counter > 20)
			SSradiation.radiate(src, fail_counter)
	return ..()

/obj/item/gun/energy/gun/nuclear/emp_act(severity)
	..()
	switch(severity)
		if(1)
			fail_counter += 30
			visible_message("\The [src]'s reactor overloads!")
		if(2)
			fail_counter += 15
			if(ismob(loc))
				to_chat(loc, SPAN("warning", "\The [src] feels pleasantly warm."))

/obj/item/gun/energy/gun/nuclear/Fire(atom/target, mob/living/user, clickparams, pointblank = 0, reflex = 0)
	..()
	if(fail_counter > 35)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(2, 0, user.loc)
		spark_system.start()
		if(prob(50))
			visible_message("\The [src]'s reactor heats up uncontrollably!")
			explosion(src.loc, -1, 1, 2)
			if(src)
				user.drop_from_inventory(src)
				qdel(src)
			return
		else
			visible_message("\The [src]'s reactor heats up uncontrollably...  But nothing happens.")
	if(prob(95))
		fail_counter += rand(1, 2)
	else
		fail_counter += rand(5, 12)
		to_chat(loc, SPAN("warning", "\The [src] emits a nasty buzzing sound!"))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(2, 0, user.loc)
		spark_system.start()
	if(fail_counter > 30)
		to_chat(loc, SPAN("warning", "\The [src] feels burning hot!"))
	else if(fail_counter > 15)
		to_chat(loc, SPAN("warning", "\The [src] feels pleasantly warm."))

/obj/item/gun/energy/gun/nuclear/_examine_text(mob/user)
	. = ..()
	if(. && user.Adjacent(src))
		if(fail_counter > 30)
			. += "\n[SPAN("danger", "It feels burning hot!")]"
		else if(fail_counter > 15)
			. += "\n[SPAN("warning", "It feels pleasantly warm.")]"

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
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/energy/electrode,    modifystate="egunstun"),
		list(mode_name = "lethal", projectile_type = /obj/item/projectile/energy/laser/lesser, modifystate="egunkill")
		)

/obj/item/gun/energy/rifle
	name = "energy rifle"
	desc = "Hephaestus Industries G50XS \"Raijin\", a carbine with lethal and stun settings. Because of its cost, it is rarely seen in use."
	icon_state = "eriflestun"
	item_state = "erifle"
	modifystate = "eriflestun"
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_LARGE
	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0
	one_hand_penalty = 3
	accuracy = 2
	max_shots = 24
	fire_delay = null
	burst_accuracy = list(0)
	charge_cost = 10
	burst = 2
	burst_delay = 1
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 5, TECH_POWER = 4, TECH_MAGNET = 3)
	matter = list(MATERIAL_STEEL = 2500)
	projectile_type = /obj/item/projectile/energy/electrode/stunsphere

	firemodes = list(
		list(mode_name = "stun", modifystate = "eriflestun", projectile_type = /obj/item/projectile/energy/electrode, fire_delay = null, charge_cost = 10, burst = 2),
		list(mode_name = "beam", modifystate = "eriflekill", projectile_type = /obj/item/projectile/beam/laser/mid,   fire_delay = 8,    charge_cost = 20, burst = 1),
		list(mode_name = "bolt", modifystate = "eriflekill", projectile_type = /obj/item/projectile/energy/laser/mid, fire_delay = 8,    charge_cost = 20, burst = 1)
	)

/obj/item/gun/energy/rifle/update_icon()
	var/ratio = 0
	if(power_supply && power_supply.charge >= charge_cost)
		ratio = max(round(power_supply.percent(), icon_rounder), icon_rounder)

	icon_state = "[modifystate][ratio]"

	var/mob/living/M = loc
	if(istype(M))
		if(M.can_wield_item(src) && is_held_twohanded(M))
			item_state_slots[slot_l_hand_str] = "[modifystate][ratio]-wielded"
			item_state_slots[slot_r_hand_str] = "[modifystate][ratio]-wielded"
		else
			item_state_slots[slot_l_hand_str] = "[modifystate][ratio]"
			item_state_slots[slot_r_hand_str] = "[modifystate][ratio]"
	update_held_icon()

/obj/item/gun/energy/rifle/cheap
	name = "energy rifle"
	desc = "Hephaestus Industries G50SE \"Razor\", a cheaper version of G50XS \"Raijin\". It has lethal and stun settings."
	mod_handy = 1.0
	accuracy = 1
	max_shots = 20
	fire_delay = null
	charge_cost = 10
	burst = 2
	burst_delay = 2
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 4, TECH_POWER = 3, TECH_MAGNET = 2)
	matter = list(MATERIAL_STEEL = 2500)
	projectile_type = /obj/item/projectile/energy/electrode/stunsphere

	firemodes = list(
		list(mode_name = "stun", modifystate = "eriflestun", projectile_type = /obj/item/projectile/energy/electrode,    fire_delay = null, charge_cost = 10, burst = 2),
		list(mode_name = "beam", modifystate = "eriflekill", projectile_type = /obj/item/projectile/beam/laser/lesser,   fire_delay = 10,   charge_cost = 20, burst = 1),
		list(mode_name = "bolt", modifystate = "eriflekill", projectile_type = /obj/item/projectile/energy/laser/lesser, fire_delay = 10,   charge_cost = 20, burst = 1)
	)
