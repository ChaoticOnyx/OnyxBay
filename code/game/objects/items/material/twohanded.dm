/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Spears
 *		Baseball bats
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere.

/*
 * Twohanded
 */
/obj/item/material/twohanded
	w_class = ITEM_SIZE_HUGE
	var/wielded = 0
	var/force_wielded = 0
	var/force_unwielded
	var/wieldsound = null
	var/unwieldsound = null
	var/base_icon
	var/base_name
	var/unwielded_force_const = 0
	var/unwielded_force_divisor = 0.25
	var/mod_handy_w
	var/mod_weight_w
	var/mod_reach_w
	var/mod_handy_u
	var/mod_weight_u
	var/mod_reach_u

/obj/item/material/twohanded/update_twohanding()
	var/mob/living/M = loc
	if(istype(M) && M.can_wield_item(src) && is_held_twohanded(M))
		wielded = 1
		force = force_wielded
		mod_handy = mod_handy_w
		mod_weight = mod_weight_w
		mod_reach = mod_reach_w
	else
		wielded = 0
		force = force_unwielded
		mod_handy = mod_handy_u
		mod_weight = mod_weight_u
		mod_reach = mod_reach_u
	update_icon()
	..()

/obj/item/material/twohanded/update_force()
	base_name = name
	if(sharp || edge)
		force_wielded = material.get_edge_damage()
	else
		force_wielded = material.get_blunt_damage()
	force_wielded = force_const + round(force_wielded * force_divisor, 0.1)
	force_unwielded = unwielded_force_const + round(force_wielded * unwielded_force_divisor, 0.1)
	force = force_unwielded
	throwforce = round(force * thrown_force_divisor)
//	log_debug("[src] has unwielded force [force_unwielded], wielded force [force_wielded] and throwforce [throwforce] when made from default material [material.name]")


/obj/item/material/twohanded/New()
	..()
	update_icon()

/obj/item/material/twohanded/update_icon()
	var/new_item_state = "[base_icon][wielded]"
	item_state_slots[slot_l_hand_str] = new_item_state
	item_state_slots[slot_r_hand_str] = new_item_state

/*
 * Fireaxe
 */
/obj/item/material/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	base_icon = "fireaxe"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"

	// 12/30 with hardness 60 (steel) and 16/40 with hardness 80 (plasteel)
	force_divisor = 0.5
	unwielded_force_divisor = 0.2
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_HUGE
	mod_handy_w = 1.2
	mod_weight_w = 2.0
	mod_reach_w = 1.5
	mod_handy_u = 0.4
	mod_weight_u = 1.5
	mod_reach_u = 1.0
	slot_flags = SLOT_BACK
	force_wielded = 30
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	applies_material_colour = 0
	unbreakable = 1 // Because why should it break at all
	material_amount = 8

/obj/item/material/twohanded/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	..()
	if(A && wielded)
		if(istype(A,/obj/structure/window))
			var/obj/structure/window/W = A
			W.shatter()
		else if(istype(A,/obj/structure/grille))
			qdel(A)
		else if(istype(A,/obj/effect/vine))
			var/obj/effect/vine/P = A
			P.die_off()

//spears, bay edition
/obj/item/material/twohanded/spear
	icon_state = "spearglass0"
	base_icon = "spearglass"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	unwielded_force_const = 5.5
	force_const = 6.5
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_HUGE
	mod_handy_w = 1.25
	mod_weight_w = 1.25
	mod_reach_w = 2.0
	mod_handy_u = 0.75
	mod_weight_u = 1.0
	mod_reach_u = 1.5
	slot_flags = SLOT_BACK

	// 6/12 with hardness 60 (steel) or 5/10 with hardness 50 (glass)
	force_divisor = 0.2
	unwielded_force_divisor = 0.1
	thrown_force_divisor = 1.2 // 120% of force
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	default_material = MATERIAL_GLASS
	material_amount = 3

/obj/item/material/twohanded/spear/shatter(consumed)
	if(!consumed)
		new /obj/item/material/wirerod(get_turf(src)) //give back the wired rod
	..()

/obj/item/material/twohanded/baseballbat
	name = "bat"
	desc = "HOME RUN!"
	icon_state = "metalbat0"
	base_icon = "metalbat"
	w_class = ITEM_SIZE_LARGE
	mod_weight = 1.5
	mod_reach = 1.0
	mod_handy = 1.0

	mod_handy_w = 1.0
	mod_weight_w = 1.5
	mod_reach_w = 1.0
	mod_handy_u = 0.75
	mod_weight_u = 1.35
	mod_reach_u = 1.0

	throwforce = 7
	attack_verb = list("smashed", "beaten", "slammed", "smacked", "struck", "battered", "bonked")
	hitsound = SFX_FIGHTING_SWING
	default_material = MATERIAL_WOOD

	force_const = 8.0
	force_divisor = 0.6           // 14 when wielded with weight 20 (steel)
	unwielded_force_const = 5.0
	unwielded_force_divisor = 0.5 // 15 when unwielded based on above.
	slot_flags = SLOT_BACK
	material_amount = 5

//Predefined materials go here.
/obj/item/material/twohanded/baseballbat/metal/New(newloc)
	..(newloc, MATERIAL_STEEL)

/obj/item/material/twohanded/baseballbat/uranium/New(newloc)
	..(newloc, MATERIAL_URANIUM)

/obj/item/material/twohanded/baseballbat/gold/New(newloc)
	..(newloc, MATERIAL_GOLD)

/obj/item/material/twohanded/baseballbat/platinum/New(newloc)
	..(newloc, MATERIAL_PLATINUM)

/obj/item/material/twohanded/baseballbat/diamond/New(newloc)
	..(newloc, MATERIAL_DIAMOND)
