/obj/item/fighter_component/armour_plating
	name = "durasteel armour plates"
	desc = "A set of armour plates which can afford basic protection to a fighter, however heavier plates may slow you down"
	icon_state = "armour_tier1"
	slot = HARDPOINT_SLOT_ARMOUR
	weight = 1
	integrity = 250
	max_integrity = 250
	armor = list("melee" = 50, "bullet" = 40, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //Armour's pretty tough.
	var/repair_speed = 25 // How much integrity you can repair per second
	var/busy = FALSE
