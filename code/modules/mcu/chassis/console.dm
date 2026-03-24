/obj/item/mcu_chassis/stationary/console
	name = "console"
	desc = "A stationary computer."
	icon = 'icons/obj/mcu.dmi'
	icon_state = "console"
	cooling_bonus = 0.6
	max_health = 80

/obj/item/mcu_chassis/stationary/console/__on_mcu_on()
	ClearOverlays()

	AddOverlays(OVERLAY(icon, "console-on"))

/obj/item/mcu_chassis/stationary/console/__on_mcu_off(is_trap = FALSE)
	ClearOverlays()

	if(is_trap)
		AddOverlays(OVERLAY(icon, "console-bsod"))
