/obj/item/material/butterfly
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
	material_amount = 2

/obj/item/material/butterfly/update_force()
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

/obj/item/material/butterfly/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, "<span class='notice'>You flip out \the [src].</span>")
		playsound(user, 'sound/weapons/flipblade.ogg', 15, 1)
	else
		to_chat(user, "<span class='notice'>\The [src] can now be concealed.</span>")
	update_force()
	add_fingerprint(user)

/obj/item/material/butterfly/switchblade
	name = "switchblade"
	desc = "A classic switchblade with gold engraving. Just holding it makes you feel like a gangster."
	icon_state = "switchblade"
	unbreakable = 1

/*
 * Kitchen knives
 */
/obj/item/material/knife
	name = "knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A sharpened piece of metal. Probably, one of the eldest technologies to be present at the station."
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
	matter = list(MATERIAL_STEEL = 12000)
	origin_tech = list(TECH_MATERIAL = 1)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	unbreakable = 1
	material_amount = 2

	drop_sound = SFX_DROP_KNIFE
	pickup_sound = SFX_PICKUP_KNIFE

/obj/item/material/knife/hook
	name = "meat hook"
	desc = "A sharp, metal hook what sticks into things."
	icon_state = "hook_knife"
	item_state = "hook_knife"

/obj/item/material/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	force_const = 6.5
	mod_weight = 0.65
	mod_reach = 0.5
	mod_handy = 1.1
	applies_material_colour = 0

/obj/item/material/knife/kitchen
	name = "kitchen knife"
	icon_state = "kitchenknife"
	item_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	mod_weight = 0.5
	mod_reach = 0.4
	mod_handy = 1.1
	applies_material_colour = 0
	unbreakable = 1 // "Guaranteed to stay sharp for years to come"

/obj/item/material/knife/butch
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
	material_amount = 3

/obj/item/material/knife/butch/kitchen
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products. Made by SpaceCook Incorporated. Guaranteed to be shinier than your average steel cleaver."
	applies_material_colour = 0
	unbreakable = 1

///
/obj/item/material/knife/shiv
	name = "shiv blade"
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
	matter = list(MATERIAL_STEEL = 12000)
	origin_tech = list(TECH_MATERIAL = 1)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	unbreakable = 0
	slot_flags = SLOT_BELT
	randpixel = 0
	m_overlay = 1
	material_amount = 2
	var/hasgrip = FALSE

/obj/item/material/knife/shiv/attackby(obj/item/W, mob/user)
	if(!hasgrip)
		if(istype(W, /obj/item/material/shivgrip))
			var/obj/item/material/shivgrip/SG = W
			hasgrip = TRUE
			name = "[material.display_name] knife"
			desc = "A small blade. This one has a comfortable [SG.material.display_name] grip."
			mod_weight += 0.10
			mod_handy = W.mod_handy
			unbreakable = 1
			to_chat(user, "<span class='notice'>You insert [src] into [W].</span>")
			AddOverlays(image('icons/obj/weapons.dmi', W.icon_state))
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
				AddOverlays(image('icons/obj/weapons.dmi', "shiv_wire"))
			return
		if(istype(W,/obj/item/tape_roll))
			hasgrip = 1
			name = "[src:material.display_name] shiv"
			desc = "A small blade. This one has a makeshift duct tape grip."
			mod_weight += 0.1
			mod_handy = 1.0
			to_chat(user, "<span class='notice'>You wind up [src]'s grip with the cable.</span>")
			AddOverlays(image('icons/obj/weapons.dmi', "shiv_tape"))
			return
	..()

/obj/item/material/shivgrip
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
	matter = list(MATERIAL_STEEL = 6000)
	randpixel = 0
	applies_material_colour = 0
	hitsound = SFX_FIGHTING_SWING
	w_class = ITEM_SIZE_SMALL

/obj/item/material/shivgrip/wood/New(newloc)
	..(newloc, MATERIAL_WOOD)
	name = "wooden small knife grip"
	icon_state = "shiv_wood"
	color = null

/obj/item/material/shivgrip/plastic/New(newloc)
	..(newloc, MATERIAL_PLASTIC)
	name = "plastic small knife grip"
	icon_state = "shiv_plastic"
	color = null


/obj/item/material/knife/butch/kitchen/syndie
	desc = "A huge thing used for chopping and chopping up meat. This includes personnel and personnel-by-products. Made by Waffle Co. Guaranteed to be shinier than your average steel cleaver."
	icon_state = "butch_syndie"
	item_state = "butch"
	force_const = 10.0
	armor_penetration = 15

/obj/item/material/knife/butch/kitchen/syndie/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	if(ishuman(target) && target.is_ic_dead())
		chopchop(user, target)
		return 0
	return ..()

/obj/item/material/knife/butch/kitchen/syndie/proc/chopchop(mob/user, mob/living/carbon/human/victim)
	user.visible_message(SPAN("danger", "<b>[user]</b> chops [victim] into pieces!"))

	var/slab_name = victim.real_name
	var/slab_count = 0
	var/slab_type = victim.species.meat_type
	var/robotic_slab_count = 0
	var/robotic_slab_type = /obj/item/stack/material/steel
	var/slab_nutrition = victim.nutrition / 15

	for(var/obj/item/organ/external/O in victim.organs)
		if(O.is_stump())
			continue
		var/obj/item/organ/external/chest/C = O
		if(istype(C))
			if(BP_IS_ROBOTIC(O))
				robotic_slab_count += C.butchering_capacity
			else
				slab_count += C.butchering_capacity
			continue
		if(BP_IS_ROBOTIC(O))
			robotic_slab_count++
		else
			slab_count++

	if(slab_count > 0)
		slab_nutrition /= slab_count

		var/reagent_transfer_amt
		if(victim.reagents)
			reagent_transfer_amt = round(victim.reagents.total_volume / slab_count, 1)

		for(var/i = 1 to slab_count)
			var/obj/item/reagent_containers/food/meat/new_meat = new slab_type(victim.loc, rand(3, 8))
			if(istype(new_meat))
				new_meat.SetName("[slab_name] [new_meat.name]")
				new_meat.reagents.add_reagent(/datum/reagent/nutriment, slab_nutrition)
				if(victim.reagents)
					victim.reagents.trans_to_obj(new_meat, reagent_transfer_amt)

	for(var/i = 1 to robotic_slab_count)
		new robotic_slab_type(victim.loc, rand(3, 5))

	admin_attack_log(user, victim, "Gibbed the victim", "Was gibbed", "gibbed")

	playsound(victim.loc, 'sound/effects/splat.ogg', 50, 1)
	victim.gib()
	QDEL_NULL(victim)
