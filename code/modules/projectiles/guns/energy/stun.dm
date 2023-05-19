/obj/item/gun/energy/taser
	name = "Mk30 NL"
	desc = "The NT Mk30 NL is a small, low capacity gun used for non-lethal takedowns. Produced by NT, it's actually a licensed version of a W-T design. It can switch between high and low intensity stun shots."
	icon_state = "taserold"
	item_state = null	//so the human update icon uses the icon_state instead.
	max_shots = 5
	projectile_type = /obj/item/projectile/beam/stun
	combustion = 0
	force = 8.5
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0

	firemodes = list(
		list(mode_name="stun", projectile_type=/obj/item/projectile/beam/stun),
		list(mode_name="shock", projectile_type=/obj/item/projectile/beam/stun/shock),
		)

/obj/item/gun/energy/taser/carbine
	name = "stun carbine"
	desc = "The NT Mk44 NL is a high capacity gun used for non-lethal takedowns. It can switch between high and low intensity stun beams, and concentrated stun spheres."
	icon_state = "tasercarbine"
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_BACK
	one_hand_penalty = 3
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0
	max_shots = 12
	accuracy = 1
	max_shots = 12
	projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	wielded_item_state = "tasercarbine-wielded"

	firemodes = list(
		list(mode_name = "sphere", projectile_type = /obj/item/projectile/energy/electrode),
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/beam/stun/heavy),
		list(mode_name = "shock",  projectile_type = /obj/item/projectile/beam/stun/shock/heavy),
		)

/obj/item/gun/energy/taser/mounted
	name = "mounted taser gun"
	desc = "Modified NT Mk30 NL, designed to be mounted on cyborgs and other battle machinery. It can switch between high and low intensity stun beams, and concentrated stun spheres."
	icon_state = "btaser"
	self_recharge = 1
	use_external_power = 1
	projectile_type = /obj/item/projectile/energy/electrode

	firemodes = list(
		list(mode_name = "sphere", projectile_type = /obj/item/projectile/energy/electrode),
		list(mode_name = "stun",   projectile_type = /obj/item/projectile/beam/stun),
		list(mode_name = "shock",  projectile_type = /obj/item/projectile/beam/stun/shock),
		)

/obj/item/gun/energy/taser/mounted/cyborg
	name = "taser gun"
	max_shots = 6
	fire_delay = 15
	recharge_time = 10 //Time it takes for shots to recharge (in ticks)


/obj/item/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A LAEP20 Zeus. Designed by Lawson Arms and produced under the wing of the FTU, several TSCs have been trying to get a hold of the blueprints for half a decade."
	icon_state = "stunrevolver"
	item_state = "stunrevolver"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_POWER = 2)
	projectile_type = /obj/item/projectile/energy/electrode/greater
	fire_delay = 10
	max_shots = 6
	combustion = 0

/obj/item/gun/energy/stunrevolver/rifle
	name = "stun rifle"
	desc = "A LAEP38 Thor, a vastly oversized variant of the LAEP20 Zeus. Fires overcharged electrodes to take down hostile armored targets without harming them too much."
	icon_state = "stunrifle"
	item_state = "stunrifle"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	one_hand_penalty = 6
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	force = 10
	max_shots = 10
	accuracy = 1
	projectile_type = /obj/item/projectile/energy/electrode/stunshot
	wielded_item_state = "stunrifle-wielded"

/obj/item/gun/energy/crossbow
	name = "mini energy-crossbow"
	desc = "A crossbow that doesn't seem to have space for bolts."
	icon_state = "crossbow"
	w_class = ITEM_SIZE_NORMAL
	item_state = "crossbow"
	origin_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 2, TECH_ILLEGAL = 5)
	matter = list(MATERIAL_STEEL = 2000)
	slot_flags = SLOT_BELT
	silenced = 1
	fire_sound = 'sound/effects/weapons/gun/fire_dart1.ogg'
	projectile_type = /obj/item/projectile/energy/bolt
	max_shots = 8
	self_recharge = 1
	charge_meter = 0
	combustion = 0

/obj/item/gun/energy/crossbow/ninja
	name = "energy dart thrower"
	projectile_type = /obj/item/projectile/energy/dart
	max_shots = 5

/obj/item/gun/energy/crossbow/largecrossbow
	name = "energy crossbow"
	desc = "A weapon favored by syndicate infiltration teams."
	w_class = ITEM_SIZE_LARGE
	force = 10
	one_hand_penalty = 1
	matter = list(MATERIAL_STEEL = 200000)
	projectile_type = /obj/item/projectile/energy/bolt/large

/obj/item/gun/energy/plasmastun
	name = "plasma pulse projector"
	desc = "The Mars Military Industries MA21 Selkie is a weapon that uses a laser pulse to ionise the local atmosphere, creating a disorienting pulse of plasma and deafening shockwave as the wave expands."
	icon_state = "plasma_stun"
	item_state = "plasma_stun"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2, TECH_POWER = 3)
	fire_delay = 20
	max_shots = 4
	projectile_type = /obj/item/projectile/energy/plasmastun
	combustion = 0

/obj/item/gun/energy/classictaser
	name = "taser gun"
	desc = "A small, low capacity gun manufactured by NanoTrasen. Used for non-lethal takedowns."
	icon_state = "taserold"
	item_state = "taser"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_POWER = 2)
	projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	max_shots = 5
	combustion = 0
	force = 8.5
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0

/obj/item/gun/energy/security
	name = "taser"
	desc = "A taser gun manufactured by NanoTrasen. Used for non-lethal takedowns."
	icon_state = "taserold"
	item_state = null
	wielded_item_state = FALSE
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_POWER = 2)
	projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	max_shots = 6
	combustion = 0
	force = 8.5
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0
	burst_delay = 2

	var/subtype = /decl/taser_types
	var/owner = null

/obj/item/gun/energy/security/Initialize()
	. = ..()
	if(subtype)
		subtype = decls_repository.get_decl(subtype)
	update_subtype()

/obj/item/gun/energy/security/_examine_text(mob/user)
	. = ..()
	if(owner)
		. += "\nIt is assigned to <b>[owner]</b>."

/obj/item/gun/energy/security/proc/update_subtype()
	var/decl/taser_types/tt = subtype
	name = tt.name
	desc = tt.desc
	icon_state = tt.icon_state
	wielded_item_state = tt.wielded_item_state
	projectile_type = tt.projectile_type
	max_shots = tt.max_shots
	accuracy = tt.accuracy
	one_hand_penalty = tt.one_hand_penalty
	fire_delay = tt.fire_delay
	burst = tt.burst
	w_class = tt.w_class
	slot_flags = tt.slot_flags

	set_firemodes(tt.firemodes)
	var/old_charge_ratio = power_supply.charge / power_supply.maxcharge
	power_supply.maxcharge = max_shots * charge_cost
	power_supply.charge = power_supply.maxcharge * old_charge_ratio

	modifystate = tt.icon_state
	update_icon()

/obj/item/gun/energy/security/update_icon()
	var/ratio = 0
	if(power_supply && power_supply.charge >= charge_cost)
		ratio = max(round(power_supply.percent(), icon_rounder), icon_rounder)

	icon_state = "[modifystate][ratio]"

	var/mob/living/M = loc
	if(istype(M))
		if(wielded_item_state && M.can_wield_item(src) && is_held_twohanded(M))
			item_state_slots[slot_l_hand_str] = "[modifystate][ratio]-wielded"
			item_state_slots[slot_r_hand_str] = "[modifystate][ratio]-wielded"
		else
			item_state_slots[slot_l_hand_str] = "[modifystate][ratio]"
			item_state_slots[slot_r_hand_str] = "[modifystate][ratio]"
	update_held_icon()

/obj/item/gun/energy/security/pistol
	name = "taser pistol"
	icon_state = "taser"
	subtype = /decl/taser_types/pistol

/obj/item/gun/energy/security/smg
	name = "taser SMG"
	icon_state = "taser_smg"
	subtype = /decl/taser_types/smg

/obj/item/gun/energy/security/rifle
	name = "taser rifle"
	icon_state = "taser_rifle"
	subtype = /decl/taser_types/rifle

/decl/taser_types
	var/name = "taser"
	var/desc = "A perfectly generic taser."
	var/icon_state = "taser"
	var/wielded_item_state = FALSE
	var/projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	var/max_shots = 6
	var/accuracy = 0
	var/one_hand_penalty = 0
	var/fire_delay = 6
	var/burst = 1
	var/list/firemodes = list()
	var/w_class = ITEM_SIZE_NORMAL
	var/slot_flags = SLOT_BELT|SLOT_HOLSTER
	var/type_name = ""
	var/type_desc = ""

/decl/taser_types/pistol
	name = "taser pistol"
	desc = "The smallest of all the tasers. It only has a single fire mode, but each shot wields power."
	icon_state = "taser"
	wielded_item_state = FALSE
	projectile_type = /obj/item/projectile/energy/electrode
	max_shots = 6
	accuracy = 0
	one_hand_penalty = 0
	fire_delay = 6
	burst = 1
	list/firemodes = list()
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	type_name = "pistol"
	type_desc = "Baseline taser gun. No alternative firemodes. Compact and lightweighted, it can be stored in holsters."

/decl/taser_types/smg
	name = "taser SMG"
	desc = "This model is not as powerful as pistols, but is capable of launching electrodes left and right with its remarkable rate of fire."
	icon_state = "taser_smg"
	wielded_item_state = FALSE
	projectile_type = /obj/item/projectile/energy/electrode/small
	max_shots = 12
	accuracy = 0
	one_hand_penalty = 1
	fire_delay = 3
	burst = 1
	firemodes = list(
		list(mode_name = "semiauto", fire_delay = 3,    burst = 1),
		list(mode_name = "burst",    fire_delay = null, burst = 3)
	)
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_BELT
	type_name = "SMG"
	type_desc = "Rapid-firing taser gun. Can launch electrodes in 3-shot bursts. A little bigger than pistols, it cannot be holstered."

/decl/taser_types/rifle
	name = "taser rifle"
	desc = "This model is bulky and heavy, it must be wielded with both hands. Although its rate of fire is way below average, it is capable of shooting stun beams."
	icon_state = "taser_rifle"
	wielded_item_state = TRUE
	projectile_type = /obj/item/projectile/energy/electrode/greater
	max_shots = 6
	accuracy = 0
	one_hand_penalty = 2
	fire_delay = 12
	burst = 1
	firemodes = list(
		list(mode_name = "electrode", projectile_type = /obj/item/projectile/energy/electrode/greater),
		list(mode_name = "beam",      projectile_type = /obj/item/projectile/beam/stun/greater)
	)
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_BACK
	type_name = "rifle"
	type_desc = "Long-range taser gun. Single electrodes are more powerful than the pistols', capable of shooting beams. Can be worn on one's back."
