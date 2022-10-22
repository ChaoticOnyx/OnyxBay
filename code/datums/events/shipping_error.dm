/datum/event/shipping_error
	id = "shipping_error"
	name = "Shipping Error"
	description = "A random parcel will appear in the cargo department"

	mtth = 1 HOURS
	difficulty = 10

/datum/event/shipping_error/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (4 MINUTES))
	. = max(1 HOUR, .)

/datum/event/shipping_error/on_fire()
	var/datum/supply_order/O = new /datum/supply_order()
	O.ordernum = SSsupply.ordernum
	O.object = pick(cargo_supply_packs)
	O.orderedby = random_name(pick(MALE,FEMALE), species = SPECIES_HUMAN)
	SSsupply.shoppinglist += O
