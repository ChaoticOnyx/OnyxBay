//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/smokable
	name = "smokable item"
	desc = "You're not sure what this is. You should probably ahelp it."
	body_parts_covered = NO_BODYPARTS
	icon = 'icons/obj/cigarettes.dmi'
	var/lit = 0
	var/ever_lit = FALSE // Has it ever been lit
	var/icon_on
	var/type_butt = null
	var/chem_volume = 10
	var/smokeamount = 1
	var/smoketime = 0
	var/brand
	var/filter_trans = 0.5
	var/smoke_effect = 0

/obj/item/clothing/mask/smokable/New()
	..()
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER

/obj/item/clothing/mask/smokable/Initialize()
	. = ..()
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of [chem_volume]

/obj/item/clothing/mask/smokable/Destroy()
	. = ..()
	if(lit)
		set_next_think(0)

/obj/item/clothing/mask/smokable/proc/smoke(amount, manual = FALSE)
	smoketime -= amount
	if(reagents && reagents.total_volume) // check if it has any reagents at all
		var/smoke_loc = loc
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			if((src == C.wear_mask || manual) && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.trans_to_mob(C, smokeamount*amount, CHEM_INGEST, filter_trans)
			else // else just remove some of the reagents
				reagents.remove_any(smokeamount*amount)
			smoke_loc = C.loc
		smoke_effect++
		if((smoke_effect >= 3 || manual) && isturf(smoke_loc))
			smoke_effect = 0
			new /obj/effect/effect/cig_smoke(smoke_loc)
		update_icon()
	else
		die()

#define MIN_OXIDIZER_PRESSURE_TO_SMOKE 8

/obj/item/clothing/mask/smokable/think()
	var/turf/location = get_turf(src)
	smoke(1)
	if(smoketime < 1)
		die()
		return

	var/datum/gas_mixture/air = location.return_air()
	if(!air)
		die(nomessage = TRUE, nodestroy = TRUE)
		return
	else if(air.gas["oxygen"] < MIN_OXIDIZER_PRESSURE_TO_SMOKE)
		die(nomessage = TRUE, nodestroy = TRUE)
		return

	if(location)
		location.hotspot_expose(700, 5)

	if(prob(1) && ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.head && istype(H.head, /obj/item/clothing/head/cardborg))
			H.visible_message(SPAN("danger", "[src] ignites \the [H.head], and sets [H] on fire!"), \
							  SPAN("danger", "[src] ignites \the [H.head] on your head. You are on fire!"))
			H.adjust_fire_stacks(10)
			H.IgniteMob(TRUE)

	set_next_think(world.time + 1 SECOND)

/obj/item/clothing/mask/smokable/on_update_icon()
	if(lit && icon_on)
		icon_state = icon_on
		item_state = icon_on
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	if(ismob(loc))
		var/mob/living/M = loc
		M.update_inv_wear_mask(0)
		M.update_inv_l_hand(0)
		M.update_inv_r_hand(1)

#undef MIN_OXIDIZER_PRESSURE_TO_SMOKE

/obj/item/clothing/mask/smokable/proc/light(atom/used_tool, mob/holder) // both arguments are optional
	if(src.lit)
		return

	if(reagents.has_reagent_or_subtypes(/datum/reagent/water))
		if(holder)
			to_chat(holder, SPAN_WARNING("\the [src] is wet and it won't light!"))
		return

	lit = TRUE
	ever_lit = TRUE
	if(atom_flags & ATOM_FLAG_NO_REACT)
		atom_flags &= ~ATOM_FLAG_NO_REACT

	atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER

	damtype = BURN
	force = initial(force) + 2

	var/explosion_amount = 0

	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
		explosion_amount += reagents.get_reagent_amount(/datum/reagent/toxin/plasma)
	if(reagents.get_reagent_amount(/datum/reagent/fuel))
		explosion_amount += reagents.get_reagent_amount(/datum/reagent/fuel) / 2

	if(explosion_amount)
		var/datum/effect/effect/system/reagents_explosion/e = new()
		e.set_up(explosion_amount, src, 0, 0)
		e.start()
		qdel(src)
		return

	update_icon()
	var/turf/T = get_turf(src)
	T.visible_message(generate_lighting_message(used_tool, holder))
	set_light(0.3, 0.2, 1, 1, "#e38f46")
	smokeamount = reagents.total_volume / smoketime
	set_next_think(world.time)

/obj/item/clothing/mask/smokable/clean_blood()
	die(FALSE, TRUE)
	return ..()

/obj/item/clothing/mask/smokable/proc/die(nomessage = FALSE, nodestroy = FALSE)
	set_light(0)
	lit = 0
	set_next_think(0)
	update_icon()
	damtype = initial(damtype)
	force = initial(force)
	playsound(loc, 'sound/items/pffsh.ogg', 50, 1, -1)

/obj/item/clothing/mask/smokable/proc/can_be_lit_with(obj/W)
	return W.get_temperature_as_from_ignitor() || istype(W, /obj/item/device/assembly/igniter)

/obj/item/clothing/mask/smokable/proc/generate_lighting_message(atom/tool, mob/holder)
	var/text = ""
	if(holder)
		if(src.loc == holder)
			text += "[holder] lights \his [name]"
		else
			text += "[holder] lights [name]"
	else
		text += "\A [name] was lit"
	if(tool)
		if(istype(tool, /obj/machinery))
			text += " by \a [tool]."
		else
			text += " with \a [tool]."
	else
		text += "."
	return SPAN("notice", text)

/obj/item/clothing/mask/smokable/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(!lit && can_be_lit_with(W))
		light(W, user)

/obj/item/clothing/mask/smokable/afterattack(obj/item/W, mob/user as mob, proximity)
	if(!proximity)
		return

	if(!lit && istype(W, /obj/item) && can_be_lit_with(W))
		light(W, user)
