/atom/movable/screen/movable/alert/status_effect/rainbow_protection
	name = "Rainbow Protection"
	desc = "You are defended from harm, but so are those you might seek to injure!"
	icon_state = "metroid_rainbowshield"

/datum/modifier/status_effect
	var/duration = 0
	var/alert_type = null
	var/atom/movable/screen/movable/alert/linked_alert = null

/datum/modifier/status_effect/New(new_holder, new_origin)
	..()
	if(duration)
		expire_at = world.time + duration

	if(alert_type)
		linked_alert = holder.throw_alert("\ref[src]",alert_type)

/datum/modifier/status_effect/on_expire()
	. = ..()
	holder.clear_alert("\ref[src]")

/datum/modifier/status_effect/rainbow_protection
	name = "rainbow_protection"
	duration = 200
	alert_type = /atom/movable/screen/movable/alert/status_effect/rainbow_protection
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
	..()

/atom/movable/screen/movable/alert/status_effect/metroidskin
	name = "Adamantine metroidskin"
	desc = "You are covered in a thick, non-neutonian gel."
	icon_state = "metroid_stoneskin"

/datum/modifier/status_effect/metroidskin
	name = "metroidskin"
	duration = 300
	alert_type = /atom/movable/screen/movable/alert/status_effect/metroidskin
	incoming_brute_damage_percent = 0.75
	var/originalcolor

/datum/modifier/status_effect/metroidskin/on_applied()
	originalcolor = holder.color
	holder.color = "#3070CC"
	holder.visible_message(SPAN_WARNING("[holder] is suddenly covered in a strange, blue-ish gel!"),
		SPAN_NOTICE("You are covered in a thick, rubbery gel."))
	return ..()

/datum/modifier/status_effect/metroidskin/on_expire()
	holder.color = originalcolor
	holder.visible_message(SPAN_WARNING("[holder]'s gel coating liquefies and dissolves away."),
		SPAN_NOTICE("Your gel second-skin dissolves!"))
	..()

/datum/modifier/status_effect/metroidrecall
	name = "metroid_recall"
	duration = 0 //Will be removed by the extract.

	var/interrupted = FALSE
	var/mob/target
	var/icon/bluespace

/datum/modifier/status_effect/metroidrecall/on_applied()
	register_signal(holder, SIGNAL_MOB_RESIST, nameof(.proc/resistField))
	to_chat(holder, SPAN_DANGER("You feel a sudden tug from an unknown force, and feel a pull to bluespace!"))
	to_chat(holder, SPAN_NOTICE("Resist if you wish avoid the force!"))
	bluespace = icon('icons/effects/effects.dmi',"chronofield")
	holder.AddOverlays(bluespace)
	return ..()

/datum/modifier/status_effect/metroidrecall/proc/resistField()
	if(do_after(holder, 30))
		interrupted = TRUE
		holder.remove_specific_modifier(src)

/datum/modifier/status_effect/metroidrecall/on_expire()
	unregister_signal(holder, SIGNAL_MOB_RESIST)
	holder.CutOverlays(bluespace)
	if(interrupted || !ismob(target))
		to_chat(holder, SPAN_WARNING("The bluespace tug fades away, and you feel that the force has passed you by."))
		return
	var/turf/old_location = get_turf(holder)
	if(do_teleport(holder, target.loc))
		old_location.visible_message(SPAN_WARNING("[holder] disappears in a flurry of sparks!"))
		to_chat(holder, SPAN_WARNING("The unknown force snatches briefly you from reality, and deposits you next to [target]!"))

/atom/movable/screen/movable/alert/status_effect/freon/stasis
	desc = "You're frozen inside of a protective ice cube! While inside, you can't do anything, but are immune to harm! Resist to get out."

/datum/modifier/status_effect/frozenstasis
	name = "metroid_frozen"
	var/obj/structure/ice_stasis/cube
	alert_type = /atom/movable/screen/movable/alert/status_effect/freon/stasis

/datum/modifier/status_effect/frozenstasis/on_applied()
	register_signal(holder, SIGNAL_MOB_RESIST, nameof(.proc/breakCube))
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
	..()

	unregister_signal(holder, SIGNAL_MOB_RESIST)

/datum/modifier/status_effect/metroid_clone
	name = "metroid_clone"
	var/mob/living/clone
	var/datum/mind/originalmind //For when the clone gibs.

/datum/modifier/status_effect/metroid_clone/on_applied()
	var/typepath = holder.type
	clone = new typepath(holder.loc)
	var/mob/living/carbon/human/O = holder
	var/mob/living/carbon/human/C = clone
	if(istype(C) && istype(O))
		C.real_name = O.real_name
		C.set_species(O.get_species())
		C.setDNA(O.getDNA())
		C.h_style = O.h_style
		C.f_style = O.f_style
		C.UpdateAppearance()
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

/datum/modifier/status_effect/metroid_clone_decay/tick()
	holder.adjustToxLoss(1)
	holder.adjustOxyLoss(1)
	holder.adjustBruteLoss(1)
	holder.adjustFireLoss(1)
	holder.color = "#007BA7"

/atom/movable/screen/movable/alert/status_effect/clone_decay
	name = "Clone Decay"
	desc = "You are simply a construct, and cannot maintain this form forever. You will be returned to your original body if you should fall."
	icon_state = "metroid_clone"

/atom/movable/screen/movable/alert/status_effect/bloodchill
	name = "Bloodchilled"
	desc = "You feel a shiver down your spine after getting hit with a glob of cold blood. You'll move slower and get frostbite for a while!"
	icon_state = "bloodchill"

/datum/modifier/status_effect/bloodchill
	name = "bloodchill"
	duration = 100
	alert_type = /atom/movable/screen/movable/alert/status_effect/bloodchill

/datum/modifier/status_effect/bloodchill/on_applied()
	holder.add_modifier(/datum/modifier/movespeed/bloodchill)
	return ..()

/datum/modifier/status_effect/bloodchill/tick()
	if(prob(50))
		holder.adjustFireLoss(2)

/datum/modifier/status_effect/bloodchill/on_expire()
	holder.remove_a_modifier_of_type(/datum/modifier/movespeed/bloodchill)
	..()

/datum/modifier/status_effect/bonechill
	name = "bonechill"
	duration = 80
	alert_type = /atom/movable/screen/movable/alert/status_effect/bloodchill

/datum/modifier/status_effect/bonechill/on_applied()
	holder.add_modifier(/datum/modifier/movespeed/bonechill)
	return ..()

/datum/modifier/status_effect/bonechill/tick()
	if(prob(50))
		holder.adjustFireLoss(1)
		holder.bodytemperature -= 10

/datum/modifier/status_effect/bonechill/on_expire()
	holder.remove_a_modifier_of_type(/datum/modifier/movespeed/bonechill)
	..()

/atom/movable/screen/movable/alert/status_effect/bonechill
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
	stacks = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/firecookie/on_applied()
	ADD_TRAIT(holder, TRAIT_COLDRESIST)
	holder.bodytemperature+=110
	return ..()

/datum/modifier/status_effect/firecookie/on_expire()
	REMOVE_TRAIT(holder, TRAIT_COLDRESIST)

/datum/modifier/status_effect/watercookie
	name = "watercookie"
	stacks = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/watercookie/on_applied()
	ADD_TRAIT(holder, TRAIT_NOSLIP)
	return ..()

/datum/modifier/status_effect/watercookie/tick()
	for(var/turf/simulated/T in range(get_turf(holder),1))
		T.wet_floor(1)

/datum/modifier/status_effect/watercookie/on_expire()
	REMOVE_TRAIT(holder, TRAIT_NOSLIP)

/datum/modifier/status_effect/metalcookie
	name = "metalcookie"
	stacks = MODIFIER_STACK_EXTEND
	incoming_brute_damage_percent = 0.9
	duration = 100

/datum/modifier/status_effect/sparkcookie
	name = "sparkcookie"
	stacks = MODIFIER_STACK_EXTEND
	siemens_coefficient = 0
	duration = 300

/datum/modifier/status_effect/toxincookie
	name = "toxincookie"
	stacks = MODIFIER_STACK_EXTEND

	duration = 600

/datum/modifier/status_effect/toxincookie/on_applied()
	ADD_TRAIT(holder, TRAIT_TOXINLOVER)
	return ..()

/datum/modifier/status_effect/toxincookie/on_expire()
	REMOVE_TRAIT(holder, TRAIT_TOXINLOVER)

/datum/modifier/status_effect/timecookie
	name = "timecookie"
	stacks = MODIFIER_STACK_EXTEND

	duration = 600

/datum/modifier/status_effect/timecookie/on_applied()
	holder.add_modifier(/datum/modifier/actionspeed/timecookie)
	return ..()

/datum/modifier/status_effect/timecookie/on_expire()
	holder.remove_a_modifier_of_type(/datum/modifier/actionspeed/timecookie)
	return ..()

/datum/modifier/status_effect/lovecookie
	name = "lovecookie"
	stacks = MODIFIER_STACK_EXTEND

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
	stacks = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/tarcookie/tick()
	for(var/mob/living/carbon/human/L in range(get_turf(holder),1))
		if(L != holder)
			L.add_modifier(/datum/modifier/status_effect/tarfoot)

/datum/modifier/status_effect/tarfoot
	name = "tarfoot"
	stacks = MODIFIER_STACK_EXTEND

	duration = 30

/datum/modifier/status_effect/tarfoot/on_applied()
	holder.add_modifier(/datum/modifier/movespeed/tarfoot)
	return ..()

/datum/modifier/status_effect/tarfoot/on_expire()
	holder.remove_a_modifier_of_type(/datum/modifier/movespeed/tarfoot)

/datum/modifier/status_effect/spookcookie
	name = "spookcookie"
	stacks = MODIFIER_STACK_EXTEND

	duration = 300

/datum/modifier/status_effect/spookcookie/on_applied()
	holder.add_mutation(MUTATION_SKELETON)
	holder.regenerate_icons()
	return ..()

/datum/modifier/status_effect/spookcookie/on_expire()
	holder.remove_mutation(MUTATION_SKELETON)
	holder.regenerate_icons()

/datum/modifier/status_effect/peacecookie
	name = "peacecookie"
	stacks = MODIFIER_STACK_EXTEND

	duration = 100

/datum/modifier/status_effect/peacecookie/tick()
	for(var/mob/living/L in range(get_turf(holder),1))
		L.add_modifier(/datum/modifier/status_effect/plur)

/datum/modifier/status_effect/plur
	name = "plur"
	stacks = MODIFIER_STACK_EXTEND

	duration = 30

/datum/modifier/status_effect/plur/on_applied()
	ADD_TRAIT(holder, TRAIT_PACIFISM)
	return ..()

/datum/modifier/status_effect/plur/on_expire()
	REMOVE_TRAIT(holder, TRAIT_PACIFISM)

/datum/modifier/status_effect/adamantinecookie
	name = "adamantinecookie"
	stacks = MODIFIER_STACK_EXTEND
	incoming_fire_damage_percent = 0.9
	duration = 100

///////////////////////////////////////////////////////
//////////////////STABILIZED EXTRACTS//////////////////
///////////////////////////////////////////////////////

/datum/modifier/status_effect/stabilized //The base stabilized extract effect, has no effect of its' own.
	name = "stabilizedbase"
	var/obj/item/metroidcross/stabilized/linked_extract
	var/colour = "null"
	var/think_delay = 1 SECOND

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
			linked_extract.owner = null
		holder.remove_specific_modifier(src)
		return
	set_next_think(world.time + think_delay)
	return ..()

//Stabilized effects start below.
/datum/modifier/status_effect/stabilized/green
	name = "stabilizedgreen"
	colour = "green"

/datum/modifier/status_effect/stabilized/green/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/green/on_expire()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/green/think()
	for(var/mob/living/carbon/metroid/S in range(1, get_turf(holder)))
		if(!(holder in S.Friends))
			to_chat(holder, SPAN_NOTICE("[linked_extract] pulses gently as it communicates with [S]."))
			S.Friends += holder
	return ..()

/datum/modifier/status_effect/stabilized/orange
	name = "stabilizedorange"
	colour = "orange"

/datum/modifier/status_effect/stabilized/orange/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/orange/on_expire()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/orange/think()
	var/body_temperature_difference = holder.get_species().body_temperature - holder.bodytemperature
	holder.bodytemperature += body_temperature_difference<0?(max(-5, body_temperature_difference)):(min(5, body_temperature_difference))
	return ..()

/datum/modifier/status_effect/stabilized/purple
	name = "stabilizedpurple"
	colour = "purple"
	/// Whether we healed from our last tick
	var/healed_last_tick = FALSE

/datum/modifier/status_effect/stabilized/purple/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/purple/on_expire()
	set_next_think(0)

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
		new /obj/effect/heal(get_turf(holder), "#FF0000")

	return ..()

/datum/modifier/status_effect/stabilized/purple/_examine_text()
	if(healed_last_tick)
		return SPAN_WARNING("[holder] [holder] regenerating slowly, purplish goo filling in small injuries!")

	return null

/datum/modifier/status_effect/stabilized/blue
	name = "stabilizedblue"
	colour = "blue"

/datum/modifier/status_effect/stabilized/blue/on_applied()
	ADD_TRAIT(holder, TRAIT_NOSLIP)
	return ..()

/datum/modifier/status_effect/stabilized/blue/on_expire()
	REMOVE_TRAIT(holder, TRAIT_NOSLIP)

/datum/modifier/status_effect/stabilized/metal
	name = "stabilizedmetal"
	colour = "metal"
	var/cooldown = 30
	var/max_cooldown = 30

/datum/modifier/status_effect/stabilized/metal/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/metal/on_expire()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/metal/think()
	if(cooldown > 0)
		cooldown--
	else
		cooldown = max_cooldown
		var/list/sheets = list()
		for(var/obj/item/stack/material/S in holder.contents)
			if(S.amount < S.max_amount)
				sheets += S

		for(var/obj/item/stack/material/S in holder.back.contents)
			if(S.amount < S.max_amount)
				sheets += S

		if(sheets.len > 0)
			var/obj/item/stack/material/S = pick(sheets)
			S.amount++
			to_chat(holder, SPAN_NOTICE("[linked_extract] adds a layer of metroid to [S], which metamorphosizes into another sheet of material!"))
	return ..()


/datum/modifier/status_effect/stabilized/yellow
	name = "stabilizedyellow"
	colour = "yellow"
	var/cooldown = 10
	var/max_cooldown = 10

/datum/modifier/status_effect/stabilized/yellow/_examine_text()
	return SPAN_WARNING("Nearby electronics seem just a little more charged wherever [holder] go[holder].")

/datum/modifier/status_effect/stabilized/yellow/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/yellow/on_expire()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/yellow/think()
	if(cooldown > 0)
		cooldown--
		return ..()
	cooldown = max_cooldown
	var/list/batteries = list()
	for(var/obj/item/cell/C in holder.get_contents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/cell/ToCharge = pick(batteries)
		ToCharge.charge += min(ToCharge.maxcharge - ToCharge.charge, ToCharge.maxcharge/10) //10% of the cell, or to maximum.
		to_chat(holder, SPAN_NOTICE("[linked_extract] discharges some energy into a device you have."))
	return ..()

/obj/item/hothands
	name = "burning fingertips"
	desc = "You shouldn't see this."

/obj/item/hothands/get_temperature_as_from_ignitor()
	return 290 //Below what's required to ignite plasma.

/datum/modifier/status_effect/stabilized/darkpurple
	name = "stabilizeddarkpurple"
	colour = "dark purple"
	var/obj/item/hothands/fire

/datum/modifier/status_effect/stabilized/darkpurple/on_applied()
	ADD_TRAIT(holder, TRAIT_RESISTHEATHANDS)
	fire = new(holder)
	set_next_think(world.time+1)
	return ..()

/datum/modifier/status_effect/stabilized/darkpurple/on_expire()
	REMOVE_TRAIT(holder, TRAIT_RESISTHEATHANDS)
	qdel(fire)
	set_next_think(0)

/datum/modifier/status_effect/stabilized/darkpurple/think()
	var/obj/item/item = holder.get_active_item()
	if(item)
		item.attackby(fire, holder)
	return ..()

/datum/modifier/status_effect/stabilized/darkpurple/_examine_text()
	return SPAN_NOTICE("[holder] fingertips burn brightly!")

/datum/modifier/status_effect/stabilized/darkblue
	name = "stabilizeddarkblue"
	colour = "dark blue"

/datum/modifier/status_effect/stabilized/darkblue/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/darkblue/on_expire()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/darkblue/think()
	if(holder.fire_stacks > 0 && prob(80))
		holder.adjust_fire_stacks(-1)
		if(holder.fire_stacks > 0)
			to_chat(holder, SPAN_NOTICE("[linked_extract] coats you in a watery goo, extinguishing the flames."))
	var/obj/O = holder.get_active_item()
	if(O)
		O.clean_blood()
	// Monkey cube
	if(istype(O, /obj/item/reagent_containers/food/monkeycube))
		to_chat(holder, SPAN_WARNING("[linked_extract] kept your hands wet! It makes [O] expand!"))
		var/obj/item/reagent_containers/food/monkeycube/cube = O
		cube.Expand()

	..()

/datum/modifier/status_effect/stabilized/silver
	name = "stabilizedsilver"
	colour = "silver"
	metabolism_percent = 0.8

//Bluespace has an icon because it's kinda active.
/atom/movable/screen/movable/alert/status_effect/bluespacemetroid
	name = "Stabilized Bluespace Extract"
	desc = "You shouldn't see this, since we set it to change automatically!"
	icon_state = "metroid_bluespace_on"

/datum/modifier/status_effect/bluespacestabilization
	name = "stabilizedbluespacecooldown"
	duration = 1200


/datum/modifier/status_effect/stabilized/bluespace
	name = "stabilizedbluespace"
	colour = "bluespace"
	alert_type = /atom/movable/screen/movable/alert/status_effect/bluespacemetroid
	var/list/healthcheck = list(BRUTE = 0, BURN = 0, OXY = 0)
	think_delay = 5 SECONDS

/datum/modifier/status_effect/stabilized/bluespace/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/bluespace/on_expire()
	..()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/bluespace/think()
	if(holder.has_modifier_of_type(/datum/modifier/status_effect/bluespacestabilization))
		linked_alert.desc = "The stabilized bluespace extract is still aligning you with the bluespace axis."
		linked_alert.icon_state = "metroid_bluespace_off"
		return ..()
	else
		linked_alert.desc = "The stabilized bluespace extract will try to redirect you from harm!"
		linked_alert.icon_state = "metroid_bluespace_on"

	if(((holder.getBruteLoss() - healthcheck[BRUTE]) > 20) || ((holder.getFireLoss() - healthcheck[BURN]) > 20) || ((holder.getOxyLoss() - healthcheck[OXY]) > 20))
		holder.visible_message(SPAN_WARNING("[linked_extract] notices the sudden change in [holder]'s physical health, and activates!"))
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(5, 0, holder.loc)
		sparks.start()

		var/list/F = get_area_turfs(pick(playerlocs), list(/proc/not_turf_contains_dense_objects, /proc/IsTurfAtmosSafe))
		var/range = 0
		if(!length(F))
			F = get_turf(holder)
			range = 50
		if(do_teleport(holder, F, range))
			to_chat(holder, SPAN_NOTICE("[linked_extract] will take some time to re-align you on the bluespace axis."))
			sparks.set_up(5, 0, holder.loc)
			sparks.start()
			holder.add_modifier(/datum/modifier/status_effect/bluespacestabilization)
	healthcheck = list(BRUTE = holder.getBruteLoss(), BURN = holder.getFireLoss(), OXY = holder.getOxyLoss())
	return ..()

/datum/modifier/status_effect/stabilized/sepia
	name = "stabilizedsepia"
	colour = "sepia"
	var/mod = 0
	var/datum/modifier/movespeed/speed_mod

/datum/modifier/status_effect/stabilized/sepia/on_applied()
	speed_mod = holder.add_modifier(/datum/modifier/movespeed/sepia)
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/sepia/on_expire()
	holder.remove_a_modifier_of_type(/datum/modifier/movespeed/sepia)
	set_next_think(0)

/datum/modifier/status_effect/stabilized/sepia/think()
	if(prob(50) && mod > -1)
		mod--
		holder.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/sepia, slowdown = -0.5)
	else if(mod < 1)
		mod++
		holder.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/sepia, slowdown = 0)
	return ..()

/datum/modifier/status_effect/stabilized/cerulean
	name = "stabilizedcerulean"
	colour = "cerulean"
	var/mob/living/clone

/datum/modifier/status_effect/stabilized/cerulean/on_applied()
	if(holder.stat==DEAD)
		holder.dust()
		holder.drop(src)
		return
	var/typepath = holder.type
	clone = new typepath(holder.loc)
	var/mob/living/carbon/human/O = holder
	var/mob/living/carbon/human/C = clone
	if(istype(C) && istype(O))
		C.real_name = O.real_name
		C.set_species(O.get_species())
		C.setDNA(O.getDNA())
		C.h_style = O.h_style
		C.f_style = O.f_style
		C.UpdateAppearance()
	set_next_think(world.time+1)
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
		for(var/obj/item/I in clone.get_equipped_items())
			clone.drop(I, force = TRUE)
		qdel(clone)
	set_next_think(0)

/datum/modifier/status_effect/stabilized/pyrite
	name = "stabilizedpyrite"
	colour = "pyrite"
	var/originalcolor

/datum/modifier/status_effect/stabilized/pyrite/on_applied()
	originalcolor = holder.color
	set_next_think(world.time+1)
	return ..()

/datum/modifier/status_effect/stabilized/pyrite/think()
	holder.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	return ..()

/datum/modifier/status_effect/stabilized/pyrite/on_expire()
	holder.color = originalcolor
	set_next_think(0)

/datum/modifier/status_effect/stabilized/red
	name = "stabilizedred"
	colour = "red"

/datum/modifier/status_effect/stabilized/red/on_applied()
	. = ..()
	holder.add_modifier(/datum/modifier/movespeed/equipment_immunity_speedmod)
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/red/on_expire()
	holder.remove_modifiers_of_type(/datum/modifier/movespeed/equipment_immunity_speedmod)
	set_next_think(0)
	return ..()

/datum/modifier/status_effect/stabilized/grey
	name = "stabilizedgrey"
	colour = "grey"
	var/datum/dna/originalDNA
	var/originalname

/datum/modifier/status_effect/stabilized/grey/on_applied()
	to_chat(holder, SPAN_WARNING("You feel different..."))
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		originalDNA = H.dna.Clone()
		originalname = H.real_name
		H.real_name = H.species.get_random_name(H.gender)
		for(var/i=1 to H.dna.UI.len)
			H.dna.SetUIValue(i,rand(1,4095))

		H.UpdateAppearance()
	set_next_think(world.time+1)
	return ..()

// Only occasionally give examiners a warning.
/datum/modifier/status_effect/stabilized/grey/_examine_text()
	if(prob(50))
		return SPAN_WARNING("[holder] look[holder] a bit grey and gooey...")
	return null

/datum/modifier/status_effect/stabilized/grey/on_expire()
	to_chat(holder, SPAN_NOTICE("You feel more like yourself."))
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		H.real_name = originalname
		H.setDNA(originalDNA)
		H.UpdateAppearance()
	set_next_think(0)
	return ..()

/datum/modifier/status_effect/brokenpeace
	name = "brokenpeace"
	duration = 1200


/datum/modifier/status_effect/pinkdamagetracker
	name = "pinkdamagetracker"
	duration = 0

	var/damage = 0
	var/lasthealth
	var/think_delay = 5 SECONDS

/datum/modifier/status_effect/stabilized/pink
	name = "stabilizedpink"
	colour = "pink"

/datum/modifier/status_effect/stabilized/oil
	name = "stabilizedoil"
	colour = "oil"

/datum/modifier/status_effect/stabilized/oil/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/oil/on_expire()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/oil/think()
	if(holder.stat == DEAD)
		explosion(holder, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4)
	return ..()

/datum/modifier/status_effect/stabilized/oil/_examine_text()
	return SPAN_WARNING("[holder] smell[holder] of sulfer and oil!")

/// How much damage is dealt per healing done for the stabilized back.
/// This multiplier is applied to prevent two people from converting each other's damage away.
#define DRAIN_DAMAGE_MULTIPLIER 0.75

/datum/modifier/status_effect/stabilized/black
	name = "stabilizedblack"
	colour = "black"
	/// How much we heal per tick (also how much we damage per tick times DRAIN_DAMAGE_MULTIPLIER).
	var/heal_amount = 3
	/// Weakref to the mob we're currently draining every tick.
	var/weakref/draining_ref

/datum/modifier/status_effect/stabilized/black/on_applied()
	register_signal(holder, SIGNAL_MOB_GRAB_SET_STATE, nameof(.proc/on_grab))
	set_next_think(world.time+1)
	return ..()

/datum/modifier/status_effect/stabilized/black/on_expire()
	unregister_signal(holder, SIGNAL_MOB_GRAB_SET_STATE)
	set_next_think(0)
	return ..()

/// Whenever we grab someone by the neck, set "draining" to a weakref of them.
/datum/modifier/status_effect/stabilized/black/proc/on_grab(mob/living/source, new_state, target)
	if(new_state != NORM_KILL || !isliving(target))
		draining_ref = null
		return

	var/mob/living/draining = target
	if(draining.stat == DEAD)
		return

	draining_ref = weakref(draining)
	to_chat(holder, SPAN_NOTICE(FONT_LARGE("You feel your hands melt around [draining]'s neck as you start to drain [draining] of [draining] life!")))
	to_chat(draining, SPAN_DANGER(FONT_LARGE("[holder]'s hands melt around your neck as you can feel your life starting to drain away!")))

/datum/modifier/status_effect/stabilized/black/_examine_text()
	var/mob/living/draining = draining_ref?.resolve()
	if(!draining)
		return null

	return SPAN_WARNING("[holder] are draining health from [draining]!")

/datum/modifier/status_effect/stabilized/black/think()
	..()
	if(!iscarbon(holder))
		return
	var/mob/living/carbon/C = holder
	var/obj/item/grab/G
	if(istype(C.l_hand, /obj/item/grab))
		G = C.l_hand
	else
		if(istype(C.r_hand, /obj/item/grab))
			G = C.r_hand

	if(!istype(G))
		return

	if(G.current_grab.state_name != NORM_KILL || !IS_WEAKREF_OF(G.affecting, draining_ref))
		return

	var/mob/living/drained = draining_ref.resolve()
	if(drained.stat == DEAD)
		to_chat(C, SPAN_WARNING("[drained] is dead, you cannot drain anymore life from them!"))
		draining_ref = null
		return
	if(C.getBruteLoss() > 0)
		drained.adjustBruteLoss(heal_amount * DRAIN_DAMAGE_MULTIPLIER)
		C.adjustBruteLoss(-heal_amount)
	if(C.getFireLoss() > 0)
		drained.adjustFireLoss(heal_amount * DRAIN_DAMAGE_MULTIPLIER)
		C.adjustFireLoss(-heal_amount)
	if(C.getToxLoss() > 0)
		drained.adjustToxLoss(heal_amount * DRAIN_DAMAGE_MULTIPLIER)
		C.adjustToxLoss(-heal_amount)
	if(C.getCloneLoss() > 0)
		drained.adjustCloneLoss(heal_amount * DRAIN_DAMAGE_MULTIPLIER)
		C.adjustCloneLoss(-heal_amount)

	C.add_nutrition(3)

#undef DRAIN_DAMAGE_MULTIPLIER

/datum/modifier/status_effect/stabilized/lightpink
	name = "stabilizedlightpink"
	colour = "light pink"
	think_delay = 5 SECONDS

/datum/modifier/status_effect/stabilized/lightpink/on_applied()
	holder.add_modifier(/datum/modifier/movespeed/lightpink)
	ADD_TRAIT(holder, TRAIT_PACIFISM)
	set_next_think(world.time+1)
	return ..()

/datum/modifier/status_effect/stabilized/lightpink/think()
	for(var/mob/living/carbon/human/H in range(1, get_turf(holder)))
		if(H != holder && H.stat != DEAD && (H.getBruteLoss() >= 80 || H.getFireLoss() >= 80 || H.getOxyLoss() >= 30)  && !H.reagents.has_reagent(/datum/reagent/inaprovaline))
			to_chat(holder, "[linked_extract] pulses in sync with [H]'s heartbeat, trying to keep [H] alive.")
			H.reagents.add_reagent(/datum/reagent/inaprovaline,5)
	return ..()

/datum/modifier/status_effect/stabilized/lightpink/on_expire()
	holder.remove_a_modifier_of_type(/datum/modifier/movespeed/lightpink)
	REMOVE_TRAIT(holder, TRAIT_PACIFISM)
	set_next_think(0)


/datum/modifier/status_effect/stabilized/gold
	name = "stabilizedgold"
	colour = "gold"
	var/mob/living/simple_animal/familiar

/datum/modifier/status_effect/stabilized/gold/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/gold/think()
	var/obj/item/metroidcross/stabilized/gold/linked = linked_extract
	if(isnull(familiar))
		familiar = new linked.mob_type(get_turf(holder.loc))
		familiar.name = linked.mob_name
		familiar.add_language(LANGUAGE_GALCOM)
		if(linked.saved_mind)
			linked.saved_mind.transfer_to(familiar)
			familiar.ckey = linked.saved_mind.key
	else
		if(familiar.mind)
			linked.saved_mind = familiar.mind
	return ..()

/datum/modifier/status_effect/stabilized/gold/on_expire()
	if(familiar)
		qdel(familiar)
	set_next_think(0)

/datum/modifier/status_effect/stabilized/adamantine
	name = "stabilizedadamantine"
	colour = "adamantine"
	incoming_brute_damage_percent = 0.75

/datum/modifier/status_effect/stabilized/adamantine/_examine_text()
	return SPAN_WARNING("[holder] have strange metallic coating on [holder] skin.")

/datum/modifier/status_effect/stabilized/rainbow
	name = "stabilizedrainbow"
	colour = "rainbow"

/datum/modifier/status_effect/stabilized/rainbow/on_applied()
	set_next_think(world.time+1)

/datum/modifier/status_effect/stabilized/rainbow/on_expire()
	set_next_think(0)

/datum/modifier/status_effect/stabilized/rainbow/proc/check_mob_crit(mob/M)
	if(!ishuman(M))
		M.gib()
		return FALSE
	var/mob/living/carbon/human/H = M
	if(H.is_asystole() && !isundead(H))
		return TRUE
	var/trauma_val = max(H.shock_stage, H.get_shock()) / H.species.total_health
	if(trauma_val > 0.7)
		return TRUE

/datum/modifier/status_effect/stabilized/rainbow/think()
	if(check_mob_crit(holder))
		var/obj/item/metroidcross/stabilized/rainbow/X = linked_extract
		if(istype(X))
			if(X.regencore)
				X.regencore.afterattack(holder,holder,TRUE)
				X.regencore = null
				holder.visible_message(SPAN_WARNING("[holder] flashes a rainbow of colors, and [holder] skin is coated in a milky regenerative goo!"))
				holder.remove_specific_modifier(src)
				qdel(linked_extract)
	return ..()

/datum/modifier/status_effect/adamantine
	name = "adamantine"
	incoming_damage_percent = 0.75
	duration = 1200

/datum/modifier/status_effect/burningpurple
	name = "burningpurple"
	stacks = MODIFIER_STACK_EXTEND

	duration = 1 MINUTE

/datum/modifier/status_effect/burningpurple/on_applied()
	ADD_TRAIT(holder, /datum/modifier/movespeed/lightpink)

/datum/modifier/status_effect/burningpurple/on_expire()
	REMOVE_TRAIT(holder, /datum/modifier/movespeed/lightpink)
