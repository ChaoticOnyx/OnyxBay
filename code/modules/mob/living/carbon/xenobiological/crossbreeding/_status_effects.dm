/atom/movable/screen/alert/status_effect/rainbow_protection
	name = "Rainbow Protection"
	desc = "You are defended from harm, but so are those you might seek to injure!"
	icon_state = "slime_rainbowshield"

/datum/status_effect/rainbow_protection
	id = "rainbow_protection"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/rainbow_protection
	var/originalcolor

/datum/status_effect/rainbow_protection/on_apply()
	owner.status_flags |= GODMODE
	ADD_TRAIT(owner, TRAIT_PACIFISM, /datum/status_effect/rainbow_protection)
	owner.visible_message(span_warning("[owner] shines with a brilliant rainbow light."),
		span_notice("You feel protected by an unknown force!"))
	originalcolor = owner.color
	return ..()

/datum/status_effect/rainbow_protection/tick()
	owner.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	return ..()

/datum/status_effect/rainbow_protection/on_remove()
	owner.status_flags &= ~GODMODE
	owner.color = originalcolor
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, /datum/status_effect/rainbow_protection)
	owner.visible_message(span_notice("[owner] stops glowing, the rainbow light fading away."),
		span_warning("You no longer feel protected..."))

/atom/movable/screen/alert/status_effect/slimeskin
	name = "Adamantine Slimeskin"
	desc = "You are covered in a thick, non-neutonian gel."
	icon_state = "slime_stoneskin"

/datum/status_effect/slimeskin
	id = "slimeskin"
	duration = 300
	alert_type = /atom/movable/screen/alert/status_effect/slimeskin
	var/originalcolor

/datum/status_effect/slimeskin/on_apply()
	originalcolor = owner.color
	owner.color = "#3070CC"
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.damage_resistance += 10
	owner.visible_message(span_warning("[owner] is suddenly covered in a strange, blue-ish gel!"),
		span_notice("You are covered in a thick, rubbery gel."))
	return ..()

/datum/status_effect/slimeskin/on_remove()
	owner.color = originalcolor
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.damage_resistance -= 10
	owner.visible_message(span_warning("[owner]'s gel coating liquefies and dissolves away."),
		span_notice("Your gel second-skin dissolves!"))

/datum/status_effect/slimerecall
	id = "slime_recall"
	duration = -1 //Will be removed by the extract.
	tick_interval = -1
	alert_type = null
	var/interrupted = FALSE
	var/mob/target
	var/icon/bluespace

/datum/status_effect/slimerecall/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, .proc/resistField)
	to_chat(owner, span_danger("You feel a sudden tug from an unknown force, and feel a pull to bluespace!"))
	to_chat(owner, span_notice("Resist if you wish avoid the force!"))
	bluespace = icon('icons/effects/effects.dmi',"chronofield")
	owner.add_overlay(bluespace)
	return ..()

/datum/status_effect/slimerecall/proc/resistField()
	SIGNAL_HANDLER
	interrupted = TRUE
	owner.remove_status_effect(src)

/datum/status_effect/slimerecall/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)
	owner.cut_overlay(bluespace)
	if(interrupted || !ismob(target))
		to_chat(owner, span_warning("The bluespace tug fades away, and you feel that the force has passed you by."))
		return
	var/turf/old_location = get_turf(owner)
	if(do_teleport(owner, target.loc, channel = TELEPORT_CHANNEL_QUANTUM)) //despite being named a bluespace teleportation method the quantum channel is used to preserve precision teleporting with a bag of holding
		old_location.visible_message(span_warning("[owner] disappears in a flurry of sparks!"))
		to_chat(owner, span_warning("The unknown force snatches briefly you from reality, and deposits you next to [target]!"))

/atom/movable/screen/alert/status_effect/freon/stasis
	desc = "You're frozen inside of a protective ice cube! While inside, you can't do anything, but are immune to harm! Resist to get out."

/datum/status_effect/frozenstasis
	id = "slime_frozen"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1 //Will remove self when block breaks.
	alert_type = /atom/movable/screen/alert/status_effect/freon/stasis
	var/obj/structure/ice_stasis/cube

/datum/status_effect/frozenstasis/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, .proc/breakCube)
	cube = new /obj/structure/ice_stasis(get_turf(owner))
	owner.forceMove(cube)
	owner.status_flags |= GODMODE
	return ..()

/datum/status_effect/frozenstasis/tick()
	if(!cube || owner.loc != cube)
		owner.remove_status_effect(src)

/datum/status_effect/frozenstasis/proc/breakCube()
	SIGNAL_HANDLER

	owner.remove_status_effect(src)

/datum/status_effect/frozenstasis/on_remove()
	if(cube)
		qdel(cube)
	owner.status_flags &= ~GODMODE
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)

/datum/status_effect/slime_clone
	id = "slime_cloned"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	alert_type = null
	var/mob/living/clone
	var/datum/mind/originalmind //For when the clone gibs.

/datum/status_effect/slime_clone/on_apply()
	var/typepath = owner.type
	clone = new typepath(owner.loc)
	var/mob/living/carbon/O = owner
	var/mob/living/carbon/C = clone
	if(istype(C) && istype(O))
		C.real_name = O.real_name
		O.dna.transfer_identity(C)
		C.updateappearance(mutcolor_update=1)
	if(owner.mind)
		originalmind = owner.mind
		owner.mind.transfer_to(clone)
	clone.apply_status_effect(/datum/status_effect/slime_clone_decay)
	return ..()

/datum/status_effect/slime_clone/tick()
	if(!istype(clone) || clone.stat != CONSCIOUS)
		owner.remove_status_effect(src)

/datum/status_effect/slime_clone/on_remove()
	if(clone?.mind && owner)
		clone.mind.transfer_to(owner)
	else
		if(owner && originalmind)
			originalmind.transfer_to(owner)
			if(originalmind.key)
				owner.ckey = originalmind.key
	if(clone)
		clone.unequip_everything()
		qdel(clone)

/atom/movable/screen/alert/status_effect/clone_decay
	name = "Clone Decay"
	desc = "You are simply a construct, and cannot maintain this form forever. You will be returned to your original body if you should fall."
	icon_state = "slime_clonedecay"

/datum/status_effect/slime_clone_decay
	id = "slime_clonedecay"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/clone_decay

/datum/status_effect/slime_clone_decay/tick()
	owner.adjustToxLoss(1, 0)
	owner.adjustOxyLoss(1, 0)
	owner.adjustBruteLoss(1, 0)
	owner.adjustFireLoss(1, 0)
	owner.color = "#007BA7"

/atom/movable/screen/alert/status_effect/bloodchill
	name = "Bloodchilled"
	desc = "You feel a shiver down your spine after getting hit with a glob of cold blood. You'll move slower and get frostbite for a while!"
	icon_state = "bloodchill"

/datum/status_effect/bloodchill
	id = "bloodchill"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/bloodchill

/datum/status_effect/bloodchill/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/bloodchill)
	return ..()

/datum/status_effect/bloodchill/tick()
	if(prob(50))
		owner.adjustFireLoss(2)

/datum/status_effect/bloodchill/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/bloodchill)

/datum/status_effect/bonechill
	id = "bonechill"
	duration = 80
	alert_type = /atom/movable/screen/alert/status_effect/bonechill

/datum/status_effect/bonechill/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/bonechill)
	return ..()

/datum/status_effect/bonechill/tick()
	if(prob(50))
		owner.adjustFireLoss(1)
		owner.set_jitter_if_lower(6 SECONDS)
		owner.adjust_bodytemperature(-10)
		if(ishuman(owner))
			var/mob/living/carbon/human/humi = owner
			humi.adjust_coretemperature(-10)

/datum/status_effect/bonechill/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/bonechill)
/atom/movable/screen/alert/status_effect/bonechill
	name = "Bonechilled"
	desc = "You feel a shiver down your spine after hearing the haunting noise of bone rattling. You'll move slower and get frostbite for a while!"
	icon_state = "bloodchill"

/datum/status_effect/rebreathing
	id = "rebreathing"
	duration = -1
	alert_type = null

/datum/status_effect/rebreathing/tick()
	owner.adjustOxyLoss(-6, 0) //Just a bit more than normal breathing.

///////////////////////////////////////////////////////
//////////////////CONSUMING EXTRACTS///////////////////
///////////////////////////////////////////////////////

/datum/status_effect/firecookie
	id = "firecookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 100

/datum/status_effect/firecookie/on_apply()
	ADD_TRAIT(owner, TRAIT_RESISTCOLD,"firecookie")
	owner.adjust_bodytemperature(110)
	return ..()

/datum/status_effect/firecookie/on_remove()
	REMOVE_TRAIT(owner, TRAIT_RESISTCOLD,"firecookie")

/datum/status_effect/watercookie
	id = "watercookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 100

/datum/status_effect/watercookie/on_apply()
	ADD_TRAIT(owner, TRAIT_NOSLIPWATER,"watercookie")
	return ..()

/datum/status_effect/watercookie/tick()
	for(var/turf/open/T in range(get_turf(owner),1))
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)

/datum/status_effect/watercookie/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOSLIPWATER,"watercookie")

/datum/status_effect/metalcookie
	id = "metalcookie"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 100

/datum/status_effect/metalcookie/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 0.9
	return ..()

/datum/status_effect/metalcookie/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod /= 0.9

/datum/status_effect/sparkcookie
	id = "sparkcookie"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 300
	var/original_coeff

/datum/status_effect/sparkcookie/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		original_coeff = H.physiology.siemens_coeff
		H.physiology.siemens_coeff = 0
	return ..()

/datum/status_effect/sparkcookie/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.siemens_coeff = original_coeff

/datum/status_effect/toxincookie
	id = "toxincookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 600

/datum/status_effect/toxincookie/on_apply()
	ADD_TRAIT(owner, TRAIT_TOXINLOVER,"toxincookie")
	return ..()

/datum/status_effect/toxincookie/on_remove()
	REMOVE_TRAIT(owner, TRAIT_TOXINLOVER,"toxincookie")

/datum/status_effect/timecookie
	id = "timecookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 600

/datum/status_effect/timecookie/on_apply()
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/timecookie)
	return ..()

/datum/status_effect/timecookie/on_remove()
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/timecookie)
	return ..()

/datum/status_effect/lovecookie
	id = "lovecookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 300

/datum/status_effect/lovecookie/tick()
	if(owner.stat != CONSCIOUS)
		return
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		if(C.handcuffed)
			return
	var/list/huggables = list()
	for(var/mob/living/carbon/L in range(get_turf(owner),1))
		if(L != owner)
			huggables += L
	if(length(huggables))
		var/mob/living/carbon/hugged = pick(huggables)
		owner.visible_message(span_notice("[owner] hugs [hugged]!"), span_notice("You hug [hugged]!"))

/datum/status_effect/tarcookie
	id = "tarcookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 100

/datum/status_effect/tarcookie/tick()
	for(var/mob/living/carbon/human/L in range(get_turf(owner),1))
		if(L != owner)
			L.apply_status_effect(/datum/status_effect/tarfoot)

/datum/status_effect/tarfoot
	id = "tarfoot"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 30

/datum/status_effect/tarfoot/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/tarfoot)
	return ..()

/datum/status_effect/tarfoot/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/tarfoot)

/datum/status_effect/spookcookie
	id = "spookcookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 300

/datum/status_effect/spookcookie/on_apply()
	var/image/I = image(icon = 'icons/mob/simple/simple_human.dmi', icon_state = "skeleton", layer = ABOVE_MOB_LAYER, loc = owner)
	I.override = 1
	owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "spookyscary", I)
	return ..()

/datum/status_effect/spookcookie/on_remove()
	owner.remove_alt_appearance("spookyscary")

/datum/status_effect/peacecookie
	id = "peacecookie"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 100

/datum/status_effect/peacecookie/tick()
	for(var/mob/living/L in range(get_turf(owner),1))
		L.apply_status_effect(/datum/status_effect/plur)

/datum/status_effect/plur
	id = "plur"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 30

/datum/status_effect/plur/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, "peacecookie")
	return ..()

/datum/status_effect/plur/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "peacecookie")

/datum/status_effect/adamantinecookie
	id = "adamantinecookie"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 100

/datum/status_effect/adamantinecookie/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.burn_mod *= 0.9
	return ..()

/datum/status_effect/adamantinecookie/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.burn_mod /= 0.9


///////////////////////////////////////////////////////
//////////////////STABILIZED EXTRACTS//////////////////
///////////////////////////////////////////////////////

/datum/modifier/stabilized //The base stabilized extract effect, has no effect of its' own.
	name = "stabilizedbase"
	var/alert_type = null
	var/obj/item/metroidcross/stabilized/linked_extract
	var/colour = "null"

/datum/modifier/stabilized/proc/location_check()
	if(linked_extract.loc == holder)
		return TRUE
	if(linked_extract.loc.loc == holder)
		return TRUE

	return FALSE

/datum/modifier/stabilized/think()
	if(!linked_extract || !linked_extract.loc) //Sanity checking
		qdel(src)
		return
	if(linked_extract && !location_check())
		linked_extract.linked_effect = null
		if(!QDELETED(linked_extract))
			linked_extract.owner = null
			linked_extract.set_next_think(world.time + 1 SECOND)
		qdel(src)
	return ..()

/datum/modifier/stabilized/null //This shouldn't ever happen, but just in case.
	name = "stabilizednull"


//Stabilized effects start below.
/datum/modifier/stabilized/grey
	name = "stabilizedgrey"
	colour = "grey"

/datum/modifier/stabilized/grey/think()
	for(var/mob/living/carbon/metroid/S in range(1, get_turf(holder)))
		if(!(holder in S.Friends))
			to_chat(holder, SPAN_NOTICE("[linked_extract] pulses gently as it communicates with [S]."))
			S.Friends += holder
	return ..()

/datum/modifier/stabilized/orange
	name = "stabilizedorange"
	colour = "orange"

/datum/modifier/stabilized/orange/think()
	var/body_temperature_difference = holder.get_species().body_temperature - holder.bodytemperature
	holder.bodytemperature += body_temperature_difference<0?(max(-5, body_temperature_difference)):(min(5, body_temperature_difference))
	return ..()

/datum/modifier/stabilized/purple
	name = "stabilizedpurple"
	colour = "purple"
	/// Whether we healed from our last tick
	var/healed_last_tick = FALSE

/datum/modifier/stabilized/purple/think()
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

/datum/modifier/stabilized/purple/get_examine_text()
	if(healed_last_tick)
		return SPAN_WARNING("[holder] [holder.p_are()] regenerating slowly, purplish goo filling in small injuries!")

	return null

/datum/modifier/stabilized/blue
	name = "stabilizedblue"
	colour = "blue"

/datum/modifier/stabilized/blue/on_apply()
	ADD_TRAIT(holder, TRAIT_NOSLIPWATER, "metroidstatus")
	return ..()

/datum/modifier/stabilized/blue/on_remove()
	REMOVE_TRAIT(holder, TRAIT_NOSLIPWATER, "metroidstatus")

/datum/modifier/stabilized/metal
	name = "stabilizedmetal"
	colour = "metal"
	var/cooldown = 30
	var/max_cooldown = 30

/datum/modifier/stabilized/metal/think()
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


/datum/modifier/stabilized/yellow
	name = "stabilizedyellow"
	colour = "yellow"
	var/cooldown = 10
	var/max_cooldown = 10

/datum/modifier/stabilized/yellow/get_examine_text()
	return SPAN_WARNING("Nearby electronics seem just a little more charged wherever [holder] go[holder].")

/datum/modifier/stabilized/yellow/think()
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

/datum/modifier/stabilized/darkpurple
	name = "stabilizeddarkpurple"
	colour = "dark purple"
	var/obj/item/hothands/fire

/datum/modifier/stabilized/darkpurple/on_apply()
	ADD_TRAIT(holder, TRAIT_RESISTHEATHANDS, "metroidstatus")
	fire = new(holder)
	return ..()

/datum/modifier/stabilized/darkpurple/think()
	var/obj/item/item = holder.get_active_held_item()
	if(item)
		if(IS_EDIBLE(item) && item.microwave_act())
			to_chat(holder, SPAN_WARNING("[linked_extract] flares up brightly, and your hands alone are enough cook [item]!"))
		else
			item.attackby(fire, holder)
	return ..()

/datum/modifier/stabilized/darkpurple/on_remove()
	REMOVE_TRAIT(holder, TRAIT_RESISTHEATHANDS, "metroidstatus")
	qdel(fire)

/datum/modifier/stabilized/darkpurple/get_examine_text()
	return SPAN_NOTICE("[holder.p_their(TRUE)] fingertips burn brightly!")

/datum/modifier/stabilized/darkblue
	name = "stabilizeddarkblue"
	colour = "dark blue"

/datum/modifier/stabilized/darkblue/think()
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

/datum/modifier/stabilized/silver
	name = "stabilizedsilver"
	colour = "silver"

/datum/modifier/stabilized/silver/on_apply()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.hunger_mod *= 0.8 //20% buff
	return ..()

/datum/modifier/stabilized/silver/on_remove()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.hunger_mod /= 0.8

//Bluespace has an icon because it's kinda active.
/atom/movable/screen/alert/modifier/bluespacemetroid
	name = "Stabilized Bluespace Extract"
	desc = "You shouldn't see this, since we set it to change automatically!"
	icon_state = "metroid_bluespace_on"

/datum/modifier/bluespacestabilization
	name = "stabilizedbluespacecooldown"
	duration = 1200
	alert_type = null

/datum/modifier/stabilized/bluespace
	name = "stabilizedbluespace"
	colour = "bluespace"
	alert_type = /atom/movable/screen/alert/modifier/bluespacemetroid
	var/healthcheck

/datum/modifier/stabilized/bluespace/think()
	if(holder.has_modifier_of_type(/datum/modifier/bluespacestabilization))
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
		if(do_teleport(holder, F, range, channel = TELEPORT_CHANNEL_BLUESPACE))
			to_chat(holder, SPAN_NOTICE("[linked_extract] will take some time to re-align you on the bluespace axis."))
			do_sparks(5,FALSE,holder)
			holder.apply_modifier(/datum/modifier/bluespacestabilization)
	healthcheck = holder.health
	return ..()

/datum/modifier/stabilized/sepia
	name = "stabilizedsepia"
	colour = "sepia"
	var/mod = 0

/datum/modifier/stabilized/sepia/think()
	if(prob(50) && mod > -1)
		mod--
		holder.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/modifier/sepia, multiplicative_slowdown = -0.5)
	else if(mod < 1)
		mod++
		// yeah a value of 0 does nothing but replacing the trait in place is cheaper than removing and adding repeatedly
		holder.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/modifier/sepia, multiplicative_slowdown = 0)
	return ..()

/datum/modifier/stabilized/sepia/on_remove()
	holder.remove_movespeed_modifier(/datum/movespeed_modifier/modifier/sepia)

/datum/modifier/stabilized/cerulean
	name = "stabilizedcerulean"
	colour = "cerulean"
	var/mob/living/clone

/datum/modifier/stabilized/cerulean/on_apply()
	var/typepath = holder.type
	clone = new typepath(holder.loc)
	var/mob/living/carbon/O = holder
	var/mob/living/carbon/C = clone
	if(istype(C) && istype(O))
		C.real_name = O.real_name
		O.dna.transfer_identity(C)
		C.updateappearance(mutcolor_update=1)
	return ..()

/datum/modifier/stabilized/cerulean/think()
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

/datum/modifier/stabilized/cerulean/on_remove()
	if(clone)
		clone.visible_message(SPAN_WARNING("[clone] dissolves into a puddle of goo!"))
		clone.unequip_everything()
		qdel(clone)

/datum/modifier/stabilized/pyrite
	name = "stabilizedpyrite"
	colour = "pyrite"
	var/originalcolor

/datum/modifier/stabilized/pyrite/on_apply()
	originalcolor = holder.color
	return ..()

/datum/modifier/stabilized/pyrite/think()
	holder.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	return ..()

/datum/modifier/stabilized/pyrite/on_remove()
	holder.color = originalcolor

/datum/modifier/stabilized/red
	name = "stabilizedred"
	colour = "red"

/datum/modifier/stabilized/red/on_apply()
	. = ..()
	holder.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/equipment_speedmod)

/datum/modifier/stabilized/red/on_remove()
	holder.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/equipment_speedmod)
	return ..()

/datum/modifier/stabilized/green
	name = "stabilizedgreen"
	colour = "green"
	var/datum/dna/originalDNA
	var/originalname

/datum/modifier/stabilized/green/on_apply()
	to_chat(holder, SPAN_WARNING("You feel different..."))
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		originalDNA = new H.dna.type
		originalname = H.real_name
		H.dna.copy_dna(originalDNA)
		randomize_human(H)
	return ..()

// Only occasionally give examiners a warning.
/datum/modifier/stabilized/green/get_examine_text()
	if(prob(50))
		return SPAN_WARNING("[holder] look[holder.p_s()] a bit green and gooey...")

	return null

/datum/modifier/stabilized/green/on_remove()
	to_chat(holder, SPAN_NOTICE("You feel more like yourself."))
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		originalDNA.transfer_identity(H)
		H.real_name = originalname
		H.updateappearance(mutcolor_update=1)

/datum/modifier/brokenpeace
	name = "brokenpeace"
	duration = 1200
	alert_type = null

/datum/modifier/pinkdamagetracker
	name = "pinkdamagetracker"
	duration = -1
	alert_type = null
	var/damage = 0
	var/lasthealth

/datum/modifier/pinkdamagetracker/think()
	if((lasthealth - holder.health) > 0)
		damage += (lasthealth - holder.health)
	lasthealth = holder.health

/datum/modifier/stabilized/pink
	name = "stabilizedpink"
	colour = "pink"
	var/list/mobs = list()
	var/faction_name

/datum/modifier/stabilized/pink/on_apply()
	faction_name = REF(holder)
	return ..()

/datum/modifier/stabilized/pink/think()
	for(var/mob/living/simple_animal/M in view(7,get_turf(holder)))
		if(!(M in mobs))
			mobs += M
			M.apply_modifier(/datum/modifier/pinkdamagetracker)
			M.faction |= faction_name
	for(var/mob/living/simple_animal/M in mobs)
		if(!(M in view(7,get_turf(holder))))
			M.faction -= faction_name
			M.remove_modifier(/datum/modifier/pinkdamagetracker)
			mobs -= M
		var/datum/modifier/pinkdamagetracker/C = M.has_modifier_of_type(/datum/modifier/pinkdamagetracker)
		if(istype(C) && C.damage > 0)
			C.damage = 0
			holder.apply_modifier(/datum/modifier/brokenpeace)
	var/HasFaction = FALSE
	for(var/i in holder.faction)
		if(i == faction_name)
			HasFaction = TRUE

	if(HasFaction && holder.has_modifier_of_type_of_type(/datum/modifier/brokenpeace))
		holder.faction -= faction_name
		to_chat(holder, SPAN_DANGER("The peace has been broken! Hostile creatures will now react to you!"))
	if(!HasFaction && !holder.has_modifier_of_type(/datum/modifier/brokenpeace))
		to_chat(holder, SPAN_NOTICE("[linked_extract] pulses, generating a fragile aura of peace."))
		holder.faction |= faction_name
	return ..()

/datum/modifier/stabilized/pink/on_remove()
	for(var/mob/living/simple_animal/M in mobs)
		M.faction -= faction_name
		M.remove_modifier(/datum/modifier/pinkdamagetracker)
	for(var/i in holder.faction)
		if(i == faction_name)
			holder.faction -= faction_name

/datum/modifier/stabilized/oil
	name = "stabilizedoil"
	colour = "oil"

/datum/modifier/stabilized/oil/think()
	if(holder.stat == DEAD)
		explosion(holder, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 5, explosion_cause = src)
	return ..()

/datum/modifier/stabilized/oil/get_examine_text()
	return SPAN_WARNING("[holder] smell[holder.p_s()] of sulfer and oil!")

/// How much damage is dealt per healing done for the stabilized back.
/// This multiplier is applied to prevent two people from converting each other's damage away.
#define DRAIN_DAMAGE_MULTIPLIER 1.2

/datum/modifier/stabilized/black
	name = "stabilizedblack"
	colour = "black"
	/// How much we heal per tick (also how much we damage per tick times DRAIN_DAMAGE_MULTIPLIER).
	var/heal_amount = 1
	/// Weakref to the mob we're currently draining every tick.
	var/datum/weakref/draining_ref

/datum/modifier/stabilized/black/on_apply()
	RegisterSignal(holder, COMSIG_MOVABLE_SET_GRAB_STATE, .proc/on_grab)
	return ..()

/datum/modifier/stabilized/black/on_remove()
	UnregisterSignal(holder, COMSIG_MOVABLE_SET_GRAB_STATE)
	return ..()

/// Whenever we grab someone by the neck, set "draining" to a weakref of them.
/datum/modifier/stabilized/black/proc/on_grab(mob/living/source, new_state)
	SIGNAL_HANDLER

	if(new_state < GRAB_KILL || !isliving(source.pulling))
		draining_ref = null
		return

	var/mob/living/draining = source.pulling
	if(draining.stat == DEAD)
		return

	draining_ref = WEAKREF(draining)
	to_chat(holder, span_boldnotice("You feel your hands melt around [draining]'s neck as you start to drain [draining.p_them()] of [draining] life!"))
	to_chat(draining, SPAN_DANGER("[holder]'s hands melt around your neck as you can feel your life starting to drain away!"))

/datum/modifier/stabilized/black/get_examine_text()
	var/mob/living/draining = draining_ref?.resolve()
	if(!draining)
		return null

	return SPAN_WARNING("[holder] [holder.p_are()] draining health from [draining]!")

/datum/modifier/stabilized/black/think()
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

/datum/modifier/stabilized/lightpink
	name = "stabilizedlightpink"
	colour = "light pink"

/datum/modifier/stabilized/lightpink/on_apply()
	holder.add_movespeed_modifier(/datum/movespeed_modifier/modifier/lightpink)
	ADD_TRAIT(holder, TRAIT_PACIFISM, STABILIZED_LIGHT_PINK_TRAIT)
	return ..()

/datum/modifier/stabilized/lightpink/think()
	for(var/mob/living/carbon/human/H in range(1, get_turf(holder)))
		if(H != holder && H.stat != DEAD && H.health <= 0 && !H.reagents.has_reagent(/datum/reagent/medicine/epinephrine))
			to_chat(holder, "[linked_extract] pulses in sync with [H]'s heartbeat, trying to keep [H.p_them()] alive.")
			H.reagents.add_reagent(/datum/reagent/medicine/epinephrine,5)
	return ..()

/datum/modifier/stabilized/lightpink/on_remove()
	holder.remove_movespeed_modifier(/datum/movespeed_modifier/modifier/lightpink)
	REMOVE_TRAIT(holder, TRAIT_PACIFISM, STABILIZED_LIGHT_PINK_TRAIT)

/datum/modifier/stabilized/adamantine
	name = "stabilizedadamantine"
	colour = "adamantine"

/datum/modifier/stabilized/adamantine/get_examine_text()
	return SPAN_WARNING("[holder] [holder.p_have()] strange metallic coating on [holder] skin.")

/datum/modifier/stabilized/gold
	name = "stabilizedgold"
	colour = "gold"
	var/mob/living/simple_animal/familiar

/datum/modifier/stabilized/gold/think()
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

/datum/modifier/stabilized/gold/on_remove()
	if(familiar)
		qdel(familiar)

/datum/modifier/stabilized/adamantine/on_apply()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.damage_resistance += 5
	return ..()

/datum/modifier/stabilized/adamantine/on_remove()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.physiology.damage_resistance -= 5

/datum/modifier/stabilized/rainbow
	name = "stabilizedrainbow"
	colour = "rainbow"

/datum/modifier/stabilized/rainbow/think()
	if(holder.health <= 0)
		var/obj/item/metroidcross/stabilized/rainbow/X = linked_extract
		if(istype(X))
			if(X.regencore)
				X.regencore.afterattack(holder,holder,TRUE)
				X.regencore = null
				holder.visible_message(SPAN_WARNING("[holder] flashes a rainbow of colors, and [holder] skin is coated in a milky regenerative goo!"))
				qdel(src)
				qdel(linked_extract)
	return ..()
