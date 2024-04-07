//Skrell space gear. Sleek like a wetsuit.
/obj/item/clothing/head/helmet/space/skrell
	name = "Skrellian helmet"
	desc = "Smoothly contoured and polished to a shine. Still looks like a fishbowl."
	armor = list(melee = 20, bullet = 20, laser = 50,energy = 50, bomb = 50, bio = 100)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(SPECIES_SKRELL,SPECIES_HUMAN)
	rad_resist_type = /datum/rad_resist/space_vox

/obj/item/clothing/head/helmet/space/skrell/white
	icon_state = "skrell_helmet_white"

/obj/item/clothing/head/helmet/space/skrell/black
	icon_state = "skrell_helmet_black"

/obj/item/clothing/suit/space/skrell
	name = "Skrellian voidsuit"
	desc = "Seems like a wetsuit with reinforced plating seamlessly attached to it. Very chic."
	armor = list(melee = 20, bullet = 20, laser = 50,energy = 50, bomb = 50, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/storage/ore,/obj/item/device/t_scanner,/obj/item/pickaxe, /obj/item/construction/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(SPECIES_SKRELL,SPECIES_HUMAN)
	rad_resist_type = /datum/rad_resist/space_vox

/obj/item/clothing/suit/space/skrell/white
	icon_state = "skrell_suit_white"

/obj/item/clothing/suit/space/skrell/black
	icon_state = "skrell_suit_black"

// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.
/obj/item/clothing/suit/space/vox
	w_class = ITEM_SIZE_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/pirate,/obj/item/handcuffs,/obj/item/tank)
	armor = list(melee = 60, bullet = 50, laser = 40,energy = 15, bomb = 30, bio = 100)
	siemens_coefficient = 0.6
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(SPECIES_VOX)
	rad_resist_type = /datum/rad_resist/space_vox

/datum/rad_resist/space_vox
	alpha_particle_resist = 40 MEGA ELECTRONVOLT
	beta_particle_resist = 8.9 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/suit/space/vox/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 2

/obj/item/clothing/head/helmet/space/vox
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 15, bomb = 30, bio = 100)
	siemens_coefficient = 0.6
	flags_inv = 0
	species_restricted = list(SPECIES_VOX)
	rad_resist_type = /datum/rad_resist/space_vox

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 30, bomb = 90, bio = 100)

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."
	action_button_name = "Toggle Bio-RCD"
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 30, bomb = 90, bio = 100)
	var/tool_delay = 120 SECONDS
	var/last_used = 0

/obj/item/clothing/suit/space/vox/pressure/attack_self(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/pressure))
		return
	if(!(world.time > last_used))
		to_chat(H, "<span class='danger'>[src] is recharging.</span>")
		return
	last_used = world.time + tool_delay
	spawn_vox_rcd(H)

/obj/item/clothing/suit/space/vox/pressure/proc/spawn_vox_rcd(mob/living/carbon/human/H)
	if(H.l_hand && H.r_hand)
		to_chat(H, "<span class='danger'>Your hands are full.</span>")
		return

	var/obj/item/I = new /obj/item/vox_rcd(H)
	H.pick_or_drop(I)
////////////RCD


/obj/item/vox_rcd
	name = "Deconstruction device"
	var/charge = 3
	var/mob/living/creator //This is just like ninja swords, needed to make sure dumb shit that removes the sword doesn't make it stay around.
	icon = 'icons/obj/guns/gun.dmi'
	icon_state = "voxrcd"
	desc = "A small device filled with biorobots."
	var/mode = 1 //We have 3 types of mode, 1 - deconstruct, 2 - construct, 3 - construct doors

/obj/item/vox_rcd/attack_self(mob/user)
	playsound(src, 'sound/voice/alien_roar_larva2.ogg', 30, 1)
	switch(mode)
		if(1)
			mode = 2
			to_chat(user, "<span class='notice'>Changed mode to construct</span>")
		if(2)
			mode = 3
			to_chat(user, "<span class='notice'>Changed mode to construct doors</span>")
		if(3)
			mode = 1
			to_chat(user, "<span class='notice'>Changed mode to deconstruct</span>")

/obj/item/vox_rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(charge == 0)
		user.visible_message("<span class='warning'>With a slight hiss, the [src] dissolves.</span>",
		"<span class='notice'>You turn off your device.</span>",
		"<span class='italics'>You hear a faint hiss.</span>")
		playsound(src, 'sound/effects/flare.ogg', 30, 1)
		spawn(1)
			if(src)
				qdel(src)
		return

	switch(mode)
		if(1)
			new /obj/effect/acid(get_turf(A), A)
			charge--
		if(2)
			if(!istype(A, /turf/simulated/floor))
				var/turf/T = A
				T.ChangeTurf(/turf/simulated/floor/misc/diona)
				charge--
			else
				if(istype(A.loc, /turf/simulated/wall) || istype(A.loc, /obj/machinery/door))
					return
				var/turf/T = A
				new /obj/structure/alien/resin/wall(get_turf(T), T)
				charge--
		if(3)
			if(istype(A, /turf/simulated/floor))
				if(istype(A.loc, /turf/simulated/wall) || istype(A.loc, /obj/machinery/door))
					return
				new /obj/machinery/door/unpowered/simple/resin(get_turf(A), A)
				charge--
	playsound(src, 'sound/effects/flare.ogg', 30, 1)
	if(charge == 0)
		user.visible_message("<span class='warning'>With a slight hiss, the [src] dissolves.</span>",
		"<span class='notice'>You turn off your device.</span>",
		"<span class='italics'>You hear a faint hiss.</span>")
		spawn(1)
			if(src)
				qdel(src)
		return

/obj/item/vox_rcd/dropped(mob/user)
	user.visible_message("<span class='warning'>With a slight hiss, the [src] dissolves.</span>",
	"<span class='notice'>You turn off our device.</span>",
	"<span class='italics'>You hear a faint hiss.</span>")
	playsound(src, 'sound/effects/flare.ogg', 30, 1)
	spawn(1)
		if(src)
			qdel(src)
//RCD/////////////////////

/obj/item/alien_med_device
	name = "Med-device"
	var/charge = 3
	icon = 'icons/obj/guns/gun.dmi'
	icon_state = "voxrcd"
	desc = "A small bio-device with teeth."
	var/recharge_time = 120 SECONDS
	var/max_ammo = 3
	var/ammo = 3
	var/last_regen = 0

/obj/item/alien_med_device/afterattack(atom/A, mob/user, proximity)
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/V = A
	if(ammo >= 1)
		if(istype(V, /mob/living/carbon/human/vox))
			playsound(V.loc, 'sound/effects/flare.ogg', 30, 1)
			V.reagents.add_reagent(/datum/reagent/peridaxon, 5)
			to_chat(V, "<span class='notice'>You feel a tiny prick!</span>")
			ammo--
		else
			playsound(V.loc, 'sound/weapons/bite.ogg', 30, 1)
			V.reagents.add_reagent(/datum/reagent/toxin/amatoxin, 5)
			to_chat(V, "<span class='notice'>You were bitten!</span>")
			ammo--
	else
		playsound(src, 'sound/voice/alien_roar_larva2.ogg', 30, 1)
		to_chat(user, "<span class='notice'>[src] is discharged.</span>")

/obj/item/alien_med_device/Initialize()
	. = ..()
	set_next_think(world.time)
	last_regen = world.time

/obj/item/alien_med_device/think()
	if((ammo < max_ammo) && (world.time > (last_regen + recharge_time)))
		ammo++
		last_regen = world.time

	set_next_think(world.time + 1 SECOND)

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	action_button_name = "Toggle Protection"
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 30, bomb = 40, bio = 100)
	var/protection = FALSE

/obj/item/clothing/suit/space/vox/carapace/attack_self(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/carapace))
		return
	protection(H)

/obj/item/clothing/suit/space/vox/carapace/proc/protection(mob/living/carbon/human/H)
	if(protection)
		to_chat(H, "<span class='notice'>You deactivate the protection mode.</span>")
		armor = list(melee = 60, bullet = 50, laser = 40, energy = 30, bomb = 60, bio = 100)
		siemens_coefficient = 0.6
		if(istype(H.head, /obj/item/clothing/head/helmet/space/vox/carapace))
			H.head.armor = list(melee = 60, bullet = 50, laser = 40, energy = 40, bomb = 60, bio = 100)
			H.head.siemens_coefficient = 0.6
			H.head.item_state = "vox-carapace"
		slowdown_per_slot[slot_wear_suit] = 3
		item_state = "vox-carapace"
	else
		to_chat(H, "<span class='notice'>You activate the protection mode.</span>")
		armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 60, bio = 100)
		siemens_coefficient = 0.2
		if(istype(H.head, /obj/item/clothing/head/helmet/space/vox/carapace))
			H.head.armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 60, bio = 100)
			H.head.siemens_coefficient = 0.2
			H.head.item_state = "vox-carapace-active"
		slowdown_per_slot[slot_wear_suit] = 20
		item_state = "vox-carapace-active"
	protection = !protection

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."
	siemens_coefficient = 0
	armor = list(melee = 25, bullet = 40, laser = 65, energy = 40, bomb = 20, bio = 100)

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very light."
	action_button_name = "Toggle Cloak"
	siemens_coefficient = 0
	armor = list(melee = 25, bullet = 30, laser = 65, energy = 30, bomb = 20, bio = 100)
	var/cloak = FALSE

/obj/item/clothing/suit/space/vox/stealth/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

/obj/item/clothing/suit/space/vox/stealth/attack_self(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/stealth))
		return
	cloak(H)

/obj/item/clothing/suit/space/vox/stealth/proc/cloak(mob/living/carbon/human/H)
	if(cloak)
		cloak = FALSE
		return 1

	to_chat(H, "<span class='notice'>Stealth mode enabled.</span>")
	cloak = TRUE
	animate(H,alpha = 255, alpha = 20, time = 10)

	var/remain_cloaked = TRUE
	while(remain_cloaked) //This loop will keep going until the player uncloaks.
		sleep(1 SECOND) // Sleep at the start so that if something invalidates a cloak, it will drop immediately after the check and not in one second.
		if(!cloak)
			remain_cloaked = 0
		if(H.stat) // I love lings so much
			remain_cloaked = 0
		if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/stealth))
			remain_cloaked = 0
	H.invisibility = initial(H.invisibility)
	H.visible_message("<span class='warning'>[H] suddenly fades in, seemingly from nowhere!</span>",
	"<span class='notice'>Stealth mode disabled.</span>")
	cloak = FALSE

	animate(H,alpha = 20, alpha = 255, time = 10)

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."
	armor = list(melee = 60, bullet = 50, laser = 40,energy = 15, bomb = 30, bio = 100)
	siemens_coefficient = 0.3

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."
	siemens_coefficient = 0.3
	armor = list(melee = 60, bullet = 50, laser = 40,energy = 15, bomb = 30, bio = 100)
	action_button_name = "Toggle Nanobots"
	var/nanobots = FALSE //user

/obj/item/clothing/suit/space/vox/medic/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/obj/item/clothing/suit/space/vox/medic/attack_self(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/medic))
		return
	nanobots(H)

/obj/item/clothing/suit/space/vox/medic/proc/nanobots(mob/living/carbon/human/H)
	if(nanobots)
		nanobots = FALSE
		to_chat(H, "<span class='notice'>Nanobots deactivated.</span>")
		item_state = "vox-medic"
		set_light(0)
		slowdown_per_slot[slot_wear_suit] = 1
	else
		nanobots = TRUE
		item_state = "vox-medic-active"
		to_chat(H, "<span class='notice'>Nanobots activated.</span>")
		set_light(0.5, 0.1, 3, 2, "#e09d37")
		slowdown_per_slot[slot_wear_suit] = 10

/obj/item/clothing/suit/space/vox/medic/equipped()
	set_next_think(world.time)
	return ..()

/obj/item/clothing/suit/space/vox/medic/think()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/H = loc
	if(!H.client)
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/medic))
		return
	if(H.stat != CONSCIOUS)
		return
	if(nanobots)
		for(var/mob/living/carbon/human/vox/V in range(2, H))
			for(var/obj/item/organ/external/regen_organ in V.organs)
				regen_organ.damage = max(regen_organ.damage - 2, 0)
			if(V.getBruteLoss())
				V.adjustBruteLoss(-5 * config.health.organ_regeneration_multiplier)	//Heal brute better than other ouchies.
			if(V.getFireLoss())
				V.adjustFireLoss(-5 * config.health.organ_regeneration_multiplier)
			if(V.getToxLoss())
				V.adjustToxLoss(-5 * config.health.organ_regeneration_multiplier)
			if(V.reagents.get_reagent_amount(/datum/reagent/painkiller/paracetamol) + 5 <= 20)
				V.reagents.add_reagent(/datum/reagent/painkiller/paracetamol, 5)
	else
		for(var/mob/living/carbon/human/vox/V in range(1, H))
			if(V.getBruteLoss())
				V.adjustBruteLoss(-2 * config.health.organ_regeneration_multiplier)	//Heal brute better than other ouchies.
			if(V.getFireLoss())
				V.adjustFireLoss(-2 * config.health.organ_regeneration_multiplier)
			if(V.getToxLoss())
				V.adjustToxLoss(-2 * config.health.organ_regeneration_multiplier)
			if(V.reagents.get_reagent_amount(/datum/reagent/painkiller/paracetamol) + 5 <= 20)
				V.reagents.add_reagent(/datum/reagent/painkiller/paracetamol, 5)

	set_next_think(world.time + 1 SECOND)

/obj/item/storage/belt/vox
	name = "Vox belt"
	desc = "High-tech belt with mounts for any objects."
	icon_state = "voxbelt"
	storage_slots = 9
	item_state = "voxbelt"
	max_storage_space = DEFAULT_BACKPACK_STORAGE + 5

/obj/item/clothing/under/vox
	has_sensor = 0
	species_restricted = list(SPECIES_VOX)

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	item_state = "vox-casual-1"
	body_parts_covered = LEGS

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	item_state = "vox-casual-2"

/obj/item/clothing/gloves/vox
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	name = "insulated gauntlets"
	icon_state = "gloves-vox"
	item_state = "gloves-vox"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	species_restricted = list(SPECIES_VOX)

/obj/item/clothing/shoes/magboots/vox

	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	name = "vox magclaws"
	item_state = "boots-vox"
	icon_state = "boots-vox"
	species_restricted = list(SPECIES_VOX)

	action_button_name = "Toggle the magclaws"

/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(src.magpulse)
		item_flags &= ~ITEM_FLAG_NOSLIP
		magpulse = 0
		canremove = 1
		to_chat(user, "You relax your deathgrip on the flooring.")
	else
		//make sure these can only be used when equipped.
		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		if (H.shoes != src)
			to_chat(user, "You will have to put on the [src] before you can do that.")
			return

		item_flags |= ITEM_FLAG_NOSLIP
		magpulse = 1
		canremove = 0	//kinda hard to take off magclaws when you are gripping them tightly.
		to_chat(user, "You dig your claws deeply into the flooring, bracing yourself.")
		to_chat(user, "It would be hard to take off the [src] without relaxing your grip first.")
	user.update_action_buttons()

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user as mob)
	..()
	if(src.magpulse)
		user.visible_message("The [src] go limp as they are removed from [usr]'s feet.", "The [src] go limp as they are removed from your feet.")
		item_flags &= ~ITEM_FLAG_NOSLIP
		magpulse = 0
		canremove = 1

/obj/item/clothing/shoes/magboots/vox/examine(mob/user, infix)
	. = ..()

	if(magpulse)
		. += "It would be hard to take these off without relaxing your grip first."//theoretically this message should only be seen by the wearer when the claws are equipped.
