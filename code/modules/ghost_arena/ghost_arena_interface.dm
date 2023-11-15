/obj/screen/arena_round_timer
	screen_loc = "1,1"
	layer = HUD_ABOVE_ITEM_LAYER

	mouse_opacity = 0
	alpha = 20 //Animated up when loading

/mob/living/carbon/human/arenahuman
	hud_type = /datum/hud/human/arenahuman

/datum/hud/human/arenahuman/FinalizeInstantiation()
	. = ..()

	var/mob/living/carbon/human/arenahuman/A = mymob
	A.arenahuman_timer = new /obj/screen/arenahuman_timer()
	//A.arenahuman_timer.icon = 'icons/hud/mob/screen_vrhuman.dmi'
	//A.arenahuman_timer.icon_state = "vrui_shop"
	A.arenahuman_timer.screen_loc = "NORTH:10,CENTER"
	A.arenahuman_timer.alpha = 200

	A.arenahuman_money = new /obj/screen/arenahuman_money()
	//A.arenahuman_timer.icon = 'icons/hud/mob/screen_vrhuman.dmi'
	//A.arenahuman_timer.icon_state = "vrui_shop"
	A.arenahuman_money.screen_loc = "EAST-1:28,CENTER"
	A.arenahuman_money.alpha = 200

	A.arenahuman_sec_counter = new /obj/screen/sec_counter()
	A.arenahuman_sec_counter.screen_loc = "NORTH:10,CENTER-2"
	A.arenahuman_sec_counter.alpha = 200

	A.arenahuman_grey_counter = new /obj/screen/greytide_counter()
	A.arenahuman_grey_counter.screen_loc = "NORTH:10,CENTER+2"
	A.arenahuman_grey_counter.alpha = 200

	A.client.screen += list(A.arenahuman_timer, A.arenahuman_money, A.arenahuman_sec_counter, A.arenahuman_grey_counter)
	A.client.screen += mymob.client.void

/obj/screen/arenahuman_timer
	name = "arenahuman timer"

/obj/screen/arenahuman_money

/obj/screen/sec_counter

/obj/screen/greytide_counter
