/obj/item/fighter_component/fuel_tank
	name = "Fighter Fuel Tank"
	desc = "The fuel tank of a fighter, upgrading this lets your fighter hold more fuel."
	icon_state = "fueltank_tier1"
	var/fuel_capacity = 1000
	slot = HARDPOINT_SLOT_FUEL

/obj/item/fighter_component/fuel_tank/Initialize(mapload)
	. = ..()
	create_reagents(fuel_capacity)
	reagents.add_reagent(/datum/reagent/cryogenic_fuel, fuel_capacity)
