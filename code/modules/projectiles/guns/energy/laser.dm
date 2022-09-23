/obj/item/gun/energy/laser
	name = "laser rifle"
	desc = "A NanoTrasen G40E rifle, designed to kill with concentrated energy blasts."
	icon_state = "laser"
	item_state = "laserrifle"
	slot_flags = SLOT_BACK
	w_class = ITEM_SIZE_HUGE
	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0
	one_hand_penalty = 2
	accuracy = 2
	max_shots = 12
	fire_delay = 9
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	matter = list(MATERIAL_STEEL = 2000)
	projectile_type = /obj/item/projectile/energy/laser/mid
	wielded_item_state = "laserrifle-wielded"

	firemodes = list(
		list(mode_name = "bolt", projectile_type = /obj/item/projectile/energy/laser/mid),
		list(mode_name = "beam", projectile_type = /obj/item/projectile/beam/laser/mid)
	)

/obj/item/gun/energy/laser/mounted
	desc = "A modification of NanoTrasen G40E rifle, designed to be mounted on cyborgs and other battle machinery. It's designed to kill with concentrated energy blasts."
	self_recharge = 1
	use_external_power = 1
	one_hand_penalty = 0 //just in case
	icon_state = "blaser"

/obj/item/gun/energy/laser/mounted/cyborg
	max_shots = 6
	recharge_time = 10 //Time it takes for shots to recharge (in ticks)
	var/locked = 1


/obj/item/gun/energy/laser/mounted/cyborg/afterattack(atom/A, mob/living/user)
	if (locked)
		to_chat(user, "<span class='warning'>Current security protocols are not allowing you to use [src].</span>")
		return
	..()

/obj/item/gun/energy/laser/mounted/cyborg/attack(atom/A, mob/living/user)
	if (locked)
		to_chat(user, "<span class='warning'>Current security protocols are not allowing you to use [src].</span>")
		return
	..()

/obj/item/gun/energy/laser/pistol
	name = "laser pistol"
	desc = "A NanoTrasen LP \"Arclight\", a combat laser pistol. Not as powerful as a laser rifle, it is much smaller and capable of shooting much more rapidly."
	icon_state = "laser_pistol"
	item_state = "laser"
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	one_hand_penalty = 0
	accuracy = 1.0
	max_shots = 12
	fire_delay = 5.5
	projectile_type = /obj/item/projectile/energy/laser/small
	wielded_item_state = null
	force = 8.5
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0

	firemodes = list(
		list(mode_name = "bolt", projectile_type = /obj/item/projectile/energy/laser/small),
		list(mode_name = "beam", projectile_type = /obj/item/projectile/beam/laser/small)
	)

/obj/item/gun/energy/laser/practice
	name = "practice laser rifle"
	desc = "A modified version of the NT G40E, this one fires less concentrated energy bolts designed for target practice."
	icon_state = "laserp"
	projectile_type = /obj/item/projectile/beam/practice
	charge_cost = 10 //How much energy is needed to fire.
	combustion = FALSE

	firemodes = list()

/obj/item/gun/energy/laser/practice/proc/hacked()
	return projectile_type != /obj/item/projectile/beam/practice

/obj/item/gun/energy/laser/practice/emag_act(remaining_charges, mob/user, emag_source)
	if(hacked())
		return NO_EMAG_ACT
	to_chat(user, "<span class='warning'>You disable the safeties on [src] and crank the output to the lethal levels.</span>")
	desc += " Its safeties are disabled and output is set to dangerous levels."
	projectile_type = /obj/item/projectile/beam/laser/mid
	charge_cost = 20
	max_shots = rand(3,6) //will melt down after those
	return 1

/obj/item/gun/energy/laser/practice/handle_post_fire(mob/user, atom/target, pointblank=0, reflex=0)
	..()
	if(hacked())
		max_shots--
		if(!max_shots) //uh hoh gig is up
			to_chat(user, "<span class='danger'>\The [src] sizzles in your hands, acrid smoke rising from the firing end!</span>")
			desc += " The optical pathway is melted and useless."
			projectile_type = null

/obj/item/gun/energy/retro
	name = "retro laser"
	icon_state = "retro"
	item_state = "retro"
	desc = "An older model of the basic lasergun. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	w_class = ITEM_SIZE_NORMAL
	projectile_type = /obj/item/projectile/energy/laser/lesser // Old but gold
	fire_delay = 15 //old technology, and a pistol
	force = 9.0
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0

/obj/item/gun/energy/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	desc = "A rare weapon, handcrafted by a now defunct specialty manufacturer on Luna for a small fortune. It's certainly aged well."
	force = 10.0
	mod_weight = 0.8
	mod_reach = 0.5
	mod_handy = 1.1
	slot_flags = SLOT_BELT //too unusually shaped to fit in a holster
	w_class = ITEM_SIZE_NORMAL
	projectile_type = /obj/item/projectile/energy/laser/small
	fire_delay = 6
	origin_tech = null
	max_shots = 5 //to compensate a bit for self-recharging
	one_hand_penalty = 1 //a little bulky
	self_recharge = 1

/obj/item/gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the laser cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon"
	item_state = null
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	slot_flags = SLOT_BACK
	one_hand_penalty = 6 //large and heavy
	w_class = ITEM_SIZE_HUGE
	projectile_type = /obj/item/projectile/energy/laser/heavy
	charge_cost = 40
	max_shots = 8
	accuracy = 2
	fire_delay = 20
	wielded_item_state = "lasercannon-wielded"
	force = 14.0
	mod_weight = 1.25
	mod_reach = 1.0
	mod_handy = 1.0

	firemodes = list(
		list(mode_name = "bolt", projectile_type = /obj/item/projectile/energy/laser/heavy),
		list(mode_name = "beam", projectile_type = /obj/item/projectile/beam/laser/heavy)
	)

/obj/item/gun/energy/lasercannon/mounted
	name = "mounted laser cannon"
	self_recharge = 1
	use_external_power = 1
	recharge_time = 10
	accuracy = 0 //mounted laser cannons don't need any help, thanks
	one_hand_penalty = 0

/obj/item/gun/energy/xray
	name = "x-ray laser carbine"
	desc = "A high-power laser gun capable of emitting concentrated x-ray blasts, that are able to penetrate laser-resistant armor much more readily than standard photonic beams."
	icon_state = "xray"
	item_state = "xray"
	slot_flags = SLOT_BACK
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3, TECH_MAGNET = 2, TECH_ILLEGAL = 2)
	projectile_type = /obj/item/projectile/beam/xray/midlaser
	one_hand_penalty = 2
	w_class = ITEM_SIZE_HUGE
	charge_cost = 15
	max_shots = 10
	wielded_item_state = "gun_wielded"
	combustion = 0
	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0

/obj/item/gun/energy/xray/pistol
	name = "x-ray laser gun"
	icon_state = "oldxray"
	item_state = "oldxray"
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_MAGNET = 2, TECH_ILLEGAL = 2)
	projectile_type = /obj/item/projectile/beam/xray
	one_hand_penalty = 1
	w_class = ITEM_SIZE_NORMAL
	fire_delay = 10
	wielded_item_state = null
	force = 8.5
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0

/obj/item/gun/energy/sniperrifle
	name = "marksman energy rifle"
	desc = "The HI DMR 9E is an older design of Hephaestus Industries. A designated marksman rifle capable of shooting powerful ionized beams, this is a weapon to kill from a distance."
	icon_state = "sniper"
	item_state = "laser"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_POWER = 4)
	projectile_type = /obj/item/projectile/beam/sniper
	one_hand_penalty = 5 // The weapon itself is heavy, and the long barrel makes it hard to hold steady with just one hand.
	slot_flags = SLOT_BACK
	charge_cost = 40
	max_shots = 4
	fire_delay = 35
	force = 13.5
	mod_weight = 1.1
	mod_reach = 1.0
	mod_handy = 1.0
	w_class = ITEM_SIZE_HUGE
	accuracy = -2 //shooting at the hip
	scoped_accuracy = 0
	wielded_item_state = "gun_wielded"

/obj/item/gun/energy/sniperrifle/update_icon()
	..()
	item_state_slots[slot_back_str] = icon_state //so that the on-back overlay uses the different charged states

/obj/item/gun/energy/sniperrifle/verb/scope()
	set category = "Object"
	set name = "Use Scope"
	set popup_menu = 1

	toggle_scope(usr, 2.0)

////////Laser Tag////////////////////

/obj/item/gun/energy/lasertag
	name = "laser tag gun"
	item_state = "laser"
	desc = "Standard issue weapon of the Imperial Guard."
	origin_tech = list(TECH_COMBAT = 1, TECH_MAGNET = 2)
	self_recharge = 1
	force = 5.0
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0
	matter = list(MATERIAL_STEEL = 2000)
	projectile_type = /obj/item/projectile/beam/lasertag/blue
	var/required_vest
	combustion = FALSE

/obj/item/gun/energy/lasertag/special_check(mob/living/carbon/human/M)
	if(ishuman(M))
		if(!istype(M.wear_suit, required_vest))
			to_chat(M, "<span class='warning'>You need to be wearing your laser tag vest!</span>")
			return 0
	return ..()

/obj/item/gun/energy/lasertag/blue
	icon_state = "bluetag"
	item_state = "bluetag"
	projectile_type = /obj/item/projectile/beam/lasertag/blue
	required_vest = /obj/item/clothing/suit/bluetag

/obj/item/gun/energy/lasertag/red
	icon_state = "redtag"
	item_state = "redtag"
	projectile_type = /obj/item/projectile/beam/lasertag/red
	required_vest = /obj/item/clothing/suit/redtag
