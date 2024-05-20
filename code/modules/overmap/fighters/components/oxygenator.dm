/obj/item/fighter_component/oxygenator
	name = "atmospheric regulator"
	desc = "A device which moderates the conditions inside a fighter, it requires fuel to run."
	icon_state = "oxygenator_tier1"
	var/refill_amount = 1 //Starts off really terrible.
	slot = HARDPOINT_SLOT_OXYGENATOR
	weight = 0.5 //Wanna go REALLY FAST? Pack your own O2.
	power_usage = 200
