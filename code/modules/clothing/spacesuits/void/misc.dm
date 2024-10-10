
//Deathsquad suit
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad_helm"
	item_state = "deathsquad_helm"
	armor = list(melee = 120, bullet = 150, laser = 150, energy = 65, bomb = 90, bio = 100)
	item_flags = ITEM_FLAG_STOPPRESSUREDAMAGE | ITEM_FLAG_THICKMATERIAL
	flags_inv = BLOCKHAIR
	siemens_coefficient = 0.6
	rad_resist_type = /datum/rad_resist/deathsquad

/obj/item/clothing/suit/space/void/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad_voidsuit"
	item_state = "deathsquad_voidsuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/gun, /obj/item/ammo_magazine, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/handcuffs, /obj/item/tank)
	armor = list(melee = 120, bullet = 150, laser = 150, energy = 65, bomb = 90, bio = 100)
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0.6
	rad_resist_type = /datum/rad_resist/deathsquad

/obj/item/clothing/suit/space/void/deathsquad/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 1

/datum/rad_resist/deathsquad
	alpha_particle_resist = 59.4 MEGA ELECTRONVOLT
	beta_particle_resist = 13.2 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/suit/space/void/deathsquad/prepared
	helmet = /obj/item/clothing/head/helmet/space/deathsquad
	boots = /obj/item/clothing/shoes/magboots

// Captain
/obj/item/clothing/head/helmet/space/void/captain
	name = "captain's space helmet"
	desc = "A special heavily armored helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	icon_state = "cap_helm"
	item_state = "cap_helm"
	armor = list(melee = 90, bullet = 80, laser = 90, energy = 40, bomb = 55, bio = 100)
	siemens_coefficient = 0.5
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/captain
	name = "captain's space armor"
	desc = "A bulky, heavy-duty piece of exclusive corporate hardsuit. YOU are in charge!"
	icon_state = "cap_voidsuit"
	item_state = "cap_voidsuit"
	armor = list(melee = 90, bullet = 80, laser = 90, energy = 40, bomb = 55, bio = 100)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit, /obj/item/ammo_magazine, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/handcuffs, /obj/item/disk/nuclear)
	siemens_coefficient = 0.5

/obj/item/clothing/suit/space/void/captain/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/captain
	boots = /obj/item/clothing/shoes/magboots


// Exploration
/obj/item/clothing/head/helmet/space/void/exploration
	name = "exploration voidhelmet"
	desc = "A radiation-resistant helmet made especially for exploring unknown planetary environments."
	icon_state = "explorer_helm"
	item_state = "explorer_helm"
	armor = list(melee = 20, bullet = 10, laser = 15,energy = 45, bomb = 30, bio = 100)
	light_overlay = "explorer_light"
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/obj/item/clothing/suit/space/void/exploration
	name = "exploration voidsuit"
	desc = "A lightweight, radiation-resistant voidsuit, featuring the Expeditionary Corps emblem on its chest plate. Designed for exploring unknown planetary environments."
	icon_state = "explorer_voidsuit"
	item_state = "explorer_voidsuit"
	armor = list(melee = 20, bullet = 10, laser = 15,energy = 45, bomb = 30, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/healthanalyzer,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/device/bluespace_beacon,/obj/item/material/hatchet/machete,/obj/item/shovel)
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/obj/item/clothing/suit/space/void/exploration/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/exploration
	boots = /obj/item/clothing/shoes/magboots


// Salvage
/obj/item/clothing/head/helmet/space/void/engineering/salvage
	name = "salvage voidhelmet"
	desc = "A heavily modified salvage voidsuit helmet. It has been fitted with radiation-resistant plating."
	icon_state = "salvage_helm"
	item_state = "salvage_helm"
	armor = list(melee = 50, bullet = 10, laser = 30,energy = 15, bomb = 35, bio = 100)
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/obj/item/clothing/suit/space/void/engineering/salvage
	name = "salvage voidsuit"
	desc = "A hand-me-down salvage voidsuit. It has obviously had a lot of repair work done to its radiation shielding."
	icon_state = "salvage_voidsuit"
	item_state = "salvage_voidsuit"
	armor = list(melee = 50, bullet = 10, laser = 30,energy = 15, bomb = 35, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/construction/rcd)
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/datum/rad_resist/void_engi_salvage
	alpha_particle_resist = 400 MEGA ELECTRONVOLT
	beta_particle_resist = 300 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/suit/space/void/engineering/salvage/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/salvage
	boots = /obj/item/clothing/shoes/magboots


// Pilot
/obj/item/clothing/head/helmet/space/void/pilot
	name = "pilot voidhelmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "pilot_helm"
	item_state = "pilot_helm"
	armor = list(melee = 40, bullet = 10, laser = 35,energy = 15, bomb = 0, bio = 100)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/pilot
	name = "pilot voidsuit"
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "pilot_voidsuit"
	item_state = "pilot_voidsuit"
	armor = list(melee = 40, bullet = 10, laser = 35,energy = 15, bomb = 0, bio = 100)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/construction/rcd)

/obj/item/clothing/suit/space/void/pilot/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/pilot
	boots = /obj/item/clothing/shoes/magboots


// Knight
/obj/item/clothing/head/helmet/space/void/knight
	name = "strange voidhelmet"
	desc = "A bulky helmet with some heavy armor plating."
	icon_state = "hardsuit_knight_helm"
	item_state = "hardsuit_knight_helm"
	armor = list(melee = 70, bullet = 35, laser = 35, energy = 25, bomb = 55, bio = 100)
	siemens_coefficient = 0.7
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/knight
	icon_state = "hardsuit_knight"
	item_state = "hardsuit_knight"
	name = "strange voidsuit"
	desc = "A bulky set of space-proof armor, that looks kinda ancient. 'Lancelot X-40' is written on the front plate."
	armor = list(melee = 70, bullet = 35, laser = 35, energy = 25, bomb = 55, bio = 100)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)
	siemens_coefficient = 0.7


// Optical
/obj/item/clothing/head/helmet/space/void/optical
	name = "experimental voidhelmet"
	icon_state = "hardsuit_optical_helm"
	item_state = "hardsuit_optical_helm"
	desc = "Strange looking, smoothly contoured helmet. It looks a bit blurry."
	siemens_coefficient = 0
	armor = list(melee = 35, bullet = 40, laser = 45, energy = 40, bomb = 20, bio = 100)

/obj/item/clothing/suit/space/void/optical
	name = "experimental voidsuit"
	icon_state = "hardsuit_optical"
	item_state = "hardsuit_optical"
	desc = "Strange black voidsuit, with some devices attached to it. It looks a bit blurry."
	action_button_name = "Toggle Optical Disruptor"
	siemens_coefficient = 0
	armor = list(melee = 35, bullet = 40, laser = 45, energy = 40, bomb = 20, bio = 100)
	var/cloak = FALSE

/obj/item/clothing/suit/space/void/optical/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

/obj/item/clothing/suit/space/void/optical/attack_self(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/void/optical))
		return
	cloak(H)

/obj/item/clothing/suit/space/void/optical/proc/cloak(mob/living/carbon/human/H)
	if(cloak)
		cloak = FALSE
		return 1

	to_chat(H, "<span class='notice'>Optical disruptor activated.</span>")
	cloak = TRUE
	animate(H,alpha = 255, alpha = 85, time = 10)

	var/remain_cloaked = TRUE
	while(remain_cloaked)
		sleep(1 SECOND)
		if(!cloak)
			remain_cloaked = 0
		if(H.stat)
			remain_cloaked = 0
		if(!istype(H.head, /obj/item/clothing/head/helmet/space/void/optical))
			remain_cloaked = 0
	H.invisibility = initial(H.invisibility)
	H.visible_message("<span class='warning'>[H] suddenly fades in.</span>",
	"<span class='notice'>Optical disruptor deactivated.</span>")
	cloak = FALSE

	animate(H,alpha = 85, alpha = 255, time = 10)

/obj/item/clothing/head/helmet/space/void/templar
	name = "templar helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "templar"
	item_state = "templar"
	armor = list(melee = 40, bullet = 5, laser = 15,energy = 5, bomb = 5, bio = 100)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/head/helmet/space/void/scuba
	name = "scuba helmet"
	desc = "An atmos resistant helmet for space and planet exploration."
	icon_state = "scuba"
	item_state = "scuba"
	armor = list(melee = 40, bullet = 5, laser = 15,energy = 5, bomb = 5, bio = 100)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"
