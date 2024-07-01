/obj/machinery/atmospherics/unary/engine
	name = "rocket nozzle"
	desc = "Simple rocket nozzle, expelling gas at hypersonic velocities to propell the ship."
	icon = 'icons/obj/ship_engine.dmi'
	icon_state = "nozzle"
	layer = STRUCTURE_LAYER
	opacity = TRUE
	density = TRUE
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_FUEL
	use_power = POWER_USE_ACTIVE
	power_channel = STATIC_EQUIP
	idle_power_usage = 2320
	active_power_usage = 2320
	var/engine_extension = /datum/extension/ship_engine/gas

/obj/machinery/atmospherics/unary/engine/Initialize()
	. = ..()
	update_nearby_tiles(need_rebuild=1)
	set_extension(src, /datum/extension/ship_engine, /datum/extension/ship_engine/gas)
	var/obj/structure/overmap/OM = get_overmap()
	OM?.engines |= src

/obj/machinery/atmospherics/unary/engine/on_update_icon()
	ClearOverlays()
	if(operable())
		AddOverlays(emissive_appearance(icon, "indicator_power"))
		if(use_power)
			AddOverlays(emissive_appearance(icon, "nozzle_idle"))

/obj/machinery/atmospherics/unary/engine/attackby(obj/item/I, mob/user)
	if(isMultitool(I) && !panel_open)
		var/datum/extension/ship_engine/engine = get_extension(src, /datum/extension/ship_engine)
		if(engine.sync_to_ship())
			to_chat(user, SPAN_NOTICE("\The [src] emits a ping as it syncs its controls to a nearby ship."))
		else
			to_chat(user, SPAN_WARNING("\The [src] flashes an error!"))
		return TRUE

	return ..()

/obj/machinery/atmospherics/unary/engine/CanPass(atom/movable/mover, turf/target)
	return FALSE

/obj/machinery/atmospherics/unary/engine/Destroy()
	update_nearby_tiles()
	return ..()

/obj/machinery/atmospherics/unary/engine/power_change()
	. = ..()
	if(stat & NOPOWER)
		update_use_power(POWER_USE_OFF)
	else if(operable(MAINT))
		update_use_power(POWER_USE_ACTIVE)

/obj/machinery/atmospherics/unary/engine/RefreshParts()
	..()
	var/datum/extension/ship_engine/E = get_extension(src, /datum/extension/ship_engine)
	if(!E)
		return

	///allows them to upgrade the max limit of fuel intake (which only gives diminishing returns) for increase in max thrust but massive reduction in fuel economy
	//var/bin_upgrade = 10 * clamp(total_component_rating_of_type(/obj/item/stock_parts/matter_bin), 0, 6)//5 litre per rank
	//E.volume_per_burn = bin_upgrade ? initial(E.volume_per_burn) + bin_upgrade : 2 //Penalty missing part: 10% fuel use, no thrust
	E.volume_per_burn = 2 //Penalty missing part: 10% fuel use, no thrust
	//E.boot_time = bin_upgrade ? initial(E.boot_time) - bin_upgrade : initial(E.boot_time) * 2
	E.boot_time = initial(E.boot_time) * 2
	//energy cost - thb all of this is to limit the use of back up batteries
	//var/energy_upgrade = clamp(total_component_rating_of_type(/obj/item/stock_parts/capacitor), 0.1, 6)
	//E.charge_per_burn = initial(E.charge_per_burn) / energy_upgrade
	E.charge_per_burn = initial(E.charge_per_burn)
	//change_power_consumption(initial(idle_power_usage) / energy_upgrade, POWER_USE_IDLE)
	change_power_consumption(initial(idle_power_usage), POWER_USE_IDLE)

//Exhaust effect
/obj/effect/engine_exhaust
	name = "engine exhaust"
	icon = 'icons/turf/thruster_big.dmi'
	icon_state = "nozzle_burn"
	light_color = "#00a2ff"
	anchored = TRUE

/obj/effect/engine_exhaust/Initialize(mapload, ndir)
	. = ..(mapload)
	if(isturf(loc))
		var/turf/T = loc
		T.hotspot_expose(1000,125)
	set_light(5, 2)
	set_dir(ndir)
	QDEL_IN(src, 2 SECONDS)

// This comes with an additional terminal component and tries to set it up on init (you should map a terminal beneath it). This is for mapping only.
/obj/machinery/atmospherics/unary/engine/terminal
