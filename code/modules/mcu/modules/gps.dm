/obj/item/mcu_module/gps
	name = "GPS module"
	desc = "A GPS module"
	icon_state = "gps"

	device_type = Z_DEVICE_TYPE_GPS

/obj/item/mcu_module/gps/__reset(attached)
	if(!attached)
		return
