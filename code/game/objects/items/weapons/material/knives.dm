/obj/item/weapon/material/butterfly
	name = "butterfly knife"
	desc = "A basic metal blade concealed in a lightweight plasteel grip. Small enough when folded to fit in a pocket."
	icon_state = "butterflyknife"
	item_state = null
	hitsound = null
	var/active = 0
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.4
	mod_reach = 0.4
	mod_handy = 1.0
	attack_verb = list("patted", "tapped")
	force_const = 5
	thrown_force_const = 3
	force_divisor = 0.1 // 6 when wielded with hardness 60 (steel)
	thrown_force_divisor = 0.25 // 5 when thrown with weight 20 (steel)

/obj/item/weapon/material/butterfly/update_force()
	if(active)
		edge = 1
		sharp = 1
		..() //Updates force.
		throwforce = max(3,force-3)
		hitsound = 'sound/weapons/bladeslice.ogg'
		icon_state += "_open"
		w_class = ITEM_SIZE_NORMAL
		attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	else
		force = 3
		edge = 0
		sharp = 0
		hitsound = initial(hitsound)
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		attack_verb = initial(attack_verb)

/obj/item/weapon/material/butterfly/switchblade
	name = "switchblade"
	desc = "A classic switchblade with gold engraving. Just holding it makes you feel like a gangster."
	icon_state = "switchblade"
	unbreakable = 1

/obj/item/weapon/material/butterfly/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, "<span class='notice'>You flip out \the [src].</span>")
		playsound(user, 'sound/weapons/flipblade.ogg', 15, 1)
	else
		to_chat(user, "<span class='notice'>\The [src] can now be concealed.</span>")
	update_force()
	add_fingerprint(user)

/*
 * Kitchen knives
 */
/obj/item/weapon/material/knife
	name = "kitchen knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	sharp = 1
	edge = 1
	mod_weight = 0.5
	mod_reach = 0.4
	mod_handy = 1.0
	force_const = 5.5
	thrown_force_const = 3
	force_divisor = 0.05 // 6 when wielded with hardness 60 (steel)
	thrown_force_divisor = 0.25 // 5 when thrown with weight 20 (steel)
	matter = list(DEFAULT_WALL_MATERIAL = 12000)
	origin_tech = list(TECH_MATERIAL = 1)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	unbreakable = 1

/obj/item/weapon/material/knife/hook
	name = "meat hook"
	desc = "A sharp, metal hook what sticks into things."
	icon_state = "hook_knife"
	item_state = "hook_knife"

/obj/item/weapon/material/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	force_const = 6.5
	mod_weight = 0.65
	mod_reach = 0.5
	mod_handy = 1.1
	applies_material_colour = 0

/obj/item/weapon/material/knife/butch
	name = "butcher's cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products. So much meat, so little time."
	mod_weight = 0.6
	mod_reach = 0.4
	mod_handy = 1.0
	force_const = 7.5
	force_divisor = 0.125 // 7.5 when wielded with hardness 60 (steel)
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

///
/obj/item/weapon/material/knife/shiv
	name = "blade"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "shiv"
	item_state = "shiv"
	desc = "A small blade. It's quite uncomfortable to use it without a grip."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	sharp = 1
	edge = 1
	mod_weight = 0.25
	mod_reach = 0.4
	mod_handy = 0.5
	force_const = 5.0
	thrown_force_const = 3
	force_divisor = 0.05 // 3 when wielded with hardness 60 (steel)
	matter = list(DEFAULT_WALL_MATERIAL = 12000)
	origin_tech = list(TECH_MATERIAL = 1)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	unbreakable = 0
	slot_flags = SLOT_BELT
	randpixel = 0
	m_overlay = 1
	var/hasgrip = 0

/obj/item/weapon/material/knife/shiv/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!hasgrip)
		if(istype(W,/obj/item/weapon/material/shivgrip))
			hasgrip = 1
			name = "[src:material.display_name] knife"
			desc = "A small blade. This one has a comfortable [src:material.display_name] grip."
			mod_weight += 0.10
			mod_handy = W.mod_handy
			unbreakable = 1
			to_chat(user, "<span class='notice'>You insert [src] into [W].</span>")
			overlays += image("icon" = 'icons/obj/weapons.dmi', "icon_state" = "[W.icon_state]")
			user.drop_from_inventory(W)
			qdel(W)
			return
		if(isCoil(W))
			var/obj/item/stack/cable_coil/C = W
			if(C.use(5))
				hasgrip = 1
				name = "[src:material.display_name] shiv"
				desc = "A small blade. This one has a makeshift cable grip."
				mod_weight += 0.05
				mod_handy = 1.0
				to_chat(user, "<span class='notice'>You wind up [src]'s grip with the cable.</span>")
				overlays += image("icon" = 'icons/obj/weapons.dmi', "icon_state" = "shiv_wire")
			return
		if(istype(W,/obj/item/weapon/tape_roll))
			hasgrip = 1
			name = "[src:material.display_name] shiv"
			desc = "A small blade. This one has a makeshift duct tape grip."
			mod_weight += 0.1
			mod_handy = 1.0
			to_chat(user, "<span class='notice'>You wind up [src]'s grip with the cable.</span>")
			overlays += image("icon" = 'icons/obj/weapons.dmi', "icon_state" = "shiv_tape")
			return
	..()

/obj/item/weapon/material/shivgrip
	name = "small knife grip"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "shiv_plastic"
	desc = "A durable grip for a small knife."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	mod_weight = 0.5
	mod_reach = 0.25
	mod_handy = 1.15
	force_const = 5.0
	thrown_force_const = 3
	force_divisor = 0
	matter = list(DEFAULT_WALL_MATERIAL = 6000)
	randpixel = 0
	applies_material_colour = 0

/obj/item/weapon/material/shivgrip/wood/New(var/newloc)
	..(newloc,"wood")
	name = "wooden small knife grip"
	icon_state = "shiv_wood"
	color = null

/obj/item/weapon/material/shivgrip/plastic/New(var/newloc)
	..(newloc,"plastic")
	name = "plastic small knife grip"
	icon_state = "shiv_plastic"
	color = null

