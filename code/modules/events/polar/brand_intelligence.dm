/datum/event/brand_intelligence/polar/announce()
	command_announcement.Announce(
		"Rampant brand intelligence has been detected aboard the Pathos-I. The origin is believed to be \a \"[initial(originMachine.name)]\" type. Fix it, before it spreads to other vending machines.",
		"Machine Learning Alert",
		zlevels = affecting_z,
		new_sound = 'sound/AI/polar/rampant_announce.ogg'
	)

/datum/event/brand_intelligence/polar/end()
	originMachine.shut_up = 1
	originMachine.shooting_chance = initial(originMachine.shooting_chance)
	for(var/weakref/W in infectedVendingMachines)
		var/obj/machinery/vending/infectedMachine = W.resolve()
		if(!infectedMachine)
			continue
		infectedMachine.shut_up = 1
		infectedMachine.shoot_inventory = 0

	command_announcement.Announce(
		"All traces of the rampant brand intelligence have disappeared from the systems.",
		"[location_name()] Firewall Subroutines",
		zlevels = affecting_z,
		new_sound = 'sound/AI/polar/rampant_end.ogg'
	)
	
	originMachine = null
	infectedVendingMachines.Cut()
	vendingMachines.Cut()
