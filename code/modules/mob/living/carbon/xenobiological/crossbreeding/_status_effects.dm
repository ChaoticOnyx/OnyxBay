/atom/movable/screen/alert/status_effect/rainbow_protection
	name = "Rainbow Protection"
	desc = "You are defended from harm, but so are those you might seek to injure!"
	icon_state = "metroid_rainbowshield"

/datum/modifier/status_effect
	var/duration = 0
	var/alert_type = null

/datum/modifier/status_effect/New(new_holder, new_origin)
	if(duration)
		expire_at = world.time + duration
	holder.throw_alert("\ref[src]",alert_type)

/datum/modifier/status_effect/rainbow_protection
	name = "rainbow_protection"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/rainbow_protection
	var/originalcolor

/datum/modifier/status_effect/rainbow_protection/on_applied()
	holder.status_flags |= GODMODE
	ADD_TRAIT(holder, TRAIT_PACIFISM)
	holder.visible_message(SPAN_WARNING("[holder] shines with a brilliant rainbow light."),
		SPAN_NOTICE("You feel protected by an unknown force!"))
	originalcolor = holder.color
	return ..()

/datum/modifier/status_effect/rainbow_protection/tick()
	holder.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	return ..()

/datum/modifier/status_effect/rainbow_protection/on_expire()
	holder.status_flags &= ~GODMODE
	holder.color = originalcolor
	REMOVE_TRAIT(holder, TRAIT_PACIFISM)
	holder.visible_message(SPAN_NOTICE("[holder] stops glowing, the rainbow light fading away."),
		SPAN_WARNING("You no longer feel protected..."))

/atom/movable/screen/alert/status_effect/metroidskin
	name = "Adamantine metroidskin"
	desc = "You are covered in a thick, non-neutonian gel."
	icon_state = "metroid_stoneskin"

/datum/modifier/status_effect/metroidskin
	name = "metroidskin"
	duration = 300
	alert_type = /atom/movable/screen/alert/status_effect/metroidskin
	var/originalcolor

/datum/modifier/status_effect/metroidskin/on_applied()
	originalcolor = holder.color
	holder.color = "#3070CC"
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
	holder.visible_message(SPAN_WARNING("[holder] is suddenly covered in a strange, blue-ish gel!"),
		SPAN_NOTICE("You are covered in a thick, rubbery gel."))
	return ..()

/datum/modifier/status_effect/metroidskin/on_expire()
	holder.color = originalcolor
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
	holder.visible_message(SPAN_WARNING("[holder]'s gel coating liquefies and dissolves away."),
		SPAN_NOTICE("Your gel second-skin dissolves!"))

/datum/modifier/status_effect/metroidrecall
	name = "metroid_recall"
	duration = 0 //Will be removed by the extract.

	var/interrupted = FALSE
	var/mob/target
	var/icon/bluespace

/datum/modifier/status_effect/metroidrecall/on_applied()
	register_signal(holder, SIGNAL_MOB_RESIST, .proc/resistField)
	to_chat(holder, SPAN_DANGER("You feel a sudden tug from an unknown force, and feel a pull to bluespace!"))
	to_chat(holder, SPAN_NOTICE("Resist if you wish avoid the force!"))
	bluespace = icon('icons/effects/effects.dmi',"chronofield")
	holder.overlays += bluespace
	return ..()

/datum/modifier/status_effect/metroidrecall/proc/resistField()
	interrupted = TRUE
	holder.remove_specific_modifier(src)

/datum/modifier/status_effect/metroidrecall/on_expire()
	unregister_signal(holder, SIGNAL_MOB_RESIST)
	holder.cut_overlay(bluespace)
	if(interrupted || !ismob(target))
		to_chat(holder, SPAN_WARNING("The bluespace tug fades away, and you feel that the force has passed you by."))
		return
	var/turf/old_location = get_turf(holder)
	if(do_teleport(holder, target.loc))
		old_location.visible_message(SPAN_WARNING("[holder] disappears in a flurry of sparks!"))
		to_chat(holder, SPAN_WARNING("The unknown force snatches briefly you from reality, and deposits you next to [target]!"))

/atom/movable/screen/alert/status_effect/freon/stasis
	desc = "You're frozen inside of a protective ice cube! While inside, you can't do anything, but are immune to harm! Resist to get out."

/datum/modifier/status_effect/frozenstasis
	name = "metroid_frozen"
	var/obj/structure/ice_stasis/cube
	alert_type = /atom/movable/screen/alert/status_effect/freon/stasis

/datum/modifier/status_effect/frozenstasis/on_applied()
	holder.throw_alert("\ref[holder]_frozenstasis", /obj/screen/movable/alert/clone_decay)
	register_signal(holder, SIGNAL_MOB_RESIST, .proc/breakCube)
	cube = new /obj/structure/ice_stasis(get_turf(holder))
	holder.forceMove(cube)
	holder.status_flags |= GODMODE

/datum/modifier/status_effect/frozenstasis/tick()
	if(!cube || holder.loc != cube)
		holder.remove_specific_modifier(src)

/datum/modifier/status_effect/frozenstasis/proc/breakCube()
	holder.remove_specific_modifier(src)

/datum/modifier/status_effect/frozenstasis/on_expire()
	if(cube)
		qdel(cube)
	holder.status_flags &= ~GODMODE

	unregister_signal(holder, SIGNAL_MOB_RESIST)

/datum/modifier/status_effect/metroid_clone/on_applied()
	var/typepath = holder.type
	clone = new typepath(holder.loc)
	var/mob/living/carbon/O = holder
	var/mob/living/carbon/C = clone
	if(istype(C) && istype(O))
		C.real_name = O.real_name
		C.setDNA(O.getDNA())

	if(holder.mind)
		originalmind = holder.mind
		holder.mind.transfer_to(clone)
	clone.add_modifier(/datum/modifier/status_effect/metroid_clone_decay)
	return ..()

/datum/modifier/status_effect/metroid_clone/tick()
	if(!istype(clone) || clone.stat != CONSCIOUS)
		holder.remove_specific_modifier(src)

/datum/modifier/status_effect/metroid_clone/on_expire()
	if(clone?.mind && holder)
		clone.mind.transfer_to(holder)
	else
		if(holder && originalmind)
			originalmind.transfer_to(holder)
			if(originalmind.key)
				holder.ckey = originalmind.key
	if(clone)
		for(var/obj/item/I in clone.get_equipped_items())
			clone.drop(I, force = TRUE)
		qdel(clone)

/datum/modifier/status_effect/metroid_clone_decay
	name = "metroid_clonedecay"

/datum/modifier/status_effect/metroid_clone_decay/on_applied()
	holder.throw_alert("\ref[holder]_clone_decay", /obj/screen/movable/alert/clone_decay)

/datum/modifier/status_effect/metroid_clone_decay/tick()
	holder.adjustToxLoss(1)
	holder.adjustOxyLoss(1)
	holder.adjustBruteLoss(1)
	holder.adjustFireLoss(1)
	holder.color = "#007BA7"

/obj/screen/movable/alert/clone_decay
	name = "Clone Decay"
	desc = "You are simply a construct, and cannot maintain this form forever. You will be returned to your original body if you should fall."
	icon_state = "metroid_clonedecay"

/atom/movable/screen/alert/status_effect/bloodchill
	name = "Bloodchilled"
	desc = "You feel a shiver down your spine after getting hit with a glob of cold blood. You'll move slower and get frostbite for a while!"
	icon_state = "bloodchill"

/datum/modifier/status_effect/bloodchill
	name = "bloodchill"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/bloodchill

/datum/modifier/status_effect/bloodchill/on_applied()
	holder.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/bloodchill)
	return ..()

/datum/modifier/status_effect/bloodchill/tick()
	if(prob(50))
		holder.adjustFireLoss(2)

/datum/modifier/status_effect/bloodchill/on_expire()
	holder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/bloodchill)

/datum/modifier/status_effect/bonechill
	name = "bonechill"
	duration = 80
	alert_type = /atom/movable/screen/alert/status_effect/bonechill

/datum/modifier/status_effect/bonechill/on_applied()
	holder.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/bonechill)
	return ..()

/datum/modifier/status_effect/bonechill/tick()
	if(prob(50))
		holder.adjustFireLoss(1)
		holder.set_jitter_if_lower(6 SECONDS)
		holder.adjust_bodytemperature(-10)
		if(ishuman(holder))
			var/mob/living/carbon/human/humi = holder
			humi.adjust_coretemperature(-10)

/datum/modifier/status_effect/bonechill/on_expire()
	holder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/bonechill)
/atom/movable/screen/alert/status_effect/bonechill
	name = "Bonechilled"
	desc = "You feel a shiver down your spine after hearing the haunting noise of bone rattling. You'll move slower and get frostbite for a while!"
	icon_state = "bloodchill"

/datum/modifier/status_effect/rebreathing
	name = "rebreathing"
	duration = 0


/datum/modifier/status_effect/rebreathing/tick()
	holder.adjustOxyLoss(-6, 0) //Just a bit more than normal breathing.

///////////////////////////////////////////////////////
//////////////////CONSUMING EXTRACTS///////////////////
///////////////////////////////////////////////////////

/datum/modifier/status_effect/firecookie
	name = "firecookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/firecookie/on_applied()
	ADD_TRAIT(holder, TRAIT_RESISTCOLD)
	holder.adjust_bodytemperature(110)
	return ..()

/datum/modifier/status_effect/firecookie/on_expire()
	REMOVE_TRAIT(holder, TRAIT_RESISTCOLD)

/datum/modifier/status_effect/watercookie
	name = "watercookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/watercookie/on_applied()
	ADD_TRAIT(holder, TRAIT_NOSLIPWATER)
	return ..()

/datum/modifier/status_effect/watercookie/tick()
	for(var/turf/open/T in range(get_turf(holder),1))
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)

/datum/modifier/status_effect/watercookie/on_expire()
	REMOVE_TRAIT(holder, TRAIT_NOSLIPWATER)

/datum/modifier/status_effect/metalcookie
	name = "metalcookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/metalcookie/on_applied()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.brute_mod *= 0.9
	return ..()

/datum/modifier/status_effect/metalcookie/on_expire()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.brute_mod /= 0.9

/datum/modifier/status_effect/sparkcookie
	name = "sparkcookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 300
	var/original_coeff

/datum/modifier/status_effect/sparkcookie/on_applied()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		original_coeff = H.physiology.siemens_coeff
		H.physiology.siemens_coeff = 0
	return ..()

/datum/modifier/status_effect/sparkcookie/on_expire()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.siemens_coeff = original_coeff

/datum/modifier/status_effect/toxincookie
	name = "toxincookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 600

/datum/modifier/status_effect/toxincookie/on_applied()
	ADD_TRAIT(holder, TRAIT_TOXINLOVER)
	return ..()

/datum/modifier/status_effect/toxincookie/on_expire()
	REMOVE_TRAIT(holder, TRAIT_TOXINLOVER)

/datum/modifier/status_effect/timecookie
	name = "timecookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 600

/datum/modifier/status_effect/timecookie/on_applied()
	holder.add_actionspeed_modifier(/datum/actionspeed_modifier/timecookie)
	return ..()

/datum/modifier/status_effect/timecookie/on_expire()
	holder.remove_actionspeed_modifier(/datum/actionspeed_modifier/timecookie)
	return ..()

/datum/modifier/status_effect/lovecookie
	name = "lovecookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 300

/datum/modifier/status_effect/lovecookie/tick()
	if(holder.stat != CONSCIOUS)
		return
	if(iscarbon(holder))
		var/mob/living/carbon/C = holder
		if(C.handcuffed)
			return
	var/list/huggables = list()
	for(var/mob/living/carbon/L in range(get_turf(holder),1))
		if(L != holder)
			huggables += L
	if(length(huggables))
		var/mob/living/carbon/hugged = pick(huggables)
		holder.visible_message(SPAN_NOTICE("[holder] hugs [hugged]!"), SPAN_NOTICE("You hug [hugged]!"))

/datum/modifier/status_effect/tarcookie
	name = "tarcookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/tarcookie/tick()
	for(var/mob/living/carbon/human/L in range(get_turf(holder),1))
		if(L != holder)
			L.apply_status_effect(/datum/modifier/status_effect/tarfoot)

/datum/modifier/status_effect/tarfoot
	name = "tarfoot"
	status_type = MODIFIER_STACK_EXTEND

	duration = 30

/datum/modifier/status_effect/tarfoot/on_applied()
	holder.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/tarfoot)
	return ..()

/datum/modifier/status_effect/tarfoot/on_expire()
	holder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/tarfoot)

/datum/modifier/status_effect/spookcookie
	name = "spookcookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 300

/datum/modifier/status_effect/spookcookie/on_applied()
	var/image/I = image(icon = 'icons/mob/simple/simple_human.dmi', icon_state = "skeleton", layer = ABOVE_MOB_LAYER, loc = holder)
	I.override = 1
	holder.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "spookyscary", I)
	return ..()

/datum/modifier/status_effect/spookcookie/on_expire()
	holder.remove_alt_appearance("spookyscary")

/datum/modifier/status_effect/peacecookie
	name = "peacecookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/peacecookie/tick()
	for(var/mob/living/L in range(get_turf(holder),1))
		L.apply_status_effect(/datum/modifier/status_effect/plur)

/datum/modifier/status_effect/plur
	name = "plur"
	status_type = MODIFIER_STACK_EXTEND

	duration = 30

/datum/modifier/status_effect/plur/on_applied()
	ADD_TRAIT(holder, TRAIT_PACIFISM)
	return ..()

/datum/modifier/status_effect/plur/on_expire()
	REMOVE_TRAIT(holder, TRAIT_PACIFISM)

/datum/modifier/status_effect/adamantinecookie
	name = "adamantinecookie"
	status_type = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/adamantinecookie/on_applied()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.burn_mod *= 0.9
	return ..()

/datum/modifier/status_effect/adamantinecookie/on_expire()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.burn_mod /= 0.9


///////////////////////////////////////////////////////
//////////////////STABILIZED EXTRACTS//////////////////
///////////////////////////////////////////////////////

/datum/modifier/status_effect/stabilized //The base stabilized extract effect, has no effect of its' own.
	name = "stabilizedbase"
	var/
	var/obj/item/metroidcross/stabilized/linked_extract
	var/colour = "null"

/datum/modifier/status_effect/stabilized/proc/location_check()
	if(linked_extract.loc == holder)
		return TRUE
	if(linked_extract.loc.loc == holder)
		return TRUE

	return FALSE

/datum/modifier/status_effect/stabilized/think()
	if(!linked_extract || !linked_extract.loc) //Sanity checking
		holder.remove_specific_modifier(src)
		return
	if(linked_extract && !location_check())
		linked_extract.linked_effect = null
		if(!QDELETED(linked_extract))
			linked_extract.holder = null
			linked_extract.set_next_think(world.time + 1 SECOND)
		holder.remove_specific_modifier(src)
	return ..()

/datum/modifier/status_effect/stabilized/null //This shouldn't ever happen, but just in case.
	name = "stabilizednull"


//Stabilized effects start below.
/datum/modifier/status_effect/stabilized/grey
	name = "stabilizedgrey"
	colour = "grey"

/datum/modifier/status_effect/stabilized/grey/think()
	for(var/mob/living/carbon/metroid/S in range(1, get_turf(holder)))
		if(!(holder in S.Friends))
			to_chat(holder, SPAN_NOTICE("[linked_extract] pulses gently as it communicates with [S]."))
			S.Friends += holder
	return ..()

/datum/modifier/status_effect/stabilized/orange
	name = "stabilizedorange"
	colour = "orange"

/datum/modifier/status_effect/stabilized/orange/think()
	var/body_temperature_difference = holder.get_species().body_temperature - holder.bodytemperature
	holder.bodytemperature += body_temperature_difference<0?(max(-5, body_temperature_difference)):(min(5, body_temperature_difference))
	return ..()

/datum/modifier/status_effect/stabilized/purple
	name = "stabilizedpurple"
	colour = "purple"
	/// Whether we healed from our last tick
	var/healed_last_tick = FALSE

/datum/modifier/status_effect/stabilized/purple/think()
	healed_last_tick = FALSE

	if(holder.getBruteLoss() > 0)
		holder.adjustBruteLoss(-0.2)
		healed_last_tick = TRUE

	if(holder.getFireLoss() > 0)
		holder.adjustFireLoss(-0.2)
		healed_last_tick = TRUE

	if(holder.getToxLoss() > 0)
		// Forced, so metroidpeople are healed as well.
		holder.adjustToxLoss(-0.2)
		healed_last_tick = TRUE

	// Technically, "healed this tick" by now.
	if(healed_last_tick)
		new /obj/effect/temp_visual/heal(get_turf(holder), "#FF0000")

	return ..()

/datum/modifier/status_effect/stabilized/purple/get_examine_text()
	if(healed_last_tick)
		return SPAN_WARNING("[holder] [holder.p_are()] regenerating slowly, purplish goo filling in small injuries!")

	return null

/datum/modifier/status_effect/stabilized/blue
	name = "stabilizedblue"
	colour = "blue"

/datum/modifier/status_effect/stabilized/blue/on_applied()
	ADD_TRAIT(holder, TRAIT_NOSLIPWATER)
	return ..()

/datum/modifier/status_effect/stabilized/blue/on_expire()
	REMOVE_TRAIT(holder, TRAIT_NOSLIPWATER)

/datum/modifier/status_effect/stabilized/metal
	name = "stabilizedmetal"
	colour = "metal"
	var/cooldown = 30
	var/max_cooldown = 30

/datum/modifier/status_effect/stabilized/metal/think()
	if(cooldown > 0)
		cooldown--
	else
		cooldown = max_cooldown
		var/list/sheets = list()
		for(var/obj/item/stack/sheet/S in holder.get_all_contents())
			if(S.amount < S.max_amount)
				sheets += S

		if(sheets.len > 0)
			var/obj/item/stack/sheet/S = pick(sheets)
			S.amount++
			S.update_custom_materials()
			to_chat(holder, SPAN_NOTICE("[linked_extract] adds a layer of metroid to [S], which metamorphosizes into another sheet of material!"))
	return ..()


/datum/modifier/status_effect/stabilized/yellow
	name = "stabilizedyellow"
	colour = "yellow"
	var/cooldown = 10
	var/max_cooldown = 10

/datum/modifier/status_effect/stabilized/yellow/get_examine_text()
	return SPAN_WARNING("Nearby electronics seem just a little more charged wherever [holder] go[holder].")

/datum/modifier/status_effect/stabilized/yellow/think()
	if(cooldown > 0)
		cooldown--
		return ..()
	cooldown = max_cooldown
	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in holder.get_all_contents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge += min(ToCharge.maxcharge - ToCharge.charge, ToCharge.maxcharge/10) //10% of the cell, or to maximum.
		to_chat(holder, SPAN_NOTICE("[linked_extract] discharges some energy into a device you have."))
	return ..()

/obj/item/hothands
	name = "burning fingertips"
	desc = "You shouldn't see this."

/obj/item/hothands/get_temperature()
	return 290 //Below what's required to ignite plasma.

/datum/modifier/status_effect/stabilized/darkpurple
	name = "stabilizeddarkpurple"
	colour = "dark purple"
	var/obj/item/hothands/fire

/datum/modifier/status_effect/stabilized/darkpurple/on_applied()
	ADD_TRAIT(holder, TRAIT_RESISTHEATHANDS)
	fire = new(holder)
	return ..()

/datum/modifier/status_effect/stabilized/darkpurple/think()
	var/obj/item/item = holder.get_active_held_item()
	if(item)
		if(IS_EDIBLE(item) && item.microwave_act())
			to_chat(holder, SPAN_WARNING("[linked_extract] flares up brightly, and your hands alone are enough cook [item]!"))
		else
			item.attackby(fire, holder)
	return ..()

/datum/modifier/status_effect/stabilized/darkpurple/on_expire()
	REMOVE_TRAIT(holder, TRAIT_RESISTHEATHANDS)
	qdel(fire)

/datum/modifier/status_effect/stabilized/darkpurple/get_examine_text()
	return SPAN_NOTICE("[holder] fingertips burn brightly!")

/datum/modifier/status_effect/stabilized/darkblue
	name = "stabilizeddarkblue"
	colour = "dark blue"

/datum/modifier/status_effect/stabilized/darkblue/think()
	if(holder.fire_stacks > 0 && prob(80))
		holder.adjust_wet_stacks(1)
		if(holder.fire_stacks <= 0)
			to_chat(holder, SPAN_NOTICE("[linked_extract] coats you in a watery goo, extinguishing the flames."))
	var/obj/O = holder.get_active_held_item()
	if(O)
		O.extinguish() //All shamelessly copied from water's expose_obj, since I didn't seem to be able to get it here for some reason.
		O.wash(CLEAN_TYPE_ACID)
	// Monkey cube
	if(istype(O, /obj/item/food/monkeycube))
		to_chat(holder, SPAN_WARNING("[linked_extract] kept your hands wet! It makes [O] expand!"))
		var/obj/item/food/monkeycube/cube = O
		cube.Expand()

	// Dehydrated carp
	else if(istype(O, /obj/item/toy/plush/carpplushie/dehy_carp))
		to_chat(holder, SPAN_WARNING("[linked_extract] kept your hands wet! It makes [O] expand!"))
		var/obj/item/toy/plush/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp

	else if(istype(O, /obj/item/stack/sheet/hairlesshide))
		to_chat(holder, SPAN_WARNING("[linked_extract] kept your hands wet! It wets [O]!"))
		var/obj/item/stack/sheet/hairlesshide/HH = O
		new /obj/item/stack/sheet/wethide(get_turf(HH), HH.amount)
		qdel(HH)
	..()

/datum/modifier/status_effect/stabilized/silver
	name = "stabilizedsilver"
	colour = "silver"

/datum/modifier/status_effect/stabilized/silver/on_applied()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.hunger_mod *= 0.8 //20% buff
	return ..()

/datum/modifier/status_effect/stabilized/silver/on_expire()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.hunger_mod /= 0.8

//Bluespace has an icon because it's kinda active.
/atom/movable/screen/alert/modifier/bluespacemetroid
	name = "Stabilized Bluespace Extract"
	desc = "You shouldn't see this, since we set it to change automatically!"
	icon_state = "metroid_bluespace_on"

/datum/modifier/status_effect/bluespacestabilization
	name = "stabilizedbluespacecooldown"
	duration = 1200


/datum/modifier/status_effect/stabilized/bluespace
	name = "stabilizedbluespace"
	colour = "bluespace"
	alert_type = /atom/movable/screen/alert/modifier/bluespacemetroid
	var/healthcheck

/datum/modifier/status_effect/stabilized/bluespace/think()
	if(holder.has_modifier_of_type(/datum/modifier/status_effect/bluespacestabilization))
		linked_alert.desc = "The stabilized bluespace extract is still aligning you with the bluespace axis."
		linked_alert.icon_state = "metroid_bluespace_off"
		return ..()
	else
		linked_alert.desc = "The stabilized bluespace extract will try to redirect you from harm!"
		linked_alert.icon_state = "metroid_bluespace_on"

	if(healthcheck && (healthcheck - holder.health) > 5)
		holder.visible_message(SPAN_WARNING("[linked_extract] notices the sudden change in [holder]'s physical health, and activates!"))
		do_sparks(5,FALSE,holder)
		var/F = find_safe_turf(zlevels = holder.z, extended_safety_checks = TRUE)
		var/range = 0
		if(!F)
			F = get_turf(holder)
			range = 50
		if(do_teleport(holder, F, range))
			to_chat(holder, SPAN_NOTICE("[linked_extract] will take some time to re-align you on the bluespace axis."))
			do_sparks(5,FALSE,holder)
			holder.add_modifier(/datum/modifier/status_effect/bluespacestabilization)
	healthcheck = holder.health
	return ..()

/datum/modifier/status_effect/stabilized/sepia
	name = "stabilizedsepia"
	colour = "sepia"
	var/mod = 0

/datum/modifier/status_effect/stabilized/sepia/think()
	if(prob(50) && mod > -1)
		mod--
		holder.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/modifier/sepia, multiplicative_slowdown = -0.5)
	else if(mod < 1)
		mod++
		// yeah a value of 0 does nothing but replacing the trait in place is cheaper than removing and adding repeatedly
		holder.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/modifier/sepia, multiplicative_slowdown = 0)
	return ..()

/datum/modifier/status_effect/stabilized/sepia/on_expire()
	holder.remove_movespeed_modifier(/datum/movespeed_modifier/modifier/sepia)

/datum/modifier/status_effect/stabilized/cerulean
	name = "stabilizedcerulean"
	colour = "cerulean"
	var/mob/living/clone

/datum/modifier/status_effect/stabilized/cerulean/on_applied()
	var/typepath = holder.type
	clone = new typepath(holder.loc)
	var/mob/living/carbon/O = holder
	var/mob/living/carbon/C = clone
	if(istype(C) && istype(O))
		C.real_name = O.real_name
		O.dna.transfer_identity(C)
		C.updateappearance(mutcolor_update=1)
	return ..()

/datum/modifier/status_effect/stabilized/cerulean/think()
	if(holder.stat == DEAD)
		if(clone && clone.stat != DEAD)
			holder.visible_message(SPAN_WARNING("[holder] blazes with brilliant light, [linked_extract] whisking [holder] soul away."),
				SPAN_NOTICE("You feel a warm glow from [linked_extract], and you open your eyes... elsewhere."))
			if(holder.mind)
				holder.mind.transfer_to(clone)
			clone = null
			qdel(linked_extract)
		if(!clone || clone.stat == DEAD)
			to_chat(holder, SPAN_NOTICE("[linked_extract] desperately tries to move your soul to a living body, but can't find one!"))
			qdel(linked_extract)
	..()

/datum/modifier/status_effect/stabilized/cerulean/on_expire()
	if(clone)
		clone.visible_message(SPAN_WARNING("[clone] dissolves into a puddle of goo!"))
		clone.unequip_everything()
		qdel(clone)

/datum/modifier/status_effect/stabilized/pyrite
	name = "stabilizedpyrite"
	colour = "pyrite"
	var/originalcolor

/datum/modifier/status_effect/stabilized/pyrite/on_applied()
	originalcolor = holder.color
	return ..()

/datum/modifier/status_effect/stabilized/pyrite/think()
	holder.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	return ..()

/datum/modifier/status_effect/stabilized/pyrite/on_expire()
	holder.color = originalcolor

/datum/modifier/status_effect/stabilized/red
	name = "stabilizedred"
	colour = "red"

/datum/modifier/status_effect/stabilized/red/on_applied()
	. = ..()
	holder.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/equipment_speedmod)

/datum/modifier/status_effect/stabilized/red/on_expire()
	holder.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/equipment_speedmod)
	return ..()

/datum/modifier/status_effect/stabilized/green
	name = "stabilizedgreen"
	colour = "green"
	var/datum/dna/originalDNA
	var/originalname

/datum/modifier/status_effect/stabilized/green/on_applied()
	to_chat(holder, SPAN_WARNING("You feel different..."))
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		originalDNA = new H.dna.type
		originalname = H.real_name
		H.dna.copy_dna(originalDNA)
		randomize_human(H)
	return ..()

// Only occasionally give examiners a warning.
/datum/modifier/status_effect/stabilized/green/get_examine_text()
	if(prob(50))
		return SPAN_WARNING("[holder] look[holder.p_s()] a bit green and gooey...")

	return null

/datum/modifier/status_effect/stabilized/green/on_expire()
	to_chat(holder, SPAN_NOTICE("You feel more like yourself."))
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		originalDNA.transfer_identity(H)
		H.real_name = originalname
		H.updateappearance(mutcolor_update=1)

/datum/modifier/status_effect/brokenpeace
	name = "brokenpeace"
	duration = 1200


/datum/modifier/status_effect/pinkdamagetracker
	name = "pinkdamagetracker"
	duration = 0

	var/damage = 0
	var/lasthealth

/datum/modifier/status_effect/pinkdamagetracker/think()
	if((lasthealth - holder.health) > 0)
		damage += (lasthealth - holder.health)
	lasthealth = holder.health

/datum/modifier/status_effect/stabilized/pink
	name = "stabilizedpink"
	colour = "pink"
	var/list/mobs = list()
	var/faction_name

/datum/modifier/status_effect/stabilized/pink/on_applied()
	faction_name = REF(holder)
	return ..()

/datum/modifier/status_effect/stabilized/pink/think()
	for(var/mob/living/simple_animal/M in view(7,get_turf(holder)))
		if(!(M in mobs))
			mobs += M
			M.add_modifier(/datum/modifier/status_effect/pinkdamagetracker)
			M.faction |= faction_name
	for(var/mob/living/simple_animal/M in mobs)
		if(!(M in view(7,get_turf(holder))))
			M.faction -= faction_name
			M.remove_a_modifier_of_type(/datum/modifier/status_effect/pinkdamagetracker)
			mobs -= M
		var/datum/modifier/status_effect/pinkdamagetracker/C = M.has_modifier_of_type(/datum/modifier/status_effect/pinkdamagetracker)
		if(istype(C) && C.damage > 0)
			C.damage = 0
			holder.add_modifier(/datum/modifier/status_effect/brokenpeace)
	var/HasFaction = FALSE
	for(var/i in holder.faction)
		if(i == faction_name)
			HasFaction = TRUE

	if(HasFaction && holder.has_modifier_of_type(/datum/modifier/status_effect/brokenpeace))
		holder.faction -= faction_name
		to_chat(holder, SPAN_DANGER("The peace has been broken! Hostile creatures will now react to you!"))
	if(!HasFaction && !holder.has_modifier_of_type(/datum/modifier/status_effect/brokenpeace))
		to_chat(holder, SPAN_NOTICE("[linked_extract] pulses, generating a fragile aura of peace."))
		holder.faction |= faction_name
	return ..()

/datum/modifier/status_effect/stabilized/pink/on_expire()
	for(var/mob/living/simple_animal/M in mobs)
		M.faction -= faction_name
		M.remove_a_modifier_of_type(/datum/modifier/status_effect/pinkdamagetracker)
	for(var/i in holder.faction)
		if(i == faction_name)
			holder.faction -= faction_name

/datum/modifier/status_effect/stabilized/oil
	name = "stabilizedoil"
	colour = "oil"

/datum/modifier/status_effect/stabilized/oil/think()
	if(holder.stat == DEAD)
		explosion(holder, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 5, explosion_cause = src)
	return ..()

/datum/modifier/status_effect/stabilized/oil/get_examine_text()
	return SPAN_WARNING("[holder] smell[holder.p_s()] of sulfer and oil!")

/// How much damage is dealt per healing done for the stabilized back.
/// This multiplier is applied to prevent two people from converting each other's damage away.
#define DRAIN_DAMAGE_MULTIPLIER 1.2

/datum/modifier/status_effect/stabilized/black
	name = "stabilizedblack"
	colour = "black"
	/// How much we heal per tick (also how much we damage per tick times DRAIN_DAMAGE_MULTIPLIER).
	var/heal_amount = 1
	/// Weakref to the mob we're currently draining every tick.
	var/datum/weakref/draining_ref

/datum/modifier/status_effect/stabilized/black/on_applied()
	register_signal(holder, COMSIG_MOVABLE_SET_GRAB_STATE, .proc/on_grab)
	return ..()

/datum/modifier/status_effect/stabilized/black/on_expire()
	unregister_signal(holder, COMSIG_MOVABLE_SET_GRAB_STATE)
	return ..()

/// Whenever we grab someone by the neck, set "draining" to a weakref of them.
/datum/modifier/status_effect/stabilized/black/proc/on_grab(mob/living/source, new_state)

	if(new_state < GRAB_KILL || !isliving(source.pulling))
		draining_ref = null
		return

	var/mob/living/draining = source.pulling
	if(draining.stat == DEAD)
		return

	draining_ref = weakref(draining)
	to_chat(holder, SPAN_NOTICE(FONT_LARGE("You feel your hands melt around [draining]'s neck as you start to drain [draining] of [draining] life!")))
	to_chat(draining, SPAN_DANGER(FONT_LARGE("[holder]'s hands melt around your neck as you can feel your life starting to drain away!")))

/datum/modifier/status_effect/stabilized/black/get_examine_text()
	var/mob/living/draining = draining_ref?.resolve()
	if(!draining)
		return null

	return SPAN_WARNING("[holder] [holder.p_are()] draining health from [draining]!")

/datum/modifier/status_effect/stabilized/black/think()
	if(holder.grab_state < GRAB_KILL || !IS_WEAKREF_OF(holder.pulling, draining_ref))
		return

	var/mob/living/drained = draining_ref.resolve()
	if(drained.stat == DEAD)
		to_chat(holder, SPAN_WARNING("[drained] is dead, you cannot drain anymore life from them!"))
		draining_ref = null
		return

	var/list/healing_types = list()
	if(holder.getBruteLoss() > 0)
		healing_types += BRUTE
	if(holder.getFireLoss() > 0)
		healing_types += BURN
	if(holder.getToxLoss() > 0)
		healing_types += TOX
	if(holder.getCloneLoss() > 0)
		healing_types += CLONE

	if(length(healing_types))
		holder.apply_damage_type(-heal_amount, damagetype = pick(healing_types))

	holder.adjust_nutrition(3)
	drained.adjustCloneLoss(heal_amount * DRAIN_DAMAGE_MULTIPLIER)
	return ..()

#undef DRAIN_DAMAGE_MULTIPLIER

/datum/modifier/status_effect/stabilized/lightpink
	name = "stabilizedlightpink"
	colour = "light pink"

/datum/modifier/status_effect/stabilized/lightpink/on_applied()
	holder.add_movespeed_modifier(/datum/movespeed_modifier/modifier/lightpink)
	ADD_TRAIT(holder, TRAIT_PACIFISM)
	return ..()

/datum/modifier/status_effect/stabilized/lightpink/think()
	for(var/mob/living/carbon/human/H in range(1, get_turf(holder)))
		if(H != holder && H.stat != DEAD && H.health <= 0 && !H.reagents.has_reagent(/datum/reagent/medicine/epinephrine))
			to_chat(holder, "[linked_extract] pulses in sync with [H]'s heartbeat, trying to keep [H] alive.")
			H.reagents.add_reagent(/datum/reagent/medicine/epinephrine,5)
	return ..()

/datum/modifier/status_effect/stabilized/lightpink/on_expire()
	holder.remove_movespeed_modifier(/datum/movespeed_modifier/modifier/lightpink)
	REMOVE_TRAIT(holder, TRAIT_PACIFISM)

/datum/modifier/status_effect/stabilized/adamantine
	name = "stabilizedadamantine"
	colour = "adamantine"

/datum/modifier/status_effect/stabilized/adamantine/get_examine_text()
	return SPAN_WARNING("[holder] [holder.p_have()] strange metallic coating on [holder] skin.")

/datum/modifier/status_effect/stabilized/gold
	name = "stabilizedgold"
	colour = "gold"
	var/mob/living/simple_animal/familiar

/datum/modifier/status_effect/stabilized/gold/think()
	var/obj/item/metroidcross/stabilized/gold/linked = linked_extract
	if(QDELETED(familiar))
		familiar = new linked.mob_type(get_turf(holder.loc))
		familiar.name = linked.mob_name
		familiar.del_on_death = TRUE
		familiar.copy_languages(holder, LANGUAGE_MASTER)
		if(linked.saved_mind)
			linked.saved_mind.transfer_to(familiar)
			familiar.update_atom_languages()
			familiar.ckey = linked.saved_mind.key
	else
		if(familiar.mind)
			linked.saved_mind = familiar.mind
	return ..()

/datum/modifier/status_effect/stabilized/gold/on_expire()
	if(familiar)
		qdel(familiar)

/datum/modifier/status_effect/stabilized/adamantine/on_applied()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.damage_resistance += 5
	return ..()

/datum/modifier/status_effect/stabilized/adamantine/on_expire()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.damage_resistance -= 5

/datum/modifier/status_effect/stabilized/rainbow
	name = "stabilizedrainbow"
	colour = "rainbow"

/datum/modifier/status_effect/stabilized/rainbow/think()
	if(holder.health <= 0)
		var/obj/item/metroidcross/stabilized/rainbow/X = linked_extract
		if(istype(X))
			if(X.regencore)
				X.regencore.afterattack(holder,holder,TRUE)
				X.regencore = null
				holder.visible_message(SPAN_WARNING("[holder] flashes a rainbow of colors, and [holder] skin is coated in a milky regenerative goo!"))
				holder.remove_specific_modifier(src)
				qdel(linked_extract)
	return ..()
