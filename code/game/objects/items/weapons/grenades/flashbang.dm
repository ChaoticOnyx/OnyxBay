/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = list(TECH_MATERIAL = 2, TECH_COMBAT = 1)
	var/banglet = 0

/obj/item/weapon/grenade/flashbang/detonate()
	..()
	for(var/obj/structure/closet/L in hear(7, get_turf(src)))
		if(locate(/mob/living/carbon/, L))
			for(var/mob/living/carbon/M in L)
				bang(get_turf(src), M)

	for(var/mob/living/carbon/M in hear(7, get_turf(src)))
		bang(get_turf(src), M)

	for(var/obj/effect/blob/B in hear(8, get_turf(src)))       		// Blob damage here
		var/damage = round(30 / (get_dist(B,get_turf(src)) + 1))
		B.health -= damage
		B.update_icon()

	new /obj/effect/sparks(loc)
	new /obj/effect/effect/smoke/illumination(loc, 5, range = 30, power = 1, color = "#ffffff")
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/proc/bang(turf/T , mob/living/carbon/M) // Added a new proc called 'bang' that takes a location and a person to be banged.
	to_chat(M, SPAN("danger", "*BANG*"))                // Called during the loop that bangs people in lockers/containers and when banging
	playsound(loc, 'sound/effects/bang.ogg', 50, 1, 30) // people in normal view. Could theroetically be called during other explosions.
															// -- Polymorph
	// Checking for protections
	var/eye_effect = 0
	var/ear_effect = 0
	if(iscarbon(M))
		eye_effect = M.eyecheck()
		ear_effect = M.get_ear_protection()

	// Checking for distance tresholds
	var/distance_tier = 1
	if(M == loc)
		distance_tier = 7
	else if(get_dist(M, T) <= 1)
		distance_tier = 5
	else if(get_dist(M, T) <= 3)
		distance_tier = 3
	else if(get_dist(M, T) <= 5)
		distance_tier = 2

	eye_effect = distance_tier - eye_effect
	ear_effect = distance_tier - ear_effect

	// Blinding effect
	if(eye_effect >= 6)
		M.Stun(eye_effect)
		M.Weaken(eye_effect * 1.5)

	if(eye_effect >= 5)
		M.confused = max(M.confused, eye_effect) // No need to stack these

	if(eye_effect >= 3)
		M.eye_blurry += eye_effect // But stacking these doesn't hurt too much

	if(eye_effect >= 0)
		M.flash_eyes(intensity = INFINITY, type = /obj/screen/fullscreen/flash/persistent, effect_duration = (10 * eye_effect))

	// Deafening effect
	if(ear_effect >= 3)
		M.Stun(ear_effect)
		M.Weaken(ear_effect)

	if(ear_effect >= 1)
		if(prob(ear_effect * 2) || (M == loc && prob(70)))
			M.ear_damage += rand(1, 10)
		else
			M.ear_damage += rand(0, 5)
		M.ear_deaf = max(M.ear_deaf, (ear_effect * 3))

	// This really should be in mob not every check
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[BP_EYES]
		if(E?.damage >= E.min_bruised_damage)
			to_chat(M, SPAN("danger", "Your eyes start to burn badly!"))
			if(!banglet && !istype(src, /obj/item/weapon/grenade/flashbang/clusterbang))
				if(E.damage >= E.min_broken_damage)
					to_chat(M, SPAN("danger", "You can't see anything!"))
	if(M.ear_damage >= 15)
		to_chat(M, SPAN("danger", "Your ears start to ring badly!"))
		if(!banglet && !istype(src, /obj/item/weapon/grenade/flashbang/clusterbang))
			if(prob(M.ear_damage - 5))
				to_chat(M, SPAN("danger", "You can't hear anything!"))
				M.sdisabilities |= DEAF
	else
		if(M.ear_damage >= 5)
			to_chat(M, SPAN("danger", "Your ears start to ring!"))
	M.update_icons()

/obj/item/weapon/grenade/flashbang/Destroy()
	walk(src, 0) // Because we might have called walk_away, we must stop the walk loop or BYOND keeps an internal reference to us forever.
	return ..()

/obj/item/weapon/grenade/flashbang/instant/Initialize()
	. = ..()
	name = "arcane energy"
	icon_state = null
	item_state = null
	detonate()

/obj/item/weapon/grenade/flashbang/clusterbang//Created by Polymorph, fixed by Sieve
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"

/obj/item/weapon/grenade/flashbang/clusterbang/detonate()
	var/numspawned = rand(4,8)
	var/again = 0
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(src.loc)//Launches flashbangs
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	for(,again > 0, again--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/clusterbang/segment(src.loc)//Creates a 'segment' that launches a few more flashbangs
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/clusterbang/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/flashbang/clusterbang/segment/New()//Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	icon_state = "clusterbang_segment_active"
	active = 1
	banglet = 1
	var/stepdist = rand(1,4)//How far to step
	var/temploc = src.loc//Saves the current location to know where to step away from
	walk_away(src,temploc,stepdist)//I must go, my people need me
	var/dettime = rand(15,60)
	spawn(dettime)
		detonate()
	..()

/obj/item/weapon/grenade/flashbang/clusterbang/segment/detonate()
	var/numspawned = rand(4,8)
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(src.loc)
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/cluster/New()//Same concept as the segments, so that all of the parts don't become reliant on the clusterbang
	spawn(0)
		icon_state = "flashbang_active"
		active = 1
		banglet = 1
		var/stepdist = rand(1,3)
		var/temploc = src.loc
		walk_away(src,temploc,stepdist)
		var/dettime = rand(15,60)
		spawn(dettime)
		detonate()
	..()
