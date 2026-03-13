/obj/item/mcu_chassis/tablet
	name = "tablet computer"
	desc = "A small portable microcomputer"
	icon = 'icons/obj/mcu.dmi'
	icon_state = "tablet"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 50)
	origin_tech = list(TECH_ENGINEERING = 1)
	max_health = 10
	cooling_bonus = 0.15

/obj/item/mcu_chassis/tablet/__on_mcu_on()
	ClearOverlays()

	AddOverlays(OVERLAY(icon, "tablet-on"))

/obj/item/mcu_chassis/tablet/__on_mcu_off(is_trap = FALSE)
	ClearOverlays()

	if(is_trap)
		AddOverlays(OVERLAY(icon, "tablet-bsod"))

/obj/item/mcu_chassis/tablet/__on_mcu_insert()
	if(__mcu.is_on())
		__on_mcu_on()
	else
		__on_mcu_off(FALSE)

/obj/item/mcu_chassis/tablet/__on_mcu_eject()
	__on_mcu_off(FALSE)
