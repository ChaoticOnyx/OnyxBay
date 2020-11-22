
/obj/item/weapon/backwear/powered/rpd
	name = "rapid piping pack"
	desc = "A heavy and bulky backpack-shaped device. It can be used to quickly set up or dismantle pipelines using nothing but electrical power."
	icon_state = "pipe1"
	base_icon = "pipe"
	item_state = "backwear_rpd"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/weapon/rpd/linked
	bcell = null
	atom_flags = null
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)
	action_button_name = "RPD"

/obj/item/weapon/rpd/linked
	name = "rapid piping device"
	desc = "A device used to rapidly pipe things."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "rpd0"
	item_state = "rpd"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 0.75
	mod_handy = 1.0
	unacidable = 1 //TODO: make these replaceable so we won't need such ducttaping
	origin_tech = null
	matter = null
	var/datum/effect/effect/system/spark_spread/spark_system
