/obj/structure/overmap/small_craft/combat/light
	name = "Su-818 Rapier"
	desc = "An Su-818 Rapier space superiorty fighter craft. Designed for high maneuvreability and maximum combat effectiveness against other similar weight classes."
	icon = 'icons/overmap/nanotrasen/fighter.dmi'
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 200 //Really really squishy!
	max_angular_acceleration = 200
	speed_limit = 10
	pixel_w = -16
	pixel_z = -20
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary,
						)
