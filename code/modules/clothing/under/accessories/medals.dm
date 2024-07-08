//Medals!

/obj/item/clothing/accessory/medal
	name = ACCESSORY_SLOT_MEDAL
	desc = "A simple medal."
	icon_state = "bronze"
	slot = ACCESSORY_SLOT_MEDAL
	coverage = 0.03 // Who said medals are useless?
	armor = list(melee = 50, bullet = 90, laser = 120, energy = 65, bomb = 0, bio = 0)
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

/obj/item/clothing/accessory/medal/iron
	name = "iron medal"
	desc = "A simple iron medal."
	icon_state = "iron"
	item_state = "iron"

/obj/item/clothing/accessory/medal/bronze
	name = "bronze medal"
	desc = "A simple bronze medal."
	icon_state = "bronze"
	item_state = "bronze"

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A simple silver medal."
	icon_state = "silver"
	item_state = "silver"

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A simple gold medal."
	icon_state = "gold"
	item_state = "gold"

//NT medals!

/obj/item/clothing/accessory/medal/gold/nanotrasen
	name = "\improper NanoTrasen command medal"
	desc = "A gold medal awarded to NanoTrasen employees for service as the Captain of a NanoTrasen facility, station, or vessel."
	icon_state = "gold_nt"
	item_state = "gold_nt"

/obj/item/clothing/accessory/medal/silver/nanotrasen
	name = "\improper NanoTrasen service medal"
	desc = "A silver medal awarded to NanoTrasen employees for distinguished service in support of corporate interests."
	icon_state = "silver_nt"
	item_state = "silver_nt"

/obj/item/clothing/accessory/medal/bronze/nanotrasen
	name = "\improper NanoTrasen sciences medal"
	desc = "A bronze medal awarded to NanoTrasen employees for signifigant contributions to the fields of science or engineering."
	icon_state = "bronze_nt"
	item_state = "bronze_nt"

/obj/item/clothing/accessory/medal/iron/nanotrasen
	name = "\improper NanoTrasen merit medal"
	desc = "An iron medal awarded to NanoTrasen employees for merit."
	icon_state = "iron_nt"
	item_state = "iron_nt"
