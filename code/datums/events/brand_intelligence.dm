/datum/event2/brand_intelligence
	id = "brand_intelligence"
	name = "Brand Intelligence"
	description = "There will be a virus infecting vending machines"

	mtth = 4 HOURS
	fire_only_once = TRUE

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedVendingMachines = list()
	var/obj/machinery/vending/originMachine
	var/end_timer
	var/list/affecting_z = list()

/datum/event2/brand_intelligence/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Janitor"] * (15 MINUTES))
	. = max(1 HOUR, .)

/datum/event2/brand_intelligence/get_conditions_description()
	. = "<em>Brand Intelligence</em> should not be <em>running</em>.<br>"

/datum/event2/brand_intelligence/check_conditions()
	. = SSevents.evars["brand_intelligence_running"] != TRUE

/datum/event2/brand_intelligence/on_fire()
	GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	for(var/obj/machinery/vending/V in GLOB.machines)
		if(V.z in affecting_z)
			vendingMachines += weakref(V)

	if(!length(vendingMachines))
		return

	originMachine = pick(vendingMachines).resolve()
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1
	originMachine.shooting_chance = 15

	SSevents.evars["brand_intelligence_running"] = TRUE

	end_timer = addtimer(CALLBACK(src, .proc/announce), 10 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	set_next_think(world.time)

/datum/event2/brand_intelligence/think()
	// If every machine is infected, or if the original vending machine is missing or has it's voice switch flipped or fixed
	if(!vendingMachines.len || QDELETED(originMachine) || originMachine.shut_up || !originMachine.shoot_inventory)
		end()
		return

	if(prob(15))
		var/weakref/W = pick(vendingMachines)
		vendingMachines -= W
		var/obj/machinery/vending/infectedMachine = W.resolve()
		if(infectedMachine)
			infectedVendingMachines += W
			infectedMachine.shut_up = 0
			infectedMachine.shoot_inventory = 1

	originMachine.speak(pick("Try our aggressive new marketing strategies!", \
								"You should buy products to feed your lifestyle obsession!", \
								"Consume!", \
								"Your money can buy happiness!", \
								"Engage direct marketing!", \
								"Advertising is legalized lying! But don't let that put you off our great deals!", \
								"You don't want to buy anything? Yeah, well I didn't want to buy your mom either."))

	set_next_think(world.time + 5 SECONDS)

/datum/event2/brand_intelligence/proc/end()
	SSevents.evars["brand_intelligence_running"] = FALSE
	deltimer(end_timer)
	set_next_think(0)

	originMachine.shut_up = 1
	originMachine.shooting_chance = initial(originMachine.shooting_chance)
	for(var/weakref/W in infectedVendingMachines)
		var/obj/machinery/vending/infectedMachine = W.resolve()
		if(!infectedMachine)
			continue
		infectedMachine.shut_up = 1
		infectedMachine.shoot_inventory = 0
	
	if(GLOB.using_map.type == /datum/map/polar)
		command_announcement.Announce(
			"All traces of the rampant brand intelligence have disappeared from the systems.",
			"[station_name()] Firewall Subroutines",
			new_sound = 'sound/AI/polar/rampant_end.ogg'
		)
	else
		command_announcement.Announce("All traces of the rampant brand intelligence have disappeared from the systems.", "[station_name()] Firewall Subroutines")

	originMachine = null
	infectedVendingMachines.Cut()
	vendingMachines.Cut()

/datum/event2/brand_intelligence/proc/announce()
	var/list/affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	if(GLOB.using_map.type == /datum/map/polar)
		command_announcement.Announce(
			"Rampant brand intelligence has been detected aboard the Pathos-I. The origin is believed to be \a \"[initial(originMachine.name)]\" type. Fix it, before it spreads to other vending machines.",
			"Machine Learning Alert",
			new_sound = 'sound/AI/polar/rampant_announce.ogg'
		)
	else
		command_announcement.Announce(
			"Rampant brand intelligence has been detected aboard the [station_name()]. The origin is believed to be \a \"[initial(originMachine.name)]\" type. Fix it, before it spreads to other vending machines.",
			"Machine Learning Alert",
			zlevels = affecting_z
		)
