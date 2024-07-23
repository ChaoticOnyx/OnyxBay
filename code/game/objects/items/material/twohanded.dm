
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
		improper_held_icon = TRUE
	else
		wielded = 0
		force = force_unwielded
		mod_handy = mod_handy_u
		mod_weight = mod_weight_u
		mod_reach = mod_reach_u
		improper_held_icon = FALSE
	update_icon()
	..()

/obj/item/material/twohanded/update_force()
	base_name = name
	var/force_raw
	if(sharp || edge)
		force_raw = material.get_edge_damage()
	else
		force_raw = material.get_blunt_damage()
	force_wielded = force_const + round(force_raw * force_divisor, 0.1)
	force_unwielded = unwielded_force_const + round(force_raw * unwielded_force_divisor, 0.1)
	force = force_unwielded
	throwforce = round(force * thrown_force_divisor)
//	log_debug("[src] has unwielded force [force_unwielded], wielded force [force_wielded] and throwforce [throwforce] when made from default material [material.name]")


/obj/item/material/twohanded/New()
	..()
	update_icon()

/obj/item/material/twohanded/on_update_icon()
	var/new_item_state = "[base_icon][wielded]"
	item_state_slots[slot_l_hand_str] = new_item_state
	item_state_slots[slot_r_hand_str] = new_item_state

/*
 * Chainsaw by BWJes
*/
/obj/item/material/twohanded/chainsaw
	name = "chainsaw"
	desc = "It`s time to rip and tear... The trees. Right?"
	icon_state = "chainsaw"
	base_icon = "chainsaw"
	improper_held_icon = TRUE

	sharp = FALSE // Hard to cut with a not working chainsaw
	edge = FALSE
	w_class = ITEM_SIZE_LARGE

	mod_handy_w = 0.95
	mod_weight_w = 1.5
	mod_reach_w = 1.75
	mod_handy_u = 0.8
	mod_weight_u = 1.2
	mod_reach_u = 1.25

	armor_penetration = 0

	force_wielded = 30
	force_divisor = 0.5
	unwielded_force_divisor = 0.33
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked") // Beating with not working chainsaw
	hitsound = SFX_FIGHTING_SWING
	applies_material_colour = FALSE
	unbreakable = TRUE
	var/active = FALSE
	var/obj/item/welder_tank/tank = null // chainsaw fuel tank
	var/fuel_consumption = 0.05

/obj/item/material/twohanded/chainsaw/think()
	if(!active)
		return
	if(get_fuel() >= fuel_consumption)
		tank.reagents.remove_reagent(/datum/reagent/fuel, fuel_consumption)
	else
		turnOff()
	set_next_think(world.time + 1 SECOND)

/obj/item/material/twohanded/chainsaw/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/welder_tank))
		if(tank)
			to_chat(user, SPAN("danger", "Remove the current tank first."))
			return

		if(!user.drop(W, src))
			return
		tank = W
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return
	..()

/obj/item/material/twohanded/chainsaw/attack_hand(mob/user)
	if(tank && user.get_inactive_hand() == src)
		user.visible_message("[user] removes \the [tank] from \the [src].", "You remove \the [tank] from \the [src].")
		user.pick_or_drop(tank)
		tank = null
		if(active)
			turnOff()
		update_icon()
		return
	..()

/obj/item/material/twohanded/chainsaw/proc/get_fuel()
	return tank ? tank.reagents.get_reagent_amount(/datum/reagent/fuel) : 0

/obj/item/material/twohanded/chainsaw/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 0)
		return

	if(tank)
		. += "\icon[tank] \The [tank] contains [get_fuel()]/[tank.max_fuel] units of fuel!"
	else
		. += "There is no tank attached."

/obj/item/material/twohanded/chainsaw/attack_self(mob/user)
	if(active)
		turnOff()
	else
		turnOn()
	add_fingerprint(user)

/obj/item/material/twohanded/chainsaw/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	..()
	if(A && wielded && active)
		if(istype(A,/obj/structure/grille))
			qdel(A)
		else if(istype(A,/obj/effect/vine))
			var/obj/effect/vine/P = A
			P.die_off()

/obj/item/material/twohanded/chainsaw/proc/turnOn()
	if(get_fuel() <= 0)
		to_chat(usr, SPAN_WARNING("No fuel in [src]!"))
		return
	THROTTLE(toggle_cooldown, 0.5 SECONDS)
	if(!toggle_cooldown)
		return
	if(!do_after(usr, 5, src, luck_check_type = LUCK_CHECK_COMBAT))
		return

	playsound(loc, 'sound/weapons/chainsaw_start.ogg', 50, 1, -1)
	visible_message(SPAN("danger", "[usr] starts the chainsaw!"))

	icon_state = "chainsaw_active"
	base_icon = "chainsaw_active"
	attack_verb = list("tears", "rips")
	hitsound = SFX_CHAINSAW
	sharp = TRUE
	edge = TRUE
	active = TRUE
	armor_penetration = 75

	update_icon()
	update_force()
	update_twohanding()
	think()


/obj/item/material/twohanded/chainsaw/proc/turnOff()
	playsound(loc, 'sound/weapons/chainsaw_stop.ogg', 50, 1, -1)
	visible_message(SPAN("danger", "[usr] stops the chainsaw!"))

	icon_state = "chainsaw"
	base_icon = "chainsaw"
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	hitsound = SFX_FIGHTING_SWING
	sharp = FALSE
	edge = FALSE
	active = FALSE
	armor_penetration = 0

	update_icon()
	update_force()
	update_twohanding()

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
	armor_penetration = 40
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

	drop_sound = SFX_DROP_AXE
	pickup_sound = SFX_PICKUP_AXE

/obj/item/material/twohanded/fireaxe/afterattack(atom/A, mob/user, proximity)
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
	armor_penetration = 65 // Impale those fuckers
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
