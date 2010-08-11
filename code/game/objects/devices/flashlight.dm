#define FLASHLIGHT_LUM 4

/obj/item/device/flashlight/attack_self(mob/user)
	on = !on
	icon_state = "flight[on]"

	if(on)
		user.ul_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)
	else
		user.ul_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)


/obj/item/device/flashlight/pickup(mob/user)
	if(on)
		src.ul_SetLuminosity(0)
		user.ul_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)



/obj/item/device/flashlight/dropped(mob/user)
	if(on)
		user.ul_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)
		src.ul_SetLuminosity(FLASHLIGHT_LUM)

/obj/item/clothing/head/helmet/hardhat/attack_self(mob/user)
	on = !on
	icon_state = "hardhat[on]"
	item_state = "hardhat[on]"

	if(on)
		user.ul_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)
	else
		user.ul_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)

/obj/item/clothing/head/helmet/hardhat/pickup(mob/user)
	if(on)
		src.ul_SetLuminosity(0)
		user.ul_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)



/obj/item/clothing/head/helmet/hardhat/dropped(mob/user)
	if(on)
		user.ul_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)
		src.ul_SetLuminosity(FLASHLIGHT_LUM)