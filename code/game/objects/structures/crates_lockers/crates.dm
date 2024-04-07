/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	atom_flags = ATOM_FLAG_CLIMBABLE
	pull_sound = SFX_PULL_BOX
	pull_slowdown = PULL_SLOWDOWN_MEDIUM
	setup = 0
	open_delay = 3

	dremovable = 0
	intact_closet = FALSE

	storage_types = CLOSET_STORAGE_ITEMS

	var/points_per_crate = 5
	var/rigged = 0

	var/has_overlay = TRUE
	var/image/crate_overlay

	turf_height_offset = 14
	var/opened_turf_height_offset = 3
	var/closed_turf_height_offset = 0

/obj/structure/closet/crate/Initialize()
	. = ..()
	if(!closed_turf_height_offset)
		closed_turf_height_offset = turf_height_offset
	if(has_overlay)
		crate_overlay = OVERLAY(icon, "[icon_closed]over", layer = ABOVE_HUMAN_LAYER)
	update_icon()

/obj/structure/closet/crate/on_update_icon()
	..()
	if(opened && crate_overlay)
		AddOverlays(crate_overlay)

/obj/structure/closet/crate/open()
	if((atom_flags & ATOM_FLAG_OPEN_CONTAINER) && !opened && can_open())
		object_shaken()
	. = ..()
	if(.)
		if(opened_turf_height_offset)
			set_turf_height_offset(opened_turf_height_offset)
		if(rigged)
			visible_message(SPAN_DANGER("There are wires attached to the lid of [src]..."))
			for(var/obj/item/device/assembly_holder/H in src)
				H.process_activation(usr)
			for(var/obj/item/device/assembly/A in src)
				A.activate()

/obj/structure/closet/crate/close()
	. = ..()
	if(. && closed_turf_height_offset)
		set_turf_height_offset(closed_turf_height_offset)

/obj/structure/closet/crate/examine(mob/user, infix)
	. = ..()

	if(rigged && opened)
		var/list/devices = list()
		for(var/obj/item/device/assembly_holder/H in src)
			devices += H
		for(var/obj/item/device/assembly/A in src)
			devices += A
		. += "There are some wires attached to the lid, connected to [english_list(devices)]."

/obj/structure/closet/crate/attackby(obj/item/W, mob/user)
	if(opened)
		return ..()
	else if(istype(W, /obj/item/packageWrap))
		return
	else if(isCoil(W))
		var/obj/item/stack/cable_coil/C = W
		if(rigged)
			to_chat(user, SPAN_NOTICE("[src] is already rigged!"))
			return
		if (C.use(1))
			to_chat(user, SPAN_NOTICE("You rig [src]."))
			rigged = TRUE
			return
	else if(istype(W, /obj/item/device/assembly_holder) || istype(W, /obj/item/device/assembly))
		if(rigged)
			if(istype(W.loc, /obj/item/gripper)) // Snowflaaaaakeeeeey
				var/obj/item/gripper/G = W.loc
				G.wrapped.forceMove(src)
				G.wrapped = null
			else if(!user.drop(W, src))
				return
			to_chat(user, SPAN_NOTICE("You attach [W] to [src]."))
			return
	else if(isWirecutter(W))
		if(rigged)
			to_chat(user, SPAN_NOTICE("You cut away the wiring."))
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			rigged = FALSE
			return
	else
		return ..()

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	req_access = list(access_mailsorting)

	setup = CLOSET_HAS_LOCK
	locked = TRUE

/obj/structure/closet/crate/secure/on_update_icon()
	..()
	if(broken)
		AddOverlays(emag)
	else if(locked)
		AddOverlays(redlight)
	else
		AddOverlays(greenlight)

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "plasticcrate"
	icon_opened = "plasticcrateopen"
	icon_closed = "plasticcrate"
	points_per_crate = 1
	material = /obj/item/stack/material/plastic

/obj/structure/closet/crate/handmade
	name = "handmade crate"
	desc = "Another handmade by a young assistant. Crude crate, now it`s more steel than plasteel."
	icon_state = "handmadecrate"
	icon_opened = "handmadecrateopen"
	icon_closed = "handmadecrate"

/obj/structure/closet/crate/internals
	name = "internals crate"
	desc = "A internals crate."
	icon_state = "o2crate"
	icon_opened = "o2crateopen"
	icon_closed = "o2crate"

/obj/structure/closet/crate/internals/fuel
	name = "\improper Fuel tank crate"
	desc = "A fuel tank crate."

/obj/structure/closet/crate/internals/fuel/WillContain()
	return list(/obj/item/tank/hydrogen = 4)

/obj/structure/closet/crate/trashcart
	name = "trash cart"
	desc = "A heavy, metal trashcart with wheels."
	icon_state = "trashcart"
	icon_opened = "trashcartopen"
	icon_closed = "trashcart"
	pull_slowdown = PULL_SLOWDOWN_LIGHT

	turf_height_offset = 15
	opened_turf_height_offset = 4

/obj/structure/closet/crate/medical
	name = "medical crate"
	desc = "A medical crate."
	icon_state = "medicalcrate"
	icon_opened = "medicalcrateopen"
	icon_closed = "medicalcrate"

/obj/structure/closet/crate/rcd
	name = "\improper RCD crate"
	desc = "A crate with rapid construction device."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/rcd/WillContain()
	return list(
		/obj/item/rcd_ammo = 3,
		/obj/item/construction/rcd
	)

/obj/structure/closet/crate/solar
	name = "solar pack crate"

/obj/structure/closet/crate/solar/WillContain()
	return list(
		/obj/item/solar_assembly = 14,
		/obj/item/circuitboard/solar_control,
		/obj/item/tracker_electronics,
		/obj/item/paper/solar
	)

/obj/structure/closet/crate/solar_assembly
	name = "solar assembly crate"

/obj/structure/closet/crate/solar_assembly/WillContain()
	return list(/obj/item/solar_assembly = 16)

/obj/structure/closet/crate/freezer
	name = "freezer"
	desc = "A freezer."
	icon_state = "freezer"
	icon_opened = "freezeropen"
	icon_closed = "freezer"
	turf_height_offset = 15
	var/target_temp = -40 CELSIUS
	var/cooling_power = 40

	return_air()
		var/datum/gas_mixture/gas = (..())
		if(!gas)	return null
		var/datum/gas_mixture/newgas = new /datum/gas_mixture()
		newgas.copy_from(gas)
		if(newgas.temperature <= target_temp)	return

		if((newgas.temperature - cooling_power) > target_temp)
			newgas.temperature -= cooling_power
		else
			newgas.temperature = target_temp
		return newgas

/obj/structure/closet/crate/freezer/rations //Fpr use in the escape shuttle
	name = "emergency rations"
	desc = "A crate of emergency rations."


/obj/structure/closet/crate/freezer/rations/WillContain()
	return list(/obj/item/reagent_containers/food/liquidfood = 4)

/obj/structure/closet/crate/bin
	name = "large bin"
	desc = "A large bin."
	icon_state = "largebin"
	icon_opened = "largebinopen"
	icon_closed = "largebin"

	turf_height_offset = 16
	opened_turf_height_offset = 2

/obj/structure/closet/crate/radiation
	name = "radioactive crate"
	desc = "A leadlined crate with a radiation sign on it."
	icon_state = "radiation"
	icon_opened = "radiationopen"
	icon_closed = "radiation"
	rad_resist_type = /datum/rad_resist/crate_radiation

/datum/rad_resist/crate_radiation
	alpha_particle_resist = 808 MEGA ELECTRONVOLT
	beta_particle_resist = 24 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"
	icon_opened = "scicrateopen"
	icon_closed = "scicrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	desc = "An engineering crate."
	icon_state = "engicrate"
	icon_opened = "engicrateopen"
	icon_closed = "engicrate"

/obj/structure/closet/crate/radiation_gear
	name = "radioactive gear crate"
	desc = "A crate with a radiation sign on it."
	icon_state = "radiation"
	icon_opened = "radiationopen"
	icon_closed = "radiation"


/obj/structure/closet/crate/radiation_gear/WillContain()
	return list(/obj/item/clothing/suit/radiation = 8)

/obj/structure/closet/crate/secure/weapon
	name = "weapons crate"
	desc = "A secure weapons crate."
	icon_state = "weaponcrate"
	icon_opened = "weaponcrateopen"
	icon_closed = "weaponcrate"
	req_access = list(access_security)

/obj/structure/closet/crate/secure/science
	name = "science crate"
	desc = "A secure science crate."
	icon_state = "scisecurecrate"
	icon_opened = "scisecurecrateopen"
	icon_closed = "scisecurecrate"
	req_access = list(access_research)

/obj/structure/closet/crate/secure/engineering
	name = "engineering crate"
	desc = "A secure engineering crate."
	icon_state = "engisecurecrate"
	icon_opened = "engisecurecrateopen"
	icon_closed = "engisecurecrate"
	req_access = list(access_engine)

/obj/structure/closet/crate/secure/plasma
	name = "plasma crate"
	desc = "A secure plasma crate."
	icon_state = "plasmacrate"
	icon_opened = "plasmacrateopen"
	icon_closed = "plasmacrate"
	req_access = list(access_medical,access_research,access_engine)

/obj/structure/closet/crate/secure/gear
	name = "gear crate"
	desc = "A secure gear crate."
	icon_state = "secgearcrate"
	icon_opened = "secgearcrateopen"
	icon_closed = "secgearcrate"
	req_access = list(access_security)

/obj/structure/closet/crate/secure/hydrosec
	name = "secure hydroponics crate"
	desc = "A crate with a lock on it, painted in the scheme of botany and botanists."
	icon_state = "hydrosecurecrate"
	icon_opened = "hydrosecurecrateopen"
	icon_closed = "hydrosecurecrate"
	req_access = list(access_mailsorting, access_hydroponics)

/obj/structure/closet/crate/secure/bin
	name = "secure bin"
	desc = "A secure bin."
	icon_state = "largebins"
	icon_opened = "largebinsopen"
	icon_closed = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"

	turf_height_offset = 16
	opened_turf_height_offset = 2

/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"

	storage_capacity = 2 * MOB_LARGE
	storage_types = CLOSET_STORAGE_ITEMS|CLOSET_STORAGE_STRUCTURES

	has_overlay = FALSE
	turf_height_offset = 0
	opened_turf_height_offset = 0

/obj/structure/closet/crate/large/hydroponics
	icon_state = "hydro_crate_large"
	icon_opened = "hydro_crate_large_open"
	icon_closed = "hydro_crate_large"

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	redlight = "largemetalr"
	greenlight = "largemetalg"

	storage_capacity = 2 * MOB_LARGE
	storage_types = CLOSET_STORAGE_ITEMS|CLOSET_STORAGE_STRUCTURES

	has_overlay = FALSE
	turf_height_offset = 0
	opened_turf_height_offset = 0

/obj/structure/closet/crate/secure/large/plasma
	icon_state = "plasma_crate_large"
	icon_opened = "plasma_crate_large_open"
	icon_closed = "plasma_crate_large"
	req_access = list(access_mailsorting, access_medical, access_research, access_engine)

/obj/structure/closet/crate/secure/large/plasma/supermatter
	name = "supermatter crate"
	req_access = list(access_engine)

/obj/structure/closet/crate/secure/large/plasma/supermatter/prespawned/WillContain()
	return list(/obj/machinery/power/supermatter)
//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"
	icon_opened = "hydrocrateopen"
	icon_closed = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned/WillContain()
	return list(
		/obj/item/reagent_containers/spray/plantbgone = 2,
		/obj/item/material/minihoe = 2,
		/obj/item/storage/plants = 2,
		/obj/item/material/hatchet = 2,
		/obj/item/wirecutters/clippers = 2,
		/obj/item/device/analyzer/plant_analyzer = 2
	)

/obj/structure/closet/crate/secure/biohazard
	name = "biohazard cart"
	desc = "A heavy cart with extensive sealing. You shouldn't eat things you find in it."
	icon_state = "biohazard"
	icon_opened = "biohazardopen"
	icon_closed = "biohazard"
	open_sound = 'sound/items/Deconstruct.ogg'
	close_sound = 'sound/items/Deconstruct.ogg'
	req_access = list(access_mailsorting, access_xenobiology ,access_virology)
	storage_types = CLOSET_STORAGE_ITEMS|CLOSET_STORAGE_MOBS
	pull_slowdown = PULL_SLOWDOWN_LIGHT

	turf_height_offset = 15
	opened_turf_height_offset = 4

/obj/structure/closet/crate/secure/biohazard/blanks/WillContain()
	return list(/mob/living/carbon/human/blank, /obj/item/usedcryobag)

/obj/structure/closet/crate/paper_refill
	name = "paper refill crate"
	desc = "A rectangular plastic crate, filled up with blank papers for refilling bins and printers. A bureaucrat's favorite."
	icon_state = "plasticcrate"
	icon_opened = "plasticcrateopen"
	icon_closed = "plasticcrate"

/obj/structure/closet/crate/paper_refill/WillContain()
	return list(/obj/item/paper = 30)

/obj/structure/closet/crate/uranium
	name = "fissibles crate"
	desc = "A crate with a radiation sign on it."
	icon_state = "radiation"
	icon_opened = "radiationopen"
	icon_closed = "radiation"


/obj/structure/closet/crate/uranium/WillContain()
	return list(/obj/item/stack/material/uranium/ten = 5)

/obj/structure/closet/crate/pig
	name = "pig crate"
	desc = "A pink crate with a pig's face on it."
	icon_state = "pigcrate"
	icon_opened = "pigcrateopen"
	icon_closed = "pigcrate"
