//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

//For anything that can light stuff on fire
/obj/item/weapon/flame
	var/lit = 0

/obj/item/weapon/flame/get_temperature_as_from_ignitor()
	if(lit)
		return 1000
	return 0

///////////
//MATCHES//
///////////
/obj/item/weapon/flame/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/burnt = 0
	var/smoketime = 5
	w_class = ITEM_SIZE_TINY
	origin_tech = list(TECH_MATERIAL = 1)
	slot_flags = SLOT_EARS
	attack_verb = list("burnt", "singed")

/obj/item/weapon/flame/match/Process()
	if(isliving(loc))
		var/mob/living/M = loc
		M.IgniteMob()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		burn_out()
		return
	if(location)
		location.hotspot_expose(700, 5)
		return

/obj/item/weapon/flame/match/dropped(mob/user as mob)
	//If dropped, put ourselves out
	//not before lighting up the turf we land on, though.
	if(lit)
		spawn(0)
			var/turf/location = src.loc
			if(istype(location))
				location.hotspot_expose(700, 5)
			burn_out()
	return ..()

/obj/item/weapon/flame/match/proc/burn_out()
	lit = 0
	burnt = 1
	damtype = "brute"
	icon_state = "match_burnt"
	item_state = "cigoff"
	name = "burnt match"
	desc = "A match. This one has seen better days."
	STOP_PROCESSING(SSobj, src)

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/smokable
	name = "smokable item"
	desc = "You're not sure what this is. You should probably ahelp it."
	body_parts_covered = 0
	var/lit = 0
	var/icon_on
	var/type_butt = null
	var/chem_volume = 15
	var/smoketime = 0
	var/brand

/obj/item/clothing/mask/smokable/New()
	..()
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of [chem_volume]

/obj/item/clothing/mask/smokable/Destroy()
	. = ..()
	if(lit)
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/smokable/proc/smoke(amount)
	smoketime -= amount
	if(reagents && reagents.total_volume) // check if it has any reagents at all
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			if (src == C.wear_mask && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.trans_to_mob(C, REM, CHEM_INGEST, 0.2) // Most of it is not inhaled... balance reasons.
		else // else just remove some of the reagents
			reagents.remove_any(REM)

#define MIN_OXIDIZER_PRESSURE_TO_SMOKE 8

/obj/item/clothing/mask/smokable/Process()
	var/turf/location = get_turf(src)
	smoke(1)
	if(smoketime < 1)
		die()
		return
	
	var/datum/gas_mixture/air = location.return_air()
	if(!air)
		die(nomessage = TRUE, nodestroy = TRUE)
	else if(air.gas["oxygen"] < MIN_OXIDIZER_PRESSURE_TO_SMOKE)
		die(nomessage = TRUE, nodestroy = TRUE)
	
	if(location)
		location.hotspot_expose(700, 5)
	
	if(prob(1) && ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.head && istype(H.head, /obj/item/clothing/head/cardborg))
			H.visible_message(SPAN_DANGER("[src] ignites \the [H.head], and sets [H] on fire!"), \
								SPAN_DANGER("[src] ignites \the [H.head] on your head. You are on fire!"))
			H.adjust_fire_stacks(1)
			H.IgniteMob()

/obj/item/clothing/mask/smokable/update_icon()
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
	if(!src.lit)
		src.lit = 1

		damtype = BURN
		force = initial(force) + 2

		var/explosion_amount = 0

		if(reagents.get_reagent_amount(/datum/reagent/toxin/phoron))
			explosion_amount += reagents.get_reagent_amount(/datum/reagent/toxin/phoron)
		if(reagents.get_reagent_amount(/datum/reagent/fuel))
			explosion_amount += reagents.get_reagent_amount(/datum/reagent/fuel) / 2

		if (explosion_amount)
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(explosion_amount, src, 0, 0)
			e.start()
			qdel(src)
			return

		update_icon()
		var/turf/T = get_turf(src)
		T.visible_message(generate_lighting_message(used_tool, holder))
		set_light(2, 0.25, "#e38f46")
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/smokable/proc/die(nomessage = FALSE, nodestroy = FALSE)
	set_light(0)
	lit = 0
	STOP_PROCESSING(SSobj, src)
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
	return SPAN_NOTICE(text)

/obj/item/clothing/mask/smokable/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(!lit && can_be_lit_with(W))
		light(W, user)

/obj/item/clothing/mask/smokable/afterattack(obj/item/W, mob/user as mob, proximity)
	if(!proximity)
		return
	
	if(!lit && can_be_lit_with(W))
		light(W, user)

/obj/item/clothing/mask/smokable/cigarette
	name = "cigarette"
	desc = "A small paper cylinder filled with processed tobacco and various fillers."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	attack_verb = list("burnt", "singed")
	type_butt = /obj/item/weapon/cigbutt
	chem_volume = 5
	smoketime = 120
	brand = "\improper Trans-Stellar Duty-free"
	hitsound = 'sound/items/pffsh.ogg'
	var/list/filling = list(/datum/reagent/tobacco = 3)

/obj/item/clothing/mask/smokable/cigarette/New()
	..()
	for(var/R in filling)
		reagents.add_reagent(R, filling[R])

/obj/item/clothing/mask/smokable/cigarette/update_icon()
	..()
	overlays.Cut()
	if(lit)
		overlays += overlay_image(icon, "cigember", flags=RESET_COLOR)

/obj/item/clothing/mask/smokable/cigarette/trident/update_icon()
	..()
	overlays.Cut()
	if(lit)
		overlays += overlay_image(icon, "cigarello-on", flags=RESET_COLOR)

/obj/item/clothing/mask/smokable/cigarette/die(nomessage = FALSE, nodestroy = FALSE)
	..()
	if (type_butt && !nodestroy)
		var/obj/item/butt = new type_butt(get_turf(src))
		transfer_fingerprints_to(butt)
		butt.color = color
		if(brand)
			butt.desc += " This one is \a [brand]."
		if(ismob(loc))
			var/mob/living/M = loc
			if (!nomessage)
				to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
			M.remove_from_mob(src) //un-equip it so the overlays can update
		qdel(src)

/obj/item/clothing/mask/smokable/cigarette/get_temperature_as_from_ignitor()
	if(lit)
		return 1000
	return 0

/obj/item/clothing/mask/smokable/cigarette/menthol
	name = "menthol cigarette"
	desc = "A cigarette with a little minty kick. Well, minty in theory."
	icon_state = "cigmentol"
	brand = "\improper Temperamento Menthol"
	color = "#ddffe8"
	type_butt = /obj/item/weapon/cigbutt/menthol
	filling = list(/datum/reagent/tobacco = 1, /datum/reagent/menthol = 1)

/obj/item/weapon/cigbutt/menthol
	icon_state = "cigbuttmentol"

/obj/item/clothing/mask/smokable/cigarette/luckystars
	brand = "\improper Lucky Star"

/obj/item/clothing/mask/smokable/cigarette/jerichos
	name = "rugged cigarette"
	brand = "\improper Jericho"
	icon_state = "cigjer"
	color = "#dcdcdc"
	type_butt = /obj/item/weapon/cigbutt/jerichos
	filling = list(/datum/reagent/tobacco/bad = 3.5)

/obj/item/weapon/cigbutt/jerichos
	icon_state = "cigbuttjer"

/obj/item/clothing/mask/smokable/cigarette/carcinomas
	name = "dark cigarette"
	brand = "\improper Carcinoma Angel"
	color = "#869286"

/obj/item/clothing/mask/smokable/cigarette/professionals
	name = "thin cigarette"
	brand = "\improper Professional"
	icon_state = "cigpro"
	type_butt = /obj/item/weapon/cigbutt/professionals
	filling = list(/datum/reagent/tobacco/bad = 3)

/obj/item/weapon/cigbutt/professionals
	icon_state = "cigbuttpro"

/obj/item/clothing/mask/smokable/cigarette/killthroat
	brand = "\improper Acme Co. cigarette"

/obj/item/clothing/mask/smokable/cigarette/dromedaryco
	brand = "\improper Dromedary Co. cigarette"

/obj/item/clothing/mask/smokable/cigarette/trident
	name = "wood tip cigar"
	brand = "\improper Trident cigar"
	desc = "A narrow cigar with a wooden tip."
	icon_state = "cigarello"
	item_state = "cigaroff"
	smoketime = 480
	chem_volume = 10
	type_butt = /obj/item/weapon/cigbutt/woodbutt
	filling = list(/datum/reagent/tobacco/fine = 6)

/obj/item/clothing/mask/smokable/cigarette/trident/mint
	icon_state = "cigarelloMi"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/menthol = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/berry
	icon_state = "cigarelloBe"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/berry = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/cherry
	icon_state = "cigarelloCh"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/nutriment/cherryjelly = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/grape
	icon_state = "cigarelloGr"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/grape = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/watermelon
	icon_state = "cigarelloWm"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/watermelon = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/orange
	icon_state = "cigarelloOr"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/orange = 2)

/obj/item/weapon/cigbutt/woodbutt
	name = "wooden tip"
	desc = "A wooden mouthpiece from a cigar. Smells rather bad."
	icon_state = "woodbutt"
	matter = list(MATERIAL_WOOD = 1)

/obj/item/clothing/mask/smokable/cigarette/can_be_lit_with(obj/W)
	if(istype(W, /obj/item/weapon/gun) && !istype(W, /obj/item/weapon/gun/flamer) && !istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		var/obj/item/weapon/gun/gun = W
		return gun.combustion && gun.loc == src.loc
	if(istype(W, /obj/machinery/cooker/grill))
		var/obj/machinery/cooker/grill/grill = W
		return !(grill.stat & (NOPOWER|BROKEN))
	if(istype(W, /obj/machinery/light))
		var/obj/machinery/light/mounted = W
		var/obj/item/weapon/light/bulb = mounted.lightbulb
		return bulb && istype(bulb, /obj/item/weapon/light/bulb) && bulb.status == 2 && !(mounted.stat & BROKEN)
	return ..()

/obj/item/clothing/mask/smokable/cigarette/generate_lighting_message(atom/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()

	if(istype(tool, /obj/item/weapon/flame/lighter))
		if(istype(tool, /obj/item/weapon/flame/lighter/zippo))
			return SPAN("rose", "With a flick of the wrist, [holder] lights \his [name] with \a [tool].")
		else
			return SPAN_NOTICE("[holder] manages to light \his [name] with \a [tool].")
	if(istype(tool, /obj/item/weapon/flame/candle))
		return SPAN_NOTICE("[holder] carefully lights \his [name] with \a [tool].")
	if(istype(tool, /obj/item/weapon/weldingtool))
		return SPAN_NOTICE("[holder] casually lights \his [name] with \a [tool].")
	if(istype(tool, /obj/item/device/assembly/igniter))
		return SPAN_NOTICE("[holder] fiddles with \his [tool.name], and manages to light \a [name].")
	if(istype(tool, /obj/item/weapon/reagent_containers/glass/rag))
		return SPAN_NOTICE("[holder] somehow manages to light \his [name] with \a [tool].")
	if(istype(tool, /obj/item/jackolantern))
		return SPAN_NOTICE("[holder] shoves \his [name] into \a [tool] to light it up.")
	if(istype(tool, /obj/item/weapon/melee/energy))
		return SPAN_WARNING("[holder] swings \his [tool.name], and light \a [name] in the process.")
	if(istype(tool, /obj/item/weapon/gun))
		if(istype(tool, /obj/item/weapon/gun/flamer))
			return SPAN_WARNING("[holder] fearlessly lights \his [name] with the twinkling flare of \the lit [tool].")
		else if(istype(tool, /obj/item/weapon/gun/energy/plasmacutter))
			return SPAN_NOTICE("[holder] touches \his [tool.name] with \a [name] to light it up.")
		else
			return SPAN_DANGER("[holder] fired \his [tool.name] into the air, lighting \a [name] in the process!")
	if(istype(tool, /spell/targeted/projectile/dumbfire/fireball))
		return SPAN_NOTICE("Roaring fireball lits \a [name] in the mouth of [holder]!")
	if(istype(tool, /obj/machinery/light))
		return SPAN_NOTICE("[holder] cleverly lights \his [name] by a red-hot incandescent spiral inside the broken lightbulb.")
	if(isliving(tool))
		return SPAN_NOTICE("[holder] coldly lights \his [name] with the burning body of [tool].")

	return ..()

/obj/item/clothing/mask/smokable/cigarette/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wirecutters))
		user.visible_message(SPAN_NOTICE("[user] cut the tip of \his [name] with [W]."), "You cut the tip of your [name]")
		smoketime -= 10
		if(smoketime <= 0)
			die()
		else
			die(nodestroy = TRUE)
		return
	
	if(istype(W, /obj/item/weapon/gun) && !istype(W, /obj/item/weapon/gun/energy/plasmacutter) && !istype(W, /obj/item/weapon/gun/flamer))
		if(!lit && can_be_lit_with(W))
			var/obj/item/weapon/gun/gun = W
			if(gun.special_check(user))
				var/obj/P = gun.consume_next_projectile()
				if(P)
					gun.play_fire_sound(user, P)
					gun.handle_post_fire(user, src, TRUE)

					var/oops_chance = 25 // %
					if(isliving(user))
						var/mob/living/L = user
						for(var/datum/modifier/trait/inaccurate/M in L.modifiers)
							oops_chance = max(0, oops_chance - 2 * M.accuracy)
					if(ishuman(user))
						var/mob/living/carbon/human/H = user
						oops_chance = max(0, oops_chance - 10 * H.skills["weapons"])
					
					var/fuck_up_chance = ceil(oops_chance / 8)
					var/roll = rand(99) + 1
					if(roll < fuck_up_chance)
						if(gun.process_projectile(P, user, user, BP_HEAD))
							user.visible_message(SPAN_DANGER("[user] shot \himself in the face with \the [gun].")) // Oops
						return
					else if(roll < oops_chance && istype(gun, /obj/item/weapon/gun/projectile) && isliving(user))
						var/mob/living/L = user
						to_chat(user, SPAN_WARNING("You burned your face a little."))
						L.apply_damage(5, BURN, BP_HEAD, used_weapon = gun)	
					light(W, user)
				else
					gun.handle_click_empty(user)
					return
			else
				return
		else
			..()
	else
		..()

/obj/item/clothing/mask/smokable/cigarette/attack(mob/living/M, mob/user, def_zone)
	if(lit && M == user && istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/blocked = H.check_mouth_coverage()
		if(blocked)
			to_chat(H, SPAN_WARNING("\The [blocked] is in the way!"))
			return 1
		to_chat(H, SPAN_NOTICE("You take a drag on your [name]."))
		smoke(5)
		return 1
	if(!lit && istype(M) && M.on_fire)
		user.do_attack_animation(M)
		light(M, user)
		return 1
	return ..()

/obj/item/clothing/mask/smokable/cigarette/afterattack(obj/item/W, mob/user as mob, proximity)
	if(istype(W, /obj/item/weapon/gun) && !istype(W, /obj/item/weapon/gun/energy/plasmacutter) && !istype(W, /obj/item/weapon/gun/flamer))
		return
	
	..()
	
	if(istype(W, /obj/item/weapon/reagent_containers/glass) && !istype(W, /obj/item/weapon/reagent_containers/glass/rag)) //you can dip cigarettes into beakers
		var/obj/item/weapon/reagent_containers/glass/glass = W
		if(!glass.is_open_container())
			to_chat(user, "<span class='notice'>You need to take the lid off first.</span>")
			return
		var/transfered = glass.reagents.trans_to_obj(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
				return
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")
		die(nomessage = FALSE, nodestroy = TRUE)

/obj/item/clothing/mask/smokable/cigarette/attack_self(mob/user as mob)
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		die(nomessage = TRUE, nodestroy = FALSE)
	return ..()

/obj/item/clothing/mask/smokable/cigarette/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	. = ..()
	if(lit)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.a_intent == I_HELP)
				return
		die()

/obj/item/clothing/mask/smokable/cigarette/get_icon_state(slot)
	return item_state

/obj/item/clothing/mask/smokable/cigarette/get_mob_overlay(mob/user_mob, slot)
	var/image/res = ..()
	if(lit == 1)
		var/image/ember = overlay_image(res.icon, "cigember", flags=RESET_COLOR)
		ember.layer = ABOVE_LIGHTING_LAYER
		ember.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		res.overlays += ember
	return res

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/smokable/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	type_butt = /obj/item/weapon/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1200
	chem_volume = 22.5
	filling = list(/datum/reagent/tobacco/fine = 15)

/obj/item/clothing/mask/smokable/cigarette/cigar/generate_lighting_message(obj/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()
	
	if(istype(tool, /obj/item/weapon/flame/lighter) && !istype(tool, /obj/item/weapon/flame/lighter/zippo))
		return SPAN_NOTICE("[holder] manages to offend \his [name] by lighting it with \a [tool].")
	if(istype(tool, /obj/item/weapon/flame/candle))
		return SPAN_NOTICE("[holder] carefully lights \his [name] with \a classic [tool].")
	if(istype(tool, /obj/item/weapon/weldingtool))
		return SPAN_NOTICE("[holder] insults \his [name] by lighting it with \a [tool].")
	if(istype(tool, /obj/item/device/assembly/igniter))
		return SPAN_NOTICE("[holder] fiddles with \his [tool.name], and manages to light \a [name] with the power of science.")
	if(istype(tool, /obj/item/weapon/reagent_containers/glass/rag))
		return SPAN_NOTICE("[holder] somehow manages to light \his [name] with \a [tool]. What a clown!")
	return ..()

/obj/item/clothing/mask/smokable/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"

/obj/item/clothing/mask/smokable/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	smoketime = 3000
	chem_volume = 30
	filling = list(/datum/reagent/tobacco/fine = 20)

/obj/item/weapon/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	randpixel = 10
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	throwforce = 1

/obj/item/weapon/cigbutt/New()
	..()
	transform = turn(transform,rand(0,360))

/obj/item/weapon/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/obj/item/clothing/mask/smokable/cigarette/cigar/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/smokable/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	w_class = ITEM_SIZE_TINY
	icon_on = "pipeon"  //Note - these are in masks.dmi
	smoketime = 0
	chem_volume = 50

/obj/item/clothing/mask/smokable/pipe/New()
	..()
	name = "empty [initial(name)]"

/obj/item/clothing/mask/smokable/pipe/smoke(amount)
	smoketime -= amount
	if(reagents && reagents.total_volume) // check if it has any reagents at all
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			if (src == C.wear_mask && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.trans_to_mob(C, REM, CHEM_BLOOD, 0.9) // You waste some stuff, but not so much.
			else // else just remove some of the reagents
				reagents.remove_any(REM)

/obj/item/clothing/mask/smokable/pipe/light(obj/used_tool, mob/holder)
	if(!src.lit && src.smoketime)
		src.lit = 1
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		var/turf/T = get_turf(src)
		T.visible_message(generate_lighting_message(used_tool, holder))
		START_PROCESSING(SSobj, src)
		if(ismob(loc))
			var/mob/living/M = loc
			M.update_inv_wear_mask(0)
			M.update_inv_l_hand(0)
			M.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/pipe/die(nomessage = FALSE)
	..()
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	if(ismob(loc))
		var/mob/living/M = loc
		if (!nomessage)
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")

/obj/item/clothing/mask/smokable/pipe/attack_self(mob/user as mob)
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>", "<span class='notice'>You put out [src].</span>")
		lit = 0
		update_icon()
		STOP_PROCESSING(SSobj, src)
	else if (smoketime)
		var/turf/location = get_turf(user)
		user.visible_message("<span class='notice'>[user] empties out [src].</span>", "<span class='notice'>You empty out [src].</span>")
		new /obj/effect/decal/cleanable/ash(location)
		smoketime = 0
		reagents.clear_reagents()
		SetName("empty [initial(name)]")

/obj/item/clothing/mask/smokable/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = W
		if (!G.dry)
			to_chat(user, "<span class='notice'>[G] must be dried before you stuff it into [src].</span>")
			return
		if (smoketime)
			to_chat(user, "<span class='notice'>[src] is already packed.</span>")
			return
		smoketime = 180
		if(G.reagents)
			G.reagents.trans_to_obj(src, G.reagents.total_volume)
		SetName("[G.name]-packed [initial(name)]")
		qdel(G)

	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/pipe/can_be_lit_with(obj/W)
	for(var/ignitor_type in list(/obj/item/weapon/flame/lighter, /obj/item/weapon/flame/lighter/zippo, /obj/item/weapon/weldingtool, /obj/item/device/assembly/igniter, /obj/item/weapon/flame/candle, /obj/item/clothing/mask/smokable/cigarette, /obj/item/weapon/reagent_containers/glass/rag))
		if(istype(W.type, ignitor_type))
			return ..()
	
	if(istype(W, /obj/machinery/light))
		var/obj/machinery/light/mounted = W
		var/obj/item/weapon/light/bulb = mounted.lightbulb
		return bulb && istype(bulb, /obj/item/weapon/light/bulb) && bulb.status == 2 && mounted.on
	return FALSE

/obj/item/clothing/mask/smokable/pipe/generate_lighting_message(obj/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()
	
	if(istype(tool, /obj/item/weapon/flame/lighter/zippo))
		return SPAN("rose", "With much care, [holder] lights \his [name] with \a [tool].")
	if(istype(tool, /obj/item/weapon/flame/candle))
		return SPAN_NOTICE("[holder] lights \his [name] with a hot wax from \a [tool].")
	if(istype(tool, /obj/item/weapon/weldingtool))
		return SPAN_NOTICE("[holder] recklessly \his [name] with \a [tool].")
	if(istype(tool, /obj/item/weapon/reagent_containers/glass/rag))
		return SPAN_WARNING("[holder] puts a piece of \a [tool] into \a [name] to light it up.")
	if(istype(tool, /obj/item/clothing/mask/smokable/cigarette))
		return SPAN_NOTICE("[holder] dips \his [tool.name] into \a [name] to light it up.")
	if(istype(tool, /obj/machinery/light))
		return SPAN_NOTICE("[holder] cleverly lights \his [name] by a red-hot incandescent spiral inside the broken lightbulb.")
	
	return ..()

/obj/item/clothing/mask/smokable/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen, kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	chem_volume = 35

/////////
//ZIPPO//
/////////
/obj/item/weapon/flame/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = ITEM_SIZE_TINY
	throwforce = 4
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	attack_verb = list("burnt", "singed")
	var/max_fuel = 5

/obj/item/weapon/flame/lighter/New()
	..()
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	set_extension(src, /datum/extension/base_icon_state, /datum/extension/base_icon_state, icon_state)
	update_icon()

/obj/item/weapon/flame/lighter/proc/light(mob/user)
	lit = 1
	update_icon()
	light_effects(user)
	set_light(2)
	START_PROCESSING(SSobj, src)

/obj/item/weapon/flame/lighter/proc/light_effects(mob/living/carbon/user)
	if(prob(95))
		user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src].</span>")
	else
		to_chat(user, "<span class='warning'>You burn yourself while lighting the lighter.</span>")
		if (user.l_hand == src)
			user.apply_damage(2,BURN,BP_L_HAND)
		else
			user.apply_damage(2,BURN,BP_R_HAND)
		user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src], they however burn their finger in the process.</span>")
	playsound(src.loc, "light_bic", 100, 1, -4)

/obj/item/weapon/flame/lighter/proc/shutoff(mob/user)
	lit = 0
	update_icon()
	if(user)
		shutoff_effects(user)
	else
		visible_message("<span class='notice'>[src] goes out.</span>")
	set_light(0)
	STOP_PROCESSING(SSobj, src)

/obj/item/weapon/flame/lighter/proc/shutoff_effects(mob/user)
	user.visible_message("<span class='notice'>[user] quietly shuts off the [src].</span>")

/obj/item/weapon/flame/lighter/get_temperature_as_from_ignitor()
	if(lit)
		return 1500
	return 0

/obj/item/weapon/flame/lighter/zippo
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	max_fuel = 10

/obj/item/weapon/flame/lighter/zippo/light_effects(mob/user)
	user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
	playsound(src.loc, 'sound/items/zippo_open.ogg', 100, 1, -4)

/obj/item/weapon/flame/lighter/zippo/shutoff_effects(mob/user)
	user.visible_message("<span class='rose'>You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing.</span>")
	playsound(src.loc, 'sound/items/zippo_close.ogg', 100, 1, -4)

/obj/item/weapon/flame/lighter/zippo/afterattack(obj/O, mob/user, proximity)
	if(!proximity) return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && !lit)
		O.reagents.trans_to_obj(src, max_fuel)
		to_chat(user, "<span class='notice'>You refuel [src] from \the [O]</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)

/obj/item/weapon/flame/lighter/random/New()
	icon_state = "lighter-[pick("r","c","y","g")]"
	item_state = icon_state
	..()

/obj/item/weapon/flame/lighter/attack_self(mob/living/user)
	if(!lit)
		if(reagents.has_reagent(/datum/reagent/fuel))
			light(user)
		else
			to_chat(user, "<span class='warning'>[src] won't ignite - out of fuel.</span>")
	else
		shutoff(user)

/obj/item/weapon/flame/lighter/update_icon()
	var/datum/extension/base_icon_state/bis = get_extension(src, /datum/extension/base_icon_state)

	if(lit)
		icon_state = "[bis.base_icon_state]on"
		item_state = "[bis.base_icon_state]on"
	else
		icon_state = "[bis.base_icon_state]"
		item_state = "[bis.base_icon_state]"

/obj/item/weapon/flame/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if(lit)
		M.IgniteMob()

		if(istype(M.wear_mask, /obj/item/clothing/mask/smokable/cigarette) && user.zone_sel.selecting == BP_MOUTH)
			var/obj/item/clothing/mask/smokable/cigarette/cig = M.wear_mask
			if(M == user)
				cig.attackby(src, user)
			else
				if(istype(src, /obj/item/weapon/flame/lighter/zippo))
					visible_message(SPAN("rose", "[user] whips the [name] out and holds it for [M]."))
				else
					visible_message(SPAN_NOTICE("[user] holds the [name] out for [M], and lights the [cig.name]."))
				cig.light(src, user)
			return

	..()

/obj/item/weapon/flame/lighter/Process()
	if(reagents.has_reagent(/datum/reagent/fuel))
		if(ismob(loc) && prob(10) && reagents.get_reagent_amount(/datum/reagent/fuel) < 1)
			to_chat(loc, "<span class='warning'>[src]'s flame flickers.</span>")
			set_light(0)
			spawn(4)
				set_light(2)
		reagents.remove_reagent(/datum/reagent/fuel, 0.05)
	else
		shutoff()
		return

	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)

//////////////
//  SPLIFF  //
//////////////

/obj/item/clothing/mask/smokable/cigarette/spliff
	name = "spliff"
	desc = "What makes me happy? A big spliff!"
	icon_state = "spliffoff"
	item_state = "spliffoff"
	icon_on = "spliffon"
	type_butt = /obj/item/weapon/cigbutt/spliffbutt
	throw_speed = 0.5
	smoketime = 120
	chem_volume = 15
	filling = list(/datum/reagent/thc = 12)

/obj/item/clothing/mask/smokable/cigarette/spliff/smoke(amount)
	smoketime -= amount
	if(reagents && reagents.total_volume) // check if it has any reagents at all
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			if (src == C.wear_mask && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.trans_to_mob(C, REM, CHEM_BLOOD, 1) // Smoke it all, b1tch!
			else // else just remove some of the reagents
				reagents.remove_any(REM)

/obj/item/clothing/mask/smokable/cigarette/spliff/generate_lighting_message(obj/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()
	
	if(istype(tool, /obj/item/weapon/weldingtool))
		return SPAN_NOTICE("[holder] looks like a real stoner after lighting \his [name] with \a [tool].")
	return ..()

/obj/item/weapon/cigbutt/spliffbutt
	name = "spliff butt"
	desc = "Still contains some burnt weed inside."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	randpixel = 10
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	throwforce = 1

/obj/item/weapon/cigbutt/New()
	..()
	transform = turn(transform,rand(0,360))
