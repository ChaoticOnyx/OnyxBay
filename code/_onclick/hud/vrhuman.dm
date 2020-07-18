/mob/living/carbon/human/vrhuman
	hud_type = /datum/hud/human/vrhuman

/datum/hud/human/vrhuman/FinalizeInstantiation()
	. = ..()

	var/mob/living/carbon/human/vrhuman/V = mymob
	V.vrhuman_shop = new /obj/screen/vrhuman_shop()
	V.vrhuman_shop.icon = 'icons/mob/screen_vrhuman.dmi'
	V.vrhuman_shop.icon_state = "vrui_shop"
	V.vrhuman_shop.screen_loc = ui_vrhuman_shop
	V.vrhuman_shop.alpha = 0

	V.vrhuman_exit = new /obj/screen/vrhuman_exit()
	V.vrhuman_exit.icon = 'icons/mob/screen_vrhuman.dmi'
	V.vrhuman_exit.icon_state = "vrui_exit"
	V.vrhuman_exit.screen_loc = ui_vrhuman_exit
	V.vrhuman_exit.alpha = 0

	V.vrhuman_main = new /obj/screen/vrhuman_main()
	V.vrhuman_main.icon = 'icons/mob/screen_vrhuman.dmi'
	V.vrhuman_main.icon_state = "vrui_main"
	V.vrhuman_main.screen_loc = ui_vrhuman_main

	V.vrhuman_cleanup = new /obj/screen/vrhuman_cleanup()
	V.vrhuman_cleanup.icon = 'icons/mob/screen_vrhuman.dmi'
	V.vrhuman_cleanup.icon_state = "vrui_cleanup"
	V.vrhuman_cleanup.screen_loc = ui_vrhuman_cleanup
	V.vrhuman_cleanup.alpha = 0


	V.client.screen += list(V.vrhuman_shop, V.vrhuman_exit, V.vrhuman_main, V.vrhuman_cleanup)
	V.client.screen += mymob.client.void

/obj/screen/vrhuman_shop/Click(location, control, params)
	var/mob/living/carbon/human/vrhuman/V = usr
	if(!V.vr_shop.vr_mind)
		V.vr_shop.vr_mind = V.mind
	V.vr_shop.trigger(V)

/obj/screen/vrhuman_exit/Click(location, control, params)
	var/mob/living/carbon/human/vrhuman/V = usr
	V.exit_body()

/obj/screen/vrhuman_cleanup/Click(location, control, params)
	var/mob/living/carbon/human/vrhuman/V = usr
	V.try_cleanup()

/obj/screen/vrhuman_main
	var/hidden = TRUE

/obj/screen/vrhuman_main/Click(location, control, params)
	var/mob/living/carbon/human/vrhuman/V = usr
	hidden = !hidden
	if(hidden)
		V.vrhuman_exit.alpha = 0
		V.vrhuman_shop.alpha = 0
		V.vrhuman_cleanup.alpha = 0
		icon_state = "vrui_main"
	else
		V.vrhuman_exit.alpha = 255
		V.vrhuman_shop.alpha = 255
		V.vrhuman_cleanup.alpha = 255
		icon_state = "vrui_main_open"
