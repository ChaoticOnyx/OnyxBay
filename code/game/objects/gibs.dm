/proc/gibs(atom/location, var/datum/disease/virus,var/datum/disease2/disease/virus2 = null)
	var/obj/decal/cleanable/blood/gibs/gib = null

	// NORTH
	gib = new /obj/decal/cleanable/blood/gibs(location)
	if (prob(30))
		gib.icon_state = "gibup1"
	gib.virus = virus
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))
	if(virus2)
		gib.virus2 = virus2.getcopy()

	// SOUTH
	gib = new /obj/decal/cleanable/blood/gibs(location)
	if (prob(30))
		gib.icon_state = "gibdown1"
	gib.virus = virus
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))
	if(virus2)
		gib.virus2 = virus2.getcopy()
	// WEST
	gib = new /obj/decal/cleanable/blood/gibs(location)
	gib.virus = virus
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))
	if(virus2)
		gib.virus2 = virus2.getcopy()
	// EAST
	gib = new /obj/decal/cleanable/blood/gibs(location)
	gib.virus = virus
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))
	if(virus2)
		gib.virus2 = virus2.getcopy()
	// RANDOM BODY
	gib = new /obj/decal/cleanable/blood/gibs/body(location)
	gib.virus = virus
	gib.streak(cardinal8)
	if(virus2)
		gib.virus2 = virus2.getcopy()
	// RANDOM LIMBS
	for (var/i = 0, i < pick(0, 1, 2), i++)
		gib = new /obj/decal/cleanable/blood/gibs/limb(location)
		gib.virus = virus
		gib.streak(cardinal8)
		if(virus2)
			gib.virus2 = virus2.getcopy()
	// CORE
	gib = new /obj/decal/cleanable/blood/gibs/core(location)
	gib.virus = virus
	if(virus2)
		gib.virus2 = virus2.getcopy()
/proc/robogibs(atom/location, var/datum/disease/virus)
	var/obj/decal/cleanable/robot_debris/gib = null

	// RUH ROH
	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(2, 1, location)
	s.start()

	// NORTH
	gib = new /obj/decal/cleanable/robot_debris(location)
	if (prob(25))
		gib.icon_state = "gibup1"
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))

	// SOUTH
	gib = new /obj/decal/cleanable/robot_debris(location)
	if (prob(25))
		gib.icon_state = "gibdown1"
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))

	// WEST
	gib = new /obj/decal/cleanable/robot_debris(location)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))

	// EAST
	gib = new /obj/decal/cleanable/robot_debris(location)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))

	// RANDOM
	gib = new /obj/decal/cleanable/robot_debris(location)
	gib.streak(cardinal8)

	// RANDOM LIMBS
	for (var/i = 0, i < pick(0, 1, 2), i++)
		gib = new /obj/decal/cleanable/robot_debris/limb(location)
		gib.streak(cardinal8)
